---
id: replication
title: Replication
permalink: ready/guides/couchbase-lite/native-api/replication/index.html
---

A Replication object represents a replication (or "sync") task that transfers changes between a local database and a remote one. To replicate, you first get a new Replication object from a Database, then configure its settings, then tell it to start. The actual replication runs asynchronously on a background thread; you can monitor its progress by observing notifications posted by the Replication object when its state changes, as well as notifications posted by the database when documents are changed by the replicator.

A typical application will create a pair of replications (push and pull) at launch time, both pointing to the URL of a server run by the application vendor. These stay active continuously during the lifespan of the app, uploading and downloading documents as changes occur and when the network is available.

(Of course, atypical applications can use replication differently. The architecture is very flexible, supporting one-way replication, peer-to-peer replication, and replication between multiple devices and servers in arbitrary directed graphs. An app might also choose to replicate only once in a while, or only with a subset of its documents.)

The application code doesn't have to pay attention to the details: it just knows that when it makes changes to the local database they will eventually be uploaded to the server, and when changes occur on the server they will eventually be downloaded to the local database. The app's job is to make the UI reflect what's in the local database, and to reflect user actions by making changes to local documents. If it does that, replication will Just Work without much extra effort.

## Types of replications

- **Push vs Pull:** A push replication uploads changes from the local database to the remote one; a pull downloads changes from the remote database to the local one.
- **One-shot vs Continuous:** By default a replication runs long enough to transfer all the changes from the source to the target database, then quits. A continuous replication, on the other hand, will stay active indefinitely, watching for further changes to occur and transferring them.
- **Filtered:** Replications can have filters that restrict what documents they'll transfer. This can be useful to limit the amount of a large remote database that's downloaded to a device, or to keep some local documents private. A special type of filter used with the Couchbase Sync Gateway is the set of **channels** that a pull replication will download from. It's also possible to limit a replication to an explicit set of document IDs.

## Creating and configuring replications

You create a Replication object by calling the Database methods `createPullReplication` or `createPushReplication`. Both of these take a single parameter, the URL of the remote database to sync with. As the names imply, each method creates a replication that transfers changes in one direction only; if you want bidirectional sync, as most apps do, you should create one of each.

Next you can customize the replication settings. The most common change is to set the `continuous` property to `true`. You may also need to supply authentication credentials, like a username/password or a Facebook token.

<div class="tabs"></div>

```objective-c+
NSURL* url = [NSURL URLWithString: @"https://example.com/mydatabase/"];
CBLReplication *push = [database createPushReplication: url];
CBLReplication *pull = [database createPullReplication: url];
push.continuous = pull.continuous = YES;
id<CBLAuthenticator> auth;
auth = [CBLAuthenticator basicAuthenticatorWithName: username
                                           password: password];
push.authenticator = pull.authenticator = auth;
```

```swift+
let url = NSURL(string: "https://example.com/mydatabase/")
let push = database.createPushReplication(url)
let pull = database.createPullReplication(url)
push.continuous = true
pull.continuous = true
var auth: CBLAuthenticatorProtocol?
auth = CBLAuthenticator.basicAuthenticatorWithName(username, password: password)
push.authenticator = auth
pull.authenticator = auth
```

```java+
URL url = new URL("https://example.com/mydatabase/");
Replication push = database.createPushReplication(url);
Replication pull = database.createPullReplication(url);
pull.setContinuous(true);
push.setContinuous(true);
Authenticator auth = new BasicAuthenticator(username, password);
push.setAuthenticator(auth);
pull.setAuthenticator(auth);
```

```c+
var url = new Uri("https://example.com/mydatabase/");
var push = database.CreatePushReplication(url);
var pull = database.CreatePullReplication(url);
var auth = AuthenticatorFactory.CreateBasicAuthenticator(username, password);
push.Authenticator = auth;
pull.Authenticator = auth;
push.Continuous = true;
pull.Continuous = true;
```

You will also probably want to monitor the replication's progress, particularly because this will tell you if errors occur, but also if you want to display a progress indicator to the user. The API for registering as an observer is platform-specific.

Once everything is set, you call start to `start` the replication. If the replication is continuous, it'll keep running indefinitely. Otherwise, the replication will eventually stop when it's transferred everything.

<div class="tabs"></div>

```objective-c+
[[NSNotificationCenter defaultCenter] addObserver: self
                                         selector: @selector(replicationChanged:)
                                             name: kCBLReplicationChangeNotification
                                           object: push];
[[NSNotificationCenter defaultCenter] addObserver: self
                                         selector: @selector(replicationChanged:)
                                             name: kCBLReplicationChangeNotification
                                           object: pull];
[push start];
[pull start];
// It's important to keep a reference to a running replication,
// or it is likely to be dealloced!
self.push = push;
self.pull = pull;
// The replications are running now; the -replicationChanged: method will
// be called with notifications when their status changes.
```

