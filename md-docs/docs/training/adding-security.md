---
id: adding-security
title: Adding Security
---

# Adding Security

The first step in restricting data access is to implement authentication and then access rules for every user. It’s typically done in two parts: on Couchbase Lite, you set up authentication by connecting the basic authenticator to the replication object. On Sync Gateway, you need to validate the data before it gets written and read by other users. To start this lesson, download the starter project below.

<div class="buttons-unit downloads">
  <a href="http://cl.ly/3s2T3G2d1p2u/part3_start.zip" class="button">
    Download starter project
  </a>
</div>

[Download Couchbase Lite for iOS](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile). Unzip the file and drag **CouchbaseLite.framework** and **libsqlcipher.a** to the **Frameworks** folder in the starter project.

## User Authentication

To authenticate as a user, you first need to create one. With Sync Gateway, users are registered through the Admin REST API. Follow the instructions below to get Sync Gateway up and running:

1. [Download Sync Gateway](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile)
2. Unzip the file and locate the executable at couchbase-sync-gateway/bin/sync_gateway
3. Start it from the command-line with the configuration file located in the project directory you downloaded above: `$ /path/to/sync_gateway sync-gateway-authentication.json`

Create the user from the command line:

```bash
curl -vX PUT 'http://localhost:4985/todo/_user/user1' -H 'Content-Type: application/json' -d '{"name": "user1","password": "pass"}'
```

This is a quick method to create a user during development but it doesn’t scale. Instead, you would have an App Server create the user by sending the HTTP request above to Sync Gateway. The user creation endpoint of Sync Gateway is on the Admin REST API, so the Sync Gateway and App Server must reside on the same network in the cloud. With the back-end infrastructure in place, your app could have a Sign-Up screen that would send a request to the App Server, creating the user on Sync Gateway.

Since Sync Gateway is running in Walrus mode, the user will be deleted any time you stop or restart it so you will need to issue that Curl command again. An easier way to create users is in the config file itself. Stop the running instance and change the configuration file with the following:

```javascript
"todo": {
  "server": "walrus:",
  "users": {
    "user1": {"password": "pass"},
    "user2": {"password": "pass"}
  }
}
```

Start Sync Gateway.

Now, you will add authentication in Couchbase Lite using the basic authenticator.
Locate the **startReplication** method in **AppDelegate.swift**.
Add the following.

```swift
var authenticator: CBLAuthenticatorProtocol?
if kLoginFlowEnabled {
    authenticator = CBLAuthenticator.basicAuthenticatorWithName(username, password: password!)
}
syncError = nil
pusher = database.createPushReplication(kSyncGatewayUrl)
pusher.continuous = true
pusher.authenticator = authenticator
NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationProgress:",
    name: kCBLReplicationChangeNotification, object: pusher)
puller = database.createPullReplication(kSyncGatewayUrl)
puller.continuous = true
puller.authenticator = authenticator
NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationProgress:",
    name: kCBLReplicationChangeNotification, object: puller)
pusher.start()
puller.start()
```

Here, you are setting up two replicators and connecting the basic authenticator to each one.
Build and run. The application will prompt you to enter a username and password. Use the same credentials defined in the config file previously (user1/pass).

<img src="./img/image00.png" class="portrait" />

All the grocery items in the pre-built database are replicated to Sync Gateway. You can add other lists and tasks as well.

## Read/Write Access Controls

In order to give different users access to different documents, you must write a sync function. You typically write a sync function in the configuration file of Sync Gateway. It’s a JavaScript function and every time a new document, revision or deletion is added to a database, the sync function is called and given a chance to examine the document.  For simple applications it might be the only server-side code you need to write. For more complex applications it is still a primary touchpoint for managing data routing and access control. The first access rule you will write in the sync function is for **task-list** documents.

Download the configuration file below. Stop the running instance of Sync Gateway and start it with the new configuration file.

