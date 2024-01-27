__includes [
  "initialisation.nls"
  "allocation.nls"
  "power.nls"
  "welfare.nls"
  "output.nls"
]

extensions [csv]

breed [demand-centres demand-centre]
breed [conventionals conventional]
breed [wind-plants windplant]
breed [solar-plants solarplant]

globals [
  n-conventionals
  n-solarplants
  n-windplants

  sum-power-feedin
  total-power-demand

  feedin-solar
  feedin-wind
  feedin-conv

  sum-costs-wind
  sum-costs-solar
  sum-costs-conv
  sum-costs-all

  sum-inv-wind
  sum-inv-solar
  sum-inv-conv
  sum-inv-all

  sum-costs-net
  sum-costs-transition

  alpha-regions
  reg-taboo
  reg-intervention
  fairness

  welfare-region
  welfare-full-region
  welfare-full-reduction

  available-land
  occupied-land

  av-land-reg
  oc-land-reg

  equilibrium-wind
  equilibrium-solar

  replace-wind
  replace-solar

  t-shutdown
  t-mismatch

  mismatch-type
  supply-secure?
  replace-mode?
  coverage

]

patches-own [
  area-number

  y-solar
  y-wind

  y-solar-summer
  y-solar-winter
  epsilon-solar

  y-wind-summer
  y-wind-winter
  epsilon-wind

  wind-plant-capacity
  solar-plant-capacity

  taboo

  g-wind
  g-solar

  transmission-line?
  connected-to-grid?
  dist-to-grid

  net-costs
  net-costs-count?
]

turtles-own [
]

demand-centres-own [
  n-households
  power-demand
  taboo-radius
]

conventionals-own [
  age
  operating-life
  power-rating
  feedin
  feedin-max
]

wind-plants-own [
  age
  operating-life
  power-rating
  feedin
  feedin-max
]

solar-plants-own [
  age
  operating-life
  power-rating
  feedin
  feedin-max
]

to go
  if (ticks = runtime) [
    if (region-statistics?) [
      print-region-statistics
    ]

    if (landscape-statistics?) [
      print-landscape-statistics
    ]
    file-close
    stop
  ]

  if (region-optimisation = false) [
    if (replace-mode? = false) [replace-mode]
  ]

  if (ticks >= 20) [
    if (region-optimisation) [
      if (region-scenario = "regions w-market" or region-scenario = "regions w-full") [
        regional-intervention
      ]
    ]
  ]

  update-meteorology
  calculate-period-profit
  remove-power-plants
  add-power-plants
  calculate-power-demand
  calculate-power-feedin
  calculate-land-use
  update-costs
  update-supply-security
  update-welfare
  update-fairness
  print-to-file
  increase-age
  tick
end

to calculate-land-use
  set av-land-reg []
  set oc-land-reg []
  let i 1
  while [i <= 9] [
    set av-land-reg lput (count patches with [area-number = i and taboo = 0 and not any? wind-plants-here]) av-land-reg
    set oc-land-reg lput (count patches with [area-number = i and any? wind-plants-here]) oc-land-reg
    set i (i + 1)
  ]
  set available-land sum av-land-reg
  set occupied-land sum oc-land-reg
end

to set-reg-taboo [reg-number new-taboo]
  if (reg-number = 1) [set taboo-reg-1 new-taboo]
  if (reg-number = 2) [set taboo-reg-2 new-taboo]
  if (reg-number = 3) [set taboo-reg-3 new-taboo]
  if (reg-number = 4) [set taboo-reg-4 new-taboo]
  if (reg-number = 5) [set taboo-reg-5 new-taboo]
  if (reg-number = 6) [set taboo-reg-6 new-taboo]
  if (reg-number = 7) [set taboo-reg-7 new-taboo]
  if (reg-number = 8) [set taboo-reg-8 new-taboo]
  if (reg-number = 9) [set taboo-reg-9 new-taboo]
end

