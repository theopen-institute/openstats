```{=html}
<!-- Week 1, "Answering the question": the share of the class's posterior above 50%.
     Behavior in js/poll-answer.js, styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="poll-answer-graph" class="widget-graph poll-graph"></div>
  <div class="poll-side">
    <p>The posterior doesn't say what <i>will</i> happen. It spreads our belief over every
      possible result, some more plausible than others.</p>
    <p><i>Will the mayor get more than half the vote?</i> Add up the posterior above 50%: the dark
      green area.</p>
    <table class="poll-stats">
      <thead>
        <tr><th></th><th>P( mayor wins )</th></tr>
      </thead>
      <tbody>
        <tr><td class="red">Prior</td><td id="poll-answer-prior"></td></tr>
        <tr><td class="green">Posterior</td><td id="poll-answer-post"></td></tr>
      </tbody>
    </table>
    <p id="poll-answer-chance" class="poll-answer-key"></p>
    <p>That's the same kind of number as <i>"a 31% chance of rain"</i>. The election isn't
      random, but we're uncertain about it. The percentage describes how much chance we think
      there is that the mayor will win.</p>
    <p class="source">If our assumptions hold: the people we surveyed were a random sample of
      voters, they'll vote the way they said, and winning takes more than half the vote.</p>
  </div>
</div>
```

<script type="module" src="js/poll-answer.js"></script>
