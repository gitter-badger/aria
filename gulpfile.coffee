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

jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
cson = require 'gulp-cson'

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

#coffee
gulp.task 'coffee', ->
  gulp.src ['./**/*.coffee', '!./node_modules/**']
  .pipe coffee bare: true
  .pipe gulp.dest './'

#jade
gulp.task 'jade', ->
  gulp.src ['./**/*.jade', '!./node_modules/**']
  .pipe jade()
  .pipe gulp.dest './'

#stylus
gulp.task 'stylus', ->
  gulp.src ['./**/*.styl', '!./node_modules/**']
  .pipe stylus()
  .pipe gulp.dest './'

#cson
gulp.task 'cson', ->
  gulp.src ['./**/*.cson', '!./node_modules/**']
  .pipe cson()
  .pipe gulp.dest './'

#nagisa
gulp.task 'nagisa', ->
  watch 'client/nagisa/require/**/*.styl', ->
    gulp.src './client/nagisa/core.styl'
    .pipe stylus()
    .pipe gulp.dest './client/nagisa/'

#build
gulp.task 'build', [
  'cson'
  'coffee'
  'stylus'
  'uglify'
  'jade'
]