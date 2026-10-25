// Shared drawing for week 2's canvas widgets (galton.js, sample-mean.js, conditional.js,
// model-builder.js). A Canvas fills its container and is drawn in the slide's own,
// unscaled pixels, so text and lines size with the rest of the slide however reveal
// scales the deck.
import { brand } from './palette.js';

export const font = (px, weight = 400) =>
  `${weight} ${px}px Inter, system-ui, -apple-system, "Segoe UI", sans-serif`;

export class Canvas {
  // draw(ctx, width, height) paints the whole picture, in slide pixels
  constructor(container, draw) {
    this.container = container;
    this.draw = draw;
    this.canvas = document.createElement('canvas');
    Object.assign(this.canvas.style, { width: '100%', height: '100%', display: 'block' });
    container.appendChild(this.canvas);
    this.ctx = this.canvas.getContext('2d');
    // The container's box changes when its slide is first shown; reveal's scale
    // changes with the window
    new ResizeObserver(() => this.resize()).observe(container);
    window.addEventListener('resize', () => this.resize());
    window.Reveal?.on?.('resize', () => this.resize());
    window.Reveal?.on?.('slidechanged', () => this.resize());
    this.resize();
  }

  resize() {
    const w = this.container.clientWidth;
    const h = this.container.clientHeight;
    if (w < 1 || h < 1) return; // on a hidden slide
    const shown = this.container.getBoundingClientRect().width / w; // reveal's scale
    const k = Math.max(1, shown * (window.devicePixelRatio || 1));
    this.canvas.width = Math.round(w * k);
    this.canvas.height = Math.round(h * k);
    Object.assign(this, { width: w, height: h, k });
    this.render();
  }

  render() {
    if (!this.k) return;
    const { ctx } = this;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    ctx.setTransform(this.k, 0, 0, this.k, 0, 0);
    this.draw(ctx, this.width, this.height);
  }

  // A pointer event's position, in slide pixels
  point(event) {
    const r = this.canvas.getBoundingClientRect();
    return {
      x: ((event.clientX - r.left) * this.width) / r.width,
      y: ((event.clientY - r.top) * this.height) / r.height,
    };
  }
}

// A linear map from data [d0, d1] to pixels [p0, p1], with .invert for the way back
export function scale(d0, d1, p0, p1) {
  const f = (v) => p0 + ((v - d0) * (p1 - p0)) / (d1 - d0);
  f.invert = (p) => d0 + ((p - p0) * (d1 - d0)) / (p1 - p0);
  return f;
}

// The multiples of `step` from lo to hi
export function ticks(lo, hi, step) {
  const out = [];
  for (let v = Math.ceil(lo / step) * step; v <= hi + 1e-9; v += step) out.push(+v.toFixed(9));
  return out;
}

export function text(ctx, str, x, y, {
  size = 18, weight = 400, color = brand('ink'), align = 'left', baseline = 'alphabetic',
} = {}) {
  ctx.font = font(size, weight);
  ctx.fillStyle = color;
  ctx.textAlign = align;
  ctx.textBaseline = baseline;
  ctx.fillText(str, x, y);
}

export function line(ctx, x0, y0, x1, y1, { color = brand('ink'), width = 1.5, dash = [] } = {}) {
  ctx.save();
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.setLineDash(dash);
  ctx.beginPath();
  ctx.moveTo(x0, y0);
  ctx.lineTo(x1, y1);
  ctx.stroke();
  ctx.restore();
}

export function dot(ctx, x, y, r, color) {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.arc(x, y, r, 0, 2 * Math.PI);
  ctx.fill();
}

// A horizontal axis at pixel row y, over x's range: a baseline, a tick and label at
// each value, and a title underneath. x is a scale(); grid: the top of light grid
// lines up from each tick, if any.
export function xAxis(ctx, x, y, values, { title, format = String, grid } = {}) {
  const ink = brand('ink');
  const [left, right] = [x(values[0]), x(values[values.length - 1])];
  for (const v of values) {
    if (grid != null) line(ctx, x(v), grid, x(v), y, { color: 'rgba(22, 49, 77, 0.08)', width: 1 });
    line(ctx, x(v), y, x(v), y + 6, { color: ink });
    text(ctx, format(v), x(v), y + 10, { size: 16, align: 'center', baseline: 'top' });
  }
  line(ctx, Math.min(left, right), y, Math.max(left, right), y, { color: ink });
  if (title) text(ctx, title, (left + right) / 2, y + 34, { size: 17, align: 'center', baseline: 'top' });
}

// A vertical axis at pixel column x, the same way. Its title runs up the axis.
export function yAxis(ctx, y, x, values, { title, format = String, grid } = {}) {
  const ink = brand('ink');
  for (const v of values) {
    if (grid != null) line(ctx, x, y(v), grid, y(v), { color: 'rgba(22, 49, 77, 0.08)', width: 1 });
    line(ctx, x - 6, y(v), x, y(v), { color: ink });
    text(ctx, format(v), x - 10, y(v), { size: 16, align: 'right', baseline: 'middle' });
  }
  const [top, bottom] = [y(values[values.length - 1]), y(values[0])];
  line(ctx, x, Math.min(top, bottom), x, Math.max(top, bottom), { color: ink });
  if (title) {
    ctx.save();
    ctx.translate(x - 52, (top + bottom) / 2);
    ctx.rotate(-Math.PI / 2);
    text(ctx, title, 0, 0, { size: 17, align: 'center', baseline: 'bottom' });
    ctx.restore();
  }
}

export const normalDensity = (x, mean, sd) =>
  Math.exp(-0.5 * ((x - mean) / sd) ** 2) / (sd * Math.sqrt(2 * Math.PI));

export const mean = (xs) => xs.reduce((a, b) => a + b, 0) / xs.length;

export function sd(xs) {
  const m = mean(xs);
  return Math.sqrt(xs.reduce((a, b) => a + (b - m) ** 2, 0) / (xs.length - 1));
}

// The JSON data block an R chunk wrote on the page (r/week2.R, json_script())
export function pageData(id) {
  const el = document.getElementById(id);
  return el ? JSON.parse(el.textContent) : null;
}
