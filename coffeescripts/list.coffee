#################################
# Settings
#################################
window.list = []
window.pageNumber = 0
window.perPage = 100

#################################
# Function
#################################
appendList = (page) ->
  start = page*window.perPage
  end = (page + 1)*window.perPage

  if end > window.list.length
    $('.list-more-song').remove()

  array = window.list.slice(start,end)
  for item in array
    $('.song-list').append $songItem(item)
    if item.waveform is null
      SC.get '/tracks/'+item.track_id, (track) ->
        $.getJSON 'http://waveformjs.org/w?callback=?', { url: track.waveform_url }, (d) ->
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
    createWaveform(item.id,item.track_id,songWaveform,'.song-item-'+item.id)
  window.pageNumber++

songFilter = (filter) ->
  $('.song-list').find(".song-string:not(:Contains(" + filter + "))").parents('li').hide()
  $('.song-list').find(".song-string:contains(" + filter + ")").parents('li').show()


#################################
# Html pattern
#################################
$songItem = (item) ->
  '<li class="song-item song-item-'+item.id+'">
    <div class="song-string">' +
      padLeft(item.id,3) + ','+
      item.id + ','+
      item.title + ','+
      item.desc + ','+
      item.author_name + '
    </div>
    <div class="song-content">
      <a href="/song/'+item.id+'">
        <div class="song-number">'+padLeft(item.id,3)+'</div>
        <div class="song-info">
          <div class="song-title">'+item.title+'</div>
          <div class="song-artist">'+item.author_name+'</div>
        </div>
      </a>
      <!--<div class="vote-count">票數：'+item.vote_count+'</div>-->
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
      <!--<button class="vote-button" type="button" data-id="'+item.id+'">投他一票</button>-->
      <button class="fb-share" type="button" data-href="https://www.facebook.com/sharer/sharer.php?u=http://melody.iing.tw/song/'+item.id+'">分享</button>
    </div>
  </li>'


#################################
# Document events
#################################
$ ->
  $.getJSON 'http://api.iing.tw/soundclouds.json?token=8888', (r) ->
    xx r

    window.list = r
    appendList 0

  $('body').delegate '.list-more-song', 'click', ->
    appendList window.pageNumber

  # $('body').delegate '.header-search .submit', 'click', ->
  #   filter = $('.search-string').val()
  #   if filter
  #     songFilter filter
  #   else
  #     $('.song-list li').show()

  $('body').delegate '.search-string', 'keyup', ->
    filter = $(this).val()
    if filter
      songFilter filter
    else
      $('.song-list li').show()