to-report get-reg-taboo [reg-number]
    if (reg-number = 1) [report taboo-reg-1]
    if (reg-number = 2) [report taboo-reg-2]
    if (reg-number = 3) [report taboo-reg-3]
    if (reg-number = 4) [report taboo-reg-4]
    if (reg-number = 5) [report taboo-reg-5]
    if (reg-number = 6) [report taboo-reg-6]
    if (reg-number = 7) [report taboo-reg-7]
    if (reg-number = 8) [report taboo-reg-8]
    if (reg-number = 9) [report taboo-reg-9]
end

to increase-taboo [reg-number]
  let regional-taboo (get-reg-taboo reg-number)
  if (regional-taboo <= 12)[
    ask demand-centres with [area-number = reg-number] [
      set taboo-radius taboo-radius + 1
      ask patches in-radius taboo-radius with [area-number = reg-number]  [
        if (taboo = 0) [
          set taboo 1
        ]
        set pcolor 8
        if (transmission-line? = true)[
          set pcolor black
        ]
      ]
    ]
    set-reg-taboo reg-number (regional-taboo + 1)
  ]

  ask demand-centres [
    if (any? solar-plants-here) [
      let color-intensity count solar-plants-here
      set color solar-color - (0.2 * color-intensity)
      ask neighbors [set pcolor (solar-color - (0.2 * color-intensity))]
    ]
    set color black
  ]
end

to regional-intervention
  let i 0
  while [i <= 8] [
    if (item i welfare-full-region < 0 and item i n-wind-region > 0) [
      if(ticks - operating-life-wind > item i reg-intervention or item i reg-intervention = 0) [
        increase-taboo (i + 1)
        set reg-intervention replace-item i reg-intervention ticks
      ]
    ]
    set i (i + 1)
  ]
end

to update-meteorology
  ask patches [
    set epsilon-wind precision( random-normal 0 sigma-epsilon-wind ) 2
    set epsilon-solar precision( random-normal 0 sigma-epsilon-solar ) 2

    ifelse ticks mod 2 = 0 [
      set y-wind precision( (y-wind-winter + epsilon-wind) ) 2
      set y-solar precision( (y-solar-winter + epsilon-solar) ) 2
    ][
      set y-wind precision( (y-wind-summer + epsilon-wind) ) 2
      set y-solar precision( (y-solar-summer + epsilon-solar) ) 2
    ]

  ]
end

to calculate-period-profit
  ask patches [
    set g-wind precision( (y-wind * rem-wind) - c-wind - (c-inv-wind / operating-life-wind) - net-costs) 2
    set g-solar precision( (y-solar * rem-solar) - c-solar - (c-inv-solar / operating-life-solar)) 2
  ]

  if (region-scenario = "optimisation w-full" or region-scenario = "regions w-full") [
    let i 1
    while [i <= 9] [
      ask patches with [area-number = i] [
        let reduction item (i - 1) welfare-full-reduction
        set g-wind precision (g-wind - reduction) 2
      ]
      set i (i + 1)
    ]
  ]
end

to update-supply-security
  if (ticks = shutdown-time + 1) [
    set t-shutdown ticks
    set t-mismatch coverage
  ]

  if (ticks >= shutdown-time and supply-secure? = true) [
    calculate-mismatch-type
  ]

  if (total-power-demand > 0) [
    calculate-coverage
  ]
end

to update-welfare
  set welfare-region calculate-welfare-region
  set welfare-full-region calculate-welfare-full-region
end

to update-fairness
  if (ticks >= runtime - 100 and fairness = 1) [
    if (min welfare-full-region < 0) [
      set fairness 0
    ]
  ]
end

