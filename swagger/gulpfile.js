var gulp = require('gulp');
var swagger = require('gulp-swagger');

gulp.task('admin', function () {
  gulp.src('./admin.yaml')
    .pipe(swagger('full-admin.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('default', ['admin']);