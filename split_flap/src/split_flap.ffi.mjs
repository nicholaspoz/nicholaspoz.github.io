export function set_timeout(delay, cb) {
  return window.setTimeout(cb, delay);
}

export function clear_timeout(id) {
  window.clearTimeout(id);
}
