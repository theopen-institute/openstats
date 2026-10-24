// Week 1, the "What if" slides after Step 3: the class's own prior and survey, with one
// input changed at a time, to see how much the posterior depends on it. Each slide's
// markup is in _includes/week1/poll-whatif-*.md, and each part below runs only if its
// slide is in the deck.
//   "What if I'd started from a different prior?" — the drawn prior, moved or reshaped
//   "What if I'd asked more (or fewer) people?"    — the same result, another survey size
//   "What if the survey had come out differently?" — another result, the same size
// The class's own posterior stays on each plot in gray, for comparison. Changing the
// prior or survey on Steps 1–3 resets each slide to the class's own inputs.
import { PosteriorPlot } from './posterior.js';
import { DEFAULT_SURVEY, POLL_EVENTS, loadPrior, loadSurvey, surveyCount } from './poll-store.js';
import {
  density, likelihoodMass, pct, posteriorMass, prob, summarize, surveyText, toMass, update, xs,
} from './poll-math.js';
import { brand, withAlpha } from './palette.js';
import { tweenText } from './tween.js';

const $ = (id) => document.getElementById(id);
const GREEN = brand('green');

// The class's own inputs and posterior, from Steps 1 and 2
function ours() {
  const survey = loadSurvey();
  return { survey, ...update(loadPrior(), survey) };
}

// One what-if slide's plot and table: the class's posterior against the what-if one
function makeView(prefix) {
  const plot = new PosteriorPlot({ container: $(`${prefix}-graph`) });
  const stats = (suffix, mass) => {
    const s = mass && summarize(mass);
    tweenText($(`${prefix}-mean${suffix}`), s?.mean, pct);
    tweenText($(`${prefix}-range${suffix}`), s && [s.lo, s.hi], ([a, b]) => `${pct(a)} – ${pct(b)}`);
    tweenText($(`${prefix}-win${suffix}`), s?.win, prob);
  };
  return ({ base, prior, lik }) => {
    const post = posteriorMass(prior, lik);
    stats('-base', base.post);
    stats('', post);
    // Always the same four curves in the same order, so each eases into its next shape
    plot.setSeries([
      { label: 'Your posterior', color: brand('gray'), xs, ys: density(base.post), dash: [3, 5] },
      { label: 'Prior', color: brand('red'), xs, ys: density(prior) },
      { label: 'Likelihood', color: brand('blue'), xs, ys: density(lik), dash: [8, 6] },
      { label: 'What if', color: GREEN, xs, ys: density(post), fill: withAlpha(GREEN, 0.12) },
    ]);
  };
}

// Preset buttons: each calls apply(button) when clicked
function presets(id, apply) {
  for (const btn of $(id)?.querySelectorAll('button') ?? []) {
    btn.addEventListener('click', () => apply(btn));
  }
}

const parts = []; // each part's reset-and-redraw, run when Steps 1–3 change

// ---- A different prior ------------------------------------------------------------------

// The drawn prior moved by `shift` (a share, -0.4 to 0.4) and raised to `power`: 0 is
// flat (no opinion), 1 as drawn, more than 1 surer. Past the ends, it keeps its edge value.
function reshape(mass, shift, power) {
  if (!mass) return null;
  const last = xs.length - 1;
  return toMass(xs.map((x) => {
    const from = Math.min(last, Math.max(0, Math.round((x - shift) * last)));
    return mass[from] ** power;
  }));
}

// The "How sure" slider (0-100) as a power: 50 is as drawn, 0 flat, 100 four times as
// sharp
const power = (v) => (v / 50) ** 2;

function sureText(v) {
  const p = power(v);
  if (p === 0) return 'no opinion';
  if (p < 0.85) return 'less sure';
  if (p <= 1.2) return 'as drawn';
  return 'surer';
}

if ($('whatif-prior-graph')) {
  const draw = makeView('whatif-prior');
  const shiftIn = $('whatif-shift');
  const strengthIn = $('whatif-strength');

  const redraw = () => {
    const base = ours();
    const drawn = loadPrior();
    $('whatif-prior-flat').hidden = !drawn.every((p) => p === drawn[0]);
    const shift = Number(shiftIn.value);
    $('whatif-shift-out').textContent = shift === 0
      ? 'as drawn'
      : `${Math.abs(shift)} points ${shift < 0 ? 'lower' : 'higher'}`;
    $('whatif-strength-out').textContent = sureText(Number(strengthIn.value));
    draw({ base, prior: reshape(base.prior, shift / 100, power(Number(strengthIn.value))), lik: base.lik });
  };
  const set = (shift, strength) => {
    shiftIn.value = shift;
    strengthIn.value = strength;
    redraw();
  };

  shiftIn.addEventListener('input', redraw);
  strengthIn.addEventListener('input', redraw);
  presets('whatif-prior-presets', (b) => set(b.dataset.shift, b.dataset.strength));
  parts.push(() => set(0, 50));
}

// ---- More (or fewer) people -----------------------------------------------------------

// The size slider (0-100) on a log scale, so small surveys get as much room as big ones:
// 0 is nobody, 100 is 2,000 people
const MAX_N = 2000;
const sizeToN = (v) => (v <= 0 ? 0 : Math.round(MAX_N ** (v / 100)));
const nToSize = (n) => (n <= 0 ? 0 : (100 * Math.log(n)) / Math.log(MAX_N));

if ($('whatif-size-graph')) {
  const draw = makeView('whatif-size');
  const sizeIn = $('whatif-size');
  const oursBtn = $('whatif-size-presets').querySelector('[data-ours]');
  let n = 0;

  const redraw = () => {
    const base = ours();
    const survey = { ...base.survey, n };
    $('whatif-size-out').textContent = n === 0 ? 'nobody' : n.toLocaleString('en');
    $('whatif-size-said').textContent = n === 0 ? '—' : surveyText(survey);
    oursBtn.textContent = `Ours (${base.survey.n})`;
    draw({ base, prior: base.prior, lik: likelihoodMass(survey) });
  };
  const set = (size) => {
    n = size;
    sizeIn.value = nToSize(size);
    redraw();
  };

  sizeIn.addEventListener('input', () => {
    n = sizeToN(Number(sizeIn.value));
    redraw();
  });
  presets('whatif-size-presets', (b) => set('ours' in b.dataset ? ours().survey.n : Number(b.dataset.n)));
  parts.push(() => set(ours().survey.n));
}

// ---- A different result ---------------------------------------------------------------

if ($('whatif-result-graph')) {
  const draw = makeView('whatif-result');
  const shareIn = $('whatif-result');

  const redraw = () => {
    const base = ours();
    // Without a survey on Step 2, imagine one of the usual size
    const survey = { n: base.survey.n || DEFAULT_SURVEY.n, share: Number(shareIn.value) };
    $('whatif-result-out').textContent = `${surveyCount(survey)} of ${survey.n} (${pct(survey.share / 100)})`;
    draw({ base, prior: base.prior, lik: likelihoodMass(survey) });
  };
  const set = (share) => {
    shareIn.value = share;
    redraw();
  };

  shareIn.addEventListener('input', redraw);
  presets('whatif-result-presets', (b) => set('ours' in b.dataset ? ours().survey.share : Number(b.dataset.share)));
  parts.push(() => set(ours().survey.share));
}

// ---- Start each slide from the class's own inputs, and again whenever they change -----

const reset = () => parts.forEach((part) => part());
for (const ev of POLL_EVENTS) window.addEventListener(ev, reset);
reset();
