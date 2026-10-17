// Week 1, "Probability lets us ask questions": a live hand count. Type the number of
// people in the room and hands up; draws one dot per person and fills every
// .count-k-out / .count-n-out span on the page with the current counts.
(() => {
  const $ = (id) => document.getElementById(id);
  const nIn = $('count-n');
  const kIn = $('count-k');

  function update() {
    const n = Math.min(200, Math.max(0, Math.round(Number(nIn.value) || 0)));
    const k = Math.min(n, Math.max(0, Math.round(Number(kIn.value) || 0)));
    $('count-dots').innerHTML = Array.from({ length: n }, (_, i) =>
      `<span class="${i < k ? 'on' : ''}"></span>`
    ).join('');
    $('count-result').innerHTML = n > 0
      ? `<span class="blue">${k} out of ${n}</span> had tea this morning.`
      : '';
    document.querySelectorAll('.count-k-out').forEach((el) => (el.textContent = k));
    document.querySelectorAll('.count-n-out').forEach((el) => (el.textContent = n));
  }

  [nIn, kIn].forEach((el) => el.addEventListener('input', update));
  update();
  // the count-k-out / count-n-out spans come after this script, so fill them
  // again once the whole page has loaded
  document.addEventListener('DOMContentLoaded', update);
})();
