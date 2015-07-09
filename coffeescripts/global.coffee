#################################
# Settings
#################################
DEBUG = true
# DEBUG = false

# window.inInterval = true
window.inInterval = false


#################################
# Function
#################################
xx = (x) ->
  DEBUG && console.log x


#################################
# Document events
#################################
$ ->
  # $.getJSON '//api.iing.tw/check_ininterval.json?token=8888', (r) ->
  # # $.getJSON '//api.iing.tw/check_ininterval.json?token=8888&date=2015-07-07 00:00', (r) ->
  #   if r.in_interval is false
  #     window.inInterval = false
  #     $('body').addClass 'event-close'

  $('body').delegate '.header-nav-button', 'click', ->
    if $('.header-nav').hasClass('off')
      $('.header-nav').addClass('on').removeClass('off')
    else
      $('.header-nav').addClass('off').removeClass('on')
