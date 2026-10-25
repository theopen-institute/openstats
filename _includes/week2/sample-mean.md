```{=html}
<!-- Week 2, "How sure can a few people make us?": measure a random few of the !Kung
     adults, and compare how much they vary with how sure we are about their average.
     Data from the deck's kung-data block, behavior in js/sample-mean.js, styles in
     css/deck.scss (.w2-*). -->
<div class="widget-layout sample-mean">
  <div class="w2-graph"></div>
  <div class="w2-side">
    <label>Adults measured: <b class="sample-size-out"></b>
      <input type="range" class="sample-size" min="3" max="100" step="1" value="5">
    </label>
    <div class="w2-buttons">
      <button type="button" class="widget-btn" data-n="5">5</button>
      <button type="button" class="widget-btn" data-n="20">20</button>
      <button type="button" class="widget-btn" data-n="100">100</button>
    </div>
    <button type="button" class="widget-btn sample-again">Measure new people</button>
    <table class="w2-stats">
      <tbody>
        <tr><td>Best guess for the average</td><td class="sample-guess"></td></tr>
        <tr><td class="blue">Most of these adults are within</td><td class="sample-spread"></td></tr>
        <tr><td class="green">95% sure the average is within</td><td class="sample-sure"></td></tr>
      </tbody>
    </table>
    <label class="w2-check"><input type="checkbox" class="sample-truth"> Show everyone's average</label>
  </div>
</div>
```

<script type="module" src="js/sample-mean.js"></script>
