#################################
# Settings
#################################
window.pageName = 'song'
window.id = undefined


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
    url: '//api.staging.iing.tw/check_user_voted.json'
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

    $.getJSON '//api.staging.iing.tw/soundclouds/'+window.id+'.json?token=8888', (item) ->
      xx item
      $('.song-title').text item.title
      $('.song-artist').text item.author_name
      $('.song-number').text padLeft(item.id,3)
      $('.song-lyric p').html nl2br(item.lyrics)
      $('.song-intro p').html nl2br(item.desc)
      $('.song-waveform-value').val item.waveform
      $('.vote-button').attr('data-id',item.id)
      $('.play-button').attr('data-trackid',item.track_id)
      $('#nextSong').attr('href','/song/'+item.next_song_id)
      $('.vote-count').text(item.vote_count+' 票')
      $('.fb-share').attr('data-href','https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/'+item.id)

      if item.official_url
        $('.song-intro .song-artist').prepend '<a class="official-link" targe="_blank" href="'+item.official_url+'">Official Link</a>'

      if item.waveform is null
        SC.get '/tracks/'+item.track_id, (track) ->
          xx track
          xx track.waveform_url
          $.getJSON '//waveformjs.org/w?callback=?', { url: track.waveform_url }, (d) ->
            xx d
            syncWaveform(item.id,item.token,d)
            songWaveform = d
            waveform = new Waveform(
              container: $('.waveform-preview').get(0)
              innerColor: 'rgba(0,0,0,.1)'
              data: songWaveform
            )
      else
        songWaveform = waveformStringToArray item.waveform
        waveform = new Waveform(
          container: $('.waveform-preview').get(0)
          innerColor: 'rgba(0,0,0,.1)'
          data: songWaveform
        )
      createWaveform(item.id,item.track_id,songWaveform,'.page')
      $('.page .spinner').remove()
      $('.song-player-container').removeClass 'off'
      $('.song-detail').removeClass 'off'
      $('.page-bottom-illustrator').removeClass 'off'

