var gulp = require('gulp')
  , concat = require('gulp-concat')
  , runSequence = require('run-sequence')
  , swagger = require('gulp-swagger');

/**
 * Concat the parameters into parameters/index.yaml
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
 * Concat the definitions into definitions/index.yaml
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

/**
 * Concat the paths into paths/index.yaml
 */
gulp.task('paths-cbl', function () {
  return gulp.src(['paths/common.yaml', 'paths/cbl.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('paths'));
});

gulp.task('paths-sg-public', function () {
  return gulp.src(['paths/common.yaml', 'paths/sg/common.yaml', 'paths/sg/public.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('paths'));
});

gulp.task('paths-sg-admin', function () {
  return gulp.src(['paths/common.yaml', 'paths/sg/common.yaml', 'paths/sg/admin.yaml'])
    .pipe(concat('index.yaml'))
    .pipe(gulp.dest('paths'));
});

/**
 * Build Swagger specs
 */

gulp.task('public', ['params-sg', 'definitions-sg', 'paths-sg-public'], function () {
  return gulp.src('./public.yaml')
    .pipe(swagger('public.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('admin', ['params-sg', 'definitions-sg', 'paths-sg-admin'], function () {
  return gulp.src('./admin.yaml')
    .pipe(swagger('admin.json'))
    .pipe(gulp.dest('./tmp'))
});

gulp.task('cbl', ['params-cbl', 'definitions-cbl', 'paths-cbl'], function () {
  return gulp.src('./cbl.yaml')
    .pipe(swagger('cbl.json'))
    // run the swagger js code
    .pipe(gulp.dest('./tmp'))
});

gulp.task('build', function(done) {
  runSequence('public', 'admin', 'cbl', function() {
    console.log('Run something else');
    done();
  });
});

gulp.task('watch', ['build'], function () {
  gulp.watch('**/*.yaml', ['build']);
});