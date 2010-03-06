$(function() {
  $('#demo-link2').click(function() {
    $('#demo').show();
    console.log('clicked demo');
    return true;
  });
  return $('#demo .run').click(function() {
    var html, json, template;
    console.log('clicked run');
    template = $('#demo .template').val();
    json = $.parseJSON($('#demo .json').val());
    html = Mustache.to_html(template, json);
    $('#demo .html').text(html);
    return Highlight.highlightDocument();
  });
});