```swift+
NSNotificationCenter.defaultCenter().addObserver(self,
    selector: "replicationChanged", name: kCBLReplicationChangeNotification, object: push)
NSNotificationCenter.defaultCenter().addObserver(self,
    selector: "replicationChanged", name: kCBLReplicationChangeNotification, object: pull)
push.start()
pull.start()
// It's important to keep a reference to a running replication,
// or it is likely to be dealloced!
self.push = push;
self.pull = pull;
// The replications are running now; the -replicationChanged: method will
// be called with notifications when their status changes.
```

```java+
push.addChangeListener(new Replication.ChangeListener() {
    @Override
    public void changed(Replication.ChangeEvent event) {
        // will be called back when the push replication status changes
    }
});
pull.addChangeListener(new Replication.ChangeListener() {
    @Override
    public void changed(Replication.ChangeEvent event) {
        // will be called back when the pull replication status changes
    }
});
push.start();
pull.start();
this.push = push;
this.pull = pull;
```

```c+
push.Changed += (sender, e) => 
{
    // Will be called when the push replication status changes
};
pull.Changed += (sender, e) => 
{
    // Will be called when the pull replication status changes
};
push.Start();
pull.Start();
this.push = push;
this.pull = pull;
```

## Filtered replications

You can restrict a replication to only a subset of the available documents, by writing a filter function. There are several types of filtered replication, based on the direction and the type of server.

### Filtered push replications

During a push replication, the candidate documents live in your local database, so the filter function runs locally. You define it as a native function (a block in Objective-C, an inner class method in Java), assign it a name, and register it with the Database object. You then set the filter's name as the `filter` property of the Replication object.

The replicator passes your filter function a SavedRevision object. The function can examine the document's ID and properties, and simply returns true to allow the document to be replicated, or false to prevent it from being replicated.

Caution:The filter function will be called on the replicator's background thread, so it should be thread-safe. Ideally it shouldn't reference any external state, but this isn't strictly required.

The filter function can also be given parameters. The parameter values are specified in the `Replication.filterParams` property as a dictionary/map, and passed to the filter function. This way you can write a generalized filter that can be used with different replications, and also avoid referencing external state from within the function. For example, a function could filter documents created in any year, accepting the specific year as a parameter.

<div class="tabs"></div>

```objective-c+
// Define a filter that matches only docs with a given "owner" property.
// The value to match is given as a parameter named "name":
[db setFilterNamed: @"byOwner" asBlock: FILTERBLOCK({
    NSString* nameParam = params[@"name"];
    return nameParam && [revision[@"owner"] isEqualToString: nameParam];
})];
//
// Set up a filtered push replication using the above filter block,
// that will push only docs whose "owner" property equals "Waldo":
CBLReplication *push = [database createPushReplication: url];
push.filter = @"byOwner";
push.filterParams = @{@"name": @"Waldo"};
```

```swift+
db.setFilterNamed("byOwnder", asBlock: { 
    (revision, params) -> Bool in
        let nameParam = params["name"] as? String
        return nameParam != nil && nameParam! == revision["owner"] as? String
})
```

```java+
// Define a filter that matches only docs with a given "owner" property.
// The value to match is given as a parameter named "name":
db.setFilter("byOwner", new ReplicationFilter() {
    @Override
    public boolean filter(SavedRevision revision, Map<String, Object> params) {
        String nameParam = (String) params.get("name");
        return nameParam != null && nameParam.equals(revision.getProperty("owner"));
    }
});
//
// Set up a filtered push replication using the above filter block,
// that will push only docs whose "owner" property equals "Waldo":
Replication push = db.createPushReplication(url);
push.setFilter("byOwner");
Map<String, Object> params = new HashMap<String, Object>();
params.put("name", "Waldo");
push.setFilterParams(params);
```

```c+
// Define a filter that matches only docs with a given "owner" property.
// The value to match is given as a parameter named "name":
database.SetFilter("byOwner", (revision, filterParams) =>
{
    var nameParam = filterParams["name"];
    var owner = (string)revision.GetProperty("owner");
    return (nameParam != null) && nameParam.Equals(owner);
});
// Set up a filtered push replication using the above filter block,
// that will push only docs whose "owner" property equals "Waldo":
var push = database.CreatePushReplication(url);
push.Filter = "byOwner";
push.FilterParams = new Dictionary<string, object> { {"name", "Waldo"} };
```

### Filtered pull from Sync Gateway

