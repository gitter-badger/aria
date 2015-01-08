#============
#require
#============
gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
replace = require 'gulp-replace'
clean = require 'gulp-clean'
ignore = require 'gulp-ignore'
concat = require 'gulp-concat'

uglify = require 'gulp-uglify'

stylus = require 'gulp-stylus'

#============
#error
#============
#uncaughtException
process.on 'uncaughtException', (err) -> log err.statck

#============
#function
#============
#log
log = console.log

#============
#task
#============

#uglify
gulp.task 'uglify', ->
  gulp.src ['./**/*.js', '!./node_modules/**']
  .pipe uglify()
  .pipe gulp.dest './'

#nagisa
gulp.task 'nagisa', ->
  watch 'client/nagisa/require/**/*.styl', ->
    gulp.src './client/nagisa/core.styl'
    .pipe stylus()
    .pipe gulp.dest './client/nagisa/'