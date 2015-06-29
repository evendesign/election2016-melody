#################################
# Settings
#################################
window.pageName = 'list'
window.list = []
window.pageNumber = 1
window.perPage = 5

#################################
# Function
#################################
songFilter = (filter) ->
  $('.song-list').find(".song-string:not(:Contains(" + filter + "))").parents('li').hide()
  $('.song-list').find(".song-string:contains(" + filter + ")").parents('li').show()


#################################
# Html pattern
#################################
$songItem = (item,display) ->
  '<li class="song-item song-item-'+item.id+display+'">
    <div class="song-string">' +
      padLeft(item.id,3) + ','+
      item.id + ','+
      item.title.toLowerCase() + ','+
      item.desc.toLowerCase() + ','+
      item.author_name.toLowerCase() + '
    </div>
    <div class="song-content">
      <a href="/song/'+item.id+'">
        <div class="song-number">'+padLeft(item.id,3)+'</div>
        <div class="song-info">
          <div class="song-title">'+item.title+'</div>
          <div class="song-artist">'+item.author_name+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br class="mobile-wrap">播放次數: <span class="play-times"></span></div>
        </div>
      </a>
    </div>
    <div class="song-player">
      <button class="play-button" data-trackid="'+item.track_id+'" data-sid=""></button>
      <div class="song-wave">
        <div class="waveform-preview"></div>
        <div class="waveform"></div>
        <input type="hidden" class="song-waveform-value" value="'+item.waveform+'">
      </div>
    </div>
    <div class="song-tool-buttons">
      <div class="vote-button-container">
        <button class="vote-button" type="button" data-id="'+item.id+'">投他一票</button>
        <div class="vote-count">'+item.vote_count+' 票</div>
      </div>
      <button class="fb-share" type="button" data-href="https://www.facebook.com/sharer/sharer.php?u=http://melody.iing.tw/song/'+item.id+'">分享</button>
    </div>
  </li>'


#################################
# Document events
#################################
$ ->
  $.getJSON 'http://api.staging.iing.tw/soundclouds.json?token=8888', (r) ->
    xx r
    window.list = r
    window.loading = true
    $('.song-list').addClass 'loading'
    i = 0
    for item in window.list
      if i > window.perPage - 1
        display = ' hide'
      else
        display = ''

      $('.song-list').append $songItem(item, display)

      if item.waveform is null
        SC.get '/tracks/'+item.track_id, (track) ->
          $.getJSON 'http://waveformjs.org/w?callback=?', { url: track.waveform_url }, (d) ->
            syncWaveform(item.id,item.token,d)
            songWaveform = d
            waveform = new Waveform(
              container: $('.song-item-'+item.id+' .waveform-preview').get(0)
              innerColor: '#F0F0F0'
              data: songWaveform
            )
      else
        songWaveform = waveformStringToArray item.waveform
        waveform = new Waveform(
          container: $('.song-item-'+item.id+' .waveform-preview').get(0)
          innerColor: '#F0F0F0'
          data: songWaveform
        )
      createWaveform(item.id,item.track_id,songWaveform,'.song-item-'+item.id)
      i++
      if i is window.list.length
        $('.song-list').removeClass 'loading'

  $('body').delegate '.list-more-song', 'click', ->
    i = window.pageNumber * window.perPage
    while i < (window.pageNumber+1) * window.perPage
      $('.song-item:eq('+i+')').removeClass 'hide'
      i++
    window.pageNumber++

    if $('.song-item.hide').length is 0
      $('.list-more-song').remove()


  # $('body').delegate '.header-search .submit', 'click', ->
  #   filter = $('.search-string').val()
  #   if filter
  #     songFilter filter
  #   else
  #     $('.song-list li').show()

  $('body').delegate '.search-string', 'keyup', ->
    filter = $(this).val()
    if filter
      $('body').addClass 'searching'
      songFilter filter.toLowerCase()
    else
      $('body').removeClass 'searching'
      $('.song-list li').show()
