#require
require 'node-jquery-lite'

#router
require './router/router'

#count
setInterval ->
  $.info 'info', $.parsePts((($.now() - $.st) / 1e3) | 0) + 's'
, 1e3

#log
$.info 'success', 'server is ready, in ' + ($.now() - $.st) + ' ms'