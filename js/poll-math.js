// The math behind week 1's poll slides, shared by Steps 2 and 3, the "What if" slides
// (poll-whatif.js) and "Answering the question" (poll-answer.js): the drawn prior as a distribution over θ, the survey's
// likelihood, the posterior, and the numbers we read off them.
import { POINTS, STEP, surveyCount } from './poll-store.js';
import { smoothCurve } from './smooth.js';

// Fine grid over θ; the 21 drawn prior points are joined by a smooth curve on it
export const G = 201;
export const xs = Array.from({ length: G }, (_, i) => i / (G - 1));
const dx = 1 / (G - 1);
const PER_POINT = (G - 1) / (POINTS - 1); // grid steps between prior points

// Probability mass on each grid point (sums to 1), or null if all zero
export function toMass(v) {
  const s = v.reduce((a, b) => a + b, 0);
  return s > 0 ? v.map((a) => a / s) : null;
}

// The drawn prior (21 heights) as a distribution over the grid: the same smooth curve
// through the points that Step 1 draws (smooth.js), never below zero
export function priorMass(points) {
  const curve = smoothCurve(points);
  return toMass(xs.map((x) => Math.max(0, curve(x / STEP))));
}

// The survey's binomial likelihood over the grid, rescaled to sum to 1. Computed on the
// log scale so large surveys don't underflow.
export function likelihoodMass(survey) {
  const { n } = survey;
  const k = surveyCount(survey);
  const ll = xs.map((x) => {
    let l = 0;
    if (k > 0) l += k * Math.log(x);
    if (n - k > 0) l += (n - k) * Math.log(1 - x);
    return l;
  });
  const m = Math.max(...ll.filter(Number.isFinite));
  return toMass(ll.map((l) => (Number.isFinite(l) ? Math.exp(l - m) : 0)));
}

// Prior × likelihood, rescaled: null if the prior rules out everything the data allow
export function posteriorMass(prior, lik) {
  return prior && lik ? toMass(prior.map((p, i) => p * lik[i])) : null;
}

// One update, from the drawn prior and a survey
export function update(points, survey) {
  const prior = priorMass(points);
  const lik = likelihoodMass(survey);
  return { prior, lik, post: posteriorMass(prior, lik) };
}

// A distribution as heights to plot (a density, so curves on any grid compare)
export const density = (mass) => (mass ? mass.map((w) => w / dx) : xs.map(() => 0));

// A posterior back onto the 21 draggable points, scaled so its peak is 100
export function toPoints(mass) {
  const coarse = Array.from({ length: POINTS }, (_, i) => mass[i * PER_POINT]);
  const max = Math.max(...coarse);
  return max > 0 ? coarse.map((v) => (v / max) * 100) : null;
}

// Best guess (the mean), 90% range, and the chance of more than half the vote
export function summarize(mass) {
  const mean = mass.reduce((a, w, i) => a + w * xs[i], 0);
  const quantile = (q) => {
    let cum = 0;
    for (let i = 0; i < G; i++) {
      cum += mass[i];
      if (cum >= q) return xs[i];
    }
    return 1;
  };
  return { mean, lo: quantile(0.05), hi: quantile(0.95), win: majority(mass) };
}

export function majority(mass) {
  let win = 0;
  for (let i = 0; i < G; i++) {
    if (xs[i] > 0.5) win += mass[i];
    else if (xs[i] === 0.5) win += mass[i] / 2;
  }
  return win;
}

// ---- Exact binomial probabilities, for the tables ---------------------------------

// log(n!), computed as far as needed
const logFact = [0];
const logFactorial = (n) => {
  for (let i = logFact.length; i <= n; i++) logFact[i] = logFact[i - 1] + Math.log(i);
  return logFact[n];
};

// P( k of n | θ )
export function binomial(k, n, theta) {
  if (theta === 0) return k === 0 ? 1 : 0;
  if (theta === 1) return k === n ? 1 : 0;
  const logChoose = logFactorial(n) - logFactorial(k) - logFactorial(n - k);
  return Math.exp(logChoose + k * Math.log(theta) + (n - k) * Math.log(1 - theta));
}

// ---- Formatting -------------------------------------------------------------------

export const pct = (x) => `${Math.round(x * 100)}%`;
export const prob = (x) => (x < 0.01 ? '< 1%' : x > 0.99 ? '> 99%' : pct(x));
export const range = (s) => `${pct(s.lo)} – ${pct(s.hi)}`;

// Small numbers written out in full (0.0000017), like the lecture's examples
export function fmtNum(p) {
  if (p === 0) return '0';
  if (p >= 1) return p.toFixed(1);
  if (p >= 0.001) return p.toFixed(3);
  if (p < 1e-9) return '≈ 0';
  return p.toFixed(1 - Math.floor(Math.log10(p)));
}

export const surveyText = (survey) => {
  const k = surveyCount(survey);
  return survey.n > 0 ? `${k} of ${survey.n} (${pct(k / survey.n)})` : 'nobody asked';
};
