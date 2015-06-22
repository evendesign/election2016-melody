#################################
# Settings
#################################


#################################
# Function
#################################
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


#################################
# Document events
#################################
$ ->
  vars = getUrlVars()
  if typeof vars.no isnt 'undefined' and parseInt(vars.no) > 0
    id = parseInt(vars.no)
    $.getJSON 'http://api.staging.iing.tw/soundclouds/'+id+'.json?token=8888', (r) ->
      $('.song-title').text r.title
      $('.song-artist').text r.author_name
      $('.song-number').text padLeft(r.id,3)
      $('.vote-count span').text r.vote_count
      $('.song-lyric p').html nl2br(r.lyrics)
      $('.song-intro p').html nl2br(r.desc)
      $('.song-waveform-value').val r.waveform
      $('.vote-button').attr('data-id',r.id)
      $('.play-button').attr('data-trackid',r.track_id)

      songWaveform = waveformStringToArray r.waveform
      waveform = new Waveform(
        container: $('.waveform-preview').last().get(0)
        innerColor: '#F0F0F0'
        data: songWaveform
      )
  else
    window.location = '/list'
