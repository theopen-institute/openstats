// Shared look for week 1's canvas plots (graph.js, posterior.js): a white plot with a
// light grid, and an x axis for a share from 0 to 1 labelled in percent.
import { brand, withAlpha } from './palette.js';

export function font(px, dpr) {
  return `${px * dpr}px system-ui, -apple-system, Segoe UI, Roboto, Arial`;
}

export function clearCanvas(canvas, ctx) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

// pr: the plot rectangle in canvas pixels ({ x, y, w, h }); dpr: device pixel ratio.
// yTicks: values to draw y grid lines, ticks and labels at, placed by yToCanvas(y).
export function drawPercentAxes(ctx, pr, dpr, { xLabel, yTicks = [], yToCanvas } = {}) {
  const ink = brand('ink');
  const tickLen = 6 * dpr;
  const xs = Array.from({ length: 11 }, (_, i) => i / 10); // 0%, 10%, ..., 100%
  const xToCanvas = (x) => pr.x + x * pr.w;
  const line = (x0, y0, x1, y1) => {
    ctx.beginPath();
    ctx.moveTo(x0, y0);
    ctx.lineTo(x1, y1);
    ctx.stroke();
  };

  ctx.save();

  // Grid
  ctx.strokeStyle = withAlpha(ink, 0.1);
  ctx.lineWidth = 1 * dpr;
  for (const y of yTicks) line(pr.x, yToCanvas(y), pr.x + pr.w, yToCanvas(y));
  for (const x of xs) line(xToCanvas(x), pr.y, xToCanvas(x), pr.y + pr.h);

  // Axes
  ctx.strokeStyle = ink;
  ctx.lineWidth = 1.5 * dpr;
  line(pr.x, pr.y, pr.x, pr.y + pr.h);
  line(pr.x, pr.y + pr.h, pr.x + pr.w, pr.y + pr.h);

  // Ticks and labels
  ctx.fillStyle = ink;
  ctx.font = font(12, dpr);

  ctx.textAlign = 'right';
  ctx.textBaseline = 'middle';
  for (const y of yTicks) {
    const cy = yToCanvas(y);
    line(pr.x, cy, pr.x - tickLen, cy);
    ctx.fillText(String(y), pr.x - tickLen - 6 * dpr, cy);
  }

  ctx.textAlign = 'center';
  ctx.textBaseline = 'top';
  for (const x of xs) {
    const cx = xToCanvas(x);
    line(cx, pr.y + pr.h, cx, pr.y + pr.h + tickLen);
    ctx.fillText(`${Math.round(x * 100)}`, cx, pr.y + pr.h + tickLen + 4 * dpr);
  }
  if (xLabel) ctx.fillText(xLabel, pr.x + pr.w / 2, pr.y + pr.h + tickLen + 20 * dpr);

  ctx.restore();
}

// The y axis's label, running up the axis in muted gray, `gap` (in CSS px) to the left
// of the plot
export function drawYLabel(ctx, pr, dpr, text, gap = 8) {
  ctx.save();
  ctx.fillStyle = brand('gray');
  ctx.font = font(12, dpr);
  ctx.textAlign = 'center';
  ctx.textBaseline = 'bottom';
  ctx.translate(pr.x - gap * dpr, pr.y + pr.h / 2);
  ctx.rotate(-Math.PI / 2);
  ctx.fillText(text, 0, 0);
  ctx.restore();
}
