$ ->
  $('#demo-link2').click ->
    $('#demo').show()
    console.log 'clicked demo'
    true
    
  $('#demo .run').click ->
    console.log 'clicked run'
    template: $('#demo .template').val()
    json: $.parseJSON $('#demo .json').val()
    html: Mustache.to_html(template, json)
    $('#demo .html').text(html)
    Highlight.highlightDocument()    
