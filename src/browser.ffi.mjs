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

/**
 * Clears a timeout by its ID
 * @param {number} id - Timer ID to clear
 * @returns {void}
 */
export function clear_timeout(id) {
  window.clearTimeout(id);
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
  const wide = rect.width / rect.height > 1;
  return wide ? "landscape" : "portrait";
}

/** @type {ResizeObserver | null} */
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

gsap.registerPlugin(TextPlugin);
gsap.config({
  force3D: true,
});

/**
 * Calculates distance between two characters in the adjacency list
 * @param {string} from - Starting character
 * @param {string} to - Destination character
 * @param {Record<string, string>} adjacencyList - Map of character to next character
 * @returns {number} Distance between characters
 */
function getDistance(from, to, adjacencyList) {
  if (!from || !to) {
    console.error("Invalid characters", { from, to });
    return 0;
  }
  if (!(from in adjacencyList) || !(to in adjacencyList)) {
    console.error("Invalid list", { adjacencyList, from, to });
    return 0;
  }

  let dist = 0;
  let current = from;
  while (current !== to) {
    current = adjacencyList[current];
    dist++;
  }
  return dist;
}

/**
 * Creates a flip animation timeline for a split-flap element
 * @param {HTMLElement} el - The split-flap element to animate
 * @param {Record<string, string>} adjacencyList - Map of character transitions
 * @returns {gsap.core.Timeline | null} GSAP timeline or null if no animation needed
 */
export function flip(el, adjacencyList) {
  const topContent = el.querySelector(`.top > .flap-content`);
  const bottom = el.querySelector(`.bottom`);
  const bottomContent = bottom.querySelector(`.flap-content`);
  const flippingBottom = el.querySelector(`.flipping-bottom`);
  const flippingBottomContent = flippingBottom.querySelector(`.flap-content`);

  let destination = el.dataset.dest || " ";
  let distance = 0;
  let curr = topContent.textContent || " ";
  let from = curr;
  let next = (() => {
    if (curr in adjacencyList) {
      return adjacencyList[curr];
    }
    distance = 1;
    from = " ";
    return " ";
  })();

  distance += getDistance(from, destination, adjacencyList);
  if (distance === 0) {
    return null;
  }

  let timeline = gsap
    .timeline({
      force3D: true,
      onInterrupt: () => {
        console.log("interrupted!");
      },
    })
    .set(bottom, { opacity: 1 }, 0);

  while (distance > 0) {
    timeline = timeline
      .call(() => {
        topContent.textContent = next;
        bottomContent.textContent = curr;
        flippingBottomContent.textContent = next;
        curr = next;
        next = adjacencyList[curr];
      }, 0)
      .to(flippingBottom, {
        rotationX: 0,
        duration: 0.04,
        ease: "power1.inOut",
      })
      .set(flippingBottom, { rotationX: 90 }, ">")
      .addLabel(`${distance}`, ">");

    distance--;
  }
  timeline = timeline.set(bottom, { opacity: 0 }, ">");

  return timeline;
}

/** @type {Record<string, gsap.core.Timeline>} */
let timelines = {};

/** @type {string[]} */
const selectors = [".display", "#pagination"];

/**
 * Animates all split-flap displays on the page
 * @returns {void}
 */
export function animate() {
  for (const selector of selectors) {
    /** @type HTMLElement */
    const display = document.querySelector(selector);

    /** @type {Record<string, string>} */
    const adjacencyList = JSON.parse(display.dataset.adjacencyList);
    /** @type {NodeListOf<HTMLElement>} */
    const displayEls = display.querySelectorAll(".split-flap");

    if (timelines[selector]) {
      timelines[selector].pause();
      timelines[selector].getChildren(true, false, true).forEach((child) => {
        child.seek(child.nextLabel());
        child.kill();
      });
      timelines[selector].kill();
      delete timelines[selector];
    }

    timelines[selector] = gsap.timeline({
      paused: true,
      force3D: true,
    });

    let i = 0;
    /** @ts-expect-error displayEls is iterable somehow */
    for (const el of displayEls) {
      const child = flip(el, adjacencyList);
      if (child) {
        timelines[selector] = timelines[selector].add(child, 0);
      }
      i++;
    }

    timelines[selector].play();
  }
}
