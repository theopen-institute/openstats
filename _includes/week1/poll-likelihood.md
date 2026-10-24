```{=html}
<!-- Week 1, "Step 2: The likelihood": sliders for the survey, with the likelihood curve
     (and the prior from Step 1, for comparison) and its value at a few θs. Behavior in js/poll-likelihood.js (the survey is shared
     with Step 3 through js/poll-store.js), styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="poll-lik-graph" class="widget-graph poll-graph"></div>
  <div class="poll-side">
    <label for="poll-n">People surveyed: <b id="poll-n-out"></b></label>
    <input type="range" id="poll-n" min="0" max="500" step="1" value="20">
    <label for="poll-share">Said "mayor": <b id="poll-share-out"></b></label>
    <input type="range" id="poll-share" min="0" max="100" step="1" value="20">
    <table class="poll-stats">
      <thead>
        <tr><th>If θ is</th><th id="poll-lik-head" class="blue"></th></tr>
      </thead>
      <tbody>
        <tr><td>20%</td><td id="poll-lik-20"></td></tr>
        <tr><td>40%</td><td id="poll-lik-40"></td></tr>
        <tr><td>60%</td><td id="poll-lik-60"></td></tr>
        <tr><td>80%</td><td id="poll-lik-80"></td></tr>
      </tbody>
    </table>
  </div>
</div>
```

<script type="module" src="js/poll-likelihood.js"></script>
