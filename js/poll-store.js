// State shared by week 1's poll slides: the prior drawn on "Step 1: The prior" and the
// survey set on "Step 2: The likelihood", used by Step 3 and the slides after it. Each
// lives on window for the current session and in localStorage across reloads. The math
// is in poll-math.js.

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

// ---- The survey: n people asked, and the share (%) who said "mayor" -----------------

const SURVEY_KEY = 'week1-poll-survey-v2'; // v2: the default survey changed to 20%
export const DEFAULT_SURVEY = { n: 20, share: 20 };

// The number who said "mayor", from the survey size and share
export const surveyCount = ({ n, share }) => Math.round((n * share) / 100);

export function loadSurvey() {
  if (window.__pollSurvey) return { ...window.__pollSurvey };
  try {
    const parsed = JSON.parse(localStorage.getItem(SURVEY_KEY));
    if (parsed && Number.isFinite(parsed.n) && Number.isFinite(parsed.share)) return parsed;
  } catch {
    // ignore storage errors
  }
  return { ...DEFAULT_SURVEY };
}

// Store a new survey and announce it:
//   'poll-survey:change' — the Step 2 sliders changed it (Step 3 listens)
//   'poll-survey:set'    — another slide wants the Step 2 sliders to show it
export function saveSurvey(survey, event = 'poll-survey:change') {
  window.__pollSurvey = { ...survey };
  try {
    localStorage.setItem(SURVEY_KEY, JSON.stringify(survey));
  } catch {
    // ignore storage errors
  }
  window.dispatchEvent(new CustomEvent(event, { detail: { ...survey } }));
}

// Every event that changes what the poll slides show
export const POLL_EVENTS = [
  'poll-prior:change', 'poll-prior:set', 'poll-survey:change', 'poll-survey:set',
];
