---
id: database
title: Database
permalink: ready/guides/couchbase-lite/native-api/database/index.html
---

A Database is a container and a namespace for documents, a scope for queries, and the source and target of replication. Databases are represented by the `Database` class.

Most applications only need one database, but you can use the Manager to create as many as you need. Multiple databases are independent of each other. If your application supports switching between multiple users, each with their own separate content and settings, you should consider using a database for each user. Otherwise, it's usually best to stick with one database.

> **Note:** A database is not a table. Couchbase Lite doesn't have any equivalent of relational database tables: different types of documents all coexist in the same database. Usually you use a "type" property to distinguish them.

A database has the following elements:

- Its **name**. The name must consist only of _lowercase_ ASCII letters, digits, and the special characters `_$()+-/`. It must also be less than 240 bytes and start with a lower case letter.
- Documents. Each document is identified uniquely by its ID.
- Views. Each view has a unique name, and a persistent index as well as map and reduce functions.
- Filter functions. These are used to replicate subsets of documents.
- Replications. Each replication specifies a remote database to sync documents to or from, and other parameters.

## Creating a database

### Creating an empty database

You create a new empty database by simply accessing it, using the `databaseNamed` method -- this method opens the database if it isn't yet open, and creates it if it doesn't yet exist. See the next section, Opening a database, for details. This way you don't have to write any special code for the first launch of the app.

### Pulling down a remote database

Often you'll want to create a local clone (or subset) of a database on a server. To do this you simply create an empty database as above, then start a pull replication that will download the remote database into it. The replication is asynchronous, but you can monitor its progress to find out when it's done.

> **Note:** If possible, avoid blocking until the replication completes. The user's first-launch experience will be much
 more pleasant if s/he can begin using your app immediately instead of staring at a modal progress screen waiting for downloads to complete. If you've implemented a data-driven UI, the content will appear incrementally as it downloads. For example, the ToDoLite app initially displays no content, but the to-do lists and their items quickly appear as the replication progresses.
 
### Installing a pre-built database
 
 If your app needs to sync a lot of data initially, but that data is fairly static and won't change much, it can be a lot more efficient to bundle a database in your application and install it on the first launch. Even if some of the content changes on the server after you create the app, the app's first pull replication will bring the database up to date.
 
> **Note:** This is essentially trading setup time for app installation time. If you install a 100MB database in your app,
  that of course adds to the time it takes to download and install the app. But it can still be faster than replication since the 100MB database will simply be downloaded in bulk as part of the app archive, instead of going through the interactive sync protocol. Also, the download happens when the user expects it to (while installing the app) rather than when s/he's not (on first launch.)
  
To use a prebuilt database, you need to set up the database, build the database into your app bundle as a resource, and install the database during the initial launch.

**Setting Up the Database:** You need to make the database as small as possible. Couchbase Lite keeps a revision history of every document and 
that takes up space. When creating the database locally, you can make it smaller by storing each document (via a PUT request) only once, rather than updating it multiple times. (You can double-check this by verifying that each document revision ID starts with `1-`.)

If you start with a snapshot of a live database from a server, then create a new, empty local database and replicate the source database into it.

> **Tip:** On iOS / Mac OS, the Couchbase Lite Xcode project has a target called LiteServ that builds a small Mac app that does nothing but run the REST API. LiteServ is a useful tool for creating databases and running replications locally on your development machine.

