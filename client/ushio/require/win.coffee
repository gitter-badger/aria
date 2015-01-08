#show card
system.func.showCard = (obj, func) ->
  clearTimeout system.timer.winHint
  system.timer.winHint = setTimeout ->
    win = func.win
    inner = func.mainer
    o = obj.offset()
    switch func.direction
      when 'left'
        left = o.left - win.width() - 24
        top = o.top
      when 'right'
        left = o.left + obj.width() + 8
        top = o.top
      when 'top'
        left = o.left
        top = o.top - win.height()
      when 'bottom'
        left = o.left
        top = o.top + obj.height()
      else
        if o.top + win.height() > $(window).scrollTop() + $(window).innerHeight() - 32
          left = o.left
          top = o.top - win.height()
        else
          left = o.left
          top = o.top + obj.height()
        left = $(window).innerWidth() - 16 - win.width() if left + win.width() > $(window).innerWidth() - 16
    #check type
    if obj.hasClass('name') or obj.hasClass 'avatar'
      name = obj.data().name or obj.text()
      uid = obj.data().uid
      if user.online and name != user.name and uid != user.uid
        name = name[1...] if name[0...1] == '@'
        inner.html '<div class="hint-info">少女祈祷中...</div>'
        win.css
          left: left - 16
          top: top
          opacity: 0
          display: 'block'
        .stop true, false
        .transition
          opacity: 1
          left: left + 16
        , 200
        url = if uid then '/usercard.aspx?uid=' + uid else
          if name then '/usercard.aspx?username=' + encodeURI(name) else ''
        system.port.getUserInfo?.abort()
        system.port.getUserInfo = $.get url
        .done (data) ->
          if data.success
            a = data.userjson
            temp = '<div class="l">
              <a target="_blank" href="/member/user.aspx?uid=[uid]" class="thumb">
              <img class="avatar" [avatar]>
              </a>
              </div>
              <div class="r">
              <a title="注册于 [regTime] (Uid:[uid])&#13;最后登录于 [lastTime]" target="_blank" href="/member/user.aspx?uid=[uid]" class="name">[name]<span class="gender">([gender])</span></a>
              <p class="location">[from]</p>
              <p class="sign">[sign]</p>
              </div>
              <span class="clearfix"></span>
              <div class="area-info">
              <a target="_blank" href="/u/[uid].aspx#area=following">关注</a>：<span class="pts">[followings]</span>[spx]
              <a target="_blank" href="/u/[uid].aspx#area=followers">听众</a>：<span class="pts">[followeds]</span>[spx]
              <a target="_blank" href="/u/[uid].aspx#area=post-history">投稿</a><span class="pts">：[posts]</span>
              </div>
              <div class="area-tool">
              <a id="mail-user-info" href="[mailto]" target="_blank" title="私信"><i class="icon icon-envelope"></i></a>
              <a id="follow-user-info" title="关注"><i class="icon icon-plus-circle"></i></a>
              <span class="clearfix"></span>
              </div>'
            html = $.parseTemp temp,
              uid: a.uid or 4
              avatar: 'src="' + $.parseSafe(a.avatar) + '"'
              regTime: if a.regTime then $.parseTime(a.regTime) else '未知时间'
              lastTime: if a.lastLoginDate then $.parseTime(a.lastLoginDate) else '未知时间'
              name: $.parseSafe a.name
              gender: switch a.gender | 0
                when 0 then '♀'
                when 1 then '♂'
                else '?'
              from: '来自' + if a.comeFrom then $.parseSafe(a.comeFrom.replace /[\s\,]/g, '') else ' ' + a.lastLoginIp
              sign: if a.sign then $.parseSafe a.sign else '这个人很懒，神马都没有写…'
              followings: $.parsePts a.follows
              followeds: $.parsePts a.fans
              posts: $.parsePts a.posts
              mailto: '/member/#area=mail-new;username=' + $.parseSafe a.name
              spx: '&nbsp;&nbsp;/&nbsp;&nbsp;'
            #animation
            inner
            .removeClass 'card-video'
            .css opacity: 0
            .stop()
            .transition
              opacity: 0
            , 0, ->
              inner.html html
              $ '#mail-user-info'
              .click (e) ->
                btn = $ @
                if !user.online
                  e.preventDefault()
                  text = 'warning::您尚未登录。请先行登录。'
                  $.info text
                  btn.info text
                  btn.unfold('login') if !$('#win-login').length
              $ '#follow-user-info'
              .click ->
                btn = $ @
                if !btn.hasClass 'active'
                  if user.online
                    $.followUser
                      singer: btn
                      uid: a.uid
                      username: a.name
                      callback: ->
                        html = '<i class="icon icon-star"></i>已关注'
                        btn.html html
                  else
                    text = 'warning::您尚未登录。请先行登录。'
                    $.info text
                    btn.info text
                    btn.unfold 'login'
                else
                  text = 'warning::您已关注该用户。'
                  $.info text
                  btn.info text
              #callback
              func.callback?()
            .delay 50
            .transition
              opacity: 1
            , 200
          else
            $.info 'error::该用户不存在或尚不可用。'
            inner.html '<div class="hint-info">不存在的用户。</div>'
        .fail ->
          $.info 'error::获取用户信息失败。请稍后重试。'
          inner.html '<div class="hint-info">网络连接超时。</div>'
    else if obj.hasClass('title') or obj.hasClass('preview') or obj.hasClass('unit')
      aid = if obj.is('[data-aid]') then obj.data().aid else obj.closest('div.unit, span.unit, a.unit, li.unit').data().aid
      win.css
        left: left
        top: top
        opacity: 0
        display: 'block'
      .stop true, false
      .transition
        opacity: 1
      , 200
      system.port.getVideoInfo?.abort()
      system.port.getVideoInfo = $.get '/videoinfo.aspx?aid=' + aid
      .done (data) ->
        if data.success
          a = data.contentjson
          temp = '<div class="a">
            <div class="l">
            <a class="thumb" href="/v/ac[aid]" target="_blank">
            <img class="preview" [preview]>
            <i class="icon icon-play-circle-o small"></i>
            </a>
            </div>
            <div class="r">
            <a class="title" href="/v/ac[aid]" title="[title]" target="_blank">[title]</a>
            <p class="desc" title="[desc]">[desc]</p>
            </div><span class="clearfix"></span>
            </div>
            <div class="b">
            <a class="name" href="/member/user.aspx?uid=[uid]" target="_blank" title="[name]"><i class="icon icon-user"></i>[name]</a>
            <p class="time"><i class="icon icon-clock-o"></i><span class="pts">[pubTime]</span></p>
            <div class="c">
            <span class="views pts" title="点击数：[views]"><i class="icon icon-play-circle"></i>[views]</span>[spx]
            <span class="comments pts" title="评论数：[comms]"><i class="icon icon-comment"></i>[comms]</span>[spx]
            <span class="favors pts" title="收藏数：[favors]"><i class="icon icon-star"></i>[favors]</span>
            </div>
            <a class="channel" href="/v/list[cid]/index.htm" target="_blank">[channel]</a>
            </div>'
          html = $.parseTemp temp,
            uid: a.authorId or 4
            aid: aid or 41
            cid: $.parseChannel a.channel
            preview: 'src="' + $.parseSafe(a.preview) + '"'
            pubTime: if a.date then $.parseTime(a.date) else '未知时间'
            name: $.parseSafe a.author
            title: $.parseSafe a.title
            desc: if a.desc then $.parseSafe(a.desc) else '该视频暂无简介。'
            channel: $.parseSafe a.channel
            views: $.parsePts a.views
            comms: $.parsePts a.comments
            favors: $.parsePts a.stows
            mailto: '/member/#area=mail-new;username=' + encodeURI($.parseSafe a.name)
            spx: '&nbsp;&nbsp;'
          #insert
          inner.addClass 'card-video'
          .stop()
          .transition
            opacity: 0
          , 0, ->
            inner.html html
          .delay 50
          .transition
            opacity: 1
          , 200
        else
          $.info 'error::该视频不存在或尚不可用。'
          inner.html '<div class="hint-info">不存在的视频。</div>'
      .fail ->
        $.info 'error::获取视频信息失败。请稍后重试。'
        inner.html '<div class="hint-info">网络连接超时。</div>'
    else $.info "debug::[#{func.name}]无法识别的非法参数。"
  , 400

