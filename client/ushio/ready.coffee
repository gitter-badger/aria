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

  #listener of stage
  do ->
    #set handle
    root = $ window
    body = $$ 'body'
    stage = $$ '#stage'
    mainer = $$ '#mainer'
    #add listener
    root.resize -> $.delay 'stageResize', 200, resize
    #function
    do resize = ->
      #height fix
      do ->
        h = mainer.height() + (root.height() or body.height()) - stage.height()
        if h > 0 then mainer.css 'min-height': h
      #shortcut
      do ->
        elem = $$ '#btn-top-shortcut'
        inner = $$ '#guide-inner'
        if elem.length then elem.css left: inner.offset().left + inner.width() + 16

  #shortcut
  do ->
    #set handle
    elem = $$ '#btn-top-shortcut'
    #prepare
    if elem.length
      elem
      .data
        timer: null
        viewing: false
      #buttons
      #light
      eb = elem.find '.light'
      if eb.length
        eb.click ->
          btn = $ @
          hint = btn.children '.hint'
          if btn.hasClass 'active'
            btn.removeClass 'active'
            $.curtain off
            hint.text '关灯'
          else
            btn.addClass 'active'
            $.curtain on, ->
              $$ '#area-player'
              .css 'z-index': 5
              .scrollOnto()
              $$ '#curtain'
              .css
                'background-color': '#000'
                opacity: 0.95
              .click ->
                btn.click()
            hint.text '开灯'
      #comment
      eb = elem.find '.comm'
      if eb.length
        eb.click -> $$('#area-comment').scrollOnto()
      #feedback
      eb = elem.find 'a.feedback'
      if eb.length
        eb.attr href: eb.attr('href') + '#from=' + location.href.replace /[#\?].*/, ''
      #top
      eb = elem.find '.top'
      if eb.length
        eb.click -> $$('#stage').scrollOnto()

      #show
      elem.removeClass 'hidden'

  #guide
  do ->
    #set handle
    guide = $$ '#guide'
    sub = $$ '#sub-guide'
    inner = $$ '#guide-inner'
    subInner = $$ '#sub-guide-inner'

    #simple
    simple = if guide.hasClass 'simple' then yes or no

    tabs = if simple then inner.find 'div.l:eq(0)>a:not(.only)' else inner.find 'div.b>div.l>a:not(.only)'

    #prepare
    sub.data timer: null
    #action
    tabs
    .mouseenter ->
      #set handle
      tab = $ @
      clearTimeout sub.data().timer
      sub.data().timer = setTimeout ->
        tab
        .addClass 'active'
        .siblings '.active'
        .removeClass 'active'
        channel = tab.data().channel
        unit = subInner.find 'div.channel-' + channel
        #action
        unit
        .addClass 'active'
        .removeClass 'hidden'
        #left
        left = tab.position().left - unit.width() * 0.2
        left = 0 if left < 0
        unit
        .css
          opacity: 0
          left: left
        .stop false, true
        .transition
          opacity: 1
        , 200
        .siblings '.active'
        .removeClass 'active'
        .addClass 'hidden'
        sub.addClass 'active'
      , 50
    .mouseleave ->
      clearTimeout sub.data().timer
      sub.data().timer = setTimeout ->
        tabs.filter '.active'
        .removeClass 'active'
        sub.removeClass 'active'
      , 200

    sub
    .mouseenter ->
      clearTimeout sub.data().timer
    .mouseleave ->
      clearTimeout sub.data().timer
      sub.data().timer = setTimeout ->
        tabs.filter '.active'
        .removeClass 'active'
        sub.removeClass 'active'
      , 200
    #win
    #info
    do ->
      elem = $$ '#a-avatar-guide'
      win = $$ '#win-info-guide'
      mainer = win.find 'div.mainer'
      cont = mainer.children 'div.b'
      area = $$ '#area-user-guide'
      thumb = $$ '#a-avatar-guide'
      link = thumb.add '#win-info-guide>div.mainer>div.c>a'
      #prepare
      elem.data timer: null
      #function
      f = ->
        clearTimeout elem.data().timer
        elem.data().timer = setTimeout ->
          win
          .stop false, true
          .addClass 'hidden'
        , 500
      hideHint = ->
        elem.find 'p.info-hint'
        .text 0
        .addClass 'hidden'
      elem
      .mouseenter ->
        clearTimeout elem.data().timer
        elem.data().timer = setTimeout ->
          #clear
          $$('#win-history-guide').addClass 'hidden'
          $$('#win-post-guide').addClass 'hidden'
          top = if simple then 48 else if guide.data().viewing then 48 else 80
          win
          .css
            opacity: 0
            top: top - 8
          .removeClass 'hidden'
          .stop false, true
          .transition
            opacity: 1
            top: top
          , 100
        , 200
      .mouseleave f
      win
      .mouseenter ->
        clearTimeout elem.data().timer
      .mouseleave f

      #check online
      user.uid = ($.cookie 'auth_key') | 0
      if user.uid
        #user data
        user.online = 1
        user.name = $.cookie 'ac_username'
        user.key = $.cookie 'auth_key_ac_sha1'
        #check group
        if $.cookie('ac_time')
          #admin
          user.group = 0
        else
          #member
          user.group = 2
      else
        #user data
        user.online = 0
        user.group = 1
        user.name = '游客'

      if user.online
        #online
        #name
        $$ '#a-name-guide'
        .text $.parseSafe(user.name)
        #avatar
        elem
        .removeClass 'hidden'
        .children 'img.avatar'
        .attr src: $.parseSafe(user.avatar)
        .removeClass 'hidden'
        #logout
        $$ '#a-logout-guide'
        .attr href: '/logout.aspx?returnUrl=' + $.parseSafe location.href.replace(/\?.*/, '').replace /#.*/, ''
        .one 'click', (e) ->
          e.preventDefault()
          #clear data
          window.user = {}
          $.save 'user', ->
            #logout
            location.href = '/logout.aspx?returnUrl=' + $.parseSafe location.href
        #bind action
        thumb.click hideHint
        mainer.delegate 'div.b a, div.c a', 'click', hideHint

        #check unread
        $.get '/member/unRead.aspx',
          uid: user.uid
        .fail -> error 8
        .done (data) ->
          user.unread =
            push: data.newPush
            at: data.mention
            mail: data.unReadMail
            fan: data.newFollowed
          #callback
          html = ''
          n = 0
          url = ''
          if user.unread.push
            html += '<a class="unit" href="/member/#area=push" target="_blank">
                          <i class="icon icon-play-circle"></i>
                          您有<span class="pts">' + user.unread.push + '</span>条新推送
                        </a>'
            n += parseInt user.unread.push
            url = '/member/#area=push'
          if user.unread.fan
            html += '<a class="unit" href="/member/#area=followers" target="_blank">
                          <i class="icon icon-user"></i>
                          您有<span class="pts">' + user.unread.fan + '</span>个新听众
                        </a>'
            n += parseInt user.unread.fan
            url = '/member/#area=followers'
          if user.unread.at
            html += '<a class="unit" href="/member/#area=mention" target="_blank">
                          <i class="icon icon-at"></i>
                          您被召唤了<span class="pts">' + user.unread.at + '</span>次
                        </a>'
            n += parseInt user.unread.at
            url = '/member/#area=mention'
          if user.unread.mail
            html += '<a class="unit" href="/member/#area=mail" target="_blank">
                          <i class="icon icon-envelope"></i>
                          您有<span class="pts">' + user.unread.mail + '</span>条新私信
                        </a>'
            n += parseInt user.unread.mail
            url = '/member/#area=mail'
          link.attr href: url if url
          html = '<p class="alert">暂未有任何信息。</p>' if !html.length
          cont.html html
          if n > 0
            n = '99+' if n > 99
            elem.find 'p.info-hint'
            .text n
            .removeClass 'hidden'
          else hideHint()
      else
        #not online
        $$ '#a-login-guide'
        .removeClass 'hidden'
    #history
    do ->
      elem = $$ '#a-history-guide'
      win = $$ '#win-history-guide'
      cont = win.find 'div.mainer>div.b'
      #prepare
      elem.data timer: null
      #function
      f = ->
        clearTimeout elem.data().timer
        elem.data().timer = setTimeout ->
          win
          .stop false, true
          .addClass 'hidden'
        , 500
      elem
      .mouseenter ->
        clearTimeout elem.data().timer
        elem.data().timer = setTimeout ->
          #clear
          $$('#win-info-guide').addClass 'hidden'
          $$('#win-post-guide').addClass 'hidden'
          html = ''
          #check length
          len = cache.history.views?.length ? null
          if len
            temp = '<a class="unit" href="[url]" target="_blank" title="[title]">
                      <p class="title">[title]</p>
                      <p class="desc">浏览于<span class="time">[time]</span></p>
                    </a>'
            for i in (if simple then [0..3] else[0..5])
              a = cache.history.views[len - i]
              if a?
                if a.type == 'bangumi'
                  data =
                    url: '/v/ab' + a.bid + (if a.part > 0 then '_' + a.part else '')
                    title: a.title + ' ' + a.name
                    time: $.parseTime a.time
                else
                  data =
                    url: (if a.type and a.type == 'album' then '/a/aa' else '/v/ac') + a.aid + (if (a.part | 0) > 0 then '_' + (a.part + 1) else '')
                    title: a.title
                    time: $.parseTime a.time
                html += $.parseTemp temp, data
          else
            html = '<p class="alert warning">
                      尚未记录任何历史信息。
                    </p>'
          #insert dom
          cont.html html
          top = if simple then 48 else if guide.data().viewing then 48 else 80
          win
          .css
            opacity: 0
            top: top - 8
          .removeClass 'hidden'
          .stop false, true
          .transition
            opacity: 1
            top: top
          , 100
        , 200
      .mouseleave f
      win
      .mouseenter ->
        clearTimeout elem.data().timer
      .mouseleave f
    #post
    do ->
      elem = $$ '#a-post-guide'
      win = $$ '#win-post-guide'
      #prepare
      elem.data timer: null
      #function
      f = ->
        clearTimeout elem.data().timer
        elem.data().timer = setTimeout ->
          win
          .stop false, true
          .addClass 'hidden'
        , 500
      elem
      .mouseenter ->
        clearTimeout elem.data().timer
        elem.data().timer = setTimeout ->
          #clear
          $$('#win-info-guide').addClass 'hidden'
          $$('#win-history-guide').addClass 'hidden'
          top = if simple then 48 else if guide.data().viewing then 48 else 80
          win
          .css
            opacity: 0
            top: top - 8
          .removeClass 'hidden'
          .stop false, true
          .transition
            opacity: 1
            top: top
          , 100
        , 200
      .mouseleave f
      win
      .mouseenter ->
        clearTimeout elem.data().timer
      .mouseleave f
    #scroll
    do ->
      #set handle
      root = $ window
      doc = $ document
      shortcut = $$ '#btn-top-shortcut>.top'
      gh = if simple then 0 else 78 #guide height
      tc = if simple then 'float' else 'float simple' #toggle class
      #function
      fold = (time = 500) ->
        if !guide.data().viewing
          return
        if time
          guide
          .stop false, true
          .data
            viewing: false
            top: 0
          .transition
            top: -48
          , time, ->
            guide
            .removeClass tc
            .css top: 0
        else
          guide
          .stop false, true
          .data
            viewing: false
            top: 0
          .removeClass tc
          .css top: 0
      #scroll
      scroll = ->
        top = doc.scrollTop() #scroll top
        wh = root.innerHeight() #window height
        #guide
        if !system.gate.guideFloatDisabled and config.globe.guideFloatAllowed
          if top > guide.data().top
            #down
            if guide.data().viewing and !guide.data().hover
              fold()
          else if top < guide.data().top
            #up
            if top <= gh
              if guide.data().viewing
                clearTimeout guide.data().timer
                fold 0
            else
              if !guide.data().viewing
                guide
                .data viewing: true
                .css
                  top: -48
                .addClass tc
                .stop false, true
                .transition
                  top: 0
                , 200
              #fold
              clearTimeout guide.data().timer
              guide.data().timer = setTimeout ->
                if guide.data().viewing then fold()
              , 2e3
        #top
        guide.data().top = top
        #shortcut
        if top > wh
          if !shortcut.data().viewing
            shortcut
            .css
              opacity: 0
              visibility: 'visible'
            .stop false, true
            .transition
              opacity: 1
            , 200, ->
              shortcut.data().viewing = true
        else
          if shortcut.data().viewing
            shortcut
            .stop false, true
            .transition
              opacity: 0
            , 200, ->
              shortcut
              .css visibility: 'hidden'
              .data().viewing = false
      #prepare
      guide
      .data
        timer: null
        top: 0
        viewing: false
        hover: false
      .mouseenter ->
        guide.data().hover = true
        clearTimeout guide.data().timer
      .mouseleave ->
        guide.data().hover = false
        #fold
        clearTimeout guide.data().timer
        guide.data().timer = setTimeout ->
          if guide.data().viewing then fold()
        , 2e3
      #action
      root.scroll -> $.delay 'guideScroll', 100, scroll

  #search bar
  $$('#area-search-guide>input.ipt-search').one 'focus', ->
    #set handle
    form = $$ '#area-search-guide'
    ipt = form.find 'input.ipt-search'
    dropdown = form.find 'ul.menu-search'
    placeholder = ipt.attr('placeholder') or '搜索'
    #check input is exist or not
    if ipt.length
      #prepare
      form.data
        timer: null
        port: null
      #placeholder
      ipt.val placeholder if !window.Worker

      #dropdown
      dropdown
      .css
        left: ipt.offset().left - form.offset().left
        top: ipt.offset().top - form.offset().top + 36
        'min-width': ipt.width() + 20
      .delegate 'a', 'click', ->
        obj = $ @
        ipt.val obj.find('span.cont').text()

      #input
      ipt
      .focus ->
        if ipt.val() == placeholder then ipt.val ''
        ipt.keyup()
        dropdown
        .css
          display: 'block'
          opacity: 0
          'min-width': ipt.width() + 20
        .stop false, true
        .transition
          opacity: 1
        , 200
      .blur ->
        #trim
        ipt.val $.trim ipt.val()
        if !$.trim(ipt.val()).length and !window.Worker then ipt.val placeholder
        dropdown
        .stop false, true
        .transition
          opacity: 0
        , 200, ->
          dropdown.css display: 'none'
      .keydown (e) ->
        #trim
        if e.which == 13 or e.which == 10
          ipt.val $.trim ipt.val()
      .keyup (e) ->
        #set handle
        obj = dropdown.children 'li.active'
        #check which
        if e.which == 38 or e.which == 40
          #up and down
          e.preventDefault()
          if !obj.length
            system.tv = if e.which == 38 then 'last' else 'first'
            dropdown.children('li:' + system.tv).addClass 'active'
          else
            i = if e.which == 38 then obj.index() - 1 else obj.index() + 1
            i = dropdown.children('li').length - 1 if i < 0
            i = 0 if i >= dropdown.children('li').length
            obj.removeClass 'active'
            dropdown.children 'li:eq(' + i + ')'
            .addClass 'active'
          #change ipt
          ipt.val dropdown.children('li.active').find('span.cont').text()
        else
          val = $.trim ipt.val()
          if val.length
            clearTimeout form.data().timer
            form.data().timer = setTimeout ->
              form.data().port?.abort()
              form.data().port = $.getScript 'http://search.acfun.tv/suggest?cd=1&q=' + encodeURI(val)
              .done ->
                d = $.parseJson $.parseString system.tv
                if d?.status == 200
                  if d.data.length
                    html = ''
                    for a in d.data
                      html += '<li><a href="/search/#query=' + a.name + '" target="_blank"><span class="cont">' + a.name + '</span><span class="hint">约有' + a.count + '个结果</span></a></li>'
                  else html = temp
                else html = temp
                dropdown.html html
                .removeClass 'hidden'
              .fail -> dropdown.html temp
            , 500
          else
            dropdown.addClass 'hidden'
      #first time
      .val ''
      .focus()

  #site list
  $.parseChannel.list = [
    #anime
    [1, '动画']
    [106, '动画短片']
    [107, 'MAD·AMV']
    [108, 'MMD·3D']
    [67, '新番连载']
    [109, '旧番补档']
    [120, '国产动画']
    [113, '动画专题']
    #music
    [58, '音乐']
    [101, '演唱·乐器']
    [102, '宅舞']
    [103, 'Vocaloid']
    [105, '流行音乐']
    [104, 'ACG音乐']
    [114, '音乐专题']
    #game
    [59, '游戏']
    [83, '游戏集锦']
    [84, '实况解说']
    [71, 'Flash游戏']
    [72, 'Mugen']
    [85, '英雄联盟']
    [115, '游戏专题']
    #joy
    [60, '娱乐']
    [86, '生活娱乐']
    [87, '鬼畜调教']
    [88, '萌宠']
    [89, '美食']
    [121, '原创网络剧']
    [116, '娱乐专题']
    #tech
    [70, '科技']
    [90, '科学技术']
    [91, '数码']
    [92, '军事']
    [122, '汽车']
    [119, '科技专题']
    #sport
    [69, '体育']
    [93, '惊奇体育']
    [94, '足球']
    [95, '篮球']
    [118, '体育专题']
    #film
    [68, '影视']
    [96, '电影']
    [97, '剧集']
    [98, '综艺']
    [99, '特摄·布袋戏']
    [100, '纪录片']
    [117, '影视专题']
    #article
    [63, '文章'],
    [110, '文章综合']
    [73, '工作·情感']
    [74, '动漫文化']
    [75, '漫画·小说']
    #other
    [76, '页游资料']
    [77, '1区']
    [78, '21区']
    [79, '31区']
    [80, '41区']
    [81, '文章里区(不审)']
    [82, '视频里区(不审)']
    [42, '图库']
  ]
  $.parseChannel.map =
    1: [106, 107, 108, 67, 109, 120, 113]
    58: [101, 102, 103, 105, 104, 114]
    59: [83, 84, 71, 72, 85, 115]
    60: [86, 87, 88, 89, 121, 116]
    70: [90, 91, 92, 122, 119]
    69: [93, 94, 95, 118]
    68: [96, 97, 98, 99, 100, 117]
    110: [63, 73, 74, 75]
    0: [76, 77, 78, 79, 80, 81, 82, 42]

  #record online
  do ->
    if user.online and system.url.search(/acfun/) != -1
      do f = ->
        $.get '/online.aspx', uid: user.uid
        .done (data) ->
          if data.success
            user.level = data.level | 0
            user.ban = data.isdisabled
            user.onlineTime = data.duration | 0
            $.save 'user'
      setInterval f, 3e5

  #tongji
  window._hmt or= []
  $$ '#stage'
  .after '<script src="//hm.baidu.com/hm.js?bc75b9260fe72ee13356c664daa5568c"></script>'

  #remove game hidden class
  if user.online and user.level > 1
    $('#sub-guide-inner .unit a.hidden').removeClass 'hidden'

  #check browser
  system.func.checkBrowser ->
    #notice
    port = $.get '/notice.aspx'
    .done (data) ->
      if data.success

        #check date
        system.td = system.st - new Date port.getResponseHeader 'Date'

        #regable
        if data.data.registerOn then system.regable = 1

        #notice
        arr = data.data.list
        if arr.length
          #params
          cache.notice or= []
          #handle
          block = $$ '#block-notice-guide'
          temp = block.children('div.temp').html()
          inner = block.children 'div.inner'
          html = ''
          inner.data().length = 0
          for a, i in arr when i < 2
            #check browser
            if b = a.content.match /data\-browser="([\w\W]+?)"/
              b = b[1].split ':'
              #check browser name
              if system.browser.name == b[0]
                if b[1]
                  v = system.browser.version.split('.')[0]
                  if b[1].search(/\+/) != -1 #like 9+
                    if v < parseInt b[1]
                      continue
                  else if b[1].search(/\-/) != -1 #like 9-
                    if v > parseInt b[1]
                      continue
                  else #like 9+
                    if v != b[1] | 0
                      continue
              else continue
            #check if readed
            if a.time in cache.notice then continue
            #temp
            inner.data().length++
            html += $.parseTemp temp,
              text: a.content
              time: a.time
          if inner.data().length
            inner
            .delegate 'span.close', 'click', ->
              btn = $ @
              elem = btn.closest 'div.item'
              cache.notice.unshift btn.data().time
              cache.notice = cache.notice[0...5] if cache.notice.length > 5
              $.save 'cache'
              inner.data().length--
              obj = if inner.data().length then elem else block
              obj
              .transition
                opacity: 0
                height: 0
                padding: 0
              , 200, -> obj.remove()
            .html html
            block.removeClass 'hidden'

    #avatar
    do ->
      elem = $$ '#avatar-ac-footer'
      #check length
      if system.browser.borderradius and elem.length
        elem.data().src = ->
          system.path.short + '/umeditor/dialogs/emotion/images/ac/' + ($.rnd 1, 51) + '.gif'
        src = elem.data().src()
        $.preload src, ->
          html = '<img src="' + src + '">'
          elem
          .html html
          #bind action
          .one 'click', -> $.getScript system.path.short + '/script/require/avatar' + if system.debug then '.js' else '.min.js?date=' + parseInt($.now() / 864e5) + system.ver.replace(/\./g, '')
          .removeClass 'hidden'

    #debug
    if system.debug then $.require 'debug'

    #clear
    system.func.ready = null

    #callback
    callback?()
#======