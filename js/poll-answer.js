// Week 1, "Answering the question": the share of the class's posterior above 50%, from
// the prior drawn on Step 1 and the survey set on Step 2. Markup in
// _includes/week1/poll-answer.md.
import { PosteriorPlot } from './posterior.js';
import { POLL_EVENTS, loadPrior, loadSurvey } from './poll-store.js';
import { density, majority, pct, prob, update, xs } from './poll-math.js';
import { brand, withAlpha } from './palette.js';
import { tweenText } from './tween.js';

const $ = (id) => document.getElementById(id);
const graphEl = $('poll-answer-graph');
const GREEN = brand('green');

// How sure, in words: "about 13% sure", or "less than 1% sure" at the extremes
const sure = (p) => (p < 0.01 ? 'less than 1% sure' : p > 0.99 ? 'more than 99% sure'
  : `about ${pct(p)} sure`);

if (graphEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';
  const plot = new PosteriorPlot({ container: graphEl });

  function redraw() {
    const { prior, post } = update(loadPrior(), loadSurvey());
    tweenText($('poll-answer-prior'), prior && majority(prior), prob);
    tweenText($('poll-answer-post'), post && majority(post), prob);
    tweenText($('poll-answer-chance'), post && majority(post), (p) => `So we're ${sure(p)} the mayor will get a majority.`);

    const ys = density(post);
    const half = xs.findIndex((x) => x >= 0.5); // the grid has a point at exactly 50%
    plot.setSeries([
      // the posterior was on Step 3, so it's simply there; the shading grows in
      { label: 'Posterior', color: GREEN, xs, ys, fill: withAlpha(GREEN, 0.12), grow: false },
      // the share above 50%, shaded darker, scaled like the whole posterior. Only the
      // part from 50% up, so its edge is a straight vertical line at 50%.
      { color: GREEN, xs: xs.slice(half), ys: ys.slice(half),
        fill: withAlpha(GREEN, 0.5), line: false, peak: Math.max(...ys) },
    ]);
  }

  // Keep in step with Steps 1–3
  for (const ev of POLL_EVENTS) window.addEventListener(ev, redraw);
  redraw();
}
