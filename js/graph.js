// js/graph.js
export class LineGraphWidget {
  constructor({ container, yValues, onChange } = {}) {
    if (!container) throw new Error("LineGraphWidget: container is required");
    this.container = container;
    this.onChange = typeof onChange === "function" ? onChange : null;

    // Fixed x positions: 0..1 step 0.05 => 21 points
    this.step = 0.05;
    this.count = Math.round(1 / this.step) + 1; // 21

    this.yMin = 0;
    this.yMax = 100;

    this.padding = { left: 44, right: 16, top: 16, bottom: 34 };
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
      this.yValues[this._dragIndex] = clamped;
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

  _eventToCanvas(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left) * this.dpr;
    const y = (e.clientY - rect.top) * this.dpr;
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
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    this._drawAxesAndGrid();
    this._drawLineAndPoints();
  }

  _drawAxesAndGrid() {
    const ctx = this.ctx;
    const pr = this._plotRect();

    // Tick configuration
    const yTickStep = 10;
    const xTickStep = 0.1;
    const tickLen = 6 * this.dpr;

    const fmtX = (v) => (Math.round(v * 100) / 100).toString();
    const fmtY = (v) => String(v);

    ctx.save();

    // Grid (Y)
    ctx.strokeStyle = "#e6e6e6";
    ctx.lineWidth = 1 * this.dpr;
    for (let y = this.yMin; y <= this.yMax; y += yTickStep) {
      const cy = this._valueToCanvasY(y);
      ctx.beginPath();
      ctx.moveTo(pr.x, cy);
      ctx.lineTo(pr.x + pr.w, cy);
      ctx.stroke();
    }

    // Optional Grid (X)
    for (let x = 0; x <= 1 + 1e-9; x += xTickStep) {
      const cx = this._valueToCanvasX(x);
      ctx.beginPath();
      ctx.moveTo(cx, pr.y);
      ctx.lineTo(cx, pr.y + pr.h);
      ctx.stroke();
    }

    // Axes
    ctx.strokeStyle = "#333333";
    ctx.lineWidth = 1.5 * this.dpr;

    ctx.beginPath();
    ctx.moveTo(pr.x, pr.y);
    ctx.lineTo(pr.x, pr.y + pr.h);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(pr.x, pr.y + pr.h);
    ctx.lineTo(pr.x + pr.w, pr.y + pr.h);
    ctx.stroke();

    // Ticks + labels
    ctx.fillStyle = "#333333";
    ctx.font = `${12 * this.dpr}px system-ui, -apple-system, Segoe UI, Roboto, Arial`;

    // Y ticks + labels
    ctx.textAlign = "right";
    ctx.textBaseline = "middle";
    for (let y = this.yMin; y <= this.yMax; y += yTickStep) {
      const cy = this._valueToCanvasY(y);

      ctx.beginPath();
      ctx.moveTo(pr.x, cy);
      ctx.lineTo(pr.x - tickLen, cy);
      ctx.stroke();

      ctx.fillText(fmtY(y), pr.x - tickLen - 6 * this.dpr, cy);
    }

    // X ticks + labels
    ctx.textAlign = "center";
    ctx.textBaseline = "top";
    for (let x = 0; x <= 1 + 1e-9; x += xTickStep) {
      const cx = this._valueToCanvasX(x);

      ctx.beginPath();
      ctx.moveTo(cx, pr.y + pr.h);
      ctx.lineTo(cx, pr.y + pr.h + tickLen);
      ctx.stroke();

      ctx.fillText(fmtX(x), cx, pr.y + pr.h + tickLen + 4 * this.dpr);
    }

    ctx.restore();
  }

  _drawLineAndPoints() {
    const ctx = this.ctx;

    ctx.save();
    ctx.strokeStyle = "#1976d2";
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
      ctx.fillStyle = isActive ? "#ff7043" : "#ffffff";
      ctx.strokeStyle = "#1976d2";
      ctx.lineWidth = 2 * this.dpr;
      ctx.arc(x, y, this.pointRadius * this.dpr, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();
    }

    ctx.restore();

    this._applyNodeHoverHandlers();
  }

  _applyNodeHoverHandlers() {
    // find nodes by the class used when creating them (adjust selector if your nodes use a different class)
    const nodes = this.container.querySelectorAll('.lg-node, circle.node, .node');
    nodes.forEach((node) => {
      // ensure pointer cursor
      node.style.cursor = 'pointer';

      // store original attributes so we can restore them
      if (!node.dataset._origFill) {
        node.dataset._origFill = node.getAttribute('fill') || window.getComputedStyle(node).fill || '';
      }
      if (!node.dataset._origR) {
        node.dataset._origR = node.getAttribute('r') || node.style.r || '';
      }

      // choose hover color: prefer a dataset hint, otherwise a safe default
      const hoverColor = node.dataset.hoverFill || '#ff9800';

      // handlers (defined as named functions so removals avoid duplicates)
      function onEnter() {
        // enlarge slightly if it's a circle
        if (node.tagName && node.tagName.toLowerCase() === 'circle') {
          const r = parseFloat(node.getAttribute('r') || node.dataset._origR || 3);
          node.setAttribute('r', (r * 1.25).toString());
        }
        // set hover fill
        node.setAttribute('fill', hoverColor);
        node.classList && node.classList.add('lg-node--hover');
      }
      function onLeave() {
        if (node.tagName && node.tagName.toLowerCase() === 'circle') {
          if (node.dataset._origR) node.setAttribute('r', node.dataset._origR);
        }
        if (node.dataset._origFill) node.setAttribute('fill', node.dataset._origFill);
        node.classList && node.classList.remove('lg-node--hover');
      }

      // remove any previous handlers to avoid duplicates (safe no-op if they weren't attached)
      node.removeEventListener('mouseenter', onEnter);
      node.removeEventListener('mouseleave', onLeave);

      node.addEventListener('mouseenter', onEnter);
      node.addEventListener('mouseleave', onLeave);
    });
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