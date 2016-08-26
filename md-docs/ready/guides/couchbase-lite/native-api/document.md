---
id: document
title: Document
permalink: ready/guides/couchbase-lite/native-api/document/index.html
---

In a _document database_ such as Couchbase Lite, the primary entity stored in a database is called a **document** instead of a "row" or "record". This reflects the fact that a document can store more data, with more structure, than its equivalent in other databases.

In Couchbase Lite (as in Couchbase Server and CouchDB) a document's **body** takes the form of a JSON object — a collection of key/value pairs where the values can be different types of data such as numbers, strings, arrays or even nested objects. Every document is identified by a **document ID**, which can be automatically generated (as a UUID) or determined by the application; the only constraints are that it must be unique within the database, and it can't be changed.

In addition, a document can contain attachments, named binary blobs that are useful for storing large media files or other non-textual data. Couchbase Lite supports attachments of unlimited size, although the Sync Gateway currently imposes a 20MB limit for attachments synced to it.

Couchbase Lite keeps track of the change history of every document, as a series of revisions. This is somewhat like a version control system such as Git or Subversion, although its main purpose is not to be able to access old data, but rather to assist the replicator in deciding what data to sync and what documents have conflicts. Every time a document is created or updated, it is assigned a new unique **revision ID**. 
The IDs of 
past revisions are available, and the contents of past revisions may be available, but only if the revision was created locally and the database has not yet been compacted.

To summarize, a document has the following attributes:

- A document ID
- A current revision ID (which changes every time the document is updated)
- A history of past revision IDs (usually linear, but will form a branching tree if the document has or has had 
conflicts)
- A body in the form of a JSON object, i.e. a set of key/value pairs
- Zero or more named binary attachments
- Creating, Reading, Updating and Deleting documents (CRUD)

## Creating, Reading, Updating and Deleting documents (CRUD)

Couchbase Lite of course supports the typical database "CRUD" operations on documents: Create, Read, Update, Delete.

### Creating documents

You can create a document with or without giving it an ID. If you don't need or want to define your own ID, call the Database method `createDocument`, and the ID will be generated randomly in the form of a Universally Unique ID (UUID), which looks like a string of hex digits. The uniqueness ensures that there is no chance of an accidental collision by two client apps independently creating different documents with the same ID, then replicating to the same server.

The following example shows how to create a document with an automatically-assigned UUID:

<div class="tabs"></div>

```objective-c+
NSString* owner = [@"profile:" stringByAppendingString: userId];
NSDictionary* properties = @{@"type":       @"list",
                             @"title":      title,
                             @"created_at": currentTimeString,
                             @"owner":      owner,
                             @"members":    @[]};
CBLDocument* document = [database createDocument];
NSError* error;
if (![document putProperties: properties error: &error]) {
    [self handleError: error];
}
```

```swift+
let owner = "profile".stringByAppendingString(userId)
let properties = [
    "type": "list",
    "title": title,
    "owner": owner,
    "members": []
]
let document = database.createDocument()
var error: NSError?
if document.putProperties(properties, error: &error) == nil {
    self.handleError(error)
}
```

```java+
Map<String, Object> properties = new HashMap<String, Object>();
properties.put("type", "list");
properties.put("title", title);
properties.put("created_at", currentTimeString);
properties.put("owner", "profile:" + userId);
properties.put("members", new
ArrayList<String>());
Document document = database.createDocument();
document.putProperties(properties); 
```

```c+
var document = database.CreateDocument();
var properties = new Dictionary<string, object>()
    {
        {"type", "list"},
        {"title", "title"},
        {"created_at", DateTime.UtcNow.ToString ("o")},
        {"owner", "profile:" + userId},
        {"members", new List<string>()}
    };
var rev = document.PutProperties(properties);
Debug.Assert(rev != null);
```

If you do want to choose the document's ID, just call the Database method `getDocument`, just as you would to retrieve an existing document. If the document doesn't exist yet, you still get a valid Document object, it just doesn't have any revisions or contents yet. The first time you save the document, it will be added persistently to the database. If a document does already exist with the same ID, saving the document will produce a conflict error.

