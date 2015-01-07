#============
#require
#============
gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
rename = require 'gulp-rename'

coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'

jade = require 'gulp-jade'

stylus = require 'gulp-stylus'
nib = require 'nib'

cson = require 'gulp-cson'

server = require 'gulp-express'

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

#start
server.start = ->
  #check ready
  if server.ready
    server.run file: 'index.js'

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
  #server
  server.start()
#coffee
gulp.task 'watch-coffee-server', ->
  list = 'src/server/**/*.coffee'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe coffee bare: true
  .pipe uglify()
  .pipe gulp.dest './server'
  #server
  server.start()
gulp.task 'watch-coffee-client', ->
  list = 'src/client/**/*.coffee'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe coffee bare: true
  .pipe uglify()
  .pipe gulp.dest './'

#jade
gulp.task 'watch-jade-server', ->
  list = 'src/server/**/*.jade'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe gulp.dest './'
gulp.task 'watch-jade-client', ->
  list = 'src/client/**/*.jade'
  gulp.src list
  .pipe watch list
  .pipe plumber()
  .pipe jade()
  .pipe gulp.dest './'

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

#server
gulp.task 'server', ->
  server.ready = true
  server.start()

#default
gulp.task 'default', [
  'watch-coffee-source'
  'watch-coffee-server'
  'watch-coffee-client'
  'watch-jade-server'
  'watch-jade-client'
  'watch-stylus'
  'watch-cson'
  'server'
]

#build
gulp.task 'build', ->
  #remove folder
  for a in ['server', 'client']
    exec = (require 'child_process').exec
    exec 'rm -rf ' + a