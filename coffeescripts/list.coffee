#################################
# Settings
#################################


#################################
# Function
#################################


#################################
# Html pattern
#################################
$songItem = (item) ->
  '<li class="song-item">
    <div class="song-content">
      <a class="song-number" href="/song?no='+item.id+'">'+padLeft(item.id,3)+'</a>
      <a class="song-info" href="/song?no='+item.id+'">
        <div class="song-title">'+item.desc+'</div>
        <div class="song-artist">'+item.author_name+'</div>
      </a>
      <div class="vote-count">票數：'+item.vote_count+'</div>
    </div>
    <div class="song-player">
      <button class="play-button"></button>
      <div class="song-wave">
        <div class="waveform-preview"></div>
        <div class="waveform"></div>
      </div>
    </div>
    <div class="song-tool-buttons">
      <button class="vote-button" type="button" data-id="'+item.id+'">投他一票</button>
      <button class="fb-share">分享</button>
    </div>
  </li>'


#################################
# Document events
#################################
$ ->
  $.getJSON 'http://api.staging.iing.tw/soundclouds.json?token=8888', (r) ->
    i = 0
    for item in r
      if i < 10
        $('.song-list').append $songItem(item)

        waveform = new Waveform(
          container: $('.waveform-preview').last().get(0)
          innerColor: '#F0F0F0'
          data: demoWaveform()
        )
        i++
