var gulp = require('gulp');
var swagger = require('gulp-swagger');

gulp.task('public', function () {
  gulp.src('./public.yaml')
    .pipe(swagger('public.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('admin', function () {
  gulp.src('./admin.yaml')
    .pipe(swagger('admin.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('lite', function () {
  gulp.src('./lite.yaml')
    .pipe(swagger('lite.json'))
    // run the swagger js code
    .pipe(gulp.dest('./tmp'))
});

gulp.task('build', ['public', 'admin', 'lite']);
gulp.task('watch', ['public', 'admin', 'lite', 'watch']);