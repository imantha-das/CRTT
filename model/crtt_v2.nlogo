;                          ++++      +       ++++   +  +   +     +++++  +   +          +++++   ++++   ++++   ++++  +   +    ++++
;                          +        + +      +      +  +   +       +     + +           +   +   +      +      +     +   +    +
;                          +       + + +     ++++   +  +   +       +      +            + +     ++++   ++++   +     +   +    ++++
;                          +      +     +       +   +  +   +       +      +            + +     +         +   +     +   +    +
;                          ++++  +       +   ++++   ++++   ++++    +      +            +   +   ++++   ++++   ++++  +++++    ++++
;
;
;                                                          +++++   +++++   ++++       +     +++++   +     +    ++++    +      +   +++++
;                                                            +     +   +   +         + +      +     + + + +    +       + +    +     +
;                                                            +     + +     ++++     + + +     +     +  +  +    ++++    +   +  +     +
;                                                            +     +  +    +       +     +    +     +     +    +       +    + +     +
;                                                            +     +   +   ++++   +       +   +     +     +    ++++    +      +     +
;
;
;                                                                                            +       +     +   +++++
;                                                                                           + +      + +   +   +    +
;                                                                                          + + +     +  +  +   +     +
;                                                                                         +     +    +   + +   +    +
;                                                                                        +       +   +     +   +++++
;
;
;                                                                                                    +++++   +++++       +       +     +   ++++   +++++   +++++   +++++   +++++
;                                                                                                      +     +   +      + +      + +   +   +      +   +   +   +   +  +      +
;                                                                                                      +     + +       + + +     +  +  +   ++++   +++++   +   +   + +       +
;                                                                                                      +     +  +     +     +    +   + +      +   +       +   +   +  +      +
;                                                                                                      +     +   +   +       +   +     +   ++++   +       +++++   +   +     +
;
;
;                                                                                                                        Model developed by the Volcanic Hazard and Risk Group
;                                                                                                                                at the Earth Observatory of Singapore
;
;
; _________________________________________________________________________________________________________________________________________________________________________________________

extensions [gis nw py]
globals [
  ;general
  G-target-agent G-target-node avg-time
  ;gis
  guo-boundary guo-impactzone guo-roads guo-routier guo-pop guo-PMA-Hosp-Airpt Net-Gis-Convfac Gis-Net-Convfac
  ;lists

  ;lists
  Recovered-TS1 Recovered-time-TS1 Decd-Queue-TS2 Decd-Queue-Time-TS2 Decd-Queue-TS3 Decd-Queue-Time-TS3 Decd-stabilise-TS2 Decd-stabilise-Time-TS2
  Decd-stabilise-TS3 Decd-stabilise-Time-TS3 Decd-Transfer-Hosp-TS3 Decd-Transfer-Hosp-TS2 Decd-Transfer-Hosp-Time-TS3 Decd-Transfer-Hosp-time-TS2 Decd-BB-TS2 Decd-BB-Time-TS2 Decd-BB-TS3 Decd-BB-Time-TS3 Decd-NBB-TS2 Decd-NBB-Time-TS2 Decd-NBB-TS3 Decd-NBB-Time-TS3
  Decd-Hosp-Q-TS2 Decd-Hosp-Q-time-TS2 Decd-Hosp-Q-TS3 Decd-Hosp-Q-Time-TS3 Decd-AwaResc-TS2 Decd-AwaResc-Time-TS2 Decd-AwaResc-TS3 Decd-AwaResc-Time-TS3
  Decd-OnRout-PMA-TS2 Decd-OnRout-PMA-Time-TS2 Decd-OnRout-PMA-TS3 Decd-OnRout-PMA-Time-TS3 Decd-OnRout-Hosp-TS2 Decd-OnRout-Hosp-Time-TS2 Decd-OnRout-Hosp-TS3
  Decd-OnRout-Hosp-Time-TS3


]
;*********************************************************************************************************************************************************************************************************************************************************************
;TYPE OF AGENTS
;PRIMARY AGENTS:

;Casualties
breed [cas-agents cas-agent] ; Casualty Agent

;Medically Equpped Vehicles
breed [resc-agents-A resc-agent-A]; Rescue Agent (Type A)
breed [resc-agents-B resc-agent-B];  Rescue Agent (Type B)
breed [heli-agents heli-agent]; Helicopter

;Treatment Facilities
breed [PMA's PMA]; Field Triage
breed [Hospitals Hospital] ; Hospital

;Transport Network
breed [nodes node];  Nodes (constructed at verties of imported GIS polylines), Allow Rescue agents to travel along the network
;links :  Included within Netlgogo (not needed to declare), connects nodes
;patches: Include within Netlogo, used to allow helicopters to travels as well as for visual representation of queues

;SECONDARY AGENTS:

breed [Helipad's Helipad] ; Airport for the purposes of illustration and start and end points of helicopter rescue
breed [volcanoes volcano] ; dummy-agent for the purpose of illustration only
breed [pma-hosp-heli-nodes pma-hosp-heli-node] ;dummy-agent for the purpose of identifying the locations of PMA, hospital & helipad
breed [pop-nodes pop-node] ; dummy-agent for identifying the location of casualties
breed [dummy-agents dummy-agent] ;dummy-agent for the purposes of labeling only.

;*********************************************************************************************************************************************************************************************************************************************************************
;AGENT OWN VARIABLES:
;PRIMARY AGENT OWN VARIABLES:

;Casualties
cas-agents-own [node-pop patch-pop targeted? targeted-by targeted-transfer? targeted-transfer-by TS PMA-at PMA-name PMA-at-node
  on-route-PMA-time queue-time stabilise-time transfer-hosp-time on-route-hospital-time BB-admission-time NBB-admission-time Hospital-Queue-Time recovered-time deceased-time
  Rescue-by-Helicopter? Rescue-by-resc-agent-B? awaiting-rescue?  on-route-PMA? in-queue? in-stabilisation? transfer-hosp?
  on-route-hospital? recovered? in-Burn-beds? in-Non-Burn-Beds? in-Hospital-Queue? random-death? Deceased? treated?]

;Medically Equiped Vehicles
resc-agents-A-own [node-resc target-agent node-agent-at target-transfer-agents  Mode case-commute case-pma route-length next-pos current-pos current-node next-node
  distance-to-next-node remaining-distance rem-fm-prev-run commute-path list-of-distances list-of-time list-of-m-distances rescued-agents-list transfer-hosp-TS2-ls transfer-hosp-TS3-ls
rescue-time transfer-time]

resc-agents-B-own [node-resc target-agent node-agent-at Mode case-commute case-pma route-length next-pos current-pos current-node next-node
  distance-to-next-node remaining-distance rem-fm-prev-run commute-path list-of-distances list-of-time list-of-m-distances transfer-hosp-TS2-ls transfer-hosp-TS3-ls
  Transfer-Time other-pma-activate-t]

heli-agents-own [Mode case-commute helipad-patch pma-patch current-patch patch-agent-at target-agent distance-to-target remaining-distance  Rescued-Agents-List collected-agents-TS2 collected-agents-TS3
  list-of-distances list-of-time list-of-m-distances rescue-time transfer-time ]

;Treatment Facilities
PMA's-own [nid node-PMA PMA-capacity Queue-TS1 Queue-t-TS1 Queue-TS23 Queue-t-TS23 stabilise-TS1 stabilise-t-TS1 stabilise-TS23 stabilise-t-TS23
  to-be-hospitalised-t-TS23 transfer-hosp-q-TS2 transfer-hosp-q-t-TS2 transfer-hosp-q-TS3 transfer-hosp-q-t-TS3]

hospitals-own [nid node-hosp Burn-Beds-TS2 Burn-Beds-Time-TS2 Burn-Beds-TS3 Burn-Beds-Time-TS3 Non-Burn-Beds-TS2 Non-Burn-Beds-time-TS2 Non-Burn-Beds-TS3 Non-Burn-Beds-Time-TS3
  Hospital-Queue-TS2 Hospital-Queue-Time-TS2 Hospital-Queue-TS3 Hospital-Queue-Time-TS3]

;Transport Network
nodes-own [linked-to  cas-agent-present-TS1 Count-TS1 cas-agent-present-TS23 count-TS23 PMA-present Hospital-present]
links-own [netlogo-dist]


;SECONDARY AGENT OWN VARIABLES:
Helipad's-own [nid site]
volcanoes-own [nid site]
pma-hosp-heli-nodes-own [ntype nid]
pop-nodes-own [TS1-count TS2-count TS3-count]
dummy-agents-own [used-up?]



;________________________________________________________________________________________________________________ MAIN SETUP PROCEDURE ______________________________________________________________________________________________________________________________________
to setup
  clear-all

  setup-gis
  setup-road-nodes&links
  setup-PMA-Hosp-heli
  setup-population
  setup-resc-agents-A

  if resc-agent-A-only = false [
    setup-resc-agents-B
  ]
  setup-visual-queue
  setup-labels

  if heli-rescue? = True [
   setup-helicopter
  ]
end
;_______________________________________________________________________________________________________________ END MAIN SETUP PROCEDURE _______________________________________________________________________________________________________________________________

; __________________________________________________________________________________________________________________ SETUP FUNCTION ___________________________________________________________________________________________________________________________________


; ------------------------------------------------------------------------------------------------- SETUP-GIS : LOADS GIS FILES INTO NETLOGO ENVIRONMENT -------------------------------------------------------------------------------------------------------------
to setup-gis
  ; setups the interface coordinates

  set-patch-size 1
  let max-px 780
  let min-px 0
  let max-py 780
  let min-py 0
  resize-world min-px max-px min-py max-py

  set-current-directory "/Users/imantha/workspace/github/CRTT/model"

  ;declare global variables for each of the shapefiles and draw
  set guo-boundary gis:load-dataset "inputs/gis/Gudaloupe_boundary.shp"
  gis:set-drawing-color 5
  gis:fill guo-boundary 1.0

  set guo-impactzone gis:load-dataset "inputs/gis/LaSoufrière_ImpactZones.shp"
  gis:set-drawing-color 6
  gis:fill guo-impactzone 1.0

  set guo-roads gis:load-dataset "inputs/gis/Primaryrds_EPSG36320.shp"

  set guo-PMA-Hosp-Airpt gis:load-dataset "inputs/gis/PMA_and_Hospital_Airport_Volcano_Nodes_EPSG36320.shp"

  set guo-pop gis:load-dataset "inputs/gis/PDC_Humans_default.shp"

  ;for viewing only, to switch world-envelope : NOTE - DISTANCES CHANGE
  gis:set-world-envelope gis:envelope-of guo-boundary
  gis:set-transformation-ds (gis:envelope-of guo-boundary)(list (min-px) (max-px) (min-py) (max-py))

  set avg-time 60
  reset-ticks
  ;tick-advance 60
end

;--------------------------------------------------------------------------- SETUP-ROAD-NODES-AND-LINKS : CONSTRUCT NODES AT VERTICES OF POLYLINES, CONNECTS NODES THROUGH LINKS -------------------------------------------------------------------------------------
to setup-road-nodes&links
  let dist-list []

  foreach gis:feature-list-of guo-roads[

    i ->
    let dist_m gis:property-value i "DISTANCE"
    set dist-list lput dist_m dist-list

    foreach gis:vertex-lists-of i[
      j ->

      let first-node-point nobody
      let previous-node-point nobody

      foreach j[
        k ->
        let location gis:location-of k
        if not empty? location [
          ifelse any? nodes with [xcor = item 0 location and ycor = item 1 location]
          []
          [
            create-nodes 1[
              set xcor item 0 location
              set ycor item 1 location
              set size 2.99
              set shape "circle"
              set color green
              set hidden? True
              set PMA-present nobody
            ]
          ]
  ;to create links

          let node-here (nodes with [xcor = item 0 location and ycor = item 1 location])
          ifelse previous-node-point = nobody
          [set first-node-point node-here]
          [let who-node 0
            let who-prev 0
            ask node-here
            [create-link-with previous-node-point
              set who-node who]
            ask previous-node-point[
              set who-prev who
            ]
          ]
          set previous-node-point one-of node-here
        ]
      ]
    ]
  ]

  let netlogo-dist-list []
  ask links[
    let end-point-1 end1
    let end-point-2 end2
    let link-distance 0

    ask end1[set linked-to end-point-2
      set link-distance precision (distance end-point-2) 3
    ]
    ask end2[
      set linked-to end-point-1]

    set color 3
    set netlogo-dist link-distance
    set netlogo-dist-list fput netlogo-dist netlogo-dist-list
  ]


;1 METER in NETLOGO UNITS
  set Net-Gis-Convfac precision ((sum dist-list) / (sum netlogo-dist-list)) 4
  set Gis-Net-Convfac precision ((sum netlogo-dist-list) / (sum dist-list)) 4

end

;------------------------------------------------------------------------------- SETUP-PMA-HOSP-HELI : CREATE AGENTS FOR PMA, HOSPITAL AND HELIPAD AT THE SPECIFIED LOCATIONS FROM THE GIS FILE ----------------------------------------------------------------------
to setup-PMA-Hosp-heli
  foreach gis:feature-list-of guo-PMA-Hosp-Airpt[
    i ->
    let copy-ntypes gis:property-value i "NTYPE"
    let copy-nid gis:property-value i "NID"

    foreach gis:vertex-lists-of i[
      j ->

      foreach j[
        k ->
        let location gis:location-of k
        if not empty? location
        [
          create-pma-hosp-heli-nodes 1[
            set xcor item 0 location
            set ycor item 1 location
            set size 0
            set ntype copy-ntypes
            set nid copy-nid
          ]
        ]
      ]
    ]
  ]
  ask pma-hosp-heli-nodes with [ntype = "PMA"] [
    hatch-PMA's 1 [
      set shape "PMA-shape"
      set size 19.5 ;size (1.5 x 13)
      set nid [nid] of myself
      move-to min-one-of nodes in-radius 5 [distance myself]
      set node-PMA min-one-of nodes in-radius 0.0001 [distance myself]
      ask node-PMA [set PMA-present myself]
      set Queue-TS1 []
      set Queue-t-TS1 []
      set Queue-TS23 []
      set Queue-t-TS23 []
      set stabilise-TS1 []
      set stabilise-t-TS1 []
      set stabilise-TS23 []
      set stabilise-t-TS23 []
      set transfer-hosp-q-TS2 []
      set transfer-hosp-q-TS3 []
      set transfer-hosp-q-t-TS2 []
      set transfer-hosp-q-t-TS3 []
    ]
  ]
  ask pma-hosp-heli-nodes with [ntype = "Hospital"][
   hatch-hospitals 1 [
      set shape "hospital-shape"
      set size 22.75 ; (1.75 x 13)
      set nid [nid] of myself
      move-to min-one-of nodes in-radius 5 [distance myself]
      set node-hosp min-one-of nodes in-radius 0.0001 [distance myself]
      set Burn-Beds-TS2 []
      set Burn-Beds-Time-TS2 []
      set Burn-Beds-TS3 []
      set Burn-Beds-Time-TS3 []
      set Non-Burn-Beds-TS2 []
      set Non-Burn-Beds-Time-TS2 []
      set Non-Burn-Beds-TS3 []
      set Non-Burn-Beds-Time-TS3 []
      set Hospital-Queue-TS2 []
      set Hospital-Queue-Time-TS2 []
      set Hospital-Queue-TS3 []
      set Hospital-Queue-Time-TS3 []
    ]
  ]
  ask pma-hosp-heli-nodes with [ntype = "Airport"][
    hatch-helipad's 1[
      set shape "Helipad"
      set size 22.75 ; (1.75 x 13)
      set nid [nid] of myself
      set site patch-here
    ]
  ]
  ask pma-hosp-heli-nodes with [ntype = "Volcano"][
    hatch-volcanoes 1[
     set shape "volcano"
     set size 30
      set nid[nid] of myself
      set site patch-here
    ]
  ]
end

;--------------------------------------------------------------------------------------------------------------- SETUP-POPULATION : LOAD POULATON NUMBERS FROM.SHP FILE -------------------------------------------------------------------------------------------
to setup-population

  foreach gis:feature-list-of guo-pop[
    i ->

    let copy-TS1 gis:property-value i "TS1"
    let copy-TS2 gis:property-value i "TS2"
    let copy-TS3 gis:Property-value i "TS3"

    foreach gis:vertex-lists-of i[
      j ->

      foreach j[
        k ->
        let location gis:location-of k
        if not empty? location
        [
          create-pop-nodes 1 [
            set xcor item 0 location
            set ycor item 1 location
            set size 13.0 ; size 1 x 13
            set TS1-count copy-TS1
            set TS2-count copy-TS2
            set TS3-count copy-TS3
            set hidden? True
          ]
        ]
      ]
    ]
  ]

  ask pop-nodes[
    hatch-cas-agents TS1-count [
      set color 44
      set shape "person"
      set size 9.75 ; 0.75 x 13
      set TS 1
      set patch-pop patch-here
      set hidden? false
      set targeted? false
      set targeted-by nobody
      set Rescue-by-Helicopter? false
      set Rescue-by-resc-agent-B? false
      set awaiting-rescue? true
      set on-route-PMA? false
      set in-queue? false
      set in-stabilisation? false
      set recovered? false
      set Deceased? false
      set treated? false
    ]

    hatch-cas-agents TS2-count [
      set color 24
      set shape "person"
      set size 9.75 ;size 0.75 x 13
      set TS 2
      set patch-pop patch-here
      set hidden? false
      set targeted? false
      set targeted-by nobody
      set targeted-transfer? false
      set targeted-transfer-by nobody
      set Rescue-by-Helicopter? false
      set Rescue-by-resc-agent-B? false
      set awaiting-rescue? true
      set on-route-PMA? false
      set in-queue? false
      set in-stabilisation? false
      set transfer-hosp? false
      set on-route-hospital? false
      set recovered? false
      set in-Burn-beds? false
      set in-Non-Burn-Beds? false
      set in-Hospital-Queue? false
      set random-death? false
      set Deceased? false
      set treated? false
    ]

    hatch-cas-agents TS3-count [
      set color 13
      set shape "person"
      set size 9.75 ;size 0.75 x 13
      set TS 3
      set patch-pop patch-here
      set hidden? false
      set targeted? false
      set targeted-by nobody
      set targeted-transfer? false
      set targeted-transfer-by nobody
      set Rescue-by-Helicopter? false
      set Rescue-by-resc-agent-B? false
      set awaiting-rescue? true
      set on-route-PMA? false
      set in-queue? false
      set in-stabilisation? false
      set transfer-hosp? false
      set on-route-hospital? false
      set recovered? false
      set in-Burn-beds? false
      set in-Non-Burn-Beds? false
      set in-Hospital-Queue? false
      set random-death? false
      set Deceased? false
      set treated? false
  ]
  ]

  ;distribure cas-agents to any one of the closest vertex based on gis file
  ask cas-agents[
    ifelse any? nodes in-radius 0.65[ ; changed from 0.05 to 0.05 x 13
      move-to one-of nodes in-radius 0.65
      set node-pop min-one-of nodes in-radius 0.00001 [distance myself]
    ]
    [
      move-to one-of nodes in-radius 13 ; changed from 1 to 1 x 13
      set node-pop min-one-of nodes in-radius 0.00001 [distance myself]
    ]
  ]

  ;ask nodes to store the number of population agents on each node
  ask nodes[
    set cas-agent-present-TS1 cas-agents with [TS = 1] in-radius 0.0001
    set cas-agent-present-TS23 cas-agents with [TS = 2 or TS = 3] in-radius 0.0001
  ]

end

;----------------------------------------------------------------------------------------------------------- SETUP-resc-agents-A : SETUP RESCUE AGENTS (resc-agent-B - TYPE A) ------------------------------------------------------------------------------------------------------------

to setup-resc-agents-A
  create-resc-agents-A no-resc-agent-A[
    set shape "resc-agent-A-shape"
    set size 16.25 ;size 1.25 x 13
    move-to one-of nodes with [PMA-present != nobody]

    set node-resc min-one-of nodes in-radius 0.0001 [distance myself]
    set mode "Searching !!!"
    set case-pma "NA"
    set list-of-distances []
    set list-of-time []
    set list-of-m-distances []
    set rescued-agents-list []
    set transfer-hosp-TS2-ls []
    set transfer-hosp-TS3-ls []
    set target-agent nobody
    set target-transfer-agents nobody
    set rescue-time rescue-time-mins
    set transfer-time transfer-time-mins
  ]

end

