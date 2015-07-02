#################################
# Settings
#################################
window.pageName = 'song'
window.id = undefined
window.item = undefined


#################################
# Function
#################################
checkUserVoted = (facebook_token)->
  $.ajax
    type: 'post'
    dataType: 'json'
    cache: false
    data:
      facebook_token: facebook_token
    url: '//api.iing.tw/check_user_voted.json'
    success: (response) ->
      for id in response.data
        if id is window.id
          disableVoteButton()

disableVoteButton =  ->
  button = $('.vote-button')
  if button.hasClass('done') is false
    button.addClass 'done'
    button.text '感謝支持！'


#################################
# Document events
#################################
$(document).on 'fbload', ->
  FB.getLoginStatus (response) ->
    xx response
    if response.status is 'connected'
      checkUserVoted response.authResponse.accessToken

$ ->
  xx window.getVars
  if parseInt(window.getVars['autoplay']) is 1
    window.autoPlay = true

  url = window.location.href
  if url.indexOf('?') > 0 then url = url.split('?')[0]
  if url.indexOf('#') > 0 then url = url.split('#')[0]
  explode = url.split('/')
  song_no = explode[4]
  if typeof song_no isnt 'undefined' and parseInt(song_no) > 0
    window.id = parseInt(song_no)

    $.getJSON '//api.iing.tw/soundclouds/'+window.id+'.json?token=8888', (item) ->
      xx item
      window.item = item
      $('.song-title').text item.title
      $('.song-artist').text item.author_name
      $('.song-number').text padLeft(item.id,3)
      $('.song-lyric p').html nl2br(item.lyrics)
      $('.song-intro p').html nl2br(item.desc)
      $('.song-waveform-value').val item.waveform
      $('.vote-button').attr('data-id',item.id)
      $('.play-button').attr('data-id',item.id).attr('data-trackid',item.track_id)
      $('#nextSong').attr('href','/song/'+item.next_song_id+'/?shuffle=1')
      $('.vote-count').text(item.vote_count+' 票')
      $('.fb-share').attr('data-href','https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/'+item.id)

      if item.official_url
        $('.song-intro .song-artist').prepend '<a class="official-link" targe="_blank" href="'+item.official_url+'">Official Link</a>'

      songWaveform = waveformStringToArray item.waveform
      waveform = new Waveform(
        container: $('.waveform-preview').get(0)
        innerColor: 'rgba(0,0,0,.1)'
        data: songWaveform
      )

      if window.shuffle and window.isDesktop
        $('.play-button').addClass 'loading'
        createWaveform(item.id,item.track_id,songWaveform,'.song-player')

      if window.isDesktop is false
        createWaveform(item.id,item.track_id,songWaveform,'.song-player')

      $('.page .spinner').remove()
      $('.song-detail').removeClass 'off'
      $('.song-player-container').removeClass 'off'
      $('.page-bottom-illustrator').removeClass 'off'

