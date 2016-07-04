var gulp = require('gulp');
var swagger = require('gulp-swagger');

gulp.task('public', function () {
  gulp.src('./public.yaml')
    .pipe(swagger('full-public.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('admin', function () {
  gulp.src('./admin.yaml')
    .pipe(swagger('full-admin.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('lite', function () {
  gulp.src('./lite.yaml')
    .pipe(swagger('full-lite.json'))
    // run the swagger js code
    .pipe(gulp.dest('./tmp'))
});

gulp.task('custom', function () {
  console.log('Gulp is running!!');
});

gulp.task('default', ['public', 'admin', 'lite', 'watch']);

gulp.task('watch', function () {
  gulp.watch('**/*.yaml', ['public', 'admin', 'lite']);
});