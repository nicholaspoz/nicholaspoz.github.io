(function() {
  var body = $("#b");
  var poz = $('#poz');
  var name = $('#name');
  var mediaLinks = $("a.media");
  var suggestion = $('#suggestion');
  var count = 0;

  body.on('click', function(event) {
    target = $(event.target);
    if (!target.is('i')) {
      count = count + 1;
      var color = randomColor()
      poz.css('color', color);
      name.css('color', color);
      $.each(mediaLinks, function(index, link) {
        $(link).hover(function(hoverEvent) {
          var linkColor = hoverEvent.type === 'mouseenter' ? color : 'black'
          $(this).css('color', linkColor);
        })
      });
    }
    if (count === 5) {
      suggestion.show();
    }
    if (count === 10) {
      suggestion.text(suggestion.text().toUpperCase());
    }
    if (count === 20) {
      body.css('background-size', 'cover');
      body.css('filter', 'invert(100%)');
    }
  });

  function randomColorVal() {
    return 30 + Math.round(Math.random() * 69);
  }

  function randomColor() {
    return '#' + [randomColorVal(), randomColorVal(), randomColorVal()].join('');
  }
})();
