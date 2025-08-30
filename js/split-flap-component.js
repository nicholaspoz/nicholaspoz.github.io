class SplitFlapDisplay extends HTMLElement {
  constructor() {
    super();

    // Create shadow DOM for encapsulation
    this.attachShadow({ mode: "open" });

    // Default configuration
    this.chars =
      this.getAttribute("chars") || "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ";
    this.autoFlip = this.hasAttribute("auto-flip");
    this.flipInterval = parseInt(this.getAttribute("flip-interval")) || 2000;

    // State
    this.currentChar = this.getAttribute("value") || this.chars[0];
    this.charIndex = this.chars.indexOf(this.currentChar);

    this.render();
    this.setupEventListeners();

    if (this.autoFlip) {
      this.startAutoFlip();
    }
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
        
        .flap.flipping-top .flap-content {
          top: 0;
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
      </div>
    `;

    this.shadowRoot.innerHTML = styles + html;
  }

  setupEventListeners() {
    const splitFlap = this.shadowRoot.querySelector(".split-flap");
    splitFlap.addEventListener("click", () => this.flipToNext());
  }

  flipToNext() {
    const nextIndex = (this.charIndex + 1) % this.chars.length;
    const nextChar = this.chars[nextIndex];

    this.flipTo(nextChar);
  }

  flipTo(targetChar) {
    if (!this.chars.includes(targetChar)) return;

    const targetIndex = this.chars.indexOf(targetChar);
    if (targetIndex === this.charIndex) return;

    const topFlap = this.shadowRoot.querySelector(".flap.top");
    const bottomFlap = this.shadowRoot.querySelector(".flap.bottom");
    const flippingTop = this.shadowRoot.querySelector(".flap.flipping-top");

    // Prepare the bottom flap to show next character
    bottomFlap.querySelector(".flap-content").textContent = targetChar;

    // Set up the flipping flap with current character
    flippingTop.querySelector(".flap-content").textContent = this.currentChar;

    // Create timeline for the flip animation
    const tl = gsap.timeline({
      onComplete: () => {
        // Update the top flap to show next character
        topFlap.querySelector(".flap-content").textContent = targetChar;

        // Reset flipping flap
        gsap.set(flippingTop, { opacity: 0, rotateX: 0 });

        // Update current state
        this.currentChar = targetChar;
        this.charIndex = targetIndex;

        // Dispatch custom event
        this.dispatchEvent(
          new CustomEvent("flip", {
            detail: { character: targetChar, index: targetIndex },
          })
        );
      },
    });

    // Animate the flip
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

  startAutoFlip() {
    this.autoFlipTimer = setInterval(() => {
      this.flipToNext();
    }, this.flipInterval);
  }

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
    if (name === "value" && newValue !== oldValue) {
      this.flipTo(newValue);
    }
  }
}

// Register the custom element
customElements.define("split-flap-display", SplitFlapDisplay);
