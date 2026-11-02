// Week 2, "The distributions behind the averages": the Will Rogers paradox in Nepal's earnings data. Paid
// employees as two distributions of monthly earnings, secondary or less (top) and
// post-secondary (bottom), each the sum of its education levels' curves, drawn to one
// scale, so a curve's area is its number of employees. Each group's average is a line
// through it, labelled with the opening slide's numbers. Grades 11–12 sit at the bottom
// of their group's curve. The slide's fragments step it along:
//   start  2008, grades 11–12 counted as post-secondary, as the 2008 tables count them
//   1      2017/18, still counted that way
//   2      grades 11–12 light up green, and are named
//   3      they rise into the secondary group, as the 2017/18 tables count them, pushing
//          its curve up: both averages rise, and nobody's pay changed
// Each change animates, and the averages before it stay behind, dashed. Back a
// fragment, and it goes back. The shapes are hypothetical: each level is a log-normal
// with the survey's average and a made-up spread. Data from the page (r/week2.R,
// reclass_widget_data()). Markup in _includes/week2/reclass.md, styles in
// css/deck.scss (.w2-*).
import { brand, withAlpha } from './palette.js';
import { Canvas, line, pageData, scale, text, ticks, xAxis } from './canvas-plot.js';
import { animate } from './tween.js';

const X_RANGE = [0, 70]; // thousand rupees a month
const STEP = 0.25; // between the curves' points, thousand rupees
const MOVE_MS = 1800; // slow enough to watch

// Each step: the year (u: 0 is 2008, 1 is 2017/18), where grades 11–12 are counted
// (m: 0 post-secondary, 1 secondary), whether they're green, and a heading
const STEPS = [
  { u: 0, m: 0, lit: 0, heading: '2008 survey results' },
  { u: 1, m: 0, lit: 0, heading: '2017/18 survey results' },
  { u: 1, m: 0, lit: 1, heading: '2017/18 survey results' },
  { u: 1, m: 1, lit: 1, heading: '2017/18 survey results (Grades 11–12 reclassified)' },
];

function lognormal(x, mean, s) {
  if (x <= 0) return 0;
  const mu = Math.log(mean) - (s * s) / 2; // so the curve's mean is `mean`
  return Math.exp(-((Math.log(x) - mu) ** 2) / (2 * s * s)) / (x * s * Math.sqrt(2 * Math.PI));
}

// Thousands as people, or as rupees to the nearest ten, the way the slides write them
const people = (n) => (Math.round(n) * 1000).toLocaleString('en-US');
const rupees = (v) => `Rs ${(Math.round(v * 100) * 10).toLocaleString('en-US')}`;

const mix = (a, b, f) => a + (b - a) * f;
const mixAll = (a, b, f) => a.map((v, i) => mix(v, b[i], f));

