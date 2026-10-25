// Week 2, the "moving distribution": the !Kung adults' heights and weights, with a band
// of similar heights picked out (drag on the plot, or use the slider). Beside the plot,
// sideways, the distribution of weight within the band: P( weight | height ). As the
// band moves, the distribution moves with it. Two modes, one per slide:
//   default            — "A relationship is a distribution that moves": the band's
//                        weights against everyone's. Each band's average leaves a
//                        mark, and the marks trace out the regression line.
//   data-split="sex"   — "Compare adults of the same height": women and men colored,
//                        and their weights compared inside the band. Overall the men
//                        are much heavier; at the same height, hardly at all.
// Data and lines from the page (r/week2.R, kung_widget_data()). Markup in
// _includes/week2/conditional*.md, styles in css/deck.scss (.w2-*).
import { brand, withAlpha } from './palette.js';
import {
  Canvas, dot, line, mean, pageData, scale, text, ticks, xAxis, yAxis,
} from './canvas-plot.js';

const X_RANGE = [135, 181]; // height, cm
const Y_RANGE = [30, 65]; // weight, kg
const BIN = 2; // kg, for the sideways histograms
const MIN_GROUP = 3; // fewer women or men than this in the band: no comparison

const data = pageData('kung-data');
if (data) {
  for (const root of document.querySelectorAll('.conditional')) init(root, data);
}

