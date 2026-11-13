; Schelling's segregation model (The Model Thinker, chapter 19).
; The Model Thinker Companion: reference implementation, run with nlrx by
; abm/schelling-segregation.R. The page replays the same rules in JavaScript.
;
; Agents of two types live on a wrapped grid with some empty cells. An agent
; is content if at least its threshold percent of the agents on its eight
; neighbouring cells share its type (an agent with no neighbours is content).
; Thresholds are `threshold` plus a uniform draw in [-spread, +spread].
; Each tick, every discontented agent moves to a random empty cell, one at a
; time in random order. The run stops when everyone is content.

globals [
  percent-similar   ; average share of same-type neighbours, in percent
  percent-unhappy   ; share of agents who want to move, in percent
]

turtles-own [
  kind              ; 0 or 1
  my-threshold      ; this agent's threshold, in percent
  similar-nearby
  total-nearby
  happy?
]

to setup
  clear-all
  ask patches [
    if random-float 100 < density [
      sprout 1 [
        set kind random 2
        set my-threshold threshold - spread + random-float (2 * spread)
        set shape "square"
        set color ifelse-value (kind = 0) [ 84 ] [ 25 ]
      ]
    ]
  ]
  update-agents
  reset-ticks
end

to go
  if all? turtles [ happy? ] [ stop ]
  ask turtles with [ not happy? ] [
    move-to one-of patches with [ not any? turtles-here ]
  ]
  update-agents
  tick
end

to update-agents
  ask turtles [
    let nearby turtles-on neighbors
    set total-nearby count nearby
    set similar-nearby count nearby with [ kind = [ kind ] of myself ]
    set happy? (total-nearby = 0) or
      (100 * similar-nearby >= my-threshold * total-nearby)
  ]
  set percent-similar 100 * sum [ similar-nearby ] of turtles
    / max list 1 sum [ total-nearby ] of turtles
  set percent-unhappy 100 * count turtles with [ not happy? ]
    / max list 1 count turtles
end
@#$#@#$#@
GRAPHICS-WINDOW
260
10
668
419
-1
-1
10.0
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
39
0
39
1
1
1
ticks
30.0

SLIDER
10
10
240
43
density
density
50
95
80.0
1
1
%
HORIZONTAL

SLIDER
10
50
240
83
threshold
threshold
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
10
90
240
123
spread
spread
0
30
0.0
1
1
%
HORIZONTAL

BUTTON
10
135
120
168
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
130
135
240
168
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
180
120
225
% similar
percent-similar
1
1
11

MONITOR
130
180
240
225
% unhappy
percent-unhappy
1
1
11
@#$#@#$#@
## WHAT IS IT?

Schelling's segregation model, as described in chapter 19 of Scott E. Page's *The Model Thinker*. Two types of agents share a wrapped 40 x 40 grid. An agent stays put if at least THRESHOLD percent of its neighbours are of its own type; otherwise it moves to a random empty cell.

## HOW TO USE IT

Set DENSITY and THRESHOLD, press SETUP, then GO. The run stops when every agent is content. The monitors show the average share of same-type neighbours and the share of agents who want to move.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/schelling-segregation.R.
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
