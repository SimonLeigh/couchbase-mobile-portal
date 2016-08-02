---
id: attachment
title: Attachment
permalink: ready/guides/couchbase-lite/native-api/attachment/index.html
---

Attachments store data associated with a document, but are not part of the document's JSON object. Their primary purpose is to make it efficient to store large binary data in a document. Binary data stored in JSON has to be base64-encoded into a string, which inflates its size by 33%. Also, binary data blobs are often large (think of camera images or audio files), and big JSON documents are slow to parse.

Attachments are uninterpreted data (blobs) stored separately from the JSON body. A document can have any number of attachments, each with a different name. Each attachment is also tagged with a MIME type, which isn't used by Couchbase Lite but can help your application interpret its contents. Attachments can be arbitrarily large, and are only read on demand, not when you load a Document object.

Attachments also make replication more efficient. When a document that contains pre-existing attachments is synced, only attachments that have changed since the last sync are transferred over the network. In particular, changes to document JSON values will **not** cause Couchbase Lite to re-send attachment data when the 
attachment has not changed.

In the native API, attachments are represented by the `Attachment` class. Attachments are available from a `Revision` object. From a `Document`, you get to the attachments via its `currentRevision`.

## Reading attachments

The `Revision` class has a number of methods for accessing attachments:

- `attachmentNames` returns the names of all the attachments.
- `attachmentNamed` returns an `Attachment` object given its name.
- `attachments` returns all the attachments as `Attachment` objects.

Once you have an `Attachment` object, you can access its name, MIME type and content length. The accessors for the content vary by platform: on iOS it's available as an `NSData` object or as an `NSURL` pointing to a read-only file; in Java you read the data from an `InputStream`.

<div class="tabs"></div>

```objective-c+
// Load an JPEG attachment from a document into a UIImage:
CBLDocument* doc = [db documentWithID: @"Robin"];
CBLRevision* rev = doc.currentRevision;
CBLAttachment* att = [rev attachmentNamed: @"photo.jpg"];
UIImage* photo = nil;
if (att != nil) {
    NSData* imageData = att.content;
    photo = [[UIImage alloc] initWithData: imageData];
}
```

```swift+
// Load an JPEG attachment from a document into a UIImage:
let doc = db.documentWithID("Robin")
let rev = doc.currentRevision
let att = rev.attachmentNamed("photo.jpg")
var photo: UIImage?
if att != nil {
    photo = UIImage(att.content)
}
```

```java+
// Load an JPEG attachment from a document into a Drawable:
Document doc = database.getDocument("Robin");
Revision rev = doc.getCurrentRevision();
Attachment att = rev.getAttachment("photo.jpg");
if (att != null) {
    InputStream is = att.getContent();
    Drawable d = Drawable.createFromStream(is, "src name");
}
```

```c+
// Load an JPEG attachment from a document:
var doc = database.GetDocument("Robin");
var rev = doc.CurrentRevision;
var att = rev.GetAttachment("photo.jpg");
if (att != null)
{
    var imageData = att.Content.ToList<byte>();
    // Convert the raw image data into an Image object based
    // on your development platform.
}
```

## Writing (and deleting) attachments

To create an attachment, first create a mutable `UnsavedRevision` object by calling `createRevision` on the document's `currentRevision`. Then call `setAttachment` on the new revision to add an attachment. (You can of course also change the JSON by modifying the revision's properties.) Finally you call `save` to save the new revision.

Updating an attachment's content (or type) works exactly the same way: the `setAttachment` method will replace any existing attachment with the same name.

<div class="tabs"></div>

```objective-c+
// Add or update an image to a document as a JPEG attachment:
CBLDocument* doc = [db documentWithID: @"Robin"];
CBLUnsavedRevision* newRev = [doc.currentRevision createRevision];
NSData* imageData = UIImageJPEGRepresentation(photo, 0.75);
[newRev setAttachmentNamed: @"photo.jpg"
           withContentType: @"image/jpeg"
                   content: imageData];
// (You could also update newRev.properties while you're here)
NSError* error;
assert([newRev save: &error]);
```

```swift+
// Add or update an image to a document as a JPEG attachment:
let doc = db.documentWithID("Robin")
let newRev = doc.currentRevision.createRevision()
let imageData = UIImageJPEGRepresentation(photo, 0.75)
newRev.setAttachmentNamed("photo.jpg", withContentType: "image/jpeg", content: imageData)
var error: NSError?
assert(newRev.save(&error) != nil)
```

```java+
// Add an image in a callback after invoking the Android Camera activity
protected void onActivityResult(int requestCode, int resultCode, Intent data){
    InputStream stream = null;
    if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
        InputStream stream = getContentResolver().openInputStream(data.getData());
        // Add or update an image to a document as a JPEG attachment:
        Document doc = database.getDocument("Robin");
        UnsavedRevision newRev = doc.getCurrentRevision().createRevision();
        newRev.setAttachment("photo.jpg", "image/jpeg", stream);
        newRev.save();
    }
}
```

```c+
// Add or update an image to a document as a JPEG attachment:
var doc = database.GetDocument("Robin");
var newRev = doc.CurrentRevision.CreateRevision();
var imageStream = GetAsset("photo.png");
newRev.SetAttachment("photo.jpg", "image/jpeg", imageStream);
var savedRev = newRev.Save();
Debug.Assert(savedRev != null);
```

To delete an attachment, just call `removeAttachment` instead of `setAttachment`.

<div class="tabs"></div>

```objective-c+
// Remove an attachment from a document:
CBLDocument* doc = [db documentWithID: @"Robin"];
CBLUnsavedRevision* newRev = [doc.currentRevision createRevision];
[newRev removeAttachmentNamed: @"photo.jpg"];
// (You could also update newRev.properties while you're here)
NSError* error;
assert([newRev save: &error]);
```

```swift+
// Remove an attachment from a document:
let doc = db.documentWithID("Robin")
let newRev = doc.currentRevision.createRevision()
newRev.removeAttachmentNamed("phto.jpg")
var error: NSError?
assert(newRev.save(&error) != nil)
```

```java+
// Remove an attachment from a document:
Document doc = database.getDocument("Robin");
UnsavedRevision newRev = doc.getCurrentRevision().createRevision();
newRev.removeAttachment("photo.jpg");
// (You could also update newRev.properties while you're here)
newRev.save();
```

```c+
// Remove an attachment from a document:
var doc = database.GetDocument("Robin");
var newRev = doc.CurrentRevision.CreateRevision();
newRev.RemoveAttachment("photo.jpg");
var savedRev = newRev.Save();
Debug.Assert(savedRev != null);
```

## Attachment storage

In general, you don't need to think about where and how Couchbase Lite is storing data. But since attachments can occupy a lot of space, it can be helpful to know where that space is and how it's managed.

Attachments aren't stored in the database file itself. Instead they are individual files, contained in a directory right next to the database file. Each attachment file has a cryptic name that is actually a SHA-1 digest of its contents.

As a consequence of the naming scheme, attachments are de-duplicated: if multiple attachments in the same database have exactly the same contents, the data is only stored once in the filesystem.

Updating a document's attachment does **not** immediately remove the old version of the attachment. And deleting a document does not immediately delete its attachments. An attachment file has to remain on disk as long as there are any document revisions that reference it, And a revision persists until the next database compaction after it's been replaced or deleted. (Orphaned attachment files are deleted from disk as part of the compaction process.) So if you're concerned about the space taken up by attachments, you should compact the database frequently, or at least after making changes to large attachments.