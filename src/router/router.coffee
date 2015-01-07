#require
app = (require 'express')()
jade = require 'jade'

#config
jadeCache = false

#setting
app.settings['x-powered-by'] = false

#date
date = $.now()

#render

#============
#common
renderCommon = (req, res, callback) ->
  #check url
  path = req.url
  #check if .html
  if path.search(/\.html/) != -1
    path = path.replace /\.html/g, '.jade'
  else
    path += '/index.jade'
  #finish path
  path = './client/' + path.replace /\/\//, '/'
  #render
  temp = jade.compileFile path, cache: jadeCache
  res.send temp
    date: date
  #callback
  callback?()
#============

#router

#rules
rules =
  #index
  '/': null

#execute rules
for k, v of rules
  do (p = k, c = v) ->
    #callback
    cb = c or renderCommon
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

#port
#use process.env.PORT for c9.io
app.listen process.env.PORT or 80

#log
$.info 'success', 'router is ready'