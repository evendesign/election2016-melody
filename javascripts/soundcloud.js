var nl2br, padLeft, syncWaveform, vote, voteCheck, waveformStringToArray;

SC.initialize({
  client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
});

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

voteCheck = function(facebook_token, soundcloud_id) {
  xx(facebook_token);
  xx(soundcloud_id);
  return $.ajax({
    type: 'post',
    dataType: 'json',
    cache: false,
    data: {
      facebook_token: facebook_token,
      soundcloud_id: soundcloud_id
    },
    url: 'http://api.staging.iing.tw/vote_check.json',
    success: function(response) {
      if (response.message === true) {
        return vote(facebook_token, soundcloud_id);
      } else {
        return alert('您已完成投票（每人每日每首歌可投票乙次）');
      }
    }
  });
};

vote = function(facebook_token, soundcloud_id) {
  return $.ajax({
    type: 'post',
    dataType: 'json',
    cache: false,
    data: {
      facebook_token: facebook_token,
      soundcloud_id: soundcloud_id
    },
    url: 'http://api.staging.iing.tw/vote.json',
    success: function(response) {
      return xx(response);
    }
  });
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
    url: 'http://api.staging.iing.tw/sync_waveform.json',
    success: function(response) {
      return xx(response);
    }
  });
};

$(function() {
  $('body').delegate('.vote-button', 'click', function() {
    var soundcloud_id;

    soundcloud_id = $(this).data('id');
    return FB.getLoginStatus(function(response) {
      var facebook_token;

      if (response.status === 'connected') {
        facebook_token = response.authResponse.accessToken;
        return voteCheck(facebook_token, soundcloud_id);
      } else {
        return FB.login((function(response) {
          if (response.status === 'connected') {
            facebook_token = response.authResponse.accessToken;
            return voteCheck(facebook_token, soundcloud_id);
          } else {
            return xx('Login failed');
          }
        }), {
          return_scopes: true
        });
      }
    });
  });
  $('body').delegate('.play-button', 'click', function() {
    var _parent, _this, _trackid, _waveform;

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
          sound = s;
          sound.play();
          _this.removeClass('loading');
          _this.removeClass('play-button');
          return _this.addClass('stop-button');
        });
      });
    }
  });
  return $('body').delegate('.stop-button', 'click', function() {
    sound.stop();
    _this.removeClass('stop-button');
    return _this.addClass('play-button');
  });
});
