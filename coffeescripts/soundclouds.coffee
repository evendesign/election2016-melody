#################################
# Settings
#################################
SC.initialize client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
soundManager = undefined
soundTrack = []
window.getVars = []
window.autoLoop = false
window.autoPlay = false
window.shuffle = false
window.isDesktop = true
window.soundcloudId = undefined
window.userVoted = []
window.loadingTime = undefined


#################################
# Html pattern
#################################
$popupLoginContent = (id) ->
  '<i class="icon-alarm"></i>
  <h2>請先登入臉書帳號</h2>
  <p>投票會需要你的臉書帳號</p>
  <button class="btn btn_primary login-button">以 Facebook 登入投票</button><br>
  <button type="button" class="close-popup">算了</button>'

$popupAlarmContent = (id) ->
  '<i class="icon-alarm"></i>
  <h2>咦，你今天已經投過囉！</h2>
  <p>每天可以對任一首歌投票一次</p>
  <a class="btn btn_primary" href="https://www.facebook.com/sharer/sharer.php?u=http://melody.iing.tw/song/'+id+'" target="_blank">分享拉票</a><br>
  <button type="button" class="close-popup">關閉視窗</button>'


$popupEventCloseContent = ->
  '<i class="icon-alarm"></i>
  <h2>投票時間已過</h2>
  <p>7/9 將進行決選，敬請期待</p>
  <button type="button" class="close-popup">關閉視窗</button>'

$popupSuccessContent = (id) ->
  '<i class="icon-success"></i>
  <h2>恭喜你完成投票！</h2>
  <p>是否將投票的好歌曲分享到臉書？</p>
  <a class="btn btn_primary" href="https://www.facebook.com/sharer/sharer.php?u=http://melody.iing.tw/song/'+id+'" target="_blank">分享拉票</a><br>
  <button type="button" class="close-popup">關閉視窗</button>'

$popupErrorContent = ->
  '<i class="icon-error"></i>
  <h2>糟糕！投票失敗...</h2>
  <p>請嘗試重新整理頁面</p>
  <button type="button" class="close-popup">關閉視窗</button>'

$popup401ErrorContent = ->
  '<i class="icon-error"></i>
  <h2>糟糕，出錯了...</h2>
  <p>請嘗試重新整理頁面</p>
  <button type="button" class="close-popup">關閉視窗</button>'

$popup429ErrorContent = ->
  '<i class="icon-error"></i>
  <h2>目前網路壅塞</h2>
  <p>請晚一點再來播放</p>
  <button type="button" class="close-popup">關閉視窗</button>'

$popupLoginErrorContent = ->
  '<i class="icon-error"></i>
  <h2>糟糕！登入失敗...</h2>
  <p>請嘗試重新整理頁面</p>
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

# voteCheck = (facebook_token,soundcloud_id)->
#   xx 'vote check'
#   $.ajax
#     type: 'post'
#     dataType: 'json'
#     cache: false
#     data:
#       facebook_token: facebook_token
#       soundcloud_id: soundcloud_id
#     url: '//api.iing.tw/vote_check.json'
#     error: (r) ->
#       xx r
#       if r.status is 400
#         showPopup $popupEventCloseContent()
#       else
#         showPopup $popup401ErrorContent()
#     success: (r) ->
#       xx r
#       if r.message is true
#         vote(facebook_token,soundcloud_id)
#       else
#         disableVoteButton(soundcloud_id)
#         showPopup $popupAlarmContent(soundcloud_id)

# vote = (facebook_token,soundcloud_id)->
#   xx facebook_token
#   xx soundcloud_id
#   $.ajax
#     type: 'post'
#     dataType: 'json'
#     cache: false
#     data:
#       facebook_token: facebook_token
#       soundcloud_id: soundcloud_id
#     url: '//api.iing.tw/votes.json'
#     error: (r) ->
#       xx r
#       if r.status is 400
#         showPopup $popupEventCloseContent()
#       else
#         showPopup $popup401ErrorContent()
#     success: (r) ->
#       xx r
#       if r.message is 'success'
#         showPopup $popupSuccessContent(soundcloud_id)
#         disableVoteButton(soundcloud_id)
#         if window.pageName is 'list'
#           $('.song-item-'+soundcloud_id+' .vote-count').text(r.vote_count+' 票')
#         else
#           $('.vote-count').text(r.vote_count+' 票')
#       else
#         showPopup $popupErrorContent()

showPopup = (html) ->
  stopLoadingTime()
  popup = $('.popup-container')
  loading = $('.popup-loading-container')
  if popup.hasClass('on') is true
    popup.removeClass 'on'
  if loading.hasClass('on') is true
    loading.removeClass 'on'
  $('.popup-dialog-inner').html html
  popup.addClass 'on'

showPopupLoading = ->
  popup = $('.popup-container')
  loading = $('.popup-loading-container')
  if popup.hasClass('on') is true
    popup.removeClass 'on'
  loading.addClass 'on'

