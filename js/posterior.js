import { brand } from './palette.js';
import { clearCanvas, drawPercentAxes, font } from './canvas-axes.js';
import { animate, onCurrentSlide, whenShown } from './tween.js';

// Read-only canvas plot of one or more curves over x in [0, 1], used to show
// prior, likelihood and posterior together. Styled to match LineGraphWidget.
//
// Changes are animated: each curve, and the height of the y axis, eases from what's on
// screen to the new values. A plot changed while its slide is hidden waits, and
// animates when the slide comes into view; the first time, its curves grow from zero.
export class PosteriorPlot {
  constructor({ container, xLabel = "Percent of Voters", yLabel = "Plausibility" } = {}) {
    if (!container) throw new Error("PosteriorPlot: container is required");
    this.container = container;
    this.xLabel = xLabel;
    this.yLabel = yLabel;
    this.series = []; // the curves to show
    this._shown = null; // the curves on screen now, partway through a transition
    this._shownMax = null;
    this._pending = false; // changed while hidden
    this._cancel = () => {};

    this.padding = { left: 24, right: 16, top: 16, bottom: 46 };

    this.canvas = document.createElement("canvas");
    this.canvas.style.width = "100%";
    this.canvas.style.height = "100%";
    this.canvas.style.display = "block";
    container.appendChild(this.canvas);
    this.ctx = this.canvas.getContext("2d");

    this._onResize = this._onResize.bind(this);
    window.addEventListener("resize", this._onResize);
    this._resizeObserver = new ResizeObserver(this._onResize);
    this._resizeObserver.observe(container);

    this._onResize();
    whenShown(container, () => {
      if (this._pending) this._transition();
    });
  }

  destroy() {
    window.removeEventListener("resize", this._onResize);
    this._resizeObserver.disconnect();
    this.canvas.remove();
  }

  // series: [{ label, color, xs, ys, dash?: number[], fill?: string, line?: false }]
  // (line: false draws only the fill, e.g. to shade part of another curve)
  setSeries(series) {
    this.series = Array.isArray(series) ? series : [];
    this._pending = true;
    if (onCurrentSlide(this.container)) this._transition();
  }

  // -------- internal --------

  _onResize() {
    const rect = this.container.getBoundingClientRect();
    if (rect.width < 1 || rect.height < 1) return; // hidden slide
    const dpr = window.devicePixelRatio || 1;
    this.canvas.width = Math.round(rect.width * dpr);
    this.canvas.height = Math.round(rect.height * dpr);
    this.dpr = dpr;
    this._draw();
  }

  _plotRect() {
    const { left, right, top, bottom } = this.padding;
    return {
      x: left * this.dpr,
      y: top * this.dpr,
      w: Math.max(1, this.canvas.width - (left + right) * this.dpr),
      h: Math.max(1, this.canvas.height - (top + bottom) * this.dpr),
    };
  }

  _yMax() {
    let m = 0;
    for (const s of this.series) {
      for (const y of s.ys) if (Number.isFinite(y) && y > m) m = y;
    }
    return m > 0 ? m * 1.08 : 1;
  }

  // Ease from the curves on screen to this.series. A curve matches the one in the same
  // position; a new one (or the first time) grows from zero.
  _transition() {
    this._pending = false;
    this._cancel();
    const to = this.series;
    const toMax = this._yMax();
    const from = to.map((s, i) => {
      const prev = this._shown?.[i]?.ys;
      return prev && prev.length === s.ys.length ? prev : s.ys.map(() => 0);
    });
    const fromMax = this._shownMax ?? toMax;
    this._cancel = animate((e) => {
      this._shown = to.map((s, i) => ({
        ...s,
        ys: s.ys.map((y, j) => from[i][j] + ((Number.isFinite(y) ? y : 0) - from[i][j]) * e),
      }));
      this._shownMax = fromMax + (toMax - fromMax) * e;
      this._draw();
    });
  }

