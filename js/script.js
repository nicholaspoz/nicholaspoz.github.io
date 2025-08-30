(function () {
  // use a script tag or an external JS file
  document.addEventListener("DOMContentLoaded", (event) => {
    gsap.registerPlugin(SplitText);
    console.log("DOMContentLoaded GSAP hooray");

    // Initialize split-flap display
    initSplitFlap();
  });

  // defer to next tick so the blur placeholder paints first
  requestAnimationFrame(() =>
    document.querySelector(".site-hero").classList.add("ready")
  );

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

  // Split-flap display functionality
  function initSplitFlap() {
    const splitFlap = document.querySelector(".split-flap");
    if (!splitFlap) return;

    const topFlap = splitFlap.querySelector(".flap.top");
    const bottomFlap = splitFlap.querySelector(".flap.bottom");
    const flippingTop = splitFlap.querySelector(".flap.flipping-top");

    let currentChar = "A";
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
    let charIndex = 0;

    function flipToNext() {
      const nextIndex = (charIndex + 1) % chars.length;
      const nextChar = chars[nextIndex];

      // Set up the display for realistic flipping:
      // - Top static flap keeps showing current character
      // - Bottom static flap shows next character (will be revealed)
      // - Flipping top flap shows current character (will rotate down)

      // Prepare the bottom flap to show next character (hidden behind flipping flap)
      bottomFlap.querySelector(".flap-content").textContent = nextChar;

      // Set up the flipping flap with current character
      flippingTop.querySelector(".flap-content").textContent = currentChar;

      // Create timeline for the flip animation
      const tl = gsap.timeline({
        onComplete: () => {
          // Update the top flap to show next character
          topFlap.querySelector(".flap-content").textContent = nextChar;

          // Reset flipping flap
          gsap.set(flippingTop, { opacity: 0, rotateX: 0 });

          // Update current state
          currentChar = nextChar;
          charIndex = nextIndex;
        },
      });

      // Animate the flip with enhanced shadow effect
      tl.set(flippingTop, {
        opacity: 1,
        zIndex: 10,
        boxShadow: "0 2px 4px rgba(0, 0, 0, 0.3)",
      }).to(flippingTop, {
        rotateX: -90,
        duration: 1,
        ease: "power2.in",
        boxShadow: "0 8px 16px rgba(0, 0, 0, 0.5)",
      });

      return tl;
    }

    // Flip every 2 seconds for demo
    setInterval(flipToNext, 2000);

    // Also flip on click
    splitFlap.addEventListener("click", flipToNext);
  }
})();
