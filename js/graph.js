// Draggable line graph over x in [0, 1]: `count` evenly spaced points whose
// heights (0-100) the user drags. Used for the week 1 poll prior (poll-prior.js).
//
// `falloff` (in points) makes a drag pull the neighbors along, less and less with
// distance (a Gaussian: at distance d a neighbor moves by exp(-d^2 / (2 falloff^2)) of
// the dragged point's change), so a single drag keeps the curve smooth. 0 moves only
// the dragged point.
import { brand } from './palette.js';
import { clearCanvas, drawPercentAxes } from './canvas-axes.js';

export class LineGraphWidget {
  constructor({
    container, yValues, onChange, count = 21, xLabel = "Percent of Voters", falloff = 0,
  } = {}) {
    if (!container) throw new Error("LineGraphWidget: container is required");
    this.container = container;
    this.onChange = typeof onChange === "function" ? onChange : null;
    this.xLabel = xLabel;
    this.falloff = falloff;

    // Fixed x positions: count points from 0 to 1
    this.count = count;
    this.step = 1 / (count - 1);

    this.yMin = 0;
    this.yMax = 100;

    this.padding = { left: 44, right: 16, top: 16, bottom: 46 };
    this.pointRadius = 7; // slightly bigger for touch
    this.hitRadius = 18;  // touch-friendly hit area

    this.yValues = this._normalizeYValues(yValues);

    this.canvas = document.createElement("canvas");
    this.canvas.style.width = "100%";
    this.canvas.style.height = "100%";
    this.canvas.style.display = "block";
    this.canvas.style.touchAction = "none"; // critical for touch dragging
    container.appendChild(this.canvas);

    this.ctx = this.canvas.getContext("2d");

    this._dragIndex = null;
    this._hoverIndex = null;
    this._needsRedraw = true;

    // Only emit changes on pointer up/cancel
    this._changedDuringDrag = false;

    this._onPointerDown = this._onPointerDown.bind(this);
    this._onPointerMove = this._onPointerMove.bind(this);
    this._onPointerUp = this._onPointerUp.bind(this);
    this._onPointerLeave = this._onPointerLeave.bind(this);
    this._onResize = this._onResize.bind(this);
    this._raf = this._raf.bind(this);

    // Use { passive:false } so preventDefault is honored in more environments
    this.canvas.addEventListener("pointerdown", this._onPointerDown, { passive: false });

    // IMPORTANT: attach move/up to the canvas (not window) for Reveal/Quarto reliability
    this.canvas.addEventListener("pointermove", this._onPointerMove, { passive: false });
    this.canvas.addEventListener("pointerup", this._onPointerUp, { passive: false });
    this.canvas.addEventListener("pointercancel", this._onPointerUp, { passive: false });
    this.canvas.addEventListener("pointerleave", this._onPointerLeave, { passive: true });

    window.addEventListener("resize", this._onResize);

    // Container size can change without a window resize (e.g. flex siblings
    // filling in), so watch it directly to keep the bitmap in sync.
    this._resizeObserver = new ResizeObserver(this._onResize);
    this._resizeObserver.observe(container);

    this._resizeToContainer();
    requestAnimationFrame(this._raf);
  }

  destroy() {
    this.canvas.removeEventListener("pointerdown", this._onPointerDown);
    this.canvas.removeEventListener("pointermove", this._onPointerMove);
    this.canvas.removeEventListener("pointerup", this._onPointerUp);
    this.canvas.removeEventListener("pointercancel", this._onPointerUp);
    this.canvas.removeEventListener("pointerleave", this._onPointerLeave);
    window.removeEventListener("resize", this._onResize);
    this._resizeObserver.disconnect();
    this.canvas.remove();
  }

  setYValues(yValues) {
    this.yValues = this._normalizeYValues(yValues);
    this._invalidate();
    // programmatic changes should still notify immediately
    this._emitChange();
  }

  getYValues() {
    return this.yValues.slice();
  }

  getPoints() {
    return this.yValues.map((y, i) => ({
      x: +(i * this.step).toFixed(2),
      y: y,
    }));
  }

  // -------- internal --------

  _normalizeYValues(yValues) {
    const arr = Array.isArray(yValues) ? yValues.slice(0, this.count) : [];
    while (arr.length < this.count) arr.push(50);
    return arr.map((v) => this._clamp(Number(v) || 0, this.yMin, this.yMax));
  }

  _invalidate() {
    this._needsRedraw = true;
  }

  _emitChange() {
    if (this.onChange) this.onChange(this.getPoints());
  }

  _onResize() {
    this._resizeToContainer();
    this._invalidate();
  }

  _resizeToContainer() {
    const rect = this.container.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;

    const cssW = Math.max(1, rect.width);
    const cssH = Math.max(1, rect.height);

    this.canvas.width = Math.round(cssW * dpr);
    this.canvas.height = Math.round(cssH * dpr);
    this.dpr = dpr;

    this._invalidate();
  }

  _raf() {
    if (this._needsRedraw) {
      this._draw();
      this._needsRedraw = false;
    }
    requestAnimationFrame(this._raf);
  }

  _onPointerDown(e) {
    const p = this._eventToCanvas(e);
    const idx = this._hitTestPoint(p.x, p.y);
    if (idx != null) {
      this._dragIndex = idx;
      this._dragStart = this.yValues.slice(); // neighbors move relative to these
      this._changedDuringDrag = false;

      // Capture pointer so dragging continues even if pointer leaves canvas
      this.canvas.setPointerCapture?.(e.pointerId);

      e.preventDefault();
    }
  }

