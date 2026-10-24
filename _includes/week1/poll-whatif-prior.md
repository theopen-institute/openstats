```{=html}
<!-- Week 1, "What if I'd started from a different prior?": the class's prior from
     Step 1, moved and made more or less sure, with the class's survey. Behavior in
     js/poll-whatif.js, styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="whatif-prior-graph" class="widget-graph poll-graph"></div>
  <div class="poll-side">
    <label for="whatif-shift">Move it: <b id="whatif-shift-out"></b></label>
    <input type="range" id="whatif-shift" min="-40" max="40" step="1" value="0">
    <label for="whatif-strength">How sure: <b id="whatif-strength-out"></b></label>
    <input type="range" id="whatif-strength" min="0" max="100" step="1" value="50">
    <div class="whatif-presets" id="whatif-prior-presets">
      <button type="button" class="widget-btn" data-shift="0" data-strength="50">As drawn</button>
      <button type="button" class="widget-btn" data-shift="0" data-strength="0">No opinion</button>
      <button type="button" class="widget-btn" data-shift="0" data-strength="30">Less sure</button>
      <button type="button" class="widget-btn" data-shift="0" data-strength="85">Surer</button>
      <button type="button" class="widget-btn" data-shift="-20" data-strength="50">20 points lower</button>
      <button type="button" class="widget-btn" data-shift="20" data-strength="50">20 points higher</button>
    </div>
    <p id="whatif-prior-flat" class="whatif-hint" hidden>Your prior is flat, so moving it or
      making it surer changes nothing. Draw a hump on Step 1 to try it.</p>
    <table class="poll-stats">
      <thead>
        <tr><th></th><th class="gray">Yours</th><th class="green">What if</th></tr>
      </thead>
      <tbody>
        <tr><td>Best guess</td><td id="whatif-prior-mean-base"></td><td id="whatif-prior-mean"></td></tr>
        <tr><td>90% range</td><td id="whatif-prior-range-base"></td><td id="whatif-prior-range"></td></tr>
        <tr><td>P( more than half )</td><td id="whatif-prior-win-base"></td><td id="whatif-prior-win"></td></tr>
      </tbody>
    </table>
  </div>
</div>
```

<script type="module" src="js/poll-whatif.js"></script>