createWaveform = (id,track_id,waveform,selector,autoplay) ->
  if $(selector+' .waveform canvas').length <= 0
    SC.get '/tracks/'+track_id, (track) ->

      xx 'get track success'
      # $(selector+' .play-times').text track.playback_count
      soundTrack[track_id] = track
      sound = undefined
      $(selector+' .waveform-preview canvas').remove()
      waveform = new Waveform(
        container: $(selector+' .waveform').get(0)
        innerColor: 'rgba(0,0,0,.1)'
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
          'rgba(0,0,0,.2)'
        else
          'rgba(0,0,0,.1)'

      SC.stream '/tracks/'+track_id, {
        whileloading: waveform.redraw
        whileplaying: waveform.redraw
        volume: 100
        useHTML5Audio: true
        preferFlash: false
      }, (s) ->

        xx 'stream prepared'
        if window.isDesktop is false
          xx 'remove loading'
          $(selector+' .play-button').removeClass 'loading'

        $(selector+' .play-button').attr('data-sid',s.sID)
        sound = s
        if window.isDesktop
          if window.autoPlay or window.shuffle or autoplay
            xx 'auto play starting'
            playSong = (element,sid) ->
              soundManager.play sid,
                onload: (state) ->
                  if state is false
                    showPopup $popup429ErrorContent()
                    element.addClass 'play-button'
                    element.removeClass 'pause-button'
                onplay: ->
                  xx 'play'
                  element.addClass 'pause-button'
                  element.removeClass 'loading'
                  element.removeClass 'play-button'
                onresume: ->
                  xx 'resume'
                  element.addClass 'pause-button'
                  element.removeClass 'loading'
                  element.removeClass 'play-button'
                onfinish: ->
                  xx 'song finish'
                  if window.autoLoop
                    playSong(element,sid)
                  else if window.shuffle and window.pageName is 'song'
                    window.location = $('#nextSong').attr('href')
                  else
                    element.addClass 'play-button'
                    element.removeClass 'pause-button'
            if window.pageName is 'list'
              playSong($('.play-button.loading'), s.sID)
            else
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

getItemById = (array, id) ->
  i = 0
  while i < array.length
    if array[i].id is id
      return array[i]
    i++

setLoadingTime = ->
  window.loadingTime = Date.now()
  loadingStateCheckInterval = setInterval ->
    if window.loadingTime is undefined
      clearInterval(loadingStateCheckInterval)
    else
      # xx Date.now() - window.loadingTime
      if Date.now() - window.loadingTime >= 5000
        if $('.too-many-people-is-here').hasClass('on') is false
          $('.too-many-people-is-here').addClass 'on'
  , 500

stopLoadingTime = ->
  window.loadingTime = undefined
  $('.too-many-people-is-here').removeClass 'on'


#################################
# Document events
#################################
$ ->
  if isMobile()
    xx 'is mobile'
    window.isDesktop = false

  window.getVars = getUrlVars()
  if parseInt(window.getVars['loop']) is 1
    window.autoLoop = true

  if parseInt(window.getVars['shuffle']) is 1
    window.shuffle = true

  # $('body').delegate '.vote-button', 'click', ->
  #   xx 'vote button clicked'
  #   if window.inInterval is false
  #     showPopup $popupEventCloseContent
  #   else
  #     setLoadingTime()
  #     soundcloud_id = $(this).data('id')
  #     showPopupLoading()
  #     FB.getLoginStatus (response) ->
  #       xx response
  #       if response.status is 'connected'
  #         facebook_token = response.authResponse.accessToken
  #         voteCheck(facebook_token,soundcloud_id)
  #       else
  #         window.soundcloudId = soundcloud_id
  #         showPopup $popupLoginContent()

  # $('body').delegate '.login-button', 'click', ->
  #   xx 'login button clicked'
  #   showPopupLoading()
  #   FB.login ((response) ->
  #     if response.status is 'connected'
  #       facebook_token = response.authResponse.accessToken
  #       xx facebook_token
  #       xx window.soundcloudId
  #       voteCheck(facebook_token,window.soundcloudId)
  #     else
  #       showPopup $popupLoginErrorContent()
  #     ),
  #       return_scopes: true

  $('body').delegate '.play-button', 'click', ->
    xx 'play'
    $('.play-button').removeClass 'loading'
    $(this).addClass 'loading'
    if soundManager isnt undefined
      soundManager.pauseAll()
      $('.pause-button').addClass 'play-button'
      $('.play-button').removeClass 'pause-button'

    if $(this).parents('.song-player').find('.waveform').find('canvas').length <= 0
      xx 'no canvas'
      xx songid = $(this).data 'id'
      xx trackid = $(this).data 'trackid'
      if window.pageName is 'list'
        item = getItemById(window.list, songid)

        if window.isDesktop
          waveformItem = getItemById(window.waveform, songid)
          waveform = waveformStringToArray waveformItem.waveform
        else
          waveform = [1,1,1,1,1]

        createWaveform(songid, trackid, waveform, '.song-item-'+songid, true)
      else if window.pageName is 'song'
        waveform = waveformStringToArray window.item.waveform
        createWaveform(songid, trackid, waveform, '.page', true)
    else
      xx 'canvas exist'
      _this = $(this)
      sid = _this.data 'sid'
      playSong = (element,sid) ->
        soundManager.play sid,
          onload: (state) ->
            if state is false
              showPopup $popup429ErrorContent()
              element.addClass 'play-button'
              element.removeClass 'pause-button'
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