Channels are used to filter documents being pulled from the Sync Gateway. Every document stored in a Sync Gateway database is tagged with a set of named channels by the Gateway's app-defined sync function. Every pull replication from the Gateway is already implicitly filtered by the set of channels that the user's account is allowed to access; you can filter it further by creating an array of channel names and setting it as the value of the channels property of a pull Replication. Only documents tagged with those channels will be downloaded.

<div class="tabs"></div>

```objective-c+
// Set up a channel-filtered pull replication that will pull only
// docs in the "sales" channel from the Sync Gateway:
CBLReplication *pull = [database createPullReplication: url];
pull.channels = @[@"sales"];
```

```swift+
// Set up a channel-filtered pull replication that will pull only
// docs in the "sales" channel from the Sync Gateway:
var pull: CBLReplication = database.createPullReplication(url)
pull.channels = ["sales"]
```

```java+
// Set up a channel-filtered pull replication that will pull only
// docs in the "sales" channel from the Sync Gateway:
db.createPullReplication(url);
List<String> channels = new ArrayList<String>();
channels.add("sales");
pull.setChannels(channels);
```

```c+
No code example is currently available.
```

> **Note:** Replication properties changed after it has already started won't have any effect. If you wish to change replication properties such as channels, authentication, etc, you must create a new replication object using the `createPushReplication` or `createPullReplication` method.

### Filtered pull from CouchDB, PouchDB or Cloudant

Other non-Couchbase databases that Couchbase Lite can replicate with don't support channels, but they do support server-side filter functions. These are implemented in JavaScript and stored in special "design documents" in the server-side database. The CouchDB documentation describes how to write and install them.

To use such a filter function in a pull replication, set the Replication object's filter property to a string of the form designDocName/filterName. For example, if the server-side design document is named _design/access and you want to use its filter function called byYear, you would set the Replication.filter property to "access/byYear".

(The same example from the previous section applies here too; the difference is on the remote server, where the byOwner filter would be defined as a JavaScript function stored in a design document.)

### Observing and monitoring replications

Since a replication runs asynchronously, if you want to know when it completes or when it gets an error, you'll need to register as an observer to get notifications from it. The details of this are platform-specific.

A replication has a number of properties that you can access, especially from a notification callback, to check on its status and progress:

- `status`: An enumeration that gives the current state of the replication. The values are Stopped, Offline, Idle and Active.
	- Stopped: A one-shot replication goes into this state after all documents have been transferred or a fatal error occurs. (Continuous replications never stop.)
	- **Offline**: The remote server is not reachable. Most often this happens because there's no network connection, 
	but it can 
	also occur if the server's inside an intranet or home network but the device isn't. (The replication will monitor the network state and will try to connect when the server becomes reachable.)
	- **Idle**: Indicates that a continuous replication has "caught up" and transferred all documents, but is monitoring
	 the 
	source database for future changes.
	- **Active**: The replication is actively working, either transferring documents or determining what needs to be 
	transferred.
- `lastError`: The last error encountered by the replicator. (Not all errors are fatal, and a continuous replication will keep running even after a fatal error, by waiting and retrying later.)
- `completedChangesCount`, `changesCount`: The number of documents that have been transferred so far, and the estimated total number to transfer in order to catch up. The ratio of these can be used to display a progress meter. Just be aware that changesCount may be zero if the number of documents to transfer isn't known yet, and in a continuous replication both values will reset to zero when the status goes from Idle back to Active.

<div class="tabs"></div>

```objective-c+
[[NSNotificationCenter defaultCenter] addObserver: self
                     selector: @selector(replicationChanged:)
                         name: kCBLReplicationChangeNotification
                       object: push];
[[NSNotificationCenter defaultCenter] addObserver: self
                     selector: @selector(replicationChanged:)
                         name: kCBLReplicationChangeNotification
                       object: pull];
- (void) replicationChanged: (NSNotification*)n {
    // The replication reporting the notification is n.object , but we
    // want to look at the aggregate of both the push and pull.
    
    // First check whether replication is currently active:
    BOOL active = (pull.status == kCBLReplicationActive) || (push.status == kCBLReplicationActive);
    self.activityIndicator.state = active;
    // Now show a progress indicator:
    self.progressBar.hidden = !active;
    if (active) {
        double progress = 0.0;
        double total = push.changesCount + pull.changesCount;
        if (total > 0.0) {
            progress = (push.completedChangesCount + pull.completedChangesCount) / total;
        }
        self.progressBar.progress = progress;
    }
}
```