The following example shows how to create a document with an custom ID:

<div class="tabs"></div>

```objective-c+
NSDictionary* properties = @{@"title":      @"Little, Big",
                             @"author":     @"John Crowley",
                             @"published":  1982};
CBLDocument* document = [database documentWithID: @"978-0061120053"];
NSError* error;
if (![document putProperties: properties error: &error]) {
    [self handleError: error];
}
```

```swift+
let properties =
[
    "title": "Little, Big",
    "author": "John Crowley",
    "published":  1982
]
let document = database.documentWithID("978-0061120053")
var error: NSError?
if document.putProperties(properties, error: &error) == nil {
    self.handleError(error)
}
```

```java+
Map<String, Object> properties = new HashMap<String, Object>();
properties.put("title", "Little, Big");
properties.put("author", "John Crowley");
properties.put("published", 1982);
Document document = database.getDocument("978-0061120053");
try {
    document.putProperties(properties);
} catch (CouchbaseLiteException e) {
    Log.e(TAG, "Cannot save document", e);
}
```

```c+
var properties = new Dictionary<string, object>
    {
        {"title", "Little, Big"},
        {"author", "John Crowley"},
        {"published", 1982}
    };
var document = database.GetDocument("978-0061120053");
Debug.Assert(document != null);
var rev = document.PutProperties(properties);
Debug.Assert(rev != null);
```

> **Tip:** It's up to you whether to assign your own IDs or use random UUIDs. If the documents are representing entities that already have unique IDs — like email addresses or employee numbers — then it makes sense to use those, especially if you need to ensure that there can't be two documents representing the same entity. For example, in a library cataloging app, you wouldn't want two librarians to independently create duplicate records for the same book, so you might use the book's ISBN as the document ID to enforce uniqueness.

### Reading documents

To retrieve a Document object given its ID, call the Database method `getDocument`. As described in the previous section, if there is no document with this ID, this method will return a valid but empty Document object. (If you would rather get a null/nil result for a nonexistent document, call `existingDocumentWithID` instead.)

Document objects, like document IDs, are unique. That means that there is never more than one Document object in memory that represents the same document. If you call `getDocument` multiple times with the same ID, you get the same Document object every time. This helps conserve memory, and it also makes it easy to compare Document object references (pointers) — you can just use `==` to check whether two references refer to the same document.

Loading a Document object doesn't immediately read its properties from the database. Those are loaded on demand, when you call an accessor method like `getProperties` (or access the Objective-C property `properties`). The properties are represented using whatever platform type is appropriate for a JSON object. In Objective-C they're an `NSDictionary`, in Java a `Map<String,Object>`.

Here's a simple example of getting a document's properties:

<div class="tabs"></div>

```objective-c+
CBLDocument* doc = [database documentWithID: _myDocID];
// We can directly access properties from the document object:
NSString* title = doc[@"title"];
// Or go through its properties dictionary:
NSDictionary* properties = doc.properties;
NSString* owner = properties[@"owner"];
```

```swift+
let doc = database.documentWithID(myDocID)
// We can directly access properties from the document object:
let title = doc["title"] as? String
// Or go through its properties dictionary:
let properties = doc.properties;
let owner = properties["owner"] as? String;
```

```java+
Document doc = database.getDocument(myDocId);
// We can directly access properties from the document object:
doc.getProperty("title");
// Or go through its properties dictionary:
Map<String, Object> properties = doc.getProperties();
String owner = (String) properties.get("owner");
```

```c+
var doc = database.GetDocument(myDocId);
// We can directly access properties from the document object:
doc.GetProperty("title");
// Or go through its properties dictionary:
var owner = doc.Properties["owner"];
```

> **Note:** The `getProperties` method is actually just a convenient shortcut for getting the Document's `currentRevision` and then getting its `properties` — since a document usually has multiple revisions, the properties really belong to a revision. Every existing document has a current revision (in fact that's how you can tell whether a document exists or not.) Almost all the time you'll be accessing a document's current revision, which is why the convenient direct properties accessor exists.

