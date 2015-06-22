#################################
# Settings
#################################
SC.initialize client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
soundManager = undefined

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
# Html pattern
#################################


#################################
# Document events
#################################
$ ->

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
      # $('.waveform').find('canvas').remove()
      $('.pause-button').addClass 'play-button'
      $('.play-button').removeClass 'pause-button'

    _this = $(this)
    _parent = _this.parents('.song-player')
    _waveform = waveformStringToArray(_parent.find('.song-waveform-value').val())
    _trackid = _this.data('trackid')
    _this.addClass 'loading'

    if _parent.find('.waveform').find('canvas').length < 1
      SC.get '/tracks/'+_trackid, (track) ->
        sound = undefined
        waveform = new Waveform(
          container: _parent.find('.waveform').get(0)
          innerColor: '#F0F0F0'
          data: _waveform
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

        SC.stream '/tracks/'+_trackid, {
          whileloading: waveform.redraw
          whileplaying: waveform.redraw
          volume: 100
        }, (s) ->
          _this.attr('data-sid',s.sID)
          sound = s
          sound.play()
          _this.removeClass 'loading'
          _this.removeClass 'play-button'
          _this.addClass 'pause-button'
    else
      sid = _this.data 'sid'
      soundManager.play(sid)
      _this.removeClass 'loading'
      _this.removeClass 'play-button'
      _this.addClass 'pause-button'


  $('body').delegate '.pause-button', 'click', ->
    soundManager.pauseAll()
    # $('.waveform').find('canvas').remove()
    $(this).removeClass 'pause-button'
    $(this).addClass 'play-button'


  $('body').delegate '.fb-share', 'click', ->
    href = $(this).data('href')
    window.open(href)
