#require
app = (require 'express')()

#router

#index
app.get '/', (req, res) ->
  res.sendFile 'public/html/index.html'

#port
app.listen 80

#log
$.info 'success', 'router is ready'