#call
$.fn.unfold = (param, callback) ->
  func =
    name: '$.fn.unfold()'
    token: 'mimiko'
    callback: callback
  if param
    switch $.type(param)
      when 'string'
        func.id = "@" + param
      when 'object'
        $.extend func, param
        func.name = '$.fn.unfold()'
      else $.info "debug::[#{func.name}]#6"
  if @length
    if @length == 1
      @each ->
        func.singer = $ @
        func.left ?= func.singer.offset().left
        func.top ?= func.singer.offset().top + 32
        if func.id[0...1] == '@'
          switch func.id
            #follow
            when '@follow'
              $.extend func,
                id: 'win-follow'
                title: '关注'
                width: 480
                height: 'auto'
                src: 'win-follow'
                curtain: on
              win = $ '#' + func.id
              if win.length
                win.shut -> $.unfold func
              else $.unfold func
            #image
            when '@img'
              #check src
              src = func.singer.data().src or func.singer.attr('src') or func.singer.attr('href')

              #check baidu
              if (src.search 'baidu\.com') != -1
                window.open 'https://ssl.acfun.tv/block-image-baidu.html?src=' + src
                return

              #extend
              $.extend func,
                id: 'win-image'
                icon: 'picture-o'
                title: '图像'
                width: 'auto'
                height: 'auto'
                src: 'win-image'
                curtain: on
                draggable: off
                start: ->
                  win = $ '#' + func.id
                  win.data().src = src

              win = $ '#' + func.id
              if win.length
                win.shut -> $.unfold func
              else $.unfold func
            #login
            when '@login'
              $.extend func,
                id: 'win-login'
                title: '登录/注册'
                width: 560
                height: 240
                src: 'win-login-index'
                curtain: on
                draggable: off
              win = $ '#' + func.id
              if win.length
                win.shut -> $.unfold func
              else $.unfold func
            #mail
            when '@mail'
              window.open '/member/#area=mail-new;username=' + (func.singer.data().name or '')
            #qrcode
            when '@qrcode'
              $.extend func,
                id: 'win-qrcode'
                icon: 'qrcode'
                title: '二维码'
                width: 256
                height: 256
                src: 'win-qrcode'
                curtain: on
                draggable: off
                start: ->
                  win = $ '#' + func.id
                  win.data().src = func.singer.data().src or func.singer.attr('href') or func.singer.attr('src')
              win = $ '#' + func.id
              if win.length
                win.shut -> $.unfold func
              else $.unfold func
            #reg
            when '@reg'
              $.extend func,
                id: 'win-reg'
                icon: 'user'
                title: '注册'
                width: 400
                height: 'auto'
                src: 'win-reg'
                curtain: on
              win = $ '#' + func.id
              if win.length
                win.shut -> $.unfold func
              else $.unfold func
        else $.unfold func

    else $.info "debug::[#{func.name}]#4"
  else $.info "debug::[#{func.name}]#3"
