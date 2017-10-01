(function() {
  var body = $("#b");
  var poz = $('#poz');
  var media = $(".media");
  var mysteryButton = $('#mystery-button');
  var count = 0;
  var backgrounds = [
    new Background("/img/fire.gif", 'ion-bonfire', 'bg-fire'),
    new Background('/img/city.gif', 'ion-android-car', 'bg-city'),
    new Background('/img/fall.gif', 'ion-leaf', 'bg-fall'),
    new Background('/img/waterfall.gif', 'ion-waterdrop', 'bg-waterfall'),
    new Background('img/winter.gif', 'ion-ios-snowy', 'bg-winter')
  ];
  var currentBackground;
  var nextBackground;

  mysteryButton.on('click', getNextBackground);

  function getNextBackground() {
    //set background to next
    if (currentBackground) {
      body.removeClass(currentBackground.className);
    }
    if (nextBackground) {
      body.addClass(nextBackground.className);
    }
    currentBackground = nextBackground;
    do {
      var index = Math.floor(Math.random() * backgrounds.length);
      nextBackground = backgrounds[index];
    } while (nextBackground === currentBackground);

    //Set the icon for the next background
    if (currentBackground) {
      mysteryButton.removeClass(currentBackground.icon);
    }
    mysteryButton.addClass(nextBackground.icon);
  }

  body.on('click', function(event) {
    target = $(event.target);
    if (!target.is('i')) {
      count = count + 1;
      var color = randomColor()
      poz.css('color', color);
      $.each(media, function(index, link) {
        $(link).hover(function(hoverEvent) {
          var linkColor = hoverEvent.type === 'mouseenter' ? color : 'black'
          $(this).css('color', linkColor);
        })
      });
    }
    if (count === 5) {
      count = count + 1;
      getNextBackground()
      mysteryButton.removeClass('secret');
    }
    if (count === 10) {
      //body.removeClass('bg-fire');
    }
  });

  function randomColorVal() {
    return 30 + Math.floor(Math.random() * 69);
  }

  function randomColor() {
    return '#' + [randomColorVal(), randomColorVal(), randomColorVal()].join('');
  }

  function Background(src, icon, className) {
    this.src = src;
    this.icon = icon;
    this.className = className;

    this.imageCache = new Image()
    this.imageCache.src = src;
  }
})();
