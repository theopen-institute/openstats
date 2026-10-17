// The course palette for scripts, read from the CSS variables that css/deck.scss
// defines (--brand-blue, --brand-red, ...), so canvas drawings match the theme.
export function brand(name) {
  return getComputedStyle(document.documentElement)
    .getPropertyValue(`--brand-${name}`)
    .trim();
}

// "#rrggbb" plus an alpha (0-1) as an rgba() string, e.g. for translucent fills
export function withAlpha(hex, alpha) {
  const n = parseInt(hex.slice(1), 16);
  return `rgba(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}, ${alpha})`;
}
