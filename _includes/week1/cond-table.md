```{=html}
<!-- Week 1, "Direction of conditions": an editable 2x2 table. Behavior in
     js/cond-table.js, styles in css/deck.scss (#cond-table). The starting counts
     are the Kathmandu rain days of "Writing it down: P(event | condition)",
     checked by check_stated_numbers() in r/week1.R. -->
<table id="cond-table">
  <thead>
    <tr><th></th><th>Rain</th><th>No rain</th><th class="cond-reset-cell"><button id="cond-reset" class="widget-btn" type="button">Reset</button></th></tr>
  </thead>
  <tbody>
    <tr>
      <td><b>July</b></td>
      <td><input class="num-input key" type="number" min="0" step="1" value="126" data-default="126" id="cond-jr"></td>
      <td><input class="num-input" type="number" min="0" step="1" value="29" data-default="29" id="cond-jd"></td>
      <td class="cond-total" id="cond-july"></td>
    </tr>
    <tr>
      <td><b>Other months</b></td>
      <td><input class="num-input" type="number" min="0" step="1" value="439" data-default="439" id="cond-or"></td>
      <td><input class="num-input" type="number" min="0" step="1" value="1231" data-default="1231" id="cond-od"></td>
      <td class="cond-total" id="cond-other"></td>
    </tr>
    <tr>
      <td></td>
      <td class="cond-total" id="cond-rain"></td>
      <td class="cond-total" id="cond-dry"></td>
      <td class="cond-total" id="cond-all"></td>
    </tr>
  </tbody>
</table>

<div class="cond-results">
  <p class="fragment"><span class="red">P( rain | Jul )</span> = <span id="cond-p1"></span>: the share of July days that are rainy</p>
  <p class="fragment"><span class="blue">P( Jul | rain )</span> = <span id="cond-p2"></span>: the share of rainy days that are in July</p>
</div>
```

<script src="js/cond-table.js"></script>