to update-costs
  set sum-costs-wind precision( (sum-costs-wind + costs-wind) ) 2
  set sum-costs-solar precision( (sum-costs-solar + costs-solar) ) 2
  set sum-costs-conv precision( (sum-costs-conv + costs-conv) ) 2
  set sum-costs-all (sum-costs-wind + sum-costs-solar + sum-costs-conv)

  set sum-inv-wind precision( (sum-inv-wind + inv-wind) ) 2
  set sum-inv-solar precision( (sum-inv-solar + inv-solar) ) 2
  set sum-inv-conv precision( (sum-inv-conv + inv-conv) ) 2
  set sum-inv-all precision( (sum-inv-wind + sum-inv-solar + sum-inv-conv) ) 2

  set sum-costs-net precision( (sum-costs-net + costs-net) ) 2

  set sum-costs-transition precision( (sum-costs-all + sum-inv-all + sum-costs-net) ) 2
  set sum-costs-transition precision (sum-costs-transition / 1000000) 2
end

to increase-age
  ask (turtle-set wind-plants solar-plants conventionals) [
    set age (age + 1)
  ]
end

to-report costs-wind
  report n-windplants * c-wind
end

to-report costs-solar
  report n-solarplants * c-solar
end

to-report costs-conv
  report n-conventionals * c-conv
end

to-report costs-all
  report costs-wind + costs-solar + costs-conv
end

to-report inv-wind
  report (count wind-plants with [age = 1]) * c-inv-wind
end

to-report inv-solar
  report (count solar-plants with [age = 1]) * c-inv-solar
end

to-report inv-conv
  report (count conventionals with [age = 1]) * c-inv-conv
end

to-report inv-all
  report inv-wind + inv-solar + inv-conv
end

to-report costs-net
  let nc precision( (sum [net-costs] of patches with [count wind-plants-here > 0 and net-costs-count? = false]) ) 2
  ask patches with [count wind-plants-here > 0 and net-costs-count? = false] [set net-costs-count? true]
  report nc
end

to-report costs-transition
  report precision( (costs-all + inv-all + costs-net) ) 2
end

to calculate-coverage
  set coverage precision( (sum-power-feedin * 100 / total-power-demand) ) 1
end

to calculate-mismatch-type
  ifelse (t-mismatch >= 100) [
    set mismatch-type 0
  ][
    let managable-mismatch 90
    ifelse (coverage >= managable-mismatch)
      [set mismatch-type 1]
      [set mismatch-type 2 set supply-secure? false]
  ]
end

to-report disutility-land-consumption
  report (count patches with [any? wind-plants-here])
end

to-report demand-region
  let regiondemand []
  let i 1
  while [i <= 9] [
    set regiondemand lput precision (sum [power-demand] of demand-centres with [area-number = i]) 2 regiondemand
    set i (i + 1)
  ]
  report regiondemand
end

to-report n-dc-region
  let n-dc []
  let i 1
  while [i <= 9] [
    set n-dc lput (count demand-centres with [area-number = i]) n-dc
    set i (i + 1)
  ]
  report n-dc
end

to-report n-wind-region
  let n-wind []
  let i 1
  while [i <= 9] [
    set n-wind lput (count wind-plants with [area-number = i]) n-wind
    set i (i + 1)
  ]
  report n-wind
end

to-report n-solar-region
  let n-solar []
  let i 1
  while [i <= 9] [
    set n-solar lput (count solar-plants with [area-number = i]) n-solar
    set i (i + 1)
  ]
  report n-solar
end

to-report n-renewables-region
  let n-ren []
  let i 1
  while [i <= 9] [
    set n-ren lput (count wind-plants with [area-number = i] + count solar-plants with [area-number = i]) n-ren
    set i (i + 1)
  ]
  report n-ren
end

to-report number-households
  report 5000
end

to-report solar-color
  report 48
end

to-report size-wind
  report 1
end

to-report size-solar
  report 0.5
end

to-report size-conventionals
  report 1.5
end

to-report number-vertical-lines
  report 2
end

to-report nameplate-capacity-wind
  report 3
end

to-report nameplate-capacity-solar
  report 3
end

to-report nameplate-capacity-conv
  report 1000
end

to-report operating-life-conv
  report 100
end

to-report c-inv-wind
  report 1000
end

