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
      document.body.setAttribute("style", "height: 105svh");
    });
    setTimeout(() => {
      window.requestAnimationFrame(() => {
        document.body.removeAttribute("style");
      });
    }, 20);
  }, 400);
});

// MARK: GSAP Animation

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
 * @type {Record<string, gsap.core.Timeline>}
 */
let timelines = {};

/**
 * @type {Record<string, Record<string, string>>}
 */
const adjacencyLists = {};

/**
 * @param {string} name
 * @param {Record<string, string>} adjacency_list
 */
export function set_adjacency_list(name, adjacency_list) {
  console.log(name, adjacency_list);
  adjacencyLists[name] = adjacency_list;
}

/**
 * Animates all split-flap displays on the page.
 * Reads each display's `data-adjacency-list` attribute and animates
 * each character to its `data-dest` destination.
 * @returns {void}
 */
export function animate() {
  for (const [selector, adjacencyList] of Object.entries(adjacencyLists)) {
    // Clean up existing timeline for this selector
    if (timelines[selector]) {
      timelines[selector].pause();
      timelines[selector].getChildren(true, false, true).forEach((child) => {
        child.progress(1); // Jump to end so character lands on destination
        child.kill();
      });
      timelines[selector].kill();
      delete timelines[selector];
    }

    timelines[selector] = gsap.timeline({ paused: true });

    const splitFlaps = document.querySelectorAll(
      `[data-name=${selector}] > .split-flap`,
    );
    for (const el of splitFlaps) {
      const child = flip(/** @type {HTMLElement} */ (el), adjacencyList);
      if (child) {
        timelines[selector] = timelines[selector].add(child, 0);
      }
    }

    timelines[selector].play();
  }
}

/**
 * Creates a flip animation timeline for a split-flap element
 * @param {HTMLElement} el - The split-flap element to animate
 * @param {Record<string, string>} adjacencyList - Map of character transitions
 * @returns {gsap.core.Timeline | null} GSAP timeline or null if no animation needed
 */
function flip(el, adjacencyList) {
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

  const destination = el.dataset.dest || " ";
  let distance = 0;
  let curr = topContent.textContent || " ";
  const from = curr;

  let next = (() => {
    if (curr in adjacencyList) {
      return adjacencyList[curr];
    }
    distance = 1;
    return " ";
  })();

  distance += getDistance(
    curr in adjacencyList ? from : " ",
    destination,
    adjacencyList,
  );
  if (distance === 0) {
    return null;
  }

  let timeline = gsap.timeline().set(bottom, { opacity: 1 }, 0);
  const duration = [0.03, 0.045, 0.04, 0.045][Math.floor(Math.random() * 4)];

  while (distance > 0) {
    timeline = timeline
      .call(() => {
        topContent.textContent = next;
        bottomContent.textContent = curr;
        flippingBottomContent.textContent = next;
        curr = next;
        next = adjacencyList[curr];
      })
      .to(flippingBottom, {
        rotationX: 0,
        duration,
        ease: "power1.inOut",
      })
      .set(flippingBottom, { rotationX: 90 }, ">")
      .addLabel(`${distance}`, ">");

    distance--;
  }

  timeline = timeline.set(bottom, { opacity: 0 }, ">");
  return timeline;
}
