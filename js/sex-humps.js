// Week 2, "Describing distributions": the adults' heights, in the same bars as the
// other height plots. The slide's fragments step it along:
//   start  everyone, in gray
//   1      the same bars colored by sex, women at the bottom and men stacked on top, so
//          the outline doesn't move
//   2      the bars separate: each bar splits in two, women's half on the left and men's
//          on the right, both from the baseline, and each sex's Normal (its own mean
//          and SD) draws in over its bars
//   3      they stack back up, and the two Normals added together (dashed) follow the
//          outline: one lopsided bell
// Each change animates, and goes back with the fragment. Data from the page
// (r/week2.R, sex_humps_widget_data()). Markup in _includes/week2/sex-humps.md, styles
// in css/deck.scss (.w2-*).
import { brand } from './palette.js';
import { Canvas, line, normalDensity, pageData, scale, text, ticks, xAxis, yAxis } from './canvas-plot.js';
import { animate } from './tween.js';

const STEPS = 3;
const MOVE_MS = 1400; // slow enough to watch
const LIGHTEN = 0.55; // how far the bars fade toward white once the curves are on them

const clamp = (v) => Math.max(0, Math.min(1, v));

// A "#rrggbb" color as [r, g, b], two of those mixed (f = 0 is a, 1 is b), and one as
// an rgb() string
const rgb = (hex) => [16, 8, 0].map((s) => (parseInt(hex.slice(1), 16) >> s) & 255);
const blend = (a, b, f) => a.map((v, i) => v + (b[i] - v) * f);
const css = (c) => `rgb(${c.map(Math.round).join(', ')})`;

function init(root, data) {
  const { width, left, women, men, normals, xlim, ylim, ystep } = data;
  const sexes = [
    { key: 'women', counts: women, color: 'red' },
    { key: 'men', counts: men, color: 'blue' },
  ];
  // The Normals' points, in adults per bar
  const xs = [];
  for (let v = xlim[0]; v <= xlim[1] + 1e-9; v += 0.25) xs.push(v);
  const curve = ({ mean, sd, n }) => xs.map((v) => n * width * normalDensity(v, mean, sd));
  const curves = { women: curve(normals.women), men: curve(normals.men) };
  const sum = xs.map((_, i) => curves.women[i] + curves.men[i]);

  let p = 0; // where along the steps (eased in between)
  let target = 0;
  let cancel = () => {};

  const canvas = new Canvas(root.querySelector('.w2-graph'), draw);

  function draw(ctx, w, h) {
    const ink = brand('ink');
    const gray = brand('gray');
    const pad = { left: 96, right: 28, top: 24, bottom: 84 };
    const x = scale(xlim[0], xlim[1], pad.left, w - pad.right);
    const y = scale(ylim[0], ylim[1], h - pad.bottom, pad.top);
    const base = y(0);

    const colored = clamp(p); // gray to women and men
    const apart = p <= 2 ? clamp(p - 1) : 1 - clamp(p - 2); // stacked to side by side
    const light = clamp(p - 1); // the bars fade back for the curves
    const fills = Object.fromEntries(sexes.map((s) => {
      const c = blend(rgb(gray), rgb(brand(s.color)), colored);
      return [s.key, css(blend(c, [255, 255, 255], LIGHTEN * light))];
    }));

    yAxis(ctx, y, pad.left, ticks(0, ylim[1], ystep), { title: 'Number of adults', grid: w - pad.right });
    xAxis(ctx, x, base, ticks(Math.ceil(xlim[0] / 10) * 10, xlim[1], 10), { title: 'Height (cm)', grid: pad.top });

    // Each bar: women from the baseline, narrowing to the left half; men from the top
    // of the women's bar down to the baseline, narrowing to the right half. White
    // outlines, as in the plots; in gray, a stacked bar is one bar, so the line between
    // its women and men comes in with the color.
    const rect = (x0, x1, y0, y1) => [x(x0), y(y1), x(x1) - x(x0), y(y0) - y(y1)];
    const outline = (r, alpha = 1) => {
      ctx.save();
      ctx.globalAlpha = alpha;
      ctx.strokeStyle = 'white';
      ctx.lineWidth = 1.5;
      ctx.strokeRect(...r);
      ctx.restore();
    };
    left.forEach((l, i) => {
      const [f, m] = [women[i], men[i]];
      const mBase = f * (1 - apart);
      const parts = [
        { r: rect(l, l + width * (1 - apart / 2), 0, f), fill: fills.women, n: f },
        { r: rect(l + (width * apart) / 2, l + width, mBase, mBase + m), fill: fills.men, n: m },
      ].filter((b) => b.n > 0);
      // While stacked, men's part reaches a pixel into women's, so no hairline of
      // background shows where they meet
      if (apart < 1 && parts.length === 2) parts[1].r[3] += 1;
      for (const b of parts) {
        ctx.fillStyle = b.fill;
        ctx.fillRect(...b.r);
      }
      if (apart < 1 && parts.length === 2) parts[1].r[3] -= 1;
      outline(rect(l, l + width, 0, f + m), 1 - apart); // the whole bar, while stacked
      for (const b of parts) outline(b.r, Math.max(colored * (1 - apart), apart));
    });

    const path = (ys, color, lineWidth, dash = []) => {
      ctx.save();
      ctx.strokeStyle = color;
      ctx.lineWidth = lineWidth;
      ctx.setLineDash(dash);
      ctx.beginPath();
      xs.forEach((v, i) => (i ? ctx.lineTo(x(v), y(ys[i])) : ctx.moveTo(x(v), y(ys[i]))));
      ctx.stroke();
      ctx.restore();
    };
    ctx.save();
    ctx.globalAlpha = clamp(p - 1);
    for (const s of sexes) path(curves[s.key], brand(s.color), 4);
    ctx.restore();
    ctx.save();
    ctx.globalAlpha = clamp(p - 2);
    path(sum, ink, 3, [10, 7]);
    ctx.restore();

    // Each sex named over its average
    ctx.save();
    ctx.globalAlpha = colored;
    for (const s of sexes) {
      text(ctx, s.key, x(normals[s.key].mean), pad.top + 12, {
        size: 24, weight: 700, align: 'center', baseline: 'top', color: brand(s.color), halo: true,
      });
    }
    ctx.restore();
    line(ctx, pad.left, base, w - pad.right, base, { color: ink });
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
    const to = Math.min(step, STEPS);
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

const root = document.querySelector('.sex-humps');
const data = pageData('sex-humps-data');
if (root && data) init(root, data);
