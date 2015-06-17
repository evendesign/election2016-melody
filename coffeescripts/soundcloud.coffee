$('.play-button').on 'click', ->
  SC.initialize client_id: 'd2f7da453051d648ae2f3e9ffbd4f69b'
  SC.get '/tracks/293', (track) ->
    $.getJSON 'http://waveformjs.org/w?callback=?', { url: track.waveform_url }, (d) ->
      sound = undefined
      waveform = new Waveform(
        container: $('.w0').get(0)
        innerColor: (x) ->
          if sound and x < sound.position / sound.durationEstimate
            'rgba(255,  102, 0, 0.8)'
          else if sound and x < sound.bytesLoaded / sound.bytesTotal
            'rgba(0, 0, 0, 0.8)'
          else
            'rgba(0, 0, 0, 0.4)'
        data: d)
      SC.stream track.uri, {
        whileloading: waveform.redraw
        whileplaying: waveform.redraw
        volume: 0
        autoPlay: true
      }, (s) ->
        sound = s
        return
      return
    return
  d = []
  a = [
    0
    0.25
    0
    1
    0
    0.5
    0
    0.75
  ]
  i = 0
  while i < a.length
        ii = 0
    while ii < 10
      d.push a[i]
      ii++
    i++
  return false
  w0 = new Waveform(
    container: $('.w2')[0]
    outerColor: 'transparent'
    innerColor: '#ff0066'
    width: 8 * 10
    interpolate: false
    data: d)
  $.getJSON 'http://waveformjs.org/w?callback=?', { url: 'http://w1.sndcdn.com/EQyi2vpPOMvG_m.png' }, (d) ->
    w1 = new Waveform(
      container: $('.w1')[0]
      outerColor: 'transparent'
      innerColor: ->
        '#' + Math.floor(Math.random() * 16777215).toString(16)
      data: d)
    return
  w2 = new Waveform(
    container: $('.w2')[0]
    outerColor: 'transparent'
    innerColor: ->
      '#' + Math.floor(Math.random() * 16777215).toString(16)
    data: [
      1
      0.5
      1
      0
    ])
  w3 = new Waveform(
    container: $('.w3')[0]
    outerColor: 'transparent'
    innerColor: (x) ->
      '#' + Math.floor((0.2 + x) * 16777215).toString(16)
  )
  w4 = new Waveform(
    container: $('.w3')[0]
    outerColor: 'transparent'
    innerColor: 'black'
    interpolate: false)
  d = []
  setInterval (->
    #d.push(Math.random());
    #d.push( x= Math.sin(d.length));
    d.push x = d.length % 36 / 36
    w3.update data: d
    w4.update data: d
    return
  ), 50
