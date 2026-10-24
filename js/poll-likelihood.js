// Week 1, "Step 2: The likelihood": sliders set the survey (how many people, what share
// said "mayor"), and the plot and table show how likely that result is for each value
// of θ. The prior from Step 1 is drawn too, for comparison. The survey is shared with
// "Step 3" through poll-store.js.
import { PosteriorPlot } from './posterior.js';
import { POLL_EVENTS, loadPrior, saveSurvey, loadSurvey, surveyCount } from './poll-store.js';
import { binomial, density, fmtNum, likelihoodMass, priorMass, xs } from './poll-math.js';
import { brand } from './palette.js';
import { tweenText } from './tween.js';

const MARKS = [0.2, 0.4, 0.6, 0.8]; // the θ values in the table

const $ = (id) => document.getElementById(id);
const graphEl = $('poll-lik-graph');

if (graphEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';

  const plot = new PosteriorPlot({ container: graphEl });
  const nInput = $('poll-n');
  const shareInput = $('poll-share');

  function show(survey) {
    nInput.value = survey.n;
    shareInput.value = survey.share;
  }

  function draw(survey) {
    plot.setSeries([
      { label: 'Prior', color: brand('red'), xs, ys: density(priorMass(loadPrior())) },
      {
        label: 'Likelihood', color: brand('blue'), xs, ys: density(likelihoodMass(survey)),
        dash: [8, 6],
      },
    ]);
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
      tweenText($(`poll-lik-${Math.round(theta * 100)}`), binomial(k, n, theta), fmtNum);
    });
    draw(survey);
    saveSurvey(survey);
  }

  show(loadSurvey());
  nInput.addEventListener('input', update);
  shareInput.addEventListener('input', update);

  // Step 3's "make this posterior my new prior" starts a new survey
  window.addEventListener('poll-survey:set', (e) => {
    if (e.detail) {
      show(e.detail);
      update();
    }
  });

  // Redraw the prior when it changes on Step 1 (or is carried over from Step 3)
  for (const ev of POLL_EVENTS.filter((name) => name.startsWith('poll-prior'))) {
    window.addEventListener(ev, () => draw(loadSurvey()));
  }

  update();
}
