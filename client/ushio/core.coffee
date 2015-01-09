#======
#param

#system
do ->
  #window
  w = window
  #path
  p = w.path
  #system
  s = w.system =
    ver: '0.3.19'
    st: $.now()
    date: w.date
    path:
      base: p.base
      cdn: p.cdn
      ssl: p.ssl
      api: p.api
    location: 'location-guru'
    url: location.href.toString()
    timer: {}
    gate:
      actionFollowAllowed: 1
    port: {}
    func: {}
    param: {}
    hash: {}
    handle: {}
    require: {}
    session: {}
    browser: {}
    debug: w.debug
  #short of path
  s.path.short = if s.debug then '/dotnet/date' else s.path.cdn + '/dotnet/20130418'
  #clear
  w.path = w.date = null

  #user
  w.user =
    ver: '0.1.0'
    name: $.cookie('ac_username') or '用户'
    avatar: $.cookie('ac_userimg') or s.path.short + '/style/image/avatar.jpg'
    online: 0
    ban: false
    uid: -1
    group: -1

  #config
  w.config =
    ver: '0.3.18'
    globe:
      themeEffectAllowed: 1
      guideFloatAllowed: 1
    channel:
      style: 'th-large'
    player:
      playerFloatAllowed: 1
    comment:
      videoViewAllowed: 0,
      autoShowCommentAllowed: 1
    album:
      hidePlaylistAllowed: 0

  #cache
  w.cache =
    ver: '0.2.10'
    history:
      views: []
      comms: []
      ups: []
    save: {}
#======

#======
#try
$.try = (p...) ->
  [msg, fn] = if p[1] then [p[0], p[1]] else ['', p[0]]
  try
    fn?()
  catch err
    if msg
      msg += '\n'
    $.i msg + err + '\n' + err.stack
#======

#======
#ajaxSetup
$.ajaxSetup cache: true

#selector
$$ = window.$$ = (selector) ->
  h = system.handle
  if s = selector
    h[s] or h[s] = $ s
  else h

#salt
$.salt = (day = 1) ->
  #cache
  c = $.salt.cache or= {}
  #day
  d = day or 1
  #system
  s = system
  #res
  c[d] or= '?salt=' + if !s.debug then ((s.st / (864e5 * d)) | 0) + s.ver.replace /\./g, '' else s.st

#bind require
bind = (c, a) ->
  for d in a
    #check function name
    v = d.split '.'
    if v.length == 1 then do ->
      #$.func
      f = v[0]
      $[f] = (p...) -> $.require c, -> $[f] p...
    else do ->
      #$.fn.func
      f = v[1]
      $.fn[f] = (p...) ->
        e = @
        $.require c, -> e[f] p...
        e
#======

#======
#info
bind 'info', ['info', 'fn.info', 'fn.riseInfo']
$.i = (p...) -> if system.debug then $.require 'info', -> $.i p... else $.log p...

#log
$.log = (param) -> console?.log? param

#hoverInfo
$.fn.hoverInfo = (param, callback) ->
  @each ->
    #set handle
    obj = $ @

    #class
    c = '.hoverInfo'

    #bind action
    obj
    .off c
    .on 'mouseenter' + c, -> obj.info param, callback
    .on 'mouseleave' + c, -> $('#win-hint').click()
#======

#======
#transition
if window.Worker then bind 'transit', ['fn.transition']
else $.fn.transition = (p...) -> $(@).animate p...
#======

#======
#srcoll

#scrollOnto
$.fn.scrollOnto = (time = 500, callback) ->
  @eq(0).each ->
    top = $(@).offset().top - 64
    $ 'body, html'
    .stop()
    .animate
      scrollTop: top
    , time, -> callback?()

#isViewing
$.isViewing = (elem) ->
  #function
  f = (e) ->
    if e?.length
      root = $ window
      ya = root.scrollTop()
      yb = ya + root.innerHeight()
      pa = e.offset().top
      pb = pa + e.height()
      if yb > pa > ya or yb > pb > ya or (pa < ya and pb > yb)
        true
      else
        false
    else false
  #check param
  switch $.type e = elem
    when 'string' then f $ e
    when 'object' then f e
    else false
#======

