var nl2br, padLeft, soundManager, syncWaveform, waveformStringToArray;

SC.initialize({
  client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
});

soundManager = void 0;

padLeft = function(str, length) {
  if (str.toString().length >= length) {
    return str;
  } else {
    return padLeft('0' + str, length);
  }
};

nl2br = function(str, is_xhtml) {
  var breakTag;

  breakTag = is_xhtml || typeof is_xhtml === 'undefined' ? '<br ' + '/>' : '<br>';
  return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2');
};

waveformStringToArray = function(str) {
  return str.split(',').map(Number);
};

syncWaveform = function(id, token, data) {
  return $.ajax({
    type: 'post',
    dataType: 'json',
    cache: false,
    data: {
      id: id,
      token: token,
      data: data.toString()
    },
    url: 'http://api.iing.tw/sync_waveform.json',
    success: function(response) {
      return xx(response);
    }
  });
};

$(function() {
  $('body').delegate('.play-button', 'click', function() {
    var sid, _parent, _this, _trackid, _waveform;

    if (soundManager !== void 0) {
      soundManager.pauseAll();
      $('.pause-button').addClass('play-button');
      $('.play-button').removeClass('pause-button');
    }
    _this = $(this);
    _parent = _this.parents('.song-player');
    _waveform = waveformStringToArray(_parent.find('.song-waveform-value').val());
    _trackid = _this.data('trackid');
    _this.addClass('loading');
    if (_parent.find('.waveform').find('canvas').length < 1) {
      return SC.get('/tracks/' + _trackid, function(track) {
        var ctx, gradient, sound, waveform;

        sound = void 0;
        waveform = new Waveform({
          container: _parent.find('.waveform').get(0),
          innerColor: '#F0F0F0',
          data: _waveform
        });
        ctx = waveform.context;
        gradient = ctx.createLinearGradient(0, 0, 0, waveform.height);
        gradient.addColorStop(0.0, '#E4E779');
        gradient.addColorStop(1.0, '#57C0C7');
        waveform.innerColor = function(x) {
          if (sound && x < sound.position / sound.durationEstimate) {
            return gradient;
          } else if (sound && x < sound.bytesLoaded / sound.bytesTotal) {
            return '#D1D1D1';
          } else {
            return '#F0F0F0';
          }
        };
        return SC.stream('/tracks/' + _trackid, {
          whileloading: waveform.redraw,
          whileplaying: waveform.redraw,
          volume: 100
        }, function(s) {
          _this.attr('data-sid', s.sID);
          sound = s;
          sound.play();
          _this.removeClass('loading');
          _this.removeClass('play-button');
          return _this.addClass('pause-button');
        });
      });
    } else {
      sid = _this.data('sid');
      soundManager.play(sid);
      _this.removeClass('loading');
      _this.removeClass('play-button');
      return _this.addClass('pause-button');
    }
  });
  return $('body').delegate('.pause-button', 'click', function() {
    soundManager.pauseAll();
    $(this).removeClass('pause-button');
    return $(this).addClass('play-button');
  });
});
