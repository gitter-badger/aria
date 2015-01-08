#history
$.history = (p...) -> if !p[0] then cache.history else cache.history[p[0]] or {}

#add
$.history.add = ->
  #check url
  url = location.href

  #check if sp
  if ~url.search /\/sp\//
    $.info 'sp'

  $.info '123'