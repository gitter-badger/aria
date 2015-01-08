#============
#require
#============
app = (require 'express')()
jade = require 'jade'

#============
#param
#============
st = $.now()
debug = $.debug
date = $.st
jadeCache = false
port = process.env.PORT or 80

#============
#render
#============
render = {}

#common
render.common = (req, res, callback) ->
  #check url
  path = req.url
  #check if .html
  if path.search(/\.html/) != -1
    path = path.replace /\.html/g, '.jade'
  else
    path += '/index.jade'
  #finish path
  path = './src/' + path.replace /\/\//, '/'
  #render
  temp = jade.compileFile path, cache: jadeCache
  res.send temp
    date: date
  #callback
  callback?()

#index
render.index = (req, res, callback) ->
  #render
  temp = jade.compileFile './src/index/index.jade', cache: jadeCache
  res.send temp
    date: date
  #callback
  callback?()
#============

#============
#rule
#============
#rule
rule =
  #index
  '/': render.index

#execute rule
for k, v of rule
  do (p = k, c = v) ->
    #callback
    cb = c or render.common
    #route
    app.get p, (req, res) ->
      st = $.now()
      #header
      res.header 'X-Powered-By', 'Mimiko'
      #callback
      cb? req, res, ->
        #check res.failed
        if res.failed
          $.info 'error', req.url + ' is failed, in ' + $.parsePts($.now() - st) + 'ms, due to ' + res.failed
        else
          $.info 'info', req.url + ' is rendered, in ' + $.parsePts($.now() - st) + 'ms'

#============
#setting
#============
app.settings['x-powered-by'] = false
app.listen port

#============
#log
#============
#port
$.info 'info', 'listening port ' + port
$.info 'success', 'router is ready, in ' + $.parsePts($.now() - st) + 'ms, as ' + app.settings.env