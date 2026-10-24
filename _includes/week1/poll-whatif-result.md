```{=html}
<!-- Week 1, "What if the survey had come out differently?": another share saying
     "mayor", at the class's survey size, with the class's prior. Behavior in
     js/poll-whatif.js, styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="whatif-result-graph" class="widget-graph poll-graph"></div>
  <div class="poll-side">
    <label for="whatif-result">Said "mayor": <b id="whatif-result-out"></b></label>
    <input type="range" id="whatif-result" min="0" max="100" step="1" value="20">
    <div class="whatif-presets" id="whatif-result-presets">
      <button type="button" class="widget-btn" data-share="10">10%</button>
      <button type="button" class="widget-btn" data-ours>Ours</button>
      <button type="button" class="widget-btn" data-share="50">50%</button>
      <button type="button" class="widget-btn" data-share="70">70%</button>
    </div>
    <table class="poll-stats">
      <thead>
        <tr><th></th><th class="gray">Original</th><th class="green">What if</th></tr>
      </thead>
      <tbody>
        <tr><td>Best guess</td><td id="whatif-result-mean-base"></td><td id="whatif-result-mean"></td></tr>
        <tr><td>90% range</td><td id="whatif-result-range-base"></td><td id="whatif-result-range"></td></tr>
        <tr><td>P( mayor wins )</td><td id="whatif-result-win-base"></td><td id="whatif-result-win"></td></tr>
      </tbody>
    </table>
  </div>
</div>
```

<script type="module" src="js/poll-whatif.js"></script>
