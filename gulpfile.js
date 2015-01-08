var clean, coffee, concat, cson, gulp, gutil, ignore, jade, log, plumber, replace, stylus, uglify, watch;

gulp = require('gulp');

gutil = require('gulp-util');

watch = require('gulp-watch');

plumber = require('gulp-plumber');

replace = require('gulp-replace');

clean = require('gulp-clean');

ignore = require('gulp-ignore');

concat = require('gulp-concat');

uglify = require('gulp-uglify');

jade = require('gulp-jade');

coffee = require('gulp-coffee');

stylus = require('gulp-stylus');

cson = require('gulp-cson');

process.on('uncaughtException', function(err) {
  return log(err.statck);
});

log = console.log;

gulp.task('uglify', function() {
  return gulp.src(['./**/*.js', '!./node_modules/**']).pipe(uglify()).pipe(gulp.dest('./'));
});

gulp.task('coffee', function() {
  return gulp.src(['./**/*.coffee', '!./node_modules/**']).pipe(coffee({
    bare: true
  })).pipe(gulp.dest('./'));
});

gulp.task('jade', function() {
  return gulp.src(['./**/*.jade', '!./node_modules/**']).pipe(jade()).pipe(gulp.dest('./'));
});

gulp.task('stylus', function() {
  return gulp.src(['./**/*.styl', '!./node_modules/**']).pipe(stylus()).pipe(gulp.dest('./'));
});

gulp.task('cson', function() {
  return gulp.src(['./**/*.cson', '!./node_modules/**']).pipe(cson()).pipe(gulp.dest('./'));
});

gulp.task('nagisa', function() {
  return watch('client/nagisa/require/**/*.styl', function() {
    return gulp.src('./client/nagisa/core.styl').pipe(stylus()).pipe(gulp.dest('./client/nagisa/'));
  });
});

gulp.task('build', ['cson', 'coffee', 'stylus', 'uglify', 'jade']);
