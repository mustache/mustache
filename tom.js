//###
// Scrolls the window to element:
//   $('element').scrollTo()
//   $('element').scrollTo(speed)
//
// Scrolls element1 to element2:
//   $('element1').scrollTo($('element2'))
//   $('element1').scrollTo($('element2'), speed)
$.fn.scrollTo = function scrollTo(speed) {
  var container, offset, target;
  target = this;
  container = 'html,body';
  offset = $(target).offset().top - 30;
  $(container).animate({
    scrollTop: offset
  }, speed || 1000);
  return this;
};
$(function() {
  $('#demo').click(function() {
    $('#demo-box').toggle();
    if ($('#demo-box:visible').length > 0) {
      $('#demo').scrollTo(1);
      window.location.hash = '#demo';
    } else {
      window.location.hash = '';
    }
    return false;
  });
  if (window.location.hash === "#demo") {
    $('#demo').click();
  }
  return $('.run').click(function() {
    var html, json, template;
    template = $('.template').val();
    json = $.parseJSON($('.json').val());
    html = Mustache.to_html(template, json).replace(/^\s*/mg, '');
    $('.html').text(html).scrollTo(1);
    return Highlight.highlightDocument();
  });
});