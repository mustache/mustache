//###
// Scrolls the window to element:
//   $('element').scrollTo()
//   $('element').scrollTo(speed)
//
// Scrolls element1 to element2:
//   $('element1').scrollTo($('element2'))
//   $('element1').scrollTo($('element2'), speed)
$.fn.scrollTo = function scrollTo(el, speed) {
  var container, offset, target;
  if (typeof el === 'number' || !el) {
    speed = el;
    target = this;
    container = 'html,body';
  } else {
    target = el;
    container = this;
  }
  offset = $(target).offset().top - 30;
  $(container).animate({
    scrollTop: offset
  }, speed || 1000);
  return this;
};
$(function() {
  $('#demo').click(function() {
    $('#demo-box').show();
    $('#demo').scrollTo(1);
    return true;
  });
  if (window.location.hash === "#demo") {
    $('#demo').click();
  }
  return $('.run').click(function() {
    var html, json, template;
    console.log('clicked run');
    template = $('.template').val();
    json = $.parseJSON($('.json').val());
    html = Mustache.to_html(template, json).replace(/^\s*/mg, '');
    $('.html').text(html).scrollTo(1);
    return Highlight.highlightDocument();
  });
});