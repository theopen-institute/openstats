// Week 2, "The same puzzle, in Nepal": every developing country as a dot, in two
// rows: the UN's least developed countries (LDCs) and the rest. Each row's average is a
// line. "Graduate" moves Nepal, Bangladesh and Laos from the top row to the bottom one:
// they were among the healthiest, richest LDCs, and below the others' average, so both
// averages get worse, while no country's numbers change. The last averages stay behind,
// dashed, for comparison. Two indicators: child mortality, and income on a log scale.
// Data from the page (r/week2.R, ldc_widget_data()). Markup in
// _includes/week2/ldc-shift.md, styles in css/deck.scss (.w2-*).
import { brand, withAlpha } from './palette.js';
import { Canvas, dot, line, mean, pageData, text, xAxis } from './canvas-plot.js';
import { animate } from './tween.js';

const INDICATORS = {
  u5: {
    title: 'Children who die before age 5, per 1,000 born',
    range: [0, 150],
    ticks: [0, 25, 50, 75, 100, 125, 150],
    format: (v) => v.toFixed(1),
    worse: 1, // higher is worse
  },
  gni: {
    title: 'Income per person (GNI, US$, log scale)',
    range: [200, 20000],
    ticks: [200, 500, 1000, 2000, 5000, 10000, 20000],
    log: true,
    format: (v) => `$${Math.round(v).toLocaleString('en-US')}`,
    worse: -1, // lower is worse
  },
};
const R = 7; // dot radius

const root = document.querySelector('.ldc-shift');
const data = pageData('ldc-data');
if (root && data) init(root, data);

function init(root, countries) {
  const $ = (sel) => root.querySelector(sel);
  const button = $('.ldc-go');
  let key = 'u5';
  let graduated = false;
  let t = 0; // 0: on the list, 1: graduated (eased in between)
  let cancel = () => {};

  const canvas = new Canvas($('.w2-graph'), draw);

  const inLdc = (c, done) => c.ldc && !(done && c.graduate);
  const averages = (k, done) => {
    const have = countries.filter((c) => c[k] != null);
    return {
      ldc: mean(have.filter((c) => inLdc(c, done)).map((c) => c[k])),
      other: mean(have.filter((c) => !inLdc(c, done)).map((c) => c[k])),
    };
  };

  function table() {
    const ind = INDICATORS[key];
    const before = averages(key, false);
    const after = averages(key, true);
    for (const g of ['ldc', 'other']) {
      $(`.ldc-${g}-before`).textContent = ind.format(before[g]);
      const cell = $(`.ldc-${g}-after`);
      cell.textContent = ind.format(after[g]);
      cell.classList.toggle('red', Math.sign(after[g] - before[g]) === ind.worse);
    }
    $('.ldc-verdict').style.visibility = graduated ? 'visible' : 'hidden';
  }

  // A row of dots that don't overlap: each placed as close to the row's middle as it fits
  function swarm(items, cy, half) {
    const placed = [];
    for (const it of [...items].sort((a, b) => a.px - b.px)) {
      let y = cy;
      for (let k = 0; k < 40; k++) {
        const off = Math.ceil(k / 2) * (2 * R + 1) * (k % 2 ? -1 : 1);
        if (Math.abs(off) > half) break;
        y = cy + off;
        const clash = placed.some((p) => Math.abs(p.px - it.px) < 2 * R && Math.abs(p.y - y) < 2 * R);
        if (!clash) break;
      }
      placed.push({ ...it, y });
    }
    return new Map(placed.map((p) => [p.c.name, p]));
  }

  function draw(ctx, w, h) {
    const ind = INDICATORS[key];
    const ink = brand('ink');
    const blue = brand('blue');
    const gray = brand('gray');
    const red = brand('red');
    const pad = { left: 24, right: 24, bottom: 70 };
    const [lo, hi] = ind.range;
    const f = ind.log ? Math.log : (v) => v;
    const x = (v) => pad.left + ((f(v) - f(lo)) / (f(hi) - f(lo))) * (w - pad.left - pad.right);
    const rows = {
      ldc: { cy: h * 0.27, label: 'Least developed countries', color: blue },
      other: { cy: h * 0.66, label: 'Other developing countries', color: gray },
    };
    const half = h * 0.13;

    // Where each dot sits on the list (t = 0) and after graduation (t = 1)
    const have = countries.filter((c) => c[key] != null);
    const layout = (done) => {
      const items = (g) => have
        .filter((c) => (g === 'ldc') === inLdc(c, done))
        .map((c) => ({ c, px: Math.min(x(Math.max(lo, c[key])), x(hi)) }));
      return new Map([...swarm(items('ldc'), rows.ldc.cy, half), ...swarm(items('other'), rows.other.cy, half)]);
    };
    const from = layout(false);
    const to = layout(true);

    // Row labels, with the number of countries in each row now
    const n = (g) => have.filter((c) => (g === 'ldc') === inLdc(c, graduated)).length;
    for (const g of ['ldc', 'other']) {
      text(ctx, `${rows[g].label} (${n(g)})`, pad.left, rows[g].cy - half - 24, {
        size: 19, weight: 600, color: g === 'ldc' ? blue : ink,
      });
    }

    // The dots: the graduates last, on top, in red and labelled
    const ordered = [...have].sort((a, b) => a.graduate - b.graduate);
    for (const c of ordered) {
      const a = from.get(c.name);
      const b = to.get(c.name);
      const px = a.px + (b.px - a.px) * t;
      const py = a.y + (b.y - a.y) * t;
      const color = c.graduate ? red : withAlpha(c.ldc ? blue : gray, c.ldc ? 0.75 : 0.55);
      dot(ctx, px, py, c.graduate ? R + 1.5 : R, color);
      if (c.graduate) {
        text(ctx, c.name, px, py - R - 10, { size: 16, weight: 700, align: 'center', color: red });
      }
      if (c[key] > hi) { // off the scale: say so
        text(ctx, `${c.name}: ${ind.format(c[key])} →`, px - R - 6, py, {
          size: 14, align: 'right', baseline: 'middle', color: ink,
        });
      }
    }

    // Each row's average: now (solid), and before the last change (dashed)
    const before = averages(key, false);
    const after = averages(key, true);
    for (const g of ['ldc', 'other']) {
      const { cy } = rows[g];
      const now = before[g] + (after[g] - before[g]) * t;
      if (t > 0.02) {
        line(ctx, x(before[g]), cy - half - 4, x(before[g]), cy + half + 4, { color: gray, width: 2, dash: [5, 4] });
      }
      line(ctx, x(now), cy - half - 8, x(now), cy + half + 8, { color: ink, width: 3 });
      text(ctx, `average ${ind.format(now)}`, x(now) + 8, cy + half + 6, {
        size: 16, weight: 600, baseline: 'top', color: ink,
      });
    }

    xAxis(ctx, x, h - pad.bottom, ind.ticks, {
      title: ind.title,
      format: ind.log ? (v) => (v >= 1000 ? `${v / 1000}k` : String(v)) : String,
    });
  }

  function go() {
    graduated = !graduated;
    button.textContent = graduated ? 'Put them back on the list' : 'Graduate Nepal, Bangladesh and Laos';
    const start = t;
    const end = graduated ? 1 : 0;
    cancel();
    cancel = animate((e) => {
      t = start + (end - start) * e;
      canvas.render();
    });
    table();
  }

  button.addEventListener('click', go);
  for (const input of root.querySelectorAll('input[name="ldc-indicator"]')) {
    input.addEventListener('change', () => {
      key = input.value;
      table();
      canvas.render();
    });
  }
  table();
}
