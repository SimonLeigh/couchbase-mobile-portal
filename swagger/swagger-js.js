var Swagger = require('swagger-client');

var fs = require('fs');
var spec = JSON.parse(fs.readFileSync('./tmp/admin.json', 'utf8'));

var client = new Swagger({
  spec: spec,
  usePromise: true
})
  .then(function (client) {

    var db = 'todos';

    /**
     * Create a database named 'todos' and add a document (it recreates the database on every run):
     * 1. Check for the existing databases on the Sync Gateway instance
     * 2. If 'todos' exists then delete it, otherwise create it
     * 3. If the response status is 201 then continue, otherwise it was deleted so create it again
     * 4. Save a document
     * 5. Log the result
     */
    client.server.allDbs({})
      .then(function (res) {
        var json = JSON.parse(res.data);
        if (json.indexOf(db) != -1) { // doesn't exist
          return client.database.delete({db: db});
        } else { // exists
          return client.database.put({db: db});
        }
      })
      .then(function (res) {
        if (res.status == 201) {
          return true;
        }
        return client.database.put({db: db});
      })
      .then(function (res) {
        return client.document.put({db: db, doc: '123', body: {type: 'task', task: 'groceries'}})
      })
      .then(function (res) {
        console.log(res.data);
      })
      .catch(function (err) {
        throw err;
      });
  });