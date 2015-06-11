var DEBUG, maxWidth, movemove, xx;

DEBUG = true;

maxWidth = $(window).width();

xx = function(x) {
  return DEBUG && console.log(x);
};

movemove = function(elment, distance) {
  return $(elment).css({
    "-webkit-transform": "translateX(" + distance + "px)",
    "-moz-transform": "translateX(" + distance + "px)",
    "-ms-transform": "translateX(" + distance + "px)",
    "-o-transform": "translateX(" + distance + "px)",
    "transform": "translateX(" + distance + "px)"
  });
};

$(function() {
  return $('body').mousemove(function(e) {
    var percent;

    percent = (e.pageX / maxWidth) * 100;
    movemove('.color-lines .layer-1', (percent - 50) * -1.3);
    movemove('.color-lines .layer-2', (percent - 50) * .4);
    movemove('.color-lines .layer-3', (percent - 50) * -.5);
    movemove('.color-lines .layer-4', (percent - 50) * .6);
    movemove('.color-lines .layer-5', (percent - 50) * .7);
    movemove('.color-lines .layer-6', (percent - 50) * -.9);
    movemove('.color-lines .layer-7', (percent - 50) * -1.5);
    movemove('.color-lines .layer-8', (percent - 50) * -1);
    movemove('.color-dots', (percent - 50) * .3);
    movemove('.intro-right-lines', (percent - 50) * .3);
    return movemove('.intro-left-lines', (percent - 50) * -.3);
  });
});
