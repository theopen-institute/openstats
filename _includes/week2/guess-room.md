```{=html}
<!-- Week 2, "Ask the room": simulated rooms of people guess the man's age; each
     room's guesses, and every room's average. Behavior in js/guess-room.js, styles in
     css/deck.scss (.w2-*). -->
<div class="widget-layout guess-room">
  <div class="w2-graph"></div>
  <div class="w2-side">
    <div>
      <p>People per room</p>
      <div class="w2-buttons">
        <button type="button" class="widget-btn w2-choice" data-size="1">1</button>
        <button type="button" class="widget-btn w2-choice" data-size="5">5</button>
        <button type="button" class="widget-btn w2-choice" data-size="20">20</button>
      </div>
    </div>
    <div class="w2-buttons">
      <button type="button" class="widget-btn guess-ask">Ask a room</button>
      <button type="button" class="widget-btn guess-many">Ask 50 rooms</button>
    </div>
    <p class="w2-readout">Rooms asked: <b class="guess-rooms">0</b></p>
    <label class="w2-check"><input type="checkbox" class="guess-truth"> Show his age</label>
    <button type="button" class="widget-btn guess-reset">Start over</button>
  </div>
</div>
```

<script type="module" src="js/guess-room.js"></script>