to setup-resc-agents-B

  create-resc-agents-B no-resc-agent-B[
    set shape "resc-agent-B-shape"
    set size 16.25
    set mode "(B) At PMA"
    set list-of-distances []
    set list-of-time []
    set list-of-m-distances []
    set transfer-hosp-TS2-ls []
    set transfer-hosp-TS3-ls []
    set target-agent nobody
    set node-resc nobody
    set transfer-time transfer-time-mins
    set other-pma-activate-t 60
  ]


  let temp-count ceiling no-resc-agent-B / 2
  let vh-pma-node reduce sentence [node-pma] of PMA's with [nid = "Vieux Habitants PMA"]
  let sm-pma-node reduce sentence [node-pma] of PMA's with [nid = "Sainte Marie PMA"]
  let vh-pma reduce sentence[self] of PMA's with [nid = "Vieux Habitants PMA"]
  let sm-pma reduce sentence [self] of PMA's with [nid = "Sainte Marie PMA"]

  ask n-of temp-count resc-agents-B [
    set node-resc vh-pma-node
    set target-agent vh-pma
    set node-agent-at vh-pma-node
    move-to node-resc
  ]

  ask resc-agents-B with [node-resc = nobody][
    set node-resc sm-pma-node
    set target-agent sm-pma
    set node-agent-at sm-pma-node
    move-to node-resc
  ]



end

to increment-rescue-agents
  create-resc-agents-A Increase-Rescue-Agents[
    set shape "resc-agent-A-shape"
    set size 16.25 ;size 1.25 x 13
    move-to one-of nodes with [PMA-present != nobody]

    set node-resc min-one-of nodes in-radius 0.0001 [distance myself]
    set mode "Searching !!!"
    set case-pma "NA"
    set list-of-distances []
    set list-of-time []
    set list-of-m-distances []
    set rescued-agents-list []
    set transfer-hosp-TS2-ls []
    set transfer-hosp-TS3-ls []
    set target-agent nobody
    set target-transfer-agents nobody
    set rescue-time rescue-time-mins
    set transfer-time transfer-time-mins
  ]
end

;--------------------------------------------------------------------------------------------------------------- SETUP-HELICOPTER : SETUP RECUE AGENTS (HELIOPTER) ----------------------------------------------------------------------------------------------------

to setup-helicopter
  create-heli-agents no-heli-agent[
    set shape "Helicopter"
    set color red
    set size 22.75 ;size 1.75 x 13
    let hosp-loc [patch-here] of hospitals with[nid = "PtP Hospital"]
    ;set hospital-patch item 0 hosp-loc
    set pma-patch 0
    let heli-loc [site] of helipad's with [nid = "PtP Airport"]
    set helipad-patch item 0 heli-loc
    set current-patch patch-here
    move-to helipad-patch

    set target-agent nobody
    set Mode "Searching !!!"
    set list-of-distances []
    set list-of-time []
    set list-of-m-distances []
    set Rescued-Agents-list []
    set collected-agents-TS2 []
    set collected-agents-TS3 []
    set rescue-time rescue-time-mins
    set transfer-time transfer-time-mins
  ]
end

;---------------------------------------------------------------------------------------------------------------- SETUP-VISUAL-QUEUE : VISUALIZATION BOXES ------------------------------------------------------------------------------------------------------------

to setup-visual-queue
    ;create patches that will represent the queue and stabilisation. When pop agents are added to the queue/stabilisation lists, they are moved to the respective patches
   ask patches with [pxcor >= 460 and pxcor < 540 and pycor >= 0 and pycor <= 80][
    set pcolor 125 ; on-Route-PMA (540,620), (0,80) +++
    ]

  ; VH - PMA : Queue/Stabilisation/Transfer
  ask patches with [pxcor >= 540 and pxcor < 620 and pycor >= 0 and pycor <= 80][
    set pcolor 54 ;VH-Queue (620,700), (0,80) -- 55 +++
  ]
  ask patches with [pxcor >= 620 and pxcor <= 700 and pycor >= 0 and pycor <= 80][
    set pcolor 55 ; VH-Stabalising (700,780), 90,80) -- 54 +++
    ]
  ask patches with [pxcor >= 700 and pxcor <= 780 and pycor >= 0 and pycor <= 80][
    set pcolor 56;VH-awaiting-transfer (700,780), (80,160) --64 +++
  ]

  ;SM -PMA : Queue/Stabilisation//transfer
  ask patches with [pxcor >= 540 and pxcor < 620 and pycor >= 80 and pycor <= 160][
    set pcolor 64 ;SM-Queue (620,700), (0,80) -- 55 +++
  ]
  ask patches with [pxcor >= 620 and pxcor <= 700 and pycor >= 80 and pycor <= 160][
    set pcolor 65 ; Sm-Stabalising (700,780), 90,80) -- 54 +++
    ]
  ask patches with [pxcor >= 700 and pxcor <= 780 and pycor >= 80 and pycor <= 160][
    set pcolor 66;SM awaiting transfer(700,780), (80,160) --64 +++
  ]

  ask patches with [pxcor >= 460 and pxcor < 540 and pycor > 80 and pycor <= 160][
    set pcolor 25;On-Route-Hosp-Resc (620,700), (80,160) --25
  ]
  ask patches with [pxcor >= 460 and pxcor < 540 and pycor > 160 and pycor <= 240][
    set pcolor 34 ; on-Route-Hosp-heli (540,620), (80,160) --34 +++
    ]
  ask patches with [pxcor >= 540 and pxcor < 620 and pycor > 160 and pycor <= 240][
    set pcolor 84 ; Hospital-Queue (540, 620), (160,240) --84
    ]
  ask patches with[pxcor >= 700 and pxcor <= 780 and pycor > 160 and pycor <= 320][
    set pcolor 95;NBB (700, 780), (160, 320) --95
  ]
  ask patches with[pxcor >= 620  and pxcor < 700 and pycor > 240 and pycor <= 320][
    set pcolor 94;BB (620, 700), (240,320) --94
  ]
  ask patches with[pxcor >= 380 and pxcor < 620 and pycor  > 240 and pycor <= 320][
   set pcolor 14 ;TS1 Recovered (380, 620), (240, 320) --14
  ]
  ask patches with[pxcor >= 620 and pxcor <= 700 and pycor  > 160 and pycor <= 240][
   set pcolor 94 ;Hospital Queue (620,700) (160,240) --94
  ]
  ask patches with[pxcor >= 380 and pxcor < 460 and pycor >= 0 and pycor <= 240][
    set pcolor 4 ;Deceased (380, 540) (0,240) --4
  ]

  ; Labelling
  ask patches with [pxcor = 535 and pycor = 40] [set plabel "On Route PMA"]

  ; VH PMA : Labels
  ask patches with [pxcor = 598 and pycor = 40] [set plabel "VH PMA"]
  ask patches with [pxcor = 595 and pycor = 30] [set plabel "Queue"]

  ask patches with [pxcor = 678 and pycor = 40] [set plabel "VH PMA"]
  ask patches with [pxcor = 688 and pycor = 30] [set plabel "Stabalising"]

  ask patches with [pxcor = 761 and pycor = 45][set plabel "VH PMA"]
  ask patches with [pxcor = 763 and pycor = 35][set plabel "awaiting"]
  ask patches with [pxcor = 762 and pycor = 25][set plabel "transfer"]

  ;SM PMA Labels
  ask patches with [pxcor = 598 and pycor = 120] [set plabel "SM PMA"]
  ask patches with [pxcor = 595 and pycor = 110] [set plabel "Queue"]

  ask patches with [pxcor = 678 and pycor = 120] [set plabel "SM PMA"]
  ask patches with [pxcor = 688 and pycor = 110] [set plabel "Stabalising"]

  ask patches with [pxcor = 761 and pycor = 125][set plabel "SM PMA"]
  ask patches with [pxcor = 763 and pycor = 115][set plabel "awaiting"]
  ask patches with [pxcor = 762 and pycor = 105][set plabel "transfer"]

  ask patches with [pxcor = 534 and pycor = 120] [set plabel "On Route Hosp"]
  ask patches with [pxcor = 515 and pycor = 105] [set plabel "(Resc)"]


  ;ask patches with [pxcor = 615 and pycor = 125][set plabel "On Route Hosp"]
  ;ask patches with [pxcor = 610 and pycor = 115][set plabel "(resc-agent-B)"]

  ask patches with [pxcor = 535 and pycor = 200][set plabel "On Route PMA"]
  ask patches with [pxcor = 515 and pycor = 185][set plabel "(Heli)"]

  ask patches with [pxcor = 775 and pycor = 240][set plabel "Non Burn Beds"]
  ask patches with [pxcor = 680 and pycor = 240][set plabel "Burn Beds"]
  ask patches with [pxcor = 615 and pycor = 200][set plabel "Hospital Queue"]
  ask patches with [pxcor = 540 and pycor = 280][set plabel "TS1 Recovered"]
  ask patches with [pxcor = 440 and pycor = 120][set plabel "Deceased"]

end

;------------------------------------------------------------------------------------------------------------------ SETUP LABELS : LABELLING -------------------------------------------------------------------------------------------------------------------------

to setup-labels
  create-dummy-agents 5[
   set used-up? False
   set size 20
   set shape "dot"
  ]

  let temp-node-hosp [node-hosp] of hospitals with [nid = "PtP Hospital"]
  let temp-site-heli [site] of helipad's with [nid = "PtP Airport"]
  let temp-node-SM-PMA [node-pma] of PMA's with [nid = "Sainte Marie PMA"]
  let temp-node-VH-PMA [node-pma] of PMA's with [nid = "Vieux Habitants PMA"]
  let temp-site-volcano [site] of volcanoes with [nid = "La Grande Soufrière"]

  ask one-of dummy-agents with [used-up? = False][
    move-to item 0 temp-node-hosp
    set used-up? True
    set label "Pointe a Pitre Hospital"
    set xcor (xcor + 45)
    set ycor (ycor + 15)
    set size 0
  ]
  ask one-of dummy-agents with [used-up? = False][
    move-to item 0 temp-site-heli
    set used-up? True
    set label "Pointe a Pitre Airport"
    set xcor (xcor + 42)
    set ycor (ycor - 18)
    set size 0
  ]
  ask one-of dummy-agents with [used-up? = False][
    move-to item 0 temp-node-SM-PMA
    set used-up? True
    set label "Sainte Marie PMA"
    set xcor (xcor + 33)
    set ycor (ycor + 15)
    set size 0
  ]
    ask one-of dummy-agents with [used-up? = False][
    move-to item 0 temp-node-VH-PMA
    set used-up? True
    set label "Vieux Habitants PMA"
    set xcor (xcor + 43)
    set ycor (ycor + 15)
    set size 0
  ]
  ask one-of dummy-agents with [used-up? = False][
    move-to item 0 temp-site-volcano
    set used-up? True
    set label "La Grande Soufrière"
    set xcor (xcor + 43)
    set ycor (ycor + 15)
    set size 0
  ]
end


;_________________________________________________________________________________________________________________________ END SETUP FUNCTIONS _______________________________________________________________________________________________________________________

;_________________________________________________________________________________________________________________________ GO MAIN PROCEDURE ______________________________________________________________________________________________________________________________

