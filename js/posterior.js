// js/posterior.js
// Read-only canvas plot of one or more curves over x in [0, 1], used to show
// prior, likelihood and posterior together. Styled to match LineGraphWidget.
export class PosteriorPlot {
  constructor({ container, xLabel = "Percent of Voters" } = {}) {
    if (!container) throw new Error("PosteriorPlot: container is required");
    this.container = container;
    this.xLabel = xLabel;
    this.series = [];

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
  }

  destroy() {
    window.removeEventListener("resize", this._onResize);
    this._resizeObserver.disconnect();
    this.canvas.remove();
  }

  // series: [{ label, color, xs, ys, dash?: number[], fill?: string }]
  setSeries(series) {
    this.series = Array.isArray(series) ? series : [];
    this._draw();
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

  _draw() {
    if (!this.dpr) return;
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    this._drawAxesAndGrid();
    const yMax = this._yMax();
    for (const s of this.series) this._drawSeries(s, yMax);
    this._drawLegend();
  }

  _drawAxesAndGrid() {
    const ctx = this.ctx;
    const pr = this._plotRect();
    const tickLen = 6 * this.dpr;

    ctx.save();

    ctx.strokeStyle = "#e6e6e6";
    ctx.lineWidth = 1 * this.dpr;
    for (let x = 0; x <= 1 + 1e-9; x += 0.1) {
      const cx = pr.x + x * pr.w;
      ctx.beginPath();
      ctx.moveTo(cx, pr.y);
      ctx.lineTo(cx, pr.y + pr.h);
      ctx.stroke();
    }

    // 50% line: the threshold for winning
    ctx.strokeStyle = "#999999";
    ctx.setLineDash([4 * this.dpr, 4 * this.dpr]);
    ctx.beginPath();
    ctx.moveTo(pr.x + 0.5 * pr.w, pr.y);
    ctx.lineTo(pr.x + 0.5 * pr.w, pr.y + pr.h);
    ctx.stroke();
    ctx.setLineDash([]);

    ctx.strokeStyle = "#333333";
    ctx.lineWidth = 1.5 * this.dpr;
    ctx.beginPath();
    ctx.moveTo(pr.x, pr.y);
    ctx.lineTo(pr.x, pr.y + pr.h);
    ctx.lineTo(pr.x + pr.w, pr.y + pr.h);
    ctx.stroke();

    ctx.fillStyle = "#333333";
    ctx.font = `${12 * this.dpr}px system-ui, -apple-system, Segoe UI, Roboto, Arial`;
    ctx.textAlign = "center";
    ctx.textBaseline = "top";
    for (let x = 0; x <= 1 + 1e-9; x += 0.1) {
      const cx = pr.x + x * pr.w;
      ctx.beginPath();
      ctx.moveTo(cx, pr.y + pr.h);
      ctx.lineTo(cx, pr.y + pr.h + tickLen);
      ctx.stroke();
      ctx.fillText(`${Math.round(x * 100)}`, cx, pr.y + pr.h + tickLen + 4 * this.dpr);
    }
    ctx.fillText(this.xLabel, pr.x + pr.w / 2, pr.y + pr.h + tickLen + 20 * this.dpr);

    // Y axis is relative plausibility; absolute values aren't meaningful here
    ctx.save();
    ctx.translate(pr.x - 8 * this.dpr, pr.y + pr.h / 2);
    ctx.rotate(-Math.PI / 2);
    ctx.textBaseline = "bottom";
    ctx.fillText("Plausibility", 0, 0);
    ctx.restore();

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
    ctx.font = `${13 * d}px system-ui, -apple-system, Segoe UI, Roboto, Arial`;
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
      ctx.fillStyle = "#333333";
      ctx.fillText(s.label, bx + 16 * d + swatch, cy);
    });

    ctx.restore();
  }
}
