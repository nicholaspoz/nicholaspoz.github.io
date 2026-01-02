// @ts-check

import {
  Result$Ok,
  Result$Error,
  List$Empty,
  List$NonEmpty,
  // @ts-ignore
} from "./gleam.mjs";

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
 *
 * @param {string} selector
 */
export function doc_query_selector(selector) {
  const e = document.querySelector(selector);
  if (e) {
    return Result$Ok(e);
  }
  return Result$Error(undefined); // Error(Nil)
}

/**
 *
 * @param {HTMLElement} el
 * @param {string} selector
 */
export function el_query_selector(el, selector) {
  const e = el.querySelector(selector);
  if (e) {
    return Result$Ok(e);
  }
  return Result$Error(undefined); // Error(Nil)
}

/**
 * @param {HTMLElement} el
 * @param {string} selector
 */
export function el_query_selector_all(el, selector) {
  const els = el.querySelectorAll(selector);
  // @ts-ignore
  return [...els].reduce((acc, e) => List$NonEmpty(e, acc), new List$Empty());
}

export function new_timeline() {
  return gsap.timeline({ paused: true });
}

/**
 * @param {gsap.core.Timeline} timeline
 */
export function stop_children(timeline) {
  timeline.pause();
  timeline.getChildren(true, false, true).forEach((child) => {
    child.seek(child.nextLabel());
    child.kill();
  });
  timeline.kill();
}

/**
 * @param {gsap.core.Timeline} parent
 * @param {gsap.core.Timeline} child
 */
export function add_child(parent, child) {
  return parent.add(child, 0);
}

/**
 * @param {gsap.core.Timeline} timeline
 */
export function play(timeline) {
  return timeline.play();
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
    if (timelines[selector]) {
      timelines[selector].pause();
      timelines[selector].getChildren(true, false, true).forEach((child) => {
        child.seek(child.nextLabel());
        child.kill();
      });
      timelines[selector].kill();
      delete timelines[selector];
    }

    timelines[selector] = gsap.timeline({ paused: true });

    /** @type HTMLElement */
    const display = document.querySelector(selector);

    /** @type {Record<string, string>} */
    const adjacencyList = JSON.parse(display.dataset.adjacencyList);
    const displayEls = display.querySelectorAll(".split-flap");

    /** @ts-expect-error displayEls is iterable somehow */
    for (const el of displayEls) {
      const child = flip(el, adjacencyList);
      if (child) {
        timelines[selector] = timelines[selector].add(child, 0);
      }
    }

    timelines[selector].play();
  }
}

export function apply_flip(el, adjacencyList) {
  return flip(el, adjacencyList);
}

/**
 *
 * @param {HTMLElement} el
 * @returns {string}
 */
export function get_destination(el) {
  return el.dataset.dest || " ";
}

/**
 * @param {HTMLElement} el
 * @returns {string}
 */
export function get_text_content(el) {
  return el.textContent || " ";
}

/**
 * @param {HTMLElement} el
 * @param {string} text
 */
export function set_text_content(el, text) {
  el.textContent = text;
}

/**
 * @param {gsap.core.Timeline} tl
 * @param {HTMLElement} el
 * @param {any} params
 * @param {string | number} position
 */
export function tl_set(tl, el, params, position) {
  return tl.set(el, params, position);
}

/**
 * @param {gsap.core.Timeline} tl
 * @param {() => void} cb
 * @param {string | number} position
 */
export function tl_call(tl, cb, position) {
  return tl.call(cb, position);
}

/**
 * @param {gsap.core.Timeline} tl
 * @param {HTMLElement} el
 * @param {any} params
 */
export function tl_to(tl, el, params) {
  return tl.to(el, params);
}

/**
 * Creates a flip animation timeline for a split-flap element
 *
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

  let timeline = gsap.timeline().set(bottom, { opacity: 1 }, 0);

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