$.unfold = (param, callback) ->
  func =
    name: '$.unfold()'
    id: 'win-unexisted'
    class: ''
    curtain: on
    draggable: on
    icon: 'globe'
    title: '窗体'
    left: 64
    top: 64
    width: 320
    height: 160
    src: ''
    callback: callback

  area = $ '#area-window'
  if param
    switch $.type(param)
      when 'string'
        if param.search(/\@/) != -1
          func.id = '@' + $.trim(param).replace(/\@/g, '')
        else $.info "debug::[#{func.name}]#6"
      when 'object'
        $.extend func, param
        func.name = '$.unfold()'
      else $.info "debug::[#{func.name}]#6"
  else $.info "debug::[#{func.name}]#5"
  if func.id.length
    #check if is existed
    win = $ '#' + func.id
    if win.length
      win.shut -> $.unfold param, callback
    else
      temp = '<div id="[id]" class="win [type]">
            <div class="block-title">
            <p class="title"><i class="icon icon-[icon]"></i>[title]</p>
            <div class="area-tool">
            <div class="close" onclick="$(this).shut();" title="点击关闭窗体"><i class="icon icon-times"></i></div>
            </div>
            <span class="clearfix"></span>
            </div>
            <div class="mainer">
            <div class="hint-window">少女祈祷中...</div>
            </div>
            </div>'
      html = $.parseTemp temp,
        id: func.id
        type: func['class'] or func.type or ''
        icon: func.icon
        title: func.title
      area.append html
      win = $ '#' + func.id
      mainer = win.children("div.mainer").eq(0)
      hint = mainer.children("div.hint-window").eq(0)
      left = func.left
      top = func.top
      width = func.width
      height = func.height
      w =
        w: $(window).innerWidth()
        h: $(window).innerHeight()
        t: $(window).scrollTop()
      left = 32 if left < 32
      left = w.w - 32 - width if left + width > w.w - 32
      top = 32 if top < 32
      top = w.t + w.h - 32 - height if top + height > w.t + w.h - 32

      #shadow
      shadow = $ '#ACFlashPlayer-re'
      if shadow.length
        l = shadow.offset().left
        t = shadow.offset().top
        w = shadow.width()
        h = shadow.height()
        if !(left > l + w or top > t + h or left + width < l or top + height < t)
          win.data().scrollOnto = 1
          nl = l
          nt = top
          if left > l + w * 0.5 and l + w + 16 + width < $(window).innerWidth()
            nl = l + w + 16
          else if l - width - 16 > 0
            nl = l - width - 16
          else
            nt = t + h + 16
          left = nl
          top = nt

      mainer.css
        width: width
        height: height

      hint.css
        width: width
        height: height
        'line-height': height + 'px'

      if func.src.length
        src = if func.src.search(/http\:\/\//) == -1 then '/dotnet/date/html/' + func.src + '.html' else func.src
        src += $.salt()
        $.get src
        .done (data) ->
          if data?.length
            func.start?()
            mainer.html data
            setTimeout ->
              if !shadow.length and win.offset().top + win.height() > w.t + w.h - 48
                if !func.curtain
                  win.scrollOnto 200
                else
                  win.stop()
                  .transition
                    top: w.t + 48
                    opacity: 1
                  , 500
            , 500
            (func.callback ? func.finish)?()
          else
            $.info 'error::返回数据错误。请于稍后重试。'
            mainer.html '<p class="alert alert-danger">返回数据错误。请于稍后重试。</p>'
        .fail ->
          $.info 'error::同服务器通信失败。请于稍后重试。'
          mainer.html '<p class="alert alert-danger">同服务器通信失败。请于稍后重试。</p>'
      wfix = if system.browser.rgba then 2 else 0
      hfix = 36
      hfix = 0 if func.type == 'simple'
      win.css
        left: left
        top: top + 16
        width: mainer.width() + wfix + parseInt(mainer.css('padding-left')) + parseInt(mainer.css('padding-right'))
        opacity: 0
        display: 'block'
      .stop()
      .transition
        opacity: 0
      , 0, ->
        func.callback?() if !func.src.length
        if func.curtain
          $.curtain on, ->
            btnClose = win.find('div.close').eq(0)
            $('#curtain')
            .off 'click'
            .one 'click', -> btnClose.click()
            btnClose.click -> $.curtain off
      .transition
        top: top
        opacity: 1
      , 500, -> if win.data().scrollOnto then win.scrollOnto 200
      .click ->
        if !win.hasClass('active')
          $('#area-window>div.active').removeClass 'active'
          win.addClass 'active'
      .click()
      #draggable
      if func.draggable and !win.hasClass '.fixed'
        win
        .draggable
          handle: 'div.block-title'
          cancel: 'div.area-tool'
          containment: '#stage'
          snap: false
          opacity: 0.8
          start: ->
            $('#area-window').find('div.win-hint').click()
            $(@).stop().click()

          stop: ->
            left = $(@).offset().left
            top = $(@).offset().top
            width = $(@).width()
            height = $(@).height()
            if top < 48
              top = 48
              $(@)
              .stop()
              .transition
                top: top
              , 500
            else if shadow.length
              l = shadow.offset().left
              t = shadow.offset().top
              w = shadow.width()
              h = shadow.height()
              if !(left > l + w or top > t + h or left + width < l or top + height < t)
                nl = l
                nt = top
                if left > l + w * 0.5 and l + w + 16 + width < $(window).innerWidth()
                  nl = l + w + 16
                else if l - width - 16 > 0
                  nl = l - width - 16
                else
                  nt = t + h + 16
                $(@)
                .stop()
                .transition
                  left: nl
                  top: nt
                , 500

#curtain
$.curtain = (param, callback) ->
  #check param
  if param
    if !$('#curtain').length
      $$ '#stage'
      .append '<div id="curtain">&nbsp;</div>'
    $$()['#curtain'] = $ '#curtain'
    #check
    if window.Worker
      $$ '#curtain'
      .transition
        opacity: 0
      , 0
      .transition
        opacity: 1
      , 250, ->
        callback?()
    else callback?()
  else
    #set handle
    e = $$ '#curtain'
    #check
    if window.Worker
      e
      .stop false, true
      .transition
        opacity: 0
      , 250, ->
        e.remove()
        callback?()
    else
      e.remove()
      callback?()

#ensure
$.fn.ensure = (param) ->
  func = $.extend {}, param
  func.name = '$.fn.ensure()'
  func.singer = @eq 0
  $.ensure func
  func.singer
$.ensure = (param, callback) ->
  func =
    name: '$.ensure()'
    callback: callback
  if param
    #check type
    switch $.type(param)
      when 'function'
        func.callback = param
      when 'object'
        $.extend func, param
        func.name = '$.ensure()'
      else $.info "debug::[#{func.name}]#6"
    #singer
    func.singer ?= func.obj
    func.text ?= '若确信继续当前操作，请点击
        <a onclick="$(\'#btn-ok-ensure\').click();">[确定]</a>
        按钮，反之则请点击
        <a onclick="$(\'#btn-cancel-ensure\').click();">[取消]</a>
        按钮。'
    if func.callback?
      area = $ '#area-window'
      $('#win-ensure').remove()
      html = '<div id="win-ensure" class="win">
            <button id="btn-ok-ensure" class="btn danger"><i class="icon icon-check-circle"></i>确定</button>
            <button id="btn-cancel-ensure" class="btn primary"><i class="icon icon-times-circle"></i>取消</button>
            </div>'
      area.append html
      win = $ '#win-ensure'
      if func.singer?.length
        left = func.singer.offset().left + func.singer.width() * 0.5 - win.width() * 0.5
        top = func.singer.offset().top + func.singer.height() * 0.5 - win.height() * 0.5
        win.css
          left: left
          top: top + 16
          opacity: 0
        .stop()
        .transition
          top: top
          opacity: 1
        , 500, ->
          win.info
            type: 'warning'
            text: func.text
            fadeout: 0
            id: 'win-hint-ensure'
      else
        $$('#stage')
        .one 'click', (e) ->
          left = e.pageX - win.width() * 0.5
          top = e.pageY - win.height() * 0.5
          win.css
            left: left
            top: top + 16
            opacity: 0
          .stop()
          .transition
            top: top
            opacity: 1
          , 500, ->
            $.info 'warning::' + func.text
            win.info
              type: 'warning'
              text: func.text
              fadeout: 0
              id: 'win-hint-ensure'
      #check curtain
      if func.curtain
        $.curtain on, ->
          $$('#curtain')
          .one 'click', ->
            $('#win-hint-ensure').click()
            $.curtain off
            win.shut()
      #ok and cancel
      setTimeout ->
        $ '#btn-ok-ensure'
        .one 'click', ->
          $('#win-hint-ensure').click()
          win.shut()
          func.callback?()
          if func.curtain
            $.curtain off
        $ '#btn-cancel-ensure'
        .one 'click', ->
          $('#win-hint-ensure').click()
          win.shut()
          if func.curtain
            $.curtain off
      , 500
    else $.info "error::[#{func.name}]#5"
  else $.info "error::[#{func.name}]#5"

#shut
$.fn.shut = (callback) ->
  func =
    name: '$.fn.shut()'
    callback: callback
  @each ->
    win = $(@).closest 'div.win'
    if win.length
      clearTimeout system.timer.winHint
      $('#win-hint').click()
      win
      .stop()
      .transition
        top: win.offset().top + 16
        opacity: 0
      , 500, ->
        win.remove()
        func.callback?()
    else $.info "debug::[#{func.name}]#3"