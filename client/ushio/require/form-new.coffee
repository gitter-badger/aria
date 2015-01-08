#ready form
$.fn.readyForm = (param) ->

  #param
  p = {}
  switch $.type param
    when 'function'
      p.submit = param
    when 'object'
      p = $.extend {}, param

  #form
  form = @data().form =
    _element: {}
    _data: {}
    _callback: {}
    _status:
      ready: false
      validated: false
      disabled: false
      locked: false
      submitted: false
      unchanged: false
    _error: []

  #init
  p.init? form

  #set handle
  elem = form._element.form = @
  ipts = form._element.input = elem.find 'input, textarea'
    .not '[type=checkbox], [type=radio], [type=file]'
    .not 'input:submit, input:reset'
    .not '[disabled]'
    .filter '[name]'
  form._element.submit = (elem.find '.do, .submit').eq 0
  form._element.reset = (elem.find '.reset').eq 0

  #autosave
  s = elem.data().save
  if s
    cache.save[s] or= {}

  #function

  #element
  form.element = (name) ->
    el = form._element
    #check name
    if name
      switch name
        when 'form'
          elem
        when 'all', 'input'
          ipts
        when 'submit'
          el.submit
        when 'reset'
          el.reset
        else
          el[name] or= ipts.filter '[name=' + name + ']'
    else elem

  #data
  form.data = (p...) ->
    data = form._data
    #check param
    switch p.length
      when 1
        switch $.type p[0]
          when 'string'
            data[p[0]]
          when 'object'
            $.extend data, p[0]
            data
      when 2
        data[p[0]] = p[1]
      else data

  #reset
  form.reset = (fn) ->
    #check locked
    if !form._status.locked
      #reset
      ipts.val ''
      .keyup()
      .eq 0
      .blur().focus()
      #change
      form.change()
      #callback
      fn?()
    #return
    form

  #change
  form.change = (fn) ->
    list = form._callback.change or= $.Callbacks()
    #check fn
    if fn
      list.add fn
    else
      if !form._status.disabled
        form._status.unchanged = false
        list.fire form
    #return
    form

  #submit
  form.submit = (fn) ->
    list = form._callback.submit or= $.Callbacks()
    status = form._status
    #check fn
    if fn
      list.add fn
    else
      if !status.disabled
        #check validated
        if form.validate()
          list.fire form
        else
          $.info 'warning', (form._error.join '\n') or '未知错误。'
          if !status.submitted
            status.submitted = true
            ipts.keyup()
          ipts
          .filter '.error:eq(0)'
          .focus().select()
    #return
    form

  #validate
  form.validate = ->
    status = form._status
    #check unchanged
    if !status.unchanged
      status.unchanged = true
      arr = []
      ipts.each ->
        err = ($ @).data().error
        if err
          arr.push err
      if arr.length
        form._error = arr
        status.validated = false
      else
        form._error = []
        status.validated = true
    else status.validated

  #map
  form._map = (c) ->
    switch c
      #captcha
      when 'captcha'
        name: '验证码'
        length: [4, 8]
      #content
      when 'cont', 'content'
        name: '内容'
        length: [5, 65535]
      #comment
      when 'comm', 'comment'
        name: '评论'
        length: [5, 65535]
      #date
      when 'date'
        name: '日期'
        length: [1, 32]
        pattern: /^[\d(\-)\/\.\:\s]+$/
      #desc
      when 'desc', 'description'
        name: '简介'
        length: [10, 255]
      #email
      when 'email'
        name: '邮箱'
        length: [1, 255]
        pattern: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/
      #file
      when 'file'
        name: '文件'
        length: [1, 255]
      #username
      when 'name', 'username'
        name: '用户名'
        length: [1, 20]
      #number
      when 'num', 'number'
        name: '数字'
        length: [1, 20]
        pattern: /^[\+\-]?[\d\.]+$/
      #password
      when 'password'
        name: '密码'
        length: [6, 32]
      when 're-password'
        name: '重复密码'
        length: [6, 32]
      #required
      when 'req', 'required'
        name: '内容',
        length: [5, 65535]
      #tag
      when 'tag'
        name: '标签'
        length: [1, 255]
      when 'tags'
        name: '标签',
        length: [1, 10]
      #tel
      when 'tel'
        name: '电话'
        length: [6, 20]
        pattern: /^[\d\-\#]+$/
      #time
      when 'time'
        name: '时间'
        length: [1, 32]
        pattern: /^[\d\-\/\.\:\s]+$/
      #title
      when 'title'
        name: '标题'
        length: [5, 50]
      #url
      when 'url'
        name: '链接'
        length: [1, 255]
      else
        name: '内容'
        length: [0, 65535]

  #bind action

  #each
  ipts.each ->
    #set handle
    ipt = $ @
    #class
    c = ipt.data()['data-type'] or ipt.attr 'name' or ipt.attr 'type'
    #option
    o = form._map c
    #data
    d =
      #max
      max: ((ipt.attr 'max') | 0) or o.length[1]
      #min
      min: ((ipt.attr 'min') | 0) or o.length[0]
      #name
      name: ipt.data().name or o.name
      #pattern
      pattern: (ipt.attr 'pattern') or o.pattern

    #removeAttr
    ipt
    .removeAttr 'max'
    .removeAttr 'min'
    .removeAttr 'pattern'

    #placeholder
    d.placeholder = (ipt.attr 'placeholder') or '请输入' + d.name
    if !window.Worker
      ipt.removeAttr 'placeholder'
    else
      ipt.attr 'placeholder', d.placeholder

    #value
    v = if s then cache.save[s][c] or '' else ''
    ipt.val v
    form.data c, v

    #action
    error = (info) ->

      ipt.data 'error', info
      form._status.validated = false

      #if ready
      if form._status.ready
        ipt
        .removeClass 'success'
        .addClass 'error'

        #hint
        win = $ '#win-hint-form'
        fn = (msg) ->
          clearTimeout form._timer
          form._timer = setTimeout ->
            ipt.info
              id: 'win-hint-form'
              type: 'warning'
              direction: if ipt.data().direction then ipt.data().direction else if c == 'captcha' then 'bottom' else 'right'
              text: msg
              fadeout: 0
          , 200

        hint = info
        if hint.substr(hint.length - 1) == '。'
          hint = hint.substr 0, hint.length - 1
        if win.length
          h = win.find('.mainer').text() or 'empty'
          if hint != h or (win.css 'display') == 'none'
            fn hint
        else fn hint

    ipt
    #keyup
    .off 'keyup.setup'
    .on 'keyup.setup', ->

      #get value and length
      d.value = $.trim ipt.val()
      d.length = d.value.length
      
      #check placeholder
      if !window.Worker
        if d.value == d.placeholder
          error '请输入' + d.name + '。'
          return

      #check length
      if d.max and d.length > d.max
        error d.name + '长度不得大于' + d.max + '个字符。'
        return
      if d.min and d.length < d.min
        error d.name + '长度不得小于' + d.min + '个字符。'
        return

      #check pattern
      if d.pattern
        reg = new RegExp d.pattern
        if d.length and reg and !reg.test d.value
          error d.name + '格式错误。'
          return

      #check password
      if c == 're-password'
        if d.value != (form.element 'password').val()
          error '两次输入密码不一致。'
          return

      #there got nothing wrong
      ipt
      .data 'error', null
      .removeClass 'error'
      .addClass 'success'
      #close hint
      clearTimeout form._timer
      ($ '#win-hint-form').click()

      #validate
      if form._status.ready
        form.validate()

    #keydown
    .off 'keydown.setup'
    .on 'keydown.setup', (e) ->

      #check which
      #tab == 9, enter == 13
      which = e.which | 0
      if which in [9, 13]

        #set handle
        _ipts = ipts.not '.disabled'
        length = _ipts.length
        index = _ipts.index ipt

        #switch which
        switch which
          #tab
          when 9
            e.preventDefault()
            _ipts.eq if index != length - 1 then 1 + index else 0
            .focus().select()
          #enter
          when 13
            #function next
            next = ->
              #check if last
              if index == length - 1
                ipt.blur()
                form.submit()
              else
                _ipts.eq if index != length - 1 then 1 + index else 0
                .focus()
            #check type
            if ipt.is 'textarea'
              #textarea
              #check ctrl
              if e.ctrlKey
                e.preventDefault()
                next()
            else
              #not textarea
              e.preventDefault()
              #check ctrl
              if e.ctrlKey
                ipt.blur()
                form.submit()
              else
                next()

    #focus
    .off 'focus.setup'
    .on 'focus.setup', ->

      #placeholder
      if !window.Worker and d.value == d.placeholder
        ipt.val ''
      #keyup
      ipt.keyup()

    #blur
    .off 'blur.setup'
    .on 'blur.setup', ->

      #tag
      if c == 'tag'
        tvr = new RegExp(d.placeholder, 'g')
        arr = $.unique($.trim(ipt.val().replace(tvr, '')).replace(/\s{2,}/g, ' ').split(' '))
        arr.splice 10 if arr.length > 10
        ipt.val(arr.sort().join(' ')).change()

      #placeholder
      if !window.Worker and !(c in ['password', 're-password'])
        if !d.value
          ipt.val d.placeholder

      #close hint
      clearTimeout form._timer
      form._timer = setTimeout ->
        $('#win-hint-form').click()
      , 200

    #change
    .off 'change.setup'
    .on 'change.setup', ->

      #check if error
      if !ipt.data().error
        d.value = $.trim ipt.val().replace d.placeholder, ''
        if d.value
          form.data c, d.value
          #auto save
          if s and !(c in ['password', 're-password'])
            cache.save[s][c] = d.value
            $.save 'cache', -> $.i '表单内容已自动存储。'
      #change
      form.change()

    #ready
    .keyup()

  #reset
  (form.element 'reset').click -> form.reset()

  #submit
  (form.element 'submit').click -> form.submit()

  #check param
  if p.submit
    form.submit p.submit
  if p.change
    form.change p.change

  #ready
  form._status.ready = true
  form.validate()

  #auto focus
  if elem.data().focus
    ipts.each ->
      ipt = $ @
      if ipt.data().error
        ipt.focus().select()
        return false

  #ready
  (p.ready or p.callback)? form