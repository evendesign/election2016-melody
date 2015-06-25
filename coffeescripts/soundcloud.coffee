#################################
# Settings
#################################
SC.initialize client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
soundManager = undefined
soundTrack = []
window.getVars = []
window.autoLoop = false
window.autoPlay = false


#################################
# Function
#################################
padLeft = (str, length) ->
  if str.toString().length >= length
    str
  else
    padLeft('0' + str, length)

nl2br = (str, is_xhtml) ->
  breakTag = if is_xhtml or typeof is_xhtml == 'undefined' then '<br ' + '/>' else '<br>'
  (str + '').replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2'

waveformStringToArray = (str) ->
  str.split(',').map(Number)

# voteCheck = (facebook_token,soundcloud_id)->
#   xx facebook_token
#   xx soundcloud_id
#   $.ajax
#     type: 'post'
#     dataType: 'json'
#     cache: false
#     data:
#       facebook_token: facebook_token
#       soundcloud_id: soundcloud_id
#     url: 'http://api.iing.tw/vote_check.json'
#     success: (response) ->
#       if response.message is true
#         vote(facebook_token,soundcloud_id)
#       else
#         alert '您已完成投票（每人每日每首歌可投票乙次）'

# vote = (facebook_token,soundcloud_id)->
#   $.ajax
#     type: 'post'
#     dataType: 'json'
#     cache: false
#     data:
#       facebook_token: facebook_token
#       soundcloud_id: soundcloud_id
#     url: 'http://api.iing.tw/vote.json'
#     success: (response) ->
#       xx response

createWaveform = (id,track_id,waveform,selector) ->
  SC.get '/tracks/'+track_id, (track) ->
    $(selector+' .play-times').text track.playback_count
    soundTrack[track_id] = track
    sound = undefined
    waveform = new Waveform(
      container: $(selector+' .waveform').get(0)
      innerColor: '#F0F0F0'
      data: waveform
    )
    ctx = waveform.context
    gradient = ctx.createLinearGradient(0, 0, 0, waveform.height)
    gradient.addColorStop 0.0, '#E4E779'
    gradient.addColorStop 1.0, '#57C0C7'

    waveform.innerColor = (x) ->
      if sound and x < sound.position / sound.durationEstimate
        gradient
      else if sound and x < sound.bytesLoaded / sound.bytesTotal
        '#D1D1D1'
      else
        '#F0F0F0'

    SC.stream '/tracks/'+track_id, {
      whileloading: waveform.redraw
      whileplaying: waveform.redraw
      volume: 100
      useHTML5Audio: true
      preferFlash: false
    }, (s) ->
      $(selector+' .play-button').attr('data-sid',s.sID)
      sound = s
      if window.autoPlay is true
        xx 'auto play'
        playSong = (element,sid) ->
          soundManager.play sid,
            onplay: ->
              element.addClass 'pause-button'
              element.removeClass 'loading'
              element.removeClass 'play-button'
            onresume: ->
              element.addClass 'pause-button'
              element.removeClass 'loading'
              element.removeClass 'play-button'
            onfinish: ->
              xx 'song finish'
              if window.autoLoop
                playSong(element,sid)
              else
                element.addClass 'play-button'
                element.removeClass 'pause-button'
        playSong($('.play-button'), s.sID)


syncWaveform = (id,token,data) ->
  $.ajax
    type: 'post'
    dataType: 'json'
    cache: false
    data:
      id: id
      token: token
      data: data.toString()
    url: 'http://api.iing.tw/sync_waveform.json'
    success: (response) ->
      xx response


#################################
# Document events
#################################
$ ->
  window.getVars = getUrlVars()
  if parseInt(window.getVars['loop']) is 1
    window.autoLoop = true

  # $('body').delegate '.vote-button', 'click', ->
  #   soundcloud_id = $(this).data('id')
  #   FB.getLoginStatus (response) ->
  #     if response.status is 'connected'
  #       facebook_token = response.authResponse.accessToken
  #       voteCheck(facebook_token,soundcloud_id)
  #     else
  #       FB.login ((response) ->
  #         if response.status is 'connected'
  #           facebook_token = response.authResponse.accessToken
  #           voteCheck(facebook_token,soundcloud_id)
  #         else
  #           xx 'Login failed'
  #       ),
  #         return_scopes: true


  $('body').delegate '.play-button', 'click', ->
    if soundManager isnt undefined
      soundManager.pauseAll()
      $('.pause-button').addClass 'play-button'
      $('.play-button').removeClass 'pause-button'

    _this = $(this)
    _this.addClass 'loading'
    sid = _this.data 'sid'

    playSong = (element,sid) ->
      soundManager.play sid,
        onplay: ->
          element.addClass 'pause-button'
          element.removeClass 'loading'
          element.removeClass 'play-button'
        onresume: ->
          element.addClass 'pause-button'
          element.removeClass 'loading'
          element.removeClass 'play-button'
        onfinish: ->
          xx 'song finish'
          if window.autoLoop
            playSong(element,sid)
          else
            element.addClass 'play-button'
            element.removeClass 'pause-button'
    playSong(_this, sid)


  $('body').delegate '.pause-button', 'click', ->
    soundManager.pauseAll()
    $(this).removeClass 'pause-button'
    $(this).addClass 'play-button'


  $('body').delegate '.fb-share', 'click', ->
    href = $(this).data('href')
    window.open(href)

  $('body').delegate '.waveform', 'click', (e)->
    button = $(this).parents('.song-player').find('button')
    sid = button.data('sid')
    trackid = button.data('trackid')
    currentTrack = soundTrack[trackid]
    duration = currentTrack.duration
    position = (e.pageX - $(this).offset().left) / $(this).width()
    target = Math.floor(duration*position)
    soundManager.setPosition(sid,target)
