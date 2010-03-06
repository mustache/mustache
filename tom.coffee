####
# Scrolls the window to element:
#   $('element').scrollTo()
#   $('element').scrollTo(speed)
# 
# Scrolls element1 to element2:
#   $('element1').scrollTo($('element2'))
#   $('element1').scrollTo($('element2'), speed)
$.fn.scrollTo: (el, speed) ->
  if typeof el is 'number' or not el
    speed: el
    target: this
    container:'html,body'
  else
    target: el
    container: this

  offset: $(target).offset().top - 30
  $(container).animate({scrollTop: offset}, speed or 1000)
  this

$ ->
  $('#demo').click ->
    $('#demo-box').show()
    $('#demo').scrollTo(1)
    true
    
  $('#demo').click() if window.location.hash is "#demo"    
  
  $('.run').click ->
    template: $('.template').val()
    json: $.parseJSON $('.json').val()
    html: Mustache.to_html(template, json).replace(/^\s*/mg, '')
    $('.html').text(html).scrollTo(1)
    Highlight.highlightDocument()    