to go

  if ticks >= 0 and ticks <= 7200[


    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Resc-Agent-A Functions

    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A rescue) Increment Rescue Agents, only if set in the interface
    if ticks = increase-rescue-agents-at-time[
      increment-rescue-agents
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) : Search for casualties

    ask resc-agents-A with [Mode = "Searching !!!"][
      set case-pma "NA"
      (ifelse count cas-agents with [targeted? = False and deceased? = False] != 0[ ; stops search function if there are no cas-agents left
      ;radius-search
        if target-agent = nobody[
          setup-munkres
        ]
        ]
        ; this else if statement was included to solve the issue of last agent not being picked up.
        (count cas-agents with [awaiting-rescue? = true] != 0) and (is-cas-agent? target-agent)[
          set mode "find path"
        ]
        ;else statement: if cas-agents are zero
        [
          set target-agent one-of PMA's
          set node-agent-at [node-pma] of target-agent
          find-path
          set mode "Impact Zone -> PMA"
        ]
      )
      if target-agent != nobody and is-cas-agent? target-agent[
        set color [color] of target-agent
        set Mode "Find Path"
        ;set label Mode
      ]
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) : Find path to casualties
    ask resc-agents-A with [Mode = "Find Path"][
      find-path
      ifelse commute-path != false and length commute-path > 1 [
        set Mode "Active"
        ;set label Mode
      ]
      [
        ;else statement: Containing two if statements
        if commute-path = false [
          output-print "ERROR THERE IS NO COMMUTE PATH FOR RESC OR resc-agent-B AGENTS"
        ]
        if length commute-path = 1[
          set Mode "Rescuing !!!"
        ]
      ]
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) : Travel to PMA
    ask resc-agents-A with [Mode = "Impact Zone -> PMA"][
      ifelse current-node = node-agent-at and is-PMA? target-agent[
        set Mode "(A) Drop off Casualties at PMA"
        set rescue-time rescue-time-mins
        set transfer-time transfer-time-mins
      ]
      [
        follow-path
      ]
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) : At Impact Zone : Rescuing

    ask resc-agents-A with [Mode = "Rescuing !!!"][
      Time-to-Rescue
      (ifelse
        rescue-time = 0 and ([deceased?] of target-agent = False)[
          collect-agent
          set label ""
          ifelse (length Rescued-agents-list = resc-agent-cap) or (count cas-agents with [deceased? = False and awaiting-rescue? = True] = 0)[
            set Mode "Return to PMA"
          ]
          [
            set rescue-time rescue-time-mins
            set Mode "Searching !!!"
          ]
        ]
        rescue-time = 0 and ([deceased?] of target-agent = True)[
          ; if the agent been rescued is deceased
          set Mode "Searching !!!"
          set target-agent nobody
          set rescue-time rescue-time-mins
      ])
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) : Transport rescued casualties to PMA
    ask resc-agents-A with [Mode = "Return to PMA"][
      choose-PMA
      find-path
      set Mode "Impact Zone -> PMA"
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) :  Search or Rescuing
    ask resc-agents-A with [Mode = "Active"][
      ifelse is-cas-agent? target-agent and [Deceased?] of target-agent = true[
        set mode "Searching !!!"
        set target-agent nobody
      ]
      [
        follow-path
      ]
      if (current-node = node-agent-at)[
        ifelse (is-cas-agent? target-agent) and (length rescued-agents-list < resc-agent-cap) and ([Deceased?] of target-agent != true )[
          set Mode "Rescuing !!!"

        ]
        [
          ;else statement: if the agent has died
          set Mode "Searching !!!"
        ]
      ]
    ]


    ; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) : At PMA - from hospital
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A transfer) : Collect casualties who were targeted at hospital
    if resc-agent-A-only = true[
      ask resc-agents-A with [mode = "(A2) Make Decision at PMA"][
        time-to-transfer
        if transfer-time = 0[
          collect-agent-from-pma-coming-from-hospital

          set transfer-time transfer-time-mins

          set mode "(A) PMA -> Hospital"
          find-hospital
          find-path
        ]

        ; ensure that if casualties have died just go rescue other agents
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer) : Collect agents who were targeted at hospital

    if resc-agent-A-only = false[
      ask resc-agents-B with [mode = "(B2) Make Decision at PMA"][
        time-to-transfer
        if transfer-time = 0[

          ; check if targeted agents are deceased
          ;let cas-targeted-by-resc cas-agents with [deceased? = false and TS = (2 or 3)

          collect-agent-from-pma-coming-from-hospital
          set transfer-time transfer-time-mins
          set mode "(B) PMA -> Hospital"
          find-hospital
          find-path
        ]
      ]
    ]


    ; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) : Hospital -> PMA / Imapact zone
    ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A transfer) : Hospital -> PMA / Impact Zone

    if resc-agent-A-only = true[
      ask resc-agents-A with [Mode = "Hospital -> PMA / Impact Zone"][
       ifelse current-node = node-agent-at and is-PMA? target-agent[
         ; if pma make decision - this time a little different, as you have target agents
          set mode "(A2) Make Decision at PMA"
        ]
        ; Unless at pma, follow path
        [
          follow-path
        ]
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer) : Hospital -> PMA
    if resc-agent-A-only = false[
      ask resc-agents-B with [mode = "(B) Hospital -> PMA"][
        ifelse current-node = node-agent-at and is-PMA? target-agent[
          let temp-resc-agent self
          let temp-cas-targeted-transfer cas-agents with [deceased? = false and (TS = 2 or TS = 3) and transfer-hosp? = true and targeted-transfer-by = temp-resc-agent]

          ; Check at PMA if any cas agent have been targeted from hospital
          ifelse count temp-cas-targeted-transfer > 0[
            set mode "(B2) Make Decision at PMA"
          ]
          [
           set mode "(B) At PMA"
          ]

        ]
        [
          follow-path
        ]
      ]
    ]

    ; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) : Make decision at Hospital
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A transfer) : Hosp -> IZ / Hosp -> PMA
    if resc-agent-A-only = true[

      let cas-ts23-alive-notarget cas-agents with [(TS = 2 or TS = 3) and  deceased? = false and targeted? = false]
      let cas-ts23-alive-transfer cas-agents with [(TS = 2 or TS = 3) and deceased? = false and transfer-hosp? = true and targeted-transfer? = false]

      ask resc-agents-A with [Mode = "Make Decision at Hospital A1"][

        (ifelse

          count cas-ts23-alive-notarget > 0 [
            set mode "Searching !!!"
            set target-agent nobody
            set node-agent-at nobody
          ]

          count cas-ts23-alive-transfer > 0 [
            target-agent-at-pma-from-hospital-AB
            find-path
            set mode "Hospital -> PMA / Impact Zone"
          ]

          [
            set mode "Searching !!!"
            set target-agent nobody
            set node-agent-at nobody
          ]
        )
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer) : Hospital -> PMA

    if resc-agent-A-only = false[
      ask resc-agents-B with [mode = "(B) Make Decision at Hospital"][
        target-agent-at-pma-from-hospital-AB
        find-path
        set mode "(B) Hospital -> PMA"

      ]
    ]

    ; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) : At Hospital - Drop off casualties
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A transfer hosp)

    if resc-agent-A-only = true[
      ask resc-agents-A with [Mode = "Drop off Casualties at Hospital"][
        Time-to-Transfer
        if transfer-time = 0[
          select-bed-type
          set transfer-time transfer-time-mins
          set mode "Make Decision at Hospital A1"
        ]
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer hosp)
    if resc-agent-A-only = false[
      ask resc-agents-B with [Mode = "(B) Drop off Casualties at Hospital"][
       Time-to-Transfer
        if transfer-time = 0[
         select-bed-type
         set transfer-time transfer-time-mins
         set mode "(B) Make Decision at Hospital"
        ]
      ]
    ]

    ; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) : Travel to hospital
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A transfer hosp)
    if resc-agent-A-only = true[
      ask resc-agents-A with [Mode = "(A) PMA -> Hospital"][

        ifelse current-node = node-agent-at and is-hospital? target-agent[
          set Mode "Drop off Casualties at Hospital"
        ]
        ; Unless your at the destination, follow path
        [

          follow-path

        ]
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer hosp)

    if resc-agent-A-only = false[
      ask resc-agents-B with [Mode = "(B) PMA -> Hospital"][
        ifelse current-node = node-agent-at and is-hospital? target-agent[
         set Mode "(B) Drop off Casualties at Hospital"
        ]
        ; unless your at hospital just follow the path
        [
          follow-path
        ]
      ]
    ]

    ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * (A rescue) :  Drop off casualties at PMA

    ask resc-agents-A with [Mode = "(A) Drop off Casualties at PMA"][
      Time-to-Transfer
      if transfer-time = 0[
        move-to-queue-or-stabilise
        set transfer-time transfer-time-mins

        ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A Only = True)
        ifelse resc-agent-A-only = true[
          set Mode "(A1) Make Decision at PMA"
        ]
        ; --------------------------------------------------------------------------------- (A Only = False)
        [
          ifelse count cas-agents with [deceased? = false and awaiting-rescue? = true] != 0 [
            set Mode "Searching !!!"
            set target-agent nobody
          ]
          [
           set mode "Stay at PMA"
          ]
        ]
      ]
    ]

    ; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) Make Decision at PMA
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A transfer)

    if resc-agent-A-only = true [
      ask resc-agents-A with [Mode = "(A1) Make Decision at PMA"][
        ;let temp-target-agent [target-agent] of
        let temp-target-agent target-agent
        let temp-transfer-hosp-q-ts23 cas-agents with [deceased? = false and (ts = 2 or ts = 3) and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-target-agent]
        ; To check capacity for awaiting transfer hospital for
        let pma-id [nid] of target-agent

        ; Remaining casualties at Impact Zone who havent been targeted yet
        let temp-resc-targeted-remaining-ts23 cas-agents with [(ts = 2 or ts = 3) and targeted? = false and deceased? = false]

        (ifelse
          ; Check if all TS23 agents have been targeted & is ther TS23 agents to be transfered
          (count temp-resc-targeted-remaining-ts23 = 0) and (count temp-transfer-hosp-q-TS23 > 0)[
            set case-pma "1. Trans all TS23"
          ]

          ; VH transfer Q > VH transfer Q cap
          (count temp-transfer-hosp-q-TS23  > transfer-hosp-vh) and (pma-id = "Vieux Habitants PMA")[
            set case-pma "2a. Trans VH Cas"
          ]

          ; SM transfer Q > SM transfer Q cap
          (count temp-transfer-hosp-q-TS23 > transfer-hosp-sm) and (pma-id = "Sainte Marie PMA")[
            set case-pma "2b. Trans SM Cas"
          ]

          ; Check for all other agents
          count cas-agents with [deceased? = false and targeted? = false] != 0[
            set case-pma "3. Search Cas"
          ]

          ; Rescue all other agents
          [
            set case-pma "4. Rescue ended"
        ])

        set mode "(A) Travel to PMA or Impact Zone"
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer) : At start


    if resc-agent-A-only = false[

      ask resc-agents-B with [Mode = "(B) At PMA"][

        let temp-target-agent target-agent
        ; cas-agents at PMA (VH or SM)
        let temp-transfer-hosp-ts23 count cas-agents with [deceased? = false and (TS = 2 or TS = 3) and transfer-hosp? = true and pma-at = temp-target-agent]
        if temp-transfer-hosp-ts23 > 0[
          set mode "(B1) Make Decision at PMA"
        ]
      ]
    ]

    ; --------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer) : Collect Agent at Start

    if resc-agent-A-only = false[
      ask resc-agents-B with [mode = "(B1) Make Decision at PMA"][
        time-to-transfer
        if transfer-time = 0[
          let temp-target-agent target-agent
          target-agent-at-start-at-PMA-B temp-target-agent ; to report func-name var - targets the agents to be collected at the start of the run
          collect-agent-from-pma-coming-from-hospital ; Here we are collecting agents since its at the start of the run

          ; transfer-hsp-q-TS23 > 0
          ifelse (length transfer-hosp-ts2-ls > 0) or (length transfer-hosp-ts3-ls) > 0[
            find-hospital
            find-path
            set transfer-time transfer-time-mins
            set other-pma-activate-t 60
            set mode "(B) PMA -> Hospital"

          ]
          ; no agent to be transfered
          [
            set transfer-time transfer-time-mins
            set mode "(B) At PMA"
          ]
        ]
      ]
    ]

    ; ---------------------------------------------------------------------------------------------------------------------------------------------------- (B Transfer) : PMA -> PMA
    if resc-agent-A-only = false[
      ask resc-agents-B with [mode = "(B) PMA -> PMA"][

        ifelse (current-node = node-agent-at) and (is-PMA? target-agent)[
          set mode "(B2) Make Decision at PMA"
        ]
        [
          follow-path
        ]

      ]
    ]


    ; ---------------------------------------------------------------------------------------------------------------------------------------------------- (B transfer) : Other PMA travel activation
    ; This function is to be used only the current PMA is not being used
    if resc-agent-A-only = false[
      ask resc-agents-B with [mode = "(B) At PMA"][

        if ticks > pma-operational-t1[

          ; Get other PMA id
          let temp-pma-vh reduce sentence [self] of PMA's with [nid = "Vieux Habitants PMA"]
          let temp-pma-sm reduce sentence [self] of PMA's with [nid = "Sainte Marie PMA"]

          let temp-other-pma nobody

          ifelse target-agent = temp-pma-vh[
            set temp-other-pma temp-pma-sm
          ]
          [
            set temp-other-pma temp-pma-vh
          ]

          ; Get cas count in other pma
          let temp-other-pma-transfer-hosp-ts23 cas-agents with [deceased? = false and (TS = 2 or TS = 3) and transfer-hosp? = true and pma-at = temp-other-pma]

          ; Check if current PMA has a agent to be transfered in either queue, stabilisation or transfer-hosp
          let temp-current-pma target-agent
          ; cas-agents at PMA (VH or SM)
          let temp-transfer-hosp-ts23 cas-agents with [deceased? = false and (TS = 2 or TS = 3) and transfer-hosp? = true and pma-at = temp-current-pma]
          let temp-queue-cas-ts23 cas-agents with [deceased? = false and (TS = 2 or TS = 3) and in-queue? = true and pma-at = temp-current-pma]
          let temp-stabilise-cas-ts23 cas-agents with [deceased? = false and (TS = 2 or TS = 3) and in-stabilisation? = true and pma-at = temp-current-pma]

          ifelse (count temp-transfer-hosp-ts23 > 0) or (count temp-queue-cas-ts23 > 0) or (count temp-stabilise-cas-ts23 > 0)[
            set other-pma-activate-t 60
          ]

          [
            set other-pma-activate-t other-pma-activate-t - 1
          ]


          if other-pma-activate-t = 0 [

            ifelse count temp-other-pma-transfer-hosp-TS23 > 0[
              set mode "(B) PMA -> PMA"
              let temp-target-agent temp-other-pma ; the function target-agent-at-start-PMA-B accepts an input
              target-agent-at-start-at-PMA-B temp-target-agent
              set target-agent temp-other-pma
              set node-agent-at [node-pma] of temp-other-pma
              find-path
              set other-pma-activate-t 60
            ]
            [
             set other-pma-activate-t 60
            ]

          ]
        ]
      ]
    ]


    ; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (A only) Execute Decision

    if resc-agent-A-only = true[

      ask resc-agents-A with [mode = "(A) Travel to PMA or Impact Zone"][
        if case-pma = "1. Trans all TS23"[
          time-to-transfer
          if transfer-time = 0[
            collect-agent-from-pma-coming-from-impactzone
            find-hospital
            find-path
            set transfer-time transfer-time-mins
            set mode "(A) PMA -> Hospital"
          ]
        ]
        if case-pma = "2a. Trans VH Cas"[
          time-to-transfer
          if transfer-time = 0[
            collect-agent-from-pma-coming-from-impactzone
            find-hospital
            find-path
            set transfer-time transfer-time-mins
            set mode "(A) PMA -> Hospital"
          ]
        ]

        if case-pma = "2b. Trans SM Cas"[
          time-to-transfer
          if transfer-time = 0[
            collect-agent-from-pma-coming-from-impactzone
            find-hospital
            find-path
            set transfer-time transfer-time-mins
            set mode "(A) PMA -> Hospital"
          ]
        ]

        if case-pma = "3. Search Cas"[
          set mode "Searching !!!"
          set target-agent nobody
        ]

        if case-pma = "4. Rescue ended"[
         set mode "Stay at PMA"
        ]
      ]
    ]


    ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Time update : Keep on updating ticks for global var even after rescue has ended
    ask resc-agents-A with [Mode = "Stay at PMA"][
      set list-of-time fput 1 list-of-time
    ]


    ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Heli-Agent Functions
    ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Search for casualties

    if heli-rescue? = True [
      ask heli-agents with [Mode = "Searching !!!"][
        ifelse count cas-agents with [(TS = 2 or TS = 3) and targeted? = False and deceased? = False] != 0[
          if target-agent = nobody[
            setup-munkres-heli
          ]
        ]
        [
          ;Else statement: if there are no TS2 or TS3 agents to rescue anymore,
          ;Helicopter already at site and have already rescued more than one agent: go to hospital
          ifelse length Rescued-agents-list > 0 [
            set Mode "Return to PMA"
            choose-pma-heli ;This function will return target-agent & patch-agent-at as one of PMA's (based on closest distance or Queue length)

            ;set target-agent one-of hospitals
            ;set patch-agent-at hospital-patch
          ]
          ;Helicopter at PMA but no agents to rescue: go to helipad
          [
            set Mode "Return to Helipad"
            move-to helipad-patch
            set current-patch helipad-patch
            set target-agent nobody
            set patch-agent-at nobody
          ]
        ]

        if target-agent != nobody and is-cas-agent? target-agent[
          set Mode "Active"
        ]
      ]
      ask heli-agents with [Mode = "Active"][
        follow-path-heli
        if current-patch = patch-agent-at[
          set Mode "Rescuing !!!"
        ]
      ]

      ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ At casualty agent location : Initiate rescue operation time

      ask heli-agents with [Mode = "Rescuing !!!"][
        time-to-rescue
        (ifelse rescue-time = 0 and [deceased?] of target-agent = False[
          collect-agent
          ifelse (length Rescued-Agents-List) =  resc-agent-cap or (count cas-agents with [ (TS = 2 or TS = 3) and deceased? = False and awaiting-rescue? = True] = 0)[
            set Mode "Return to PMA"
            choose-pma-heli ;This function will return target-agent & patch-agent-at as one of PMA's (based on closest distance or Queue length)
            ;set target-agent one-of hospitals
            ;set patch-agent-at hospital-patch
            ;set Rescue-time Rescue-time-mins
          ]
          [
            set Mode "Searching !!!"
            set Rescue-time Rescue-time-mins
          ]
          ]
          rescue-time = 0 and ([deceased?] of target-agent = True)[
            ; if the agent been rescued is deceased
            set Mode "Searching !!!"
            set target-agent nobody
            set rescue-time rescue-time-mins
          ]
        )
      ]

      ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Travel to PMA

      ask heli-agents with [Mode = "Return to PMA"][
        follow-path-heli
        if is-PMA? target-agent and current-patch = patch-agent-at[ ;is-PMA? is netlogo function is-<breed>?
          set Mode "At PMA"
        ]
      ]

      ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ At PMA : return casualties to Queue / Stabilisation

      ask heli-agents with [Mode = "At PMA"][
        Time-to-transfer
        if transfer-time = 0[
          move-to-queue-or-stabilise
          ;identify-TS2-TS3-Heli
          ;select-bed-type
          reset-lists-variables-heli ; resets all variables
          set Mode "Searching !!!"
        ]
      ]
    ]

    ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ End of Helicopter Rescue


    ; ================================================================================================================================================================================== PMA related Functions
    ; ============================================================================================================================= Renew PMA lists; move from, queue -> stabilisation; stabilisation -> transfer hospital

    ask PMA's [
      setup-PMA-capacity ; Function : Sets up PMA capacity during the two time intervals
      renew-PMA-lists ; Function : this is for removeing deceased agents
      move-from-PMA-queue-stabilise ;Function : Moves from Queue to Stabalised-Queue
      TS1-recovered ; Function : Moves stabalised TS1 Agents to TS1-Recovered patches(red) / adds to list
      move-from-stabalise-to-await-transfer-hosp ; Function : Moves TS2 & TS3 agent from stabilise to awaiting transfer hosp queue
    ]


    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Hospital Functions
    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ (Hospital) Move casualties from NBB to BB
    ask hospitals[
      renew-hospital-lists
      from-non-to-burn-beds
      from-Hospital-Queue-to-Non-Burn-Beds
    ]
  ]

  ; ``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````` Update ticks + Apply mortality rates
  if ticks >= 0 and ticks <= 7200 [
    tick

    ;``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````` (Observer) Apply mortality Rates
    apply-mortality-rates

  ]
end

