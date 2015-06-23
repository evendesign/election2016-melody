#################################
# Settings
#################################
# DEBUG = true
DEBUG = false


#################################
# Function
#################################
xx = (x) ->
  DEBUG && console.log x


#################################
# Document events
#################################
$ ->

  $('body').delegate '.header-nav-button', 'click', ->
    if $('.header-nav').hasClass('off')
      $('.header-nav').addClass('on').removeClass('off')
    else
      $('.header-nav').addClass('off').removeClass('on')
