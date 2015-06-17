$(".play-button").on("click", function(){
  SC.initialize({
    client_id: "d2f7da453051d648ae2f3e9ffbd4f69b"
  });

  SC.get("/tracks/293", function(track){
    $.getJSON("http://waveformjs.org/w?callback=?", {
      url: track.waveform_url,
    }, function(d){
      var sound;
      var gradient;
      var waveform = new Waveform({
        container: $(".waveform").get(0),
        innerColor: "#F0F0F0",
        data: d
      });

      var ctx = waveform.context;
      var gradient = ctx.createLinearGradient(0, 0, 0, waveform.height);
      gradient.addColorStop(0.0, "#E4E779");
      gradient.addColorStop(1.0, "#57C0C7");
      waveform.innerColor = function(x){
        if(sound && x < sound.position / sound.durationEstimate){
          return gradient;
        }else if(sound && x < sound.bytesLoaded / sound.bytesTotal){
          return "#D1D1D1";
        }else{
          return "#F0F0F0";
        }
      };

      SC.stream(track.uri, {
        whileloading: waveform.redraw,
        whileplaying: waveform.redraw,
        volume: 100,
        autoPlay: true
      }, function(s){
        sound = s;
      });
    });
  });

  d = []
  a = [0, 0.25, 0, 1, 0, 0.5, 0, 0.75]
  for(var i=0; i < a.length; i++){
    for(var ii=0; ii < 10; ii++){
      d.push(a[i]);
    }
  }

  return false;

});
