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

// Each time the slide holding el is activated: starting() as it begins to come into
// view, then arrived() once it has landed (after the slide transition, or at once when
// the deck opens on it). A fallback timer covers decks with transitions turned off,
// where reveal never reports the end of one.
const ARRIVAL_FALLBACK = 1200; // ms, a little longer than reveal's slide transition

export function onArrival(el, { starting, arrived }) {
  const R = window.Reveal;
  if (!R?.on) return;
  let waiting = false;
  let timer = null;
  const land = () => {
    if (!waiting) return;
    waiting = false;
    clearTimeout(timer);
    arrived();
  };
  const begin = () => {
    waiting = true;
    starting();
    clearTimeout(timer);
    timer = setTimeout(land, ARRIVAL_FALLBACK);
  };
  R.on('slidechanged', (e) => {
    if (e.currentSlide?.contains(el)) begin();
  });
  R.on('slidetransitionend', (e) => {
    if (e.currentSlide?.contains(el)) land();
  });
  // The deck opened on this slide: no transition to wait for
  const openedHere = () => {
    if (R.getCurrentSlide?.()?.contains(el)) {
      begin();
      land();
    }
  };
  if (R.isReady?.()) openedHere();
  else R.on('ready', openedHere);
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
