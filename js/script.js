(() => {
  document.addEventListener("DOMContentLoaded", (event) => {
    console.log("Split-flap components loaded???!");
  });
  let word = "HELLO";

  // defer to next tick so the blur placeholder paints first
  requestAnimationFrame(() => {
    document.querySelector(".site-hero").classList.add("ready");
    setInterval(() => {
      word = word.slice(1) + word[0];
      console.log("updating word!!!", word);
      document.querySelector("#sf0").setAttribute("letter", word[0]);
      document.querySelector("#sf1").setAttribute("letter", word[1]);
      document.querySelector("#sf2").setAttribute("letter", word[2]);
      document.querySelector("#sf3").setAttribute("letter", word[3]);
      document.querySelector("#sf4").setAttribute("letter", word[4]);
    }, 5000);
  });

  // Dynamic scaling based on aspect ratio
  function updateDynamicScale() {
    const minScale = 100;
    const maxScale = 180;
    const targetAspectRatio = 16 / 9;
    const aspectRatio = window.innerWidth / window.innerHeight;

    // Calculate scale: more narrow = more scaling
    const delta = Math.abs(targetAspectRatio - aspectRatio);
    const normalizedDelta = delta / targetAspectRatio;

    const normalizedRatio = Math.max(0, Math.min(1, normalizedDelta));
    const scale = minScale + (maxScale - minScale) * normalizedRatio;
    console.log(scale);

    document.documentElement.style.setProperty("--dynamic-scale", `${scale}%`);
    document.documentElement.style.setProperty(
      "--dynamic-factor",
      `${scale / 100}`
    );
  }

  // Update on resize and initial load
  window.addEventListener("resize", updateDynamicScale);
  updateDynamicScale();
})();
