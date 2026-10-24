// Week 1, "Step 1: The prior": drag 21 points (or sketch the curve freehand) to draw a
// prior for θ, mirrored in a read-only jspreadsheet table. The
// prior is shared with the slides after it through js/poll-store.js.
import { LineGraphWidget } from './graph.js';
import { POINTS, STEP, flatPrior, loadPrior, savePrior } from './poll-store.js';
import { brand } from './palette.js';

const graphEl = document.getElementById('poll-prior-graph');
const sheetEl = document.getElementById('poll-prior-sheet');
const resetBtn = document.getElementById('poll-prior-reset');

// θ, the drawn score, and the score as a probability (normalized to sum to 1)
function pointsToTable(points) {
  const ys = points.map((p) => Number(p.y) || 0);
  const sum = ys.reduce((a, b) => a + b, 0);
  return ys.map((v, i) => [i * STEP, v, sum > 0 ? v / sum : 0]);
}

if (graphEl && sheetEl && !graphEl.dataset.initialized) {
  graphEl.dataset.initialized = 'true';

  let widget = null;
  let sheet = null; // the jspreadsheet worksheet

  const updateSheet = (points) => sheet?.setData(pointsToTable(points));

  // The graph needs real dimensions, so build it only once its slide is showing
  function initIfVisible() {
    const rect = graphEl.getBoundingClientRect();
    if (!(rect.width > 0 && rect.height > 0)) return false;
    if (window.Reveal?.getCurrentSlide && !Reveal.getCurrentSlide()?.contains(graphEl)) {
      return false;
    }
    if (widget) return true;

    graphEl.innerHTML = '';
    sheetEl.innerHTML = '';

    widget = new LineGraphWidget({
      container: graphEl,
      count: POINTS,
      yValues: loadPrior(),
      color: brand('red'), // the prior's color on Steps 2 and 3
      falloff: 1.5, // dragging one point pulls its neighbors along, for a smooth curve
      onChange: (points) => {
        updateSheet(points);
        savePrior(points.map((p) => p.y));
      },
    });

    const created = window.jspreadsheet(sheetEl, {
      tabs: false,
      worksheets: [{
        data: pointsToTable(widget.getPoints()),
        editable: false,
        minDimensions: [2, POINTS],
        rowHeaders: (rowIndex) => (rowIndex * STEP).toFixed(2),
        allowInsertRow: false,
        allowDeleteRow: false,
        allowInsertColumn: false,
        allowDeleteColumn: false,
        columnSorting: false,
        columns: [
          { type: 'numeric', title: 'Voters', width: 90, mask: '0%' },
          { type: 'numeric', title: 'Score', width: 90, mask: '0.00' },
          { type: 'numeric', title: 'Probability', width: 120, mask: '0.0000' },
        ],
        selectionCopy: true,
        selection: true,
      }],
    });
    // jspreadsheet 5 returns the list of worksheets
    Promise.resolve(created).then((worksheets) => {
      sheet = Array.isArray(worksheets) ? worksheets[0] : worksheets;
      updateSheet(widget.getPoints());
    });

    resetBtn?.addEventListener('click', () => widget.setYValues(flatPrior()));

    // The posterior slide can hand its posterior back as a new prior
    window.addEventListener('poll-prior:set', (e) => {
      if (Array.isArray(e.detail)) widget.setYValues(e.detail);
    });

    return true;
  }

  const observer = new ResizeObserver(() => {
    if (initIfVisible()) observer.disconnect();
  });
  observer.observe(graphEl);

  // Retry each frame only while this slide is showing (layout can lag the slide change)
  const runWhenReady = () => {
    if (initIfVisible()) return;
    if (!window.Reveal?.getCurrentSlide || Reveal.getCurrentSlide()?.contains(graphEl)) {
      requestAnimationFrame(runWhenReady);
    }
  };

  if (window.Reveal?.on) {
    Reveal.on('ready', runWhenReady);
    Reveal.on('slidechanged', runWhenReady);
  } else {
    window.addEventListener('load', runWhenReady);
    runWhenReady();
  }
}
