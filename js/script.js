(() => {
  const NAME_ONLY = [
    [{ text: "NICK DOT BINGO", type: "text" }],
    [], //
    [],
    [],
    [],
    [{ text: "NICHOLAS POZOULAKIS", type: "text" }],
  ];
  const TECH = [
    [{ text: "FREELANCE", type: "text" }],
    [{ text: "TECHNOLOGIST", type: "text" }],
    [],
    [], //
    [
      { text: "              ", type: "text" },
      {
        text: "LINKEDIN",
        type: "link",
        url: "https://www.linkedin.com/in/nicholaspozoulakis/",
      },
    ],
    [
      { text: "                 ", type: "text" },
      {
        text: "EMAIL",
        type: "link",
        url: "mailto:nicholaspoz@gmail.com",
      },
    ],
  ];

  const MUSICIAN = [
    [{ text: "NICK DOT BINGO", type: "text" }],
    [], //
    [{ text: "FREELANCE MUSICIAN", type: "text" }],
    [],
    [],
    [
      { text: "                 ", type: "text" },
      {
        text: "EMAIL",
        type: "link",
        url: "mailto:nicholaspoz@gmail.com",
      },
    ],
  ];

  const WHAT = [
    [{ text: "              WHAT", type: "text" }],
    [{ text: "            A", type: "text" }],
    [{ text: "       TIME", type: "text" }],
    [{ text: "    TO", type: "text" }],
    [{ text: "       BE", type: "text" }],
    [{ text: "               ALIVE", type: "text" }],
  ];

  const blurbs = [NAME_ONLY, TECH, MUSICIAN, WHAT];

  const ms = 3_000;

  let index = 0;
  function updateBlurb() {
    const blurb = blurbs[index];
    document
      .querySelector("split-flap-display")
      .setAttribute("lines", JSON.stringify(blurb));
    index = (index + 1) % blurbs.length;
  }

  document.addEventListener("DOMContentLoaded", (event) => {
    console.log("Split-flap components loaded???!");
    updateBlurb();
    setInterval(updateBlurb, ms);
  });

  // defer to next tick so the blur placeholder paints first
  requestAnimationFrame(() => {
    document.querySelector(".site-hero").classList.add("ready");
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
