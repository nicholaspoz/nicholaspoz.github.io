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

console.log(gsap);

export function animate_stuff() {
  let all = document
    .querySelector("nick-dot-bingo-v2")
    .#shadowRoot.querySelectorAll(".split-flap");

  console.log("HELLO", all);

  // const tl = gsap.timeline();
  // tl.to(all, {
  //   rotationX: 80,
  //   duration: 1,
  //   ease: "power2.inOut",
  // });
}
