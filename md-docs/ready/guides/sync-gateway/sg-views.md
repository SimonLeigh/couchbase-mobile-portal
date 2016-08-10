---
id: sg-views
title: Creating and querying a View
permalink: ready/guides/sync-gateway/views/index.html
---

Sync Gateway has a feature that allows clients to directly query Couchbase Views via the Sync Gateway REST API.

After walking through these steps, you will have a Couchbase View defined and have issued queries against it on both the Admin (4985) and User (4984) ports.

## Setup TodoLite sample

The rest of the tutorial will assume that you have done the following steps:

Installed TodoLite Android or TodoLite iOS

Created a Couchbase Server bucket called todolite, and used a Sync Gateway configuration that contains this example

Alternatively, instead of setting up TodoLite, you can adapt the rest of the article to your particular data model.

## Create an empty development view

**All views accessed via the Sync Gateway REST API must be created via the REST API rather than directly in the Couchbase Web UI, otherwise the queries will not work.**

ssh into that has access to the Sync Gateway Admin port, and copy and paste the following into a file called testview

```javascript
{
  "views":{
    "all_lists":{
      "map":"function (doc, meta) { if (doc.type != \"list\") { return; } emit(doc.title, doc.owner); }"
    }
  }
}
```

Store this in Sync Gateway via following curl request:

```bash
curl -X PUT -H "Content-type: application/json" localhost:4985/todolite/_design/all_lists --data @testview
```

You should receive a response like:

```
{"id":"all_lists","ok":true,"rev":"1-792dc3d88106756208b28a29ab3825f6"}
```

## Testing the view via the Admin port

Now we will access the Couchbase View created in the previous article via the Sync Gateway admin port (4985). The Admin port is easier to test on, because there are no access control restrictions or user auth to worry about.

- ssh into your sync gateway machine
- Query the view via curl:
  ```
  curl localhost:4985/todolite/_design/all_lists/_view/all_lists
  ```
- You should receive a response like:
  ```
  {
    "total_rows":1,
    "rows":[
        {
            "id":"57b82878-a7dc-478a-80c1-e2700f8f5a11",
            "key":"Food",
            "value":"profile:778915335487383"
        }
    ]
  }
  ```

## Testing the view via the User port

Views are also available via the User port (4984), and will automatically filter the returned data to the subset of the data which the user has access to.

- Find out your user id
  ```
  curl localhost:4985/todolite/_user/
  ```
  and look for your facebook ID. If you don't know your facebook ID, you can login to developer.facebook.com to find it.
  Create a new session token via
  ```
  curl -X POST -H "Content-type: application/json" -d '{"name": "your-user-id"}' localhost:4985/todolite/_session
  ```
  The response will look like this:
  ```
  {"session_id":"03bdd7f1be83f035a7298924f9a28270feac7f4c","expires":"2015-03-17T21:39:16.076186179Z","cookie_name":"SyncGatewaySession"}
  ```
  Query the view on port 4984 via
  ```
  curl --cookie "SyncGatewaySession=03bdd7f1be83f035a7298924f9a28270feac7f4c" localhost:4984/todolite/_design/all_lists/_view/all_lists
  ```
  You should receive a response like:
  ```
  {
    "total_rows":1,
    "rows":[
        {
            "id":"57b82878-a7dc-478a-80c1-e2700f8f5a11",
            "key":"ShoppingList",
            "value":"profile:778915335487383"
        }
    ]
  }
  ```