#################################
# Settings
#################################
DEBUG = true
# DEBUG = false
maxWidth = $(window).width()

#################################
# Function
#################################
xx = (x) ->
  DEBUG && console.log x


#################################
# Document events
#################################
$ ->

  $('body').mousemove (e) ->
    percent =  (e.pageX/maxWidth)*100
    $('.color-lines .layer-1').css('right', (percent - 50)*.7 + "px")
    $('.color-lines .layer-2').css('right', (percent - 50)*.5 + "px")
    $('.color-lines .layer-3').css('right', (percent - 50)*.3 + "px")
    $('.color-lines .layer-4').css('right', (percent - 50)*.1 + "px")
    $('.color-dots').css('right', (percent - 50)*.9 + "px")
    $('.gray-balls').css('right', (percent - 50)*.5 + "px")
    $('.hero-title-container').css('right', (percent - 50)*.3 + "px")
    $('.intro-right-lines').css('right', (percent - 50)*-.3 + "px")
    $('.intro-left-lines').css('left', (percent - 50)*.3 + "px")



