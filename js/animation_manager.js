/**
 * AnimationManager - Coordinates split-flap character animations
 *
 * Pure event-based approach that works with Shadow DOM
 * No DOM queries needed - uses event targets for element references
 */
class AnimationManager {
  constructor() {
    this.activeCharacters = new Set();
    this.maxConcurrentAnimations = 12; // Limit concurrent animations for performance
    this.animationQueue = [];

    // Listen for events from Gleam characters
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Character needs to animate
    document.addEventListener("animation-needed", (e) => {
      console.log("animation-needed", e);
      const charId = e.detail;
      const element = e.target; // Get element reference from event
      this.requestAnimation(charId, element);
    });

    // Character finished animating
    document.addEventListener("animation-complete", (e) => {
      const charId = e.detail;
      this.completeAnimation(charId);
    });
  }

  requestAnimation(charId, element) {
    // Avoid duplicate requests for same character
    if (this.activeCharacters.has(charId)) {
      return;
    }

    // Check if already in queue
    const alreadyQueued = this.animationQueue.some(
      (item) => item.charId === charId
    );
    if (alreadyQueued) {
      return;
    }

    if (this.activeCharacters.size < this.maxConcurrentAnimations) {
      // Start animation immediately
      this.startAnimation(charId, element);
    } else {
      // Queue for later
      this.animationQueue.push({ charId, element });
    }
  }

  startAnimation(charId, element) {
    this.activeCharacters.add(charId);

    // Dispatch event directly to the element (works with Shadow DOM)
    element.dispatchEvent(new CustomEvent("animation-start"));
  }

  completeAnimation(charId) {
    this.activeCharacters.delete(charId);

    // Start next queued animation if any
    if (this.animationQueue.length > 0) {
      const { charId: nextCharId, element } = this.animationQueue.shift();
      this.startAnimation(nextCharId, element);
    }
  }

  // Debug methods
  getStatus() {
    return {
      active: Array.from(this.activeCharacters),
      queued: this.animationQueue.map((item) => item.charId),
      activeCount: this.activeCharacters.size,
      queuedCount: this.animationQueue.length,
      maxConcurrent: this.maxConcurrentAnimations,
    };
  }

  setMaxConcurrentAnimations(max) {
    this.maxConcurrentAnimations = Math.max(1, max);

    // If we reduced the limit, don't interrupt active animations
    // Just let them finish naturally and the queue will catch up
  }

  // Force clear all animations (for debugging)
  reset() {
    this.activeCharacters.clear();
    this.animationQueue = [];
  }
}

// Create global instance
window.splitFlapAnimationManager = new AnimationManager();

// Debug access (no DOM queries needed!)
window.debugAnimations = () => {
  const status = window.splitFlapAnimationManager.getStatus();
  console.log("🎯 Animation Manager Status:");
  console.log(`   Active: ${status.activeCount} (${status.active.join(", ")})`);
  console.log(`   Queued: ${status.queuedCount} (${status.queued.join(", ")})`);
  console.log(`   Max Concurrent: ${status.maxConcurrent}`);
  console.log(
    `   Queue: [${status.queued.map((id) => id.substring(0, 8)).join(", ")}]`
  );
};

// Quick access for testing
window.setAnimationLimit = (max) => {
  window.splitFlapAnimationManager.setMaxConcurrentAnimations(max);
  console.log(`Animation limit set to ${max}`);
};

window.resetAnimations = () => {
  window.splitFlapAnimationManager.reset();
  console.log("All animations reset");
};
