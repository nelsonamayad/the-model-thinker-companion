; The El Farol model (The Model Thinker, chapter 4).
; The Model Thinker Companion: reference implementation, run with nlrx by
; abm/el-farol.R. The page replays the same rules in JavaScript.
;
; 100 people decide each week whether to go to a bar. Going pays +1 if at
; most `capacity` people go and -1 otherwise; staying home pays 0. Each person
; holds an ensemble of `ensemble-size` rules. A rule predicts this week's
; attendance from past attendance and advises going if its prediction is at
; most `capacity`. Each rule keeps a score: the payoff its advice would have
; earned so far. Each week every person follows their highest-scoring rule
; (the first one, if tied). Rule types, with their parameter k:
;   0 mirror: 100 minus last week's attendance
;   1 lag: attendance k weeks ago (k = 1..5)
;   2 average: mean of the last k weeks (k = 2..8)
;   3 trend: last week plus the average weekly change over the last k
;     weeks, kept within 0..100 (k = 2..5)
;   4 fixed: always predicts k (k = 0..100)
; Attendance history starts with 10 random weeks.

globals [
  history          ; past attendance, most recent first
  attendance       ; this week's attendance
  attendance-log   ; attendance in every simulated week, oldest first
]

turtles-own [
  rules            ; list of [type k] pairs
  scores           ; payoff each rule's advice would have earned
  going?
]

to setup
  clear-all
  set history n-values 10 [ random 101 ]
  set attendance-log []
  create-turtles 100 [
    set rules n-values ensemble-size [ random-rule ]
    set scores n-values ensemble-size [ 0 ]
    set hidden? true
  ]
  reset-ticks
end

to-report random-rule
  let kind random 5
  if kind = 0 [ report list 0 0 ]
  if kind = 1 [ report list 1 (1 + random 5) ]
  if kind = 2 [ report list 2 (2 + random 7) ]
  if kind = 3 [ report list 3 (2 + random 4) ]
  report list 4 random 101
end

to-report predict [ rule ]
  let kind first rule
  let k last rule
  if kind = 0 [ report 100 - item 0 history ]
  if kind = 1 [ report item (k - 1) history ]
  if kind = 2 [ report mean sublist history 0 k ]
  if kind = 3 [
    let change (item 0 history - item (k - 1) history) / (k - 1)
    report max list 0 min list 100 (item 0 history + change)
  ]
  report k
end

to go
  ask turtles [
    let best position (max scores) scores
    set going? predict (item best rules) <= capacity
  ]
  set attendance count turtles with [ going? ]
  let pay ifelse-value (attendance <= capacity) [ 1 ] [ -1 ]
  ask turtles [
    set scores (map [ [r s] ->
      s + ifelse-value (predict r <= capacity) [ pay ] [ 0 ] ] rules scores)
  ]
  set history fput attendance history
  set attendance-log lput attendance attendance-log
  tick
end

; Summaries over the weeks after a 20-week burn-in.
to-report settled-log
  ifelse length attendance-log > 20
    [ report sublist attendance-log 20 length attendance-log ]
    [ report attendance-log ]
end

to-report mean-attendance
  report mean settled-log
end

to-report sd-attendance
  report standard-deviation settled-log
end

to-report share-crowded
  report (length filter [ a -> a > capacity ] settled-log)
    / length settled-log
end
@#$#@#$#@
GRAPHICS-WINDOW
430
10
563
144
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-12
12
-12
12
1
1
1
ticks
30.0

SLIDER
10
10
220
43
ensemble-size
ensemble-size
1
12
6.0
1
1
NIL
HORIZONTAL

SLIDER
10
50
220
83
capacity
capacity
10
90
60.0
1
1
NIL
HORIZONTAL

BUTTON
10
95
110
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
120
95
220
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

PLOT
10
140
420
330
Attendance
week
people
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"attendance" 1.0 0 -16777216 true "" "plot attendance"
"capacity" 1.0 0 -2674135 true "" "plot capacity"

MONITOR
230
10
420
55
mean attendance (after week 20)
mean-attendance
1
1
11
@#$#@#$#@
## WHAT IS IT?

W. Brian Arthur's El Farol bar problem, as described in chapter 4 of Scott E. Page's *The Model Thinker*. One hundred people use ensembles of simple forecasting rules to decide whether to go to a bar that is only fun if at most CAPACITY people attend. Each person follows whichever of their rules would have earned the most so far.

## HOW TO USE IT

Set ENSEMBLE-SIZE (how many rules each person holds), press SETUP, then GO. The plot shows weekly attendance against the capacity.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/el-farol.R.
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
