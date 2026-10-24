```{=html}
<!-- Week 1, "What if I'd asked more (or fewer) people?": the class's survey result at
     another survey size, with the class's prior. Behavior in js/poll-whatif.js, styles
     in css/deck.scss. -->
<div class="widget-layout">
  <div id="whatif-size-graph" class="widget-graph poll-graph"></div>
  <div class="poll-side">
    <label for="whatif-size">People surveyed: <b id="whatif-size-out"></b></label>
    <input type="range" id="whatif-size" min="0" max="100" step="0.1" value="40">
    <p class="whatif-note">Said "mayor": <b id="whatif-size-said"></b></p>
    <div class="whatif-presets" id="whatif-size-presets">
      <button type="button" class="widget-btn" data-n="0">Nobody</button>
      <button type="button" class="widget-btn" data-n="5">5</button>
      <button type="button" class="widget-btn" data-ours>Ours</button>
      <button type="button" class="widget-btn" data-n="100">100</button>
      <button type="button" class="widget-btn" data-n="1000">1,000</button>
    </div>
    <table class="poll-stats">
      <thead>
        <tr><th></th><th class="gray">Original</th><th class="green">What if</th></tr>
      </thead>
      <tbody>
        <tr><td>Best guess</td><td id="whatif-size-mean-base"></td><td id="whatif-size-mean"></td></tr>
        <tr><td>90% range</td><td id="whatif-size-range-base"></td><td id="whatif-size-range"></td></tr>
        <tr><td>P( mayor wins )</td><td id="whatif-size-win-base"></td><td id="whatif-size-win"></td></tr>
      </tbody>
    </table>
  </div>
</div>
```

<script type="module" src="js/poll-whatif.js"></script>
