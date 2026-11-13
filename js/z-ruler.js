// Week 2, "Same data, new ruler": the adults' heights with two rulers, centimeters (or
// inches) along the bottom and z-scores along the top, and one man to drag along them.
// The bars are colored by how far from the average they are, in the zones the side
// table names (within 1 SD: typical; 1 to 2: uncommon; 2 to 3: unusual; beyond 3:
// rare). Two choices:
//   Compared with  the crowd the z-scores are measured in: all adults, women or men.
//                  The bars and the z ruler change; the centimeters don't, and
//                  neither does he. The same man is ordinary in one crowd and unusual
//                  in another.
//   Ruler          the bottom ruler in centimeters or inches: only its labels change.
//                  The bars, his place and his z-score stay put.
// He starts as "Taller or heavier?"'s man, and is back when the slide is shown again.
// Data from the page: the adults (adults_widget_data()) and the man
// (zscore_widget_data(), both in r/week2.R). Markup in _includes/week2/z-ruler.md,
// styles in css/deck.scss (.z-ruler).
import { brand, withAlpha } from './palette.js';
import { Canvas, line, mean, pageData, scale, sd, text, xAxis } from './canvas-plot.js';
import { animate } from './tween.js';

const MOVE_MS = 900;
const RANGE = [129.5, 187.5]; // cm, the bars of every height histogram in the deck
const BIN = 2;
const CM_PER_IN = 2.54;
const GROUPS = {
  all: { label: 'all adults', keep: () => true },
  women: { label: 'women', keep: (m) => m === 0 },
  men: { label: 'men', keep: (m) => m === 1 },
};
// The zones, by distance from the average in SDs; the side table lists them in order
const ZONES = [
  { upto: 1, name: 'typical' },
  { upto: 2, name: 'uncommon' },
  { upto: 3, name: 'unusual' },
  { upto: Infinity, name: 'rare' },
];
const zoneColors = () => [
  withAlpha(brand('blue'), 0.3),
  withAlpha(brand('blue'), 0.75),
  brand('orange'),
  brand('red'),
];
const zoneOf = (z) => ZONES.findIndex((zone) => Math.abs(z) < zone.upto);

const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));
const signed = (z, d = 2) => `${z < 0 ? '−' : '+'}${Math.abs(z).toFixed(d)}`;

const adults = pageData('adults-data');
const data = pageData('zscore-data');
const root = document.querySelector('.z-ruler');
if (root && adults && data) init(root, adults, data);

