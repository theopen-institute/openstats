```{=html}
<!-- Week 1, "Step 3": the prior from Step 1 times the likelihood of the survey set on
     Step 2. Behavior in js/poll-posterior.js, styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="poll-post-graph" class="widget-graph"></div>
  <div class="poll-side">
    <p class="poll-survey">Survey: <b id="poll-survey-out"></b><br><small>Change it on Step 2.</small></p>
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