to-report c-inv-solar
  report 1000
end

to-report c-inv-conv
  report 0
end

to-report availability
  ; 365 days * 24 hours
  report 8760
end

to-report c-conv
  report 5
end

to-report power-price
  report 10
end

to-report wtp
  report 12
end

to-report alpha-landscape
  report 1
end

to-report color-gradient?
  report true
end

to-report sigma-fluctuation
  report 1
end

to-report sigma-epsilon-wind
  report 1
end

to-report sigma-epsilon-solar
  report 1
end

to cancel
  set reg-taboo n-values 9 [global-taboo-radius]
  let i 1
  while [i <= 9] [
    set-reg-taboo i global-taboo-radius
    set i (i + 1)
  ]
  clear-all
  file-close
end

to set-default-parameters
  set runtime 500
  set household-demand 12
  set n-demand-centres 500
  set rem-wind 8
  set rem-solar 8
  set c-wind 5
  set c-solar 6
  set y-wind-max 10
  set y-solar-max 10
  set patch-cap-wind 6
  set patch-cap-solar 8
  set operating-life-wind 50
  set operating-life-solar 50
  set global-taboo-radius 3
  set v-wind 200
  set v-solar 150
  set shutdown-time 40
  set net-costs-weight 1
  set r-alpha 3
  set same-alphas false
  set region-scenario "regions w-market"
  set reg-taboo n-values 9 [global-taboo-radius]
  let i 1
  while [i <= 9] [
    set-reg-taboo i global-taboo-radius
    set i (i + 1)
  ]
end

to save-demand-centres
 carefully [
   file-delete "demand-centres-setup.txt"
 ][
   print "Could not delete file! (demand-centres-setup.txt)"
 ]
 let file-name (word "demand-centres-setup.txt")
 if (not file-exists? file-name) [
    file-open file-name

    ask demand-centres [
      let x-location (word xcor)
      file-print x-location
      let y-location (word ycor)
      file-print y-location
    ]

    file-close
    print "Demand centres setup saved successfully!"
  ]
end

to save-meteorology
 carefully [
   file-delete "meteorology.txt"
 ][
   print "Could not delete file! (meteorology.txt)"
 ]
 let file-name (word "meteorology.txt")
 if (not file-exists? file-name) [
    file-open file-name
    ask patches [
      let x-location (word pxcor)
      file-print x-location
      let y-location (word pycor)
      file-print (word y-location)
      file-print (word y-solar)
      file-print (word y-wind)
      file-print (word y-wind-summer)
      file-print (word y-wind-winter)
      file-print (word y-solar-summer)
      file-print (word y-solar-winter)
      file-print (word epsilon-wind)
      file-print (word epsilon-solar)
    ]
    file-close
    print "Meteorology saved successfully!"
  ]
end

to save-alphas
 carefully [
   file-delete "alphas.txt"
 ][
   print "Could not delete file! (alphas.txt)"
 ]
 let file-name (word "alphas.txt")
 if (not file-exists? file-name) [
    file-open file-name
    file-print alpha-regions
    file-close
    print "Alphas saved successfully!"
  ]
end

