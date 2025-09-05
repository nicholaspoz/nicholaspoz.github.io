(() => {
  // If the image is not a square, everything explodes and then you die.
  function positionImageOverlay() {
    const body = document.body;
    const overlay = document.getElementById("rectangle-overlay");
    if (!overlay || !body) {
      console.log("NO OVERLAY OR BODY");
      return;
    }

    // % of left/top when aspect ratio is 1
    const xOffsetBase = 0.363;
    const yOffsetBase = 0.222;

    // actual viewport dimensions
    const VIEWPORT_MIN_WIDTH = 0;
    const VIEWPORT_MIN_HEIGHT = 900;
    // const viewWidth = Math.max(VIEWPORT_MIN_WIDTH, body.scrollWidth);
    const viewWidth = body.scrollWidth;
    // const viewHeight = Math.max(VIEWPORT_MIN_HEIGHT, body.scrollHeight);
    const viewHeight = body.scrollHeight;
    const longestSide = Math.max(viewWidth, viewHeight);
    console.log("DIMENSIONS", {
      viewWidth,
      viewHeight,
      longestSide,
      windowWidth: window.innerWidth,
      windowHeight: window.innerHeight,
    });

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
  let timeout = undefined; // holder for timeout id
  const delay = 0; // delay after event is "complete" to run callback

  window.addEventListener("resize", () => {
    positionImageOverlay();
    // if (timeout) {
    //   clearTimeout(timeout);
    // }
    // timeout = setTimeout(positionImageOverlay, delay);
  });
  positionImageOverlay();

  // // Update the DOMContentLoaded listener to include overlay positioning
  document.addEventListener("DOMContentLoaded", (event) => {
    // nextFrame();
    positionImageOverlay();
  });

  // Also update it when the image transitions from blur to sharp
  requestAnimationFrame(() => {
    document.querySelector(".site-hero").classList.add("ready");
  });
})();
