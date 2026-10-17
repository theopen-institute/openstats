```{=html}
<!-- Week 1, "Step 3": the prior from Step 1 times a survey likelihood. Behavior in
     js/poll-posterior.js, styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="poll-post-graph" class="widget-graph"></div>
  <div class="poll-side">
    <label for="poll-n">People surveyed: <b id="poll-n-out"></b></label>
    <input type="range" id="poll-n" min="0" max="500" step="1" value="20">
    <label for="poll-share">Said "mayor": <b id="poll-share-out"></b></label>
    <input type="range" id="poll-share" min="0" max="100" step="1" value="30">
    <table class="poll-stats">
      <thead>
        <tr><th></th><th class="red">Prior</th><th class="green">Posterior</th></tr>
      </thead>
      <tbody>
        <tr><td>Best guess</td><td id="poll-prior-mean"></td><td id="poll-post-mean"></td></tr>
        <tr><td>90% range</td><td id="poll-prior-range"></td><td id="poll-post-range"></td></tr>
        <tr><td>P( mayor wins )</td><td id="poll-prior-win"></td><td id="poll-post-win"></td></tr>
      </tbody>
    </table>
    <div id="poll-msg" class="red"></div>
    <button id="poll-carry" class="widget-btn" type="button">Make this posterior my new prior</button>
  </div>
</div>
```

<script type="module" src="js/poll-posterior.js"></script>
