var gulp = require('gulp')
  , concat = require('gulp-concat')
  , runSequence = require('run-sequence')
  , swagger = require('gulp-swagger');

/**
 * Concat the parameters into parameters/index.yaml file
 */
gulp.task('params-cbl', function () {
  return gulp.src(['parameters/common.yaml', 'parameters/cbl.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('parameters'));
});

gulp.task('params-sg', function () {
  return gulp.src(['parameters/common.yaml', 'parameters/sg.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('parameters'));
});

/**
 * Concat the definitions into definitions/index.yaml file
 */
gulp.task('definitions-cbl', function () {
  return gulp.src(['definitions/common.yaml', 'definitions/cbl.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('definitions'));
});

gulp.task('definitions-sg', function () {
  return gulp.src(['definitions/common.yaml', 'definitions/sg.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('definitions'));
});


gulp.task('public', ['params-sg', 'definitions-sg'], function () {
  return gulp.src('./public.yaml')
    .pipe(swagger('public.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('admin', ['params-sg', 'definitions-sg'], function () {
  return gulp.src('./admin.yaml')
    .pipe(swagger('admin.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('lite', ['params-cbl', 'definitions-cbl'], function () {
  return gulp.src('./lite.yaml')
    .pipe(swagger('lite.json'))
    // run the swagger js code
    .pipe(gulp.dest('./tmp'))
});

gulp.task('build', function(done) {
  runSequence('public', 'admin', 'lite', function() {
    console.log('Run something else');
    done();
  });
});

gulp.task('watch', ['build'], function () {
  gulp.watch('**/*.yaml', ['build']);
});