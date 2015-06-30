#################################
# Settings
#################################
window.pageName = 'list'
window.list = []
window.pageNumber = 1
window.perPage = 20
window.append = false
countdown = Date.now()
currentTime = Date.now()

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
  if item.id%3 is '########' then top20 = ' top20'
  else top20 = ''
  '<li class="song-item song-item-'+item.id+display+top20+'" data-id="'+item.id+'" data-vote="'+item.vote_count+'">
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
          <div class="song-artist">'+item.author_name+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br class="mobile-wrap"><!--播放次數: <span class="play-times"></span>--></div>
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
        <button class="vote-button" type="button" data-id="'+item.id+'"><i class="icon-vote"></i>投他一票</button>
        <div class="vote-count">'+item.vote_count+' 票</div>
      </div>
      <button class="fb-share" type="button" data-href="https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/'+item.id+'">分享</button>
    </div>
  </li>'


#################################
# Document events
#################################
$ ->
  $.getJSON '//api.iing.tw/soundclouds.json?token=8888', (r) ->
    r = r.slice().sort (a, b) ->
      return a.id - b.id
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
          $.getJSON '//waveformjs.org/w?callback=?', { url: track.waveform_url }, (d) ->
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

  $(window).scroll (event) ->
    scroll = $(window).scrollTop()
    height = $(document).height()
    if scroll > height * 0.8 and window.append is false and $('.list-more-song').length > 0
      window.append = true
      i = window.pageNumber * window.perPage
      while i < (window.pageNumber+1) * window.perPage
        $('.song-item:eq('+i+')').removeClass 'hide'
        i++
      window.append = false
      window.pageNumber++
      if $('.song-item.hide').length is 0
        $('.list-more-song').remove()

  $('body').delegate '.search-string', 'keydown', ->
    countdown = Date.now()

  $('body').delegate '.search-string', 'keyup', ->
    filter = ($(this).val()).toLowerCase()
    setTimeout (->
      currentTime = Date.now()
      if currentTime - countdown >= 490
        $('.no-result-container').removeClass 'on'
        if filter
          $('body').addClass 'searching'
          songFilter filter
        else
          $('body').removeClass 'searching'
          $('.song-list li').show()

        setInterval (->
          if $('.song-list li').filter(':visible').size() is 0
            $('.no-result-container').addClass 'on'
        ), 500
    ), 500

  $('body').delegate '#listSorting', 'change', ->
    value = parseInt($(this).val())
    if value is 1
      tinysort('ul.song-list>li',{data:'id',order:'asc'})
    else if value is 2
      tinysort('ul.song-list>li',{data:'id',order:'desc'})
    else if value is 3
      tinysort('ul.song-list>li',{data:'vote',order:'desc'})
