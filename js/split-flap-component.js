const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?@#$%^&*() ";

/**
 * Requires GSAP
 */
class SplitFlapDisplay extends HTMLElement {
  constructor() {
    super();

    // Create shadow DOM for encapsulation
    this.attachShadow({ mode: "open" });

    // Default configuration
    // this.flipInterval = parseInt(this.getAttribute("flip-interval")) || 2000;
    // this.autoFlip = this.hasAttribute("auto-flip");

    // State
    this.currentChar = this.getAttribute("value") || this.chars[0];
    // this.charIndex = this.chars.indexOf(this.currentChar);

    this.tl = null;

    this.render();
    this.setupEventListeners();

    // if (this.autoFlip) {
    //   this.startAutoFlip();
    // }
  }

  render() {
    // CSS styles (scoped to this component)
    const styles = `
      <style>
        :host {
          display: inline-block;
          perspective: 400px;
        }
        
        .split-flap {
          position: relative;
          width: 60px;
          height: 80px;
          font-family: "Fragment Mono", monospace;
          font-size: 60px;
          font-weight: bold;
          background: #202020;
          border-radius: 4px;
          box-shadow: inset 0px 0px 5px 5px rgba(0, 0, 0, 0.8);
          cursor: pointer;
        }
        
        .split-flap::after {
          content: "";
          position: absolute;
          left: 0;
          right: 0;
          top: 50%;
          height: 2px;
          background: #000;
          z-index: 20;
        }
        
        .flap {
          position: absolute;
          width: 100%;
          height: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #d2d1d1;
          overflow: hidden;
          user-select: none;
        }
        
        .flap.top {
          top: 0;
          transform-origin: bottom;
          border-radius: 4px 4px 0 0;
          z-index: 2;
          user-select: text;
        }
        
        .flap.bottom {
          bottom: 0;
          transform-origin: top;
          border-radius: 0 0 4px 4px;
          z-index: 1;
        }
        
        .flap-content {
          position: absolute;
          width: 100%;
          height: 200%;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .flap.top .flap-content {
          top: 0;
        }
        
        .flap.bottom .flap-content {
          bottom: 0;
        }
        
        .flap.flipping-top {
          opacity: 0;
          pointer-events: none;
          top: 0;
          transform-origin: bottom;
          border-radius: 4px 4px 0 0;
          z-index: 10;
          box-shadow: 0 2px 4px rgb(0, 0, 0);
        }

        .flap.flipping-bottom {
          /* Animated flap that rotates down during character change */
          opacity: 0;
          pointer-events: none;
          bottom: 0;
          transform-origin: top;
          border-radius: 0 0 4px 4px;
          z-index: 10;
          box-shadow: 0 2px 4px rgb(0, 0, 0); /* Shadow for depth */
        }
        
        .flap.flipping-top .flap-content {
          top: 0;
        }

        .flap.flipping-bottom .flap-content {
          /* Positions text in bottom half of flap */
          bottom: 0;
        }
      </style>
    `;

    // HTML structure
    const html = `
      <div class="split-flap">
        <div class="flap top">
          <span class="flap-content">${this.currentChar}</span>
        </div>
        <div class="flap bottom">
          <span class="flap-content">${this.currentChar}</span>
        </div>
        <div class="flap flipping-top">
          <span class="flap-content">${this.currentChar}</span>
        </div>
        <div class="flap flipping-bottom">
          <span class="flap-content">${this.currentChar}</span>
        </div>
      </div>
    `;

    this.shadowRoot.innerHTML = styles + html;
  }

  setupEventListeners() {
    const splitFlap = this.shadowRoot.querySelector(".split-flap");
    splitFlap.addEventListener("click", () => this.flipToNext());
  }

  flipToNext() {
    const someLetter = chars[Math.floor(Math.random() * chars.length)];
    console.log(someLetter);
    const path = this.getPath(this.currentChar, someLetter);
    this.flipTo(path);
  }

  flipTo(path) {
    if (!path) return;
    if (this.tl) {
      console.log("tl already exists!!! todo");
    }

    const topFlap = this.shadowRoot.querySelector(".flap.top");
    const bottomFlap = this.shadowRoot.querySelector(".flap.bottom");
    const flippingTop = this.shadowRoot.querySelector(".flap.flipping-top");
    const flippingBottom = this.shadowRoot.querySelector(
      ".flap.flipping-bottom"
    );

    const nextChar = path[0];
    // bottomFlap.querySelector(".flap-content").textContent = this.currentChar;
    // flippingTop.querySelector(".flap-content").textContent = this.currentChar;

    // Create timeline for the flip animation
    this.tl = gsap.timeline({
      onStart: () => {
        flippingTop.querySelector(".flap-content").textContent =
          this.currentChar;
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
        this.currentChar = nextChar;

        const nextPath = path.slice(1);
        this.tl = null;
        if (nextPath.length > 0) {
          this.flipTo(nextPath);
        }
      },
    });

    // Animate the flip with enhanced shadow effect
    this.tl
      .to(flippingTop, {
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

    return this.tl;
  }

  /**
   * Get the path of characters between two characters (excluding the
   * startChar, including the endChar).
   *
   * @param {string} startChar - The starting character
   * @param {string} endChar - The ending character
   * @returns {string[]} The path of characters
   */
  getPath(startChar, endChar) {
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

  // startAutoFlip() {
  //   this.autoFlipTimer = setInterval(() => {
  //     this.flipToNext();
  //   }, this.flipInterval);
  // }

  stopAutoFlip() {
    if (this.autoFlipTimer) {
      clearInterval(this.autoFlipTimer);
      this.autoFlipTimer = null;
    }
  }

  // Lifecycle callbacks
  connectedCallback() {
    // Component added to DOM
  }

  disconnectedCallback() {
    // Component removed from DOM
    this.stopAutoFlip();
  }

  // Public API methods
  setValue(char) {
    this.flipTo(char);
  }

  getValue() {
    return this.currentChar;
  }

  // Observed attributes
  static get observedAttributes() {
    return ["value", "chars", "auto-flip", "flip-interval"];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    console.log("attributeChangedCallback", name, oldValue, newValue);
    console.log(JSON.stringify(this, null, 2));
    if (name === "value" && newValue !== oldValue) {
      if (this.tl) {
        // this.tl.kill();
        // this.tl = null;
      }
      const path = this.getPath(this.currentChar, newValue);
      console.log("path", path);
      // this.flipTo(path);
    }
  }
}

// Register the custom element
customElements.define("split-flap-display", SplitFlapDisplay);
