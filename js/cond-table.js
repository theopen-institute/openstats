// Week 1, "Direction of conditions": an editable 2×2 table (field of study by
// urban/rural) that keeps the totals and P(A|B) vs P(B|A) up to date.
(() => {
  const $ = (id) => document.getElementById(id);
  const cells = ['cond-us', 'cond-ue', 'cond-rs', 'cond-re'].map($);
  const fmt = (n) => n.toLocaleString();
  const ratio = (num, den) =>
    `${fmt(num)} / ${fmt(den)} = ${den > 0 ? (num / den).toFixed(2) : '—'}`;

  function update() {
    const [us, ue, rs, re] = cells.map((el) => Math.max(0, Number(el.value) || 0));
    $('cond-urban').textContent = fmt(us + ue);
    $('cond-rural').textContent = fmt(rs + re);
    $('cond-soc').textContent = fmt(us + rs);
    $('cond-econ').textContent = fmt(ue + re);
    $('cond-all').textContent = fmt(us + ue + rs + re);
    $('cond-p1').textContent = ratio(rs, rs + re);
    $('cond-p2').textContent = ratio(rs, us + rs);
  }

  cells.forEach((el) => el.addEventListener('input', update));
  $('cond-reset').addEventListener('click', () => {
    cells.forEach((el) => (el.value = el.dataset.default));
    update();
  });
  update();
})();