### Updating documents

There are two methods that update a document: `putProperties` and `update`. We'll cover them both, then explain why they're different.

`putProperties` is simpler: given a new JSON object, it replaces the document's body with that object. Actually what it does is creates a new revision with those properties and makes it the document's current revision.

<div class="tabs"></div>

```objective-c+
CBLDocument* doc = [database documentWithID: _myDocID];
NSMutableDictionary* p = [doc.properties mutableCopy];
p[@"title"] = title;
p[@"notes"] = notes;
NSError* error;
if (![doc putProperties: p error: &error]) {
    [self handleError: error];
}
```

```swift+
let doc = database.documentWithID(myDocID)
var properties = doc.properties
properties["title"] = title
properties["notes"] = notes
var error: NSError?
if doc.putProperties(properties, error: &error) == nil {
    self.handleError(error)
}
```

```java+
Document doc = database.getDocument(myDocID);
Map<String, Object> properties = new HashMap<String, Object>();
properties.putAll(doc.getProperties());
properties.put("title", title);
properties.put("notes", notes);
try {
    doc.putProperties(properties);
} catch (CouchbaseLiteException e) {
    e.printStackTrace();
}
```

```c+
var doc = database.GetDocument(myDocId);
var p = new Dictionary<string, object>(doc.Properties)
    {
        {"title", title},
        {"notes", notes}
    };
var rev = doc.PutProperties(p);
Debug.Assert(rev != null);
```

`update` instead takes a callback function or block (the details vary by language). It loads the current revision's properties, then calls this function, passing it an `UnsavedRevision` object, whose properties are a mutable copy of the current ones. Your callback code can modify this object's properties as it sees fit; after it returns, the modified revision is saved and becomes the current one.

<div class="tabs"></div>

```objective-c+
CBLDocument* doc = [database documentWithID: _myDocID];
NSError* error;
if (![doc update: ^BOOL(CBLUnsavedRevision *newRev) {
    newRev[@"title"] = title;
    newRev[@"notes"] = notes;
    return YES;
} error: &error]) {
    [self handleError: error];
}
```

```swift+
let doc = database.documentWithID(myDocID)
var error: NSError?
doc.update({ (newRev) -> Bool in
    newRev["title"] = title
    newRev["notes"] = notes
    return true
}, error: &error)
if error != nil {
    self.handleError(error)
}
```

```java+
Document doc = database.getDocument(myDocId);
doc.update(new Document.DocumentUpdater() {
    @Override
    public boolean update(UnsavedRevision newRevision) {
        Map<String, Object> properties = newRevision.getUserProperties();
        properties.put("title", title);
        properties.put("notes", notes);
        newRevision.setUserProperties(properties);
        return true;
    }
});
```

```c+
var doc = database.GetDocument(myDocId);
doc.Update((UnsavedRevision newRevision) => 
{
    var properties = newRevision.Properties;
    properties["title"] = title;
    properties["notes"] = notes;
    return true;
});
```

