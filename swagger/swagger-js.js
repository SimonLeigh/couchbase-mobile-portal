var Swagger = require('swagger-client');

var fs = require('fs');
var spec = JSON.parse(fs.readFileSync('./tmp/full-admin.json', 'utf8'));

var client = new Swagger({
  url: 'http://petstore.swagger.io/v2/swagger.json',
  spec: spec,
  success: function() {
    // client.pet.getPetById({petId:9999},{responseContentType: 'application/json'},function(pet){
    //   console.log('pet', pet);
    // });
  }
});