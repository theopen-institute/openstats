// Week 2, "Taller or heavier?": the adults' heights (top) and weights (bottom), with
// one man marked on each. The slide's fragments step it along:
//   start  each on its own ruler, centimeters and kilograms: two scales that can't be
//          compared
//   1      both rulers change to z-scores (SDs from the average): the histograms
//          stretch onto one shared scale, the averages line up, and his two marks can
//          be compared directly
//   2      each mark also places him in the crowd: the adults below him are shaded,
//          with their share
// Drag either mark to try someone else; he's back when the slide is shown again. Data
// from the page: the adults (adults_widget_data()) and the man (zscore_widget_data(),
// both in r/week2.R). Markup in _includes/week2/z-compare.md.
import { brand, withAlpha } from './palette.js';
import { Canvas, line, mean, pageData, scale, sd, text, ticks } from './canvas-plot.js';
import { animate } from './tween.js';

const STEPS = 2;
const MOVE_MS = 1400; // slow enough to watch the rulers change
const BIN = 2; // cm or kg per bar
const Z_RANGE = [-3.5, 4.5]; // the shared ruler (weight leans right)
const VARS = [
  { key: 'height', title: 'Height', unit: 'cm', range: [129.5, 187.5], color: 'blue', than: 'taller' },
  { key: 'weight', title: 'Weight', unit: 'kg', range: [25, 101], color: 'red', than: 'heavier' },
];

const clamp = (v, lo = 0, hi = 1) => Math.max(lo, Math.min(hi, v));
const signed = (z, d = 2) => `${z < 0 ? '−' : '+'}${Math.abs(z).toFixed(d)}`;

const adults = pageData('adults-data');
const data = pageData('zscore-data');
const root = document.querySelector('.z-compare');
if (root && adults && data) init(root, adults, data);