; (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((( END GO MAIN PROCEDURE ))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

; (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((( SUPPORT FUNCTIONS FOR GO PROCEDURE )))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))


; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Helicopter Support Functions ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (heli-agent) : Find the closest agents based on Munkres Algorithm

to setup-munkres-heli
  let pop-TS23 cas-agents with [(TS = 2 or TS = 3) and targeted? = False and Deceased? = False] ; list of cas-agents of TS cat 2 or 3
  if count pop-TS23 > 0[
    let searching-heli-agents heli-agents with [target-agent = nobody and Mode = "Searching !!!"] ;set of helicopters who are inacative / havent identied cas-agent to rescue

    let who-TS23-list []
    let pop-TS23-list []
    let who-heli-list[]
    let heli-list []
    let dist-to-TS23-list []

    ask pop-TS23[
      set who-TS23-list lput who who-TS23-list
      set pop-TS23-list lput self pop-TS23-list
    ]
    ask searching-heli-agents [
      set who-heli-list lput who who-heli-list
      set heli-list lput self heli-list

    ]
    foreach heli-list [
      i ->
      foreach pop-TS23-list[
        j ->
        ask i[
          let dist-to-cas-agent distance j
          set dist-to-TS23-list lput dist-to-cas-agent dist-to-TS23-list

        ]
      ]
    ]
    py:setup py:python3
    py:set "py_who_TS23_list" who-TS23-list
    py:set "py_who_heli_list" who-heli-list
    py:set "py_dist_to_TS23_list" dist-to-TS23-list

    ;Python code : running munkres algorithm
    (py:run
      "from munkres import Munkres"
      "from numpy import array,transpose"

      "h_agent_arr,p_agent_arr,dist_arr = array(py_who_heli_list),array(py_who_TS23_list),array(py_dist_to_TS23_list)"

      "dist_mat = dist_arr.reshape(h_agent_arr.size,p_agent_arr.size)"

      ;  Number of helicopters <= Number of pop_TS23
      "if p_agent_arr.size >= h_agent_arr.size:"

      "    m = Munkres()"
      "    idx = m.compute(dist_mat)"
      "    heli_pop_who = [(h_agent_arr[i[0]],p_agent_arr[i[1]]) for i in idx]"

      ;=== Number of helicopters > Number of pop_TS23 ===

      "else:"

      "    dist_mat_trans = transpose(dist_mat)"
      "    m = Munkres()"
      "    idx = m.compute(dist_mat_trans)"

      "    resc_pop_who = [(h_agent_arr[i[1]],p_agent_arr[i[0]]) for i in idx]"
      )


  ;converting python variables to netlogo variables

    let heli-pop-who py:runresult "heli_pop_who"
    foreach heli-pop-who[
      i ->
      let heli-who item 0 i
      let pop-who item 1 i

      ask heli-agent heli-who [
        set target-agent cas-agent pop-who
        set patch-agent-at [patch-here] of target-agent
        ;show target-agent
        ;show patch-agent-at

        ask target-agent [
          set targeted? True
          set Rescue-by-Helicopter? True
          set targeted-by heli-agent heli-who
        ]
      ]
    ]
  ]
end

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (heli-agent) : follow the assigned paths based on patches

to follow-path-heli
  let speed-m-min (Speed-Helicopter * 1000 / 60)
  let jump-dist-m speed-m-min
  let speed-net-min speed-m-min * gis-net-convfac
  let jump-dist-net jump-dist-m * gis-net-convfac

  ;updates
  set distance-to-target distance patch-agent-at
  set current-patch patch-here
  face patch-agent-at

  while [jump-dist-net > 0][

    (ifelse
      ;rem-fm-prev-run: Remaining distance left after jumping to a patch with an population agent
      ;remaining-distance: Remaining distance if the jump distance is greater than distance ot the patch
      ;jump-dist-net: Full jump distance
      ;rem-fm-prev-run > 0 [set Case 0]
      jump-dist-net < distance-to-target and remaining-distance <= 0 [set case-commute 1]
      jump-dist-net >= distance-to-target and remaining-distance <= 0 [set case-commute 2]
      remaining-distance < distance-to-target and remaining-distance > 0 [set case-commute 3]
      remaining-distance > distance-to-target and remaining-distance > 0 [set case-commute 4]
      )
    ;case 1: There distance to the agent is larger than jump distance so Jump full distance
    if case-commute = 1[
      ;position and distance update BEFORE jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at

      ;jump
      jump jump-dist-net

      ;update lists
      set list-of-distances lput jump-dist-net list-of-distances
      set list-of-m-distances lput (jump-dist-net * net-gis-convfac) list-of-m-distances
      set list-of-time lput (jump-dist-net / speed-net-min) list-of-time

      ;jump update
      set jump-dist-net (jump-dist-net - jump-dist-net)

      ;position and distance update AFTER jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at
    ]

    ;Case 2: The distance to the agent is smaller than the jump distance, so move to agent patch
    if case-commute = 2[
      ;position and distance update BEFORE jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at

      ;Jump
      move-to patch-agent-at

      ;update-lists
      set list-of-distances lput distance-to-target list-of-distances
      set list-of-m-distances lput (distance-to-target * net-gis-convfac) list-of-m-distances
      set list-of-time lput (distance-to-target / speed-net-min) list-of-time

      ;Jump update
      set remaining-distance (jump-dist-net - distance-to-target)
      set jump-dist-net 0

      ;position and distance update AFTER jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at
    ]

    ;Case 3: There is a leftover distance to jump, but the distance is less than the distance to the patch agents on, so jump that distance
    if case-commute = 3[
      ;position and distance update BEFORE jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at

      ;Jump
      jump remaining-distance

      ;update-lists
      set list-of-distances lput remaining-distance list-of-distances
      set list-of-m-distances lput (remaining-distance * net-gis-convfac) list-of-m-distances
      set list-of-time lput (remaining-distance / speed-net-min) list-of-time

      ;Jump update
      set jump-dist-net jump-dist-net - remaining-distance
      set remaining-distance 0

      ;position and distance update AFTER jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at
  ]

    ;Case 4: There is leftover distance to jump, but the distance is more than the distance to the patch the agents on. so jump that distance but store the additional distance
    if case-commute = 4[
      ;position and distance update BEFORE jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at

      ;jump
      jump distance-to-target

      ;update-lists
      set list-of-distances lput distance-to-target list-of-distances
      set list-of-m-distances lput (distance-to-target * net-gis-convfac) list-of-m-distances
      set list-of-time lput (distance-to-target / speed-net-min) list-of-time

      ;jump updates
      set jump-dist-net 0
      set remaining-distance remaining-distance - distance-to-target

      ;position and distance update AFTER jump
      set current-patch patch-here
      set distance-to-target distance patch-agent-at
    ]
  ]

end

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  (Heli - Agents) : Choose PMA based on queue / distance

to choose-pma-heli
  ; Find PMA with the least queue / closest PMA
  let vh-queue-length [length queue-TS1 + length queue-TS23] of PMA's with [nid = "Vieux Habitants PMA"]
  let sm-queue-length [length queue-TS1 + length queue-TS23] of PMA's with [nid = "Sainte Marie PMA"]

  ifelse vh-queue-length = sm-queue-length [
    ; if statement select closest PMA
      let pma-list []
      let dist-list []

      let pma-in-range PMA's in-radius 400
      ask pma-in-range[
        set dist-list lput distance myself dist-list
        set pma-list lput self pma-list
      ]
    let min-dist-idx position (min dist-list) dist-list
    set target-agent item min-dist-idx pma-list
    set patch-agent-at [patch-here] of target-agent
  ]
  [
   ; else statement : Select the pma with a smaller queue
    set target-agent min-one-of PMA's [length queue-TS1 + length queue-TS23]
    set patch-agent-at [patch-here] of target-agent

  ]
end

; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (Heli Agent - Not in use) : Sort TS23 -> TS2 / TS3
to identify-TS2-TS3-Heli
  let temp-collected-agents-TS2 []
  let temp-collected-agents-TS3 []
  foreach rescued-agents-list[
    i ->
    ask i[
      if TS = 2[
        set temp-collected-agents-TS2 lput self temp-collected-agents-TS2
      ]
      if TS = 3[
        set temp-collected-agents-TS3 lput self temp-collected-agents-TS3
      ]
    ]
    set collected-agents-TS2 temp-collected-agents-TS2
    set collected-agents-TS3 temp-collected-agents-TS3
  ]

end


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Rescue Agent Functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (resc-agent-A/B) : Find the closest casualty based on network distance & Munkres Algorithm

to setup-munkres
  ; +++ Search TS 2 or 3 Agents +++

  let pop-TS23 cas-agents with [(TS = 2 or TS = 3) and targeted? = False and Deceased? = False] ;list of cas-agents with TS cat 2 or 3

  if count pop-TS23 > 0[
    let searching-resc-agents-A resc-agents-A with [target-agent = nobody and Mode = "Searching !!!"] ;list of resc-agents-A who are inactive/havent found an cas-agent to rescue

    let who-TS23-list []
    let pop-TS23-nodes-list []
    let who-resc-list []
    let search-resc-nodes-list []
    let dist-to-TS23-list []

    ask pop-TS23 [
      set who-TS23-list lput who who-TS23-list ;list of TS23 agents who numbers
      set pop-TS23-nodes-list lput node-pop pop-TS23-nodes-list  ;list of cas-agent-nodes for agents in pop-TS23-list
  ]
    ask searching-resc-agents-A[
      set who-resc-list lput who who-resc-list ;list of resc-agents-A who are inactive
      set search-resc-nodes-list lput node-resc search-resc-nodes-list ;list of nodes for agents in search-resc-list
    ]
    ;for looping iterating over pop-TS23-nodes and search-resc-nodes-list and calculting the distance between each of the nodes
    foreach search-resc-nodes-list [
      i ->
      foreach pop-TS23-nodes-list[
        j ->
        ;show i
        ;show j
        ask i[
          let dist-to-pop-node nw:weighted-distance-to j netlogo-dist
          set dist-to-TS23-list lput dist-to-pop-node dist-to-TS23-list
        ]
      ]
    ]

    ;converting variables to python
    py:setup py:python3
    py:set "py_who_TS23_list" who-TS23-list
    py:set "py_who_resc_list" who-resc-list
    py:set "py_dist_to_TS23_list" dist-to-TS23-list

    ;running munkres algorithm
    (py:run
      "from munkres import Munkres"
      "from numpy import array,transpose"

      "r_agent_arr,p_agent_arr,dist_arr = array(py_who_resc_list),array(py_who_TS23_list),array(py_dist_to_TS23_list)"

      "dist_mat = dist_arr.reshape(r_agent_arr.size,p_agent_arr.size)"

      ;+++ Number of rescuers <= Number of pop_TS23 +++

      "if r_agent_arr.size <= p_agent_arr.size:"
      "    m = Munkres()"
      "    idx = m.compute(dist_mat)"
      "    resc_pop_who = [(r_agent_arr[i[0]],p_agent_arr[i[1]]) for i in idx]"

      ; +++ Number of rescuers > Number of pop_TS23 +++

      "else:"
      "    dist_mat_trans = transpose(dist_mat)"

      "    m = Munkres()"
      "    idx = m.compute(dist_mat_trans)"
      "    resc_pop_who = [(r_agent_arr[i[1]],p_agent_arr[i[0]]) for i in idx]"
      )

    ;converting python variables to netlogo variables

    let resc-pop-who py:runresult "resc_pop_who"
    foreach resc-pop-who[
      i ->
      let resc-who item 0 i
      let pop-who item 1 i

      ask resc-agent-A resc-who [
        set target-agent cas-agent pop-who
        set node-agent-at [node-pop] of target-agent

        ask target-agent [
          set targeted? True
          set Rescue-by-resc-agent-B? True
          set targeted-by resc-agent-A resc-who
        ]
      ]

    ]
]

  ; +++ Search TS 1 Agents +++
  if count pop-TS23 = 0 [
    let searching-resc-agents-A resc-agents-A with [target-agent = nobody and Mode = "Searching !!!"] ;list of resc-agents-A who are inactive/havent found an cas-agent to rescue

    let pop-TS1 cas-agents with [TS = 1 and targeted? = False and deceased? = False]
    let who-TS1-list []
    let pop-TS1-nodes-list []
    let who-resc-list []
    let search-resc-nodes-list []
    let dist-to-TS1-list []

    ask pop-TS1 [
      set who-TS1-list lput who who-TS1-list ;list of TS1 agents who numbers
      set pop-TS1-nodes-list lput node-pop pop-TS1-nodes-list  ;list of cas-agent-nodes for agents in pop-TS23-list
    ]
    ask searching-resc-agents-A[
      set who-resc-list lput who who-resc-list ;list of resc-agents-A who are inactive
      set search-resc-nodes-list lput node-resc search-resc-nodes-list ;list of nodes for agents in search-resc-list
    ]
    ;for looping iterating over pop-TS23-nodes and search-resc-nodes-list and calculting the distance between each of the nodes
    foreach search-resc-nodes-list [
      i ->
      foreach pop-TS1-nodes-list[
        j ->
        ask i[
          let dist-to-pop-node nw:weighted-distance-to j netlogo-dist
          set dist-to-TS1-list lput dist-to-pop-node dist-to-TS1-list
        ]
      ]
    ]

    ;converting variables to python
    py:setup py:python3
    py:set "py_who_TS1_list" who-TS1-list
    py:set "py_who_resc_list" who-resc-list
    py:set "py_dist_to_TS1_list" dist-to-TS1-list

    ;running munkres algorithm
    (py:run
      "from munkres import Munkres"
      "from numpy import array,transpose"

      "r_agent_arr,p_agent_arr,dist_arr = array(py_who_resc_list),array(py_who_TS1_list),array(py_dist_to_TS1_list)"

      "dist_mat = dist_arr.reshape(r_agent_arr.size,p_agent_arr.size)"

      ;+++ Number of rescuers <= Number of pop_TS1 +++
      "if p_agent_arr.size >= r_agent_arr.size:"

      "    m = Munkres()"
      "    idx = m.compute(dist_mat)"

      ; To extract cas-agent and resc-agent-A who numbers from indexes
      "    resc_pop_who = [(r_agent_arr[i[0]],p_agent_arr[i[1]]) for i in idx]"

      ;+++ Number of rescuers > Number of pop_TS1 +++

      "else:"

      "    dist_mat_trans = transpose(dist_mat)"
      "    m = Munkres()"
      "    idx = m.compute(dist_mat_trans)"

      ; To extract cas-agent and resc-agent-A who numbers from indexes
      "    resc_pop_who = [(r_agent_arr[i[1]],p_agent_arr[i[0]]) for i in idx]"

      )

    ;converting variables from python to netlogo

    let resc-pop-who py:runresult "resc_pop_who"
    foreach resc-pop-who[
      i ->
      let resc-who item 0 i
      let pop-who item 1 i

      ask resc-agent-A resc-who [
        set target-agent cas-agent pop-who
        set node-agent-at [node-pop] of target-agent
        ;show target-agent
        ;show node-agent-at

        ask target-agent [
          set targeted? True
          set Rescue-by-resc-agent-B? True
          set targeted-by resc-agent-A resc-who
          ;set label "targeted"
        ]
      ]
    ]
]
end

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (resc-agent-A/B) : Find path from current position to casualty locations (nodes)

to find-path

  set current-node node-resc
  let end-location node-agent-at

  let path []
  ask node-resc [set path nw:turtles-on-weighted-path-to end-location netlogo-dist]
  set commute-path path

  set route-length length commute-path
end

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  (resc-agent-A/B) : Moves across the assigned path

to follow-path
  let speed-m-min (speed * 1000 / 60)
  let jump-dist-m speed-m-min
  ;let gis-net-convfac 0.012
  ;let net-gis-convfac 1 / gis-net-convfac
  let speed-net-min speed-m-min * gis-net-convfac
  let jump-dist-net jump-dist-m * gis-net-convfac

  while [jump-dist-net > 0]
  [

    set current-pos (position current-node commute-path)
    set next-pos ((position (current-node) commute-path) + 1)
    if next-pos < route-length [set next-node item(next-pos) commute-path]
    set distance-to-next-node distance next-node

    face next-node

    (ifelse
      ;rem-fm-prev-run: Remaining distance left after jumping to a node with an population agent
      ;remaining-distance: Remaining distance if the jump distance is greater than distance ot the next node
      ;jump-dist-net: Full jump distance
      rem-fm-prev-run > 0 [set case-commute 0]
      jump-dist-net < distance-to-next-node and remaining-distance <= 0 [set case-commute 1]
      jump-dist-net >= distance-to-next-node and remaining-distance <= 0 [set case-commute 2]
      remaining-distance < distance-to-next-node and remaining-distance > 0 [set case-commute 3]
      remaining-distance > distance-to-next-node [set case-commute 4]
      )

    if case-commute = 0[
      set jump-dist-net (jump-dist-net + rem-fm-prev-run)
      set rem-fm-prev-run 0

    ]
   ;Case 1: There is no remaining distance so jump full distance provided that the distance to next node > jump distance
    if case-commute = 1[
      ifelse next-node != node-agent-at[

        jump jump-dist-net
        set distance-to-next-node distance next-node
        set list-of-distances lput jump-dist-net list-of-distances
        set list-of-time lput (jump-dist-net / speed-net-min) list-of-time
        set list-of-m-distances lput (jump-dist-net * net-gis-convfac) list-of-m-distances

        set jump-dist-net (jump-dist-net - jump-dist-net)

        ]
      [
        jump jump-dist-net
        set distance-to-next-node distance next-node
        set list-of-distances lput jump-dist-net list-of-distances
        set list-of-time lput (jump-dist-net / speed-net-min) list-of-time
        set list-of-m-distances lput (jump-dist-net * net-gis-convfac) list-of-m-distances

        set jump-dist-net (jump-dist-net - jump-dist-net)

      ]
    ]

    ;Case 2: There is no remaining distance, so jump the the full distance but since distance to next node < full jump distance, store the remaining distance from the jump
    if case-commute = 2 [
      ifelse next-node != node-agent-at [
        move-to next-node ; or can write as jump "part of" jump-dist
        set list-of-distances lput distance-to-next-node list-of-distances
        set list-of-time lput (distance-to-next-node / speed-net-min) list-of-time
        set list-of-m-distances lput (distance-to-next-node * net-gis-convfac) list-of-m-distances

        ;update
        set remaining-distance (jump-dist-net - distance-to-next-node) ; store the remaining distance left from the previous jump
        set jump-dist-net (jump-dist-net - distance-to-next-node)
        set current-node next-node
        set node-resc current-node
        set current-pos (position current-node commute-path)
        set next-pos ((position (current-node) commute-path) + 1)
        if next-pos < route-length [set next-node item(next-pos) commute-path]
        face Next-Node
        set distance-to-next-node distance next-node

      ]
      [
        ;else statement: cas-agent present hence cannot jump further in one tick, therfore set jump-dist-net to zero to exit while loop and store the remainder distance in var remaining-distance to jump in the next turn
        move-to next-node
        set list-of-distances lput distance-to-next-node list-of-distances
        set list-of-time lput (distance-to-next-node / speed-net-min) list-of-time
        set list-of-m-distances lput (distance-to-next-node * net-gis-convfac) list-of-m-distances

        ;update
        set rem-fm-prev-run (jump-dist-net - distance-to-next-node)
        set jump-dist-net 0
        set current-node next-node
        set node-resc current-node

      ]
    ]

      ;CASE 3: if there is remaining distance and the distance to the next node is large, remaining distance < distance to next node
        if case-commute = 3[
      ifelse next-node != node-agent-at [

        jump remaining-distance
        set distance-to-next-node distance next-node
        set list-of-distances lput remaining-distance list-of-distances
        set list-of-time lput (remaining-distance / speed-net-min) list-of-time
        set jump-dist-net (jump-dist-net - remaining-distance)
        set remaining-distance 0

      ]
      [
        jump remaining-distance
        set list-of-distances lput remaining-distance list-of-distances
        set list-of-time lput (remaining-distance / speed-net-min) list-of-time
        set jump-dist-net (jump-dist-net - remaining-distance)
        set remaining-distance 0
        set distance-to-next-node distance next-node

      ]
    ]

    ;CASE 4: if there is remaining distance but the distance to the next node is small, remaining distance > distance-to-next-node
    if case-commute = 4[
      ifelse next-node != node-agent-at [
        move-to next-node ; Alternatively, jump remainder of remaining-distance
        set list-of-distances lput distance-to-next-node list-of-distances
        set list-of-time lput (distance-to-next-node / speed-net-min) list-of-time
        set list-of-m-distances lput (distance-to-next-node * net-gis-convfac) list-of-m-distances

        ;update
        set jump-dist-net (jump-dist-net - distance-to-next-node)
        set remaining-distance (remaining-distance - distance-to-next-node)
        set current-node next-node
        set node-resc current-node
        set current-pos (position current-node commute-path)
        set next-pos ((position (current-node) commute-path) + 1)
        if next-pos < route-length [set next-node item(next-pos) commute-path]
        face Next-Node
        set distance-to-next-node distance next-node

    ]
      [
        ;Else statement: cas-agent present in next node, hence cannot jump full remaining distance. Therefore jump portion of the remaining distance and add the remainder for the next round (remainder + jump-net-distance)
        move-to next-node
        set list-of-distances lput distance-to-next-node list-of-distances
        set list-of-time lput (distance-to-next-node / speed-net-min) list-of-time
        set list-of-m-distances lput (distance-to-next-node * net-gis-convfac) list-of-m-distances

        ;update
        set rem-fm-prev-run (remaining-distance - distance-to-next-node)
        set jump-dist-net 0
        set current-node next-node
        set node-resc current-node

      ]
    ]
  ]
end

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++========================================================= (resc-agent-A/B / heli-agent) : Loads Agent Agent into ambulance/helicpter

to collect-agent
  set Rescued-agents-list lput target-agent Rescued-agents-list
  ask target-agent [
    if Rescue-by-resc-agent-B? = True[
      move-to one-of patches with [pcolor = 125]
      set on-route-PMA? true
      set on-route-PMA-time ticks
    ]
    if Rescue-by-Helicopter? = True[
      move-to one-of patches with [pcolor = 34]
      set on-route-hospital? True
      set on-route-hospital-time ticks
    ]
    set awaiting-rescue? False

  ]
  set target-agent nobody
end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++======================================================== (resc-agent-A / heli-agent) : At casualty location, initiate time for searching, loading etc.

to Time-to-Rescue
  set Rescue-time Rescue-time - 1
  set list-of-time lput 1 list-of-time
  ;set label Rescue-time
end

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (resc-agent-A) : Selects PMA based on distance / queue length
to choose-PMA
  ;Find PMA with least Queue / Closest PMA

  let vh-queue-length [length queue-TS1 + length queue-TS23] of PMA's with [nid = "Vieux Habitants PMA"]
  let sm-queue-length [length queue-TS1 + length queue-TS23] of PMA's with [nid = "Sainte Marie PMA"]

  let vh-transfer-hosp-TS2 [transfer-hosp-q-TS2] of PMA's with[nid = "Vieux Habitants PMA"] ; had : reduce sentence [await-transfer-hosp]
  let vh-transfer-hosp-TS3 [transfer-hosp-q-TS3] of PMA's with[nid = "Vieux Habitants PMA"]
  let sm-transfer-hosp-TS2 [transfer-hosp-q-TS2] of PMA's with[nid = "Sainte Marie PMA"]
  let sm-transfer-hosp-TS3 [transfer-hosp-q-TS3] of PMA's with[nid = "Saint Marie PMA"]


  if resc-agent-A-only = True [
    (ifelse
      ; if statement : Select Saint Marie as the destination if transfer hospital queue has reached its capacity
      (length sm-transfer-hosp-TS2 + length sm-transfer-hosp-TS3)  > transfer-hosp-sm[

        set node-agent-at item 0 [node-pma] of PMA's with [nid = "Sainte Marie PMA"]
        set target-agent item 0 [self] of PMA's with [nid = "Sainte Marie PMA"]

      ]
      ;elseif : Select Vieux Habitants as destination if transfer hospital queue has exceed its capacity
      (length vh-transfer-hosp-TS2 + length vh-transfer-hosp-TS3) > transfer-hosp-vh[

        set node-agent-at item 0 [node-pma] of PMA's with [nid = "Vieux Habitants PMA"]
        set target-agent item 0 [self] of PMA's with [nid = "Vieux Habitants PMA"]

      ]

      ; elseif : Select PMA based on distance from current location - Impact zone
      vh-queue-length = sm-queue-length [

        ask node-resc[
          set G-target-node min-one-of nodes with [PMA-present != nobody][nw:weighted-distance-to myself netlogo-dist]
        ]
        ask G-target-node [
          set G-target-agent min-one-of PMA's in-radius 0.0001 [distance myself]
        ]
        set node-agent-at G-target-node
        set target-agent G-target-agent
      ]

      ;else statement : Select PMA based on queue length
      [

        let target-PMA min-one-of PMA's [length queue-TS1 + length queue-TS23]
        set node-agent-at [node-PMA] of target-PMA
        set target-agent target-PMA
      ]
    )
  ]

  if resc-agent-A-only = False[
    (ifelse
      ; select PMA based on distance
      vh-queue-length = sm-queue-length [

        ask node-resc[
          set G-target-node min-one-of nodes with [PMA-present != nobody][nw:weighted-distance-to myself netlogo-dist]
        ]
        ask G-target-node [
          set G-target-agent min-one-of PMA's in-radius 0.0001 [distance myself]
        ]

        set node-agent-at G-target-node
        set target-agent G-target-agent
      ]

      ;else statement : Select PMA based on queue length
      [

        let target-PMA min-one-of PMA's [length queue-TS1 + length queue-TS23]
        set node-agent-at [node-PMA] of target-PMA
        set target-agent target-PMA
      ]
    )

  ]
end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++======================================================== (resc-agent-A/B / heli-agent) : At PMA/Hospital. Initate time for transfering casualties to PMA/Hospital

to Time-to-Transfer
  set Transfer-time Transfer-time - 1
  set list-of-time lput 1 list-of-time
end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++======================================================== (resc-agent-A /heli-agent) : At PMA, move causalty either to queue or stabilisation based on vacancy

to move-to-queue-or-stabilise
  let collected [Rescued-agents-list] of self ;collected: temp variable , collected-cas-agents: resc-agent-A variable holding the cas-agents that are in the resc-agent-B
  ask target-agent[;ask PMA
    foreach collected[
      i ->
     ifelse length stabilise-TS23 + length stabilise-TS1 < PMA-capacity[
        ;if statement: When summation of stabilise TS23 & TS1 lists < PMA-capacity, MOVE TO STABILISE
        ask i[ ; ask cas-agent in Rescued-agents-list
          ifelse TS = 1[
            let temp-stabilise-TS1 [stabilise-TS1] of myself
            let temp-pop-TS1 self
            set temp-stabilise-TS1 lput temp-pop-TS1 temp-stabilise-TS1
            ask myself[
              set stabilise-TS1 temp-stabilise-TS1
              set stabilise-t-TS1 lput ticks stabilise-t-TS1
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 55]] ;stabilse-TS1 VH --done
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 65]] ; stabilise-TS1 SM --done
            set stabilise-time ticks
            set on-route-PMA? False
            set in-stabilisation? True
            set hidden? False
            set label ""
          ]
          [
            let temp-stabilise-TS23 [stabilise-TS23] of myself
            let temp-pop-TS23 self
            set temp-stabilise-TS23 lput temp-pop-TS23 temp-stabilise-TS23
            ask myself[
              set stabilise-TS23 temp-stabilise-TS23
              set stabilise-t-TS23 lput ticks stabilise-t-TS23
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 55]] ;Stabilise-TS23 VH --done
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 65]] ;stabilise-TS23 SM --done
            set stabilise-time ticks
            set on-route-PMA? False
            set in-stabilisation? True
            set hidden? False
            set label ""
          ]
        ]
      ]

      [
         ;else statement: when PMA-capacity is equal to the summation of stabilise TS23 and TS1 lists, MOVE TO QUEUE
          ask i[
            ifelse TS = 1[ ; For cas-agent of Trauma scale category 1
            let temp-queue-TS1 [queue-TS1] of myself
            let temp-pop-TS1 self
            set temp-queue-TS1 lput temp-pop-TS1 temp-queue-TS1
            ask myself[
              set queue-TS1 temp-queue-TS1
              set Queue-t-TS1 lput ticks Queue-t-TS1
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 54]] ;Queue-TS1 VH --done
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 64]] ;Queue-TS1 SM --done
            set Queue-Time ticks
            set on-route-PMA? False
            set in-queue? True
            set hidden? False
            set label ""
          ]
          [
            ; For cas-agent of Trauma scale category 2 or 3
            let temp-queue-TS23 [queue-TS23] of myself
            let temp-pop-TS23 self
            set temp-queue-TS23 lput temp-pop-TS23 temp-queue-TS23
            ask myself[
              set queue-TS23 temp-queue-TS23
              set Queue-t-TS23 lput ticks Queue-t-TS23
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 54]] ;Queue-TS23 VH -- done
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 64]] ;Queue-TS23 SM -- done
            set queue-time ticks
            set on-route-PMA? False
            set in-queue? True
            set hidden? False
            set label ""
        ]
      ]
    ]
    ]
  ]
  set Rescued-agents-list []
  set label ""
end

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ (Only A) : At PMA Checks if causalties need to be taken to hospital

