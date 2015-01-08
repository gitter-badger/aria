#require
require 'node-jquery-lite'

#router
require './server/router/router'

#log
$.info 'success', 'server is ready, in ' + ($.now() - $.st) + ' ms'