#require
btoa = require 'btoa'
atob = require 'atob'

#generate
exports.generate = (secret) ->
  #seed
  seed = ($.parseString $.now())[1...]

  #token
  token = ''
  for i in [0..7]
    token += seed[i]
    token += secret[i]

  #salt
  token = 'p' + token + 's'

  #btoa
  btoa token

#validate
exports.validate = (token, secret) ->
  #check param
  if !token or !secret
    return false

  #check type
  if $.type(token) != 'string' or $.type(secret) != 'string'
    return false

  #check length
  if token.length != 24 or secret.length != 8
    return false

  #atob
  try
    t = atob token
  catch err
    $.log 'atob'
    return false

  #check pre and sub
  if t[0] != 'p'
    $.log 'pre'
    return false
  if t[17] != 's'
    $.log 'sub'
    return false

  t = t[1..16].split ''

  #get name
  name = (a for a, i in t when i % 2).join ''
  $.log name

  #check name
  if name != secret
    $.log 'name'
    return false

  #final
  true