// Week 1, "Step 2: The likelihood": sliders set the survey (how many people, what share
// said "mayor"), and the plot and table show how likely that result is for each value
// of θ. The survey is shared with "Step 3" through poll-store.js.
import { PosteriorPlot } from './posterior.js';
import { loadSurvey, saveSurvey, surveyCount } from './poll-store.js';
import { brand } from './palette.js';

const G = 201;
const xs = Array.from({ length: G }, (_, i) => i / (G - 1));
const MARKS = [0.2, 0.4, 0.6, 0.8]; // the θ values in the table

const $ = (id) => document.getElementById(id);
const graphEl = $('poll-lik-graph');

// log(n!) for n up to the slider's maximum
const MAX_N = 500;
const logFact = [0];
for (let i = 1; i <= MAX_N; i++) logFact[i] = logFact[i - 1] + Math.log(i);

// P( k of n | θ ), the binomial probability
function binomial(k, n, theta) {
  if (theta === 0) return k === 0 ? 1 : 0;
  if (theta === 1) return k === n ? 1 : 0;
  const logChoose = logFact[n] - logFact[k] - logFact[n - k];
  return Math.exp(logChoose + k * Math.log(theta) + (n - k) * Math.log(1 - theta));
}

// Small probabilities written out in full (0.0000017), like the lecture's examples
function fmtProb(p) {
  if (p >= 0.001) return p.toFixed(3);
  if (p < 1e-9) return '≈ 0';
  return p.toFixed(1 - Math.floor(Math.log10(p)));
}

if (graphEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';

  const plot = new PosteriorPlot({ container: graphEl, yLabel: 'Likelihood' });
  const nInput = $('poll-n');
  const shareInput = $('poll-share');

  function show(survey) {
    nInput.value = survey.n;
    shareInput.value = survey.share;
  }

  function update() {
    const survey = { n: Number(nInput.value), share: Number(shareInput.value) };
    const { n } = survey;
    const k = surveyCount(survey);
    const data = `${k} of ${n}`;
    $('poll-n-out').textContent = n;
    $('poll-share-out').textContent = n > 0 ? `${data} (${Math.round((100 * k) / n)}%)` : data;
    $('poll-lik-head').textContent = `P( ${data} )`;
    MARKS.forEach((theta) => {
      $(`poll-lik-${Math.round(theta * 100)}`).textContent = fmtProb(binomial(k, n, theta));
    });

    plot.setSeries([
      { label: 'Likelihood', color: brand('blue'), xs, ys: xs.map((x) => binomial(k, n, x)) },
    ]);
    saveSurvey(survey);
  }

  show(loadSurvey());
  nInput.addEventListener('input', update);
  shareInput.addEventListener('input', update);

  // Step 3's "make this posterior my new prior" clears the survey
  window.addEventListener('poll-survey:set', (e) => {
    if (e.detail) {
      show(e.detail);
      update();
    }
  });

  update();
}
