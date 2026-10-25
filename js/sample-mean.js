// Week 2, "How sure can a few people make us?": pretend the 352 !Kung adults are
// everyone, and measure a random few. Two distributions share one height axis:
//   top    — the adults we measured, a dot each (a population distribution), over a
//            faint histogram of everyone, scaled to the same number of people
//   bottom — how sure we are about the average height: Normal(sample mean, SD / √n),
//            the certainty distribution a flat prior gives (a certainty distribution)
// Each new sample moves the certainty curve; the last few stay behind, faint, so the
// class sees it jump around by about its own width. More people never narrows the
// top; it narrows the bottom.
// Data from the page (r/week2.R, kung_widget_data()). Markup in
// _includes/week2/sample-mean.md, styles in css/deck.scss (.w2-*).
import { brand, withAlpha } from './palette.js';
import {
  Canvas, dot, line, mean, normalDensity, pageData, scale, sd, text, ticks, xAxis,
} from './canvas-plot.js';
import { animate } from './tween.js';

const X_RANGE = [134, 182];
const HISTORY = 10; // earlier certainty curves left on the plot

const root = document.querySelector('.sample-mean');
const data = pageData('kung-data');
if (root && data) init(root, data.height);

function init(root, heights) {
  const $ = (sel) => root.querySelector(sel);
  const sizeIn = $('.sample-size');
  const truthIn = $('.sample-truth');
  const popMean = mean(heights);
  const popSd = sd(heights);

  let sample = [];
  let shown = null; // the certainty curve on screen: { mean, se }
  let history = [];
  let cancel = () => {};

  const canvas = new Canvas($('.w2-graph'), draw);

  // n adults, without replacement
  function measure() {
    const n = Number(sizeIn.value);
    const pool = heights.slice();
    for (let i = 0; i < n; i++) {
      const j = i + Math.floor(Math.random() * (pool.length - i));
      [pool[i], pool[j]] = [pool[j], pool[i]];
    }
    sample = pool.slice(0, n);
    const target = { mean: mean(sample), se: sd(sample) / Math.sqrt(n) };
    if (shown) history = [shown, ...history].slice(0, HISTORY);
    const from = shown ?? target;
    cancel();
    cancel = animate((e) => {
      shown = {
        mean: from.mean + (target.mean - from.mean) * e,
        se: from.se + (target.se - from.se) * e,
      };
      canvas.render();
    });
    readout(target);
  }

  function readout(t) {
    $('.sample-size-out').textContent = sample.length;
    $('.sample-guess').textContent = `${t.mean.toFixed(1)} cm`;
    $('.sample-spread').textContent = `± ${(2 * sd(sample)).toFixed(1)} cm`;
    $('.sample-sure').textContent = `± ${(2 * t.se).toFixed(1)} cm`;
  }

  function draw(ctx, w, h) {
    const blue = brand('blue');
    const green = brand('green');
    const ink = brand('ink');
    const pad = { left: 20, right: 20, top: 8, bottom: 64 };
    const x = scale(X_RANGE[0], X_RANGE[1], pad.left, w - pad.right);
    const plotH = h - pad.top - pad.bottom;
    const topBand = { y0: pad.top, y1: pad.top + plotH * 0.5 };
    const botBand = { y0: topBand.y1 + 36, y1: h - pad.bottom };

    // Top: the adults we measured, stacked in 1 cm bins, over everyone (faint)
    const binOf = (v) => Math.floor(v);
    const stacks = new Map();
    for (const v of sample) stacks.set(binOf(v), (stacks.get(binOf(v)) ?? 0) + 1);
    const everyone = new Map();
    for (const v of heights) everyone.set(binOf(v), (everyone.get(binOf(v)) ?? 0) + 1);
    const scaleToSample = sample.length / heights.length;
    const tallest = Math.max(
      1,
      ...stacks.values(),
      ...[...everyone.values()].map((c) => c * scaleToSample),
    );
    const binW = x(1) - x(0);
    const r = Math.min(binW * 0.45, (topBand.y1 - topBand.y0 - 34) / (2 * tallest));
    for (const [b, c] of everyone) {
      const bh = c * scaleToSample * 2 * r;
      ctx.fillStyle = withAlpha(ink, 0.08);
      ctx.fillRect(x(b) + 1, topBand.y1 - bh, binW - 2, bh);
    }
    for (const [b, c] of stacks) {
      for (let i = 0; i < c; i++) dot(ctx, x(b + 0.5), topBand.y1 - r - i * 2 * r, r * 0.92, blue);
    }
    text(ctx, `The ${sample.length} adults we measured`, pad.left, topBand.y0 + 20, {
      size: 19, weight: 600, color: blue,
    });
    text(ctx, 'each dot is one person; gray: everyone', pad.left, topBand.y0 + 44, {
      size: 15, color: brand('gray'),
    });
    line(ctx, pad.left, topBand.y1, w - pad.right, topBand.y1, { color: withAlpha(ink, 0.3) });

    // Bottom: how sure we are about the average height
    const yMax = normalDensity(0, 0, popSd / Math.sqrt(100)) * 1.1;
    const y = scale(0, yMax, botBand.y1, botBand.y0 + 30);
    const curve = (c) => {
      ctx.beginPath();
      for (let px = pad.left; px <= w - pad.right; px += 2) {
        const v = normalDensity(x.invert(px), c.mean, c.se);
        const py = Math.max(botBand.y0, y(v));
        if (px === pad.left) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
      }
    };
    for (const c of history) {
      curve(c);
      ctx.strokeStyle = withAlpha(green, 0.22);
      ctx.lineWidth = 2;
      ctx.stroke();
    }
    if (shown) {
      curve(shown);
      ctx.strokeStyle = green;
      ctx.lineWidth = 3.5;
      ctx.stroke();
      ctx.lineTo(w - pad.right, botBand.y1);
      ctx.lineTo(pad.left, botBand.y1);
      ctx.closePath();
      ctx.fillStyle = withAlpha(green, 0.14);
      ctx.fill();
    }
    text(ctx, 'How sure we are about the average height', pad.left, botBand.y0 + 20, {
      size: 19, weight: 600, color: green,
    });

    if (truthIn.checked) {
      line(ctx, x(popMean), topBand.y0 + 56, x(popMean), botBand.y1, { color: ink, width: 2, dash: [7, 5] });
      text(ctx, `everyone's average: ${popMean.toFixed(1)} cm`, x(popMean) + 8, botBand.y0 + 52, {
        size: 16, color: ink,
      });
    }

    xAxis(ctx, x, botBand.y1, ticks(135, 180, 5), { title: 'Height (cm)' });
  }

  sizeIn.addEventListener('input', () => {
    $('.sample-size-out').textContent = sizeIn.value;
  });
  sizeIn.addEventListener('change', measure);
  for (const btn of root.querySelectorAll('[data-n]')) {
    btn.addEventListener('click', () => {
      sizeIn.value = btn.dataset.n;
      measure();
    });
  }
  $('.sample-again').addEventListener('click', measure);
  truthIn.addEventListener('change', () => canvas.render());
  measure();
}
