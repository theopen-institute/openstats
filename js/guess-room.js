// Week 2, "Ask the room": the bridge from "How old is he?" (how sure one person is) to
// the Galton board (how random things add up). A simulated room of people each guess
// the man's age: every guess is one person's belief, and they scatter (top row, blue
// balls). The room's average drops into the bottom row as a green ball. Ask room after
// room, and the averages pile up close together, in a bell: how sure that many guesses
// can make us. Fewer people per room, a wider pile; one per room, as wide as single
// guesses.
// The guessers are made up: each guess is his age in the simulation (AGE) plus a
// random error, Normal with SD GUESS_SD, rounded to a whole year.
// Markup in _includes/week2/guess-room.md, styles in css/deck.scss (.guess-room, .w2-*).
import { brand, withAlpha } from './palette.js';
import { Canvas, dot, line, text, ticks, scale, xAxis } from './canvas-plot.js';
import { DURATION } from './tween.js';

const AGE = 42; // his age, in the simulation
const GUESS_SD = 8;
const RANGE = [15, 75]; // the ages shown, in whole-year bins
const STAGGER_MS = 45; // between one guess and the next
const FALL_MS = 420; // a ball's fall into its row
const MANY = 50; // rooms per click of "Ask 50 rooms"

const root = document.querySelector('.guess-room');
if (root) init(root);

// A Normal draw (Box–Muller)
function normal(mean, sd) {
  const u = 1 - Math.random();
  const v = Math.random();
  return mean + sd * Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v);
}

const guess = () => Math.round(Math.max(RANGE[0], Math.min(RANGE[1] - 1, normal(AGE, GUESS_SD))));
const avg = (xs) => xs.reduce((a, b) => a + b, 0) / xs.length;
const bin = (age) => Math.max(RANGE[0], Math.min(RANGE[1] - 1, Math.round(age)));

function init(root) {
  const $ = (sel) => root.querySelector(sel);
  let size = 20; // people per room
  let room = []; // this room's guesses: { age, start }
  let averages = []; // every room's average: { age, start }
  let frame = null;

  const canvas = new Canvas($('.w2-graph'), draw);
  const now = () => performance.now();
  // A ball's progress through its fall (0 to 1), eased to land softly
  const fallen = (start) => {
    if (!DURATION) return 1;
    const t = Math.max(0, Math.min(1, (now() - start) / FALL_MS));
    return 1 - (1 - t) ** 2;
  };

  function askRoom() {
    const t0 = now();
    room = Array.from({ length: size }, (_, i) => ({ age: guess(), start: t0 + i * STAGGER_MS }));
    const done = t0 + size * STAGGER_MS + FALL_MS;
    averages.push({ age: avg(room.map((g) => g.age)), start: done });
    run();
  }

  function askMany() {
    const t0 = now();
    for (let r = 0; r < MANY; r++) {
      const guesses = Array.from({ length: size }, guess);
      if (r === MANY - 1) room = guesses.map((age) => ({ age, start: t0 }));
      averages.push({ age: avg(guesses), start: t0 + r * 25 });
    }
    run();
  }

  function startOver() {
    room = [];
    averages = [];
    update();
  }

  function update() {
    $('.guess-rooms').textContent = averages.length.toLocaleString();
    root.querySelectorAll('[data-size]').forEach((b) => b.classList.toggle('is-on', Number(b.dataset.size) === size));
    canvas.render();
  }

  // Animate until every ball has landed
  function run() {
    update();
    if (frame) return;
    const tick = () => {
      canvas.render();
      const last = Math.max(0, ...room.map((g) => g.start), ...averages.map((a) => a.start));
      frame = now() < last + FALL_MS ? requestAnimationFrame(tick) : null;
    };
    frame = requestAnimationFrame(tick);
  }

  function draw(ctx, w, h) {
    const ink = brand('ink');
    const blue = brand('blue');
    const green = brand('green');
    const pad = { left: 24, right: 24, top: 8, bottom: 70 };
    const x = scale(RANGE[0], RANGE[1], pad.left, w - pad.right);
    const binW = x(RANGE[0] + 1) - x(RANGE[0]);
    const gap = 30;
    const rowH = (h - pad.top - pad.bottom - gap) / 2;
    const rows = [
      { top: pad.top, base: pad.top + rowH },
      { top: pad.top + rowH + gap, base: pad.top + 2 * rowH + gap },
    ];
    const headH = 40; // each row's title

    // Balls stacked in their year's column, shrinking (down to a point) when a column
    // gets too tall for the row
    const pile = (balls, row, color) => {
      const stacks = new Map();
      const placed = balls.map((b) => {
        const k = stacks.get(bin(b.age)) ?? 0;
        stacks.set(bin(b.age), k + 1);
        return { ...b, k };
      });
      const tallest = Math.max(1, ...stacks.values());
      const space = row.base - row.top - headH;
      const step = Math.min(binW * 0.9, space / tallest);
      const r = Math.max(1.5, step / 2 - 0.5);
      for (const b of placed) {
        const p = fallen(b.start);
        if (b.start > now() && DURATION) continue;
        const cx = x(bin(b.age)) + binW / 2;
        const rest = row.base - step * (b.k + 0.5);
        const cy = row.top + headH / 2 + (rest - row.top - headH / 2) * p;
        dot(ctx, cx, cy, r, withAlpha(color, p < 1 ? 0.6 : 0.9));
      }
    };

    // His age, in the simulation, through both rows
    if ($('.guess-truth').checked) {
      const at = x(AGE) + binW / 2;
      line(ctx, at, rows[0].top + headH - 6, at, rows[1].base, { color: ink, width: 2, dash: [8, 6] });
      text(ctx, `his age (in this simulation): ${AGE}`, at + 10, rows[1].top + headH - 10, {
        size: 15, color: ink, halo: true,
      });
    }

    // Top: this room's guesses, and their average
    text(ctx, room.length ? `One room: ${room.length} ${room.length === 1 ? 'guess' : 'guesses'}` : 'One room’s guesses', pad.left, rows[0].top + 22, {
      size: 18, weight: 700, color: blue,
    });
    pile(room, rows[0], blue);
    const roomDone = room.length && room.every((g) => fallen(g.start) >= 1);
    if (roomDone && size > 1) {
      const m = avg(room.map((g) => g.age));
      line(ctx, x(m) + binW / 2, rows[0].top + headH, x(m) + binW / 2, rows[0].base, { color: green, width: 3 });
      text(ctx, 'their average', x(m) + binW / 2 + 8, rows[0].top + headH + 6, {
        size: 15, weight: 600, color: green, baseline: 'top', halo: true,
      });
    }
    line(ctx, pad.left, rows[0].base, w - pad.right, rows[0].base, { color: ink });

    // Bottom: every room's average
    text(ctx, size === 1 ? 'Each room’s guess (one person per room)' : 'Each room’s average', pad.left, rows[1].top + 22, {
      size: 18, weight: 700, color: green,
    });
    pile(averages, rows[1], green);
    xAxis(ctx, (v) => x(v) + binW / 2, rows[1].base, ticks(20, 70, 10), { title: 'Age (years)' });
  }

  $('.guess-ask').addEventListener('click', askRoom);
  $('.guess-many').addEventListener('click', askMany);
  $('.guess-reset').addEventListener('click', startOver);
  $('.guess-truth').addEventListener('change', () => canvas.render());
  root.querySelectorAll('[data-size]').forEach((b) => b.addEventListener('click', () => {
    size = Number(b.dataset.size);
    startOver();
  }));
  update();
}
