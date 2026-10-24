```{=html}
<!-- Week 1, "Answering the question": the share of the class's posterior above 50%.
     Behavior in js/poll-answer.js, styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="poll-answer-graph" class="widget-graph poll-graph"></div>
  <div class="poll-side">
    <p><i>Will he get more than half the vote?</i> Add up the posterior above 50%.</p>
    <table class="poll-stats">
      <thead>
        <tr><th></th><th>P( more than half )</th></tr>
      </thead>
      <tbody>
        <tr><td class="red">Prior</td><td id="poll-answer-prior"></td></tr>
        <tr><td class="green">Posterior</td><td id="poll-answer-post"></td></tr>
      </tbody>
    </table>
    <p>That's P( <span class="red">hypothesis</span> | <span class="blue">data</span> ):
      the question a p-value can't answer.</p>
    <p id="poll-answer-chance"></p>
  </div>
</div>
```

<script type="module" src="js/poll-answer.js"></script>