#======
#save
$.save = (param, callback) ->
  #delay
  $.delay 'save', 200, ->
    #func
    func = name: '$.save()'
    error = (e) -> $.i "#{func.name}##{e}"
    #check param
    if param
      switch param
        when 'cache' then store.set 'cache', cache
        when 'config' then store.set 'config', config
        when 'user' then store.set 'user', user
        else error 6
      #callback
      callback?()
    else error 5
#======

#======
#setup
$.fn.setup = (p...) ->
  #error
  error = (e) -> $.i '[$.fn.setup]#' + e
  #each
  @each ->

    #set handle
    elem = $ @

    #dropdown
    if elem.hasClass 'dropdown'
      $.require 'etc', ->
        elem.readyDropdown p...
      return

    #tabbable
    if elem.hasClass 'tabb'
      elem.readyTabbable p...
      return

    #form
    if elem.hasClass 'form'
      #check version
      if elem.hasClass 'form-new'
        $.require 'form-new', -> elem.readyForm p...
      else
        $.require 'form', -> elem.readyForm p...
      return

    #switch
    if elem.hasClass 'switch'
      elem.click ->
        if !elem.hasClass 'disabled'
          elem.toggleClass 'active'
        p[0]?()
      return

    #error
    error 4

#ready tabbable
$.fn.readyTabbable = (param) ->
  p = $.extend {}, param
  #start
  p.start?()
  #set handle
  obj = @
  banner = obj.children '.banner:not(.fake):first'
  tabs = banner.children '.tab'
  pages = obj.children '.page'
  banner
  .children '.tab'
  .not '.fixed, .more, .tool'
  .click ->
    tab = $ @
    page = obj.children ".page:eq(#{tab.index()})"
    tabs.filter '.active'
    .removeClass 'active'
    pages.filter '.active'
    .removeClass 'active'
    tab.addClass 'active'
    page.addClass 'active'
    p.callback?()
  obj.data().setuped = 1
  #finish
  p.finish?()
#======

#======
#window
bind 'win', ['fn.unfold', 'fn.shut', 'curtain', 'fn.ensure', 'ensure']

#card
$.fn.card = (param, callback) ->
  f =
    name: '$.fn.card()'
    win: $$ '#win-info'
    direction: 'auto'
    callback: callback
  f.mainer = f.win.children 'div.mainer'
  #check param
  switch $.type p = param
    when 'string' then f.direction = $.trim p
    when 'function' then f.callback = p
  #class
  c = '.card'
  #timer
  t = f.win.data().timer
  @each ->
    obj = $ @
    obj
    .off 'mouseenter' + c
    .on 'mouseenter' + c, ->
      clearTimeout t
      t = setTimeout ->
        $.require 'win', -> system.func.showCard obj, f
      , 200
    .off 'mouseleave' + c
    .on 'mouseleave' + c, ->
      clearTimeout t
      $$('#win-info').mouseleave()
#======

#======
#etc
bind 'etc', ['followUser', 'fn.readyPager', 'setParam', 'fn.edit', 'fn.share']

#mid
$.mid = -> Math.random().toString(36).substring 2

#rnd
$.rnd = (p...) ->
  r = Math.random()
  #check param
  switch p.length
    when 1
      #check type
      switch $.type p[0]
        #number
        when 'number'
          (r * p[0]) | 0
        #array
        when 'array'
          p[0][(r * p[0].length) | 0]
    when 2
      (p[0] + r * (p[1] - p[0])) | 0
    else (r * 2) | 0

#next
$.next = (fn) -> setTimeout fn, 0

