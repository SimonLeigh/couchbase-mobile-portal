---
id: Integrating External Stores
title: Integrating External Stores
permalink: ready/guides/sync-gateway/integrating-external-stores/index.html
---

The Sync Gateway REST API is divided in two categories: the Public REST API available on port 4984 and the Admin REST API accessible on port 4985. Those are the default ports and they can be changed in the configuration file of Sync Gateway. 

In this guide, you will learn how to run the following operations on the Admin REST API:

- Bulk importing of documents.
- Exporting via the changes feed.
- Importing attachments.

> **Note:** When you're starting out with Couchbase, use the Sync Gateway REST API, not bucket shadowing. Bucket shadowing should not be used except when there's a pre-existing Couchbase bucket being managed by client APIs, that now needs to be synced to mobile clients.

## External Store

In this guide, you will use a simple movies API as the external data store. [Download the stub data and API server](https://cl.ly/3g2g1L1j2S2i) and unzip the content into a new directory. To start the server of the external store run the following commands:

```bash
cd external-store
npm install
node server.js
```

You can open a browser window at [http://localhost:8000/movies](http://localhost:8000/movies) to view the JSON data.

The external store supports two endpoints:

- GET `/movies`: Retrieves all movies (from **movies.json**).
- POST `/movies`: Takes one movie as the request body and updates the item with the same `_id` in **movies.json**.

## Importing Documents

The Sync Gateway Swagger JS library is a handy tool to send HTTP requests without having to write your own HTTP API wrapper. It relies on the Couchbase Mobile Swagger specs. In this case, you will use the [Admin REST API spec](http://developer.couchbase.com/mobile/swagger/sync-gateway-admin/). In the same directory, install the following dependencies.

```bash
npm install swagger-client && request-promise
```

[Download Sync Gateway](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile) and start it from the command line with a database called `movies_lister`.

```bash
~/Downloads/couchbase-sync-gateway/bin/sync_gateway -dbname movies_lister
```

The Sync Gateway database is now available at [http://localhost:4985/movies_lister/](http://localhost:4985/movies_lister/). Create a new file called `import.js` with the following to retrieve the movies and insert them in the Sync Gateway database.

```javascript
var request = require('request-promise')
  , Swagger = require('swagger-client');

var api = 'http://localhost:8000/movies'
  , db = 'movies_lister';

var client = new Swagger({
  url: 'http://developer.couchbase.com/mobile/swagger/sync-gateway-admin/spec.json',
  usePromise: true
}).then(function (client) {
  var data = [];
  // 1
  request({uri: api, json: true})
    // 2
    .then(function (movies) {
      data = movies;
      return client.database.post_db_bulk_docs({db: db, body: {docs: movies}});
    })
    .then(function (res) {
      return res.obj;
    })
    // 3
    .each(function (row) {
      var movie = data.filter(function (movie) {
        return movie._id == row.id ? true : false
      })[0];
      movie._rev = row.rev;
      var options = {
        method: 'POST',
        uri: api,
        body: movie,
        headers: {
          'Content-Type': 'application/json'
        },
        json: true
      };
      return request(options);
    })
    .then(function (res) {
      console.log('Revs of ' + res.length + ' imported');
    });
});
```

Here's what the code above is doing:

1. Use the [request-promise](https://github.com/request/request-promise) library to retrieve the movies from the external store.
2. Save the movies to Sync Gateway. The `post_db_bulk_docs` method takes a db name (`movies_lister`) and the documents to save in the request body. Notice that the response from the external store is an array and must be wrapped in a JSON object of the form `{docs: movies}`.
3. The response of the `/{db}/_bulk_docs` request contains the generated revision numbers which are written back to the external store.

> **Tip:** The Admin REST API Swagger spec is dynamically loaded. You can use the `.help()` method to query the available object and methods. This method is very helpful during development as it offers the documentation on the fly in the console.

```javascript
client.help(); // prints all the tags to the console
client.database.help(); // prints all the database methods to the console
client.database.post_db_bulk_docs.help(); // prints all the parameters (querystring and request body)
```

Start the program from the command line:

```bash
node import.js
```

Open the Sync Gateway Admin UI and you should see all the movies there.

![](img/admin-ui-movies-lister.png)

Notice that the `_rev` property is also stored on each record on the external store, `movies.json`.

Run the program again, the same number of documents are visible in Sync Gateway. This time with a 2nd generation revision number. This update operation was succesful because the parent revision number was sent as part of the request body.

## Exporting Documents

To export documents from Couchbase Mobile to the external system you will use a changes feed request to subscribe to changes and persist them to the external store.

Install the following modules:

```bash
npm install swagger-client && request
```

Create a new file called `export.js` with the following:

```javascript
var request = require('request')
  , Swagger = require('swagger-client');

var api = 'http://localhost:8000/movies'
  , db = 'movies_lister';

var client = new Swagger({
  url: 'http://developer.couchbase.com/mobile/swagger/sync-gateway-admin/spec.json',
  success: function () {

    // 1
    client.database.get_db({db: db}, function (res) {
      // 2
      getChanges(res.obj.update_seq);
    });

    function getChanges(seq) {
      // 3
      var options = {db: db, feed: 'longpoll', since: seq, include_docs: true};
      client.database.get_db_changes(options, function (res) {

        var results = res.obj.results;
        for (var i = 0; i < results.length; i++) {
          var row = results[i];
          console.log("Document with ID " + row.id);
          // 4
          var options = {
            url: api,
            method: 'POST',
            body: JSON.stringify(row.doc),
            headers: {
              'Content-Type': 'application/json'
            }
          };
          request(options, function (error, response, body) {
            if (!error && response.statusCode == 200) {
              var json = JSON.parse(body);
              console.log(json);
              console.log("Wrote update for doc " + json.id + " to external store.");
            }
          });
        }

        getChanges(res.obj.last_seq);
      });
    }

  }
});
```

Here's what the code above is doing:

1. Gets the last sequence number of the database.
2. Calls the `getChanges` method with the last sequence number.
3. Sends changes request to Sync Gateway with the following parameters:
    - **feed=longpoll**
    - **include_docs=true**
    - **since=X** (where X is the sequence number)
4. Write the document to the external store.

Run the program from the command line:

```bash
node export.js
```

Open the Admin UI on [http://localhost:4985/_admin/db/movies_lister](http://localhost:4985/_admin/db/movies_lister) and make changes to a document. Notice that the change is also updated in the external store.

[//]: # "TODO: Link to gif. It's there in ./img but AuthX ingestion ignores GIFs."
![](https://cl.ly/1s2Q0t1i3W2w/export-update.gif)

## Importing Attachments

Every movie in the stub API has a link to a thumbnail (in the `posters.thumbnail` property). Before sending the `_bulk_docs` request, you will fetch the thumbnail for each movie and embed it as a base64 string under the `_attachments` property.

Install the following dependencies:

```bash
npm install request-promise && swagger-client
```

Create a new file called `attachments.js` with the following to retrieve the movies, their thumbnails and insert them in the Sync Gateway database.

```javascript
var request = require('request-promise')
  , Swagger = require('swagger-client');

var api = 'http://localhost:8000/movies'
  , db = 'movies_lister';

var movies = [];

var client = new Swagger({
  url: 'http://developer.couchbase.com/mobile/swagger/sync-gateway-admin/spec.json',
  usePromise: true
}).then(function (client) {
  // Get movies from stub API
  request({uri: api, json: true})
    .then(function (res) {
      movies = res;
      // return array of links
      return movies.map(function (movie) {
        return movie.posters.thumbnail;
      });
    })
    .map(function (link) {
      // Fetch each thumbnail, the program continues once
      // all 24 thumbnails are downloaded
      return request({uri: link, encoding: null});
    })
    .then(function (thumbnails) {
      // Save the attachment on each document
      for (var i = 0; i < movies.length; i++) {
        var base64 = thumbnails[i].toString('base64');
        movies[i]._attachments = {
          image: {
            content_type: 'image\/jpg',
            data: base64
          }
        };
      }
      return movies;
    })
    .then(function (movies) {
      // Save the documents and attachments in the same request
      return client.database.post_db_bulk_docs({db: db, body: {docs: movies}});
    })
    .then(function (res) {
      console.log(res);
    });
});
```

Restart Sync Gateway to have an empty database and run the program. The documents are saved with the attachment metadata.

![](img/admin-ui-attachment.png)

You can view the thumbnail at `http://localhost:4984/movies_lister/{db}/{doc}/{attachment}/` (note it's on the public port 4984).

![](img/sg-attachment.png)