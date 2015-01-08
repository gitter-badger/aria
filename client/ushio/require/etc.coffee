#followUser
$.followUser = (param, callback ) ->
  func =
    name: '$.followUser()'
    callback: callback
  if param? and $.type(param) == 'object'
    $.extend func, param
    func.name = '$.followUser()'
    if user.online
      system.port.followUser?.abort()
      system.port.followUser = $.post '/api/friend.aspx?name=follow',
        username: func.username
        userId: func.uid
        groupId: 0
      .done (data) ->
        if data.success
          text = 'success::关注' + (if func.username then ('[' + func.username + ']') else '用户') + '成功。'
          $.info text
          func.singer?.info text
          func.callback?()
        else
          text = 'warning::' + data.result
          $.info text
          func.singer?.info text
      .fail ->
        text = 'error::关注' + (if func.username then ('[' + func.username + ']') else '用户') + '失败。请于稍后重试。'
        $.info text
        func.singer?.info text

#readyPager
$.fn.readyPager = (param, callback) ->
  func =
    name: '$.fn.readyPager()'
    callback: callback
  #check param
  if param
    switch $.type(param)
      when 'object'
        $.extend func, param
        func.name = '$.fn.readyPager()'
      when 'function'
        func.callback = param
  if @length
    @each ->
      area = $ @
      area.delegate 'span.pager:not(.active)', 'click', -> func.callback $(@).data().page
      if func.addon
        area
        .delegate 'input.ipt-pager', 'focus', -> $(@).select()
        .delegate 'input.ipt-pager', 'keyup', ->
          ipt = $ @
          len = $.trim(ipt.val()).length
          width = if len then (32 + (len - 1) * 8) else 32
          width = 240 if width > 240
          ipt.css {width}
        .delegate 'input.ipt-pager', 'keydown', (e) ->
          ipt = $ @
          btn = ipt.siblings('button.btn-pager').eq 0
          if e.which == 13 then btn.click()
          else if $.inArray(e.which, [8, 35, 36, 37, 39, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105]) == -1 then false
        .delegate 'button.btn-pager', 'click', ->
          btn = $ @
          ipt = btn.siblings('input.ipt-pager').eq 0
          n = parseInt(ipt.val()) ? 1
          m = ipt.data().max ? 65535
          n = 1 if n < 1
          n = m if n > m
          func.callback n
  else
    $.info "debug::[#{func.name}]#3"
    $()

#setParam
$.setParam = (param) ->
  #extend
  $.extend system.param, param
  p = $.param system.param
  h = ($.param system.hash).replace(/(?:&=)|(?:=&)/g, '').replace(/&/g, ';')
  location.href = system.url.replace(/\?.*/, '').replace(/#.*/, '') + (if p then '?' + p else '') + (if h then '#' + h else '')

#ready dropdown
$.fn.readyDropdown = (param) ->
  #param
  p = $.extend {}, param
  #start
  p.start?()
  #set handle
  obj = @
  menu = obj.find '.menu:first'
  #check elem
  if menu.length
    obj
    .off 'mouseenter.setup'
    .on 'mouseenter.setup', ->
      #callback
      p.callback?()
      m =
        w: menu.width()
        h: menu.height()
      o =
        w: obj.width()
        h: obj.height()
        t: obj.offset().top
        l: obj.offset().left
      w =
        w: $(window).innerWidth()
        h: $(window).innerHeight()
        t: $(window).scrollTop()
      t = if o.t + m.h + 32 > w.t + w.h then ['auto', o.h] else [o.h, 'auto']
      menu
      .css
        top: t[0]
        bottom: t[1]
        opacity: 0
        display: 'block'
      .transition
        opacity: 1
      , 200
    .off 'mouseleave.setup'
    .on 'mouseleave.setup', ->
      menu
      .stop()
      .transition
        opacity: 0
      , 200, -> menu.css display: 'none'
    obj.data().setup = 1
    #finish
    p.finish?()
  else
    obj.info
      id: $.mid()
      text: "debug::[#{p.name}]#4"

#edit
$.fn.edit = (param) ->
  #extend
  p = $.extend
    mimiko: 1
  , param
  #start
  p.start?()
  #prepare dom
  area = $$ '#area-window'
  #set handle
  win = $ '<div>'
  ipt = if p.multi then $ '<textarea>' else $ '<input>'
  elem = @
  #prepare
  win
  .attr
    id: 'win-edit'
    class: 'win hidden'
  .css
    left: p.left or elem.offset().left
    top: p.top or elem.offset().top
    padding: p.padding or ->
      arr = []
      for a in ['top', 'right', 'bottom', 'left']
        arr.push elem.css 'padding-' + a
      arr.join ' '
    'line-height': p['line-height'] or elem.css 'line-height'
  ipt
  .css
    width: p.width or elem.width()
    height: if p.multi then (p.height or elem.height()) else 22
  .data
    val: do ->
      text = p.text or if p.multi then elem.html() else elem.text()
      if p.multi then text = text.replace /\<br\s*?\/?\>/g, '\n'
      text = $.parseSafe $.trim text
  .val ipt.data().val
  .keydown (e) ->
    if e.which == 13
      if !p.multi or (p.multi and e.ctrlKey)
        ipt.blur()
  .blur ->
    #remove
    win
    .transition
      opacity: 0
    , 200, -> win.remove()
    #reset hide
    if p.hide
      elem
      .css visibility: 'visible'
      .transition
        opacity: 1
      , 200
    #callback
    if (val = $.parseSafe $.trim ipt.val()) != ipt.data().val
      p.callback? val
  #insert
  #hide
  if p.hide
    elem.transition
      opacity: 0
    , 200, -> elem.css visibility: 'hidden'
  ipt.prependTo win
  win
  .prependTo area
  .transition
    opacity: 0
  , 0, -> win.removeClass 'hidden'
  .transition
    opacity: 1
  , 200, -> ipt.select()
  #finish
  p.finish?()

#share
$.fn.share = (param, callback) ->
  #extend
  p = $.extend
    key:
      tsina: 529993022
      tqq: 801259307
      t163: ''
      tsohu: ''
    icon:
      size: 16
    callback: callback
  , param
  #set handle
  elem = $ @
  #ready dom
  elem
  .addClass 'bdsharebuttonbox'
  .html '
    <a title="分享到新浪微博" data-cmd="tsina" class="bds_tsina"></a>
    <a title="分享到腾讯微博" data-cmd="tqq" class="bds_tqq"></a>
    <a title="分享到QQ空间" data-cmd="qzone" class="bds_qzone"></a>
    <a title="分享到人人网" data-cmd="renren" class="bds_renren"></a>
    <a title="分享到百度贴吧" data-cmd="tieba" class="bds_tieba"></a>
    <a title="分享到微信朋友圈" data-cmd="weixin" class="bds_weixin"></a>
    <span class="clearfix"></span>'
  #config
  window._bd_share_config =
    common:
      bdSnsKey: p.key
      bdText: p.text
      bdUrl: p.url
      bdPic: p.preview
    share: [bdSize: p.icon.size]
  #insert dom
  $$('#stage').after '<script src="http://bdimg.share.baidu.com/static/api/js/share.js?cdnversion=' + ~(-new Date()/36e5) + '"></script>'
  #rewrite
  $.fn.share = -> $.i 'This function can not be executed again.'
  #callback
  p.callback?()