**Extracting and Building the Database:** Next you need to find the database's files. The location of these is determined by the Manager instance; it's in a directory called `CouchbaseLite` whose default location is platform-specific. (On iOS and Mac OS, it's in the `Application Support` directory.) The main database file has a .cblite extension. If your database has attachments, you also need the "databasename attachments" directory that’s adjacent to it.

> **Note:** iOS/Mac specific instructions: Add the database file and the corresponding attachments directory to your Xcode project. If you add the attachments folder, make sure that in the Add Files sheet you select the Create folder references for any added folders radio button, so that the folder structure is preserved; otherwise, the individual attachment files are all added as top-level bundle resources.

**Installing the Database:** After your app launches and creates a Database instance for its database, it needs to 
check whether the database exists. If the database does not exist, the app should copy it from the app bundle. The code looks like this:

<div class="tabs"></div>

```objective-c+
CBLManager* dbManager = [CBLManager sharedInstance];
CBLDatabase* database = [dbManager existingDatabaseNamed: @"catalog" error: &error];
if (!database) {
    NSString* cannedDbPath = [[NSBundle mainBundle] pathForResource: @"catalog"
                                                             ofType: @"cblite"];
    NSString* cannedAttPath = [[NSBundle mainBundle] pathForResource: @"catalog attachments"
                                                              ofType: @""];
    BOOL ok = [dbManager replaceDatabaseNamed: @"catalog"
                             withDatabaseFile: cannedDbPath
                              withAttachments: cannedAttPath
                                        error: &error];
    if (!ok) [self handleError: error];
    database = [dbManager existingDatabaseNamed: @"catalog" error: &error];
    if (!ok) [self handleError: error];
}
```

```swift+
let dbManager = CBLManager.sharedInstance()
var error :NSError?
var database = dbManager.existingDatabaseNamed("catalog", error: &error)
if database == nil {
    let cannedDbPath = NSBundle.mainBundle().pathForResource("catalog", ofType: "cblite")
    let cannedAttPath = NSBundle.mainBundle().pathForResource("catalog attachments", ofType: "")
    dbManager.replaceDatabaseNamed("catalog", withDatabaseFile: cannedDbPath, withAttachments: cannedAttPath, error: &error)
    if error != nil {
        self.handleError(error)
    }
    database = dbManager.existingDatabaseNamed("catalog", error: &error)
    if error != nil {
        self.handleError(error)
    }
}
```

```java+
File srcDir = new File(manager.getContext().getFilesDir(), "catalog.cblite2");
Database database = null;
try {
    database = manager.getExistingDatabase("catalog");
} catch (CouchbaseLiteException e) {
    e.printStackTrace();
}
if (database == null) {
    try {
        ZipUtils.unzip(getAssets().open("catalog.zip"), manager.getContext().getFilesDir());
    } catch (IOException e) {
        e.printStackTrace();
    }
    manager.replaceDatabase("catalog", srcDir.getAbsolutePath());
}
```

```c+
No code example is currently available.
```

## Opening a database

You'll typically open a database while initializing your app, right after instantiating the Manager object, and store a reference to the Database object as either a global variable or a property of your top-level application object (the app delegate on iOS or Mac OS.) Opening a database is as simple as calling the Manager's `databaseNamed` method -- this will first create a new empty database if one doesn't already exist with that name. It's fine to call this method more than once: it will return the same Database instance every time.

> **Caution:** For compatibility reasons, **database names cannot contain uppercase letters!** The only legal characters are lowercase ASCII letters, digits, and the special characters `_$()+-/`

<div class="tabs"></div>

```objective-c+
// get or create database:
CBLManager *manager = [CBLManager sharedInstance];
NSError *error;
self.database = [manager databaseNamed: @"my-database" error: &error];
if (!self.database) {
    [self handleError: error];
}
```

```swift+
let manager = CBLManager.sharedInstance()
var error: NSError?
self.database = manager.databaseNamed("my-database", error: &error)
if self.database == nil {
    self.handleError(error)
}
```

```java+
try {
     // Android application
     Manager manager = new Manager(new AndroidContext(mContext), Manager.DEFAULT_OPTIONS);
     // Java application
     Manager manager = new Manager(new JavaContext("data"), Manager.DEFAULT_OPTIONS);
     this.db = manager.getDatabase("my-database");
 } catch (IOException e) {
     Log.e(TAG, "Cannot create database", e);
     return;
 }
```

```c+
var db = Manager.SharedInstance.GetDatabase("my-database");
if (db == null) 
{
    Log.E(Tag, "Cannot create database");
}
```

> **Note:** If you want to open only an existing database, without the possibility of creating a new one, call the 
related 
Manager method `existingDatabaseNamed` instead. It returns null/nil (without an error or exception) if no database with that name exists.

## Database encryption

### Encryption with different storage types

Database encryption is available for both ForestDB and SQLite storage types. It is automatically hooked into ForestDB's filesystem abstraction layer and for SQLite storage, Couchbase Lite uses SQLCipher; an open source extension to SQLite that provides transparent encryption of database files. In both cases, the encryption specification is 256-bit AES.

#### Installing SQLCipher

SQLCipher is an optional dependency. The section below describes how to add it on each platform.

##### Android

Add the following in the application level build.gradle file.

```bash
dependencies {
    compile 'com.couchbase.lite:couchbase-lite-android:+'
    compile 'com.couchbase.lite:couchbase-lite-android-sqlcipher:+'
}
```

##### iOS

1. Download the iOS SDK from [here](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile).
2. Add the `libsqlcipher.a` library to your XCode project.
3. Go to the Link Binary With Libraries build phase of your app target.
4. Remove `libsqlite.dylib`

##### Windows

- Install the Nuget package called `Couchbase.Lite.Storage.SQLCipher`
- Alternatively, if you are manually adding the DLLs to the Visual Studio project, you should include `sqlcipher.dll` and `Couchbase.Lite.Storage.SQLCipher.dll`

#### Enabling encryption

At this point, Couchbase Lite won't work any differently. Databases are still unencrypted by default. To enable encryption, you must register an encryption key when opening the database with the openDatabase method.

<div class="tabs"></div>

```objective-c+
CBLDatabaseOptions* options = [[CBLDatabaseOptions alloc] init];
options.storageType = @"SQLite";
options.encryptionKey = @"password123456";
options.create = YES;
CBLDatabase* database = [manager openDatabaseNamed:@"db" withOptions:options error:nil];
```

```swift+
var options: CBLDatabaseOptions = CBLDatabaseOptions()
options.storageType = "SQLite"
options.encryptionKey = "password123456"
options.create = true
var database: CBLDatabase = manager.openDatabaseNamed("db", withOptions: options, error: nil)
```

```java+
String key = "password123456";
DatabaseOptions options = new DatabaseOptions();
options.setCreate(true);
options.setEncryptionKey(key);
Database database = manager.openDatabase("db", options);
```

```c+
var key = new SymmetricKey("password123456");
var options = new DatabaseOptions
{
    EncryptionKey = key,
    Create = true,
    StorageType = StorageEngineTypes.SQLite
};
Database database = manager.OpenDatabase("db", options);
```

If the database does not exist (and `options.create` is true) it will be created encrypted with the given key.

If the database already exists, the key will be used to decrypt it (and to encrypt future changes). If the key does not match the one previously used, opening the database will fail; the error/exception will have status code 401.

To change the encryption key, you must first open the database using the `openDatabase` method with the existing key and if the operation is successful, use the `changeEncryptionKey` method providing the new key. Passing `nil` as the value will disable encryption.

## Storage engines

There are two storage engines available with Couchbase Lite: SQLite and ForestDB. In the case of SQLite, it will use the system dependency already available on most platforms (iOS, Android, Windows...). To use ForestDB, the project must include the ForestDB storage dependency (see instructions below.)

### What is ForestDB?

ForestDB is a persistent key-value storage library, it's a key-value map where the keys and values are binary blobs.

#### Benefits of using ForestDB

- Faster (2x to 5x as fast, depending on the operation and data set)
- Better concurrency (writers never block readers)
- Lower RAM footprint (data caches are shared between threads)
- Database compaction is automatic and runs periodically in the background

#### iOS

The ForestDB engine isn't built into the iOS and tvOS platforms, to save space. To use ForestDB on those platforms you'll need to link it into your app as an extra static library.

1. Add the library `libCBLForestDBStorage.a` to your project and add it to your iOS app target's "Link Binary With Libraries" build phase.
2. Link the system library `libc++.dylib`. To do that, in the target's Build Phases editor, press the "+" button below the "Link 
3. Binary With Libraries" and add `libc++.dylib`
4. Make sure `-ObjC` is set in `Other Linker Flags` in `Build Settings`

> **Note:** These steps aren't necessary for Mac OS because that version of the Couchbase Lite framework already has ForestDB built into it.

#### Android

Add the following in the application level `build.gradle` file.

```gradle
dependencies {
    compile 'com.couchbase.lite:couchbase-lite-android:+'
    compile 'com.couchbase.lite:couchbase-lite-java-forestdb:+'
}
```

#### Windows

Install the Nuget package called Couchbase Lite ForestDB Storage.

### Choosing a storage engine

#### For new databases

At runtime, you need to tell the `Manager` you want to use ForestDB, by setting its `storageType` to ForestDB.

<div class="tabs"></div>

```objective-c+
manager.storageType = kCBLForestDBStorage;
```

```swift+
manager.storageType = kCBLForestDBStorage
```

```java+
manager.setStorageType("ForestDB");
```

```c+
Manager manager = Manager.SharedInstance;
manager.StorageType = "ForestDB";
```

This only applies to new databases. Existing local database files will always open with the same storage engine that created them.

#### Upgrading databases to ForestDB

It's possible to upgrade an existing local database file from SQLite to ForestDB. You can use this option if you have an already-shipping app and want your existing installs to use ForestDB as well as new installs. To do this, you use an alternate method to open your database, one that allows you to specify a set of options.

<div class="tabs"></div>

```objective-c+
CBLDatabaseOptions *options = [[CBLDatabaseOptions alloc] init];
options.create = YES;
options.storageType = kCBLForestDBStorage;  // Forces upgrade to ForestDB
CBLDatabase* db = [manager openDatabaseNamed:@"my-database"
                                 withOptions:options
                                       error:&error];
```

```swift+
var options: CBLDatabaseOptions = CBLDatabaseOptions()
options.create = true
options.storageType = kCBLForestDBStorage  // Forces upgrade to ForestDB
var db: CBLDatabase = manager.openDatabaseNamed("my-database", withOptions: options, error: error!)
```

```java+
// Android application
Manager manager = new Manager(new AndroidContext(this), null);
// Java application
Manager manager = new Manager(new JavaContext("data"), Manager.DEFAULT_OPTIONS);

DatabaseOptions options = new DatabaseOptions();
options.setCreate(true);
options.setStorageType("ForestDB");
Database database = manager.openDatabase("my-database", options);
```

```c+
Manager manager = Manager.SharedInstance;
DatabaseOptions options = new DatabaseOptions();
options.Create = true;
options.StorageType = "ForestDB";
Database database = manager.OpenDatabase ("my-database", options);
```

Setting the options' `storageType` property forces the database to use the ForestDB format. If it's currently in SQLite format, it will be converted in place before being opened. (The next time, it will just open normally, since it's already ForestDB.)

## Concurrency support

Concurrency support varies by platform.

### iOS, Mac OS (Objective-C)

The Objective-C implementation follows the typical behavior of Cocoa classes: the classes are not themselves thread-safe, so the app is responsible for calling them safely. In addition, some of the classes post `NSNotifications` and need to know what runloop or dispatch queue to deliver the notifications on. Therefore, each thread or dispatch queue that you use Couchbase Lite on should have _its own set of Couchbase Lite objects_.

If your app uses Couchbase Lite on multiple threads, then on each thread (or dispatch queue) it must:

- Create a new CBLManager instance. If you use multiple threads, do not use the `sharedInstance`.
- Use only objects (Databases, Documents, ...) acquired from its Manager.
- Not pass any Couchbase Lite objects to code running on any other thread/queue.

If different threads/queues need to communicate to each other about documents, they can use the document ID (and database name, if you use multiple databases.)

By default, Couchbase Lite is thread-based; if you are instead creating a CBLManager for use on a dispatch queue (which might run on different threads during its lifetime), you must set the Manager's `dispatchQueue` property, so that it can properly schedule future calls.

As a convenience, CBLManager's `backgroundTellDatabaseNamed:to:` method will run a block on an existing background thread (the same one the replicator runs on). You must be careful to avoid using any of the calling thread's objects in the block, since the block runs on a different thread. Instead, you should use the CBLDatabase object passed to the block and derive other objects like documents from it.

<div class="tabs"></div>

```objective-c+
// Example to read a document asynchronously on a background thread.
// (This isn't very realistic since reading one document is fast enough to
// do on the main thread.)
NSString* docID = myDocument.documentID;
[myDB.manager backgroundTellDatabaseNamed: myDB.name to: ^(CBLDatabase* bgdb) {
    // Note that we can't use myDocument in the block since we're on the wrong thread.
    // Instead we use the captured ID to get a new document object:
    CBLDocument* bgDoc = bgdb[docID];
    NSDictionary* properties = bgDoc.properties;
    dispatch_async(myQueue, ^{[self handleDoc: properties];})
}];
```

```swift+
// Example to read a document asynchronously on a background thread.
// (This isn't very realistic since reading one document is fast enough to
// do on the main thread.)
let docID = myDocument.documentID
myDB.manager.backgroundTellDatabaseNamed(myDB.name, to: { (bgdb: CBLDatabase!) -> Void in
    if let bgDoc = bgdb[docID] {
        var properties = bgDoc.properties;
        dispatch_async(nil, { () -> Void in
            self.handleDoc(properties)
        })
    }
})
```

```java+
No code example is currently available.
```

```c+
No code example is currently available.
```

#### Android, Java

It is safe to call Couchbase Lite from multiple threads on the Android / Java platform. If you find any thread safety related issues, please report a bug.

## Database notifications

You can register for notifications when documents are added/updated/deleted from a database. In practice, applications don't use these as much as live queries and document change notifications; still this facility can be useful if you want a lightweight way to tell whenever anything's changed in a database.

<div class="tabs"></div>

```objective-c+
[[NSNotificationCenter defaultCenter] addObserverForName: kCBLDatabaseChangeNotification
            object: myDatabase
             queue: nil
        usingBlock: ^(NSNotification *n) {
            NSArray* changes = n.userInfo[@"changes"];
            for (CBLDatabaseChange* change in changes)
                NSLog(@"Document '%@' changed.", change.documentID);
        }
];
```

```swift+
NSNotificationCenter.defaultCenter().addObserverForName(kCBLDatabaseChangeNotification, object: myDatabase, queue: nil) { 
  (notification) -> Void in
    if let changes = notification.userInfo!["changes"] as? [CBLDatabaseChange] {
        for change in changes {
            NSLog("Document '%@' changed.", change.documentID)
        }
    }
}
```

```java+
try {
     Database db = manager.getExistingDatabase("my-database");
     
     if(db != null) {
         db.addChangeListener(new ChangeListener() {
             public void changed(ChangeEvent event) {
                 //
                 // Process the notification here
                 //
             }
         });
     }
 
 } catch (IOException e) {
     Log.e(TAG, "Cannot delete database", e);
     return;
 }
```

```c+
database.Changed += (sender, e) => {
    var changes = e.Changes.ToList();
    foreach (DocumentChange change in changes) {
        Log.D(Tag, "Document " + change.DocumentId + " changed");
    }
};
```

> **Note:** The notifications may not be delivered immediately after the document changes. Notifications aren't delivered during a transaction; they're buffered up for delivery after the transaction completes. And on iOS / Mac OS, the notifications are scheduled on the runloop, so they won't be delivered until after the event that triggered them completes.

## Database housekeeping

A database of course stores documents, and a document stores multiple revisions of its content; this is part of the MVCC (Multi-Version Concurrency Control) system that manages concurrency and detects replication conflicts. But this also causes the database file to grow over time. Unlike a Git repository, whose history is vital, a database should be periodically compacting to reclaim space. Compaction deletes the following:

- The JSON bodies of non-current revisions of documents (that is, all but the current revision and any unresolved 
conflicts)
- The metadata of the oldest revisions (see below for details)
- Attachments that are no longer used by any document revision

You can tune the maximum revision tree depth parameter (the `Database` object's `maxRevTreeDepth` property). This governs how old a revision must be before its metadata is discarded. It defaults to 20, meaning that each document will remember the history of its latest 20 revisions. Setting this to a smaller value will save storage space, but can result in spurious conflicts if users are making lots of offline changes and then sync. Compaction happens automatically in the background to remove revisions older than the `maxRevTreeDepth` value.

## Deleting a database

The `delete` method (`deleteDatabase` in Objective-C) permanently deletes a database's file and all its attachments. After this, you should immediately set your Database reference to nil/null and not call it again.

<div class="tabs"></div>

```objective-c+
NSError* error;
if (![self.database deleteDatabase: &error]) {
    [self handleError: error];
}
self.database = nil;
```

```swift+
var error: NSError?
if !self.database.deleteDatabase(&error) {
    self.handleError(error)
}
self.database = nil
```

```java+
try {
     myDatabase.delete();
} catch (IOException e) {
     Log.e(TAG, "Cannot delete database", e);
     return;
}
```

```c+
try {
    database.Delete();
} catch (CouchbaseLiteException e) {
    Log.E(Tag, "Cannot delete database", e);
}
```