  _draw() {
    if (!this.dpr) return;
    clearCanvas(this.canvas, this.ctx);
    this._drawAxesAndGrid();
    for (const s of this._shown ?? []) this._drawSeries(s, this._shownMax);
    this._drawLegend();
  }

  _drawAxesAndGrid() {
    const ctx = this.ctx;
    const pr = this._plotRect();
    drawPercentAxes(ctx, pr, this.dpr, { xLabel: this.xLabel });

    ctx.save();

    // 50% line: the threshold for winning
    ctx.strokeStyle = brand("gray");
    ctx.lineWidth = 1 * this.dpr;
    ctx.setLineDash([4 * this.dpr, 4 * this.dpr]);
    ctx.beginPath();
    ctx.moveTo(pr.x + 0.5 * pr.w, pr.y);
    ctx.lineTo(pr.x + 0.5 * pr.w, pr.y + pr.h);
    ctx.stroke();
    ctx.setLineDash([]);

    // Y axis is relative (plausibility or likelihood); absolute values aren't shown
    ctx.fillStyle = brand("ink");
    ctx.font = font(12, this.dpr);
    ctx.textAlign = "center";
    ctx.translate(pr.x - 8 * this.dpr, pr.y + pr.h / 2);
    ctx.rotate(-Math.PI / 2);
    ctx.textBaseline = "bottom";
    ctx.fillText(this.yLabel, 0, 0);

    ctx.restore();
  }

  _drawSeries(s, yMax) {
    const ctx = this.ctx;
    const pr = this._plotRect();
    const toX = (x) => pr.x + x * pr.w;
    const toY = (y) => pr.y + (1 - y / yMax) * pr.h;

    ctx.save();

    if (s.fill) {
      ctx.fillStyle = s.fill;
      ctx.beginPath();
      ctx.moveTo(toX(s.xs[0]), toY(0));
      for (let i = 0; i < s.xs.length; i++) ctx.lineTo(toX(s.xs[i]), toY(s.ys[i]));
      ctx.lineTo(toX(s.xs[s.xs.length - 1]), toY(0));
      ctx.closePath();
      ctx.fill();
    }

    if (s.line === false) {
      ctx.restore();
      return;
    }

    ctx.strokeStyle = s.color;
    ctx.lineWidth = 2.5 * this.dpr;
    ctx.setLineDash((s.dash || []).map((d) => d * this.dpr));
    ctx.beginPath();
    for (let i = 0; i < s.xs.length; i++) {
      const x = toX(s.xs[i]);
      const y = toY(s.ys[i]);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.stroke();

    ctx.restore();
  }

  _drawLegend() {
    const ctx = this.ctx;
    const pr = this._plotRect();
    const d = this.dpr;
    const rowH = 20 * d;
    const swatch = 26 * d;

    ctx.save();
    ctx.font = font(13, d);
    ctx.textBaseline = "middle";
    ctx.textAlign = "left";

    const labels = this.series.filter((s) => s.label);
    const textW = Math.max(0, ...labels.map((s) => ctx.measureText(s.label).width));
    const boxW = swatch + 8 * d + textW + 16 * d;
    const boxH = labels.length * rowH + 8 * d;
    const bx = pr.x + pr.w - boxW - 8 * d;
    const by = pr.y + 8 * d;

    ctx.fillStyle = "rgba(255,255,255,0.9)";
    ctx.fillRect(bx, by, boxW, boxH);

    labels.forEach((s, i) => {
      const cy = by + 4 * d + rowH * (i + 0.5);
      ctx.strokeStyle = s.color;
      ctx.lineWidth = 2.5 * d;
      ctx.setLineDash((s.dash || []).map((v) => v * d));
      ctx.beginPath();
      ctx.moveTo(bx + 8 * d, cy);
      ctx.lineTo(bx + 8 * d + swatch, cy);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.fillStyle = brand("ink");
      ctx.fillText(s.label, bx + 16 * d + swatch, cy);
    });

    ctx.restore();
  }
}
