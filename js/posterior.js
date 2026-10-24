import { brand } from './palette.js';
import { clearCanvas, drawPercentAxes, drawYLabel, font } from './canvas-axes.js';
import { animate, onArrival, onCurrentSlide } from './tween.js';

// Read-only canvas plot of one or more curves over x in [0, 1], used to show
// prior, likelihood and posterior together. Styled to match LineGraphWidget.
//
// Each curve is scaled to its own peak, so they all reach the same height and only
// their shapes compare: a prior keeps its shape however tall or flat the posterior
// next to it gets. (Their heights aren't comparable across curves, and the y axis says
// so.) A series can give `peak` to be scaled by something else, e.g. a shaded part of
// another curve scaled like the whole curve.
//
// Changes are animated. Each time its slide is activated, a plot starts with the curves
// students already saw on an earlier slide (marked `grow: false`) in place, drawn the
// moment the slide starts coming in, and grows the new curves from zero once the slide
// has landed. Changes made on the slide itself (a slider, say) ease each curve from
// what's on screen to its new shape.
const Y_MAX = 1.08; // every curve peaks at 1, a little below the top

export class PosteriorPlot {
  constructor({
    container, xLabel = "Percent of Voters",
    yLabel = "Relative plausibility (each curve scaled to its peak)",
  } = {}) {
    if (!container) throw new Error("PosteriorPlot: container is required");
    this.container = container;
    this.xLabel = xLabel;
    this.yLabel = yLabel;
    this.series = []; // the curves to show
    this._shown = null; // the curves on screen now, partway through a transition
    this._arriving = false; // between the slide starting to come in and landing
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
    onArrival(container, {
      // familiar curves in place, new ones flat, before the slide slides in
      starting: () => {
        this._arriving = true;
        this._showStart();
      },
      // then grow the new ones
      arrived: () => {
        this._arriving = false;
        this._transition();
      },
    });
  }

  destroy() {
    window.removeEventListener("resize", this._onResize);
    this._resizeObserver.disconnect();
    this.canvas.remove();
  }

  // series: [{ label, color, xs, ys, dash?: number[], fill?: string, line?: false,
  //   peak?: number, grow?: false }]
  // (line: false draws only the fill, e.g. to shade part of another curve; peak is what
  // to scale the curve by, its own highest value unless given)
  setSeries(series) {
    this.series = Array.isArray(series) ? series : [];
    if (onCurrentSlide(this.container) && !this._arriving) this._transition();
    else this._showStart(); // ready for the next time the slide comes in
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

  // A curve's heights as a share of its peak (0 to 1)
  static _scaled(s) {
    const ys = s.ys.map((y) => (Number.isFinite(y) ? y : 0));
    const peak = s.peak ?? Math.max(0, ...ys);
    return peak > 0 ? ys.map((y) => y / peak) : ys.map(() => 0);
  }

  // Where a plot starts each time its slide comes in: curves with grow: false at their
  // final shape, the others flat
  _showStart() {
    this._cancel();
    this._shown = this.series.map((s) => {
      const ys = PosteriorPlot._scaled(s);
      return { ...s, ys: s.grow === false ? ys : ys.map(() => 0) };
    });
    this._draw();
  }

  // Ease from the curves on screen to this.series. A curve matches the one in the same
  // position; a new one grows from zero, or with grow: false starts where it ends.
  _transition() {
    this._cancel();
    const to = this.series.map((s) => ({ ...s, ys: PosteriorPlot._scaled(s) }));
    const from = to.map((s, i) => {
      const prev = this._shown?.[i]?.ys;
      if (prev && prev.length === s.ys.length) return prev;
      return s.grow === false ? s.ys : s.ys.map(() => 0);
    });
    this._cancel = animate((e) => {
      this._shown = to.map((s, i) => ({
        ...s,
        ys: s.ys.map((y, j) => from[i][j] + (y - from[i][j]) * e),
      }));
      this._draw();
    });
  }

  _draw() {
    if (!this.dpr) return;
    clearCanvas(this.canvas, this.ctx);
    this._drawAxesAndGrid();
    for (const s of this._shown ?? []) this._drawSeries(s, Y_MAX);
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
    ctx.restore();

    // Y axis is relative (plausibility or likelihood); absolute values aren't shown
    drawYLabel(ctx, pr, this.dpr, this.yLabel);
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
