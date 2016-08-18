---
id: sg-views
title: Creating and querying a View
permalink: ready/guides/sync-gateway/views/index.html
---

Sync Gateway has a feature that allows clients to directly query Couchbase Views via the Sync Gateway REST API.

Let's take the scenario of a ToDo List application where any list can be shared with as many users (registered on Sync Gateway) as possible. Every user could have access to a **users** channel in order to access them in a pull replication and display them on a view. The problem with this approach is that as the user base grows the number of documents in the **users** channel would quickly become too large. This is a good example for using a view query on Sync Gateway and leveraging querystring parameters such as **startkey**, **endkey** and **limit** to display a subset of the user base or even to search through the index.

After reading through this guide, you will have a Couchbase Server view registered and have issued queries against it on both the Admin (4985) and Public (4984) ports.

## Sync Gateway Configuration

Create a new file called **sync-gateway-config.json** with the following:

```javascript
{
  "databases": {
    "todo": {
      "unsupported": {
        "user_views": {
          "enabled":true
        }
      },
      "bucket": "walrus:",
      "users": {
        "GUEST": {"disabled": false, "admin_channels": ["users"]}
      }
    }
  }
}
```

The `unsupported.user_views` field in the database config enables view queries on the public REST API which is disabled by default.

> **Note:** All views accessed via the Sync Gateway REST API must be created via the REST API rather than directly in the Couchbase Web UI, otherwise the queries will not work.

Start Sync Gateway and add a few documents for this example:

```bash
curl -H 'Content-Type: application/json' -vX POST 'http://localhost:4985/todo/_bulk_docs' \
     -d '{"docs": [{"type": "user", "name": "john"},{"type": "user", "name": "alice"},{"type": "user", "name": "ben"}]}'
```

Register a new map/reduce query on the admin port:

```bash
curl -H 'Content-Type: application/json' -vX PUT 'http://localhost:4985/todo/_design/users' \
     -d '{"views": {"all": {"map": "function(doc, meta) {if (doc.type == \"user\") {emit(doc.name, null);}}"}}}'
```

The response should be a `201 Created` to indicate that the design document was saved successfully.

## Testing the view via the Admin port

Now you will access the Couchbase View created in the previous article via the Sync Gateway admin port (4985). The admin port is easier to test on because there are no access control restrictions or user auth to worry about.

```bash
curl -vX GET 'http://localhost:4985/todo/_design/users/_view/all'
```

The response contains all three users.

```javascript
{
  "total_rows":3,
  "rows":[
    {"id":"6afade7d747bf0d9d3b37507033e9fe4","key":"alice","value":null},
    {"id":"a1523cc6052ea1827bad5fa20b53a7ce","key":"ben","value":null},
    {"id":"3cd07689fab38621498cbf591bfdb7c1","key":"john","value":null}
  ],
  "Collator":{}
}
```

Add other types of documents, they will not be returned in this view query result.

## Testing the view via the Public port

Views are also available via the Public REST API (4984), and will automatically filter the returned data to the subset of the data which the user has access to.

```bash
curl -vX GET 'http://localhost:4984/todo/_design/users/_view/all'
```

This time the result set is empty. Indeed, in this case the request is not authenticated so it's considered as the GUEST user. In the configuration file, the GUEST user is granted access to the **users** channel but the 3 users you added previously are not in this channel. Stop and start Sync Gateway which will clean the database and send the following to map the documents to the **users** channel.

```javascript
curl -H 'Content-Type: application/json' -vX POST 'http://localhost:4985/todo/_bulk_docs' \
     -d '{"docs": [{"type": "user", "name": "john", "channels": ["users"]},{"type": "user", "name": "alice", "channels": ["users"]},{"type": "user", "name": "ben", "channels": ["users"]}]}'
```

> **Note:** The configuration file does not contain a custom sync function. In this case, you used the default sync function which is `function(doc, oldDoc) {channel(doc.channels);}` and the `channels` field on the document body accordingly.

Register the view once more and run the same query as above on the user port:

```bash
curl -vX GET 'http://localhost:4984/todo/_design/users/_view/all'
```

The response now contains all 3 user documents:

```bash
{
  "total_rows":3,
  "rows":[
    {"id":"fa80eec8e23e48aa2e65506144940c56","key":"alice","value":null},
    {"id":"a1a12b6a8872abae38a31eeb00429e6a","key":"ben","value":null},
    {"id":"6ce25331a9191383439a5b314f4a7b32","key":"john","value":null}
  ],
  "Collator":{}
}
```