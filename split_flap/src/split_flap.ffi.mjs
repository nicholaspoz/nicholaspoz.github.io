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
