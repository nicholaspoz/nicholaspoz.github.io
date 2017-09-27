(function() {
  var poz = $('#poz');
  mediaLinks = $("a.media")
  var body = $("#b");
  var suggestion = $('#suggestion')
  var count = 0;

  //suggestion.hide();

  body.on('click', function(event) {
    var target = $(event.target)
    if (!target.is('i')) {
      count = count + 1;
      var color = randomColor()
      poz.css('color', color);
      $.each(mediaLinks, function(index, link) {
        $(link).hover(function(hoverEvent){
          $(this).css('color', hoverEvent.type === 'mouseenter' ? color : 'black');
        })
      });
    }
    if (count === 5) {
      suggestion.show();
    }
    if (count === 10) {
      suggestion.text(suggestion.text().toUpperCase());
    }
  });

  function randomColorVal() {
    return 30 + Math.round(Math.random() * 69);
  }

  function randomColor() {
    return '#' + [randomColorVal(), randomColorVal(), randomColorVal()].join('');
  }
})();
