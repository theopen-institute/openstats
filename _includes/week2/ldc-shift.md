```{=html}
<!-- Week 2, "The same puzzle, in Nepal": every developing country, in or out of
     the UN's least developed countries; graduate Nepal, Bangladesh and Laos and watch
     both averages. Data from the deck's ldc-data block, behavior in js/ldc-shift.js,
     styles in css/deck.scss (.w2-*). -->
<div class="widget-layout ldc-shift">
  <div class="w2-graph w2-short"></div>
  <div class="w2-side">
    <button type="button" class="widget-btn ldc-go">Graduate Nepal, Bangladesh and Laos</button>
    <label class="w2-check"><input type="radio" name="ldc-indicator" value="u5" checked> Child deaths</label>
    <label class="w2-check"><input type="radio" name="ldc-indicator" value="gni"> Income per person</label>
    <table class="w2-stats">
      <thead>
        <tr><th>Average</th><th>On the list</th><th>After</th></tr>
      </thead>
      <tbody>
        <tr><td class="blue">LDCs</td><td class="ldc-ldc-before"></td><td class="ldc-ldc-after"></td></tr>
        <tr><td>Others</td><td class="ldc-other-before"></td><td class="ldc-other-after"></td></tr>
      </tbody>
    </table>
    <p class="w2-readout ldc-verdict"><b>Both averages got worse.</b> No country changed.</p>
  </div>
</div>
```

<script type="module" src="js/ldc-shift.js"></script>
