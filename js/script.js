(function() {
  var poz = $('#poz');
  var body = $("#b");
  var suggestion = $('#suggestion')
  var count = 0;

  //suggestion.hide();

  body.on('click', function(event) {
    var target = $(event.target)
    if (!target.is('i')) {
      count = count + 1;
      poz.css('color', randomColor());
    }
    if (count === 7) {
      suggestion.show();
    }
    if (count === 14) {
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