to collect-agent-from-pma-coming-from-impactzone

  ; Store resc agent variable, target-agent (At this point one of the PMA's) in a temp variable
  let temp-target-agent target-agent

  ; Get all cas agent awaiting for transfer at a specific PMA (the one the resc agent is curently at)
  ; Note the following are agentset variables
  let temp-transfer-TS2 cas-agents with [TS = 2 and deceased? = false and transfer-hosp? = true and pma-at = temp-target-agent and targeted-transfer? = false]
  let temp-transfer-TS3 cas-agents with [TS = 3 and deceased? = false and transfer-hosp? = true and pma-at = temp-target-agent and targeted-transfer? = false]

  ; Get a sorted list of above agent in order of transfer time
  let temp-transfer-TS2-ls sort-on [transfer-hosp-time] temp-transfer-TS2
  let temp-transfer-TS3-ls sort-on [transfer-hosp-time] temp-transfer-TS3


  ; while < resc agent capacity
  ; transfer-hosp-TS2/TS3-ls : Resc agent variable holding transfering casualties
  while [((length transfer-hosp-TS2-ls + length transfer-hosp-TS3-ls) < resc-agent-cap) and ((length temp-transfer-TS2-ls + length temp-transfer-TS3-ls)  > 0)][

    ;temp variables holding agent and its position, the first ifelse statement will pick him from await-transfer-hosp-TS2/3 lists ->
    let agent-transfered nobody
    let agent-transfered-pos nobody
    let agent-transfered-ts nobody


    ; Select first agent from await-transfer-hosp-TS2 queue unless queue is zero, in which case, select first agent from Tawait-transfer-hosp-TS3
    ifelse length temp-transfer-TS2-ls > 0[
      set agent-transfered item 0 temp-transfer-TS2-ls
      set agent-transfered-pos position agent-transfered temp-transfer-TS2-ls
    ]
    [
      set agent-transfered item 0 temp-transfer-TS3-ls
      set agent-transfered-pos position agent-transfered temp-transfer-TS3-ls
    ]

    ; if agent transfered is TS2 add it goes into transfer-hosp-TS2-ls list (Rescue Agent list) / Also remove it from temp list
    ifelse [TS] of agent-transfered = 2[
      set transfer-hosp-TS2-ls lput agent-transfered transfer-hosp-TS2-ls
      set temp-transfer-TS2-ls remove agent-transfered temp-transfer-TS2-ls

    ]
    ; else, add it into transfer-hosp-TS3-ls (Rescue agent list) / Also remove it from temp list
    [
      set transfer-hosp-TS3-ls lput agent-transfered transfer-hosp-TS3-ls
      set temp-transfer-TS3-ls remove agent-transfered temp-transfer-TS3-ls

    ]


    ; get TS of the transfered agent
    let temp-TS-of-agent-transfered [TS] of agent-transfered

    ; remove pma to remove transfered agent from the pma list
    ask target-agent[

      ifelse temp-TS-of-agent-transfered = 2[
        set transfer-hosp-q-TS2 remove agent-transfered transfer-hosp-q-TS2
        set transfer-hosp-q-t-TS2 remove-item agent-transfered-pos transfer-hosp-q-t-TS2
      ]
      [
        set transfer-hosp-q-TS3 remove agent-transfered transfer-hosp-q-TS3
        set transfer-hosp-q-t-TS3 remove-item agent-transfered-pos transfer-hosp-q-t-TS3
      ]
    ]


    ; ask transfered agent to jump to respective patch
    ask agent-transfered [
      move-to one-of patches with [pcolor = 25]
      set transfer-hosp? false
      set on-route-hospital? true
      set targeted-transfer? true
    ]
  ]

end

;+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (Both A/B) : Collect agent from PMA on the route back from Hospital

to collect-agent-from-pma-coming-from-hospital
  let temp-transfer-hosp-ts2 cas-agents with [deceased? = false and targeted-transfer-by = myself and ts = 2 and transfer-hosp? = true]
  let temp-transfer-hosp-ts3 cas-agents with [deceased? = false and targeted-transfer-by = myself and ts = 3 and transfer-hosp? = true]
  let temp-transfer-hosp-ts2-ls sort-on [transfer-hosp-time] temp-transfer-hosp-ts2
  let temp-transfer-hosp-ts3-ls sort-on [transfer-hosp-time] temp-transfer-hosp-ts3
  set transfer-hosp-ts2-ls temp-transfer-hosp-ts2-ls
  set transfer-hosp-ts3-ls temp-transfer-hosp-ts3-ls

  if length transfer-hosp-ts2-ls > 0[

    ; update status cas agentset - TS2
    ask temp-transfer-hosp-ts2 [
      move-to one-of patches with [pcolor = 25]
      set transfer-hosp? false
      set on-route-hospital? true
    ]

    ; update PMA lists
    ask target-agent[
      foreach temp-transfer-hosp-ts2-ls [
        a ->
        let a-pos position a transfer-hosp-q-ts2
        set transfer-hosp-q-t-ts2 remove-item a-pos transfer-hosp-q-t-ts2
        set transfer-hosp-q-ts2 remove a transfer-hosp-q-ts2

      ]
    ]
  ]

  if length transfer-hosp-ts3-ls > 0[
    ; update status cas agentset - TS3

    ask temp-transfer-hosp-ts3 [
      move-to one-of patches with [pcolor = 25]
      set transfer-hosp? false
      set on-route-hospital? true
    ]

    ; update PMA lists
    ask target-agent[
      foreach temp-transfer-hosp-ts3-ls [
        a ->
        let a-pos position a transfer-hosp-q-ts3
        set transfer-hosp-q-ts3 remove a transfer-hosp-q-ts3
        set transfer-hosp-q-t-ts3 remove-item a-pos transfer-hosp-q-t-ts3

      ]
    ]
  ]

end

; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (Both A/B) : locate hospital id and node

to find-hospital

  let temp-target-agent reduce sentence [self] of hospitals with [nid = "PtP Hospital"]
  let temp-hosp-node reduce sentence [node-hosp] of hospitals with [nid = "PtP Hospital"]

  set target-agent temp-target-agent
  set node-agent-at temp-hosp-node

end

; ----------------------------------------------------------------------------------------------------------------------- (B only func) : At hospital Select which PMA to travel to

to target-agent-at-start-at-PMA-B [temp-target-agent]

  ; input variables : temp-target-agent - Holds the PMA name

  let temp-transfer-cas-ts2 cas-agents with [deceased? = false and TS = 2 and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-target-agent]
  let temp-transfer-cas-ts3 cas-agents with [deceased? = false and TS = 3 and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-target-agent]
  let temp-transfer-cas-ts2-ls sort-on [transfer-hosp-time] temp-transfer-cas-ts2
  let temp-transfer-cas-ts3-ls sort-on [transfer-hosp-time] temp-transfer-cas-ts3

  let resc-agent-cap-counter 0
  while [(resc-agent-cap-counter < resc-agent-cap) and (length temp-transfer-cas-ts2-ls + length temp-transfer-cas-ts3-ls > 0)][

    ; TS2-transfer-hosp > 0
    ifelse length temp-transfer-cas-ts2-ls > 0[

     ; cas-agent targeted
     let ts2-cas-targeted item 0 temp-transfer-cas-ts2-ls

     ; update casualty status
     ask ts2-cas-targeted[
        set targeted-transfer? true
        set targeted-transfer-by myself
        set temp-transfer-cas-ts2-ls remove ts2-cas-targeted temp-transfer-cas-ts2-ls
        move-to one-of patches with [pcolor = 25]
      ]

      ; Update PMA lists
      ; Note this function must NOT update PMA lists as cas-agents are only targeted and NOT collected

    ]
    ; TS2-transfer-hosp = 0 but transfer-hosp-TS3 > 0
    [

      ; cas-agent targeted
     let ts3-cas-targeted item 0 temp-transfer-cas-ts3-ls

     ; update casualty status
     ask ts3-cas-targeted[
        set targeted-transfer? true
        set targeted-transfer-by myself
        set temp-transfer-cas-ts3-ls remove ts3-cas-targeted temp-transfer-cas-ts3-ls
        move-to one-of patches with [pcolor = 25]
      ]

      ; update PMA lists
      ; Note this function must NOT update PMA lists as cas-agents are only targeted and NOT collected

    ]
    set resc-agent-cap-counter resc-agent-cap-counter + 1
  ]

end

; +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ (A/B) Targets agent at PMA from hospital

to target-agent-at-pma-from-hospital-AB
  ; 4 conditions
  ; 1. VH Selected
  ; 2. SM Selected
  ; 3. either one
  ; 4. searching

  ; Store PMA-ids in temp varaibles
  let temp-pma-id-vh reduce sentence [self] of PMA's with [nid = "Vieux Habitants PMA"]
  let temp-pma-id-sm reduce sentence [self] of PMA's with [nid = "Sainte Marie PMA"]

  ; Casualties at Vieux Habitants
  let temp-transfer-cas-ts2-vh cas-agents with [deceased? = false and TS = 2 and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-pma-id-vh]
  let temp-transfer-cas-ts3-vh cas-agents with [deceased? = false and TS = 3 and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-pma-id-vh]
  let temp-transfer-cas-ts23-vh cas-agents with [deceased? = false and (TS = 2 or TS = 3) and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-pma-id-vh]

  ; Casulaties at Sainte Marie
  let temp-transfer-cas-ts2-sm cas-agents with [deceased? = false and TS = 2 and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-pma-id-sm]
  let temp-transfer-cas-ts3-sm cas-agents with [deceased? = false and (TS = 3) and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-pma-id-sm]
  let temp-transfer-cas-ts23-sm cas-agents with [deceased? = false and (TS = 2 or TS = 3) and targeted-transfer? = false and transfer-hosp? = true and pma-at = temp-pma-id-sm]

  let temp-transfer-cas-ts2-vh-ls sort-on [transfer-hosp-time] temp-transfer-cas-ts2-vh
  let temp-transfer-cas-ts3-vh-ls sort-on [transfer-hosp-time] temp-transfer-cas-ts3-vh
  let temp-transfer-cas-ts2-sm-ls sort-on [transfer-hosp-time] temp-transfer-cas-ts2-sm
  let temp-transfer-cas-ts3-sm-ls sort-on [transfer-hosp-time] temp-transfer-cas-ts3-sm

  let agent-targeted nobody
  let temp-node-pma-vh reduce sentence [node-pma] of PMA's with [nid = "Vieux Habitants PMA"]
  let temp-node-pma-sm reduce sentence [node-pma] of PMA's with [nid = "Sainte Marie PMA"]
  let temp-target-agent-vh reduce sentence [self] of PMA's with [nid = "Vieux Habitants PMA"]
  let temp-target-agent-sm reduce sentence [self] of PMA's with [nid = "Sainte Marie PMA"]


  (ifelse

    ; VH transfer Q > SM transfer Q ------------------------------------------------------------------------------

    count temp-transfer-cas-ts23-vh > count temp-transfer-cas-ts23-sm[


      let resc-agent-cap-counter 0

      while [(resc-agent-cap-counter < resc-agent-cap) and (length temp-transfer-cas-ts2-vh-ls + length temp-transfer-cas-ts3-vh-ls > 0)][

        ; Check if there are any TS2 agents in VH transfer agent list

        ifelse length temp-transfer-cas-ts2-vh-ls > 0[

          ; let casualty picked be the first item in the list
          let ts2-cas-targeted item 0 temp-transfer-cas-ts2-vh-ls

          ; update casualty status
          ask ts2-cas-targeted[
            set targeted-transfer? true
            set targeted-transfer-by myself
            set temp-transfer-cas-ts2-vh-ls remove ts2-cas-targeted temp-transfer-cas-ts2-vh-ls
          ]
        ]

        ; if not check for TS3 agents in VH transfer agent list

        [

          let ts3-cas-targeted item 0 temp-transfer-cas-ts3-vh-ls

          ;update casualty status
          ask ts3-cas-targeted[
            set targeted-transfer? true
            set targeted-transfer-by myself
            set temp-transfer-cas-ts3-vh-ls remove ts3-cas-targeted temp-transfer-cas-ts3-vh-ls
          ]
        ]

        ;update while loop counter
        set resc-agent-cap-counter (resc-agent-cap-counter + 1)

      ]

      set node-agent-at temp-node-pma-vh
      set target-agent temp-target-agent-vh
    ]

    ; SM transfer Q > VH transfer Q ---------------------------------------------------------------------------------


    count temp-transfer-cas-ts23-vh < count temp-transfer-cas-ts23-sm[

      let resc-agent-cap-counter 0
      while [(resc-agent-cap-counter < resc-agent-cap) and (length temp-transfer-cas-ts2-sm-ls + length temp-transfer-cas-ts3-sm-ls > 0)][

        ; Check if there are any TS2 agents in VH transfer agent list

        ifelse length temp-transfer-cas-ts2-sm-ls > 0[

          let ts2-cas-targeted item 0 temp-transfer-cas-ts2-sm-ls

          ; update casualty status
          ask ts2-cas-targeted[
            set targeted-transfer? true
            set targeted-transfer-by myself
            set temp-transfer-cas-ts2-sm-ls remove ts2-cas-targeted temp-transfer-cas-ts2-sm-ls
          ]
        ]

        ; if not check for TS3 agents in VH transfer agent list

        [

          let ts3-cas-targeted item 0 temp-transfer-cas-ts3-sm-ls

          ; update casualty status
          ask ts3-cas-targeted[
            set targeted-transfer? true
            set targeted-transfer-by myself
            set temp-transfer-cas-ts3-sm-ls remove ts3-cas-targeted temp-transfer-cas-ts3-sm-ls
          ]
        ]
        set resc-agent-cap-counter (resc-agent-cap-counter + 1)

      ]
      set node-agent-at temp-node-pma-sm
      set target-agent temp-target-agent-sm
    ]

    ; VH transfer Q = SM transfer Q but either != 0 ----------------------------------------------------------------------


    (count temp-transfer-cas-ts23-vh = count temp-transfer-cas-ts23-sm) and (count temp-transfer-cas-ts23-vh > 0 or count temp-transfer-cas-ts23-sm > 0)[


      ; note if the queue's are the same it doesnt matter which PMA to go to as you need to clear both
      set target-agent one-of PMA's
      ifelse [nid] of target-agent = "Vieux Habitants PMA"[

        ; ---------- select Vieux Habitants ----------

        set node-agent-at temp-node-pma-sm

        let resc-agent-cap-counter 0

        while [(resc-agent-cap-counter < resc-agent-cap) and (length temp-transfer-cas-ts2-vh-ls + length temp-transfer-cas-ts3-vh-ls > 0)][

          ; Check if there are any TS2 agents in VH transfer agent list

          ifelse length temp-transfer-cas-ts2-vh-ls > 0[

            let ts2-cas-targeted item 0 temp-transfer-cas-ts2-vh-ls

            ; update casualty status
            ask ts2-cas-targeted[
              set targeted-transfer? true
              set targeted-transfer-by myself
              set temp-transfer-cas-ts2-vh-ls remove ts2-cas-targeted temp-transfer-cas-ts2-vh-ls
            ]
          ]

          ; if not check for TS3 agents in VH transfer agent list

          [

            let ts3-cas-targeted item 0 temp-transfer-cas-ts3-vh-ls

            ; Update casualty status
            ask ts3-cas-targeted[
              set targeted-transfer? true
              set targeted-transfer-by myself
              set temp-transfer-cas-ts3-vh-ls remove ts3-cas-targeted temp-transfer-cas-ts3-vh-ls
            ]
          ]
          set resc-agent-cap-counter (resc-agent-cap-counter + 1)

        ]
      ]
      [

        ; --------- select Sainte Marie PMA ---------

        set node-agent-at temp-node-pma-vh

        let resc-agent-cap-counter 0

        while [(resc-agent-cap-counter < resc-agent-cap) and (length temp-transfer-cas-ts2-sm-ls + length temp-transfer-cas-ts3-sm-ls > 0)][

          ; Check if there are any TS2 agents in VH transfer agent list

          ifelse length temp-transfer-cas-ts2-sm-ls > 0[

            let ts2-cas-targeted item 0 temp-transfer-cas-ts2-sm-ls

            ; update casualty staus
            ask ts2-cas-targeted[
              set targeted-transfer? true
              set targeted-transfer-by myself
              set temp-transfer-cas-ts2-sm-ls remove ts2-cas-targeted temp-transfer-cas-ts2-sm-ls
            ]
          ]

        ; if not check for TS3 agents in VH transfer agent list

          [

            let ts3-cas-targeted item 0 temp-transfer-cas-ts3-sm-ls

            ; update casualty status
            ask ts3-cas-targeted[
              set targeted-transfer? true
              set targeted-transfer-by myself
              set temp-transfer-cas-ts3-sm-ls remove ts3-cas-targeted temp-transfer-cas-ts3-sm-ls
            ]
          ]
          set resc-agent-cap-counter (resc-agent-cap-counter + 1)

        ]
      ]
    ]

    ; Go searching for rest of the casialties ----------------------------------------------------------------------------

    [
      if is-resc-agent-A? self[
        set mode "Searching !!!"

      ]

      if is-resc-agent-B? self[
        set mode "(B) Hospital -> PMA"
        set target-agent one-of PMA's
        set node-agent-at [node-pma] of target-agent
        find-path
      ]
    ]
  )

end




; ============================================================================================= PMA RELATED FUNCTIONS =====================================================================================

; =========================================================================================================================================================== Availability of space depending on time

to setup-pma-capacity

  let time-1 (pma-operational-t1)
  let time-2 (pma-operational-t2)

  if ticks >= time-1 and ticks < time-2 [
    set PMA-capacity pma-cap-t1
  ]
  if ticks >= time-2 [
    set PMA-capacity pma-cap-t2
  ]
end

; ============================================================================================================================================================ Move cas-agent from queue to stabilisation upon availability

to move-from-PMA-queue-stabilise
  ;move-from-queue-stabilise: Function to move TS1 & TS23 pop agents from Queue to Stabilisation at PMA

  ; to add TS23 from Queue to stabilisation
  while [ length Queue-TS23 > 0 and ((length stabilise-TS23 + length stabilise-TS1) < PMA-capacity)][
    let agent-to-move item 0 Queue-TS23
    let agent-pos position agent-to-move Queue-TS23
    set stabilise-TS23 lput agent-to-move stabilise-TS23
    set stabilise-t-TS23 lput ticks stabilise-t-TS23
    set Queue-t-TS23 remove-item agent-pos Queue-t-TS23
    set Queue-TS23 remove agent-to-move Queue-TS23


    ask agent-to-move [
      if PMA-name = "Vieux Habitants PMA" [
        move-to one-of patches with [pcolor = 55] ;Stabilise-TS23 VH --done
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
      ]
      if PMA-name = "Sainte Marie PMA" [
        move-to one-of patches with [pcolor = 65] ; Stabilise-TS23 SM --done
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
      ]
    ]
  ]
  ;to add TS1 pop agents from Queue to Stabilisation
  while [length Queue-TS1 > 0 and ((length stabilise-TS23 + length stabilise-TS1) < PMA-capacity)][
    let agent-to-move item 0 Queue-TS1
    let agent-pos position agent-to-move Queue-TS1
    set stabilise-TS1 lput agent-to-move stabilise-TS1
    set stabilise-t-TS1 lput ticks stabilise-t-TS1
    set Queue-t-TS1 remove-item agent-pos Queue-t-TS1
    set Queue-TS1 remove agent-to-move Queue-TS1

    ask agent-to-move [
      if PMA-name = "Vieux Habitants PMA" [
        move-to one-of patches with [pcolor = 55] ;Stabilise-TS1 --done
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
    ]
      if PMA-name = "Sainte Marie PMA" [
        move-to one-of patches with [pcolor = 65] ;Stabilise-TS1 --done
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
      ]
    ]
  ]
end

; ======================================================================================================================================================== Stabilisation -> Transfer Hospital

to move-from-stabalise-to-await-transfer-hosp

  if nid = "Vieux Habitants PMA"[
    foreach stabilise-t-TS23[
      t ->
      let time-passed ticks - t

      ifelse time-passed >= stabilisation-t[
        let pos position t stabilise-t-TS23
        let hospitalise-agent item pos stabilise-TS23
        let hospitalise-agent-ts [TS] of hospitalise-agent

        ; remove stabalised casualty from the respective PMA lists
        set stabilise-t-TS23 remove-item pos stabilise-t-TS23
        set stabilise-TS23 remove hospitalise-agent stabilise-TS23

        ; add stabalised casualty to awaiting transfer lists
        ifelse hospitalise-agent-TS = 2[
          set transfer-hosp-q-t-TS2 lput ticks transfer-hosp-q-t-TS2
          set transfer-hosp-q-TS2 lput hospitalise-agent transfer-hosp-q-TS2
        ]
        [
          set transfer-hosp-q-t-TS3 lput ticks transfer-hosp-q-t-TS3
          set transfer-hosp-q-TS3 lput hospitalise-agent transfer-hosp-q-TS3
        ]

        ; update casualty agents owned variables
        ask hospitalise-agent [
          move-to one-of patches with [pcolor = 56]
          set in-stabilisation? False
          set transfer-hosp? True
          set transfer-hosp-time ticks
        ]
      ]
      [
        ; else statement : if time hasnt exceeded stabilisation-t, do nothing !
      ]
    ]
  ]

  if nid = "Sainte Marie PMA"[
    foreach stabilise-t-TS23[
      t ->
      let time-passed ticks - t
      ifelse time-passed >= stabilisation-t[
        let pos position t stabilise-t-TS23
        let hospitalise-agent item pos stabilise-TS23
        let hospitalise-agent-ts [TS] of hospitalise-agent

        ; remove stabalised casualty from the respective PMA lists
        set stabilise-t-TS23 remove-item pos stabilise-t-TS23
        set stabilise-TS23 remove hospitalise-agent stabilise-TS23

        ; add stabalised casualty to awaiting transfer lists
        ifelse hospitalise-agent-TS = 2[
          set transfer-hosp-q-t-TS2 lput ticks transfer-hosp-q-t-TS2
          set transfer-hosp-q-TS2 lput hospitalise-agent transfer-hosp-q-TS2
        ]
        [
          set transfer-hosp-q-t-TS3 lput ticks transfer-hosp-q-t-TS3
          set transfer-hosp-q-TS3 lput hospitalise-agent transfer-hosp-q-TS3
        ]

        ; update casualty agents owned variables
        ask hospitalise-agent [
          move-to one-of patches with [pcolor = 66]
          set in-stabilisation? False
          set transfer-hosp? True
          set transfer-hosp-time ticks
        ]
      ]
      [
        ; else statement : if time hasnt exceeded stabilisation-t, do nothing !
      ]
    ]
  ]


end

; ============================================================================================================================================ Stabilisation -> TS1 recovered

;TS1-recovered: Function to send TS1 cas-agents home
to TS1-recovered
  foreach stabilise-t-TS1[
    i ->
    let time-passed ticks - i
    ifelse time-passed >= stabilisation-t[
      let pos position i stabilise-t-TS1
      let recovered-agent item pos stabilise-TS1

      ;add recovered--agent and recovered-time to global list
      set recovered-TS1 lput recovered-agent recovered-TS1
      set recovered-time-TS1 lput ticks recovered-Time-TS1

      set stabilise-t-TS1 remove-item pos stabilise-t-TS1
      set stabilise-TS1 remove recovered-agent stabilise-TS1

      ask recovered-agent[
        move-to one-of patches with [pcolor = 14]
        set in-stabilisation? False
        set recovered? True
        set recovered-time ticks
      ]
    ]
    [
    ;else statement: time passed < stabilisation-t dont do anything.
    ]
  ]
end




; --------------------------------------------------------------------- RESET-LISTS-VARIABLES-HELI : AT HOSPITAL AFTER UNLOADING CASUALTIES RENEW LISTS (FOR HELI AGENTS ONLY !!!) -----------------------------------------------------------------------------------

to reset-lists-variables-heli

  set rescued-agents-list []
  set collected-agents-TS2 []
  set collected-agents-TS3 []
  set target-agent nobody
  set patch-agent-at nobody
  set transfer-time Transfer-time-mins
  set rescue-time rescue-time-mins

end



; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Hospital Functions
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  Select BB / NBB
to select-bed-type
  let temp-TS2-list transfer-hosp-TS2-ls
  let temp-TS3-list transfer-hosp-TS3-ls
  ask hospitals[
   foreach temp-TS2-list[
     i ->
     (ifelse
        length Burn-Beds-TS2 + length Burn-Beds-TS3 < no-bb[
          set Burn-Beds-TS2 lput i Burn-Beds-TS2
          set Burn-Beds-Time-TS2 lput ticks Burn-Beds-Time-TS2
        ]
        length Non-Burn-Beds-TS2 + length Non-Burn-Beds-TS3 < no-nbb[
          set Non-Burn-Beds-TS2 lput i Non-Burn-Beds-TS2
          set Non-Burn-Beds-time-TS2 lput ticks Non-Burn-Beds-time-TS2
        ]
        [
          set Hospital-Queue-TS2 lput i hospital-Queue-TS2
          set Hospital-Queue-Time-TS2 lput ticks Hospital-Queue-Time-TS2

        ]
      )
  ]
    foreach temp-TS3-list[
      i ->
      (ifelse
        length Burn-Beds-TS2 + length Burn-Beds-TS3 < no-bb[
          set Burn-Beds-TS3 lput i Burn-Beds-TS3
          set Burn-Beds-Time-TS3 lput ticks Burn-Beds-Time-TS3
        ]
        length Non-Burn-Beds-TS2 + length Non-Burn-Beds-TS3 < no-nbb[
          set Non-Burn-Beds-TS3 lput i Non-Burn-Beds-TS3
          set Non-Burn-Beds-time-TS3 lput ticks Non-Burn-Beds-time-TS3
        ]
        [
          set Hospital-Queue-TS3 lput i hospital-Queue-TS3
          set Hospital-Queue-Time-TS3 lput ticks Hospital-Queue-Time-TS3

        ]
      )
    ]

  ;To visualise Queue, move agents to designated patches
    foreach Burn-Beds-TS2[
      i ->
      ask i[
        ask patch-here[
          if pcolor != 94 [
            ask myself [
              move-to one-of patches with [pcolor = 94]
              set hidden? False
              set on-route-hospital? False
              set in-Burn-Beds? True
              set treated? True
              set BB-admission-time ticks
            ]
          ]
        ]
      ]
    ]
    foreach Burn-Beds-TS3[
      i ->
      ask i[
        ask patch-here[
          if pcolor != 94 [
            ask myself [
              move-to one-of patches with [pcolor = 94]
              set hidden? False
              set on-route-hospital? False
              set in-Burn-Beds? True
              set treated? True
              set BB-admission-time ticks
            ]
          ]
        ]
      ]
    ]
    foreach Non-Burn-Beds-TS2[
      i ->
      ask i[
        ask patch-here[
          if pcolor != 95 [
            ask myself [
              move-to one-of patches with [pcolor = 95]
              set hidden? False
              set on-route-hospital? False
              set in-Non-Burn-Beds? True
              set treated? True
              set NBB-admission-time ticks
            ]
          ]
        ]
      ]
    ]
    foreach Non-Burn-Beds-TS3[
      i ->
      ask i[
        ask patch-here[
          if pcolor != 95 [
            ask myself [
              move-to one-of patches with [pcolor = 95]
              set hidden? False
              set on-route-hospital? False
              set in-Non-Burn-Beds? True
              set treated? True
              set NBB-admission-time ticks
            ]
          ]
        ]
      ]
    ]
    foreach Hospital-Queue-TS2[
      i ->
      ask i[
        ask patch-here[
          if pcolor != 84 [
            ask myself [
              move-to one-of patches with [pcolor = 84]
              set hidden? False
              set on-route-hospital? False
              set in-Hospital-Queue? True
              set Hospital-Queue-time ticks
            ]
          ]
        ]
      ]
    ]
    foreach Hospital-Queue-TS3[
      i ->
      ask i[
        ask patch-here[
          if pcolor != 84 [
            ask myself [
              move-to one-of patches with [pcolor = 84]
              set hidden? False
              set on-route-hospital? False
              set in-Hospital-Queue? True
              set Hospital-Queue-time ticks
            ]
          ]
        ]
      ]
    ]
  ]

  ; empty rescue agent lists
  set transfer-hosp-TS2-ls []
  set transfer-hosp-TS3-ls []

end

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NBB -> BB

to from-non-to-burn-beds
  foreach Non-Burn-Beds-TS2[
    i ->
    ifelse length Burn-beds-TS2 + length Burn-Beds-TS3 < no-bb[
      set Burn-beds-TS2 lput i Burn-beds-TS2
      set Burn-Beds-time-TS2 lput ticks Burn-Beds-time-TS2

      let i-pos position i Non-Burn-Beds-TS2
      set Non-Burn-Beds-TS2 remove-item i-pos Non-Burn-Beds-TS2
      set Non-Burn-Beds-TS2 remove i Non-Burn-Beds-TS2

      ask i [
        move-to one-of patches with [pcolor = 94]
        set in-Non-Burn-Beds? False
        set in-Burn-Beds? True
        set BB-admission-Time ticks
      ]
    ]
    [
     ;Else statment: If no of TS2 and TS3 in burn beds exceed or equal then dont do anything
    ]
  ]
  foreach Non-Burn-Beds-TS3[
    i ->
    ifelse length Burn-Beds-TS2 + length Burn-Beds-TS3 < no-bb[
      set Burn-Beds-TS3 lput i Burn-Beds-TS3
      set Burn-Beds-time-TS3 lput ticks Burn-Beds-Time-TS3

      let i-pos position i Non-Burn-Beds-TS3
      set Non-Burn-Beds-TS3 remove-item i-pos Non-Burn-Beds-TS3
      set Non-Burn-Beds-TS3 remove i Non-Burn-Beds-TS3

        ask i [
        move-to one-of patches with [pcolor = 94]
        set in-Non-Burn-Beds? False
        set in-Burn-Beds? True
        set BB-admission-time ticks
      ]
    ]
    [
      ;Else statment: If no of TS2 and TS3 in burn beds exceed or equal then dont do anything
    ]
  ]
end

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Hospital Queue -> NBB

to from-Hospital-Queue-to-Non-Burn-Beds
  foreach Hospital-Queue-TS2[
    i ->
    if ((length Non-Burn-beds-TS2) + (length Non-Burn-Beds-TS3)) < no-nbb[
      set Non-Burn-Beds-TS2 lput i Non-Burn-Beds-TS2
      set Non-burn-Beds-Time-TS2 lput ticks Non-Burn-Beds-time-TS2

      let i-pos position i  Hospital-Queue-TS2
      set Hospital-Queue-Time-TS2 remove-item i-pos Hospital-Queue-Time-TS2
      set Hospital-Queue-TS2 remove i Hospital-Queue-TS2

      ask i[
        move-to one-of patches with [pcolor = 95]
        set in-Hospital-Queue? False
        set in-Non-Burn-Beds? True
        set treated? True
        set NBB-admission-time ticks
      ]
    ]
  ]
    foreach Hospital-Queue-TS3[
    i ->
    if ((length Non-Burn-beds-TS2) + (length Non-Burn-Beds-TS3)) < no-nbb[
      set Non-Burn-Beds-TS3 lput i Non-Burn-Beds-TS3
      set Non-burn-Beds-Time-TS3 lput ticks Non-Burn-Beds-time-TS3

      let i-pos position i  Hospital-Queue-TS3
      set Hospital-Queue-Time-TS3 remove-item i-pos Hospital-Queue-Time-TS3
      set Hospital-Queue-TS3 remove i Hospital-Queue-TS3

      ask i[
        move-to one-of patches with [pcolor = 95]
        set in-Hospital-Queue? False
        set in-Non-Burn-Beds? True
        set treated? True
        set NBB-admission-time ticks
      ]
    ]
  ]
end

; ``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````` Renew lists : Remove deceased agents

; `+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+``+`+`+`+` (Resc A - Renew lists)

to renew-resc-list-A
  foreach Rescued-agents-list[
    i ->
    ask i[
      if deceased? = true[
        let agent-to-be-removed self
        ask myself [
          set rescued-agents-list remove agent-to-be-removed rescued-agents-list
        ]
      ]
    ]
  ]

  foreach transfer-hosp-TS2-ls[
    i ->
    ask i[
      if deceased? = true[
        let agent-to-be-removed self
        ask myself[
          set transfer-hosp-TS2-ls remove agent-to-be-removed transfer-hosp-TS2-ls
        ]
      ]
    ]
  ]

    foreach transfer-hosp-TS3-ls[
    i ->
    ask i[
      if deceased? = true[
        let agent-to-be-removed self
        ask myself[
          set transfer-hosp-TS3-ls remove agent-to-be-removed transfer-hosp-TS3-ls
        ]
      ]
    ]
  ]

end

;`-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-`-`-`-`-``-`-` (Resc B - Renew lists)

to renew-resc-list-B
  foreach transfer-hosp-TS2-ls[
    i ->
    ask i[
      if deceased? = true[
        let agent-to-be-removed self
        ask myself [
          set transfer-hosp-TS2-ls remove agent-to-be-removed transfer-hosp-TS2-ls
        ]
      ]
    ]
  ]
   foreach transfer-hosp-TS3-ls[
     i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          set transfer-hosp-TS3-ls remove agent-to-be-removed transfer-hosp-TS3-ls
        ]
      ]
    ]
  ]
end

; `=`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`==`=`=`=`= (PMA - Renew lists)

to renew-PMA-lists

  foreach Queue-TS23[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Queue-TS23
          set Queue-t-TS23 remove-item agent-pos Queue-t-TS23
          set Queue-TS23 remove agent-to-be-removed Queue-TS23
        ]
      ]
    ]
  ]

  foreach stabilise-TS23[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed stabilise-TS23
          set stabilise-t-TS23 remove-item agent-pos stabilise-t-TS23
          set stabilise-TS23 remove agent-to-be-removed stabilise-TS23
        ]
      ]
    ]
  ]

  foreach transfer-hosp-q-TS2[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself[
          let agent-pos position agent-to-be-removed transfer-hosp-q-TS2
          set transfer-hosp-q-t-TS2 remove-item agent-pos transfer-hosp-q-t-TS2
          set transfer-hosp-q-TS2 remove agent-to-be-removed transfer-hosp-q-TS2
        ]
      ]
    ]
  ]

  foreach transfer-hosp-q-TS3[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself[
          let agent-pos position agent-to-be-removed transfer-hosp-q-TS3
          set transfer-hosp-q-t-TS3 remove-item agent-pos transfer-hosp-q-t-TS3
          set transfer-hosp-q-TS3 remove agent-to-be-removed transfer-hosp-q-TS3
        ]
      ]
    ]
  ]