function init(root, adults, data) {
  const $ = (sel) => root.querySelector(sel);
  const crowds = Object.fromEntries(Object.entries(GROUPS).map(([key, g]) => {
    const hs = adults.height.filter((_, i) => g.keep(adults.male[i]));
    const counts = new Array(Math.round((RANGE[1] - RANGE[0]) / BIN)).fill(0);
    for (const h of hs) {
      const i = Math.floor((h - RANGE[0]) / BIN);
      if (i >= 0 && i < counts.length) counts[i] += 1;
    }
    return [key, { ...g, hs, m: mean(hs), s: sd(hs), counts, max: Math.max(...counts) }];
  }));

  let group = 'all';
  let unit = 'cm';
  let height = data.person.height;
  // What's drawn: the crowd's mean, SD, bars and their scale, easing between crowds
  const pick = (c) => ({ m: c.m, s: c.s, counts: [...c.counts], max: c.max });
  let view = pick(crowds.all);
  let cancel = () => {};
  let geom = null;

  const canvas = new Canvas($('.w2-graph'), draw);
  // The table's swatches, in the canvas's colors
  root.querySelectorAll('.z-zones tbody tr').forEach((tr, i) => {
    tr.querySelector('.z-swatch').style.background = zoneColors()[i];
  });

  function update() {
    const c = crowds[group];
    const z = (height - c.m) / c.s;
    $('.zr-height').textContent = unit === 'cm'
      ? `${height} cm`
      : `${(height / CM_PER_IN).toFixed(1)} in`;
    $('.zr-z').textContent = signed(z);
    const share = c.hs.filter((h) => h < height).length / c.hs.length;
    $('.zr-share').textContent = `${Math.round(100 * share)}% of ${c.label}`;
    root.querySelectorAll('.z-zones tbody tr').forEach((tr, i) => {
      tr.classList.toggle('is-here', i === zoneOf(z));
    });
    root.querySelectorAll('[data-group]').forEach((b) => b.classList.toggle('is-on', b.dataset.group === group));
    root.querySelectorAll('[data-unit]').forEach((b) => b.classList.toggle('is-on', b.dataset.unit === unit));
    canvas.render();
  }

  function draw(ctx, w, h) {
    const ink = brand('ink');
    const blue = brand('blue');
    const colors = zoneColors();
    const pad = { left: 30, right: 30, top: 10, bottom: 84 };
    const rulerY = pad.top + 80; // the z ruler's line
    const stripY = rulerY + 8; // the zones' names, under it
    const plotTop = stripY + 44;
    const base = h - pad.bottom;
    const x = scale(RANGE[0], RANGE[1], pad.left, w - pad.right);
    const y = scale(0, view.max, base, plotTop + 30);
    const { m, s } = view;
    const zx = (z) => x(m + z * s);
    geom = { x };

    ctx.save();
    ctx.beginPath();
    ctx.rect(pad.left, pad.top, w - pad.left - pad.right, h - pad.top);
    ctx.clip();

    // The zones: a band of color under the ruler, named where there's room
    for (let k = -8; k < 8; k++) {
      const zone = Math.min(3, k < 0 ? -k - 1 : k);
      const [x0, x1] = [zx(k), zx(k + 1)];
      ctx.fillStyle = colors[zone];
      ctx.fillRect(x0, stripY, x1 - x0, 32);
      const name = ZONES[zone].name;
      const mid = (x0 + x1) / 2;
      if (x1 - x0 > 90 && k >= -4 && k <= 3 && mid > pad.left + 40 && mid < w - pad.right - 40) {
        text(ctx, name, mid, stripY + 16, {
          size: 15, weight: 600, align: 'center', baseline: 'middle', color: zone === 0 ? ink : 'white',
        });
      }
    }

    // The bars, each colored by its zone
    view.counts.forEach((c, i) => {
      if (c < 0.5) return;
      const mid = RANGE[0] + (i + 0.5) * BIN;
      ctx.fillStyle = colors[zoneOf((mid - m) / s)];
      ctx.fillRect(x(RANGE[0] + i * BIN) + 0.75, y(c), x(RANGE[0] + (i + 1) * BIN) - x(RANGE[0] + i * BIN) - 1.5, base - y(c));
    });

    // The z ruler, along the top
    line(ctx, pad.left, rulerY, w - pad.right, rulerY, { color: blue, width: 2 });
    for (let k = -4; k <= 4; k++) {
      const at = zx(k);
      line(ctx, at, rulerY - 8, at, rulerY, { color: blue, width: 2 });
      text(ctx, k ? signed(k, 0) : '0', at, rulerY - 12, { size: 18, weight: 700, align: 'center', color: blue });
      line(ctx, at, plotTop, at, base, { color: withAlpha(blue, k ? 0.15 : 0.45), width: k ? 1.5 : 2, dash: k ? [] : [7, 6] });
    }
    ctx.restore();
    text(ctx, `z-score: SDs from the average of ${crowds[group].label}`, pad.left, pad.top, {
      size: 16, weight: 600, color: blue, baseline: 'top',
    });

    // The bottom ruler, in centimeters or inches
    if (unit === 'cm') {
      xAxis(ctx, x, base, [130, 140, 150, 160, 170, 180], { title: 'Height (cm)' });
    } else {
      const inches = [52, 56, 60, 64, 68, 72];
      xAxis(ctx, x, base, inches.map((i) => i * CM_PER_IN), {
        title: 'Height (inches)', format: (v) => String(Math.round(v / CM_PER_IN)),
      });
    }
    line(ctx, pad.left, base, w - pad.right, base, { color: ink });

    // Him
    const z = (height - crowds[group].m) / crowds[group].s;
    const at = x(height);
    line(ctx, at, plotTop, at, base, { color: ink, width: 4 });
    const right = at > w - 230;
    text(ctx, `z = ${signed(z)}`, at + (right ? -12 : 12), plotTop + 22, {
      size: 20, weight: 700, color: ink, align: right ? 'right' : 'left', halo: true,
    });
  }

  function choose(nextGroup) {
    if (nextGroup === group) return;
    group = nextGroup;
    const from = view;
    const to = pick(crowds[group]);
    cancel();
    cancel = animate((e) => {
      const mix = (a, b) => a + (b - a) * e;
      view = {
        m: mix(from.m, to.m),
        s: mix(from.s, to.s),
        max: mix(from.max, to.max),
        counts: to.counts.map((c, i) => mix(from.counts[i], c)),
      };
      canvas.render();
    }, MOVE_MS);
    update();
  }

  root.querySelectorAll('[data-group]').forEach((b) => b.addEventListener('click', () => choose(b.dataset.group)));
  root.querySelectorAll('[data-unit]').forEach((b) => b.addEventListener('click', () => {
    unit = b.dataset.unit;
    update();
  }));

  // Drag him along the ruler (or click where he should be)
  const el = canvas.canvas;
  const moveTo = (event) => {
    if (!geom) return;
    height = Math.round(clamp(geom.x.invert(canvas.point(event).x), 131, 186));
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

  // Back to the man, all adults and centimeters each time the slide is left
  window.Reveal?.on?.('slidechanged', (e) => {
    if (e.currentSlide?.contains(root)) return;
    cancel();
    height = data.person.height;
    group = 'all';
    unit = 'cm';
    view = pick(crowds.all);
    update();
  });
  update();
}
