```{=html}
<!-- Week 1, "Direction of conditions": an editable 2x2 table. Behavior in
     js/cond-table.js, styles in css/deck.scss (#cond-table). -->
<table id="cond-table">
  <thead>
    <tr><th></th><th>Sociology</th><th>Economics</th><th class="cond-reset-cell"><button id="cond-reset" class="widget-btn" type="button">Reset</button></th></tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Urban</b></td>
      <td><input class="num-input" type="number" min="0" step="1" value="240" data-default="240" id="cond-us"></td>
      <td><input class="num-input" type="number" min="0" step="1" value="300" data-default="300" id="cond-ue"></td>
      <td class="cond-total" id="cond-urban"></td>
    </tr>
    <tr>
      <td><b>Rural</b></td>
      <td><input class="num-input key" type="number" min="0" step="1" value="80" data-default="80" id="cond-rs"></td>
      <td><input class="num-input" type="number" min="0" step="1" value="20" data-default="20" id="cond-re"></td>
      <td class="cond-total" id="cond-rural"></td>
    </tr>
    <tr>
      <td></td>
      <td class="cond-total" id="cond-soc"></td>
      <td class="cond-total" id="cond-econ"></td>
      <td class="cond-total" id="cond-all"></td>
    </tr>
  </tbody>
</table>

<div class="cond-results">
  <p><span class="red">P( Sociology | Rural )</span> = <span id="cond-p1"></span></p>
  <p><span class="blue">P( Rural | Sociology )</span> = <span id="cond-p2"></span></p>
</div>
```

<script src="js/cond-table.js"></script>
