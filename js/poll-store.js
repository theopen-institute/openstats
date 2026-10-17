// The poll prior shared by week 1's "Step 1: The prior" and "Step 3: Prior ×
// likelihood → posterior" slides. It lives on window for the current session
// and in localStorage across reloads.

export const POINTS = 21; // draggable prior points, at θ = 0, 0.05, ..., 1
export const STEP = 1 / (POINTS - 1);
const STORAGE_KEY = 'week1-poll-prior-v1';

export const flatPrior = () => Array.from({ length: POINTS }, () => 50);

export function loadPrior() {
  if (Array.isArray(window.__pollPrior)) return window.__pollPrior.slice();
  try {
    const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY));
    if (Array.isArray(parsed) && parsed.length === POINTS) return parsed.map(Number);
  } catch {
    // ignore storage errors
  }
  return flatPrior();
}

// Store a new prior and announce it:
//   'poll-prior:change' — the prior widget changed it (the posterior listens)
//   'poll-prior:set'    — another slide wants the prior widget to show it
export function savePrior(values, event = 'poll-prior:change') {
  window.__pollPrior = values.slice();
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(values));
  } catch {
    // ignore storage errors
  }
  window.dispatchEvent(new CustomEvent(event, { detail: values.slice() }));
}
