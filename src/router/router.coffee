#require
app = (require 'express')()

#router

#index
app.get '/', (req, res) ->
  #res.sendFile 'public/html/index.html'
  res.send 'Briko is a smart egg, with love to Mimiko.'

#port
#use process.env.PORT for c9.io
app.listen process.env.PORT or 80

#log
$.info 'success', 'router is ready'