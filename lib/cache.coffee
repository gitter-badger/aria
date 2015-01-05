#$
$ = global.$

#cache
$.cache = cache = {}

#setting
cache.env = $.config.cache

#check cache.env
if cache.env == 'redis'
  #redis
  redis = require 'redis'

  #check env
  switch $.env
    when 'production'
      client = cache.client or= redis.createClient 6379, '192.168.241.43'
    else
      client = cache.client or= redis.createClient 6379, '10.232.0.180'
  client.on 'error', (err) ->
    $.info 'error', err

  #scan
  client._scan = (param, callback) ->
    #extend
    p = $.extend
      match: '*'
      count: 1e3
    , param

    #data
    arr = []

    #function
    fn = (index) ->
      client.scan index, 'MATCH', p.match, 'COUNT', p.count, (err, res) ->
        if err
          #callback
          callback? err, null
        else
          #add data
          for a in res[1]
            arr.push a
          #check index
          if res[0] | 0
            fn res[0]
          else
            #callback
            callback? null, arr

    #start
    fn 0

  #parse
  salt = 'mimiko::key:'
  parse = (key) -> salt + key.toLowerCase().replace /[:\/\.\?&%]/g, ''

  #set
  cache.set = (key, value, p...) ->
    #check param
    [time, callback] = switch $.type p[0]
      when 'number'
        [p[0], p[1]]
      when 'function'
        [900, p[0]]
      else
        [900, null]
    #parse
    key = parse key
    #set
    client.setex key, time, value, (err, res) ->
      if res == 'OK'
        #callback
        callback?()
      else
        throw err

  #get
  cache.get = (key, callback) ->
    #parse
    key = parse key
    #get
    client.get key, (err, res) ->
      if err
        throw err
      else
        #callback
        callback? res

  #delete
  cache.del = (key, callback) ->
    #parse
    key = parse key
    #delete
    client.del key, (err, res) ->
      if err
        throw err
      else
        #callback
        callback? res

  #clear
  cache.clear = (callback) ->
    #scan
    client._scan
      match: salt + '*'
    , (err, res) ->
      if err
        throw err
      else
        #length
        length = res.length | 0
        #function
        fn = (index) ->
          #delete
          client.del res[index], (e) ->
            if e
              throw e
            else
              #check index
              if index >= length - 1
                #callback
                callback?()
              else
                fn 1 + index
        #start
        fn 0

else if cache.env == 'memory'
  #memory
  client = cache.client or= require 'memory-cache'

  #set
  cache.set = (key, value, p...) ->
    #check param
    [time, callback] = switch $.type p[0]
      when 'number'
        [p[0], p[1]]
      when 'function'
        [900, p[0]]
      else
        [900, null]
    client.put key, value, time * 1e3
    #next
    $.next ->
      #callback
      callback?()

  #get
  cache.get = (key, callback) ->
    res = client.get key
    #next
    $.next ->
      #callback
      callback? res

  #delete
  cache.del = (key, callback) ->
    #check exist
    res = 0
    if (client.get key)?
      res = 1
      client.del key
    #next
    $.next ->
      #callback
      callback? res

  #clear
  cache.clear = (callback) ->
    client.clear()
    #next
    $.next ->
      #callback
      callback?()

else
  #cache is disabled
  $.cache = cache = null

#test
if cache
  key = 'cacheTest'
  token = 'cache test'
  cache.set key, token, 5, ->
    cache.get key, (res) ->
      if res == token
        $.info 'success', 'cache is ready, as ' + cache.env