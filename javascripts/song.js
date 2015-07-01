window.pageName = 'song';

$(function() {
  var explode, id, song_no, url;

  xx(window.getVars);
  if (parseInt(window.getVars['autoplay']) === 1) {
    window.autoPlay = true;
  }
  url = window.location.href;
  if (url.indexOf('?') > 0) {
    url = url.split('?')[0];
  }
  if (url.indexOf('#') > 0) {
    url = url.split('#')[0];
  }
  explode = url.split('/');
  song_no = explode[4];
  if (typeof song_no !== 'undefined' && parseInt(song_no) > 0) {
    id = parseInt(song_no);
    return $.getJSON('//api.staging.iing.tw/soundclouds/' + id + '.json?token=8888', function(item) {
      var songWaveform, waveform;

      xx(item);
      $('.song-title').text(item.title);
      $('.song-artist').text(item.author_name);
      $('.song-number').text(padLeft(item.id, 3));
      $('.song-lyric p').html(nl2br(item.lyrics));
      $('.song-intro p').html(nl2br(item.desc));
      $('.song-waveform-value').val(item.waveform);
      $('.vote-button').attr('data-id', item.id);
      $('.play-button').attr('data-trackid', item.track_id);
      $('#nextSong').attr('href', '/song/' + item.next_song_id);
      $('.vote-count').text(item.vote_count + ' 票');
      $('.fb-share').attr('data-href', 'https://www.facebook.com/sharer/sharer.php?u=//melody.iing.tw/song/' + item.id);
      if (item.official_url) {
        $('.song-intro .song-artist').prepend('<a class="official-link" targe="_blank" href="' + item.official_url + '">Official Link</a>');
      }
      if (item.waveform === null) {
        SC.get('/tracks/' + item.track_id, function(track) {
          xx(track);
          xx(track.waveform_url);
          return $.getJSON('//waveformjs.org/w?callback=?', {
            url: track.waveform_url
          }, function(d) {
            var songWaveform, waveform;

            xx(d);
            syncWaveform(item.id, item.token, d);
            songWaveform = d;
            return waveform = new Waveform({
              container: $('.waveform-preview').get(0),
              innerColor: 'rgba(0,0,0,.1)',
              data: songWaveform
            });
          });
        });
      } else {
        songWaveform = waveformStringToArray(item.waveform);
        waveform = new Waveform({
          container: $('.waveform-preview').get(0),
          innerColor: 'rgba(0,0,0,.1)',
          data: songWaveform
        });
      }
      createWaveform(item.id, item.track_id, songWaveform, '.page');
      $('.page .spinner').remove();
      $('.song-player-container').removeClass('off');
      $('.song-detail').removeClass('off');
      return $('.page-bottom-illustrator').removeClass('off');
    });
  }
});
