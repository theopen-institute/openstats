// Week 1, "Answering the question": the share of the class's posterior above 50%, from
// the prior drawn on Step 1 and the survey set on Step 2. Markup in
// _includes/week1/poll-answer.md.
import { PosteriorPlot } from './posterior.js';
import { POLL_EVENTS, loadPrior, loadSurvey } from './poll-store.js';
import { chance, density, majority, prob, update, xs } from './poll-math.js';
import { brand, withAlpha } from './palette.js';
import { tweenText } from './tween.js';

const $ = (id) => document.getElementById(id);
const graphEl = $('poll-answer-graph');
const GREEN = brand('green');

if (graphEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';
  const plot = new PosteriorPlot({ container: graphEl });

  function redraw() {
    const { prior, post } = update(loadPrior(), loadSurvey());
    tweenText($('poll-answer-prior'), prior && majority(prior), prob);
    tweenText($('poll-answer-post'), post && majority(post), prob);
    tweenText($('poll-answer-chance'), post && majority(post),
      (p) => `Not a yes or no, but ${chance(p)} of a majority.`);

    const ys = density(post);
    plot.setSeries([
      { label: 'Posterior', color: GREEN, xs, ys, fill: withAlpha(GREEN, 0.12) },
      // the share above 50%, shaded darker
      { color: GREEN, xs, ys: ys.map((y, i) => (xs[i] >= 0.5 ? y : 0)),
        fill: withAlpha(GREEN, 0.5), line: false },
    ]);
  }

  // Keep in step with Steps 1–3
  for (const ev of POLL_EVENTS) window.addEventListener(ev, redraw);
  redraw();
}
