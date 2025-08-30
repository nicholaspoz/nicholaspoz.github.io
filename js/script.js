(function () {
  // defer to next tick so the blur placeholder paints first
  requestAnimationFrame(() =>
    document.querySelector(".site-hero").classList.add("ready")
  );

  // Dynamic scaling based on aspect ratio
  function updateDynamicScale() {
    const aspectRatio = window.innerWidth / window.innerHeight;
    const targetAspectRatio = 16 / 9; // 1.777...

    if (aspectRatio < targetAspectRatio) {
      // Calculate scale: more narrow = more scaling
      // Scale from 115% at 16:9 to 200% at very narrow ratios
      const minScale = 100;
      const maxScale = 180;
      const normalizedRatio = Math.max(
        0,
        Math.min(1, (targetAspectRatio - aspectRatio) / targetAspectRatio)
      );
      const scale = minScale + (maxScale - minScale) * normalizedRatio;

      document.documentElement.style.setProperty(
        "--dynamic-scale",
        `${scale}%`
      );
    }
  }

  // Update on resize and initial load
  window.addEventListener("resize", updateDynamicScale);
  updateDynamicScale();
})();
