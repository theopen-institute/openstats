// Week 1, "Direction of conditions": an editable 2×2 table (July or not, by
// rain or not) that keeps the totals and P(A|B) vs P(B|A) up to date.
(() => {
  const $ = (id) => document.getElementById(id);
  const cells = ['cond-jr', 'cond-jd', 'cond-or', 'cond-od'].map($);
  const fmt = (n) => n.toLocaleString();
  const ratio = (num, den) =>
    `${fmt(num)} ÷ ${fmt(den)} = ${den > 0 ? (num / den).toFixed(2) : '—'}`;

  function update() {
    const [jr, jd, or, od] = cells.map((el) => Math.max(0, Number(el.value) || 0));
    $('cond-july').textContent = fmt(jr + jd);
    $('cond-other').textContent = fmt(or + od);
    $('cond-rain').textContent = fmt(jr + or);
    $('cond-dry').textContent = fmt(jd + od);
    $('cond-all').textContent = fmt(jr + jd + or + od);
    $('cond-p1').textContent = ratio(jr, jr + jd);
    $('cond-p2').textContent = ratio(jr, jr + or);
  }

  cells.forEach((el) => el.addEventListener('input', update));
  $('cond-reset').addEventListener('click', () => {
    cells.forEach((el) => (el.value = el.dataset.default));
    update();
  });
  update();
})();
