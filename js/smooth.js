// A smooth curve through evenly spaced points: week 1's drawn prior, which is 21
// heights. Used both to draw it on Step 1 (graph.js) and to turn it into a distribution
// for the slides after (poll-math.js), so the two always match.
//
// A monotone cubic (Fritsch–Butland): it passes exactly through every point, bends
// smoothly between them instead of turning a corner at each one, and never overshoots,
// so it can't add a bump the points don't have or dip below zero between them.

// ys: the heights at x = 0, 1, ..., n - 1. Returns f(x) for x from 0 to n - 1.
export function smoothCurve(ys) {
  const n = ys.length;
  if (n < 2) return () => ys[0] ?? 0;
  const d = Array.from({ length: n - 1 }, (_, k) => ys[k + 1] - ys[k]); // secant slopes

  // Slope at each point: the harmonic mean of the slopes on either side, or flat at a
  // peak or trough (where they change sign). The ends follow their one neighbor.
  const m = ys.map((_, k) => {
    if (k === 0) return d[0];
    if (k === n - 1) return d[n - 2];
    return d[k - 1] * d[k] > 0 ? 2 / (1 / d[k - 1] + 1 / d[k]) : 0;
  });

  return (x) => {
    const k = Math.min(n - 2, Math.max(0, Math.floor(x)));
    const t = Math.min(1, Math.max(0, x - k));
    const t2 = t * t;
    const t3 = t2 * t;
    // cubic Hermite: matches each end's height and slope
    return (2 * t3 - 3 * t2 + 1) * ys[k] + (t3 - 2 * t2 + t) * m[k]
      + (-2 * t3 + 3 * t2) * ys[k + 1] + (t3 - t2) * m[k + 1];
  };
}
