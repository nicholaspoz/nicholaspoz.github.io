// Import the split-flap component
import "./split-flap-component";

// use a script tag or an external JS file
document.addEventListener("DOMContentLoaded", (event) => {
  // gsap.registerPlugin(SplitText);
  // console.log("DOMContentLoaded GSAP hooray");
  // Split-flap components are now self-contained web components
  // You can interact with them using their API methods
  console.log("Split-flap components loaded???!");
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
  const flippingBottom = splitFlap.querySelector(".flap.flipping-bottom");

  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?@#$%^&*() ";
  let currentChar = "A";

  /**
   * Get the path of characters between two characters (excluding the
   * startChar, including the endChar).
   *
   * @param {string} startChar - The starting character
   * @param {string} endChar - The ending character
   * @returns {string[]} The path of characters
   */
  function getPath(startChar: string, endChar: string) {
    const startIndex = chars.indexOf(startChar);
    const endIndex = chars.indexOf(endChar);
    if (endIndex === -1 || startIndex === -1 || startChar === endChar) {
      return [];
    }

    const path = [];
    for (let i = startIndex + 1; i <= endIndex + chars.length; i++) {
      path.push(chars[i % chars.length]);
    }
    return path;
  }

  function flipToNext(path: string[]) {
    console.log("flipping!", path);
    const nextChar = path[0];

    // Prepare the bottom flap to show next character (hidden behind flipping flap)
    bottomFlap.querySelector(".flap-content").textContent = currentChar;

    // Set up the flipping flap with current character
    flippingTop.querySelector(".flap-content").textContent = currentChar;

    // Create timeline for the flip animation
    const tl = gsap.timeline({
      onStart: () => {
        flippingTop.querySelector(".flap-content").textContent = currentChar;
        gsap.set(flippingTop, {
          opacity: 1,
          rotateX: 0,
          zIndex: 10,
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.3)",
        });

        flippingBottom.querySelector(".flap-content").textContent = nextChar;
        gsap.set(flippingBottom, { opacity: 0, rotateX: 90 });

        topFlap.querySelector(".flap-content").textContent = nextChar;
      },
      onComplete: () => {
        // Update the top flap to show next character
        bottomFlap.querySelector(".flap-content").textContent = nextChar;

        // Reset flipping flap
        gsap.set(flippingTop, { opacity: 0, rotateX: 0 });
        gsap.set(flippingBottom, { opacity: 0, rotateX: 90 });

        // Update current state
        currentChar = nextChar;

        const nextPath = path.slice(1);
        if (nextPath.length > 0) {
          flipToNext(nextPath);
        }
      },
    });

    // Animate the flip with enhanced shadow effect
    tl.to(flippingTop, {
      rotateX: -90,
      duration: 0.08,
      ease: "power2.in",
      boxShadow: "0 8px 16px rgba(0, 0, 0, 0.5)",
    })
      .set(flippingTop, {
        opacity: 0,
      })
      .set(flippingBottom, {
        opacity: 1,
        zIndex: 10,
        boxShadow: "0 2px 4px rgba(0, 0, 0, 0.3)",
        rotateX: 90,
      })
      .to(flippingBottom, {
        rotateX: 0,
        duration: 0.02,
        ease: "linear",
      });

    return tl;
  }

  function scrollToRandomLetter() {
    const someLetter = chars[Math.floor(Math.random() * chars.length)];
    console.log(someLetter);
    const path = getPath(currentChar, someLetter);
    console.log(path);
    flipToNext(path);
  }

  // Flip every 2 seconds for demo
  setInterval(scrollToRandomLetter, 20000);

  // Also flip on click
  splitFlap.addEventListener("click", scrollToRandomLetter);
}