end

; `~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~ (Hospital - Renew lists)

to renew-hospital-lists
    foreach Burn-Beds-TS2[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Burn-Beds-TS2
          set Burn-Beds-Time-TS2 remove-item agent-pos Burn-Beds-Time-TS2
          set Burn-Beds-TS2 remove agent-to-be-removed Burn-Beds-TS2
        ]
      ]
    ]
  ]
  foreach Burn-Beds-TS3[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Burn-Beds-TS3
          set Burn-Beds-Time-TS3 remove-item agent-pos Burn-Beds-Time-TS3
          set Burn-Beds-TS3 remove agent-to-be-removed Burn-Beds-TS3
        ]
      ]
    ]
  ]
  foreach Non-Burn-Beds-TS2[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
           let agent-pos position agent-to-be-removed Non-Burn-Beds-TS2
          set Non-Burn-Beds-Time-TS2 remove-item agent-pos Non-Burn-Beds-Time-TS2
          set Non-Burn-Beds-TS2 remove agent-to-be-removed Non-Burn-Beds-TS2
        ]
      ]
    ]
  ]
  foreach Non-Burn-Beds-TS3[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Non-Burn-Beds-TS3
          set Non-Burn-Beds-Time-TS3 remove-item agent-pos Non-Burn-Beds-Time-TS3
          set Non-Burn-Beds-TS3 remove agent-to-be-removed Non-Burn-Beds-TS3
        ]
      ]
    ]
  ]
    foreach Hospital-Queue-TS2[
    i ->
    ask i[
      if  deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Hospital-Queue-TS2
          set Hospital-Queue-Time-TS2 remove-item agent-pos Hospital-Queue-Time-TS2
          set Hospital-Queue-TS2 remove agent-to-be-removed Hospital-Queue-TS2
        ]
      ]
    ]
  ]
  foreach Hospital-Queue-TS3[
    i ->
    ask i[
      if  deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Hospital-Queue-TS3
          set Hospital-Queue-Time-TS3 remove-item agent-pos Hospital-Queue-Time-TS3
          set Hospital-Queue-TS3 remove agent-to-be-removed Hospital-Queue-TS3
        ]
      ]
    ]
  ]


end

; `^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^`^ (Helicopter - lists)

to renew-helicopter-list
  foreach Rescued-Agents-list[
    i ->
    ask i[
      if deceased? = True[
       let agent-to-be-removed self
       ask myself[
         set rescued-agents-list remove agent-to-be-removed rescued-agents-list
        ]
      ]
    ]
  ]
end

; ````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````` Update lists

to update-TS3-lists
  if ((awaiting-Rescue? = True) and (not member? self Decd-AwaResc-TS3)) [
    set Decd-AwaResc-TS3 lput self Decd-AwaResc-TS3
    set Decd-AwaResc-time-TS3 lput ticks Decd-AwaResc-time-TS3
  ]
  if ((on-route-PMA? = True) and (not member? self Decd-onRout-PMA-TS3))[
    set Decd-OnRout-PMA-TS3 lput self Decd-OnRout-PMA-TS3
    set Decd-OnRout-PMA-time-TS3 lput ticks Decd-OnRout-PMA-time-TS3
  ]
  if ((in-Queue? = True) and (not member? self Decd-Queue-TS3))[
    set Decd-Queue-TS3 lput self Decd-Queue-TS3
    set Decd-Queue-Time-TS3 lput ticks Decd-Queue-Time-TS3
  ]
  if ((in-stabilisation? = True) and (not member? self Decd-Stabilise-TS3))[
    set Decd-stabilise-TS3 lput self Decd-stabilise-TS3
    set Decd-stabilise-time-TS3 lput ticks Decd-stabilise-time-TS3
  ]
  if ((transfer-hosp? = True) and (not member? self Decd-transfer-hosp-TS3))[
    set Decd-transfer-hosp-TS3 lput self Decd-transfer-hosp-TS3
    set Decd-transfer-hosp-time-TS3 lput ticks Decd-transfer-hosp-time-TS3
  ]
  if ((on-route-hospital? = True) and (not member? self Decd-OnRout-hosp-TS3))[
    set Decd-OnRout-hosp-TS3 lput self Decd-OnRout-hosp-TS3
    set Decd-OnRout-hosp-time-TS3 lput ticks Decd-OnRout-hosp-time-TS3
  ]
  if ((in-Burn-Beds? = True) and (not member? self Decd-BB-TS3)) [
    set Decd-BB-TS3 lput self Decd-BB-TS3
    set Decd-BB-time-TS3 lput ticks Decd-BB-time-TS3
  ]
  if ((in-Non-Burn-Beds? = True) and (not member? self Decd-NBB-TS3)) [
    set Decd-NBB-TS3 lput self Decd-NBB-TS3
    set Decd-NBB-time-TS3 lput ticks Decd-NBB-time-TS3
  ]
  if ((in-Hospital-Queue? = True) and (not member? self Decd-Hosp-Q-TS3)) [
    set Decd-Hosp-Q-TS3 lput self Decd-Hosp-Q-TS3
    set Decd-Hosp-Q-time-TS3 lput ticks Decd-Hosp-Q-time-TS3
  ]
end

to update-TS2-BB-lists
  if ((in-Burn-Beds? = True) and (not member? self Decd-BB-TS2)) [
    set Decd-BB-TS2 lput self Decd-BB-TS2
    set Decd-BB-time-TS2 lput ticks Decd-BB-time-TS2
  ]
end

to update-TS2-NBB-lists
  if ((in-Non-Burn-Beds? = True) and (not member? self Decd-NBB-TS2)) [
    set Decd-NBB-TS2 lput self Decd-NBB-TS2
    set Decd-NBB-time-TS2 lput ticks Decd-NBB-time-TS2
  ]
end

to update-rest-of-TS2-lists
  if ((awaiting-Rescue? = True) and (not member? self Decd-AwaResc-TS2)) [
    set Decd-AwaResc-TS2 lput self Decd-AwaResc-TS2
    set Decd-AwaResc-time-TS2 lput ticks Decd-AwaResc-time-TS2
  ]
  if ((on-route-PMA? = True) and (not member? self Decd-onRout-PMA-TS2))[
    set Decd-OnRout-PMA-TS2 lput self Decd-OnRout-PMA-TS2
    set Decd-OnRout-PMA-time-TS2 lput ticks Decd-OnRout-PMA-time-TS2
  ]
  if ((in-Queue? = True) and (not member? self Decd-Queue-TS2))[
    set Decd-Queue-TS2 lput self Decd-Queue-TS2
    set Decd-Queue-Time-TS2 lput ticks Decd-Queue-Time-TS2
  ]
  if ((in-stabilisation? = True) and (not member? self Decd-Stabilise-TS2))[
    set Decd-stabilise-TS2 lput self Decd-stabilise-TS2
    set Decd-stabilise-time-TS3 lput ticks Decd-stabilise-time-TS3
  ]
  if ((transfer-hosp? = True) and (not member? self Decd-transfer-hosp-TS2))[
    set Decd-transfer-hosp-TS2 lput self Decd-transfer-hosp-TS2
    set Decd-transfer-hosp-time-TS2 lput ticks Decd-transfer-hosp-time-TS2
  ]
  if ((on-route-hospital? = True) and (not member? self Decd-OnRout-hosp-TS2))[
    set Decd-OnRout-hosp-TS2 lput self Decd-OnRout-hosp-TS2
    set Decd-OnRout-hosp-time-TS2 lput ticks Decd-OnRout-hosp-time-TS2
  ]
   if ((in-Hospital-Queue? = True) and (not member? self Decd-Hosp-Q-TS2)) [
    set Decd-Hosp-Q-TS2 lput self Decd-Hosp-Q-TS2
    set Decd-Hosp-Q-time-TS2 lput ticks Decd-Hosp-Q-time-TS2
  ]
