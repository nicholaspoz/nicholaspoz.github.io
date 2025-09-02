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
    row("  ___ ".padStart(12)),
    row(" |   |".padStart(12)),
    row("0   0 ".padStart(12)),
    email(),
  ];

  const WHAT = [
    row("              WHAT"),
    row("            A"),
    row("       TIME"),
    row("    TO"),
    row("       BE"),
    row("           ALIVE?"),
  ];

  function frame(contents, ms) {
    return { contents, ms };
  }

  const frames = [
    frame(NICK, 1_500),
    frame(NICK_DOT, 1_500),
    frame(NICK_DOT_BINGO, 2_000),
    frame(FULL_NAME, 7_000),
    frame(TECH, 8_000),
    frame(MUSICIAN, 8_000),
    frame(WHAT, 7_000),
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
    const overlay = document.getElementById("rectangle-overlay");
    if (!overlay) return;

    // % of left/top when aspect ratio is 1
    const xOffsetBase = 0.363;
    const yOffsetBase = 0.222;

    // actual viewport dimensions
    const viewWidth = window.innerWidth;
    const viewHeight = window.innerHeight;
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
    const xOffset = (viewWidth - longestSide) * 0.5;
    const yOffset = (viewHeight - longestSide) * 0.3;

    // Apply the calculated position and size
    overlay.style.left = `${left + xOffset}px`;
    overlay.style.top = `${top + yOffset}px`;
    overlay.style.width = `${width}px`;
    overlay.style.height = `${height}px`;

    const aspectRatio = window.innerWidth / window.innerHeight;
    document.documentElement.style.setProperty("--aspect-ratio", aspectRatio);
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
