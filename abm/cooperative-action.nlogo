; The cooperative action model (The Model Thinker, chapter 22).
; The Model Thinker Companion: reference implementation, run with nlrx by
; abm/cooperative-action.R. The page replays the same rules in JavaScript.
;
; Nodes of a random network (average degree `mean-degree`) are habitats.
; One node in six is occupied at the start, and one occupied node in six is
; a cooperator; the rest are defectors. A cooperator pays a cost C = 1 for
; each occupied neighbour and gives each of them a benefit B
; (`benefit-ratio`, so B/C = benefit-ratio). Each tick one empty node next to
; an occupied node is filled: it takes the type of its highest-payoff
; occupied neighbour (ties broken at random). The run stops when no empty
; node touches an occupied one.

turtles-own [ state ]   ; "empty", "C" (cooperator) or "D" (defector)

to setup
  clear-all
  create-turtles population [
    set shape "circle"
    set size 0.8
    set state "empty"
  ]
  ; Random network: add links between random pairs until the average
  ; degree is reached.
  let target round (population * mean-degree / 2)
  while [ count links < target ] [
    ask one-of turtles [
      let other-node one-of other turtles with [ not link-neighbor? myself ]
      if other-node != nobody [ create-link-with other-node ]
    ]
  ]
  ask turtles [
    if random 6 = 0 [ set state ifelse-value (random 6 = 0) [ "C" ] [ "D" ] ]
    recolor
  ]
  layout-circle turtles 15
  reset-ticks
end

to go
  let frontier turtles with [
    state = "empty" and any? link-neighbors with [ state != "empty" ]
  ]
  if not any? frontier [ stop ]
  ask one-of frontier [
    let best max-one-of (link-neighbors with [ state != "empty" ]) [ payoff ]
    set state [ state ] of best
    recolor
  ]
  tick
end

to-report payoff
  let occupied link-neighbors with [ state != "empty" ]
  let helpers count occupied with [ state = "C" ]
  report benefit-ratio * helpers
    - ifelse-value (state = "C") [ count occupied ] [ 0 ]
end

to recolor
  set color ifelse-value (state = "C") [ cyan ]
    [ ifelse-value (state = "D") [ orange ] [ gray - 3 ] ]
end

to-report coop-share
  let occupied turtles with [ state != "empty" ]
  report ifelse-value (any? occupied)
    [ count occupied with [ state = "C" ] / count occupied ] [ 0 ]
end

to-report initial-coop-share
  report 1 / 6
end
@#$#@#$#@
GRAPHICS-WINDOW
250
10
663
424
-1
-1
12.3
1
10
1
1
1
0
0
0
1
-16
16
-16
16
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
population
population
50
1000
500.0
50
1
NIL
HORIZONTAL

SLIDER
10
50
230
83
mean-degree
mean-degree
2
20
4.0
1
1
NIL
HORIZONTAL

SLIDER
10
90
230
123
benefit-ratio
benefit-ratio
1
12
4.0
0.5
1
NIL
HORIZONTAL

BUTTON
10
135
115
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
125
135
230
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
230
225
cooperators among occupied
coop-share
3
1
11
@#$#@#$#@
## WHAT IS IT?

The cooperative action model, as described in chapter 22 of Scott E. Page's *The Model Thinker*. Cooperators pay a cost to benefit each neighbour; empty nodes are filled with the type of their best-performing neighbour, so clusters of cooperators can spread.

## HOW TO USE IT

Set the network's MEAN-DEGREE and the BENEFIT-RATIO (B/C), press SETUP, then GO.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/cooperative-action.R.
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
