---
id: sync-function-api
title: Sync Function API
permalink: ready/guides/sync-gateway/sync-function-api-guide/index.html
---

The sync function is the core API you interact with on Sync Gateway. This article explains its functionality, and how you write and configure it.

## Introduction

The **sync function** is the core API you interact with on Sync Gateway. For simple applications it might be the only server-side code you need to write. For more complex applications it is still a primary touchpoint for managing data routing and access control.

The sync function is a JavaScript function whose source code is stored in the Sync Gateway's database configuration file. Every time a new document, revision or deletion is added to a database, the sync function is called and given a chance to examine the document. It can do the following things:

- **Validate the document:** If the document has invalid contents, the sync function can throw an exception to reject it. The document won't be added to the database, and the client request will get an error response
- **Authorize the change:** The sync function can call `requireUser()` or `requireRole()` to specify what user(s) are allowed to modify the document. If the user making the change isn't in that list, an exception is thrown and the update is rejected with an error. Similarly, `requireChannels()` requires that the user making the change have access to any of the listed channels.
- **Assign the document to channels:** Based on the contents of the document, the sync function can call **channel()** to add the document to one or more channels. This makes it accessible to users who have access to those channels, and will cause the document to be pulled by users that are subscribed to those channels.
- **Grant users access to channels:** Calling `access(user, channel)` grants a user access to a channel. This allows documents to act as membership lists or access-control lists.

> **Caution:** **The sync function is crucial to the security of your application.** It's in charge of data validation, and of authorizing both read and write access to documents. The API is high-level and lets you do some powerful things very simply, but you do need to remain vigilant and review the function carefully to make sure that it detects threats and prevents all illegal access. The sync function should be a focus of any security review of your application.

### Sync function structure

You write your sync function in JavaScript. The basic structure of the sync function looks like this:

```javascript
function (doc, oldDoc) {
    // Your code here
}
```

The sync function arguments are:

- `doc`: An object, the content of the document that is being saved. This matches the JSON that was saved by the Couchbase Lite and replicated to Sync Gateway. The `_id` property contains the document ID, and the `_rev` property the new revision ID. If the document is being deleted, there will be a `_deleted` property with the value true.
- `oldDoc`: If the document has been saved before, the revision that is being replaced is available in this argument. Otherwise it's `null`. (In the case of a document with conflicts, the current provisional winning revision is passed in `oldDoc`.) Your implementation of the sync function can omit the `oldDoc` parameter if you do not need it (JavaScript ignores extra parameters passed to a function).

### The sync function and document revisions

It's important to understand how the sync function interacts with document revisions.

The sync function is called every time a new revision/update is made to a document, and the changes to channels and access made by the sync function are _tied to that revision_. If the document is later updated, the sync function will be called again on the new revision, and the new channel assignments and user/channel access _replace_ the ones from the first call.

> **Note:** Routing changes have no effect until the document is actually saved in the database, so if the sync function first calls `channel()` or `access()`, but then rejects the update, the channel and access changes will not occur.

_Document deletions are updates!_ A deletion is simply a new revision where the document body contains a `_deleted` propert with the value `true`. The sync function is called on deletions. Most of the time a deletion revision contains no properties (other than `_deleted`), in which case the sync function probably won't assign any channels or access anyway. But it is possible for a client to create a deletion revision with other properties in it, in which case the sync function might need to explicitly test for `_deleted`.

If a document is in conflict there will be multiple current revisions. The default, "winning" one is the one whose channel assignments and access grants take effect.

### Default sync function

If you don't supply a sync function, Sync Gateway uses the following default sync function:

```javascript
function (doc) {
   channel(doc.channels);
}
```

In plain English: by default, a document will be assigned to the channels listed in its `channels` property (whose value must be a string or an array of strings.) More subtly, since there is no validation, _any user can change any document_. For this reason, the default sync function is really only useful for experimentation and development.

### Changing the sync function

To change a database's sync function, you simply edit the function definition in the configuration file, then restart the Sync Gateway. (Or instead of restarting, you can use the REST API to "delete" and then "create" the database.)

Changing the sync function is an expensive operation because it requires every document in the database to be processed by the new function, to update the channel and access assignments. This happens while the database is being opened, and the database can't accept any requests until this process is complete (because no user's full access privileges are known until all documents have been scanned.) Therefore the update may result in application downtime.

If you need to ensure access to the database during the update, you can create a read-only backup of the Sync Gateway's bucket beforehand, then run a secondary Sync Gateway on the backup bucket, in read-only mode. After the update is complete, switch to the main Gateway and bucket.

In a clustered environment with multiple Sync Gateways sharing the load, all the Gateways need to share the same configuration, so they all need to be taken down together. After the configuration is updated, one instance should be brought up so it can update the database — if more than one is running at this time, they'll conflict with each other. After the first instance finishes opening the database, the others can be started.