end

; `````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````APPLY MORATLITY RATE

to apply-mortality-rates

  ;```````````````````````````````````````````````````````````````````````````` Mortality rate for TS3 agents are constant throughout model run
  foreach (range 240 7200 60)[
    i ->
    if ticks = i[
      let agent-pecent 0.8 * (count cas-agents with [TS = 3 and Deceased? = False])
      ask n-of round agent-pecent (cas-agents with [TS = 3 and Deceased? = False]) [
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 13
        set size 7
      ]
       ask cas-agents with [TS = 3 and Deceased? = True][
        update-TS3-lists
      ]
    ]
  ]

  ;define agent sets for TS2 based on their current status to apply appropriate mortailty rate
  let TS2-BB-treat cas-agents with [TS = 2 and in-Burn-beds? = True and Deceased? = False]
  let TS2-NB-treat cas-agents with [TS = 2 and in-Non-Burn-beds? = True and deceased? = False]
  let TS2-pretreat cas-agents with [TS = 2 and (in-Burn-beds? = False and in-Non-Burn-Beds? = False) and Deceased? = False]

  ; `~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~mortality rate TS2 in Burned Beds
  foreach (range 240 7200 60)[
    i ->
    if ticks = i[
      let agent-percent 0.00167 * (count TS2-BB-treat)
      ask n-of round agent-percent (TS2-BB-Treat) [
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
       ask cas-agents with [TS = 2 and Deceased? = True][
         Update-TS2-BB-lists
      ]
    ]
  ]

  ; `~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~`~ mortality rate TS2 in Non Burned Beds
  foreach (range 240 1440 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0017 * (count TS2-NB-treat)
      ask n-of round agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
  foreach (range 1440 2880 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0066 * (count TS2-NB-treat)
      ask n-of round agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
  foreach (range 2880 4320 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0092 * (count TS2-NB-treat)
      ask n-of round agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
  foreach (range 4320 5760 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0063 * (count TS2-NB-treat)
      ask n-of round agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
 foreach (range 5760 7200 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0063 * (count TS2-NB-treat)
      ask n-of round agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]

  ; ````````````````````````````````````````````````````````````````````````````````````````````````````````` Mortality rate for rest of TS2
  foreach (range 240 480 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0125 * (count TS2-pretreat)
      ask n-of round agent-percent (TS2-pretreat)[
        set deceased? True
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-rest-of-TS2-lists
      ]
    ]
  ]
  foreach (range 480 720 60)[
    i ->
    if ticks = i[
    let agent-percent 0.075 * (count TS2-pretreat)
    ask n-of round agent-percent (TS2-pretreat)[
      set deceased? True
      set deceased-time ticks
      move-to one-of patches with [pcolor = 4]
      set hidden? False
      set shape "pentagon"
      set color 24
      set size 7
      ]
     ask cas-agents with [TS = 2 and Deceased? = True][
      Update-rest-of-TS2-lists
      ]
    ]
  ]
  foreach (range 720 1440 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0333 * (count TS2-pretreat)
      ask n-of round agent-percent (TS2-pretreat)[
        set deceased? True
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
      Update-rest-of-TS2-lists
      ]
    ]
  ]
  foreach (range 1440 7200 60)[
    i ->
    if ticks = i[
      let agent-percent 0.0417 * (count TS2-pretreat)
      ask n-of round agent-percent (TS2-pretreat)[
        set deceased? True
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
        set shape "pentagon"
        set color 24
        set size 7
      ]
      ask cas-agents with [TS = 2 and Deceased? = True][
        Update-rest-of-TS2-lists
      ]
    ]
  ]

  ; Renew the agent lists to remove any deceased agents

  ask resc-agents-A [renew-resc-list-A]
  ask resc-agents-B [renew-resc-list-B]
  ask PMA's [renew-pma-lists]
  ask hospitals [renew-hospital-lists]
  ask heli-agents[renew-helicopter-list]
end

;``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````` Keep track of Mortality per day


;(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((( END OF SUPPORT FUNCTIONS FOR GO PROCEDURE )))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))




;(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((( OTHER FUNCTIONS )))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

; called from interface by clicking buttons

; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINT-DECEASED-LISTS
to print-deceased-lists

  output-type "Recovered-TS1: " output-print Recovered-TS1
  output-type "Recovered-TS1 time: " output-print Recovered-time-TS1

  output-type "TS2 Deceased in Queue: " output-print Decd-Queue-TS2
  output-type "TS2 Deceased in Queue Time: " output-print Decd-Queue-Time-TS2
  output-type "TS3 Deceased in Queue: " output-print Decd-Queue-TS3
  output-type "TS3 Deceased in Queue Time: " output-print Decd-Queue-Time-TS3

  output-type "TS2 Deceased in Stabilisation: " output-print Decd-stabilise-TS2
  output-type "TS2 Decased in Stabilisation Time: " output-print Decd-stabilise-Time-TS2
  output-type "TS3 Deceased in Stabilisation: " output-print Decd-stabilise-TS3
  output-type "TS3 Deceased in Stabilisation Time: " output-print Decd-stabilise-Time-TS3

  output-type "TS2 Deceased in Burn Beds: " output-print Decd-BB-TS2
  output-type "TS2 Deceased in Burn Beds Time: " output-print Decd-BB-Time-TS2
  output-type "TS3 Deceased in Burn Beds: " output-print Decd-BB-TS3
  output-type "TS3 Deceased in Burn Beds Time: " output-print Decd-BB-Time-TS3

  output-type "TS2 Deceased in Non Burn Beds: " output-print Decd-NBB-TS2
  output-type "TS2 Deceased in Non Burn Beds Time: " output-print Decd-NBB-Time-TS2
  output-type "TS3 Deceased in Non Burn Beds: " output-print Decd-NBB-TS3
  output-type "TS3 Deceased in Non Burn Beds Time: " output-print Decd-NBB-Time-TS3

  output-type "TS2 Deceased in Hospital Queue: " output-print Decd-Hosp-Q-TS2
  output-type "TS2 Deceased in Hospital Queue Time: "output-print Decd-Hosp-Q-time-TS2
  output-type "TS3 Deceased in Hospital Queue: " output-print Decd-Hosp-Q-TS3
  output-type "TS3 Deceased in Hospital Queue Time: "output-print Decd-Hosp-Q-Time-TS3

  output-type "TS2 Deceased while Awaiting Rescue: " output-print Decd-AwaResc-TS2
  output-type "TS2 Deceased while Awaiting Rescue Time: " output-print Decd-AwaResc-Time-TS2
  output-type "TS3 Deceased while Awaiting Rescue: "output-print Decd-AwaResc-TS3
  output-type "TS3 Deceased while Awaiting Rescue Time: " output-print Decd-AwaResc-Time-TS3

  output-type "TS2 Deceased while on Route to PMA: " output-print Decd-OnRout-PMA-TS2
  output-type "TS2 Deceased while on Route to PMA Time: "output-print Decd-OnRout-PMA-Time-TS2
  output-type "TS3 Deceased while on Route to PMA: " output-print Decd-OnRout-PMA-TS3
  output-type "TS3 Deceased while on Route to PMA Time: " output-print Decd-OnRout-PMA-Time-TS3

  output-type "TS2 Deceased while on Route to hospital: " output-print Decd-OnRout-Hosp-TS2
  output-type "TS2 Deceased while on Route to hospital time: " output-print Decd-OnRout-Hosp-Time-TS2
  output-type "TS3 Deceased while on Route to hospital: " output-print Decd-OnRout-Hosp-TS3
  output-type "TS3 Deceased while on Route to hospital Time: " output-print Decd-OnRout-Hosp-Time-TS3

end

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINT-DECD-COUNT-LISTS

to print-dec-count-lists

  output-type "Recovered-TS1: " output-print length Recovered-TS1

  output-type "TS2 Deceased in Queue: " output-print length Decd-Queue-TS2
  output-type "TS3 Deceased in Queue: " output-print length Decd-Queue-TS3

  output-type "TS2 Deceased in Stabilisation: " output-print length Decd-stabilise-TS2
  output-type "TS3 Deceased in Stabilisation: " output-print length Decd-stabilise-TS3

  output-type "TS2 Deceased in Burn Beds: " output-print length Decd-BB-TS2
  output-type "TS3 Deceased in Burn Beds: " output-print length Decd-BB-TS3

  output-type "TS2 Deceased in Non Burn Beds: " output-print length Decd-NBB-TS2
  output-type "TS3 Deceased in Non Burn Beds: " output-print length Decd-NBB-TS3

  output-type "TS2 Deceased in Hospital Queue: " output-print length Decd-Hosp-Q-TS2
  output-type "TS3 Deceased in Hospital Queue: " output-print length Decd-Hosp-Q-TS3

  output-type "TS2 Deceased while Awaiting Rescue: " output-print length Decd-AwaResc-TS2
  output-type "TS3 Deceased while Awaiting Rescue: "output-print length Decd-AwaResc-TS3

  output-type "TS2 Deceased while on Route to PMA: " output-print length Decd-OnRout-PMA-TS2
  output-type "TS3 Deceased while on Route to PMA: " output-print length Decd-OnRout-PMA-TS3

  output-type "TS2 Deceased while on Route to hospital: " output-print length Decd-OnRout-Hosp-TS2
  output-type "TS3 Deceased while on Route to hospital: " output-print length Decd-OnRout-Hosp-TS3

  output-type "Total Deceased : " output-print (length Decd-Queue-TS2 + length Decd-Queue-TS3 + length Decd-stabilise-TS2 + length Decd-stabilise-TS3 + length Decd-BB-TS2 + length Decd-BB-TS3 + length Decd-NBB-TS2 + length Decd-NBB-TS3 + length Decd-Hosp-Q-TS2 + length Decd-Hosp-Q-TS3 + length Decd-AwaResc-TS2 + length Decd-AwaResc-TS3 + length Decd-OnRout-PMA-TS2 + length Decd-OnRout-PMA-TS3 + length Decd-OnRout-Hosp-TS2 + length Decd-OnRout-Hosp-TS3)

end

; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PRINT-COUNT-AGENTS

to print-count-agents

  ;let count-VH-Queue length of PMA's with [nid = "Vieux Habitants"][length ts1])
  let count-VH-queue-TS1 [length queue-ts1] of PMA's with [nid = "Vieux Habitants PMA"]
  let count-SM-queue-TS1 [length queue-ts1] of PMA's with [nid = "Sainte Marie"]
  let count-VH-stabilise-TS1 [length stabilise-ts1] of PMA's with [nid = "Vieux Habitants PMA"]
  let count-SM-stabilise-TS1 [length stabilise-ts1] of PMA's with [nid = "Sainte Marie PMA"]
  let count-VH-queue-TS23 [length queue-ts23] of PMA's with [nid = "Vieux Habitants PMA"]
  let count-SM-queue-TS23 [length queue-ts23] of PMA's with [nid = "Sainte Marie"]
  let count-VH-stabilise-TS23 [length stabilise-ts23] of PMA's with [nid = "Vieux Habitants PMA"]
  let count-SM-stabilise-TS23 [length stabilise-ts23] of PMA's with [nid = "Sainte Marie PMA"]

  output-print "Agents on route to PMA : " output-print count cas-agents-on patches with [pcolor = 125]


  output-type "Agents in VH Queue (TS1) : " output-print count-vh-queue-TS1
  output-type "Agents in SM Queue (TS1) : " output-print count-sm-queue-TS1
  output-type "Agents in VH Stabilisation (TS1) : " output-print count-vh-stabilise-TS1
  output-type "Agents in SM Stabilisation (TS1) : " output-print count-sm-stabilise-TS1

  output-type "Agents in VH Queue (TS23) : " output-print count-vh-queue-TS23
  output-type "Agents in SM Queue (TS23) : " output-print count-sm-queue-TS23
  output-type "Agents in VH Stabilisation (TS23) : " output-print count-vh-stabilise-TS23
  output-type "Agents in SM Stabilisation (TS23) : " output-print count-sm-stabilise-TS23

  output-type "Agents on route to Hospital (resc-agent-B) : " output-print count cas-agents-on patches with [pcolor = 25]
  output-type "Agents on route to Hospital (Helicopter) : " output-print count cas-agents-on patches with [pcolor = 34]

  output-type "Agents in hospital queue : " output-print count cas-agents-on patches with [pcolor = 84]
  output-type "Agents in Non Burn Beds : " output-print count cas-agents-on patches with [pcolor = 95]
  output-type "Agents in Burn Beds : " output-print count cas-agents-on patches with [pcolor = 94]

  output-type "Agents Deceased : " output-print count cas-agents-on patches with [pcolor = 4]
  output-type "Recovered-TS1 : " output-print count cas-agents-on patches with [pcolor = 14]

end

; ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((( END OF OTHER FUNCTIONS ))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

;                                                                                                                                                                                                              +++++++++++++++++++++++++++++++++++++++++++++++++++++
;                                                                                                                                                                                                              +   Casualty Rescue Treatment and Transport Model   +
;                                                                                                                                                                                                              +++++++++++++++++++++++++++++++++++++++++++++++++++++
@#$#@#$#@
GRAPHICS-WINDOW
333
11
1122
801
-1
-1
1.0
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
780
0
780
0
0
1
ticks
30.0

TEXTBOX
14
10
219
52
1. Press Setup to load & Go to run
11
0.0
1

BUTTON
19
32
83
65
Setup
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
89
32
152
65
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
19
229
308
290
3. Select Number of Rescue Agents, Vehical Speed (Km/h), Capacity of casualties that can be carried, Rescue time (mins) and Transfer times to PMA / Hospital (mins)
11
0.0
1

SLIDER
16
292
171
325
no-resc-agent-A
no-resc-agent-A
0
50
20.0
1
1
NIL
HORIZONTAL

CHOOSER
215
377
307
422
Speed
Speed
20 30 40 50 60 70 80
1

CHOOSER
15
376
107
421
Rescue-Time-Mins
Rescue-Time-Mins
10 20 30
0

CHOOSER
115
377
207
422
Transfer-Time-Mins
Transfer-Time-Mins
5 10 15
0

SLIDER
16
334
171
367
resc-agent-cap
resc-agent-cap
1
5
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
20
542
300
584
4. Select PMA opening hours and corresponding capacity at each time, Time Taken to stabilise casualties
11
0.0
1

SLIDER
18
593
160
626
pma-cap-t1
pma-cap-t1
0
50
5.0
1
1
ppl
HORIZONTAL

SLIDER
166
593
309
626
pma-cap-t2
pma-cap-t2
pma-cap-t1
160
30.0
1
1
ppl
HORIZONTAL

CHOOSER
16
634
160
679
pma-operational-t1
pma-operational-t1
60 120 180
2

CHOOSER
166
635
309
680
pma-operational-t2
pma-operational-t2
60 120 180 240 300
4

SLIDER
16
686
188
719
stabilisation-t
stabilisation-t
0
30
17.0
1
1
mins
HORIZONTAL

TEXTBOX
16
731
325
760
5. Select number of burn beds (BB) and non burn beds (NBB) at the hospital
11
0.0
1

SLIDER
18
766
150
799
no-bb
no-bb
0
100
6.0
1
1
beds
HORIZONTAL

SLIDER
162
766
295
799
no-nbb
no-nbb
0
500
212.0
1
1
beds
HORIZONTAL

PLOT
1634
94
1852
251
Recovered 
Time
No of Recovered
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"TS1" 1.0 0 -4079321 true "" "plot count cas-agents with [TS = 1 and Recovered? = true]"

PLOT
1412
265
1625
425
Casualties in hospital
Time
No of Casualties
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"BB" 1.0 0 -14439633 true "" "plot count cas-agents with [in-burn-beds? = True and Deceased? = False]"
"NBB" 1.0 0 -11221820 true "" "plot count cas-agents with [in-non-burn-beds? = True and Deceased? = False]"
"Q" 1.0 0 -13345367 true "" "plot count cas-agents with [in-hospital-queue? = True and deceased? = False] "

PLOT
1635
265
1850
425
Survival Rate
Time
No of Casualties
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"TS3" 1.0 0 -5298144 true "" "plot count cas-agents with [ TS = 3 and Deceased? != True]"
"TS2" 1.0 0 -817084 true "" "plot count cas-agents with [ TS = 2 and Deceased? != True]"
"TS1" 1.0 0 -4079321 true "" "plot count cas-agents with [ TS = 1 and Deceased? != True]"

PLOT
1191
456
1516
680
Deceased Casualties
Time
No of Deceased
0.0
10.0
0.0
10.0
true
true
"  ;Recovered-lists for TS1\n  set Recovered-TS1 []\n  set Recovered-Time-TS1 []\n\n  ;Dead Queue PMA lists for TS2 & TS3\n  set Decd-Queue-TS2 []\n  set Decd-Queue-Time-TS2 []\n  set Decd-Queue-TS3 []\n  set Decd-Queue-Time-TS3 []\n\n  ;Dead stabilise PMA lists for TS2 & TS3\n  set Decd-stabilise-TS2 []\n  set Decd-stabilise-Time-TS2 []\n  set Decd-stabilise-TS3 []\n  set Decd-stabilise-Time-TS3 []\n\n  ;Dead Transfer hosp at PMA lists\n  set Decd-Transfer-Hosp-TS3 []\n  set Decd-Transfer-Hosp-TS2 []\n  set Decd-Transfer-Hosp-Time-TS3 []\n  set Decd-Transfer-Hosp-Time-TS2 [] \n\n  ;Dead Burn Beds Hospital list for TS2 & TS3\n  set Decd-BB-TS2 []\n  set Decd-BB-Time-TS2 []\n  set Decd-BB-TS3 []\n  set Decd-BB-Time-TS3 []\n\n  ;Dead Non Burn Beds Hospital lists for TS2 & TS3\n  set Decd-NBB-TS2 []\n  set Decd-NBB-Time-TS2 []\n  set Decd-NBB-TS3 []\n  set Decd-NBB-Time-TS3 []\n\n  ;Dead Hospital Queue lists for TS2 & TS3\n  set Decd-Hosp-Q-TS2 []\n  set Decd-Hosp-Q-time-TS2 []\n  set Decd-Hosp-Q-TS3 []\n  set Decd-Hosp-Q-Time-TS3 []\n\n  ;Dead Awaiting rescue lists for TS2 & TS3\n  set Decd-AwaResc-TS2 []\n  set Decd-AwaResc-Time-TS2 []\n  set Decd-AwaResc-TS3 []\n  set Decd-AwaResc-Time-TS3 []\n\n  ;Dead on the way to PMA lists for TS2 & TS3\n  set Decd-OnRout-PMA-TS2 []\n  set Decd-OnRout-PMA-Time-TS2 []\n  set Decd-OnRout-PMA-TS3 []\n  set Decd-OnRout-PMA-Time-TS3 []\n\n  ;Dead on the way to hospital lists for TS2 & TS3\n  set Decd-OnRout-Hosp-TS2 []\n  set Decd-OnRout-Hosp-Time-TS2 []\n  set Decd-OnRout-Hosp-TS3 []\n  set Decd-OnRout-Hosp-Time-TS3 []" ""
PENS
"Awaiting Resc" 1.0 0 -7500403 true "" "plot (length Decd-AwaResc-TS3 + length Decd-AwaResc-TS2)"
"Route PMA" 1.0 0 -2674135 true "" "plot (length Decd-OnRout-PMA-TS3 + length Decd-OnRout-PMA-TS2)"
"Queue" 1.0 0 -5825686 true "" "plot (length Decd-Queue-TS3 + length Decd-Queue-TS2)\n"
"Stabilisation" 1.0 0 -6459832 true "" "plot (length Decd-stabilise-TS3 + length Decd-stabilise-TS2)"
"Route Hospital" 1.0 0 -4079321 true "" "plot (length Decd-OnRout-Hosp-TS3 + length Decd-OnRout-Hosp-TS2)"
"Burn Beds" 1.0 0 -13791810 true "" "plot (length Decd-BB-TS3 + length Decd-BB-TS2)"
"Non Burn Beds" 1.0 0 -13840069 true "" "plot (length Decd-NBB-TS3 + length Decd-NBB-TS2)"
"Hospital Q" 1.0 0 -14835848 true "" "plot (length Decd-Hosp-Q-TS3 + length Decd-Hosp-Q-TS2)"
"Await Transfer" 1.0 0 -2064490 true "" "plot (length Decd-Transfer-Hosp-TS3 + length Decd-Transfer-Hosp-TS2)"

PLOT
1521
456
1849
680
Status of casualties at end of run
Time
No of Deceased
0.0
10.0
0.0
10.0
true
true
"  " ""
PENS
"Awaiting Rescue" 1.0 0 -10899396 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and Awaiting-Rescue? = True and Deceased? = True]\n]"
"on route to pma" 1.0 0 -14835848 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and on-route-PMA? = True and Deceased? = True]\n]"
"in queue" 1.0 1 -4079321 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and in-queue? = True and Deceased? = True]\n]"
"in stabilisation" 1.0 1 -11221820 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and in-stabilisation? = True and deceased? = True]\n]"
"on route to hospital" 1.0 1 -13791810 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and on-route-hospital? = True and deceased? = True]\n]"
"in burn beds" 1.0 1 -13345367 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and in-burn-beds? = True and deceased? = True]\n]"
"in non burn beds" 1.0 1 -8630108 true "" "if ticks = 7200[\nplot count cas-agents with [TS = 2 and in-non-burn-beds? = True and deceased? = True]\n]"
"in hospital queue" 1.0 1 -5825686 true "" "if ticks = 7200[\nplot count cas-agents with[TS = 2 and in-hospital-queue? = True and deceased? = true]\n]"

