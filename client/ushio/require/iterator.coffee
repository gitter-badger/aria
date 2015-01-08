#iterator
class $.Iterator
  #function
  @::f =
    ci: (i) ->
      i = i | 0
      if i < 0
        0
      else if i > @length - 1
        @length - 1
      else i
  #push
  @::push = (p...) ->
    #list
    @list ?= []
    switch p.length
      when 0
        @
      when 1
        @list.push p[0]
      else
        @list.push.apply @list, p
    #length
    @length = @list.length
    @index ?= -1
    #return
    @
  #next
  @::next = (p...) -> @eq @f.ci(@index + 1), p...
  #prev
  @::prev = (p...) -> @eq @f.ci(@index - 1), p...
  #eq
  @::eq = (i, p...) ->
    r = if i > 0
      @list[@index = @f.ci i]
    else if i < 0
      @list[@index = @f.ci @length + i]
    else
      @list[@index = 0]
    switch $.type r
      when 'function'
        r p...
      else r
  #range
  @::range = (a, b) ->
    #check a
    if a >= 0
      a = @f.ci a
      #check b
      if b >= 0
        b = @f.ci b
        @list[a..b]
      else @list[a...]
    else @list
  #run
  @::run = (p...) ->
    @index = -1
    @next p...
  #end
  @::end = (p...) ->
    @index = @length - 2
    @next p...