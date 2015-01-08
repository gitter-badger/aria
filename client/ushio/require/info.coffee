#info
$.info = (p...) ->
  #param
  [type, text] = if p[1]? then [p[0], p[1]] else ['default', p[0]]
  #toString
  text = $.parseString text

  #check ::
  arr = text.split '::'
  if arr.length > 1
    type = arr[0]
    text = arr[1...].join '::'

  #check debug
  if type == 'debug' and !system.debug
    return

  #set handle
  area = $$ '#area-info'

  #console
  if type == 'debug'
    #error code
    ec = text.match(/#\d+/g)
    arr = $.info.list or= [
      '#0 - 未知错误。'
      '#1 - 版本号不符。'
      '#2 - 过于老旧的浏览器。'
      '#3 - 元素不存在。'
      '#4 - 元素不符合规范。'
      '#5 - 参数为空。'
      '#6 - 参数类型错误。'
      '#7 - 参数不符合规范。'
      '#8 - 同服务器通信失败。'
    ]
    if ec
      text = text.replace /#\d+/g, arr[ec[0].replace(/#/g, '') | 0] or arr[0]
    #log
    $.log text.replace(/&#13;?/, '\n').replace(/<br\s?\/>/g, '\n').replace /<[\s\S]+?>/g, ''

  #check icon
  icon = $.parseTemp '<i class="icon icon-[icon]"></i>',
    icon: switch type
      when 'debug' then 'comment'
      when 'error' then 'exclamation-circle'
      when 'info' then 'info-circle'
      when 'success' then 'check-square-o'
      when 'warning' then 'exclamation-triangle'
      else 'chevron-right'
  #dom
  text = text
    .replace /&#13;?/, '\n'
    .replace /\<br\s*?\/?\>/g, '\n'
    .replace /\<[\s\S]*?\>/g, ''
  area.css display: 'block'
  .append '<div class="item ' + type + '">' + icon + ($.parseSafe text).replace(/\n/g, '<br />') + '</div>'

  #set handle
  objs = area.children 'div'
  info = objs.eq -1

  #keep length
  if objs.length > 10
    objs.eq(0).mouseenter()

  #animate
  w = info.width()
  info.css
    left: - w
    opacity: 0
  .transition
    left: 0
    opacity: 1
  , 200, ->
    info
    .delay 1e4
    .transition
      left: - w
      opacity: 0
    , 200, -> info.mouseenter()
  #mouseenter
  .one 'mouseenter', ->
    #remove
    ($ @).remove()
    #hide
    clearTimeout area.data().timer
    area.data().timer = setTimeout ->
      if !area.children('div').length
        area.css display: 'none'
    , 200
  #return
  objs.eq -1

#shortcut for info
$.i = (text) -> $.info 'debug', text

#info
$.fn.info = (param, callback) ->
  func =
    name: '$.fn.info()'
    id: 'win-hint'
    type: 'default'
    direction: 'auto'
    text: null
    cooldown: 5e3
    fadeout: 5e3
    callback: callback

  #check param
  func.text = switch $.type p = param
    when 'string'
      if (p.search '::') == -1
        $.trim p
      else
        a = p.split '::'
        func.type = a[0]
        a[1]
    when 'object'
      $.extend func, p
      func.name = '$.fn.info()'
      if func.text and (func.text.search '::') != -1
        a = func.text.split '::'
        func.type = a[0]
        a[1]
      else func.text
    when 'function'
      func.callback = p
      null
    else
      $.info "debug::[#{func.name}]#6"
      null
  @each ->
    #set this
    obj = $ @
    #check text
    func.text ?= do ->
      title = obj.attr 'title'
      if title
        obj.data {title}
        .removeAttr 'title'
        title ? null
      else obj.data().title or null
    if func.text
      func.text = func.text.substr 0, func.text.length - 1 if (func.text.substr func.text.length - 1) == '。'
      #set win
      if func.id == 'win-hint'
        clearTimeout system.timer.hintFadeOut
        win = $ '#win-hint'
        win.addClass 'win-hint' if !win.hasClass 'win-hint'
        win.removeClass 'error success info debug warning'
      else
        win = $ '#' + func.id
        if !win.length
          $ '#area-window'
          .append '<div id="' + func.id + '" class="win win-hint"><div class="mainer"></div><div class="tail"></div></div>'
          win = $ '#' + func.id
      #set handle
      mainer = win.children 'div.mainer'
      tail = win.children 'div.tail'
      #dom
      win.addClass func.type
      func.text = func.text
        .replace /&#13;?/, '\n'
        .replace /\<br\s*?\/?\>/g, '\n'
        .replace /\<[\s\S]*?\>/g, ''
      mainer.html ($.parseSafe $.trim func.text).replace /\n/g, '<br />'
      #set size
      s =
        w: win.width()
        h: win.height()
      #set obj vars
      o =
        l: obj.offset().left
        t: obj.offset().top
        w: obj.width()
        h: obj.height()
      #set window vars
      w = do (e = $ window) ->
        w: e.innerWidth(), h: e.innerHeight(), t: e.scrollTop()
      #get y and x
      getY = ->
        if o.t - s.h - 32 > w.t
          [o.t - s.h - 8, 'top', -4]
        else
          [o.t + o.h + 8, 'bottom', 4]
      getX = ->
        if o.l + s.w < w.w - 16
          [o.l + o.w + 16, 'right', 4]
        else
          [o.l - s.w - 16, 'left', -4]
      cs = 'left right top bottom'
      switch func.direction
        when 'x'
          r = getX()
          left = r[0]
          top = o.t
          fix = [r[2], 0]
          tail.removeClass cs
          .addClass r[1]
        when 'y'
          r = getY()
          left = o.l
          top = r[0]
          fix = [0, r[2]]
          tail.removeClass cs
          .addClass r[1]
        when 'left'
          left = o.l - s.w - 16
          top = o.t
          fix = [-4, 0]
          tail.removeClass cs
          .addClass func.direction
        when 'right'
          left = o.l + o.w + 16
          top = o.t
          fix = [4, 0]
          tail.removeClass cs
          .addClass func.direction
        when 'top'
          left = o.l
          top = o.t - s.h - 8
          fix = [0, -4]
          tail.removeClass cs
          .addClass func.direction
        when 'bottom'
          left = o.l
          top = o.t + o.h + 8
          fix = [0, 4]
          tail.removeClass cs
          .addClass func.direction
        else
          r = getY()
          left = o.l
          top = r[0]
          fix = [0, r[2]]
          tail.removeClass cs
          .addClass r[1]
      #animate
      win
      .stop false, true
      .css
        left: left
        top: top
        opacity: 0
        display: 'block'
      .transition
        left: left + fix[0]
        top: top + fix[1]
        opacity: 1
      , 200, ->
        #fadeout
        if func.fadeout > 0
          if func.id == 'win-hint'
            clearTimeout system.timer.hintFadeOut
            system.timer.hintFadeOut = setTimeout ->
              win.click()
            , func.fadeout
          else
            setTimeout ->
              win.click()
            , func.fadeout
        #callback
        func.callback?()
    else $.info "debug::[#{func.name}]#5"

#rise info
$.fn.riseInfo = (param) ->
  #check param
  text = param or '+1'
  @each ->
    #set handle
    singer = $ @

    #insert
    obj = $ '<span class="info-rise">' + text + '</span>'
    obj.appendTo $$ '#area-window'

    #animation
    top = singer.offset().top - obj.height()
    obj.css
      opacity: 0
      left: singer.offset().left
      top: top
    .transition
      opacity: 1
      top: top - 16
    , 250
    .transition
      opacity: 1
      top: top - 20
    , 500
    .transition
      top: top - 20
    , 500
    .transition
      opacity: 0
      top: top - 32
    , 250, -> obj.remove()