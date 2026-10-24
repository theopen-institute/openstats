// Smooth transitions for week 1's poll slides: plots (posterior.js) and the numbers in
// their tables ease from what's shown to each new value instead of jumping. Nothing
// moves for viewers who ask their system for reduced motion.

const reduced = window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;
export const DURATION = reduced ? 0 : 500; // ms

// Fast at first, gentle at the end, so a dragged slider feels immediate
export const ease = (t) => 1 - (1 - t) ** 3;

// Run step(eased progress, 0 to 1) once a frame for one transition. Returns a function
// that cancels it.
export function animate(step) {
  if (!DURATION) {
    step(1);
    return () => {};
  }
  const start = performance.now();
  let frame = requestAnimationFrame(function tick(now) {
    const t = Math.min(1, (now - start) / DURATION);
    step(ease(t));
    frame = t < 1 ? requestAnimationFrame(tick) : null;
  });
  return () => frame && cancelAnimationFrame(frame);
}

// Whether an element is on the slide being shown (always true outside a deck)
export function onCurrentSlide(el) {
  const current = window.Reveal?.getCurrentSlide?.();
  return !current || current.contains(el);
}

// Call fn each time the slide holding el has finished coming into view
export function whenShown(el, fn) {
  window.Reveal?.on?.('slidetransitionend', (e) => {
    if (e.currentSlide?.contains(el)) fn();
  });
}

// ---- Numbers in text ------------------------------------------------------------------

const shown = new WeakMap(); // el -> the value (number or array) on screen now
const cancels = new WeakMap();

// Ease el's text to `value` (a number, or an array of numbers), written by fmt. null
// shows a dash. A value already easing starts from wherever it is.
export function tweenText(el, value, fmt) {
  if (!el) return;
  cancels.get(el)?.();
  if (value == null) {
    shown.delete(el);
    el.textContent = '—';
    return;
  }
  const to = [].concat(value);
  const from = shown.get(el);
  if (!from || from.length !== to.length || !onCurrentSlide(el)) {
    shown.set(el, to);
    el.textContent = fmt(Array.isArray(value) ? to : to[0]);
    return;
  }
  cancels.set(el, animate((e) => {
    const now = to.map((v, i) => from[i] + (v - from[i]) * e);
    shown.set(el, now);
    el.textContent = fmt(Array.isArray(value) ? now : now[0]);
  }));
}
