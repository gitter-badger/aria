$.config =
  port: process.env.PORT or 80
  cache: 'memory'
  jade:
    cache: if $.debug then false else true