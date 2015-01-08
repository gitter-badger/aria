#ready form
$.fn.readyForm = (param) ->
  #param
  p = {}
  switch $.type param
    when 'object'
      p = $.extend {}, param
    when 'function'
      p.callback = param

  #check start
  p.start?()

  #set handle
  form = @
  data = form.data()
  ipts = form.find 'input, textarea'
  .not '[type=checkbox], [type=radio], [type=file]'
  .not 'input:submit, input:reset'
  .not '[disabled]'
  .filter '[class]'

  btnDo = form.find('.do, input:submit').eq 0
  btnReset = form.find('.reset, input[type=reset]').eq 0

  #function
  #fire
  data.fire = (callback = p.callback) ->
    #check setuped
    if !form.data().setuped
      return
    #check disabled
    if btnDo.hasClass 'disabled'
      return

    #disabled
    btnDo.addClass 'disabled'
    setTimeout ->
      btnDo.removeClass('disabled')
    , 2e3

    #final check
    data.finalCheck = 1
    ipts.each ->
      $(@).focus().change().blur()
    iptsErr = ipts.filter 'input.error, textarea.error'
    if iptsErr.length
      hint = ''
      iptsErr.each ->
        hint += $(@).data().errorinfo + '<br />'
      $.info "warning::#{hint}"
      iptsErr.eq(0).focus().select()
    else callback?()

  #clear
  data.clear = (callback) ->
    ipts.val('').keyup().blur().eq(0).focus().select()
    callback?()

  #save
  s = form.data().save
  if s and !cache.save[s] then cache.save[s] = {}
  #inner
  getFunc = (c) ->
    switch c
      when 'captcha'
        name: '验证码'
        length: [4, 8]
      when 'cont', 'content'
        name: '内容'
        length: [5, 65535]
      when 'comm', 'comment'
        name: '评论'
        length: [5, 65535]
      when 'date'
        name: '日期'
        length: [1, 32]
        pattern: /^[\d(\-)\/\.\:\s]+$/
      when 'desc'
        name: '简介'
        length: [10, 255]
      when 'email'
        name: '邮箱'
        length: [1, 255]
        pattern: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/
      when 'file'
        name: '文件'
        length: [1, 255]
      when 'name'
        name: '用户名'
        length: [1, 20]
      when 'num', 'number'
        name: '数字'
        length: [1, 20]
        pattern: /^[\+\-]?[\d\.]+$/
      when 'password'
        name: '密码'
        length: [6, 32]
      when 're-password'
        name: '重复密码'
        length: [6, 32]
      when 'req', 'required'
        name: '内容',
        length: [5, 65535]
      when 'tag'
        name: '标签'
        length: [1, 255]
      when 'tags'
        name: '标签',
        length: [1, 10]
      when 'tel'
        name: '电话'
        length: [6, 20]
        pattern: /^[\d\-\#]+$/
      when 'time'
        name: '时间'
        length: [1, 32]
        pattern: /^[\d\-\/\.\:\s]+$/
      when 'title'
        name: '标题'
        length: [5, 50]
      when 'url'
        name: '链接'
        length: [1, 255]
      else
        name: '内容'
        length: [0, 65535]
  #bind action
  ipts.each ->
    #set handle
    ipt = $ @
    c = ipt.data()['class'] or ipt.attr 'class'
    if c.search(/\s/) != -1 then c = $.trim(c.replace(/\s+/g, ' ')).split(' ')[0]
    f = getFunc c
    a = p: ipt.attr 'placeholder'
    d =
      l: if ipt.data().length then ipt.data().length.replace(/\s/g, '').split ',' else f.length
      n: ipt.data().name or f.name
      r: ipt.data().pattern or f.pattern
      v: $.trim ipt.val()
    d.p = ipt.data().placeholder or a.p or "请输入#{d.n}"
    #placeholder
    if d.p?.length and !(c == 'password' or c == 're-password')
      if window.Worker and !a.p then ipt.attr placeholder: d.p
      if s and cache.save[s]?[c]? then ipt.val cache.save[s][c]
      else ipt.val d.p if !window.Worker
    else ipt.val ''
    #required
    ipt.attr required: 'required' if window.Worker and d.l[0]? and d.l[0] > 0
    #
    ipt.data class: c
    .removeAttr 'disabled'
    #keyup
    .off 'keyup.setup'
    .on 'keyup.setup', (e) ->
      d.v = $.trim ipt.val()
      hint = $ '#win-hint-form'
      if d.p and d.v == d.p
        ipt.data errorinfo: "请输入#{d.n}。"
        .removeClass 'success'
        .addClass 'error'
      else
        len = d.l
        if len and (d.v.length < len[0] or d.v.length > len[1])
          ipt.data errorinfo: "#{d.n}长度应在#{len[0]}到#{len[1]}个字符之间。"
          .removeClass 'success'
          .addClass 'error'
        else
          reg = if d.r then new RegExp d.r else null
          if d.v.length and reg and !reg.test d.v
            ipt.data errorinfo: "#{d.n}格式错误"
            .removeClass 'success'
            .addClass 'error'
          else
            if c == 're-password'
              if ipt.val() != form.find('input.password').val()
                ipt.data errorinfo: '两次输入密码不一致'
                .removeClass 'success'
                .addClass 'error'
              else
                ipt.removeClass 'error'
                .addClass 'success'
            else
              ipt.removeClass 'error'
              .addClass 'success'
      if ipt.hasClass 'error'
        e = ipt.data().errorinfo
        if e
          if e.substr(e.length - 1) == '。'
            e = e.substr(0, e.length - 1)
          h = hint.find('div.mainer').text() or 'empty'
          if form.data().setuped and (e != h or hint.css('display') == 'none')
            clearTimeout form.data().timer
            ipt.info
              id: 'win-hint-form'
              type: 'warning'
              direction: if ipt.data().direction then ipt.data().direction else
                if c == 'captcha' then 'bottom' else
                  if ipt.width() < 640 then 640 else 'auto'
              text: e
              fadeout: 0
      else
        hint.click()
    #keydown
    .off 'keydown.setup'
    .on 'keydown.setup', (e) ->
      if e.which == 9
        e.preventDefault();
        iptsv = ipts.not '.hidden'
        index = iptsv.index ipt
        if index != iptsv.length - 1 then iptsv.eq(1 + index).focus().select()
        else
          if u? then window.UE.getEditor(u).execCommand 'selectAll'
          else iptsv.eq(0).focus().select()
      else if e.which == 13
        if ipt.is('input') or (ipt.is('textarea') and e.ctrlKey)
          e.preventDefault();
          index = ipts.index ipt
          if index != ipts.length - 1 then ipts.eq(index + 1).focus()
          else
            if u? then window.UE.getEditor(u).focus()
            else
              if btnDo.is 'input' then form.submit()
              else btnDo.click()
    #focus
    .off 'focus.setup'
    .on 'focus.setup', ->
      #get value
      d.v = $.trim ipt.val()
      ipt.val '' if d.p?.length and d.v == d.p
      ipt.keyup()
    #blur
    .off 'blur.setup'
    .on 'blur.setup', ->
      if c == 'tag'
        tvr = new RegExp(d.p, 'g')
        arr = $.unique($.trim(ipt.val().replace(tvr, '')).replace(/\s{2,}/g, ' ').split(' '))
        arr.splice 10 if arr.length > 10
        ipt.val(arr.sort().join(' ')).change()
      if d.p?.length and !(c == 'password' or c == 're-password')
        ipt.val d.p if !ipt.val() and !window.Worker
      #close hint
      clearTimeout form.data().timer
      form.data().timer = setTimeout ->
        if !form.data().finalCheck
          $('#win-hint-form').click()
        else
          form.data().finalCheck = 0
      , 200
    #change
    .off 'change.setup'
    .on 'change.setup', ->
      if !ipt.hasClass 'error'
        d.v = $.trim(ipt.val().replace(d.p, ''))
        if d.v?.length
          form.data()[c] = d.v
          #auto save
          if s and form.data().setuped and !ipt.hasClass('error') and !(c == 'password' or c == 're-password')
            cache.save[s][c] = d.v
            $.save 'cache', -> $.i '表单内容已自动存储。'
  #reset
  if btnReset.length
    btnReset
    .off 'click.setup'
    .on 'click.setup', ->
      if form.data().setuped
        btnReset.ensure
          curtain: off,
          text: '是否确定清空表单？'
          callback: ->
            data.clear()
            $.info 'info::表单已清空。'
  #do
  if btnDo.length
    btnDo
    .off 'click.setup'
    .on 'click.setup', -> data.fire p.callback
  else
    $.info text = "error::[#{p.name}]#4"
    form.info text
  #check focus
  if form.data().focus
    setTimeout ->
      ipts.eq(0).select()
    , 200
  #setup finished
  form.data().setuped = 1
  #check finish
  p.finish?()