  _onPointerMove(e) {
    const p = this._eventToCanvas(e);
    const hitIndex = this._hitTestPoint(p.x, p.y);

    if (this._dragIndex == null) {
      if (hitIndex !== this._hoverIndex) {
        this._hoverIndex = hitIndex;
        this.canvas.style.cursor = hitIndex == null ? "default" : "pointer";
        this._invalidate();
      }
      return;
    }

    const yVal = this._canvasYToValue(p.y);
    const clamped = this._clamp(yVal, this.yMin, this.yMax);

    if (clamped !== this.yValues[this._dragIndex]) {
      this._dragTo(clamped);
      this._changedDuringDrag = true;
      this._invalidate(); // redraw live, but do not emit yet
    }

    e.preventDefault();
  }

  _onPointerUp(e) {
    if (this._dragIndex != null) {
      const shouldEmit = this._changedDuringDrag;
      this._dragIndex = null;
      this._changedDuringDrag = false;

      this._invalidate();

      // Emit only on release/cancel, and only if something changed
      if (shouldEmit) this._emitChange();

      e.preventDefault();
    }
  }

  // Move the dragged point to `value`, and its neighbors by a share of the same change
  _dragTo(value) {
    const i = this._dragIndex;
    const start = this._dragStart;
    const delta = value - start[i];
    const f = this.falloff;
    for (let j = 0; j < this.count; j++) {
      const d = j - i;
      const weight = j === i ? 1 : f > 0 ? Math.exp(-(d * d) / (2 * f * f)) : 0;
      if (weight < 0.01) continue; // too far out to matter
      this.yValues[j] = this._clamp(start[j] + delta * weight, this.yMin, this.yMax);
    }
  }

  _eventToCanvas(e) {
    // Map via the actual bitmap/display ratio rather than dpr, so this stays
    // correct under Reveal's slide scaling or any CSS stretching.
    const rect = this.canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left) * (this.canvas.width / rect.width);
    const y = (e.clientY - rect.top) * (this.canvas.height / rect.height);
    return { x, y };
  }

  _plotRect() {
    const w = this.canvas.width;
    const h = this.canvas.height;
    const { left, right, top, bottom } = this.padding;
    return {
      x: left * this.dpr,
      y: top * this.dpr,
      w: Math.max(1, w - (left + right) * this.dpr),
      h: Math.max(1, h - (top + bottom) * this.dpr),
    };
  }

  _valueToCanvasX(xVal) {
    const pr = this._plotRect();
    return pr.x + (xVal / 1) * pr.w;
  }

  _valueToCanvasY(yVal) {
    const pr = this._plotRect();
    const t = (yVal - this.yMin) / (this.yMax - this.yMin);
    return pr.y + (1 - t) * pr.h;
  }

  _canvasYToValue(yCanvas) {
    const pr = this._plotRect();
    const t = 1 - (yCanvas - pr.y) / pr.h;
    return this.yMin + t * (this.yMax - this.yMin);
  }

  _hitTestPoint(cx, cy) {
    const r2 = (this.hitRadius * this.dpr) ** 2;
    for (let i = 0; i < this.count; i++) {
      const xVal = i * this.step;
      const px = this._valueToCanvasX(xVal);
      const py = this._valueToCanvasY(this.yValues[i]);
      const dx = cx - px;
      const dy = cy - py;
      if (dx * dx + dy * dy <= r2) return i;
    }
    return null;
  }

  _draw() {
    clearCanvas(this.canvas, this.ctx);
    const yTicks = [];
    for (let y = this.yMin; y <= this.yMax; y += 10) yTicks.push(y);
    drawPercentAxes(this.ctx, this._plotRect(), this.dpr, {
      xLabel: this.xLabel,
      yTicks,
      yToCanvas: (y) => this._valueToCanvasY(y),
    });
    this._drawLineAndPoints();
  }

  _drawLineAndPoints() {
    const ctx = this.ctx;

    ctx.save();
    ctx.strokeStyle = brand("blue");
    ctx.lineWidth = 2 * this.dpr;

    ctx.beginPath();
    for (let i = 0; i < this.count; i++) {
      const xVal = i * this.step;
      const x = this._valueToCanvasX(xVal);
      const y = this._valueToCanvasY(this.yValues[i]);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.stroke();

    for (let i = 0; i < this.count; i++) {
      const xVal = i * this.step;
      const x = this._valueToCanvasX(xVal);
      const y = this._valueToCanvasY(this.yValues[i]);

      ctx.beginPath();
      const isActive = i === this._dragIndex || i === this._hoverIndex;
      ctx.fillStyle = isActive ? brand("red") : "#ffffff";
      ctx.strokeStyle = brand("blue");
      ctx.lineWidth = 2 * this.dpr;
      ctx.arc(x, y, this.pointRadius * this.dpr, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();
    }

    ctx.restore();
  }

  _clamp(v, lo, hi) {
    return Math.max(lo, Math.min(hi, v));
  }

  _onPointerLeave() {
    if (this._hoverIndex != null) {
      this._hoverIndex = null;
      this.canvas.style.cursor = "default";
      this._invalidate();
    }
  }
}