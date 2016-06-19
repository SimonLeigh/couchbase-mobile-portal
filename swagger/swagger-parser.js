var SwaggerParser = require('swagger-parser');
SwaggerParser.validate("public.yaml")
  .then(function(api) {
    console.log('Yay! The API is valid.');
  })
  .catch(function(err) {
    console.error('Onoes! The API is invalid. ' + err.message);
  });