function init(root, { sdlog, levels }) {
  const xs = [];
  for (let v = X_RANGE[0]; v <= X_RANGE[1] + 1e-9; v += STEP) xs.push(v);
  const pick = (year, ...groups) => levels.filter((l) => l.year === year && groups.includes(l.group));
  // Employees (thousands) per thousand rupees of earnings, at each of xs
  const curve = (ls) => xs.map((v) => ls.reduce((a, l) => a + l.employees * lognormal(v, l.earnings, sdlog), 0));
  const sum = (ls) => ls.reduce((a, l) => a + l.employees, 0);
  const avg = (ls) => ls.reduce((a, l) => a + l.employees * l.earnings, 0) / sum(ls);

  // Each part's curve in 2008 [0] and 2017/18 [1]
  const curves = Object.fromEntries(['post', 'secondary', 'movers'].map((g) => [g, [curve(pick(2008, g)), curve(pick(2017, g))]]));
  // Each group's members at each step
  const members = (year, moved) => ({
    post: pick(year, ...(moved ? ['post'] : ['post', 'movers'])),
    secondary: pick(year, ...(moved ? ['secondary', 'movers'] : ['secondary'])),
    all: pick(year, 'post', 'secondary', 'movers'),
  });
  const counts = STEPS.map((k) => members(k.u ? 2017 : 2008, k.m === 1));
  const stats = counts.map((c) => Object.fromEntries(Object.entries(c).map(([g, ls]) => [g, { avg: avg(ls), n: sum(ls) }])));
  // One scale throughout: the tallest each row gets
  const tallest = (a, b) => Math.max(...a.map((v, i) => v + b[i]));
  const peak = {
    post: Math.max(...[0, 1].map((y) => tallest(curves.post[y], curves.movers[y]))),
    secondary: Math.max(...[0, 1].map((y) => tallest(curves.secondary[y], curves.movers[y]))),
  };
  const moverCount = sum(pick(2017, 'movers'));

  let p = 0; // where along STEPS (eased in between)
  let target = 0;
  let cancel = () => {};

  // The steps either side of p, and how far between them
  const between = () => {
    const i = Math.max(0, Math.min(STEPS.length - 2, Math.floor(p)));
    return [i, p - i];
  };
  const now = (fn) => {
    const [i, f] = between();
    return mix(fn(i), fn(i + 1), f);
  };

  const canvas = new Canvas(root.querySelector('.w2-graph'), draw);

  function draw(ctx, w, h) {
    const ink = brand('ink');
    const blue = brand('blue');
    const green = brand('green');
    const gray = brand('gray');
    const pad = { left: 24, right: 44, top: 120, bottom: 76 }; // right: room for 70,000
    const gap = 70; // between the rows
    const x = scale(X_RANGE[0], X_RANGE[1], pad.left, w - pad.right);
    const k = (h - pad.top - pad.bottom - gap) / (peak.post + peak.secondary); // px per unit
    // Secondary or less on top, post-secondary below, as on the opening slide
    const rows = {
      secondary: { base: pad.top + peak.secondary * k, height: peak.secondary * k, color: ink, name: 'Secondary or less' },
      post: { base: h - pad.bottom, height: peak.post * k, color: blue, name: 'Post-secondary' },
    };
    const u = now((i) => STEPS[i].u);
    const m = now((i) => STEPS[i].m);
    const lit = now((i) => STEPS[i].lit);

    // An area between two edges (pixel rows at each of xs), filled, with its top stroked
    const area = (bottom, top, fill, stroke) => {
      ctx.beginPath();
      xs.forEach((v, i) => (i ? ctx.lineTo(x(v), top[i]) : ctx.moveTo(x(v), top[i])));
      for (let i = xs.length - 1; i >= 0; i--) ctx.lineTo(x(xs[i]), bottom[i]);
      ctx.closePath();
      ctx.fillStyle = fill;
      ctx.fill();
      if (!stroke) return;
      ctx.beginPath();
      xs.forEach((v, i) => (i ? ctx.lineTo(x(v), top[i]) : ctx.moveTo(x(v), top[i])));
      ctx.strokeStyle = stroke;
      ctx.lineWidth = 2.5;
      ctx.stroke();
    };

    // Grades 11–12 at the bottom of their group's curve, lifting the rest of it: from the
    // base of post-secondary's up to the base of secondary's
    const moverH = mixAll(...curves.movers, u).map((v) => v * k); // their height, px
    const moverBase = mix(rows.post.base, rows.secondary.base, m);
    const moverTop = moverH.map((v) => moverBase - v);
    const postBase = moverH.map((v) => rows.post.base - v * (1 - m));
    const secBase = moverH.map((v) => rows.secondary.base - v * m);
    const postTop = mixAll(...curves.post, u).map((v, i) => postBase[i] - v * k);
    const secTop = mixAll(...curves.secondary, u).map((v, i) => secBase[i] - v * k);
    area(secBase, secTop, withAlpha(ink, 0.28), ink);
    area(postBase, postTop, withAlpha(blue, 0.3), blue);
    // Unlit, they're part of post-secondary's curve; lit, green
    const moverFill = lit > 0 ? withAlpha(green, 0.55 * lit) : withAlpha(blue, 0.3);
    if (lit > 0) area(xs.map(() => moverBase), moverTop, withAlpha(blue, 0.3 * (1 - lit)), null);
    area(xs.map(() => moverBase), moverTop, moverFill, lit > 0 ? withAlpha(green, lit) : null);
    // Named as they light up (fully shown a third of the way in), and the name rides
    // with them when they move
    if (lit > 0) {
      const peakAt = moverH.indexOf(Math.max(...moverH));
      const px = x(xs[peakAt]) - 16;
      const py = moverTop[peakAt];
      const style = { align: 'right', baseline: 'top', color: green, halo: true };
      ctx.save();
      ctx.globalAlpha = Math.min(1, lit * 3);
      text(ctx, 'Grades 11–12', px, py - 52, { size: 16, weight: 700, ...style });
      text(ctx, `${people(moverCount)} employees`, px, py - 26, { size: 15, weight: 600, ...style });
      ctx.restore();
    }

    text(ctx, STEPS[Math.round(p)].heading, pad.left, 24, { size: 19, weight: 700, baseline: 'top' });

    // Baselines, and each group's name and number of employees
    for (const [g, row] of Object.entries(rows)) {
      line(ctx, pad.left, row.base, w - pad.right, row.base, { color: ink });
      text(ctx, row.name, w - pad.right, row.base - row.height - 34, {
        size: 19, weight: 700, align: 'right', color: row.color,
      });
      text(ctx, `${people(now((i) => stats[i][g].n))} employees`, w - pad.right, row.base - row.height - 8, {
        size: 15, align: 'right', color: gray,
      });
    }

    // Both groups together
    const both = now((i) => stats[i].all.avg);
    line(ctx, x(both), pad.top - 22, x(both), rows.secondary.base, { color: gray, width: 2, dash: [3, 5] });
    text(ctx, `both groups: ${rupees(both)}`, x(both), pad.top - 30, {
      size: 15, align: 'center', color: gray, halo: true,
    });

    // Each group's average now (solid), and before the last change (dashed): 2008's
    // while the years pass, then 2017/18's before grades 11–12 move
    const before = p > 2 ? 2 : 0;
    for (const [g, row] of Object.entries(rows)) {
      const avgNow = now((i) => stats[i][g].avg);
      const top = row.base - row.height - 4;
      if (p > 0.01) {
        line(ctx, x(stats[before][g].avg), top, x(stats[before][g].avg), row.base, { color: gray, width: 2, dash: [7, 5] });
      }
      line(ctx, x(avgNow), top, x(avgNow), row.base, { color: row.color, width: 4 });
      text(ctx, `average ${rupees(avgNow)}`, x(avgNow) + 8, top + 2, {
        size: 16, weight: 700, baseline: 'top', color: row.color, halo: true,
      });
    }

    xAxis(ctx, x, rows.post.base, ticks(X_RANGE[0], X_RANGE[1], 10), {
      title: 'Monthly earnings (rupees, inflation adjusted to 2026)',
      format: (v) => (v * 1000).toLocaleString('en-US'),
    });
  }

  // The step the slide's fragments are at (how many of them are showing), or null when
  // the slide isn't. Reveal renumbers fragment indices, so they're counted, not read.
  function fragmentStep() {
    const slide = window.Reveal?.getCurrentSlide?.();
    if (!slide) return 0;
    if (!slide.contains(root)) return null;
    const shown = slide.querySelectorAll('.fragment.visible');
    return new Set([...shown].map((el) => el.dataset.fragmentIndex)).size;
  }

  function show(step) {
    if (step == null) return;
    const to = Math.min(step, STEPS.length - 1);
    if (to === target) return;
    target = to;
    const from = p;
    cancel();
    cancel = animate((e) => {
      p = from + (to - from) * e;
      canvas.render();
    }, MOVE_MS * Math.min(1, Math.abs(to - from))); // a jump of several steps, in one
  }

  for (const event of ['fragmentshown', 'fragmenthidden', 'slidechanged', 'ready']) {
    window.Reveal?.on?.(event, () => show(fragmentStep()));
  }
  show(fragmentStep());
}

const root = document.querySelector('.reclass');
const data = pageData('reclass-data');
if (root && data) init(root, data);
