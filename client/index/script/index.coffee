$ ->
  $.require 'ready', ->

    #nav
    $$ '#nav'
    .find 'a:first'
    .addClass 'active'