#require
gulp = require 'gulp'

#gutil
gutil = require 'gulp-util'

#changed
changed = require 'gulp-changed'

#function

#log
log = console.log

#start
start = ->
  #check
  if !start.ready
    return

  #server
  server = require 'gulp-express'
  #run
  process.nextTick ->
    server.run file: 'index.js'

#task

#cson
gulp.task 'cson', ->
  #require
  cson = require 'gulp-cson'

  gulp.src './src/**/*.cson'
  #changed
  .pipe changed './', extension: '.json'
  #cson
  .pipe cson().on('error', gutil.log)
  #output
  .pipe gulp.dest './'
  #start
  start()

#stylus
gulp.task 'stylus', ->
  #require
  stylus = require 'gulp-stylus'
  nib = require 'nib'

  gulp.src './src/**/*.styl'
  #changed
  .pipe changed './', extension: '.css'
  #stylus
  .pipe stylus(use: nib(), compress: true).on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#coffee
gulp.task 'coffee', ->
  #require
  coffee = require 'gulp-coffee'
  uglify = require 'gulp-uglify'

  gulp.src './src/**/*.coffee'
  #changed
  .pipe changed './', extension: '.js'
  #coffee
  .pipe coffee(bare: true).on('error', gutil.log)
  #uglify
  .pipe uglify().on('error', gutil.log)
  #output
  .pipe gulp.dest './'
  #start
  start()

#jade
gulp.task 'jade', ->
  #require
  jade = require 'gulp-jade'

  gulp.src './src/**/*.jade'
  #changed
  .pipe changed './', extension: '.html'
  #jade
  .pipe (jade()).on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#server
gulp.task 'server', ->
  #ready
  start.ready = true
  #start
  start()

#watch
gulp.task 'watch', ->

  #cson
  gulp.watch 'src/**/*.cson', ['cson']

  #stylus
  gulp.watch 'src/**/*.styl', ['stylus']

  #coffee
  gulp.watch 'src/**/*.coffee', ['coffee']

  #jade
  gulp.watch 'src/**/*.jade', ['jade']

#default
gulp.task 'default', ['cson', 'stylus', 'coffee', 'jade', 'watch', 'server']