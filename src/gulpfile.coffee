#require
gulp = require 'gulp'

#gutil
gutil = require 'gulp-util'

#changed
changed = require 'gulp-changed'

#server
server = require 'gulp-express'
server.start = ->
  #check ready
  if server.ready
    server.run file: 'index.js'

#log
log = console.log

#compile
compile = {}

#cson
compile.cson = (path) ->
  #log
  log path + ' was changed'

  #require
  cson = require 'gulp-cson'

  gulp.src path
  #changed
  .pipe changed './', extension: '.json'
  #cson
  .pipe cson().on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#stylus
compile.stylus = (path) ->
  #log
  log path + ' was changed'

  #require
  stylus = require 'gulp-stylus'
  nib = require 'nib'

  gulp.src path
  #changed
  .pipe changed './', extension: '.css'
  #stylus
  .pipe stylus(use: nib(), compress: true).on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#coffee
compile.coffee = (path) ->
  #log
  log path + ' was changed'

  #require
  coffee = require 'gulp-coffee'
  uglify = require 'gulp-uglify'

  gulp.src path
  #changed
  .pipe changed './', extension: '.js'
  #coffee
  .pipe coffee(bare: true).on('error', gutil.log)
  #uglify
  .pipe uglify().on('error', gutil.log)
  #output
  .pipe gulp.dest './'

  #check path

  #gulpfile
  if ~path.search 'gulpfile.coffee'
    #exit
    process.exit()

  #not public
  if !~path.search '/public/'
    #start
    server.start()

#jade
compile.jade = (path) ->
  #log
  log path + ' was changed'

  #check path
  if !~path.search '/public/'
    gulp.src path
    #changed
    .pipe changed './'
    #output
    .pipe gulp.dest './client/'
    #return
    return

  #require
  jade = require 'gulp-jade'

  gulp.src path
  #changed
  .pipe changed './', extension: '.html'
  #jade
  .pipe (jade()).on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#server
gulp.task 'server', ->
  #ready
  server.ready = true
  #start
  server.start()

#watch
gulp.task 'watch', ->

  #cson
  #gulp.watch 'src/**/*.cson', (e) -> compile.cson e.path

  #stylus
  gulp.watch 'src/**/*.styl', (e) -> compile.stylus e.path

  #coffee
  gulp.watch 'src/**/*.coffee', (e) -> compile.coffee e.path

  #jade
  gulp.watch 'src/**/*.jade', (e) -> compile.jade e.path

#default
gulp.task 'default', ['watch', 'server']