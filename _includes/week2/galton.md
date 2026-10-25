```{=html}
<!-- Week 2, "Random individuals, predictable crowds": a Galton board. Behavior in
     js/galton.js, styles in css/deck.scss (.w2-*). -->
<div class="widget-layout galton">
  <div class="w2-graph"></div>
  <div class="w2-side">
    <label>Rows of pegs: <b class="galton-rows-out"></b>
      <input type="range" class="galton-rows" min="1" max="14" step="1" value="4">
    </label>
    <div class="w2-buttons">
      <button type="button" class="widget-btn" data-drop="1">Drop 1</button>
      <button type="button" class="widget-btn" data-drop="10">10</button>
      <button type="button" class="widget-btn" data-drop="100">100</button>
      <button type="button" class="widget-btn" data-drop="1000">1,000</button>
    </div>
    <p class="w2-readout">Balls dropped: <b class="galton-n">0</b></p>
    <label class="w2-check"><input type="checkbox" class="galton-paths"> Count the paths</label>
    <button type="button" class="widget-btn galton-reset">Empty the bins</button>
  </div>
</div>
```

<script type="module" src="js/galton.js"></script>
