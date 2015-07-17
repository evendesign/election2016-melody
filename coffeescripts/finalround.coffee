#################################
# Settings
#################################
window.pageName = 'list'
window.list = []
window.pageNumber = 1
window.perPage = 200
window.append = false
window.waveform = undefined
window.appendFinish =false


#################################
# Function
#################################


#################################
# Html pattern
#################################
$songItem = (i,item) ->
  # xx i
  # i++
  # if i is 1
  #   num = '1st'
  # else if i is 2
  #   num = '2nd'
  # else if i is 3
  #   num = '3rd'
  # else
  #   num = i+'th'

  num = item.id

  '<li class="song-item song-item-'+item.id+'" data-id="'+item.id+'" data-vote="'+item.vote_count+'">
    <div class="song-content">
      <a href="/song/'+item.id+'">
        <div class="song-number">'+num+'</div>
        <div class="song-info">
          <div class="song-title">'+item.title+'</div>
          <div class="song-artist">'+item.author_name+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br class="mobile-wrap"><!--播放次數: <span class="play-times"></span>--></div>
        </div>
      </a>
    </div>
    <div class="song-player">
      <button class="play-button" data-id="'+item.id+'" data-trackid="'+item.track_id+'" data-sid=""></button>
      <div class="song-wave">
        <div class="waveform-preview"></div>
        <div class="waveform"></div>
        <input type="hidden" class="song-waveform-value" value="'+item.waveform+'">
      </div>
    </div>
    <div class="song-tool-buttons">
      <div class="vote-button-container">
        <div class="vote-count">'+item.vote_count+' 票</div>
      </div>
      <button class="fb-share" type="button" data-href="https://www.facebook.com/sharer/sharer.php?u=http://melody.iing.tw/song/'+item.id+'">分享</button>
    </div>
  </li>'


#################################
# Document events
#################################
$ ->
  if window.location.hash isnt ''
    hash  = window.location.hash.toLowerCase()
    xx hash
    if hash is '#asc'
      window.hash = 'asc'
    else if hash is '#desc'
      window.hash = 'desc'
    else if hash is '#ranking'
      window.hash = 'ranking'
    else
      window.hash = 'ranking'
  else
    window.hash = 'ranking'

  setLoadingTime()
  $.getJSON '/json/soundclouds.finalround.json', (r) ->
    xx 'api done'
    # r = r.slice().sort (a, b) ->
    #   return b.vote_count - a.vote_count
    window.list = r
    window.loading = true
    $('.song-list').addClass 'loading'

    i = 0
    j = 0
    for item in window.list
      if item.winners
        $('.song-list').append $songItem(j,item)
        j++
        if j == 10
          $('.song-list').append('<p class="winners">以及三首由評審推薦入選的歌曲</p>')
      i++

      if i is window.list.length
        $('.search-bar').removeClass 'off'
        $('.song-list').removeClass 'loading'
        $('.page .spinner').remove()
        window.appendFinish = true
        stopLoadingTime()


  appendStateCheckInterval = setInterval ->
    xx 'append waiting'
    if window.appendFinish
      clearInterval(appendStateCheckInterval)
      if window.isDesktop
        $.getJSON '/json/waveform.json', (r) ->
          window.waveform = r
          for item in window.list
            if item.winners
              waveformItem = getItemById(window.waveform, item.id)
              songWaveform = waveformStringToArray waveformItem.waveform
              waveform = new Waveform(
                container: $('.song-item-'+item.id+' .waveform-preview').get(0)
                innerColor: 'rgba(0,0,0,.1)'
                data: songWaveform
              )
      else
        for item in window.list
          if item.winners
            songWaveform = [1,1,1,1,1]
            waveform = new Waveform(
              container: $('.song-item-'+item.id+' .waveform-preview').get(0)
              innerColor: 'rgba(0,0,0,.1)'
              data: songWaveform
            )
            $('.song-item-'+item.id+' .play-button').addClass 'loading'
            createWaveform(item.id,item.track_id,songWaveform,'.song-item-'+item.id)
  , 100
