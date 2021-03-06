#============
#require
#============
app = (require 'express')()
session = require 'express-session'
cookie = require 'cookie-parser'
jade = require 'jade'
token = require '../token/token'

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
#setting
#============
app.settings['x-powered-by'] = false
app.listen port
app.use cookie()

#============
#function
#============
isLogin = (req) -> if token.validate req.cookies.token, req.cookies.key then true else false

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
  callback? silent: true

#login
render.login = (req, res, callback) ->
  #check login
  if isLogin(req)
    res.json
      success: false
      error: 'user was logined'
    return

  #key and token
  k = $.mid()[0..7].toUpperCase()
  t = token.generate k
  #cookie
  time = 864e5 * 14 #sec
  res.cookie 'key', k, maxAge: time
  res.cookie 'token', t, maxAge: time
  #render
  res.json
    success: true
    key: k
    token: t
  #info
  $.info 'info', 'add user ' + k + '/' + t
  #callback
  callback? silent: true

#============
#rule
#============
#rule
rule =
  #login
  '/login/': render.login
  #client
  '/client/*': render.client
  #index
  '/': render.index
  '/index/': null
  #blog
  '/blog/': null

#execute rule
for k, v of rule
  do (p = k, c = v) ->
    #callback
    cb = c or render.common
    #route
    app.get p, (req, res) ->
      #start time
      st = $.now()
      #header
      res.header 'X-Powered-By', 'Mimiko'

      #callback
      cb? req, res, (param)->
        #check param
        if param
          #failed
          if param.failed
            $.info 'error', req.url + ' is failed, in ' + $.parsePts($.now() - st) + 'ms, due to ' + res.failed
            return

          #silent
          if param.silent
            return

        #info
        $.info 'info', req.url + ' is rendered, in ' + $.parsePts($.now() - st) + 'ms'

#============
#log
#============
#port
$.info 'info', 'listening port ' + port
$.info 'success', 'router is ready, in ' + $.parsePts($.now() - st) + 'ms, as ' + app.settings.env