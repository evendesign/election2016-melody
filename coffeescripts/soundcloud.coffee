#################################
# Settings
#################################
SC.initialize client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
soundManager = undefined
soundTrack = []
window.getVars = []
window.autoLoop = false
window.autoPlay = false
window.isDesktop = true


#################################
# Html pattern
#################################
$popupAlarmContent = (id) ->
  '<i class="icon-alarm"></i>
  <h2>咦，你今天已經投過囉！</h2>
  <p>每天可以對任一首歌投票一次</p>
  <a class="btn btn_primary" href="https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/'+id+'" target="_blank">分享拉票</a><br>
  <button type="button" class="close-popup">關閉視窗</button>'

$popupSuccessContent = (id) ->
  '<i class="icon-success"></i>
  <h2>恭喜你完成投票！</h2>
  <p>是否將投票的好歌曲分享到臉書？</p>
  <a class="btn btn_primary" href="https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/'+id+'" target="_blank">分享拉票</a><br>
  <button type="button" class="close-popup">關閉視窗</button>'

$popupErrorContent = ->
  '<i class="icon-error"></i>
  <h2>糟糕！投票失敗...</h2>
  <p>請嘗試重新整理頁面</p>
  <button class="btn btn_primary" type="button">再試一次</button><br>
  <button type="button" class="close-popup">關閉視窗</button>'

$popup400ErrorContent = ->
  '<i class="icon-error"></i>
  <h2>嘿，投票還沒開始唷...</h2>
  <p>投票時間 7/2 10:00 ～ 7/6 23:59</p>
  <button type="button" class="close-popup">關閉視窗</button>'

$popupLoginErrorContent = ->
  '<i class="icon-error"></i>
  <h2>糟糕！登入失敗...</h2>
  <p>請嘗試重新整理頁面</p>
  <button class="btn btn_primary" type="button">再試一次</button><br>
  <button type="button" class="close-popup">關閉視窗</button>'

#################################
# Function
#################################
isMobile = ->
  return navigator.userAgent.match(/Android/i) or navigator.userAgent.match(/webOS/i) or navigator.userAgent.match(/iPhone/i) or navigator.userAgent.match(/iPod/i) or navigator.userAgent.match(/iPad/i) or navigator.userAgent.match(/BlackBerry/)

getUrlVars = ->
  vars = []
  hash = undefined
  hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')
  i = 0
  while i < hashes.length
    hash = hashes[i].split('=')
    vars.push hash[0]
    vars[hash[0]] = hash[1]
    i++
  vars

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

voteCheck = (facebook_token,soundcloud_id)->
  $.ajax
    type: 'post'
    dataType: 'json'
    cache: false
    data:
      facebook_token: facebook_token
      soundcloud_id: soundcloud_id
    url: '//api.staging.iing.tw/vote_check.json'
    error: (response) ->
      showPopup $popup400ErrorContent()
    success: (response) ->
      if response.message is true
        vote(facebook_token,soundcloud_id)
      else
        disableVoteButton(soundcloud_id)
        showPopup $popupAlarmContent(soundcloud_id)

vote = (facebook_token,soundcloud_id)->
  xx facebook_token
  xx soundcloud_id
  $.ajax
    type: 'post'
    dataType: 'json'
    cache: false
    data:
      facebook_token: facebook_token
      soundcloud_id: soundcloud_id
    url: '//api.staging.iing.tw/votes.json'
    success: (r) ->
      xx r
      if r.message is 'success'
        showPopup $popupSuccessContent(soundcloud_id)
        disableVoteButton(soundcloud_id)
        $('.song-item-'+soundcloud_id+' .vote-count').text(r.vote_count+' 票')
      else
        showPopup $popupErrorContent()

showPopup = (html) ->
  $('.popup-loading-container').removeClass 'on'
  $('.popup-dialog-inner').html html
  $('.popup-container').addClass 'on'

disableVoteButton = (soundcloud_id) ->
  button = $('.song-item-'+soundcloud_id+' .vote-button')
  if button.hasClass('done') is false
    button.addClass 'done'
    button.text '感謝支持！'

createWaveform = (id,track_id,waveform,selector) ->
  SC.get '/tracks/'+track_id, (track) ->
    # $(selector+' .play-times').text track.playback_count
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
      if window.autoPlay is true and window.isDesktop is true
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
    url: '//api.iing.tw/sync_waveform.json'
    success: (response) ->
      xx response


#################################
# Document events
#################################
$ ->
  if isMobile()
    window.isDesktop = false

  window.getVars = getUrlVars()
  if parseInt(window.getVars['loop']) is 1
    window.autoLoop = true

  $('body').delegate '.vote-button', 'click', ->
    soundcloud_id = $(this).data('id')
    $('.popup-loading-container').addClass 'on'
    FB.getLoginStatus (response) ->
      if response.status is 'connected'
        facebook_token = response.authResponse.accessToken
        voteCheck(facebook_token,soundcloud_id)
      else
        FB.login ((response) ->
          if response.status is 'connected'
            facebook_token = response.authResponse.accessToken
            voteCheck(facebook_token,soundcloud_id)
          else
            showPopup $popupLoginErrorContent()
        ),
          return_scopes: true


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

  $('body').delegate '.close-popup', 'click', ->
    $('.popup-container').removeClass 'on'

  $(document).mouseup (e) ->
    container = $('.popup-dialog-inner')
    if !container.is(e.target) and container.has(e.target).length == 0
      $('.popup-container').removeClass 'on'
