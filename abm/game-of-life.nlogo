; Conway's Game of Life (The Model Thinker, chapter 15).
; The Model Thinker Companion: reference implementation, run with nlrx by
; abm/game-of-life.R. The page replays the same rules in JavaScript.
;
; Each cell of a wrapped grid is alive or dead. All cells update at once:
; a dead cell with exactly three live neighbours becomes alive; a live cell
; with fewer than two or more than three live neighbours dies. Cells start
; alive with probability `initial-density` percent.

globals [
  changed         ; share of cells that changed state in the last tick
]

patches-own [ alive? live-neighbors ]

to setup
  clear-all
  ask patches [
    set alive? random-float 100 < initial-density
    recolor
  ]
  set changed 0
  reset-ticks
end

to go
  ask patches [ set live-neighbors count neighbors with [ alive? ] ]
  let flips 0
  ask patches [
    let next ifelse-value alive?
      [ live-neighbors = 2 or live-neighbors = 3 ]
      [ live-neighbors = 3 ]
    if next != alive? [ set flips flips + 1 ]
    set alive? next
    recolor
  ]
  set changed flips / count patches
  tick
end

to recolor
  set pcolor ifelse-value alive? [ 55 ] [ black ]
end

to-report density
  report count patches with [ alive? ] / count patches
end
@#$#@#$#@
GRAPHICS-WINDOW
250
10
668
429
-1
-1
7.0
1
10
1
1
1
0
1
1
1
0
59
0
59
1
1
1
ticks
30.0

SLIDER
10
10
230
43
initial-density
initial-density
0
100
35.0
1
1
%
HORIZONTAL

BUTTON
10
55
115
88
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
125
55
230
88
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
10
100
230
145
density
density
3
1
11
@#$#@#$#@
## WHAT IS IT?

John Conway's Game of Life, as described in chapter 15 of Scott E. Page's *The Model Thinker*. Two rules applied to every cell at once produce still lifes, oscillators, gliders and long transients.

## HOW TO USE IT

Set INITIAL-DENSITY, press SETUP, then GO. The monitor shows the share of live cells.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/game-of-life.R.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

square
false
0
Rectangle -7500403 true true 30 30 270 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