```swift+
NSNotificationCenter.defaultCenter().addObserver(self,
    selector: "replicationChanged:",
    name: kCBLReplicationChangeNotification,
    object: push)
NSNotificationCenter.defaultCenter().addObserver(self,
    selector: "replicationChanged:",
    name: kCBLReplicationChangeNotification,
    object: pull)
func replicationProgress(n: NSNotification) {
    // The replication reporting the notification is n.object , but we
    // want to look at the aggregate of both the push and pull.
    
    // First check whether replication is currently active:
    let active = pull.status == CBLReplicationStatus.Active || push.status == CBLReplicationStatus.Active
    self.activityIndicator.state = active
    // Now show a progress indicator:
    self.progressBar.hidden = !active;
    if active {
        var progress = 0.0
        let total = push.changesCount + pull.changesCount
        let completed = push.completedChangesCount + pull.completedChangesCount
        if total > 0 {
            progress = Double(completed) / Double(total);
        }
        self.progressBar.progress = progress;
    }
}
```

```java+
final ProgressDialog progressDialog = ProgressDialog.show(MainActivity.this, "Please wait ...", "Syncing", false);
pull.addChangeListener(new Replication.ChangeListener() {
    @Override
    public void changed(Replication.ChangeEvent event) {
        // The replication reporting the notification is either
        // the push or the pull, but we want to look at the
        // aggregate of both the push and pull.
        // First check whether replication is currently active:
        boolean active = (pull.getStatus() == Replication.ReplicationStatus.REPLICATION_ACTIVE) ||
        (push.getStatus() == Replication.ReplicationStatus.REPLICATION_ACTIVE);
        if (!active) {
            progressDialog.dismiss();
        } else {
            double total = push.getCompletedChangesCount() + pull.getCompletedChangesCount();
            progressDialog.setMax(total);
            progressDialog.setProgress(push.getChangesCount() + pull.getChangesCount());
        }
    }
});
```

```c+
// The replication reporting the notification is either
// the push or the pull, but we want to look at the
// aggregate of both the push and pull.
// First check whether replication is currently active:
var active = push.Status == ReplicationStatus.Active ||
             pull.Status == ReplicationStatus.Active;
if (!active)
{
    DismissProgressBar();
}
else
{
    var total = push.CompletedChangesCount + pull.CompletedChangesCount;
    var progress = push.ChangesCount + pull.ChangesCount;
    ShowProgressBar(progress, total);
}
```

### Detecting unauthorized credentials

The replication listener can also be used to detect when credentials are incorrect or access to Sync Gateway requires authentication.

<div class="tabs"></div>

```objective-c+
    ...

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(replicationChanged:)
                                                 name: kCBLReplicationChangeNotification
                                               object: push];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(replicationChanged:)
                                                 name: kCBLReplicationChangeNotification
                                               object: pull];
}

- (void) replicationChanged: (NSNotification*)notification {
    if (pull.status == kCBLReplicationActive || push.status == kCBLReplicationActive) {
        NSLog(@"Sync in progress");
    } else {
        NSError *error = pull.lastError ? pull.lastError : push.lastError;
        if (error.code == 401) {
            NSLog(@"Authentication error");
        }
    }
}
```

```swift+
    ...

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeListener:", name: kCBLReplicationChangeNotification, object: push)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeListener:", name: kCBLReplicationChangeNotification, object: pull)
}
    
func changeListener(notification: NSNotification) {
    if (push.status == CBLReplicationStatus.Active || pull.status == CBLReplicationStatus.Active) {
        print("Sync in progress")
    } else {
        let error = push.lastError ?? pull.lastError
        print("Error with code \(error?.code)")
        if error?.code == 401 {
            print("Authentication error")
        }
    }
}
```

```java+
push = database.createPushReplication(url);
push.addChangeListener(new Replication.ChangeListener() {
    @Override
    public void changed(Replication.ChangeEvent event) {
        if (event.getError() != null) {
            Throwable lastError = event.getError();
            if (lastError instanceof RemoteRequestResponseException) {
                RemoteRequestResponseException exception = (RemoteRequestResponseException) lastError;
                if (exception.getCode() == 401) {
                    // Authentication error
                }
            }
        }
    }
});
```

```c+
    ...
    pull.Changed += Changed;
    push.Changed += Changed;
}

void Changed(object sender, ReplicationChangeEventArgs e)
{
	if (pull.Status == ReplicationStatus.Active || push.Status == ReplicationStatus.Active)
	{
		Console.WriteLine("Sync in progress");
	}
	else if (e.LastError != null)
	{
		Exception error = e.LastError;
		if (error is HttpResponseException)
		{
			HttpResponseException exception = (HttpResponseException)error;
			if ((int) exception.StatusCode == 401)
			{
				Console.WriteLine("Authentication error");
			}
		}
	}
}
```