[Download Sync Gateway Config](http://cl.ly/373k0J462N0o/sync-gateway-config-final.json)

Open it and you will see that the sync function is pretty long - too long to fit in a single code snippet - but we will go through it one section at a time. The sync function should account for every document **type** present in your application, but for brevity we will only discuss the **task-list** document in this section in the following order:

![](./img/image15.png)

If a document makes it through those 3 stages, it will be written to Sync Gateway. If it fails for any of those steps, the whole operation is aborted.

### Controlling Write Access

Write operations are controlled with the **requireUser([]string names)** method. It takes a list of names as argument and rejects the document if the authenticated user is not in that list. If it is then it continues through the execution of the sync function.

```javascript
} else if (getType() == "task-list") {
  /* Control Write Access */
  {
    if (isCreate()) {
      // Only allow users to create task-lists for themselves.
      requireUser(doc.owner);
    } else {
      requireUserOrRole(doc.owner, "moderator");
    }
  }
```

Here, you ensure that users can only create task-lists for themselves with the call to **requireUser**. The built-in functions available in the sync function are:

- **requireUser([]string names)**: authorizes a document update by rejecting it unless it's made by a specific user or users.
- **requireRole([]string roles)**: authorizes a document update by rejecting it unless the user making it has a specific role or roles.
- **requireAccess([]string channels)**: authorizes a document update by rejecting it unless the user making it has access to at least one of the given channels.
- **channel([]string channels)**: routes the document to the named channel(s).
- **access([]string users, []string channels)**: grants access to a channel to a specified user.
- **role([]string users, []string roles)**: grants a user a role, indirectly giving them access to all channels granted to that role.

Users with the moderator role can create task-lists for other users with the call to **requireUserOrRole**. It is a helper function defined within the sync function. It’s often useful to define your own helper functions to prevent code duplication. In this case, the helper functions are defined at the bottom of the sync function. Take a look at them, you may want to reuse them in your own sync function.

### Validating Changes

The next phase is to run data validation on the document. A document that doesn’t follow the schema specified in your application could have an impact on other clients when they receive it. That’s why you must check for the existence of the properties required in your application. Second, some document keys may follow a specific format (user.uuid) that will be used throughout your system so making sure that it follows the desired format is good practice. Last, you may decide that some properties should be immutable and cannot change during an update operation. Two arguments are passed to the sync function for that reason (the current revision and it parent); that way you can enforce immutability where required.The next phase is to run data validation on the document. A document that doesn’t follow the schema specified in your application could have an impact on other clients when they receive it. That’s why you must check for the existence of the properties required in your application. Second, some document keys may follow a specific format (user.uuid) that will be used throughout your system so making sure that it follows the desired format is good practice. Last, you may decide that some properties should be immutable and cannot change during an update operation. Two arguments are passed to the sync function for that reason (the current revision and it parent); that way you can enforce immutability where required.

```javascript
/* Validate */
{
  if (!isDelete()) {
    // Validate required fields.
    validateNotEmpty("name", doc.name);
    validateNotEmpty("owner", doc.owner);
    if (isCreate()) {
      // Validate that the _id is prefixed by owner.
      validatePrefix("_id", doc._id, "owner", doc.owner + ".");
    } else {
      // Don't allow task-list ownership to be changed.
      validateReadOnly("owner", doc.owner, oldDoc.owner);
    }
  }
}
```

There are 3 types of validation performed here:

- validateNotEmpty checks that the name and owner properties exist.
- validatePrefix validates that the document ID conforms to the user.uuid format.
- validateReadOnly enforces immutable on the owner property.

### Controlling Read Access

Once the write access permissions and validation have been applied successfully, you insert the document in a channel. You can think of it as tagging lots of documents with the same label. There is no limit to how many documents can be mapped to a channel and you can create as many channels as you want.

```javascript
/* Route */
{
  // Add doc to task-list's channel.
  channel("task-list." + doc._id);
  channel("moderators");
}
```

Next, you will give the moderator role to user1. Send the following request from the command line.

```bash
curl -H 'Content-Type: application/json' -vX POST 'http://admin:admin@localhost:4984/todo/' -d '{"_id": "moderator.user1", "type": "moderator", "username": "user1"}'
```

What is moderator supposed to do?

## Database Encryption

Besides enabling authentication and data access rules in the sync function, the Couchbase Lite API allows you to encrypt the database on the device. By providing an encryption key, all the data stored in the database will be secure. To decrypt it in the future, the same key must be used. 

The project already includes the required components to enable encryption. You can refer to the documentation to include them in your application. Previously, the database was created unencrypted so you must delete the application to start from a fresh state. You can also convert an unencrypted database to be encrypted using the **changeEncryptionKey** method, but we won’t cover it here.

<img src="./img/image17.png" class="portrait" />

Open **AppDelegate.swift** and scroll to the **openDatabase** method. This method is called from **startSession** which is in turn getting called in **processLogin** after the user has logged in. Currently this method uses the **databaseNamed** method. Replace the body of **openDatabase** with the following.

```swift
let dbname = username
let options = CBLDatabaseOptions()
options.create = true
if kEncryptionEnabled {
    if let encryptionKey = key {
        options.encryptionKey = encryptionKey
    }
}
try database = CBLManager.sharedInstance().openDatabaseNamed(dbname, withOptions: options)
```

Build and run.

## Offline Login

What about the scenario where a user attempts to login while being offline? Since data may already be in the database, it would be nice to allow the app to use it. From the previous section, you’ve learned that the database can be safely accessed with an encryption key so the user can attempt to enter credentials as if they were online (the **name** and **password** of the Sync Gateway user). To achieve offline login, you are mapping the user’s **name** to be the **database name** and the user’s **password** to be the **encryption key**.

If the user enters an incorrect password (that is not the valid encryption key), the database will return an error with a status code of 401 to indicate it’s the wrong password.

To make it even more challenging, consider the scenario where a user’s password has been modified on Sync Gateway. Since the encryption key is the old password it will not be accessible, so when the user’s password changes on Sync Gateway the local encryption key and server password will be out of sync. To detect that, you’re going to use the replication change event and check for the status code. If it’s a 401, you will logout the user and display the login screen. However, the data stored in the database will have changes that were not pushed to Sync Gateway yet. You can offer users the ability to update the encryption key only if they remember their old password (because it’s the only way to open and read data from the database encrypted with the old password). If they don’t remember it, the changes made while they were offline will be lost. The marble diagram below shows every scenario and outcome.

![](./img/image24.png)

In **AppDelegate.swift**, scroll to the **processLogin** method. Notice that if an error with status 401 is thrown it calls **handleEncryptionError** which displays a popup with an input text and two options.

<img src="./img/image27.png" class="portrait" />

When the user clicks **Delete** it will remove the database and create a new one with no data in it. If the user remembers the old password and clicks **Migrate** it will call the **processLogin** method again passing it the old and new encryption keys.
Add the following code at the end of the **openDatabase** method to change the encryption after it was opened.

```swift
if newKey != nil {
    try database.changeEncryptionKey(newKey)
}
```

Build and run.
Change the password for the user with the following curl request.

```bash
curl -vX PUT 'http://localhost:4985/todo/_user/user1' -H 'Content-Type: application/json' -d '{"name": "user1","password": "newpass"}'
```

Add a new task list which will wake up the replicator to push the new document. Since the user credentials have changed, the task list will not be persisted to Sync Gateway. The way to get notified of this is by checking the replication **lastError** property in the replication change event. In this case it will be a **401 Unauthorized**.

The **lastError** property is checked in the **replicationProgress** method of **AppDelegate.swift**.

```swift
func replicationProgress(notification: NSNotification) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible =
        (pusher.status == .Active || puller.status == .Active)
    let error = pusher.lastError ?? puller.lastError
    if (error != syncError) {
        syncError = error
        if let errorCode = error?.code {
            NSLog("Replication Error: %@", error!)
            if errorCode == 401 {
                Ui.showMessageDialog(
                    onController: self.window!.rootViewController!,
                    withTitle: "Authentication Error",
                    withMessage:"Your username or password is not correct.",
                    withError: nil,
                    onClose: {
                        self.logout()
                })
            }
        }
    }
}
```

If the error code is 401 it displays the popup below and logs the user out of the application.

<img src="./img/image18.png" class="portrait" />

Click **OK** and on the login screen type **user1** and **newpass**.
Type a new password on the login screen. Next, type the current password on the ‘Password Changed’ popup.

<img src="./img/image00.png" class="portrait" />

Click **Login** and on the ‘Password Changed’ popup and enter **pass** (the previous password).

<img src="./img/image14.png" class="portrait" />

Click **Migrate**. Notice that the list added after the password changed is there.

<img src="./img/image10.png" class="portrait" />

### Key Rotation

Key rotation is defined as the process of decrypting data with an old key and re-keying the data with a new one. The benefits of key rotation are all centered on security; for example, if the password to sensitive data is being shared between many users, you may decide to use key rotation to add an extra layer of security. By regularly changing the password you will mitigate the scenario where the encryption key can be compromised unknowingly. Rotating your keys offers more protection and better security for your sensitive business data, but it is not a requirement and it should be considered on a per-application basis.

Well done! You’ve built your first application with the security features provided in Couchbase Lite, including how to add fine grained access control through the sync function and how to use database encryption to protect the data with the possibility to login while being offline.

Get the full source code for this project as a downloadable zip below. Feel free to share your feedback, findings or ask any questions in the forums.

<div class="buttons-unit downloads">
  <a href="http://cl.ly/33090C3F2r1R/part3_final.zip" class="button">
    Download final project
  </a>
</div>