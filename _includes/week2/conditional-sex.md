```{=html}
<!-- Week 2, "Compare adults of the same height": women's and men's weights, among
     adults of about the same height. Data from the deck's kung-data block, behavior in
     js/conditional.js (data-split="sex"), styles in css/deck.scss (.w2-*). -->
<div class="widget-layout conditional" data-split="sex">
  <div class="w2-graph"></div>
  <div class="w2-side">
    <label>Height: <b class="cond-height-out"></b> <small class="gray">± 3 cm</small>
      <input type="range" class="cond-height" min="140" max="172" step="0.5" value="155">
    </label>
    <p class="w2-hint">Or drag across the plot.</p>
    <table class="w2-stats">
      <tbody>
        <tr><td class="red">Women this tall</td><td class="cond-women"></td></tr>
        <tr><td class="blue">Men this tall</td><td class="cond-men"></td></tr>
        <tr><td>Men's average, minus women's</td><td class="cond-gap"></td></tr>
      </tbody>
    </table>
    <label class="w2-check"><input type="checkbox" class="cond-line"> Show the lines</label>
  </div>
</div>
```

<script type="module" src="js/conditional.js"></script>
