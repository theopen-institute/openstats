```{=html}
<!-- Week 2, "A relationship is a distribution that moves": the weights of adults of
     about the same height, against everyone's. Data from the deck's kung-data block,
     behavior in js/conditional.js, styles in css/deck.scss (.w2-*). -->
<div class="widget-layout conditional">
  <div class="w2-graph"></div>
  <div class="w2-side">
    <label>Height: <b class="cond-height-out"></b> <small class="gray">± 2.5 cm</small>
      <input type="range" class="cond-height" min="140" max="172" step="0.5" value="145">
    </label>
    <p class="w2-hint">Or drag across the plot.</p>
    <table class="w2-stats">
      <tbody>
        <tr><td>Adults this tall</td><td class="cond-n"></td></tr>
        <tr><td class="orange">Their average weight</td><td class="cond-avg"></td></tr>
      </tbody>
    </table>
    <label class="w2-check"><input type="checkbox" class="cond-line"> Show the line</label>
    <button type="button" class="widget-btn cond-clear">Clear the marks</button>
  </div>
</div>
```

<script type="module" src="js/conditional.js"></script>
