// Week 1, "Step 3: Prior × likelihood → posterior": combines the prior drawn on the
// Step 1 slide with a binomial likelihood for a survey and plots all three curves.
import { PosteriorPlot } from './posterior.js';
import { POINTS, STEP, loadPrior, savePrior } from './poll-store.js';
import { brand, withAlpha } from './palette.js';

// Fine grid over θ; the 21 prior points are interpolated onto it
const G = 201;
const xs = Array.from({ length: G }, (_, i) => i / (G - 1));
const dx = 1 / (G - 1);
const PER_POINT = (G - 1) / (POINTS - 1); // grid steps between prior points

const $ = (id) => document.getElementById(id);
const graphEl = $('poll-post-graph');

function interpolate(points) {
  return xs.map((x) => {
    const p = x / STEP;
    const i = Math.min(POINTS - 2, Math.floor(p));
    const t = p - i;
    return points[i] * (1 - t) + points[i + 1] * t;
  });
}

// Probability mass on each grid point (sums to 1), or null if all zero
function toMass(v) {
  const s = v.reduce((a, b) => a + b, 0);
  return s > 0 ? v.map((a) => a / s) : null;
}

// Binomial likelihood up to a constant, computed on the log scale so large
// surveys don't underflow
function likelihood(k, n) {
  const ll = xs.map((x) => {
    let l = 0;
    if (k > 0) l += k * Math.log(x);
    if (n - k > 0) l += (n - k) * Math.log(1 - x);
    return l;
  });
  const m = Math.max(...ll.filter(Number.isFinite));
  return ll.map((l) => (Number.isFinite(l) ? Math.exp(l - m) : 0));
}

function summarize(mass) {
  const mean = mass.reduce((a, w, i) => a + w * xs[i], 0);
  const quantile = (q) => {
    let cum = 0;
    for (let i = 0; i < G; i++) {
      cum += mass[i];
      if (cum >= q) return xs[i];
    }
    return 1;
  };
  let win = 0;
  for (let i = 0; i < G; i++) {
    if (xs[i] > 0.5) win += mass[i];
    else if (xs[i] === 0.5) win += mass[i] / 2;
  }
  return { mean, lo: quantile(0.05), hi: quantile(0.95), win };
}

const pct = (x) => `${Math.round(x * 100)}%`;
const prob = (x) => (x < 0.01 ? '< 1%' : x > 0.99 ? '> 99%' : pct(x));

function showStats(prefix, s) {
  $(`poll-${prefix}-mean`).textContent = s ? pct(s.mean) : '—';
  $(`poll-${prefix}-range`).textContent = s ? `${pct(s.lo)} – ${pct(s.hi)}` : '—';
  $(`poll-${prefix}-win`).textContent = s ? prob(s.win) : '—';
}

if (graphEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';

  const colors = { prior: brand('red'), likelihood: brand('blue'), posterior: brand('green') };
  const plot = new PosteriorPlot({ container: graphEl });
  const nInput = $('poll-n');
  const shareInput = $('poll-share');
  let priorPoints = loadPrior();
  let posteriorMass = null;

  function update() {
    const n = Number(nInput.value);
    const k = Math.round((n * Number(shareInput.value)) / 100);
    $('poll-n-out').textContent = n;
    $('poll-share-out').textContent = `${k} of ${n} (${n > 0 ? pct(k / n) : '—'})`;

    const prior = toMass(interpolate(priorPoints));
    const lik = toMass(likelihood(k, n));
    const post = prior ? toMass(prior.map((p, i) => p * lik[i])) : null;
    posteriorMass = post;

    showStats('prior', prior && summarize(prior));
    showStats('post', post && summarize(post));
    $('poll-msg').textContent = !prior
      ? 'Your prior rules out every value of θ.'
      : !post
        ? 'Your prior rules out everything the data allow.'
        : '';
    $('poll-carry').disabled = !post;

    const density = (m) => (m ? m.map((w) => w / dx) : xs.map(() => 0));
    plot.setSeries([
      { label: 'Prior', color: colors.prior, xs, ys: density(prior) },
      { label: 'Likelihood', color: colors.likelihood, xs, ys: density(lik), dash: [8, 6] },
      {
        label: 'Posterior', color: colors.posterior, xs, ys: density(post),
        fill: withAlpha(colors.posterior, 0.12),
      },
    ]);
  }

  nInput.addEventListener('input', update);
  shareInput.addEventListener('input', update);

  window.addEventListener('poll-prior:change', (e) => {
    if (Array.isArray(e.detail)) {
      priorPoints = e.detail.slice();
      update();
    }
  });

  // Today's posterior is tomorrow's prior: sample it back onto the 21 draggable
  // points, then clear the survey so the data isn't counted twice
  $('poll-carry').addEventListener('click', () => {
    if (!posteriorMass) return;
    const coarse = Array.from({ length: POINTS }, (_, i) => posteriorMass[i * PER_POINT]);
    const max = Math.max(...coarse);
    if (!(max > 0)) return;
    priorPoints = coarse.map((v) => (v / max) * 100);
    savePrior(priorPoints, 'poll-prior:set');
    nInput.value = 0;
    update();
  });

  update();
}
