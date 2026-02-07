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

const FLIP_DURATIONS = [0.028, 0.03, 0.032, 0.034];
const FALLBACK_CHAR = " ";

/** @type {Record<string, gsap.core.Timeline>} */
let timelines = {};

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
 * Calculates distance between two characters in the adjacency list
 * @param {string} from - Starting character
 * @param {string} to - Destination character
 * @param {Record<string, string>} adjacencyList - Map of character to next character
 * @returns {number} Distance between characters
 */
function getDistance(from, to, adjacencyList) {
  if (!from || !to || !(from in adjacencyList) || !(to in adjacencyList)) {
    console.error("Invalid distance calculation", { from, to, adjacencyList });
    return 0;
  }

  let distance = 0;
  let current = from;
  while (current !== to) {
    current = adjacencyList[current];
    distance++;
  }
  return distance;
}

/**
 * Resolves the first "next" character and calculates total flip distance. If
 * current char is unknown, manufactures a flip from current → fallback first.
 *
 * @param {string} current - Current displayed character
 * @param {string} destination - Target character
 * @param {Record<string, string>} adjacencyList - Character transition map
 * @returns {{ next: string, distance: number }} First next char and total distance
 */
function resolveFlipDistance(current, destination, adjacencyList) {
  if (current in adjacencyList) {
    return {
      next: adjacencyList[current],
      distance: getDistance(current, destination, adjacencyList),
    };
  }
  // Unknown char: flip to fallback first, then continue from there
  return {
    next: FALLBACK_CHAR,
    distance: 1 + getDistance(FALLBACK_CHAR, destination, adjacencyList),
  };
}

/**
 * Gets required DOM elements from a split-flap element
 *
 * @param {HTMLElement} el - The split-flap element
 * @returns {FlipElements | null} DOM elements or null if incomplete
 * @typedef {{
 *   topContent: Element,
 *   bottom: Element,
 *   bottomContent: Element,
 *   flippingBottom: Element,
 *   flippingBottomContent: Element
 * }} FlipElements
 */
function getFlipElements(el) {
  const topContent = el.querySelector(".top > .flap-content");
  const bottom = el.querySelector(".bottom");
  const bottomContent = bottom?.querySelector(".flap-content");
  const flippingBottom = el.querySelector(".flipping-bottom");
  const flippingBottomContent = flippingBottom?.querySelector(".flap-content");

  if (
    !topContent ||
    !bottom ||
    !bottomContent ||
    !flippingBottom ||
    !flippingBottomContent
  ) {
    return null;
  }

  return {
    topContent,
    bottom,
    bottomContent,
    flippingBottom,
    flippingBottomContent,
  };
}

/**
 * Builds flip animation frames on the timeline
 *
 * @param {gsap.core.Timeline} timeline - Timeline to build on
 * @param {FlipElements} elements - DOM elements to animate
 * @param {string} current - Current displayed character
 * @param {string} next - First character to flip to
 * @param {number} distance - Number of flips
 * @param {Record<string, string>} adjacencyList - Character transition map
 * @param {number} duration - Duration per flip
 */
function buildFlipFrames(
  timeline,
  elements,
  current,
  next,
  distance,
  adjacencyList,
  duration,
) {
  const { topContent, bottomContent, flippingBottom, flippingBottomContent } =
    elements;

  for (let i = distance; i > 0; i--) {
    const currChar = current;
    const nextChar = next;

    timeline
      .set(topContent, { text: nextChar })
      .set(bottomContent, { text: currChar })
      .set(flippingBottomContent, { text: nextChar })
      .to(flippingBottom, {
        rotationX: 0,
        duration,
        ease: "none",
      })
      .set(flippingBottom, { rotationX: 90 })
      .set(bottomContent, { text: nextChar })
      .addLabel(`flip-${i}`);

    current = next;
    next = adjacencyList[current];
  }
}

function randomFlipDuration() {
  return FLIP_DURATIONS[Math.floor(Math.random() * FLIP_DURATIONS.length)];
}

/**
 * Cleans up an existing timeline, jumping children to completion
 *
 * @param {string} selector - Timeline selector key
 */
function cleanupTimeline(selector) {
  const timeline = timelines[selector];
  if (!timeline) return;

  timeline.pause();
  timeline
    .getChildren(true, false, true)
    .forEach((/** @type {gsap.core.Timeline} */ child) => {
      child.pause();
      // const nextLabel = child.nextLabel();
      // if(nextLabel)child.seek(nextLabel);
      child.progress(1);
      child.kill();
    });
  // timeline.kill();
  delete timelines[selector];
}

/**
 * Creates a flip animation timeline for a split-flap element
 *
 * @param {HTMLElement} el - The split-flap element to animate
 * @param {Record<string, string>} adjacencyList - Map of character transitions
 * @returns {gsap.core.Timeline | null} GSAP timeline or null if no animation needed
 */
function animate_flips(el, adjacencyList) {
  const elements = getFlipElements(el);
  if (!elements) return null;

  const destination = el.dataset.dest || FALLBACK_CHAR;
  const current = elements.topContent.textContent || FALLBACK_CHAR;

  const { next, distance } = resolveFlipDistance(
    current,
    destination,
    adjacencyList,
  );
  if (distance === 0) return null;

  const timeline = gsap.timeline({
    smoothChildTiming: true,
    paused: true,
  });

  buildFlipFrames(
    timeline,
    elements,
    current,
    next,
    distance,
    adjacencyList,
    randomFlipDuration(),
  );

  timeline.addLabel("end");

  // timeline.set(elements.bottomContent, { text: destination }, ">");

  return timeline;
}

/**
 * Animates all split-flap displays on the page.
 *
 * @returns {void}
 */
export function animate() {
  for (const [selector, adjacencyList] of Object.entries(adjacencyLists)) {
    cleanupTimeline(selector);

    timelines[selector] = gsap.timeline({ paused: true });

    const splitFlaps = document.querySelectorAll(
      `[data-name=${selector}] > .split-flap`,
    );
    for (const el of splitFlaps) {
      const child = animate_flips(
        /** @type {HTMLElement} */ (el),
        adjacencyList,
      );
      if (child) {
        timelines[selector].add(child, 0);
        child.paused(false);
      }
    }

    timelines[selector].play();
  }
}
