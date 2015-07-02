#################################
# Settings
#################################
window.pageName = 'list'
window.list = []
window.pageNumber = 1
window.perPage = 200
window.append = false
window.hash = 'asc'
countdown = Date.now()
currentTime = Date.now()

#################################
# Function
#################################
songFilter = (filter) ->
  $('.song-list').find(".song-string:not(:Contains(" + filter + "))").parents('li').hide()
  $('.song-list').find(".song-string:contains(" + filter + ")").parents('li').show()

checkUserVoted = (facebook_token)->
  $.ajax
    type: 'post'
    dataType: 'json'
    cache: false
    data:
      facebook_token: facebook_token
    url: '//api.iing.tw/check_user_voted.json'
    success: (response) ->
      window.userVoted = response.data
      for id in window.userVoted
        disableVoteButton id

disableVoteButton = (soundcloud_id) ->
  button = $('.song-item-'+soundcloud_id+' .vote-button')
  if button.hasClass('done') is false
    button.addClass 'done'
    button.text '感謝支持！'


#################################
# Html pattern
#################################
$songItem = (item,display) ->
  if item.winners isnt undefined and item.winners is true then top20 = ' top20'
  else if item.top20 isnt undefined and item.top20 is true then top20 = ' top20'
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
      <button class="play-button" data-id="'+item.id+'" data-trackid="'+item.track_id+'" data-sid=""></button>
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

$(document).on 'fbload', ->
  FB.getLoginStatus (response) ->
    xx response
    if response.status is 'connected'
      checkUserVoted response.authResponse.accessToken

$ ->
  if window.location.hash isnt ''
    hash  = window.location.hash.toLowerCase()
    xx hash
    if hash is '#asc'
      window.hash = 'asc'
    if hash is '#desc'
      window.hash = 'desc'
    else if hash is '#ranking'
      window.hash = 'ranking'
    else
      window.hash = 'asc'
  else
    window.hash = 'asc'

  setLoadingTime()
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

      songWaveform = waveformStringToArray item.waveform
      waveform = new Waveform(
        container: $('.song-item-'+item.id+' .waveform-preview').get(0)
        innerColor: 'rgba(0,0,0,.1)'
        data: songWaveform
      )
      if window.isDesktop is false
        $('.song-item-'+item.id+' .play-button').addClass 'loading'
        createWaveform(item.id,item.track_id,songWaveform,'.song-item-'+item.id)
      i++
      if i is window.list.length
        xx window.hash
        if window.hash is 'asc'
          $('#listSorting').val(1)
          tinysort('ul.song-list>li',{data:'id',order:'asc'})
        else if window.hash is 'desc'
          $('#listSorting').val(2)
          tinysort('ul.song-list>li',{data:'id',order:'desc'})
        else if window.hash is 'ranking'
          $('#listSorting').val(3)
          tinysort('ul.song-list>li',{data:'vote',order:'desc'})

        $('.search-bar').removeClass 'off'
        $('.song-list').removeClass 'loading'
        $('.page .spinner').remove()
        stopLoadingTime()

  # $('body').delegate '.list-more-song', 'click', ->
  #   i = window.pageNumber * window.perPage
  #   while i < (window.pageNumber+1) * window.perPage
  #     $('.song-item:eq('+i+')').removeClass 'hide'
  #     i++
  #   window.pageNumber++
  #   if $('.song-item.hide').length is 0
  #     $('.list-more-song').remove()

  # $(window).scroll (event) ->
  #   xx scroll = $(window).scrollTop()
  #   xx height = $(document).height()
  #   if scroll > height * 0.5 and window.append is false and $('.list-more-song').length > 0
  #     xx 'list appending'
  #     window.append = true
  #     i = window.pageNumber * window.perPage
  #     while i < (window.pageNumber+1) * window.perPage
  #       $('.song-item:eq('+i+')').removeClass 'hide'
  #       i++
  #     window.append = false
  #     window.pageNumber++
  #     if $('.song-item.hide').length is 0
  #       $('.list-more-song').remove()

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
      window.location.hash = '#asc'
      tinysort('ul.song-list>li',{data:'id',order:'asc'})
    else if value is 2
      window.location.hash = '#desc'
      tinysort('ul.song-list>li',{data:'id',order:'desc'})
    else if value is 3
      window.location.hash = '#ranking'
      tinysort('ul.song-list>li',{data:'vote',order:'desc'})
