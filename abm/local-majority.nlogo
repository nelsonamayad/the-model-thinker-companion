; The local majority model (The Model Thinker, chapter 15).
; The Model Thinker Companion: reference implementation, run with nlrx by
; abm/local-majority.R. The page replays the same rules in JavaScript.
;
; Each cell of a wrapped grid is on or off. One tick is one sweep: as many
; single-cell updates as there are cells. In each update a random cell is
; chosen and it switches state if and only if five or more of its eight
; neighbours are in the other state. The run stops when no cell would switch.

globals [
  initial-on      ; share of cells on at the start
]

patches-own [ on? ]

to setup
  clear-all
  ask patches [
    set on? random-float 100 < share-on
    recolor
  ]
  set initial-on final-on
  reset-ticks
end

to go
  if not any? patches with [ unstable? ] [ stop ]
  repeat count patches [
    ask one-of patches [
      if unstable? [ set on? not on? recolor ]
    ]
  ]
  tick
end

to-report unstable?
  report count neighbors with [ on? != [ on? ] of myself ] >= 5
end

to recolor
  set pcolor ifelse-value on? [ 85 ] [ 26 ]
end

; Share of cells on.
to-report final-on
  report count patches with [ on? ] / count patches
end

; Share of cells with at least one neighbour in the other state: a measure
; of how patchy the configuration is (0 means one uniform block).
to-report boundary-share
  report count patches with [ any? neighbors with [ on? != [ on? ] of myself ] ]
    / count patches
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
share-on
share-on
0
100
50.0
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
share on
final-on
3
1
11

MONITOR
10
150
230
195
boundary share
boundary-share
3
1
11
@#$#@#$#@
## WHAT IS IT?

The local majority model, as described in chapter 15 of Scott E. Page's *The Model Thinker*. Cells on a wrapped grid switch to match their neighbourhood when five or more of their eight neighbours disagree with them.

## HOW TO USE IT

Set SHARE-ON, press SETUP, then GO. The run stops when no cell wants to switch: the grid freezes into patches.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/local-majority.R.
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
