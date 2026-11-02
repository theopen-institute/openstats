// Week 2, "Random individuals, predictable crowds": a Galton board. At every row of
// pegs a ball bounces left or right, a coin flip, and it lands in the bin for its
// number of bounces to the right. Nobody can say where one ball will land; a thousand
// pile up into the same bell every time. "Count the paths" adds the shape Week 1's
// counting predicts: the number of paths to each bin (1, 4, 6, 4, 1 for four rows),
// scaled to the balls dropped.
// Markup in _includes/week2/galton.md, styles in css/deck.scss (.w2-*).
import { brand, withAlpha } from './palette.js';
import { Canvas, dot, line, text } from './canvas-plot.js';
import { DURATION } from './tween.js';

const ROW_MS = 120; // how long a ball takes to fall one row
const FALL_MS = 300; // and to fall from rest from the pegs to the bottom of an empty bin
const MAX_IN_FLIGHT = 400;

const root = document.querySelector('.galton');
if (root) init(root);

function choose(n, k) {
  let c = 1;
  for (let i = 1; i <= k; i++) c = (c * (n - k + i)) / i;
  return c;
}

function init(root) {
  const $ = (sel) => root.querySelector(sel);
  const rowsIn = $('.galton-rows');
  const pathsIn = $('.galton-paths');

  let rows = 0;
  let counts = [];
  let balls = []; // in flight: { path: [0 | 1, ...], start }
  let queue = []; // start times of balls waiting to drop
  let landed = 0;
  let frame = null;

  const canvas = new Canvas($('.w2-graph'), draw);

  function reset() {
    rows = Number(rowsIn.value);
    counts = new Array(rows + 1).fill(0);
    balls = [];
    queue = [];
    landed = 0;
    $('.galton-rows-out').textContent = rows;
    readout();
    canvas.render();
  }

  function readout() {
    $('.galton-n').textContent = landed.toLocaleString('en-US');
  }

  const randomPath = () => Array.from({ length: rows }, () => (Math.random() < 0.5 ? 0 : 1));
  const binOf = (path) => path.reduce((a, b) => a + b, 0);

  function drop(n) {
    if (!DURATION) { // reduced motion: straight into the bins
      for (let i = 0; i < n; i++) counts[binOf(randomPath())]++;
      landed += n;
      readout();
      canvas.render();
      return;
    }
    const now = performance.now();
    const gap = n === 1 ? 0 : Math.min(150, 3500 / n); // a thousand take about 3.5 s
    const from = Math.max(now, queue[queue.length - 1] ?? now);
    for (let i = 0; i < n; i++) queue.push(from + i * gap);
    if (!frame) frame = requestAnimationFrame(tick);
  }

  function tick(now) {
    while (queue.length && queue[0] <= now && balls.length < MAX_IN_FLIGHT) {
      balls.push({ path: randomPath(), start: queue.shift() });
    }
    // A ball counts once it lands on its bin's bar (on a hidden slide, once it's
    // through the pegs)
    const L = canvas.k ? layout(canvas.width, canvas.height) : null;
    const hops = (rows + 1) * ROW_MS;
    balls = balls.filter((b) => {
      const t = now - b.start;
      if (t < hops) return true;
      if (L && !fallAt(L, b, t - hops).landed) return true;
      counts[binOf(b.path)]++;
      landed++;
      return false;
    });
    readout();
    canvas.render();
    frame = balls.length || queue.length ? requestAnimationFrame(tick) : null;
  }

  // Where things go, for the canvas size: pegs in a triangle, bins underneath
  function layout(w, h) {
    const boardTop = 24;
    const boardH = h * 0.46;
    const binsTop = boardTop + boardH + 10;
    const binsBottom = h - (rows <= 6 ? 84 : 58);
    const dy = boardH / (rows + 0.5);
    const dx = Math.min((w - 40) / (rows + 1), dy * 2.4, 120);
    const ballR = Math.max(3, Math.min(9, dx * 0.13));
    return { cx: w / 2, dx, dy, boardTop, binsTop, binsBottom, ballR };
  }

  // The bars' scale: the tallest count (or path count, when shown) reaches 89% of the
  // bins' height
  function expectedCounts() {
    return counts.map((_, k) => (landed * choose(rows, k)) / 2 ** rows);
  }
  function barScale(L) {
    const top = Math.max(8, ...counts, ...(pathsIn.checked ? expectedCounts() : [])) * 1.12;
    return (c) => (c / top) * (L.binsBottom - L.binsTop);
  }

  const peg = (L, i, j) => ({ x: L.cx + (j - i / 2) * L.dx, y: L.boardTop + (i + 0.5) * L.dy });
  const binX = (L, k) => L.cx + (k - rows / 2) * L.dx;

  // A ball's position `t` ms after it dropped: down onto the top peg, then a hop to
  // the left or right at each row, off the last row, and a fall into its bin
  function ballAt(L, b, t) {
    const hops = (rows + 1) * ROW_MS;
    if (t >= hops) return fallAt(L, b, t - hops);
    const r = L.ballR;
    const s = t / ROW_MS;
    const seg = Math.min(rows, Math.floor(s));
    const f = Math.min(1, s - seg);
    let right = 0;
    for (let i = 0; i < seg - 1; i++) right += b.path[i];
    const lift = r + Math.max(2.5, L.dx * 0.05); // sitting on top of the peg
    if (seg === 0) {
      const to = peg(L, 0, 0);
      return { x: to.x, y: L.boardTop - L.dy * 0.6 + (to.y - lift - (L.boardTop - L.dy * 0.6)) * f };
    }
    const from = peg(L, seg - 1, right);
    const nextRight = right + b.path[seg - 1];
    const to = seg < rows
      ? peg(L, seg, nextRight)
      : { x: binX(L, nextRight), y: L.binsTop + lift };
    return {
      x: from.x + (to.x - from.x) * f,
      y: from.y - lift + (to.y - from.y) * f - L.dy * 0.45 * Math.sin(Math.PI * f),
    };
  }

  // The fall into the bin, `t` ms after leaving the last row: straight down under
  // gravity, starting at the speed it came down through the pegs (a row per ROW_MS),
  // until it lands on top of its bin's bar ({ landed: true })
  function fallAt(L, b, t) {
    const k = binOf(b.path);
    const speed = L.dy / ROW_MS; // px per ms
    const g = (2 * (L.binsBottom - L.binsTop)) / FALL_MS ** 2;
    const floor = L.binsBottom - barScale(L)(counts[k]) - L.ballR;
    const y = L.binsTop + speed * t + 0.5 * g * t * t; // the last hop ends at binsTop
    return { x: binX(L, k), y: Math.min(y, floor), landed: y >= floor };
  }

  function draw(ctx, w, h) {
    const L = layout(w, h);
    const ink = brand('ink');
    const blue = brand('blue');
    const gray = brand('gray');
    const showPaths = pathsIn.checked;
    const expected = expectedCounts();
    const barH = barScale(L);

    // Pegs
    for (let i = 0; i < rows; i++) {
      for (let j = 0; j <= i; j++) {
        const p = peg(L, i, j);
        dot(ctx, p.x, p.y, Math.max(2.5, L.dx * 0.05), withAlpha(ink, 0.45));
      }
    }

    // Balls in flight
    const now = performance.now();
    for (const b of balls) {
      const p = ballAt(L, b, now - b.start);
      dot(ctx, p.x, p.y, L.ballR, brand('red'));
    }

    // Bins: a bar per bin, with its count
    for (let k = 0; k <= rows; k++) {
      const x = binX(L, k);
      const bw = L.dx * 0.82;
      const bh = barH(counts[k]);
      ctx.fillStyle = blue;
      ctx.fillRect(x - bw / 2, L.binsBottom - bh, bw, bh);
      // Its count: inside the top of the bar, where landing balls don't cover it, or
      // above a bar too short to hold it
      if (rows <= 10 && counts[k] > 0) {
        const inside = bh > 26;
        text(ctx, counts[k].toLocaleString('en-US'), x, L.binsBottom - bh + (inside ? 6 : -6), {
          size: 15, align: 'center', color: inside ? 'white' : ink, baseline: inside ? 'top' : 'alphabetic',
        });
      }
      if (showPaths && landed > 0) {
        const eh = barH(expected[k]);
        ctx.save();
        ctx.strokeStyle = ink;
        ctx.lineWidth = 2;
        ctx.setLineDash([6, 4]);
        ctx.strokeRect(x - bw / 2, L.binsBottom - eh, bw, eh);
        ctx.restore();
      }
      if (L.dx >= 26) {
        text(ctx, String(k), x, L.binsBottom + 8, { size: 16, align: 'center', baseline: 'top' });
      }
      if (showPaths && rows <= 6) {
        const ways = choose(rows, k);
        text(ctx, `${ways} ${ways === 1 ? 'path' : 'paths'}`, x, L.binsBottom + 32, {
          size: 15, align: 'center', baseline: 'top', color: gray,
        });
      }
    }
    line(ctx, binX(L, 0) - L.dx / 2, L.binsBottom, binX(L, rows) + L.dx / 2, L.binsBottom, { color: ink });
    text(ctx, 'Bounces to the right', w / 2, h - 4, { size: 16, align: 'center', color: gray });

  }

  rowsIn.addEventListener('input', reset);
  pathsIn.addEventListener('change', () => canvas.render());
  for (const btn of root.querySelectorAll('[data-drop]')) {
    btn.addEventListener('click', () => drop(Number(btn.dataset.drop)));
  }
  $('.galton-reset').addEventListener('click', reset);
  reset();
}