#query
$.query = (p...) ->
  #function
  fn = ->
    #query
    p = (k + '=' + encodeURI(v) for k, v of system.param when v?).join('&').replace(/(?:&=)||(?:=&)/g, '')

    #hash
    h = (k + '=' + encodeURI(v) for k, v of system.hash when v?).join(';').replace(/(?:&=)||(?:=&)/g, '').replace(/&/g, ';')

    #url
    location.href = system.url.replace(/\?.*/, '').replace(/#.*/, '') + (if p then '?' + p else '') + (if h then '#' + h else '')
  #check param
  switch p.length
    when 1
    #check type
      switch $.type p[0]
        when 'string'
          system.param[p[0]]
        when 'object'
          $.extend system.param, p[0]
          fn()
    when 2
      system.param[p[0]] = p[1]
      fn()
    else
      system.param
#======

#======
#pager

#makePager
$.makePager = (param) ->
  f =
    num: 1
    count: 0
    size: 10
    long: 5
  if param then $.extend f, param
  p =
    total: f.totalPage or Math.ceil(f.count / f.size)
    num: f.num
  if p.total > 1
    p.fore = if p.num != 1 then '<span class="pager pager-fore" data-page="' + (p.num - 1) + '"><i class="icon icon-chevron-left" title="上一页"></i></span>' else ''
    p.hind = if p.num != p.total then '<span class="pager pager-hind" data-page="' + ((p.num | 0) + 1) + '"><i class="icon icon-chevron-right" title="下一页"></i></span>' else ''
    p.last = if p.num != p.total then '<span class="pager pager-first" data-page="' + p.total + '"><i class="icon icon-step-forward" title="最末"></i></span>' else ''
    p.first = if p.num != 1 then '<span class="pager pager-last" data-page="' + 1 + '"><i class="icon icon-step-backward" title="最初"></i></span>' else ''
    p.here = '<span class="pager pager-here active" data-page="' + p.num + '">' + p.num + '</span>'
    p.fores = ''
    p.fores = '<span class="pager pager-hinds" data-page="' + i + '">' + i + '</span>' + p.fores for i in [(p.num - 1)...(p.num - f.long)] by -1 when i >= 1
    p.hinds = ''
    p.hinds += '<span class="pager pager-fores" data-page="' + i + '">' + i + '</span>' for i in [(p.num + 1)...(p.num + f.long)] by 1 when i <= p.total
    p.html = '<div id="' + (f.id or '') + '" class="area-pager ' + (f['class'] or '') + '">' +
      (f.before or '') +
      p.first +
      p.fore +
      p.fores +
      p.here +
      p.hinds +
      p.hind +
      p.last +
      '<span class="hint">当前位置：' +
      (if !f.addon then p.num else '<input class="ipt-pager" type="number" value="' + p.num + '" data-max="' + p.total + '">') +
      '/' +
      p.total +
      '页' +
      (if f.addon then '<button class="btn mini btn-pager">跳页</button>' else '') +
      '</span>' +
      (f.after or '') +
      '<span class="clearfix"></span>
      </div>'
  else ''
#======

#======
#hash
bind 'hash', ['fn.hashchange', 'route', 'setHash']

#hash
$.hash = (p...) ->
  #function
  fn = ->
    h = (k + '=' + encodeURIComponent(v) for k, v of system.hash when v?).join(';').replace(/(?:&=)||(?:=&)/g, '').replace(/&/g, ';')
    location.hash = '#' + (h or '')

  #check param
  switch p.length
    when 1
      #check type
      switch $.type p[0]
        when 'string'
          system.hash[p[0]]
        when 'object'
          $.extend system.hash, p[0]
          fn()
    when 2
      system.hash[p[0]] = p[1]
      fn()
    else
      system.hash
#======

#======
#flash
bind 'flash', ['fn.flash']
window.swfobject = embedSWF: (p...) -> $.require 'flash', -> swfobject.embedSWF p...
#======

#======
#qrcode
bind 'qrcode', ['fn.qrcode']
#======

#======
#jqueryui
bind 'jqueryui', ['fn.draggable', 'fn.droppable', 'fn.selectable', 'fn.sortable']
#======

#======
#parse

#parseChannel
$.parseChannel = (param) ->
  #make list
  list = $.parseChannel.list or []
  #check param
  switch $.type param
    when 'number'
      for a in list when a[0] == param
        c = a[1]
        break
      c or '未知频道'
    when 'string'
      for a in list when a[1] == param
        c = a[0]
        break
      c or 1
    else '未知频道'


#parseColor
$.parseColor = (string) ->
  #check param
  switch $.type p = string
    when 'string'
      l = p.length
      c = [
        p.charCodeAt 0
        p.charCodeAt (l * 0.5) | 0
        p.charCodeAt l - 1
      ]
      for i in [0..2]
        c[i] = c[i].toString()
        c[i] = (c[i].substr(c[i].length - 2) * 2.55) | 0
      if c[1] > 127 then c[1] = 255 - c[1]
      for i in [0..2]
        c[i] = c[i].toString 16
        if c[i].length < 2
          c[i] = '0' + c[i]
      '#' + c.join ''
    else '#333333'

#parseGet
$.parseGet = (param) ->
  func = name: '$.parseGet()'

  #check param
  if param
    #check type
    switch $.type(param)
      when 'string'
        #string
        func.text = param
      when 'object'
        #object
        $.extend func, param
        func.name = '$.parseGet()'
    func.text = if func.text.search(/(?:\[[^\]]*?\[)|(?:\][^\[]*?\])/) == -1 then func.text else func.text.replace(/\[.*?\]/g, '').replace(/\[|\]/g, '')
    func.text = func.text
    .replace(/&amp;/g, '&')
    .replace(/&nbsp;/g, ' ')
    .replace(/&#39;/g, '\'')
    .replace(/(&quot;|&#34;)/g, '"')
    .replace(/&gt;/g, '>')
    .replace(/&lt;/g, '<')
    .replace(/<br\s?\/?>/g, '')
    .replace(/\r/g, '\n')
    .replace(/\n{2,}/g, '\n')
    #remove \n+ at beginning
    func.text.replace /\n+/, ''  if func.text.search(/\n+/) != -1

    #ubb2html
    if window.ubb2html then func.text = window.ubb2html func.text else func.text = $.parseSafe func.text

    #
    func.text = func.text
      .replace /\[ac\=(\S+?)\](\S+?)\[\/ac\]/g, '<a class="ac title btn" data-aid="$1" href="/v/ac$1" target="_blank"><i class="icon icon-play-circle"></i>$2</a>'
      .replace /\[aa\=(\S+?)\](\S+?)\[\/aa\]/g, '<a class="aa btn" href="/a/aa$1" target="_blank" title="该链接通向AcFun合辑"><i class="icon icon-list"></i>$2</a>'
      .replace /\[sm\=(\S+?)\](\S+?)\[\/sm\]/g, '<a class="sm btn" href="http://www.nicovideo.jp/watch/sm$1" target="_blank" title="该链接通向ニコニコ动画"><i class="icon icon-film"></i>$2</a>'
      .replace /\[email\](\S+?)\[\/email\]/g, '<a class="email btn" href="mailto:$1" target="_blank" title="点击以发送邮件"><i class="icon icon-envelope"></i>$1</a>'
      .replace /\[wiki\=(\S+?)\](\S+?)\[\/wiki\]/g, '<a class="wiki btn" href="http://wiki.acfun.tv/index.php/$1" target="_blank" title="该链接通向AC百科"><i class="icon icon-tag"></i>$2</a>'
      .replace /\[emot\=(\S+?)\,(\S+?)\/\]/g, '<img class="emotion" src="' + system.path.short + '/umeditor/dialogs/emotion/images/$1/$2.gif">'

    #check showImage
    if !func.showImage
      func.text = func.text
      .replace(/\[img\](\S+?)\[\/img\]/g, '<a class="btn btn-img" href="$1" target="_blank" title="点击以浏览图像"><i class="icon icon-picture-o"></i>图像</a>')
      .replace(/\[img\=(\S+?)\](\S+?)\[\/img\]/g, '<a class="btn btn-img" href="$2" target="_blank" title="$1"><i class="icon icon-picture-o"></i>$1</a>')
    else
      func.text = func.text
      .replace(/\[img\](\S+?)\[\/img\]/g, '<a class="thumb" href="$1" target="_blank" title="点击以浏览图像"><img class="preview" src="$1"></a>')
      .replace(/\[img\=(\S+?)\](\S+?)\[\/img\]/g, '<a class="thumb" href="$2" target="_blank" title="$1"><img class="preview" src="$2"></a>')
    func.text = func.text
    .replace(/\[at\]([\s\S]+?)\[\/at\]/g, '<a class="name" target="_blank" href="/member/findUser.aspx?userName=$1">@$1</a>')
    .replace(/\[\/?back.*?\]/g, '')
    .replace(/\[username\]([\s\S]+?)\[\/username\]/g, '<a  class="name" target="_blank" href="/member/findUser.aspx?userName=$1">$1</a>')
    .replace(/\[.*?\]/g, '')
    .replace(/([\s\W\_])on\w+?\s*?\=/g, '$1data-event=')
    $.trim func.text

    func.text = func.text
    .replace(/&amp;/g, '&')
    .replace(/&#91;/g, '[')
    .replace(/&#93;/g, ']')
  else ''

#parseJson
$.parseJson = (data) ->
  f = (p) ->
    try
      $.parseJSON p
    catch e
      null
  switch $.type d = data
    when 'string' then f d
    when 'object' then d
    else null

#parsePost
$.parsePost = (param) ->
  func =
    name: '$.parsePost()'
    text: ''
  #check param
  if param
    switch $.type(param)
      when 'string', 'number'
        func.text = param
      else $.i "[#{func.name}]#7"
  if func.text?.length
    func.text = '[mimiko]' +
      func.text
        #[u]
        .replace /<span\sstyle="text\-decoration\:underline;">([\s\S]+?)<\/span>/g, '[u]$1[/u]'
        #[s]
        .replace /<span\sstyle="text\-decoration:line\-through;">([\s\S]+?)<\/span>/g, '[s]$1[/s]'
        #[emot]
        .replace /<img[^>]*?src="[^>]*?\/um?editor\/dialogs\/emotion\/images\/(\w+?)\/(\d+?)\.gif".*?>/g, '[emot=$1,$2/]'
    #mails
    mails = func.text.match(/\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/g)
    func.text = func.text.replace(/\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/g, '[mimiko-mail-mark]') if mails?.length

    #html2ubb
    if window.html2ubb then func.text = window.html2ubb func.text

    #
    func.text = func.text
      .replace(/<br\s?\/?>/g, '')
      .replace(/(http:\/\/.*?\.(?:jpg|jpeg|png|gif))(?!\[)/g, '[img]$1[/img]')
      .replace(/\[url\](.*?\.(?:jpg|jpeg|png|gif))\[\/url\]/g, '[img]$1[/img]')
      .replace(/\[url\]\[img\](.*?)\[\/img\]\[\/url\]/g, '[img]$1[/img]')
      .replace(/@([^\s<>\[\]\(\)\{\}]{2,20})/g, '[at]$1[/at]')
      #ac
      .replace(/\[ac(\d+?)\]/g, '[ac=$1]ac$1[/ac]')
      .replace(/([^\w=\[\]\/])ac(\d+)/g, '$1[ac=$2]ac$2[/ac]')
      #aa
      .replace(/\[aa(\d+?)\]/g, '[aa=$1]ac$1[/aa]')
      .replace(/([^\w=\[\]\/])aa(\d+)/g, '$1[aa=$2]aa$2[/aa]')
      #sm
      .replace(/\[sm(\d+?)\]/g, '[sm=$1]sm$1[/sm]')
      .replace(/([^\w=\[\]\/])sm(\d+)/g, '$1[sm=$2]sm$2[/sm]')
      #wiki
      .replace(/\[wiki([\s\S]+?)\]/g, '[wiki=$1]$1[/wiki]')
      .replace(/\[mimiko\]/g, '')

    #rewrite mails
    if mails?.length
      for a in mails
        func.text = func.text.replace(/\[mimiko\-mail\-mark\]/, '[email]' + a + '[/email]')

    #fontsize
    fs = func.text.match(/\[size.*?\]/g)
    if fs?.length
      func.text = func.text.replace(/\[size.*?\]/g, '[mimiko-fontsize-mark]')
      list = [10, 12, 16, 18, 24, 32, 48]
      for a in fs
        b = a.match(/\d+/)[0] | 0
        a = '[size=14px]' if $.inArray(b, list) < 0
        func.text = func.text.replace(/\[mimiko\-fontsize\-mark\]/, a)

  #img to emot
  func.text = func.text.replace(/\[img\].+\/um?editor\/dialogs\/emotion\/images\/(\w+?)\/(\d+?)\.gif\[\/img\]/g, '[emot=$1,$2/]')

  #check pairs
  list = ['b', 'i', 'u', 's', 'color']
  for a in list
    r = new RegExp('\\[' + a, 'ig')
    arr = func.text.match(r)
    if arr?.length
      r = new RegExp('\\[\\/' + a, 'ig')
      b = func.text.match(r)
      func.text = func.text.replace(/\[.*?\]/g, '')  if !b or arr.length != b.length

  #final check
  if func.text.search(/\[[^\]]+\[/) >= 0 or func.text.search(/\][^\[]+\]/) >= 0
    $.info "error::[#{func.name}]#7"
    func.text = func.text.replace(/\[.*?\]/g, '')

  #return
  $.trim func.text


#parsePts
$.parsePts = (number) ->
  if (n = (number or 0) | 0) >= 1e5 then (((n * 0.001) | 0) / 10) + '万'
  else n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

#parseSafe
$.parseSafe = (text) ->
  #check text
  if t = text
    #replace
    t = $.parseString t
    .replace /&lt;/g, '<'
    .replace /&gt;/g, '>'
    .replace /&amp;/g, '&'
    .replace /&quot;/g, '"'
    .replace /&nbsp;/g, ''
    #return
    if window.Worker
      new Option(t).innerHTML
    else
      if !$$()['#item-safe-parse'] then $$('#stage').append '<div id="item-safe-parse" class="hidden"></div>'
      $$('#item-safe-parse').text(t).html()
  else ''

#parseString
$.parseString = (data) ->
  switch $.type d = data
    when 'string' then d
    when 'number' then d.toString()
    when 'array'
      (JSON.stringify _obj: d)
      .replace /\{(.*)\}/, '$1'
      .replace /"_obj":/, ''
    when 'object'then JSON.stringify d
    when 'boolean' then d.toString()
    when 'undefined' then 'undefined'
    when 'null' then 'null'
    else
      try
        d.toString()
      catch e
        ''

#parseTime
$.parseTime = (param) ->
  #trans
  trans = (t) ->
    dt = new Date t
    ts = dt.getTime()
    dtNow = new Date()
    tsNow = dtNow.getTime()
    tsDistance = tsNow - ts
    hrMin = dt.getHours() + '时' + ((if dt.getMinutes() < 10 then '0' else '')) + dt.getMinutes() + '分'
    longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin
    longLongAgo = dt.getFullYear() + '年' + longAgo
    if tsDistance < 0 then '刚刚' else
      if (tsDistance / 1000 / 60 / 60 / 24 / 365) | 0 > 0 then longLongAgo else
        if (dayAgo = tsDistance / 1000 / 60 / 60 / 24) > 3 then (if dt.getFullYear() != dtNow.getFullYear() then longLongAgo else longAgo) else
          if (dayAgo = (dtNow.getDay() - dt.getDay() + 7) % 7) > 2 then longAgo else
            if dayAgo > 1 then '前天 ' + hrMin else
              if (hrAgo = tsDistance / 1000 / 60 / 60) > 12 then (if dt.getDay() != dtNow.getDay() then '昨天 ' else '今天 ') + hrMin else
                if (hrAgo = (tsDistance / 1000 / 60 / 60 % 60) | 0) > 0 then hrAgo + '小时前' else
                  if (minAgo = (tsDistance / 1000 / 60 % 60) | 0) > 0 then minAgo + '分钟前' else
                    if (secAgo = (tsDistance / 1000 % 60) | 0) > 0 then secAgo + '秒前' else '刚刚'
  #trans
  trans $.timeStamp param

#parseTemp
$.parseTemp = (string, object) ->
  s = string
  for k, v of object
    s = s.replace (new RegExp '\\[' + k + '\\]', 'g'), v
  #return
  s
#======

#======
#time
$.timeStamp = (param) ->
  #check param
  switch $.type p = param
    when 'number' then p
    when 'string'
      text = $.trim p
      #check string
      if text.search(/[\s\.\-\/]/) != -1
        #check :
        if text.search(/\:/) != -1
          #has got :, 2013.8.6 12:00
          a = text.split(' ')
          #check :
          if a[0].search(/\:/) == -1
            #2013.8.6 12:00
            b = a[0].replace(/[\-\/]/g, '.').split('.')
            c = a[1].split(':')
          else
            #12:00 2013.8.6
            b = a[1].replace(/[\-\/]/g, '.').split('.')
            c = a[0].split(':')
        else
          #has got no :, 2013.8.6
          b = text.replace(/[\-\/]/g, '.').split('.')
          c = [0, 0, 0]
        #trans arr into nums
        for i in [0..2]
          b[i] = b[i] | 0
          c[i] = (c[i] or 0) | 0
        d = new Date()
        d.setFullYear b[0], (b[1] - 1), b[2]
        d.setHours c[0], c[1], c[2]
        ((d.getTime() / 1e3) | 0) * 1e3
      else $.now()
    else $.now()
#======

#======
#load

#loadin
$.fn.loadin = -> @each -> $(@).attr src: $(@).data().src

#preload
$.preload = (param, callback) ->
  #function
  next = ->
    #insert dom
    loader = $ '<img class="preloader hidden">'
    loader.appendTo $$ '#stage'
    #loop
    l = (src) ->
      #toString
      src = $.parseString src
      check = ->
        if i < arr.length
          l arr[i]
        else
          #end
          loader.remove()
          callback?()
      #check src
      if src.toLowerCase().search(/png|jpg|gif|jepg/) != -1
        loader
        .off()
        .one 'load', ->
          i++
          setTimeout check, 20
        .one 'error', -> loader.load()
        .attr {src}
      else
        i++
        check()
    #start
    l arr[i = 0]
  #check param
  switch $.type p = param
    when 'string'
      arr = [p]
      next()
    when 'array'
      arr = p
      next()
    else callback?()
#======

#======
#delay
$.delay = (id, delay, callback) ->
  #inner func
  func =
    name: '$.delay()'
    id: id
    delay: delay
    callback: callback
  #error
  error = (e) -> $.i "[#{func.name}]##{e}"
  #check param
  if func.id and func.delay >= 0 and func.callback
    #prepare
    c = $.delay.cache or= {}
    c[func.id] or=
      time: 0
      timer: null
    #check interval
    now = $.now()
    f = ->
      c[func.id].time = $.now()
      func.callback?()
    if now - c[func.id].time > func.delay
      f()
    else
      clearTimeout c[func.id].timer
      c[func.id].timer = setTimeout f, func.delay
  else error 7
#======

#======
#require
$.require = (p, c) ->

  #salt
  salt = $.salt()

  #fix
  fix = [
    (if system.debug then '.js' else '.min.js') + salt
    '.css' + salt
  ]

  #cache
  r = $.require.cache or= {}

  #bind
  bind = (t, s) ->
    #check
    if r[t]
      if r[t] == 1
        c?()
      else
        r[t].add c
    else
      (r[t] = $.Callbacks 'once').add c
      url = system.path.short + if s then '/ushio/lib/' + s + '.js' else '/ushio/require/' + t + fix[0]
      $.getScript url, ->
        #callbacks
        r[t].fire()
        #finish
        r[t] = 1

  #switch
  switch p
    when 'qrcode' then bind 'qrcode', 'jquery.qrcode.min' #qrcode
    when 'jqueryui' then bind 'jqueryui', 'jquery.ui.min' #jquery ui
    when 'transit' then bind 'transit', 'jquery.transit.min' #transit
    #canvas
    when 'canvas'
      #check
      if r.canvas
        c?()
      else
        #function
        f = ->
          r.canvas = 1
          c?()
        #check canvas
        if $('<canvas>')[0].getContext? then f() else $.getScript system.path.short + '/script/excanvas.min.js', f
    #editor
    when 'editor'
      #check
      if r.editor then c?()
      else
        #css
        id = 'style-require-editor'
        if !$('#' + id).length
          $$('head').append('<link id="' + id + '" href="' + system.path.short + '/umeditor/themes/ac/css/umeditor.css" rel="stylesheet">')
        #js
        $.getScript system.path.short + '/umeditor/umeditor.config.min.js', -> $.getScript system.path.short + '/umeditor/umeditor.min.js', ->
          r.editor = 1
          c?()
    #ready
    when 'ready'
      #check
      if r.ready then c?()
      else
        #ready
        system.func.ready ->
          r.ready = 1
          c?()
    #else
    else
      bind p
#======