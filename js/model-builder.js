// Week 2, practical work, "Step 7: Every coefficient moves": choose which features go
// into a model of house prices, and watch every coefficient change. A row per feature:
// its coefficient (standardized: SD of price per SD of the feature) as a bar, with its
// 90% interval; a gray mark where it stood before the last change. Underneath, how far
// a typical price is from the model's prediction, with no features and with these.
// All 64 models are fit in R (r/week2.R, house_models_data()); this only looks them
// up. Markup in _includes/week2/model-builder.md, styles in css/deck.scss (.w2-*).
import { brand, withAlpha } from './palette.js';
import { Canvas, line, pageData, scale, text, ticks, xAxis } from './canvas-plot.js';
import { animate } from './tween.js';

const X_RANGE = [-0.5, 1];
const FIRST = ['bedrooms']; // the model it starts with

const root = document.querySelector('.model-builder');
const data = pageData('house-models');
if (root && data) init(root, data);

const money = (v) => `$${Math.round(v).toLocaleString('en-US')}`;

function init(root, data) {
  const $ = (sel) => root.querySelector(sel);
  const features = data.features;
  const keyOf = (on) => features.filter((f) => on.has(f.key)).map((f) => f.key).join('+') || 'none';
  const noFeatures = data.models.none.sigma;

  const on = new Set(FIRST);
  let shown = null; // on screen: { [feature]: { est, lo, hi, alpha } }, sigma
  let before = {}; // each feature's estimate before the last change
  let cancel = () => {};

  // A checkbox per feature
  const list = $('.mb-features');
  for (const f of features) {
    const label = document.createElement('label');
    label.className = 'w2-check';
    label.innerHTML = `<input type="checkbox" value="${f.key}"> ${f.label}`;
    const box = label.querySelector('input');
    box.checked = on.has(f.key);
    box.addEventListener('change', () => {
      if (box.checked) on.add(f.key);
      else on.delete(f.key);
      update();
    });
    list.appendChild(label);
  }

  const canvas = new Canvas($('.w2-graph'), draw);

  // The current model, as what to draw
  function target() {
    const model = data.models[keyOf(on)];
    const rows = {};
    for (const f of features) {
      const b = model.beta[f.key];
      rows[f.key] = b
        ? { est: b[0], lo: b[1], hi: b[2], alpha: 1 }
        : { ...(shown?.rows[f.key] ?? { est: 0, lo: 0, hi: 0 }), alpha: 0 };
    }
    return { rows, sigma: model.sigma };
  }

  function update() {
    const to = target();
    if (shown) {
      before = {};
      for (const f of features) {
        if (shown.rows[f.key].alpha > 0.5 && to.rows[f.key].alpha === 1) before[f.key] = shown.rows[f.key].est;
      }
    }
    const from = shown ?? to;
    cancel();
    cancel = animate((e) => {
      const mix = (a, b) => a + (b - a) * e;
      const rows = {};
      for (const f of features) {
        const a = from.rows[f.key];
        const b = to.rows[f.key];
        rows[f.key] = {
          est: b.alpha ? mix(a.alpha ? a.est : 0, b.est) : a.est,
          lo: b.alpha ? mix(a.alpha ? a.lo : 0, b.lo) : a.lo,
          hi: b.alpha ? mix(a.alpha ? a.hi : 0, b.hi) : a.hi,
          alpha: mix(a.alpha, b.alpha),
        };
      }
      shown = { rows, sigma: mix(from.sigma, to.sigma) };
      canvas.render();
    });
    $('.mb-sigma').textContent = money(to.sigma);
  }

  function draw(ctx, w, h) {
    if (!shown) return;
    const ink = brand('ink');
    const gray = brand('gray');
    const orange = brand('orange');
    const blue = brand('blue');
    const labelW = 190;
    const plot = { left: labelW + 20, right: w - 30, top: 10, bottom: h - 190 };
    const x = scale(X_RANGE[0], X_RANGE[1], plot.left, plot.right);
    const rowH = (plot.bottom - plot.top) / features.length;

    xAxis(ctx, x, plot.bottom, ticks(-0.4, 1, 0.2), {
      title: 'Coefficient: SDs of price per SD of the feature',
      format: (v) => (v === 0 ? '0' : v.toFixed(1)),
      grid: plot.top,
    });
    line(ctx, x(0), plot.top, x(0), plot.bottom, { color: ink, width: 2 });

    features.forEach((f, i) => {
      const r = shown.rows[f.key];
      const cy = plot.top + (i + 0.5) * rowH;
      const barH = rowH * 0.42;
      text(ctx, f.label, labelW, cy, {
        size: 19, weight: 600, align: 'right', baseline: 'middle', color: r.alpha > 0.5 ? ink : gray,
      });
      if (r.alpha < 0.5) {
        text(ctx, 'not in the model', x(0) + 12, cy, { size: 16, baseline: 'middle', color: gray });
      }
      if (r.alpha <= 0.01) return;
      ctx.save();
      ctx.globalAlpha = r.alpha;
      // the bar, and its interval
      ctx.fillStyle = withAlpha(orange, 0.85);
      ctx.fillRect(Math.min(x(0), x(r.est)), cy - barH / 2, Math.abs(x(r.est) - x(0)), barH);
      line(ctx, x(r.lo), cy, x(r.hi), cy, { color: ink, width: 2.5 });
      line(ctx, x(r.lo), cy - 8, x(r.lo), cy + 8, { color: ink, width: 2.5 });
      line(ctx, x(r.hi), cy - 8, x(r.hi), cy + 8, { color: ink, width: 2.5 });
      const right = r.est >= 0;
      text(ctx, `${r.est >= 0 ? '+' : '−'}${Math.abs(r.est).toFixed(2)}`,
        right ? Math.max(x(r.est), x(r.hi)) + 12 : Math.min(x(r.est), x(r.lo)) - 12, cy, {
          size: 18, weight: 600, align: right ? 'left' : 'right', baseline: 'middle',
        });
      // where it stood before the last change
      const b = before[f.key];
      if (b != null && Math.abs(b - r.est) > 0.015) {
        const by = cy - barH / 2 - 6;
        line(ctx, x(b), cy - barH / 2 - 12, x(b), cy + barH / 2 + 12, { color: gray, width: 3, dash: [4, 3] });
        text(ctx, 'before', x(b), by - 10, { size: 14, align: 'center', color: gray });
      }
      ctx.restore();
    });

    // The typical miss: with no features, and with these
    const s = scale(0, noFeatures, plot.left, plot.right - 160);
    const missY = plot.bottom + 92;
    text(ctx, 'How far a typical price is from the prediction', plot.left, missY - 10, {
      size: 17, weight: 600, color: ink,
    });
    const bars = [
      { label: 'No features', v: noFeatures, color: withAlpha(gray, 0.6) },
      { label: 'This model', v: shown.sigma, color: blue },
    ];
    bars.forEach((b, i) => {
      const y0 = missY + 6 + i * 34;
      text(ctx, b.label, labelW, y0 + 13, { size: 16, align: 'right', baseline: 'middle', color: ink });
      ctx.fillStyle = b.color;
      ctx.fillRect(plot.left, y0, s(b.v) - plot.left, 26);
      text(ctx, `± ${money(b.v)}`, s(b.v) + 10, y0 + 13, { size: 16, baseline: 'middle', color: ink });
    });
  }

  $('.mb-clear').addEventListener('click', () => {
    on.clear();
    for (const box of list.querySelectorAll('input')) box.checked = false;
    update();
  });
  $('.mb-all').addEventListener('click', () => {
    for (const f of features) on.add(f.key);
    for (const box of list.querySelectorAll('input')) box.checked = true;
    update();
  });
  update();
}
