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

#extend
extend = (target, object) ->
  t = target
  for k, v of object
    t[k] = v
  t

#path
parsePath = (src) ->
  #check src
  if !src
    return './'

  #format
  src = src.replace /\\/g, '/'
  #check project name
  if ~src.search '/aria/'
    src = src.replace /.*\/aria\//, './'
    return src

  #return
  src

#compile
compile = {}

#cson
compile.cson = (param) ->
  #param
  p = extend
    path: './src/**/*.cson'
    changed: true
  , param

  #log
  log p.path + ' changed'

  #require
  cson = require 'gulp-cson'

  #stream
  stream = gulp.src p.path

  #changed
  if p.changed then stream.pipe changed './', extension: '.json'

  stream
  #cson
  .pipe cson().on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#stylus
compile.stylus = (param) ->
  #param
  p = extend
    path: './src/**/*.styl'
    changed: true
  , param

  #log
  log p.path + ' changed'

  #require
  stylus = require 'gulp-stylus'
  nib = require 'nib'

  #stream
  stream = gulp.src p.path

  #changed
  if p.changed then stream.pipe changed './', extension: '.css'

  stream
  #stylus
  .pipe stylus(use: nib(), compress: true).on('error', gutil.log)
  #output
  .pipe gulp.dest './'

#coffee
compile.coffee = (param) ->
  #param
  p = extend
    path: './src/**/*.coffee'
    changed: true
  , param

  #log
  log p.path + ' changed'

  #require
  coffee = require 'gulp-coffee'
  uglify = require 'gulp-uglify'

  #stream
  stream = gulp.src p.path

  #changed
  if p.changed then stream.pipe changed './', extension: '.js'

  stream
  #coffee
  .pipe coffee(bare: true).on('error', gutil.log)
  #uglify
  .pipe uglify().on('error', gutil.log)
  #output
  .pipe gulp.dest './'

  #check path
  if !~p.path.search '/public/'
    #restart
    server.start()

#jade
compile.jade = (param) ->
  #param
  p = extend
    path: './src/**/*.jade'
    changed: true
  , param

  #log
  log p.path + ' changed'

  #stream
  stream = gulp.src p.path

  #changed
  if p.changed then stream.pipe changed './'

  #check path
  if !~p.path.search '/public/'
    stream
    #output
    .pipe gulp.dest './client/'
    #return
    return

  #require
  jade = require 'gulp-jade'

  stream
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
      gulp.watch 'src/**/*.' + arr[1], (e) -> compile[arr[0]] path: e.path

  #server

  #ready
  server.ready = true
  #start
  server.start()

#build
gulp.task 'build', ->
  #delete
  for a in ['public', 'client', 'router']
    exec = (require 'child_process').exec
    exec 'rm -rf ' + a

  #compile
  for a in ['coffee', 'jade', 'stylus', 'cson']
    do ->
      arr = if a != 'stylus' then [a, a] else [a, 'styl']

      compile[arr[0]] changed: false