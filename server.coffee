#$
require './$/$'

#config
require './lib/config'

#cache
require './lib/cache'

#log
$.info 'success', 'server is ready, in ' + $.parsePts($.now() - $.st) + 'ms, as ' + $.env