## Validation and Authorization

The sync function API provides several methods that you can use to validate document creation, updates and deletions. For error conditions, you can simply call the built-in JavaScript `throw()` function. You can also enforce user access privileges by calling `requireUser()`, `requireRole()`, or `requireAccess()`.

What happens to rejected documents? Firstly, they aren't saved to the Sync Gateway's database, so no access changes take effect. Instead an error code (usually 403 Forbidden) is returned to Couchbase Lite's replicator. But the endpoint still has the invalid document in its local database, and it's up to it to fix it. Instead, we recommend that you not create invalid documents in the first place. As much as possible, your app logic and validation function should prevent invalid documents from being created locally. The server-side sync function validation should be seen as a fail-safe and a guard against malicious access.

> **Caution:** It's very important to understand that channels govern whether a user can read a document, but not whether they can write to it! There are legitimate use cases for being able to create documents that you can't read afterwards (such as drop-boxes) so the Sync Gateway doesn't prevent this. **By default, any user can create, update or delete any document;** it's up to your sync function to check that the user submitting the revision is authorized to make the change.

In validating a document, you'll often need to compare the new revision to the old one, to check for illegal changes in state. For example, some properties may be immutable after the document is created, or may be changeable only by certain users, or may only be allowed to change in certain ways. That's why the current document contents are given to the sync function, as the `oldDoc` parameter.

> **Caution:** All properties of the `doc` parameter should be considered _untrusted_, since this is after all the object that you're validating. This may sound obvious, but it can be easy to make mistakes, like calling `requireUser(doc.owners)` instead of `requireUser(oldDoc.owners)`. When using one document property to validate another, look up that property in `oldDoc`, not `doc`!

Validation checks often need to treat deletions specially, because a deletion is just a revision with a `"_deleted": true` property and usually nothing else. Many types of validations won't work on a deletion because of the missing properties — for example, a check for a required property, or a check that a property value doesn't change. You'll need to skip such checks if `doc._deleted` is true.

### throw()

At the most basic level, the sync function can prevent a document from persisting or syncing to any other users by calling `throw()` with an error object containing a `forbidden`: property. You enforce the validity of document structure by checking the necessary constraints and throwing an exception if they're not met.

Here is an example sync function that disallows all writes to the database it is in.

```javascript
function(doc) {
   throw({forbidden: "read only!"})
}
```

The document update will be rejected with an HTTP 403 "Forbidden" error code, with the value of the `forbidden:` property being the HTTP status message. This is the preferred way to reject an update.

Any other exception (including implicit ones thrown by the JavaScript runtime, like array bounds exceptions) will also prevent the document update, but will cause the gateway to return an HTTP 500 "Internal Error" status.

### requireUser(username)

The `requireUser()` function authorizes a document update by rejecting it unless it's made by a specific user or users, as shown in the following example:

```javascript
// Throw an error if username is not "snej":
requireUser("snej");
                            
// Throw an error if username is not in the list:
requireUser(["snej", "jchris", "tleyden"]);
```

The function signals rejection by throwing an exception, so the rest of the sync function will not be run.

### requireRole(rolename)

The `requireRole()` function authorizes a document update by rejecting it unless the user making it has a specific role or roles, as shown in the following example:

```javascript
// Throw an error unless the user has the "admin" role:
requireRole("admin");
                            
// Throw an error unless the user has one or more of those roles:
requireRole(["admin", "old-timer"]);
```

The argument may be a single role name, or an array of role names. In the latter case, the user making the change must have one or more of the given roles.

The function signals rejection by throwing an exception, so the rest of the sync function will not be run.

### requireAccess(channels)

The `requireAccess()` function authorizes a document update by rejecting it unless the user making it has access to at least one of the given channels, as shown in the following example:

```javascript
// Throw an exception unless the user has access to read the "events" channel:
requireAccess("events");
                            
// Throw an exception unless the user can read one of the channels in the
// previous revision's "channels" property:
if (oldDoc) {
    requireAccess(oldDoc.channels);
}
```

The function signals rejection by throwing an exception, so the rest of the sync function will not be run.

### Example

Here's an example of a complete, useful sync function that properly validates and authorizes both new and updated documents. The requirements are:

- Only users with the role `editor` may create or delete documents.
- Every document has an immutable `creator` property containing the name of the user who created it.
- Only users named in the document's (required, non-empty) `writers` property may make changes to a document, including deleting it.
- Every document must also have a `title` and a `channels` property.

