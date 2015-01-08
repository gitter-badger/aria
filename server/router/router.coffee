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
base = process.cwd()

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
  path = './server/' + path.replace /\/\//, '/'
  #render
  temp = jade.compileFile path, cache: jadeCache
  res.send temp
    date: date
  #callback
  callback?()

#index
render.index = (req, res, callback) ->
  #render
  temp = jade.compileFile './server/index/index.jade', cache: jadeCache
  res.send temp
    date: date
  #callback
  callback?()

#client
render.client = (req, res, callback) ->
  #render
  res.sendFile base + req.path
  #callback
  callback?()

#proxy
render.proxy = (req, res, callback) ->
  #path
  path = req.path.replace /\/proxy\//, ''

  #check path
  if !path
    #render
    res.send 'Error'
    #callback
    callback?()
    return

  #check http
  if !~path.search 'http://'
    path = 'http://' + path

  $.log path

  #get
  $.get path
  .fail ->
    #render
    res.send 'Error'
    #callback
    callback?()
  .done (data) ->
    #render
    res.send data
    #callback
    callback?()
#============

#============
#rule
#============
#rule
rule =
  #client
  '/client/*': render.client
  #index
  '/': render.index
  #proxy
  '/proxy/*': render.proxy

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