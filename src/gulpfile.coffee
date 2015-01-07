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

#default
gulp.task 'default', ->
  #watch
  for a in ['coffee', 'jade', 'stylus', 'cson']
    do ->
      arr = if a != 'stylus' then [a, a] else [a, 'styl']
      #watch
      gulp.watch 'src/**/*.' + arr[1], (e) -> compile[arr[0]] e.path

  #server

  #ready
  server.ready = true
  #start
  server.start()