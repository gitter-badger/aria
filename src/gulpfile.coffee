#============
#require
#============
gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
replace = require 'gulp-replace'

coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'

jade = require 'gulp-jade'

stylus = require 'gulp-stylus'
nib = require 'nib'

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
#source
gulp.task 'watch-coffee-source', ->
  list = 'src/*.coffee'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe coffee bare: true
  .pipe uglify()
  .pipe gulp.dest './'
#coffee
gulp.task 'watch-coffee-server', ->
  list = 'src/server/**/*.coffee'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe coffee bare: true
  .pipe uglify()
  .pipe gulp.dest './server'
gulp.task 'watch-coffee-client', ->
  list = 'src/client/**/*.coffee'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe coffee bare: true
  .pipe uglify()
  .pipe gulp.dest './client'

#jade
gulp.task 'watch-jade-server', ->
  list = 'src/server/**/*.jade'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe gulp.dest './server'
gulp.task 'watch-jade-client', ->
  list = 'src/client/**/*.jade'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe jade()
  .pipe gulp.dest './client'

#stylus
gulp.task 'watch-stylus', ->
  list = 'src/**/*.styl'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe stylus use: nib(), compress: true
  .pipe gulp.dest './'

#cson
gulp.task 'watch-cson', ->
  list = 'src/**/*.cson'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe cson()
  .pipe gulp.dest './'

#default
gulp.task 'default', [
  'watch-coffee-source'
  'watch-coffee-server'
  'watch-coffee-client'
  'watch-jade-server'
  'watch-jade-client'
  'watch-stylus'
  'watch-cson'
]