```{=html}
<!-- Week 1, "Step 1: The prior": a draggable prior for the mayor's vote share.
     Behavior in js/poll-prior.js (needs _build/jspreadsheet.html in the deck's header),
     styles in css/deck.scss. -->
<div class="widget-layout">
  <div id="poll-prior-graph" class="widget-graph"></div>
  <div>
    <div id="poll-prior-sheet"></div>
    <div class="sheet-controls">
      <button id="poll-prior-reset" class="widget-btn" type="button">Reset</button>
    </div>
  </div>
</div>
```

<script type="module" src="js/poll-prior.js"></script>