```javascript
function (doc, oldDoc) {
    if (doc._deleted) {
        // Only editors with write access can delete documents:
        requireRole("role:editor");
        requireUser(oldDoc.writers);
        // Skip other validation because a deletion has no other properties:
        return;
    }
    // Required properties:
    if (!doc.title || !doc.creator || !doc.channels || !doc.writers) {
        throw({forbidden: "Missing required properties"});
    } else if (doc.writers.length == 0) {
        throw({forbidden: "No writers"});
    }
    if (oldDoc == null) {
        // Only editors can create documents:
        requireRole("role:editor");
        // The 'creator' property must match the user creating the document:
        requireUser(doc.creator)
    } else {
        // Only users in the existing doc's writers list can change a document:
        requireUser(oldDoc.writers);
        // The "creator" property is immutable:
        if (doc.creator != oldDoc.creator) {
            throw({forbidden: "Can't change creator"});
        }
    }
    // Finally, assign the document to the channels in the list:
    channel(doc.channels);
}
```

## Routing

The sync function API provides several functions that you can use to route documents. The routing functions assign documents to channels, and enable user access to channels (which will route documents in those channels to those users.)

> **Note:** Routing changes are tied to the current revision of the document and will be replaced when the document is updated. Make sure to read the "Sync function and document revisions" section.

### channel (name)

The `channel()` function routes the document to the named channel(s). It accepts one or more arguments, each of which must be a channel name string, or an array of strings. The channel function can be called zero or more times from the sync function, for any document. Here is an example that routes all "published" documents to the "public" channel:

```javascript
function (doc, oldDoc) {
   if (doc.published) {
      channel ("public");
   } 
}
```

> **Tip:** As a convenience, it is legal to call `channel` with a `null` or `undefined` argument; it simply does nothing. This allows you to do something like `channel(doc.channels)` without having to first check whether `doc.channels` exists.

> **Note:** Channels don't have to be predefined. A channel implicitly comes into existence when a document is routed to it.

If the document was previously routed to a channel, but the current call to the sync function (for an updated revision) doesn't route it to that channel, the document is removed from the channel. This may cause users to lose access to that document. If that happens, the next time Couchbase Lite pulls changes from the gateway, it will receive an empty revision of the document with nothing but a `"_removed": true` property. (Of course the previous revisions of the document remain in your Couchbase Lite database until it's compacted.)

### access (username, channelname)

The `access()` function grants access to a channel to a specified user. It can be called multiple times from a sync function.

The first argument can be an array of strings, in which case each user in the array is given access. The second argument can also be an array of strings, in which case the user(s) are given access to each channel in the array. As a convenience, either argument may be `null` or `undefined`, in which case nothing happens.

If a user name begins with the prefix `role:`, the rest of the name is interpreted as a role rather than a user. The call then grants access to the specified channels for all users with that role.

> **Note:** The effects of all access calls by all active documents are effectively unioned together, so if _any_ document grants a user access to a channel, that user has access to the channel.

> **Caution:** Revoking access to a channel can cause a user to lose access to documents, if s/he no longer has access to any channels those documents are in. However, the replicator does _not_ currently delete such documents that have already been synced to a user's device (although future changes to those documents will not be replicated.) This is a design limitation of the Sync Gateway 1.0 that may be resolved in the future.

The following code snippets shows some valid ways to call `access()`:

```javascript
access ("jchris", "mtv");
access ("jchris", ["mtv", "mtv2", "vh1"]);
access (["snej", "jchris", "role:admin"], "vh1");
access (["snej", "jchris"], ["mtv", "mtv2", "vh1"]);
access (null, "hbo");  // no-op
access ("snej", null);  // no-op
```

Here is an example of a sync function that grants access to a channel for all the users listed in a document:

```javascript
function (doc, oldDoc) {
    if (doc.type == "chat_room") {
        // Give members access to the chat channel this document manages:
        access (doc.members, doc.channel_name);
                            
        // Put this document in the channel it manages:
        channel (doc.channel_name);
    }
}
```

### role (username, rolename)

The `role()` function grants a user a role, indirectly giving them access to all channels granted to that role. It can also affect the user's ability to revise documents, if the access function requires role membership to validate certain types of changes. Its use is similar to `access` — the value of either parameter can be a string, an array of strings, or null. If the value is null, the call is a no-op.

For consistency with the `access` call, role names must always be prefixed with `role:`. An exception is thrown if a role name doesn't match this. Some examples:

```javascript
role ("jchris", "role:admin");
role ("jchris", ["role:portlandians", "role:portlandians-owners"]);
role (["snej", "jchris", "traun"], "role:mobile");
role ("ed", null);  // no-op
```

> **Note:** Roles, like users, have to be explicitly created by an administrator. So unlike channels, which come into existence simply by being named, you can't create new roles with a `role()` call. Nonexistent roles don't cause an error, but have no effect on the user's access privileges. You can create a role after the fact; as soon as a role is created, any pre-existing references to it take effect.