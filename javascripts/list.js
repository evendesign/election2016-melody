var $songItem, countdown, currentTime, songFilter;

window.pageName = 'list';

window.list = [];

window.pageNumber = 1;

window.perPage = 20;

window.append = false;

countdown = Date.now();

currentTime = Date.now();

songFilter = function(filter) {
  $('.song-list').find(".song-string:not(:Contains(" + filter + "))").parents('li').hide();
  return $('.song-list').find(".song-string:contains(" + filter + ")").parents('li').show();
};

$songItem = function(item, display) {
  var top20;

  if (item.id % 3 === '########') {
    top20 = ' top20';
  } else {
    top20 = '';
  }
  return '<li class="song-item song-item-' + item.id + display + top20 + '" data-id="' + item.id + '" data-vote="' + item.vote_count + '">\
    <div class="song-string">' + padLeft(item.id, 3) + ',' + item.id + ',' + item.title.toLowerCase() + ',' + item.desc.toLowerCase() + ',' + item.author_name.toLowerCase() + '\
    </div>\
    <div class="song-content">\
      <a href="/song/' + item.id + '">\
        <div class="song-number">' + padLeft(item.id, 3) + '</div>\
        <div class="song-info">\
          <div class="song-title">' + item.title + '</div>\
          <div class="song-artist">' + item.author_name + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br class="mobile-wrap"><!--播放次數: <span class="play-times"></span>--></div>\
        </div>\
      </a>\
    </div>\
    <div class="song-player">\
      <button class="play-button" data-trackid="' + item.track_id + '" data-sid=""></button>\
      <div class="song-wave">\
        <div class="waveform-preview"></div>\
        <div class="waveform"></div>\
        <input type="hidden" class="song-waveform-value" value="' + item.waveform + '">\
      </div>\
    </div>\
    <div class="song-tool-buttons">\
      <div class="vote-button-container">\
        <button class="vote-button" type="button" data-id="' + item.id + '"><i class="icon-vote"></i>投他一票</button>\
        <div class="vote-count">' + item.vote_count + ' 票</div>\
      </div>\
      <button class="fb-share" type="button" data-href="https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/' + item.id + '">分享</button>\
    </div>\
  </li>';
};

$(function() {
  $.getJSON('//api.iing.tw/soundclouds.json?token=8888', function(r) {
    var display, i, item, songWaveform, waveform, _i, _len, _ref, _results;

    r = r.slice().sort(function(a, b) {
      return a.id - b.id;
    });
    window.list = r;
    window.loading = true;
    $('.song-list').addClass('loading');
    i = 0;
    _ref = window.list;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (i > window.perPage - 1) {
        display = ' hide';
      } else {
        display = '';
      }
      $('.song-list').append($songItem(item, display));
      if (item.waveform === null) {
        SC.get('/tracks/' + item.track_id, function(track) {
          return $.getJSON('//waveformjs.org/w?callback=?', {
            url: track.waveform_url
          }, function(d) {
            var songWaveform, waveform;

            syncWaveform(item.id, item.token, d);
            songWaveform = d;
            return waveform = new Waveform({
              container: $('.song-item-' + item.id + ' .waveform-preview').get(0),
              innerColor: '#F0F0F0',
              data: songWaveform
            });
          });
        });
      } else {
        songWaveform = waveformStringToArray(item.waveform);
        waveform = new Waveform({
          container: $('.song-item-' + item.id + ' .waveform-preview').get(0),
          innerColor: '#F0F0F0',
          data: songWaveform
        });
      }
      createWaveform(item.id, item.track_id, songWaveform, '.song-item-' + item.id);
      i++;
      if (i === window.list.length) {
        _results.push($('.song-list').removeClass('loading'));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  });
  $('body').delegate('.list-more-song', 'click', function() {
    var i;

    i = window.pageNumber * window.perPage;
    while (i < (window.pageNumber + 1) * window.perPage) {
      $('.song-item:eq(' + i + ')').removeClass('hide');
      i++;
    }
    window.pageNumber++;
    if ($('.song-item.hide').length === 0) {
      return $('.list-more-song').remove();
    }
  });
  $(window).scroll(function(event) {
    var height, i, scroll;

    scroll = $(window).scrollTop();
    height = $(document).height();
    if (scroll > height * 0.8 && window.append === false && $('.list-more-song').length > 0) {
      window.append = true;
      i = window.pageNumber * window.perPage;
      while (i < (window.pageNumber + 1) * window.perPage) {
        $('.song-item:eq(' + i + ')').removeClass('hide');
        i++;
      }
      window.append = false;
      window.pageNumber++;
      if ($('.song-item.hide').length === 0) {
        return $('.list-more-song').remove();
      }
    }
  });
  $('body').delegate('.search-string', 'keydown', function() {
    return countdown = Date.now();
  });
  $('body').delegate('.search-string', 'keyup', function() {
    var filter;

    filter = ($(this).val()).toLowerCase();
    return setTimeout((function() {
      currentTime = Date.now();
      if (currentTime - countdown >= 490) {
        $('.no-result-container').removeClass('on');
        if (filter) {
          $('body').addClass('searching');
          songFilter(filter);
        } else {
          $('body').removeClass('searching');
          $('.song-list li').show();
        }
        return setInterval((function() {
          if ($('.song-list li').filter(':visible').size() === 0) {
            return $('.no-result-container').addClass('on');
          }
        }), 500);
      }
    }), 500);
  });
  return $('body').delegate('#listSorting', 'change', function() {
    var value;

    value = parseInt($(this).val());
    if (value === 1) {
      return tinysort('ul.song-list>li', {
        data: 'id',
        order: 'asc'
      });
    } else if (value === 2) {
      return tinysort('ul.song-list>li', {
        data: 'id',
        order: 'desc'
      });
    } else if (value === 3) {
      return tinysort('ul.song-list>li', {
        data: 'vote',
        order: 'desc'
      });
    }
  });
});
