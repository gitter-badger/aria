#======
#ready

#check browser
system.func.checkBrowser = (callback) ->
  #final
  fin = ->
    #html class
    arr = []
    for a in ['rgba', 'borderradius']
      arr.push if system.browser[a] then a else 'no-' + a
    $('html').addClass arr.join ' '
    #clear
    window.Modernizr = null
    system.func.checkBrowser = null
    #callback
    callback()
  #check date
  if cache.browser and system.st - cache.browser.date < 14 * 864e5
    system.browser = cache.browser
    fin()
  else
    $.getScript system.path.short + '/script/modernizr.min.js', ->
      cache.browser = window.Modernizr
      #check ua
      ua = navigator.userAgent.toLowerCase()
      [cache.browser.name, cache.browser.version] =
        if b = ua.match /msie ([\d.]+)/ then ['msie', b[1]]
        else if b = ua.match /trident.*rv\:([\d.]+)/ then ['msie', b[1]]
        else if b = ua.match /firefox\/([\d.]+)/ then ['firefox', b[1]]
        else if b = ua.match /chrome\/([\d.]+)/ then ['chrome', b[1]]
        else if b = ua.match /opera.([\d.]+)/ then ['opera', b[1]]
        else if b = ua.match /version\/([\d.]+).*safari/ then ['safari', b[1]]
        else ['unknown', 'unknown']
      #date
      cache.browser.date = system.st
      #save
      $.save 'cache'
      #to system
      system.browser = cache.browser
      #fin
      fin()

#ready
system.func.ready = (callback) ->
  #set handle
  config = window.config
  user = window.user
  cache = window.cache
  #parse version
  pv = (ver = '0.0.0') ->
    arr = ver.split '.'
    (arr[0] | 0) * 1e4 + (arr[1] | 0) * 1e2 + (arr[2] | 0)
  #get config/user/cache
  do ->
    #config
    a = $.parseJson store.get 'config'
    if a and pv(a.ver) >= pv config.ver
      $.extend config, a
    else $.save 'config'
  do ->
    #user
    a = $.parseJson store.get 'user'
    if a and pv(a.ver) >= pv user.ver
      $.extend user, a
    else $.save 'user'
    #avatar
    user.avatar = $.cookie('ac_userimg') or system.path.short + '/style/image/avatar.jpg'
  do ->
    #cache
    do f = ->
      a = $.parseJson store.get 'cache'
      if a and pv(a.ver) >= pv cache.ver
        $.extend cache, a
      else $.save 'cache'
    #auto refresh
    setInterval f, 6e4
  #param and hash
  do ->
    #param
    if system.url.search(/\?/) != -1
      a = system.url.replace(/.*\?/, '').split '&'
      for v in a
        b = [v.replace(///=[\s\S]+///, ''), v.replace ///[\s\S]+?=///, '']
        if b[0]?.length and b[1]?.length then system.param[b[0]] = decodeURIComponent b[1].replace /[\(\)<>\[\]\{\}'"]/g, ''
    #hash
    if location.hash
      a = location.hash.toString().replace(/\#/, '').split ';'
      for v in a
        b = [v.replace(///=[\s\S]+///, ''), v.replace ///[\s\S]+?=///, '']
        if b[0]?.length and b[1]?.length then system.hash[b[0]] = decodeURIComponent b[1].replace /[\(\)<>\[\]\{\}'"]/g, ''
  #ready dom
  #win-info
  do ->
    #set handle
    win = $$ '#win-info'
    t = win.data().timer
    if win.length
      win
      .on 'mouseenter', -> clearTimeout t
      .on 'mouseleave', ->
        clearTimeout t
        t = setTimeout ->
          win.css display: 'none'
        , 200
    else $.i '[#win-info]#3'
  #win-hint
  do ->
    area = $$ '#area-window'
    if area.length
      area
      .delegate 'div.win-hint', 'click', ->
        win = $ @
        win
        .stop false, true
        .transition
          opacity: 0
        , 200, ->
          win.css display: 'none'
          win.remove() if !win.is '#win-hint'
    else $.i '[#area-window]#3'

  #clear
  system.func.ready = null

  #callback
  callback?()
#======