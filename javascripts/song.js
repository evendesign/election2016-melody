var getUrlVars;

getUrlVars = function() {
  var hash, hashes, i, vars;

  vars = [];
  hash = void 0;
  hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
  i = 0;
  while (i < hashes.length) {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
    i++;
  }
  return vars;
};

$(function() {
  var id, vars;

  vars = getUrlVars();
  if (typeof vars.no !== 'undefined' && parseInt(vars.no) > 0) {
    id = parseInt(vars.no);
    return $.getJSON('http://api.staging.iing.tw/soundclouds/' + id + '.json?token=8888', function(r) {
      var waveform;

      $('.song-title').text(r.title);
      $('.song-artist').text(r.author_name);
      $('.song-number').text(padLeft(r.id, 3));
      $('.vote-count span').text(r.vote_count);
      $('.song-lyric p').html(nl2br(r.lyrics));
      $('.song-intro p').html(nl2br(r.desc));
      xx(r);
      return waveform = new Waveform({
        container: $('.waveform-preview').last().get(0),
        innerColor: '#F0F0F0',
        data: demoWaveform()
      });
    });
  } else {
    return window.location = '/list';
  }
});