to show-layer
  ask patches [
    set pcolor white
    if (taboo = 1) [set pcolor 8]
    if (transmission-line? = true) [set pcolor 0]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
183
10
693
521
-1
-1
3.35
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
149
0
149
1
1
1
ticks
30.0

BUTTON
9
10
64
43
NIL
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
66
10
121
43
NIL
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

SLIDER
8
114
178
147
n-demand-centres
n-demand-centres
0
1000
500.0
1
1
NIL
HORIZONTAL

PLOT
1085
10
1289
134
total power demand
time step
[MWh]
0.0
10.0
0.0
10.0
true
false
"calculate-power-demand\ncalculate-power-feedin" ""
PENS
"Demand" 1.0 0 -2674135 true "" "plot total-power-demand"
"Feed-in" 1.0 0 -7500403 true "" "plot sum-power-feedin"

BUTTON
124
10
179
43
NIL
cancel
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
9
79
178
112
runtime
runtime
0
2000
500.0
1
1
NIL
HORIZONTAL

PLOT
1085
136
1290
263
power feed-in
time step
[MWh]
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"wind" 1.0 0 -13791810 true "" "plot feedin-wind"
"pv" 1.0 0 -16777216 true "" "plot feedin-solar"
"conv" 1.0 0 -6459832 true "" "plot feedin-conv"

INPUTBOX
248
527
320
587
rem-wind
8.0
1
0
Number

INPUTBOX
248
588
321
649
rem-solar
8.0
1
0
Number

INPUTBOX
8
148
177
208
household-demand
12.0
1
0
Number

INPUTBOX
9
211
178
271
global-taboo-radius
3.0
1
0
Number

INPUTBOX
183
527
245
587
c-wind
5.0
1
0
Number

INPUTBOX
325
527
385
587
v-wind
200.0
1
0
Number

INPUTBOX
183
588
245
648
c-solar
6.0
1
0
Number

PLOT
1085
267
1290
396
coverage
time step
[%]
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"match" 1.0 0 -16777216 true "" "plot coverage"

INPUTBOX
325
588
385
648
v-solar
150.0
1
0
Number

INPUTBOX
389
589
491
649
net-costs-weight
1.0
1
0
Number

INPUTBOX
389
527
491
587
shutdown-time
40.0
1
0
Number

CHOOSER
8
436
177
481
demand-centre-setup
demand-centre-setup
"random setup" "load setup" "north" "south" "patchy" "mixed" "mixed2"
0

BUTTON
8
400
176
433
Save Demand Centres
save-demand-centres
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
9
44
179
77
Reset parameters
set-default-parameters
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
6
618
179
651
region-statistics?
region-statistics?
0
1
-1000

SLIDER
184
653
276
686
taboo-reg-1
taboo-reg-1
0
10
13.0
1
1
NIL
HORIZONTAL

SLIDER
277
653
369
686
taboo-reg-2
taboo-reg-2
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
368
653
460
686
taboo-reg-3
taboo-reg-3
0
10
13.0
1
1
NIL
HORIZONTAL

SLIDER
463
653
555
686
taboo-reg-4
taboo-reg-4
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
556
653
648
686
taboo-reg-5
taboo-reg-5
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
647
653
739
686
taboo-reg-6
taboo-reg-6
0
10
13.0
1
1
NIL
HORIZONTAL

SLIDER
743
652
835
685
taboo-reg-7
taboo-reg-7
0
10
11.0
1
1
NIL
HORIZONTAL

SLIDER
836
652
928
685
taboo-reg-8
taboo-reg-8
0
10
11.0
1
1
NIL
HORIZONTAL

SLIDER
927
652
1019
685
taboo-reg-9
taboo-reg-9
0
10
3.0
1
1
NIL
HORIZONTAL

SWITCH
1027
526
1290
559
region-optimisation
region-optimisation
1
1
-1000

PLOT
699
10
1082
224
Total Welfare
time step
total welfare
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"D" 1.0 0 -7858858 true "" "plot sum welfare-full-region"
"0" 1.0 0 -2674135 true "" "plot 0"
"M" 1.0 0 -13791810 true "" "plot sum welfare-region"
"H1" 1.0 0 -5987164 true "" "plot 1000"
"H2" 1.0 0 -5987164 true "" "plot 2000"
"H3" 1.0 0 -5987164 true "" "plot 3000"
"H4" 1.0 0 -5987164 true "" "plot 4000"
"H5" 1.0 0 -5987164 true "" "plot 5000"

CHOOSER
1026
565
1291
610
region-scenario
region-scenario
"optimisation w-market" "optimisation w-vwl" "regions w-market" "regions w-vwl"
2

PLOT
700
225
1082
454
Regional Welfares
time step
regional welfare
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"0" 1.0 0 -2674135 true "" "plot 0\n"
"R1" 1.0 0 -3508570 true "" "plot item 0 welfare-full-region\n"
"R2" 1.0 0 -955883 true "" "plot item 1 welfare-full-region\n"
"R3" 1.0 0 -6459832 true "" "plot item 2 welfare-full-region\n\n"
"R4" 1.0 0 -1184463 true "" "plot item 3 welfare-full-region\n"
"R5" 1.0 0 -10899396 true "" "plot item 4 welfare-full-region\n"
"R6" 1.0 0 -13840069 true "" "plot item 5 welfare-full-region\n"
"R7" 1.0 0 -14835848 true "" "plot item 6 welfare-full-region"
"R8" 1.0 0 -11221820 true "" "plot item 7 welfare-full-region\n"
"R9" 1.0 0 -13791810 true "" "plot item 8 welfare-full-region\n"
"H1" 1.0 0 -5987164 true "" "plot 1000"
"H2" 1.0 0 -5987164 true "" "plot 500"

INPUTBOX
1026
460
1081
520
r-alpha
3.0
1
0
Number

MONITOR
700
458
758
507
R1
item 0 alpha-regions
17
1
12

MONITOR
758
458
816
507
R2
item 1 alpha-regions
17
1
12

MONITOR
816
458
873
507
R3
item 2 alpha-regions
17
1
12

MONITOR
700
510
758
559
R4
item 3 alpha-regions
17
1
12

MONITOR
758
510
816
559
R5
item 4 alpha-regions
17
1
12

MONITOR
816
510
873
559
R6
item 5 alpha-regions
17
1
12

MONITOR
700
561
758
610
R7
item 6 alpha-regions
17
1
12

MONITOR
758
561
816
610
R8
item 7 alpha-regions
17
1
12

MONITOR
816
561
873
610
R9
item 8 alpha-regions
17
1
12

BUTTON
879
459
1018
492
Save Alphas
save-alphas
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
879
496
1019
529
load-alphas
load-alphas
0
1
-1000

SWITCH
879
534
1019
567
same-alphas
same-alphas
1
1
-1000

SWITCH
879
574
1018
607
read-alpha
read-alpha
1
1
-1000

BUTTON
7
581
177
614
Save Meteorology
save-meteorology\nsave-alphas\nset load-alphas true
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
7
546
178
579
load-meteorology
load-meteorology
1
1
-1000

SWITCH
879
614
1018
647
load-permutation
load-permutation
1
1
-1000

SLIDER
700
614
873
647
p-number
p-number
1
512
217.0
1
1
NIL
HORIZONTAL

INPUTBOX
496
528
576
588
y-wind-max
10.0
1
0
Number

INPUTBOX
496
589
576
649
y-solar-max
10.0
1
0
Number

INPUTBOX
580
588
693
648
patch-cap-solar
8.0
1
0
Number

INPUTBOX
581
526
693
586
patch-cap-wind
6.0
1
0
Number

SWITCH
7
654
178
687
landscape-statistics?
landscape-statistics?
0
1
-1000

INPUTBOX
9
336
178
396
operating-life-wind
50.0
1
0
Number

INPUTBOX
9
273
178
333
operating-life-solar
50.0
1
0
Number

SWITCH
1025
615
1289
648
heterogenous-regions?
heterogenous-regions?
1
1
-1000

PLOT
1084
400
1289
520
Land consumption
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"O" 1.0 0 -13345367 true "" "plot occupied-land"
"A" 1.0 0 -7500403 true "" "plot available-land"

INPUTBOX
8
484
178
544
seed
42.0
1
0
Number

SWITCH
1025
653
1290
686
multi-temp-outputs?
multi-temp-outputs?
1
1
-1000

@#$#@#$#@
## About

ELAN (Energy LANdscape) is a stylised and rule-based simulation model.


## License

MIT License

Copyright (c) 2023 Henning Nolzen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
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

dashed
0.0
-0.2 0 0.0 1.0
0.0 1 4.0 4.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
