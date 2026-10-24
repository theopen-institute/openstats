// Week 1, "Step 3: Prior × likelihood → posterior": combines the prior drawn on the
// Step 1 slide with the likelihood of the survey set on Step 2, and plots all three
// curves.
import { PosteriorPlot } from './posterior.js';
import { DEFAULT_SURVEY, loadPrior, loadSurvey, savePrior, saveSurvey } from './poll-store.js';
import {
  density, pct, prob, range, summarize, surveyText, toPoints, update as bayes, xs,
} from './poll-math.js';
import { brand, withAlpha } from './palette.js';
import { tweenText } from './tween.js';

const $ = (id) => document.getElementById(id);
const graphEl = $('poll-post-graph');

function showStats(prefix, s) {
  tweenText($(`poll-${prefix}-mean`), s?.mean, pct);
  tweenText($(`poll-${prefix}-range`), s && [s.lo, s.hi], ([lo, hi]) => range({ lo, hi }));
  tweenText($(`poll-${prefix}-win`), s?.win, prob);
}

if (graphEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';

  const colors = { prior: brand('red'), likelihood: brand('blue'), posterior: brand('green') };
  const plot = new PosteriorPlot({ container: graphEl });
  let priorPoints = loadPrior();
  let survey = loadSurvey();
  let posteriorMass = null;

  function update() {
    $('poll-survey-out').textContent =
      survey.n > 0 ? `${surveyText(survey)} said "mayor"` : 'none yet';

    const { prior, lik, post } = bayes(priorPoints, survey);
    posteriorMass = post;

    showStats('prior', prior && summarize(prior));
    showStats('post', post && summarize(post));
    $('poll-msg').textContent = !prior
      ? 'Your prior rules out every value of θ.'
      : !post
        ? 'Your prior rules out everything the data allow.'
        : '';
    $('poll-carry').disabled = !post;

    plot.setSeries([
      // prior and likelihood were on Step 2, so they're simply there; the posterior is new
      { label: 'Prior', color: colors.prior, xs, ys: density(prior), grow: false },
      {
        label: 'Likelihood', color: colors.likelihood, xs, ys: density(lik), dash: [8, 6],
        grow: false,
      },
      {
        label: 'Posterior', color: colors.posterior, xs, ys: density(post),
        fill: withAlpha(colors.posterior, 0.12),
      },
    ]);
  }

  window.addEventListener('poll-survey:change', (e) => {
    if (e.detail) {
      survey = { ...e.detail };
      update();
    }
  });

  window.addEventListener('poll-prior:change', (e) => {
    if (Array.isArray(e.detail)) {
      priorPoints = e.detail.slice();
      update();
    }
  });

  // Back to the Step 1 slide, to see (and reshape) the new prior
  function goToPrior() {
    const slide = $('poll-prior-graph')?.closest('section');
    if (slide && window.Reveal) {
      const { h, v } = window.Reveal.getIndices(slide);
      window.Reveal.slide(h, v);
    }
  }

  // Today's posterior is tomorrow's prior: sample the posterior back onto the 21
  // draggable points, and start a new survey of the usual size
  $('poll-carry').addEventListener('click', () => {
    const points = posteriorMass && toPoints(posteriorMass);
    if (!points) return;
    priorPoints = points;
    savePrior(priorPoints, 'poll-prior:set');
    survey = { ...survey, n: DEFAULT_SURVEY.n };
    saveSurvey(survey, 'poll-survey:set');
    update();
    goToPrior();
  });

  update();
}