function init(root, adults, data) {
  const vars = VARS.map((v) => {
    const xs = adults[v.key];
    const counts = new Array(Math.round((v.range[1] - v.range[0]) / BIN)).fill(0);
    for (const x of xs) {
      const i = Math.floor((x - v.range[0]) / BIN);
      if (i >= 0 && i < counts.length) counts[i] += 1;
    }
    return { ...v, xs, m: mean(xs), s: sd(xs), counts, max: Math.max(...counts) };
  });
  const below = (v, x) => v.xs.filter((d) => d < x).length / v.xs.length;

  let person = { ...data.person };
  let t = 0; // the ruler: 0 in units, 1 in z-scores
  let q = 0; // the crowd below him, shaded
  let target = null;
  let cancel = () => {};
  let panels = []; // each variable's geometry, for dragging

  const canvas = new Canvas(root.querySelector('.w2-graph'), draw);

  function draw(ctx, w, h) {
    const ink = brand('ink');
    const gray = brand('gray');
    const pad = { left: 24, right: 24, top: 6, bottom: 4 };
    const gap = 26;
    const ph = (h - pad.top - pad.bottom - gap) / 2;
    const axisH = 78; // below each panel's bars: ticks, labels and title
    const headH = 70; // above its bars: the panel's title and his label
    const Z = scale(Z_RANGE[0], Z_RANGE[1], pad.left, w - pad.right);

    panels = vars.map((v, i) => {
      const top = pad.top + i * (ph + gap);
      const base = top + ph - axisH;
      const U = scale(v.range[0], v.range[1], pad.left, w - pad.right);
      // Each value's place: on its own ruler, on the z ruler, or in between
      const px = (x) => (1 - t) * U(x) + t * Z((x - v.m) / v.s);
      const inv = (p) => {
        const [a, b] = [px(v.range[0]), px(v.range[1])];
        return v.range[0] + ((p - a) * (v.range[1] - v.range[0])) / (b - a);
      };
      return { v, top, base, px, inv, y: scale(0, v.max, base, top + headH) };
    });

    // The shared z ruler's whole SDs, in both panels, as it comes in
    for (const P of panels) {
      if (t <= 0) break;
      for (let z = -3; z <= 4; z++) {
        line(ctx, Z(z), P.top + headH - 14, Z(z), P.base, {
          color: withAlpha(brand('blue'), (z === 0 ? 0.5 : 0.18) * t),
          width: z === 0 ? 2 : 1.5,
        });
      }
    }

    for (const P of panels) {
      const { v, top, base, px, y } = P;
      const color = brand(v.color);
      const value = person[v.key];
      const z = (value - v.m) / v.s;
      const xv = px(value);

      ctx.save();
      ctx.beginPath();
      ctx.rect(pad.left, top, w - pad.left - pad.right, base - top);
      ctx.clip();
      const bars = (fill) => {
        ctx.fillStyle = fill;
        v.counts.forEach((c, i) => {
          if (!c) return;
          const x0 = px(v.range[0] + i * BIN);
          const x1 = px(v.range[0] + (i + 1) * BIN);
          ctx.fillRect(x0 + 0.75, y(c), Math.max(0.5, x1 - x0 - 1.5), base - y(c));
        });
      };
      bars(withAlpha(gray, 0.5));
      if (q > 0) {
        ctx.save();
        ctx.beginPath();
        ctx.rect(pad.left, top, xv - pad.left, base - top);
        ctx.clip();
        bars(withAlpha(color, 0.5 * q));
        ctx.restore();
      }
      ctx.restore();

      // The average, and him
      line(ctx, px(v.m), top + headH - 14, px(v.m), base, { color: ink, width: 2, dash: [7, 6] });
      text(ctx, 'average', px(v.m) - 8, top + headH - 4, { size: 14, color: gray, align: 'right' });
      line(ctx, xv, top + headH - 14, xv, base, { color, width: 4 });

      // His label: the value on its own ruler, his z-score on the shared one, and,
      // later, the share below him
      const right = xv > w - 260;
      const lab = (str, dy, alpha, opts = {}) => {
        if (alpha <= 0) return;
        ctx.save();
        ctx.globalAlpha = alpha;
        text(ctx, str, xv + (right ? -12 : 12), top + dy, {
          size: 19, weight: 700, color, align: right ? 'right' : 'left', halo: true, ...opts,
        });
        ctx.restore();
      };
      lab(`${value} ${v.unit}`, 26, clamp(1 - 2 * t));
      lab(`z = ${signed(z)}`, 26, clamp(2 * t - 1));
      lab(`${v.than} than ${Math.round(100 * below(v, value))}%`, 54, q, { size: 16, weight: 600 });
      text(ctx, v.title, pad.left, top + 26, { size: 19, weight: 700, color: ink });

      // The ruler: its units fading out, z-scores fading in
      line(ctx, pad.left, base, w - pad.right, base, { color: ink });
      const tickAt = (x, label, alpha, opts) => {
        if (alpha <= 0 || x < pad.left - 1 || x > w - pad.right + 1) return;
        ctx.save();
        ctx.globalAlpha = alpha;
        line(ctx, x, base, x, base + 6, { color: opts.color });
        text(ctx, label, x, base + 10, { size: 16, align: 'center', baseline: 'top', ...opts });
        ctx.restore();
      };
      for (const u of ticks(Math.ceil(v.range[0] / 10) * 10, v.range[1], 10)) {
        tickAt(px(u), String(u), 1 - t, { color: ink });
      }
      for (let k = -3; k <= 4; k++) {
        tickAt(px(v.m + k * v.s), k ? signed(k, 0) : '0', t, { color: brand('blue'), weight: 700 });
      }
      const titleAt = (str, alpha, c) => {
        ctx.save();
        ctx.globalAlpha = alpha;
        text(ctx, str, w / 2, base + 42, { size: 17, align: 'center', baseline: 'top', color: c });
        ctx.restore();
      };
      titleAt(`${v.title} (${v.unit})`, clamp(1 - 2 * t), ink);
      titleAt(`${v.title} (z-score: SDs from the average)`, clamp(2 * t - 1), brand('blue'));
    }
  }

  // Drag a mark (or click where it should go) in either panel
  const el = canvas.canvas;
  let dragging = null;
  const moveTo = (event) => {
    const P = dragging;
    if (!P) return;
    const x = P.inv(canvas.point(event).x);
    person = { ...person, [P.v.key]: Math.round(clamp(x, P.v.range[0] + 0.5, P.v.range[1] - 0.5)) };
    canvas.render();
  };
  el.style.cursor = 'ew-resize';
  el.style.touchAction = 'none';
  el.addEventListener('pointerdown', (event) => {
    const { y } = canvas.point(event);
    dragging = panels.find((P) => y >= P.top && y <= P.base + 40) ?? null;
    if (!dragging) return;
    el.setPointerCapture(event.pointerId);
    moveTo(event);
  });
  el.addEventListener('pointermove', (event) => {
    if (el.hasPointerCapture(event.pointerId)) moveTo(event);
  });
  el.addEventListener('pointerup', () => { dragging = null; });

  // The step the slide's fragments are at, or null when the slide isn't showing
  function fragmentStep() {
    const slide = window.Reveal?.getCurrentSlide?.();
    if (!slide) return 0;
    if (!slide.contains(root)) return null;
    const shown = slide.querySelectorAll('.fragment.visible');
    return Math.min(STEPS, new Set([...shown].map((f) => f.dataset.fragmentIndex)).size);
  }

  function show(step) {
    if (step == null) {
      person = { ...data.person }; // off the slide: back to the man
      return;
    }
    const to = { t: step >= 1 ? 1 : 0, q: step >= 2 ? 1 : 0 };
    if (target && to.t === target.t && to.q === target.q) return;
    target = to;
    const from = { t, q };
    cancel();
    const far = Math.max(Math.abs(to.t - from.t), Math.abs(to.q - from.q));
    cancel = animate((e) => {
      t = from.t + (to.t - from.t) * e;
      q = from.q + (to.q - from.q) * e;
      canvas.render();
    }, (to.t !== from.t ? MOVE_MS : MOVE_MS / 2) * Math.min(1, far));
  }

  for (const event of ['fragmentshown', 'fragmenthidden', 'slidechanged', 'ready']) {
    window.Reveal?.on?.(event, () => show(fragmentStep()));
  }
  show(fragmentStep());
}