TEXTBOX
1202
10
1854
84
A Casualty Rescue, Transport and Treatment Model Using Agent Based Simulation
30
105.0
0

SWITCH
17
131
156
164
heli-rescue?
heli-rescue?
1
1
-1000

TEXTBOX
14
94
317
122
2. Select if Helicopter rescue is considered\n     Select No of Helicopters, capacity of casualties and speed
11
0.0
1

SLIDER
18
184
150
217
no-heli-agent
no-heli-agent
0
5
3.0
1
1
NIL
HORIZONTAL

CHOOSER
164
131
258
176
Speed-Helicopter
Speed-Helicopter
200 300 400
0

SLIDER
161
184
296
217
heli-agent-cap
heli-agent-cap
0
5
5.0
1
1
NIL
HORIZONTAL

PLOT
1192
94
1401
251
Queuing
Time
No of Casualties
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"VX" 1.0 0 -13345367 true "" "plot count cas-agents with [pma-name = \"Vieux Habitants PMA\" and in-queue? = True and deceased? = False]"
"SM" 1.0 0 -10899396 true "" "plot count cas-agents with[pma-name = \"Sainte Marie PMA\" and in-queue? = True and deceased? = False]"

PLOT
1413
94
1622
250
Stabilisation
Time
No of Casualties
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"VX" 1.0 0 -13345367 true "" "plot count cas-agents with [pma-name = \"Vieux Habitants PMA\" and in-stabilisation? = True and deceased? = False]"
"SM" 1.0 0 -10899396 true "" "plot count cas-agents with[pma-name = \"Sainte Marie PMA\" and in-stabilisation? = True and deceased? = False]"

OUTPUT
1473
702
1855
807
11

BUTTON
1196
770
1320
803
print dec'd count
print-dec-count-lists
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
1332
770
1456
803
print count status
print-count-agents
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
1196
724
1294
757
clear output
clear-output
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1199
695
1349
723
6. View Results\n    
11
0.0
1

CHOOSER
14
428
145
473
increase-rescue-agents-at-time
increase-rescue-agents-at-time
60 120 180 240 300 360 420 480 540 600 660 720
1

SLIDER
150
434
330
467
Increase-Rescue-Agents
Increase-Rescue-Agents
0
25
0.0
1
1
NIL
HORIZONTAL

SLIDER
175
292
330
325
no-resc-agent-B
no-resc-agent-B
0
50
15.0
1
1
NIL
HORIZONTAL

SWITCH
177
335
330
368
resc-agent-A-only
resc-agent-A-only
1
1
-1000

SLIDER
14
477
164
510
transfer-hosp-vh
transfer-hosp-vh
1
50
10.0
1
1
NIL
HORIZONTAL

PLOT
1190
265
1401
425
Awaiting Transfer to Hospital
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
"VX" 1.0 0 -13791810 true "" "plot count cas-agents with [pma-name = \"Vieux Habitants PMA\" and transfer-hosp? = True and deceased? = False]"
"SM" 1.0 0 -10899396 true "" "plot count cas-agents with [pma-name = \"Sainte Marie PMA\" and transfer-hosp? = True and deceased? = False]"

SLIDER
169
477
318
510
transfer-hosp-sm
transfer-hosp-sm
0
100
8.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The speed at which emergency services respond following a volcanic eruption plays a vital role in determining the survivability of casualties. Residents in impacted zones exposed to a pyroclastic density current will suffer severe burns and will require intensive treatment and care. However most hospitals have very limited capacity to treat burn victims and therefore the management of casualties can have a large impact on their survivability. Mitigation plans need to be enforced to enable swift access to vital equipment such as ventilators.

This model will use an Agent-Based-Modelling approach to quantify the impact of casualty rescue and treatment on casualty survivability. The selected study area is the island of Guadeloupe, where the populated area of Basse Terre and Saint Claude are in close proximity to volcano La Soufrière.

What affects casualty survivability ?

- Severity of injuries
- Age and health conditions
- Time to recieve medical treatment
- Overloading at hospitals
- Modes of rescue (helicopter / ambulance)
- Location of treatment facilities
- Damage to transportation systems
- Availability of medical equipment
- Area of Impact : Number of casualties affected

## HOW IT WORKS

The model simulates evacuation scenarios following a volcanic crisis, and explores the impact on casualty survivability using an agent based modelling approach in a GIS setting. The effects on casualty survivability is explored through different scenario testing where different parameters are varied to examine their impact.

Rescuers, casualties, medical facilities and other infrastructure are modeled as either stationary or active agents (moves across the netlogo space). To allow rescuers to travel, to and from medical facilities to impacted zones, a shapefile consisiting of the transport infrastructure is input into the model. The model converts polylines and polyline intersecting points to links and nodes respectively. This allows agents (rescuers) to travel from node to node till they reach their destination. Helicopters are allowed to move across the space using patches which is square grid with x, y coordinates that is included within the netlogo interface. All agents (casualties, rescures & medical facilities) are situated in the closest node from their input location (GIS lat/lon coordinate).

The overal time passed since eruption is measured using ticks which corresponds to a minute in real life.

The model measures the impact on casualty survivability through examining the number of casualties deceased within a specific time or at the end of simulation. Actions such as casualties been transported to medical facilites faster or offered better medical equipment will redcue the morality rate thereby improving casualty survivability.

## MODEL SPECIFICS

**Casualities** : Casualties are classified into 3 categories and distinguished by the trauma scale attribute(TS). The trauma scales is defined as combination of the severity of injuries (Total Body Surface Area - TBSA) and mortality

	- TS1 (yellow) : Low injuries, Low mortality
	- TS2 (orange) : Burn wounds 20-40% TBSA, High mortality without treatment
	- TS3 (Red) : Burn wounds > 40% TBSA, High mortality with or without treatment

**Rescuers** : Rescue agent are classified in to 2 categories

- Ambulances

	- Type-A (white with red cross)
		- Performs rescue operations in the impacted zone. Responsible 		for transporting casualties from field to PMA (Triage - Feild hospital).
		- Transports all casualties (Trauma scale 1,2 & 3)
		- Joint first priority rescue for casulaites of category TS2 and TS3. This means that even if there were TS1 casualties withtin the same node as TS2 or TS3 casualty, rescuers will ignore them and search for other TS2 and TS3 casualties provided they have capacity for further rescuing.
		- TS1 casualties will only be rescued once all TS2 and TS3 casualties are rescued from the impacted zone.
	- Type-B (Red with white cross)
		- Performs transporting casualties from PMA to hospital.
		- Transports only casualties with trauma scale 2 & 3
- Helicopters
		- Transports casualties from impacted zones to hospital
		- Only Transports casualties with trauma scale 2 & 3.
		- They travel to and from hospital to the impact zone until all TS 2 and TS 3 casualties are rescued.

**Medical Facilities** : Medical facilities are classified in to categories. Temperory field hospitals for stabilisation and perment hospital where long term treatment is recieved by casualties.

- PMA (triage / field hospital)
	- Performs stabilisation for casualties of trauma scale categories 1,2,3
	- Two PMA's are setup one in Sainte Marie and the other in Vieux Habitants
	- Capacity of casualties that can be treated at one time is decided by the number of medical staff available.
	- If Stabilisation capacity is reached casualties will be added into queue.
	- The rescue agents will decide on which PMA to travel to depending on the number casusilies in queue (travels to the smaller queue)
	- If there is no queue (if there is availability in stabilisation - enough doctors available to treat casualties at that time) rescue agents will travel to the closest PMA.
	- Rescue agents will make decisions to travel to a certain PMA once its capacity has been reached. Once a decision has been made, the rescue agent will not change course to travel to a different PMA if stabilisation capacity has been reached.
	- Upon availabilty in stabilisation queue, casualties will be transfered to the stabilisation queue.
	- Casualties with Trauma scale 2 and 3 are transported for further treament at hospital after stabilisation.
	- Casualites of Trauma scale category 1 are considered recovered after stabilisation
	- If stabilisation isnt open casualties will be added into the queue.

- Hospital

	- Provides treatment for casualties with Trauma scale 2 and 3.
	- Medical equipment
		- Burn Beds (BB)
			- casualties who are offered burn beds will have reduced mortality rate
			- Priority given to casulties with TS3.
			- However TS3 casulties brought at a later time will be not offered burn beds if TS2 casualties are occupying burn beds.
		- Non Burn Beds (NBB)
			- casualties who are offered treatment at Non burn beds will have reduced mortality rate (lower than burn beds)

**General**

	- Model will run for 7200 ticks which refers to 5 days since impact in real life

## HOW TO SET IT UP

Please visit the github repository containing the model input files at https://github.com/vharg/Post-eruption-casualty-RTT

**Netlogo**

	- Please note the code has been tested on Netlogo version 6.1

**GIS**

	- The required GIS files are found in the GIS folder in the repository
	- Following GIS files will be used in the model
		- "Edited_Gudaloupe_boundary.shp" : Gudaloupe country boundary shape file
		- "LaSoufrière_ImpactZones.shp" : Boundaries of the impact zones
		- "Primaryrds_edited_04_EPSG36320.shp" : Part of the road network (display the main roads/highways and more denser road network at impact zones)
			- Road network outside of the impact zone was removed to reduce setup loading times.
		- "PMA_and_Hospital_Airport_Volcano_Nodes_EPSG36320.shp" : Locations of infrastructure (PMA/Hospital/Volcano etc.)
		- "PDC_Humans_default.shp" : Location of casualties and their trauma scale category
	- Copy them to the desired directory
	- Specify the directory you copied the GIS files to, by ammending line 112 (set-current-directory <directory>) under Netlogo code tab

**Python**

A section of the RTT.nlogo code is written in python and therefore python must be installed for the model to sucessfully run.

The following guide shows how to install python is using Anaconda (python distribution)

	- Visit https://www.anaconda.com/ for a more comprehesive description of anaconda distribution.

Following python packages will be required by the model.

	- Numpy (https://pypi.org/project/numpy/)
	- Munkres (https://pypi.org/project/munkres/)

The recommended method to installing new packages are by setting up a new python enviornment. A new python environment can be created in the following 2 ways. The guide below details creating environments and installing packages using the anaconda prompt (command line). Alternatively Anaconda Navigator provides the same functionality using a GUI.

- Create environment and Install packages using .yml file

	- Download RTTEnv.yml file located in the python folder in this repository
	- Open Anaconda Prompt and run the following command
	- conda env create --file envname.yml
		- Example :
			- conda env create --file D:/Python/RTTEnv.yml
			- Note the first line of the RTTEnv.yml file can be changed if you wish to re-name you environment name (i.e abc)

- Create Environment and install packages manually

		- There maybe instances where installing packages using .yml file might be unsucessfull.
		- In this situation use the traditional method of creating environments and installing packages detailed below.
		-Anaconda comes with a base environment with some pre-installed packages, Numpy being one of them. However it is recommended to create a new python environment.
		- To create a new environment,
			- Open Anaconda prompt
			- Create a new environment by running, conda create -n RttEnv python=3.7.5
				- Note "RttEnv" is the environment name (name of the environment your about to create), you can enter any name you wish (i.e abc)
			- To activate the new environment,Enter activate RttEnv in the anconda prompt.
			- To install new packages, use pip (python package manager), alternatively you can use conda (anaconda package manager)
				- To install Numpy,
					- pip install numpy==1.17.4 (pip install "package name == version")
				- To install Munkres,
					- pip install munkres==1.1.2
				- you can view the list of packages installed in your environment by using pip list.

	- If you decided to install the packages in the base environment instead, you can directly install using pip or conda (no need to create a new environment and activate.). However it is recommended to create a isolated new environment for this project to ensure that it has its own dependencies.

**Configuring python executable in Netlogo**

- Once the packages are installed you will need locate the python.exe file located in the anaconda folder.
	- This will depend on where you installed python but generally will be located in C:/ProgramFiles/anaconda for the base environment.
	- For newly created environment, it will generally be in C:/ProgramFiles/anaconda/envs/Rtt provided that you named your environment Rtt. Else it will be in the same directory under the name you input during the creation of the new environment.
	- The location of python can be found by typing where python in anconda prompt. (In case of virtual environment ensue that you have activated the environment, activate Rtt before typing the command)
	- Locate the python.exe file in the directory and copy the filepath. This should include python.exe file as well (C:\Program Files\anaconda\envs\Rtt\python.exe)
	- Next open Netlogo
		- Navigate to python (top left) -> configure -> and paste the address under the field Python3.

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## MODEL ASSUMPTIONS

* Rescuers (Ambulance Type - A)
  * Dont stop for activities such as refuling etc.
  * Its assumed that all rescuers travel at the same speed (speed will not change based on road type).
  * Munkres assignment algorithm is used to optimise the assignment of casulty to each rescuer based on distance.
    * The algorithm minimises the total distance to travel by selecting the best rescuer-casualty combinations.
    * Ref : J. Munkres, "Algorithms for the Assignment and Transportation Problems", Journal of the Society for Industrial and Applied Mathematics, 5(1):32–38, 1957 March.
    * Two or more rescuers will not be assigned to the same casualty. However two or more rescuers may travel to same node if there are multiple casualties situated within the same node. This may reduce the efficiency of the munkres algorithm. 
  * At start of each rescue operation (at the PMA), its assumed that the location and the casualty agent to be rescued is known by every rescue agent. However to account for the time taken for searching (general vicinity) and rescuing (i.e loading to the ambulance etc.) a resue-time parameter is available in the model inteface, which can be set by the user.
  * Rescuers travel a unit distance within a tick (a minute in real life). Usually upon reaching close to casualty, PMA, hospital(Rescuers Type B), the distance to travel to the destination (node) will be less than the distance traveled within a tick. This will impose an casualty rescue time error of up to one tick (a minute in real life) and vice versa.
    * To minimises some of this error rescuers (Rescuers Type A) will travel an extra distance once rescue operation is completed (loaded in to ambulance) or once they reach PMA and drop casulties (remaider distance from previous run).
    
* Rescuers (Ambulance Type - B)
  * All points Rescuers, Ambulance Type - A apply to Ambulance Type-B as well.
  * Travel only in one direction, from PMA to Hospital. They do not return to PMA after transferring patients to the hospital.
  * Its considered that there are unlimited number of Ambulances (Type B)
  * Travels to hospital as soon as there are any stabilised casualties at the PMA (Do not wait for other casualties to be stabilised since there are an unlimited number of ambulances) 

* Rescuers (Helicopters)
  * Helicopters travel in straight lines (from hospital to impacted zones). They do not follow any sort of airline routes that are possibly taken in real life.
  * Do not stop for activities such as refuling etc.
  * Point 1,2,3 & 4 from rescuers (Ambulance Type - A) apply to helicopters as well.
    * Note the munkres algorithm is computed seperately for Helicopter and ambulances (Type - A). Thefore it doesnot compute most efficient assignment for all rescue agents (Helicopters + Ambulance Type -A), just for each agent class.  
   
* Casualties
  * Casualties are assigned to the closest node from their input location (GIS .shp file). So it is assumed that casualties are within the vicinity of roads in the impacted zone. 

* PMA (Triage / Field Hospitals)
  * Its assumed that PMA's are setup within 1 hour of eruption (Rescuers Type - A, activates at 60 ticks) 

* Hospital
  * Its is assummed that the hospital contains a helipad

* General
  * All casualties and medical facilities are situated at the closest node from their inputed location (gis .shp file)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

cas-ts1
false
0
Circle -1184463 true false 110 5 80
Polygon -1 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -1184463 true false 127 79 172 94
Polygon -1 true false 195 90 240 150 225 180 165 105
Polygon -1 true false 105 90 60 150 75 180 135 105

cas-ts2
false
0
Circle -955883 true false 110 5 80
Polygon -1 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -955883 true false 127 79 172 94
Polygon -1 true false 195 90 240 150 225 180 165 105
Polygon -1 true false 105 90 60 150 75 180 135 105

cas-ts3
false
0
Circle -2674135 true false 110 5 80
Polygon -1 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -2674135 true false 127 79 172 94
Polygon -1 true false 195 90 240 150 225 180 165 105
Polygon -1 true false 105 90 60 150 75 180 135 105

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

deceased
true
0
Circle -7500403 true true 108 108 85
Rectangle -7500403 true true 105 150 195 225

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

helicopter
false
1
Polygon -1 true false 0 135 15 165 150 165 195 135 270 135 255 120 195 120 165 105 150 90 60 90 45 120 30 135 15 135
Rectangle -7500403 true false 180 180 180 180
Polygon -1 true false 120 90 120 60 135 60 135 90
Polygon -1 true false 30 60 225 60 240 45 45 45
Polygon -1 true false 285 90 285 105 255 135 240 135 285 75
Rectangle -7500403 true false 60 120 90 135
Polygon -1 true false 240 135 255 120 285 150 270 165 240 135
Circle -7500403 true false 60 105 30
Polygon -1 true false 45 180 45 180 30 195 150 195 150 180 135 180 135 165 120 165 120 180 75 180 75 165 60 165 60 180 45 180
Rectangle -2674135 true true 120 105 135 150
Rectangle -2674135 true true 105 120 150 135

helipad
false
0
Circle -14835848 true false 29 29 242
Rectangle -2674135 true false 90 75 105 225
Rectangle -2674135 true false 195 75 210 225
Rectangle -2674135 true false 105 135 195 150

hospital-shape
false
0
Rectangle -1 true false 45 120 255 285
Rectangle -16777216 true false 120 240 180 285
Polygon -2674135 true false 15 120 150 15 285 120
Line -16777216 false 30 120 270 120
Rectangle -2674135 true false 135 135 165 225
Rectangle -2674135 true false 105 165 195 195

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

pma-shape
false
0
Rectangle -2674135 true false 45 120 255 285
Rectangle -16777216 true false 120 240 180 285
Polygon -1 true false 15 120 150 15 285 120
Line -16777216 false 30 120 270 120
Rectangle -1 true false 135 135 165 225
Rectangle -1 true false 105 165 195 195

resc-agent-a-shape
false
0
Rectangle -1 true false 4 45 195 187
Polygon -1 true false 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42
Rectangle -2674135 true false 90 60 105 165
Rectangle -2674135 true false 45 105 150 120

resc-agent-b-shape
false
0
Rectangle -2674135 true false 4 45 195 187
Polygon -2674135 true false 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42
Rectangle -1 true false 90 60 105 165
Rectangle -1 true false 45 105 150 120

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

volcano
false
0
Polygon -2674135 true false 165 165
Polygon -6459832 true false 105 165 60 255 240 255 195 165 135 165
Polygon -7500403 true true 150 105
Polygon -2674135 true false 105 165 150 75 195 165

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
NetLogo 6.2.0
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
