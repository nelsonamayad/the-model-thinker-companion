; Granovetter's riot model (The Model Thinker, chapter 19).
; The Model Thinker Companion: reference implementation, run with nlrx by
; abm/riot-model.R. The page replays the same rules in JavaScript.
;
; Each of `population` people has a riot threshold: the number of people
; already rioting that it takes for them to join. Thresholds are drawn from a
; normal distribution with mean `mean-threshold` and standard deviation
; `sd-threshold`, rounded to whole numbers and kept at zero or above.
; People with a threshold of zero riot from the start. Each tick, everyone
; whose threshold is at most yesterday's number of rioters joins (and stays).
; The run stops when nobody new joins.

globals [
  rioters          ; number rioting now
]

turtles-own [ threshold rioting? ]

to setup
  clear-all
  create-turtles population [
    set threshold max list 0 round random-normal mean-threshold sd-threshold
    set rioting? threshold = 0
    set shape "circle"
    setxy random-xcor random-ycor
    recolor
  ]
  set rioters count turtles with [ rioting? ]
  reset-ticks
end

to go
  let previous rioters
  ask turtles with [ not rioting? and threshold <= previous ] [
    set rioting? true
    recolor
  ]
  set rioters count turtles with [ rioting? ]
  tick
  if rioters = previous [ stop ]
end

to recolor
  set color ifelse-value rioting? [ red ] [ gray ]
end

to-report riot-share
  report rioters / population
end
@#$#@#$#@
GRAPHICS-WINDOW
250
10
563
324
-1
-1
9.0
1
10
1
1
1
0
0
0
1
-17
17
-17
17
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
10
1000
100.0
10
1
NIL
HORIZONTAL

SLIDER
10
50
230
83
mean-threshold
mean-threshold
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
10
90
230
123
sd-threshold
sd-threshold
0
50
12.0
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
rioting
rioters
0
1
11
@#$#@#$#@
## WHAT IS IT?

Mark Granovetter's threshold model of riots, as described in chapter 19 of Scott E. Page's *The Model Thinker*. People join a riot once enough others have joined; the distribution of thresholds, not just its mean, decides how big the riot gets.

## HOW TO USE IT

Set the population and the mean and spread of thresholds, press SETUP, then GO. The run stops when nobody new joins.

## CREDITS

Written for The Model Thinker Companion (an independent homage to the book). Run as an experiment with nlrx: abm/riot-model.R.
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
