(() => {
  function row(str, url) {
    return {
      type: url ? "link" : "text",
      text: str ? str : "",
      url,
    };
  }

  function linkedIn() {
    return row(
      "LINKEDIN >".padStart(22),
      "https://www.linkedin.com/in/nicholaspozoulakis/"
    );
  }

  function email() {
    return row("EMAIL >".padStart(22), "mailto:nicholaspoz@gmail.com");
  }

  function github() {
    return row("GITHUB >".padStart(22), "https://github.com/nicholaspoz");
  }

  const NICK = [
    row("NICK"), //
    row(),
    row(),
    row(),
    row(),
    row(),
  ];

  const NICK_DOT = [
    row("NICK"), //
    row(),
    row("DOT"),
    row(),
    row(),
    row(),
  ];

  const NICK_DOT_BINGO = [
    row("NICK"),
    row(),
    row("DOT"),
    row(),
    row("BINGO"),
    row(),
  ];

  const FULL_NAME = [
    row("NICK (POZOULAKIS)"),
    row(),
    row("DOT"),
    row(),
    row("BINGO"),
    row(),
  ];

  const TECH = [
    row("FREELANCE"),
    row("TECHNOLOGIST"),
    row(),
    linkedIn(),
    github(),
    email(),
  ];

  const MUSICIAN = [
    row("FREELANCE"),
    row("CELLIST"),
    row(),
    row(),
    row(),
    email(),
  ];

  const MUSIC_NOTES = [
    row("FREELANCE"),
    row("CELLIST"),
    row("  ___ ".padStart(13)),
    row(" |   |".padStart(13)),
    row("0   0 ".padStart(13)),
    email(),
  ];

  const WHAT = [
    row("              WHAT"),
    row("            A"),
    row("       TIME"),
    row("    TO"),
    row("       BE"),
    row("          ALIVE?"),
  ];

  const GLEAM_1 = [
    row("MADE"),
    row("FROM"),
    row("SCRATCH"),
    row("USING"),
    row("      GLEAM.RUN", "https://gleam.run"),
    row(),
  ];

  const GLEAM_2 = [
    row("MADE"),
    row("FROM"),
    row("SCRATCH"),
    row("USING"),
    row("      GLEAM.RUN", "https://gleam.run"),
    row("<3".padStart(20)),
  ];

  function frame(contents, ms) {
    return { contents, ms };
  }

  const frames = [
    frame(NICK, 1_000),
    frame(NICK_DOT, 1_000),
    frame(NICK_DOT_BINGO, 1_200),
    frame(FULL_NAME, 7_000),
    frame(TECH, 8_000),
    frame(MUSICIAN, 1_000),
    frame(MUSIC_NOTES, 7_000),
    frame(WHAT, 7_000),
    frame(GLEAM_1, 1_000),
    frame(GLEAM_2, 6_000),
  ];

  let index = 0;
  function nextFrame() {
    const { contents, ms } = frames[index];
    document
      .querySelector("split-flap-display")
      .setAttribute("lines", JSON.stringify(contents));
    index = (index + 1) % frames.length;
    setTimeout(nextFrame, ms);
  }

  // If the image is not a square, everything explodes and then you die.
  function positionImageOverlay() {
    const body = document.body;
    const overlay = document.getElementById("rectangle-overlay");
    if (!overlay || !body) return;

    // % of left/top when aspect ratio is 1
    const xOffsetBase = 0.363;
    const yOffsetBase = 0.222;

    // actual viewport dimensions
    const VIEWPORT_MIN_WIDTH = 300;
    const VIEWPORT_MIN_HEIGHT = 900;
    const viewWidth = Math.max(VIEWPORT_MIN_WIDTH, body.scrollWidth);
    const viewHeight = Math.max(VIEWPORT_MIN_HEIGHT, body.scrollHeight);
    const longestSide = Math.max(viewWidth, viewHeight);

    let left = xOffsetBase * longestSide;
    let top = yOffsetBase * longestSide;

    const widthBase = 0.275;
    const heightBase = 0.125;
    const width = widthBase * longestSide;
    const height = heightBase * longestSide;

    // Account for background-position offset (50% 30%)
    // https://developer.mozilla.org/en-US/docs/Web/CSS/background-position#regarding_percentages
    // TODO these should be css vars
    const bgPosX = 0.5;
    const bgPosY = 0.35;
    const xOffset = (viewWidth - longestSide) * bgPosX;
    const yOffset = (viewHeight - longestSide) * bgPosY;

    // Apply the calculated position and size
    overlay.style.left = `${left + xOffset}px`;
    overlay.style.top = `${top + yOffset}px`;
    overlay.style.width = `${width}px`;
    overlay.style.height = `${height}px`;

    document.documentElement.style.setProperty(
      "--background-position",
      `${bgPosX * 100}% ${bgPosY * 100}%`
    );
    document.documentElement.style.setProperty(
      "--viewport-min-width",
      `${VIEWPORT_MIN_WIDTH}px`
    );
    document.documentElement.style.setProperty(
      "--viewport-min-height",
      `${VIEWPORT_MIN_HEIGHT}px`
    );
  }

  // Update overlay position on resize and initial load
  window.addEventListener("resize", positionImageOverlay);
  positionImageOverlay();

  // Update the DOMContentLoaded listener to include overlay positioning
  document.addEventListener("DOMContentLoaded", (event) => {
    nextFrame();
  });

  // Also update it when the image transitions from blur to sharp
  requestAnimationFrame(() => {
    document.querySelector(".site-hero").classList.add("ready");
  });
})();