Whichever way you save changes, you need to consider the possibility of **update conflicts**. Couchbase Lite uses 
Multiversion 
Concurrency Control (MVCC) to guard against simultaneous changes to a document. (Even if your app code is single-threaded, the replicator runs on a background thread and can be pulling revisions into the database at the same time you're making changes.) Here's the typical sequence of events that creates an update conflict:

1. Your code reads the document's current properties, and constructs a modified copy to save
2. Another thread (perhaps the replicator) updates the document, creating a new revision with different properties
3. Your code updates the document with its modified properties

Clearly, if your update were allowed to proceed, the change from step 2 would be overwritten and lost. Instead, the update will fail with a conflict error. Here's where the two API calls differ:

1. putProperties simply returns the error to you to handle. You'll need to detect this type of error, and probably handle it by re-reading the new properties and making the change to those, then trying again.
2. update is smarter: it handles the conflict error itself by re-reading the document, then calling your block again with the updated properties, and retrying the save. It will keep retrying until there is no conflict.

> **Tip:** Of the two techniques, calling update may be a bit harder to understand initially, but it actually makes your code simpler and more reliable. We recommend it. (Just be aware that your callback block can be called multiple times.)

### Deleting documents

The `delete` method (`deleteDocument:` in Objective-C) deletes a document:

<div class="tabs"></div>

```objective-c+
CBLDocument* doc = [database documentWithID: _myDocID];
NSError* error;
if (![doc deleteDocument: &error]) {
    [self handleError: error];
}
```

```swift+
let doc = database.documentWithID(myDocID)
var error: NSError?
if !doc.deleteDocument(&error) {
    self.handleError(error)
}
```

```java+
Document task = (Document) database.getDocument("task1");
task.delete();
```

```c+
var doc = database.GetDocument(myDocId);
doc.Delete();
```

Deleting a document actually just creates a new revision (informally called a "tombstone") that has the special 
`_deleted` property set to `true`. This ensures that the deletion will replicate to the server, and then to other endpoints that pull from that database, just like any other document revision.

> **Note:** It's possible for the delete call to fail with a conflict error, since it's really just a special type of 
putProperties. In other words, something else may have updated the document at the same time you were trying to delete it. It's up to your app whether it's appropriate to retry the delete operation.

If you need to preserve one or more fields in a document that you want to `delete` (like a record of who deleted it or when it was deleted) you can avoid the delete method; just update the document and set the `UnsavedRevision`'s `deletion` property to `true`, or set JSON properties that include a `"_deleted"` property with a value of `true`. You can retain all of the fields, as shown in the following example, or you can remove specified fields so that the tombstone revision contains only the fields that you need.

<div class="tabs"></div>

```objective-c+
CBLDocument* doc = [database documentWithID: _myDocID];
NSError* error;
if (![doc update: ^BOOL(CBLUnsavedRevision *newRev) {
    newRev.isDeletion = YES;  // marks this as a 'tombstone'
    newRev[@"deleted_at"] = currentTimeString;
} error: &error]) {
    [self handleError: error];
}
```

```swift+
doc.update({ (newRev) -> Bool in
    newRev.isDeletion = true
    newRev["deleted_at"] = currentTimeString
    return true
}, error: &error)
if error != nil {
    self.handleError(error)
}
```

```java+
Document doc = database.getDocument(myDocId);
doc.update(new Document.DocumentUpdater() {
    @Override
    public boolean update(UnsavedRevision newRevision) {
        newRevision.setIsDeletion(true);
        Map<String, Object> properties = newRevision.getUserProperties();
        properties.put("deleted_at", currentTimeString);
        newRevision.setUserProperties(properties);
        return true;
    }
})
```

```c+
var doc = database.GetDocument(myDocId);
doc.Update((UnsavedRevision newRevision) => 
{
    newRevision.IsDeletion = true;
    newRevision.Properties["deleted_at"] = currentTimeString;
    return true;
});
```

## Document expiration (TTL)

Documents in a local database can have an expiration time. After that time, they are automatically purged from the database - this completely removes them, freeing the space they occupied.

The following example sets the TTL for a document to 5 seconds from the current time.

<div class="tabs"></div>

```objective-c+
NSDate* ttl = [NSDate dateWithTimeIntervalSinceNow: 5];
NSDictionary* properties = @{@"foo": @"bar"};
CBLDocument* doc = [db createDocument];
[doc putProperties:properties error:nil];
doc.expirationDate = ttl;
```

```swift+
var ttl = NSDate(timeIntervalSinceNow: 5)
var properties = ["foo": "bar"]
var doc = db.createDocument()
doc.putProperties(properties, error: nil)
doc.expirationDate = ttl
```

```java+
Date tll = new Date(System.currentTimeMillis() + 5000);
Document doc = database.createDocument();
Map<String, Object> properties = new HashMap<String, Object>();
properties.put("foo", "bar");
doc.putProperties(properties);
doc.setExpirationDate(ttl);
```

```c+
var doc = db.CreateDocument();
doc.PutProperties(new Dictionary<string, object> { { "foo", "bar" } });
doc.ExpireAfter(TimeSpan.FromSeconds(5));
```

Expiration timing is not highly precise. The times are stored with one-second granularity, and the timer that triggers expiration may be delayed slightly by the operating system or by other activity on the database thread. Expiration won't happen while the app is not running; this means it may be triggered soon after the app is activated or launched, to catch up with expiration times that have already passed.

**Note:** As with the existing explicit **purge** mechanism, this applies only to the local database; it has nothing 
to do
 with 
replication. This expiration time is not propagated when the document is replicated. The purge of the document does not cause it to be deleted on any other database. If the document is later updated on a remote database that the local database pulls from, the new revision will be pulled and the document will reappear.

## Document change notifications

You can register for notifications when a particular document is updated or deleted. This is very useful if you're display a user interface element whose content is based on the document: use the notification to trigger a redisplay of the view.

You can use change events for the following purposes:

- To be notified when new revisions are added to a document
- To be notified when a document is deleted
- To be notified when a document enters into a conflicted state

<div class="tabs"></div>

```objective-c+
[[NSNotificationCenter defaultCenter] addObserverForName: kCBLDocumentChangeNotification
            object: myDocument
             queue: nil
        usingBlock: ^(NSNotification *n) {
            CBLDatabaseChange* change = n.userInfo[@"change"];
            NSLog(@"There is a new revision, %@", change.revisionID);
            [self setNeedsDisplay: YES];  // redraw the view
        }
];
```

```swift+
NSNotificationCenter.defaultCenter().addObserverForName(kCBLDocumentChangeNotification, object: myDocument, queue: nil) { 
    (notification) -> Void in
        if let change = notification.userInfo!["change"] as? CBLDatabaseChange {
            NSLog("This is a new revision, %@", change.revisionID);
            set.setNeedsDisplay(true)
        }
}
```

```java+
Document doc = database.createDocument();
doc.addChangeListener(new Document.ChangeListener() { 
    @Override 
    public void changed(Document.ChangeEvent event) { 
        DocumentChange docChange = event.getChange();
        String msg = "New revision added: %s. Conflict: %s"; 
        msg = String.format(msg,
        docChange.getAddedRevision(), docChange.isConflict()); 
        Log.d(TAG, msg);
        documentChanged.countDown();
    } 
}); 
doc.createRevision().save();
```

```c+
var doc = database.CreateDocument();
doc.Change += (sender, e) =>
{
    var change = e.Change;
    var documentId = change.DocumentId;
    var revisionId = change.RevisionId;
    var isConflict = change.IsConflict;
    var addedRev = change.AddedRevision;
};
```

## Conflicts

So far we've been talking about a conflict as an error that occurs when you try to update a document that's been updated since you read it. In this scenario, Couchbase Lite is able to stop the conflict before it happens, giving your code a chance to re-read the document and incorporate the other changes.

However, there's no practical way to prevent a conflict when the two updates are made on different instances of the database. Neither app even knows that the other one has changed the document, until later on when replication propagates their incompatible changes to each other. A typical scenario is:

- Molly creates DocumentA; the revision is 1-5ac
- DocumentA is synced to Naomi's device; the latest revision is still 1-5ac
- Molly updates DocumentA, creating revision 2-54a
- Naomi makes a different change to DocumentA, creating revision 2-877
- Revision 2-877 is synced to Molly's device, which already has 2-54a, putting the document in conflict
- Revision 2-54a is synced to Naomi's device, which already has 2-877, similarly putting the local document in conflict

At this point, even though DocumentA is in a conflicted state, it needs to have a current revision. That is, when your app calls `getProperties`, Couchbase Lite has to return something. It chooses one of the two conflicting revisions (2-877 and 2-54a) as the "winner". The choice is deterministic, which means that every device that is faced with the same conflict will pick the same winner, without having to communicate. In this case it just compares the revision IDs "2-54a" and "2-877" and picks the higher one, "2-877".

To be precise, Couchbase Lite uses the following rules to handle conflicts:

- The winner is the undeleted leaf revision on the longest revision branch (i.e. with the largest prefix number in its
 revision ID.)
- If there are no undeleted leaf revisions, the deletion (tombstone) on the longest branch wins.
- If there's a tie, the winner is the one whose revision ID sorts higher in a simple ASCII comparison.

> **Note:** Couchbase Lite does not automatically merge the contents of conflicts. Automated merging sometimes works, but in many cases it'll give wrong results; only you know your document schemas well enough to decide how conflicts should be merged.

In some cases this simple "one revision wins" rule is good enough. For example, in a grocery list if two people rename the same item, one of them will just see that their change got overwritten, and may do it over again. But usually the details of the document content are more important, so the application will want to detect and resolve conflicts.

> **Note:** Resolving conflicts can also save the space in the database. Conflicting revisions stay in the database 
indefinitely until resolved, even surviving compactions. Therefore, it makes sense to deal with the conflict by at least deleting the non-winning revision.

Another reason to resolve conflicts is to implement business rules. For example, if two sales associates update the same customer record and it ends up in conflict, you might want the sales manager to resolve the conflict and "hand merge" the two conflicting records so that no information is lost.

There are two alternative ways to resolve a conflict:

- **Pick a winner.** Just decide which of the two changes should win, and delete the other one. The deleted revision will no longer be eligible as a conflict winner, so there won't be any more conflict.
- **Merge.** Consider the contents of both conflicting revisions and construct a new revision that incorporates both. The details are, of course, application-dependent, and might even require user interaction. Then resolve the conflict by saving the merged revision, then deleting the old losing conflict revision.

The following example shows how to resolve a conflict:

<div class="tabs"></div>

```objective-c+
CBLDocument* doc = [database documentWithID: _myDocID];
NSError* error;
NSArray* conflicts = [doc getConflictingRevisions: &error];
if (conflicts.count > 1) {
    // There is more than one current revision, thus a conflict!
    [database inTransaction: ^BOOL{
        // Come up with a merged/resolved document in some way that's
        // appropriate for the app. You could even just pick the body of
        // one of the revisions.
        NSDictionary* mergedProps = [self mergeRevisions: conflicts];
    
        // Delete the conflicting revisions to get rid of the conflict:
        CBLSavedRevision* current = doc.currentRevision;
        for (CBLSavedRevision* rev in conflicts) {
            CBLUnsavedRevision *newRev = [rev createRevision];
            if (rev == current) {
                // add the merged revision
                newRev.properties = [NSMutableDictionary dictionaryWithDictionary: mergedProps]; 
            } else {
                // mark other conflicts as deleted
                newRev.isDeletion = YES;  
            }
            // saveAllowingConflict allows 'rev' to be updated even if it
            // is not the document's current revision.
            NSError *error;
            if (![newRev saveAllowingConflict: &error])
                return NO;
        }
        return YES;
    }];
}
```

```swift+
let doc = database.documentWithID(myDocID)
var error: NSError?
if let conflicts = doc.getConflictingRevisions(&error) as? [CBLSavedRevision]{
    if conflicts.count > 1 {
        // There is more than one leaf revision, thus a conflict!
        database.inTransaction({ () -> Bool in
            // Come up with a merged/resolved document in some way that's
            // appropriate for the app. You could even just pick the body of
            // one of the revisions.
            var mergedProps = self.mergeRevisions(conflicts)
            // Delete the conflicting revisions to get rid of the conflict:
            var current = doc.currentRevision
            for rev in conflicts {
                var newRev = rev.createRevision()
                if rev == current {
                    // add the merged revision
                    newRev.properties = NSMutableDictionary(dictionary: mergedProps)
                } else {
                    // mark other conflicts as deleted
                    newRev.isDeletion = true
                }
                // saveAllowingConflict allows 'rev' to be updated even if it
                // is not the document's current revision.
                var error: NSError?
                if newRev.saveAllowingConflict(&error) == nil {
                    return false
                }
            }
            return true
        })
    }
}
```

```java+
final Document doc = database.getDocument(myDocID);
final List<SavedRevision> conflicts = doc.getConflictingRevisions();
if (conflicts.size() > 1) {
		// There is more than one current revision, thus a conflict!
		database.runInTransaction(new TransactionalTask() {
				@Override
				public boolean run() {
						try {
								// Come up with a merged/resolved document in some way that's
								// appropriate for the app. You could even just pick the body of
								// one of the revisions.
								Map<String, Object> mergedProps = mergeRevisions(conflicts);
								// Delete the conflicting revisions to get rid of the conflict:
								SavedRevision current = doc.getCurrentRevision();
								for (SavedRevision rev : conflicts) {
										UnsavedRevision newRev = rev.createRevision();
										if (rev.getId().equals(current.getId())) {
												newRev.setProperties(mergedProps);
										} else {
												newRev.setIsDeletion(true);
										}
										// saveAllowingConflict allows 'rev' to be updated even if it
										// is not the document's current revision.
										newRev.save(true);
								}
						} catch (CouchbaseLiteException e) {
								return false;
						}
						return true;
				}
		});
}
```

```c+
var doc = database.GetDocument(myDocId);
var conflicts = doc.ConflictingRevisions.ToList();
if (conflicts.Count > 1)
{
    // There is more than one current revision, thus a conflict!
    database.RunInTransaction(() => 
    {
        var mergedProps = MergeRevisions(conflicts);
        var current = doc.CurrentRevision;
        foreach(var rev in conflicts)
        {
            var newRev = rev.CreateRevision();
            if (rev == current)
            {
                newRev.SetProperties(mergedProps);
            }
            else
            {
                newRev.IsDeletion = true;
            }
            // saveAllowingConflict allows 'rev' to be updated even if it
            // is not the document's current revision.
            newRev.SaveAllowingConflict();
        }
        return true;
    });
}
```

## Document Conflict FAQ

### What if both devices make the same change to the document? Is that a conflict?

No. The revision ID is derived from a digest of the document body. So if two databases save identical changes, they end up with identical revision IDs, and Couchbase Lite (and the Sync Gateway) treat these as the same revision.

### I deleted a document, but the it's still in the database, only now its properties are different. What happened?

Sounds like the document was in conflict and you didn't realize it. You deleted the winning revision, but that made the other (losing) revision become the current one. If you delete the document again, it'll actually go away.

### How can I get the properties of the common ancestor revision, to do a three-way merge?

You can't always. Couchbase Lite isn't a version-control system and doesn't preserve old revision bodies indefinitely. But if the ancestor revision used to exist in your local database, and you haven't yet compacted the database, you can still get its properties. Get the `parentRevision` property of the current revision to get the ancestor, then see if its `properties` are still non-null.

### How can I tell if a document has a conflict?

Call its `getConflictingRevisions` method and see if more than one revision is returned.

### How can I tell if there are any conflicts in the database?

Use an all-documents query with the `onlyConflicts` mode.

## Purging documents

Purging a document is different from deleting it; it's more like forgetting it. The `purge` method removes all trace of a document (and all its revisions and their attachments) from the local database. It has no effect on replication or on remote databases, though.

Purging is mostly a way to save disk space by forgetting about replicated documents that you don't need anymore. It has some slightly weird interactions with replication, though. For example, if you purge a document, and then later the document is updated on the remote server, the next replication will pull the document into your database again.

## Special Properties

The body of a document contains a few special properties that store metadata about the document. For the most part you can ignore these since the API provides accessor methods for the same information, but it can still be helpful to know what they are if you encounter them.

- `_id`: The document ID.
- `_rev`: The revision ID.
- `_attachments`: Metadata about the document's attachments.
- `_deleted`: Only appears in a deletion (tombstone) revision, where it has the value `true`.

> **Note:** A leading underscore always denotes a reserved property—don’t use an underscore prefix for any of your own properties, and don't change the value of any reserved property.