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

function flip(el, adjacencyList) {
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

let timelines = {};

const selectors = [".display", "#pagination"];

export function animate() {
  for (const selector of selectors) {
    const display = document
      .querySelector("nick-dot-bingo-v2")
      .shadowRoot.querySelector(selector);

    const adjacencyList = JSON.parse(display.dataset.adjacencyList);
    const displayEls = display.querySelectorAll(".split-flap");

    if (timelines[selector]) {
      timelines[selector].pause();
      timelines[selector].getChildren(true, false, true).forEach((child) => {
        child.seek(child.nextLabel());
        child.kill();
      });
      // timelines[selector].progress(1);
      timelines[selector].kill();
      delete timelines[selector];
    }

    timelines[selector] = gsap.timeline({
      paused: true,
      force3D: true,
    });

    let i = 0;
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
