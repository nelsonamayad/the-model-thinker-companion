; The forest fire model of self-organized criticality (The Model Thinker,
; chapter 6). The Model Thinker Companion: reference implementation, run with nlrx
; by abm/forest-fire-model.R. The page replays the same rules in JavaScript.
;
; The forest is an initially empty grid (not wrapped). At each step a random
; site is chosen. If it is empty, a tree grows there with probability g. If it
; holds a tree, lightning strikes with probability 1 - g, and the fire burns
; the whole cluster of trees connected to it through the four neighbouring
; sites. One tick is as many steps as there are sites. Fire sizes are
; recorded after a burn-in of `burn-in` ticks, in doubling bins:
; bin 0 = 1 tree, bin 1 = 2-3 trees, bin 2 = 4-7 trees, ...

globals [
  fire-bins        ; number of fires in each doubling bin
  density-sum      ; sum of tree density over the recorded ticks
  recorded-ticks
  largest-fire
]

patches-own [ tree? ]

to setup
  clear-all
  ask patches [ set tree? false set pcolor black ]
  set fire-bins n-values 16 [ 0 ]
  set density-sum 0
  set recorded-ticks 0
  set largest-fire 0
  reset-ticks
end

to go
  repeat count patches [
    let p one-of patches
    ifelse [ tree? ] of p
      [ if random-float 1 < 1 - g [ burn p ] ]
      [ if random-float 1 < g [ ask p [ set tree? true set pcolor green ] ] ]
  ]
  if ticks >= burn-in [
    set density-sum density-sum + count patches with [ tree? ] / count patches
    set recorded-ticks recorded-ticks + 1
  ]
  tick
end

to burn [ p ]
  let front (patch-set p)
  ask p [ set tree? false set pcolor red ]
  let burned 1
  while [ any? front ] [
    let next patch-set [ neighbors4 with [ tree? ] ] of front
    ask next [ set tree? false set pcolor red ]
    set burned burned + count next
    set front next
  ]
  if ticks >= burn-in [
    let b floor (ln burned / ln 2)
    set fire-bins replace-item b fire-bins (item b fire-bins + 1)
    if burned > largest-fire [ set largest-fire burned ]
  ]
end

to-report mean-density
  report ifelse-value (recorded-ticks > 0)
    [ density-sum / recorded-ticks ] [ 0 ]
end

to-report fires-recorded
  report sum fire-bins
end
@#$#@#$#@
GRAPHICS-WINDOW
250
10
678
439
-1
-1
7.0
1
10
1
1
1
0
0
0
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
g
g
0.5
0.999
0.99
0.001
1
NIL
HORIZONTAL

SLIDER
10
50
230
83
burn-in
burn-in
0
200
50.0
10
1
NIL
HORIZONTAL

BUTTON
10
95
115
128
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
95
230
128
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
140
230
185
mean tree density
mean-density
3
1
11

MONITOR
10
190
230
235
largest fire
largest-fire
0
1
11
@#$#@#$#@
## WHAT IS IT?

The forest fire model of self-organized criticality, as described in chapter 6 of Scott E. Page's *The Model Thinker*. Trees grow on empty sites with probability G and lightning strikes trees with probability 1 - G; a strike burns the whole connected cluster of trees.

## HOW TO USE IT

Set G close to 1 (rare lightning), press SETUP, then GO. Tree density rises to a critical level and fires of all sizes follow. FIRE-BINS counts fires in doubling size classes after the BURN-IN.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/forest-fire-model.R.
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
