```{=html}
<!-- Week 2, "Same data, new ruler": the adults' heights on a centimeter (or inch)
     ruler and a z ruler, with one man to drag, and a choice of the crowd the z-scores
     compare him with. Data from the deck's adults-data and zscore-data blocks,
     behavior in js/z-ruler.js, styles in css/deck.scss (.z-ruler, .w2-*). -->
<div class="widget-layout z-ruler">
  <div class="w2-graph w2-short"></div>
  <div class="w2-side">
    <div>
      <p>Compared with</p>
      <div class="w2-buttons">
        <button type="button" class="widget-btn w2-choice" data-group="all">All adults</button>
        <button type="button" class="widget-btn w2-choice" data-group="women">Women</button>
        <button type="button" class="widget-btn w2-choice" data-group="men">Men</button>
      </div>
    </div>
    <div>
      <p>Ruler</p>
      <div class="w2-buttons">
        <button type="button" class="widget-btn w2-choice" data-unit="cm">Centimeters</button>
        <button type="button" class="widget-btn w2-choice" data-unit="in">Inches</button>
      </div>
    </div>
    <table class="w2-stats">
      <tbody>
        <tr><td>His height</td><td class="zr-height"></td></tr>
        <tr><td class="blue">His z-score</td><td class="zr-z"></td></tr>
        <tr><td>Taller than</td><td class="zr-share"></td></tr>
      </tbody>
    </table>
    <table class="w2-stats z-zones">
      <thead><tr><th>z</th><th></th><th>Share of people</th></tr></thead>
      <tbody>
        <tr><td>0 to ±1</td><td><span class="z-swatch"></span>typical</td><td>68%</td></tr>
        <tr><td>±1 to ±2</td><td><span class="z-swatch"></span>uncommon</td><td>27%</td></tr>
        <tr><td>±2 to ±3</td><td><span class="z-swatch"></span>unusual</td><td>1 in 20</td></tr>
        <tr><td>beyond ±3</td><td><span class="z-swatch"></span>rare</td><td>1 in 370</td></tr>
      </tbody>
    </table>
    <p class="w2-hint">Drag across the plot to move him.</p>
  </div>
</div>
```

<script type="module" src="js/z-ruler.js"></script>
