var Swagger = require('swagger-client');

var fs = require('fs');
var spec = JSON.parse(fs.readFileSync('./tmp/full-admin.json', 'utf8'));

var client = new Swagger({
  spec: spec,
  success: function() {
    client.server.get_all_dbs({}, function (res) {
      console.log(res.data);
    });
    client.server.get_logging({}, function (res) {
      console.log(res.data);
    });
    client.server.createDatabase({db: 'brighton', body: {}}, function (res) {
      console.log(res.data);
    });
    client.database.post_db_user({db: 'brighton', user: {name: 'james', password: 'letmein'}}, function (res) {
      console.log(res);
    });
  }
});

