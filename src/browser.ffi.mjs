// @ts-check

/**
 * Sets a timeout and returns the timer ID
 * @param {number} delay - Delay in milliseconds
 * @param {() => void} cb - Callback function to execute
 * @returns {number} Timer ID
 */
export function set_timeout(delay, cb) {
  return window.setTimeout(cb, delay);
}

export function get_path() {
  return window.location.pathname;
}

/**
 * Clears a timeout by its ID
 * @param {number} id - Timer ID to clear
 * @returns {void}
 */
export function clear_timeout(id) {
  window.clearTimeout(id);
}

export function update_flap_height() {
  const flapHeight =
    document.querySelector(".split-flap")?.getBoundingClientRect().height ?? 0;

  document.documentElement.style.setProperty(
    "--flap-height",
    `${flapHeight}px`,
  );
}

/**
 * Measures the orientation of an element
 * @param {HTMLElement | null} root - Root element to measure
 * @returns {"landscape" | "portrait"} Element orientation
 */
export function measure_orientation(root) {
  const rect = root?.getBoundingClientRect() || {
    width: 0,
    height: 0,
  };

  const aspectRatio = rect.height / rect.width < 1;
  return aspectRatio ? "landscape" : "portrait";
}

/**
 * @type {ResizeObserver | null}
 */
let observer = null;

/**
 * Observes resize events on the root element
 * @param {HTMLElement} root - Element to observe
 * @param {ResizeObserverCallback} cb - Callback for resize events
 * @returns {void}
 */
export function on_resize(root, cb) {
  if (observer) {
    return;
  }
  observer = new ResizeObserver(cb);
  observer.observe(root);
}

/**
 * Silly hack to fix iOS orientation + resizing issue
 */
screen.orientation.addEventListener("change", (event) => {
  const type = /** @type {ScreenOrientation} */ (event.target).type;
  if (type.startsWith("portrait")) return;

  setTimeout(() => {
    window.requestAnimationFrame(() => {
      document.body.setAttribute("style", "height: 101svh");
    });
    setTimeout(() => {
      window.requestAnimationFrame(() => {
        document.body.removeAttribute("style");
      });
    }, 20);
  }, 400);
});

// MARK: GSAP Animation

gsap.config({ force3D: true });

const FLIP_DURATIONS = [0.026, 0.028, 0.03, 0.032, 0.034];
const FALLBACK_CHAR = " ";

/** @type {Record<string, Record<string, string>>} */
const adjacencyLists = {};

/**
 * @param {string} name
 * @param {Record<string, string>} adjacency_list
 */
export function set_adjacency_list(name, adjacency_list) {
  adjacencyLists[name] = adjacency_list;
}

/**
 * @typedef {{
 *   topContent: HTMLElement,
 *   bottomContent: HTMLElement,
 *   flippingBottom: HTMLElement,
 *   flippingBottomContent: HTMLElement
 * }} FlipElements
 */

/**
 * Gets required DOM elements from a split-flap element
 *
 * @param {HTMLElement} el - The split-flap element
 * @returns {FlipElements | null} DOM elements or null if incomplete
 */
function getFlipElements(el) {
  const topContent = /** @type {HTMLElement | null} */ (
    el.querySelector(".top > .flap-content")
  );
  const bottomContent = /** @type {HTMLElement | null} */ (
    el.querySelector(".bottom > .flap-content")
  );
  const flippingBottom = /** @type {HTMLElement | null} */ (
    el.querySelector(".flipping-bottom")
  );
  const flippingBottomContent = /** @type {HTMLElement | null} */ (
    flippingBottom?.querySelector(".flap-content")
  );

  if (
    !topContent ||
    !bottomContent ||
    !flippingBottom ||
    !flippingBottomContent
  ) {
    return null;
  }

  return { topContent, bottomContent, flippingBottom, flippingBottomContent };
}

function randomFlipDuration() {
  return FLIP_DURATIONS[Math.floor(Math.random() * FLIP_DURATIONS.length)];
}

// MARK: Per-Module State Machines

/** @type {Map<string, { setTarget: (char: string, adjList: Record<string, string>) => void }>} */
const modules = new Map();

/**
 * Creates a per-element flip loop controller.
 * The loop advances one character at a time through the adjacency list,
 * re-evaluating the target after each flip. Mid-animation retargeting
 * is handled naturally — no timeline killing needed.
 *
 * A single GSAP tween is created per module and reused via .restart()
 * to avoid allocation/GC overhead from creating tweens every flip step.
 *
 * @param {HTMLElement} el
 */
function createModule(el) {
  let currentChar =
    el.querySelector(".top .flap-content")?.textContent || FALLBACK_CHAR;
  let targetChar = currentChar;
  /** @type {Record<string, string>} */
  let adjacencyList = {};
  let flipping = false;
  const elements = getFlipElements(el);

  if (!elements) return { setTarget() {} };

  const { topContent, bottomContent, flippingBottom, flippingBottomContent } =
    elements;

  const resetRotation = gsap.quickSetter(flippingBottom, "rotationX");

  // Make sure we start out at 90 from the get-go
  resetRotation(90);

  const tween = gsap.to(
    flippingBottom,
    // { rotationX: 90 },
    {
      rotationX: 0,
      duration: randomFlipDuration(),
      ease: "none",
      paused: true,
      onComplete() {
        bottomContent.textContent = flippingBottomContent.textContent;
        resetRotation(90);
        flipLoop();
      },
    },
  );

  /**
   * @param {string} char
   * @param {Record<string, string>} adjList
   */
  function setTarget(char, adjList) {
    targetChar = char;
    adjacencyList = adjList;
    if (!flipping) flipLoop();
  }

  function flipLoop() {
    if (currentChar === targetChar) {
      flipping = false;
      el.classList.remove("is-flipping");
      return;
    }
    if (!flipping) {
      flipping = true;
      el.classList.add("is-flipping");
    }

    const nextChar =
      currentChar in adjacencyList ? adjacencyList[currentChar] : FALLBACK_CHAR;

    topContent.textContent = nextChar;
    bottomContent.textContent = currentChar;
    flippingBottomContent.textContent = nextChar;
    currentChar = nextChar;

    tween.duration(randomFlipDuration());
    tween.invalidate().restart();
  }

  return { setTarget };
}

/**
 * Sets targets on all split-flap modules, starting flip loops as needed.
 *
 * @returns {void}
 */
export function animate() {
  for (const [selector, adjacencyList] of Object.entries(adjacencyLists)) {
    const splitFlaps = document.querySelectorAll(
      `[data-name=${selector}] > .split-flap`,
    );

    for (const el of splitFlaps) {
      const htmlEl = /** @type {HTMLElement} */ (el);
      const dest = htmlEl.dataset.dest || FALLBACK_CHAR;
      const id = htmlEl.id;

      let mod = modules.get(id);
      if (!mod) {
        mod = createModule(htmlEl);
        modules.set(id, mod);
      }

      mod.setTarget(dest, adjacencyList);
    }
  }
}
