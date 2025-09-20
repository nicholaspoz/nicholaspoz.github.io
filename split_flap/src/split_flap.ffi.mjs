export function set_timeout(delay, cb) {
  return window.setTimeout(cb, delay);
}

export function clear_timeout(id) {
  window.clearTimeout(id);
}

export function measure_orientation(root) {
  const rect = root?.host?.getBoundingClientRect() || {
    width: 0,
    height: 0,
  };
  const wide = rect.width / rect.height > 1;
  return wide ? "landscape" : "portrait";
}

let observer = null;
export function on_resize(root, cb) {
  if (observer) {
    return;
  }
  observer = new ResizeObserver(cb);
  observer.observe(root.host);
}

gsap.registerPlugin(TextPlugin);
gsap.config({
  force3D: true,
});

let timeline;
let charState = {};
let adjacencyList = {};
let desiredState = {};

function getState(id) {
  return charState[id] || " ";
}

function getNext(char) {
  return adjacencyList[char] || " ";
}

function getDistance(from, to) {
  if (!(from in adjacencyList) || !(to in adjacencyList)) {
    console.error("Invalid characters", from, to);
    return 0;
  }

  let dist = 0;
  let current = from;
  while (current !== to) {
    current = getNext(current);
    dist++;
  }
  return dist;
}

function flip(el, times) {
  const id = el.id;
  function curr() {
    return charState[id] || " ";
  }

  function next() {
    return adjacencyList[curr()];
  }

  const topContent = el.querySelector(`.top > .flap-content`);
  const bottomContent = el.querySelector(`.bottom > .flap-content`);
  const flippingBottomContent = el.querySelector(
    `.flipping-bottom > .flap-content`
  );
  const flippingBottom = el.querySelector(`.flipping-bottom`);

  return gsap
    .timeline({
      // paused: true,
      onStart: () => {
        topContent.textContent = next();
        bottomContent.textContent = curr();
        flippingBottomContent.textContent = next();
      },
      onRepeat: () => {
        charState[id] = next();
        topContent.textContent = next();
        bottomContent.textContent = curr();
        flippingBottomContent.textContent = next();
      },
      onComplete: () => {
        charState[id] = next();
        bottomContent.textContent = curr();
        flippingBottomContent.textContent = curr();
      },
    })
    .set(flippingBottom, { rotationX: 90 }, 0)
    .to(flippingBottom, {
      rotationX: 0,
      duration: 0.05,
      ease: "power1.inOut",
    })
    .set(flippingBottom, { rotationX: 90 }, ">")
    .repeat(times - 1);
}

// TODO
export function set_adjacency_list(list) {
  adjacencyList = list;
}

export function animate_stuff() {
  adjacencyList = {
    " ": "A",
    A: "B",
    B: "C",
    C: "D",
    D: "E",
    E: "F",
    F: "G",
    G: "H",
    H: " ",
  };

  desiredState = {
    "1-1": "A",
    "1-2": "B",
    "1-3": "C",
    "1-4": "D",
    "1-5": "E",
    "1-6": "F",
    "1-7": "G",
  };

  let all = document
    .querySelector("nick-dot-bingo-v2")
    .shadowRoot.querySelectorAll(".split-flap");

  console.log("All", all);

  if (timeline) {
    timeline.pause();
    timeline.progress(0);
    timeline.kill();
  }

  timeline = gsap.timeline({
    paused: true,
    // autoRemoveChildren: true,
    onComplete: function () {
      console.log(charState);
    },
  });

  for (const el of all) {
    if (!(el.id in desiredState)) {
      continue;
    }
    let from = getState(el.id);
    let to = desiredState[el.id];
    let distance = getDistance(from, to);
    // console.log("Distance", el.id, from, to, distance);
    if (distance === 0) {
      continue;
    }
    timeline.add(flip(el, distance), 0);
  }

  // console.log("Timeline", timeline);

  timeline.play();
}
