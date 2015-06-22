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
    $.getJSON 'http://api.iing.tw/soundclouds/'+id+'.json?token=8888', (item) ->
      xx item

      $('.song-title').text item.title
      $('.song-artist').text item.author_name
      $('.song-number').text padLeft(item.id,3)
      $('.vote-count span').text item.vote_count
      $('.song-lyric p').html nl2br(item.lyrics)
      $('.song-intro p').html nl2br(item.desc)
      $('.song-waveform-value').val item.waveform
      $('.vote-button').attr('data-id',item.id)
      $('.play-button').attr('data-trackid',item.track_id)
      $('.next-song a').attr('href',item.random_url)
      $('.fb-share').attr('data-href','https://www.facebook.com/sharer/sharer.php?u=http://melody.iing.tw/song/'+item.id)

      if item.official_url
        $('.song-artist').prepend '<a class="official-link" href="'+item.official_url+'">Official Link</a>'

      if item.waveform is null
        SC.get '/tracks/'+item.track_id, (track) ->
          xx track
          xx track.waveform_url
          $.getJSON 'http://waveformjs.org/w?callback=?', { url: track.waveform_url }, (d) ->
            xx d
            syncWaveform(item.id,item.token,d)
            songWaveform = d
            waveform = new Waveform(
              container: $('.waveform-preview').last().get(0)
              innerColor: '#F0F0F0'
              data: songWaveform
            )
      else
        songWaveform = waveformStringToArray item.waveform
        waveform = new Waveform(
          container: $('.waveform-preview').last().get(0)
          innerColor: '#F0F0F0'
          data: songWaveform
        )
  else
    window.location = '/list'