function init(root, data) {
  const $ = (sel) => root.querySelector(sel);
  const split = root.dataset.split === 'sex';
  const half = split ? 3 : 2.5; // the band: this many cm either side
  const heightIn = $('.cond-height');
  const lineIn = $('.cond-line');
  const people = data.height.map((h, i) => ({ h, w: data.weight[i], male: data.male[i] === 1 }));
  const allMean = mean(data.weight);
  const trail = new Map(); // band center (whole cm) -> the band's average weight

  let center = Number(heightIn.value);
  let geom = null; // the scatter's scales, for dragging

  const canvas = new Canvas($('.w2-graph'), draw);

  const inBand = (p, c = center) => Math.abs(p.h - c) <= half;

  function update() {
    heightIn.value = center;
    const band = people.filter((p) => inBand(p));
    $('.cond-height-out').textContent = `${center.toFixed(0)} cm`;
    if (split) {
      const women = band.filter((p) => !p.male);
      const men = band.filter((p) => p.male);
      $('.cond-women').textContent = women.length;
      $('.cond-men').textContent = men.length;
      const gap = women.length >= MIN_GROUP && men.length >= MIN_GROUP
        ? mean(men.map((p) => p.w)) - mean(women.map((p) => p.w))
        : null;
      $('.cond-gap').textContent = gap == null ? 'too few to compare' : signed(gap);
    } else {
      $('.cond-n').textContent = band.length;
      $('.cond-avg').textContent = band.length ? `${mean(band.map((p) => p.w)).toFixed(1)} kg` : '—';
      const c = Math.round(center);
      const marked = people.filter((p) => inBand(p, c));
      if (marked.length >= MIN_GROUP) trail.set(c, mean(marked.map((p) => p.w)));
    }
    canvas.render();
  }

  const signed = (v) => `${v >= 0 ? '+' : '−'}${Math.abs(v).toFixed(1)} kg`;

  // Share of `ws` in each BIN-kg bin, from the bottom of the weight range
  function shares(ws) {
    const n = Math.ceil((Y_RANGE[1] - Y_RANGE[0]) / BIN);
    const out = new Array(n).fill(0);
    for (const v of ws) {
      const i = Math.floor((v - Y_RANGE[0]) / BIN);
      if (i >= 0 && i < n) out[i] += 1 / ws.length;
    }
    return out;
  }

  function draw(ctx, w, h) {
    const ink = brand('ink');
    const gray = brand('gray');
    const orange = brand('orange');
    const red = brand('red');
    const blue = brand('blue');
    const plot = { left: 78, right: w * 0.7, top: 14, bottom: h - 66 };
    const panel = { left: plot.right + 34, right: w - 12 };
    const x = scale(X_RANGE[0], X_RANGE[1], plot.left, plot.right);
    const y = scale(Y_RANGE[0], Y_RANGE[1], plot.bottom, plot.top);
    geom = { x, plot };

    // The band
    ctx.fillStyle = withAlpha(orange, 0.13);
    ctx.fillRect(x(center - half), plot.top, x(center + half) - x(center - half), plot.bottom - plot.top);

    yAxis(ctx, y, plot.left, ticks(30, 65, 5), { title: 'Weight (kg)', grid: plot.right });
    xAxis(ctx, x, plot.bottom, ticks(135, 180, 5), { title: 'Height (cm)', grid: plot.top });

    // People: everyone faint, the band strong
    const color = (p) => (split ? (p.male ? blue : red) : orange);
    for (const p of people) {
      if (inBand(p)) continue;
      dot(ctx, x(p.h), y(p.w), 4, split ? withAlpha(color(p), 0.2) : withAlpha(gray, 0.45));
    }
    for (const p of people) if (inBand(p)) dot(ctx, x(p.h), y(p.w), 5.5, withAlpha(color(p), 0.9));

    // The lines, from R: weight on height, or on sex and height
    if (lineIn.checked) {
      const draw1 = (f, c) => line(ctx, x(X_RANGE[0]), y(f(X_RANGE[0])), x(X_RANGE[1]), y(f(X_RANGE[1])), {
        color: c, width: 3,
      });
      if (split) {
        const L = data.sex_line;
        draw1((v) => L.intercept + L.slope * v, red);
        draw1((v) => L.intercept + L.male + L.slope * v, blue);
      } else {
        draw1((v) => data.line.intercept + data.line.slope * v, ink);
      }
    }

    // Each band's average, as a mark that stays (default mode)
    if (!split) {
      for (const [c, m] of trail) {
        ctx.save();
        ctx.translate(x(c), y(m));
        ctx.rotate(Math.PI / 4);
        ctx.fillStyle = ink;
        ctx.fillRect(-5, -5, 10, 10);
        ctx.restore();
      }
    }

    // The band's average weight(s), across the band and the panel
    const band = people.filter((p) => inBand(p));
    const groups = split
      ? [
        { ws: band.filter((p) => !p.male).map((p) => p.w), color: red },
        { ws: band.filter((p) => p.male).map((p) => p.w), color: blue },
      ]
      : [{ ws: band.map((p) => p.w), color: orange }];
    for (const g of groups) {
      if (g.ws.length < (split ? MIN_GROUP : 1)) continue;
      const m = y(mean(g.ws));
      line(ctx, x(center - half), m, panel.right, m, { color: g.color, width: 3 });
    }

    // The panel: weight distributions, sideways, sharing the plot's weight axis
    const back = split ? [] : [{ s: shares(people.map((p) => p.w)), fill: withAlpha(gray, 0.3) }];
    const front = groups
      .filter((g) => g.ws.length > 0)
      .map((g) => ({ s: shares(g.ws), fill: withAlpha(g.color, split ? 0.45 : 0.75) }));
    const most = Math.max(0.05, ...[...back, ...front].flatMap((d) => d.s));
    const bx = scale(0, most, panel.left, panel.right);
    for (const d of [...back, ...front]) {
      d.s.forEach((share, i) => {
        if (!share) return;
        const y0 = y(Y_RANGE[0] + i * BIN);
        const y1 = y(Y_RANGE[0] + (i + 1) * BIN);
        ctx.fillStyle = d.fill;
        ctx.fillRect(panel.left, y1 + 1, bx(share) - panel.left, y0 - y1 - 2);
      });
    }
    line(ctx, panel.left, plot.top, panel.left, plot.bottom, { color: ink });
    text(ctx, split ? 'Weights at this height' : 'Weights', panel.left, plot.bottom + 26, {
      size: 16, weight: 600, color: split ? ink : orange,
    });
    text(ctx, split ? 'women and men' : 'at this height; gray: everyone', panel.left, plot.bottom + 48, {
      size: 15, color: gray,
    });
    if (!split) {
      const m = y(allMean);
      line(ctx, panel.left, m, panel.right, m, { color: gray, width: 2, dash: [6, 4] });
    }
  }

  // Drag the band along the plot
  const el = canvas.canvas;
  const moveTo = (event) => {
    if (!geom) return;
    const p = canvas.point(event);
    const v = geom.x.invert(p.x);
    center = Math.min(Number(heightIn.max), Math.max(Number(heightIn.min), Math.round(v * 2) / 2));
    update();
  };
  el.style.cursor = 'ew-resize';
  el.style.touchAction = 'none';
  el.addEventListener('pointerdown', (event) => {
    el.setPointerCapture(event.pointerId);
    moveTo(event);
  });
  el.addEventListener('pointermove', (event) => {
    if (el.hasPointerCapture(event.pointerId)) moveTo(event);
  });

  heightIn.addEventListener('input', () => {
    center = Number(heightIn.value);
    update();
  });
  lineIn.addEventListener('change', () => canvas.render());
  $('.cond-clear')?.addEventListener('click', () => {
    trail.clear();
    update();
  });
  update();
}
