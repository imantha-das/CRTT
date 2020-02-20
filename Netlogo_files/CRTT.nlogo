extensions [gis nw py]
globals [
  ;general
  G-target-agent G-target-node avg-time
  ;gis
  guo-boundary guo-impactzone guo-roads guo-routier guo-pop guo-PMA-Hosp-Airpt Net-Gis-Convfac Gis-Net-Convfac
  ;lists
  ;lists
  Recovered-TS1 Recovered-time-TS1 Decd-Queue-TS2 Decd-Queue-Time-TS2 Decd-Queue-TS3 Decd-Queue-Time-TS3 Decd-stabilise-TS2 Decd-stabilise-Time-TS2
  Decd-stabilise-TS3 Decd-stabilise-Time-TS3 Decd-BB-TS2 Decd-BB-Time-TS2 Decd-BB-TS3 Decd-BB-Time-TS3 Decd-NBB-TS2 Decd-NBB-Time-TS2 Decd-NBB-TS3 Decd-NBB-Time-TS3
  Decd-Hosp-Q-TS2 Decd-Hosp-Q-time-TS2 Decd-Hosp-Q-TS3 Decd-Hosp-Q-Time-TS3 Decd-AwaResc-TS2 Decd-AwaResc-Time-TS2 Decd-AwaResc-TS3 Decd-AwaResc-Time-TS3
  Decd-OnRout-PMA-TS2 Decd-OnRout-PMA-Time-TS2 Decd-OnRout-PMA-TS3 Decd-OnRout-PMA-Time-TS3 Decd-OnRout-Hosp-TS2 Decd-OnRout-Hosp-Time-TS2 Decd-OnRout-Hosp-TS3
  Decd-OnRout-Hosp-Time-TS3
]
;*********************************************************************************************************************************************************************************************************************************************************************
;TYPE OF AGENTS
;PRIMARY AGENTS:

;Casualties
breed [pop-agents pop-agent]

;Medically Equpped Vehicles
breed [resc-agents resc-agent]; Rescue Agent (Type A)
breed [ambulances ambulance];  Rescue Agent (Type B)
breed [heli-agents heli-agent]; Helicopter

;Treatmenet Facilities
breed [PMA's PMA]; Field Triage
breed [Hospitals Hospital] ; Hospitals

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
pop-agents-own [node-pop patch-pop targeted? targeted-by TS PMA-at PMA-name PMA-at-node
  on-route-PMA-time queue-time stabilise-time to-be-hospitalised-time on-route-hospital-time BB-admission-time NBB-admission-time Hospital-Queue-Time recovered-time deceased-time
  Rescue-by-Helicopter? Rescue-by-ambulance? awaiting-rescue?  on-route-PMA? in-queue? in-stabilisation? to-be-hospitalised?
  on-route-hospital? recovered? in-Burn-beds? in-Non-Burn-Beds? in-Hospital-Queue? Deceased?]

;Medically Equiped Vehicles
resc-agents-own [node-resc node-agent-at  Mode Case target-agent route-length next-pos current-pos current-node next-node
  distance-to-next-node remaining-distance rem-fm-prev-run commute-path list-of-distances list-of-time list-of-m-distances list-of-min-time Rescued-agents-list collected-agent-count
rescue-time transfer-time]
ambulances-own [Case node-resc collected-agents-TS2 collected-agents-TS3 Mode node-agent-at target-agent commute-path current-node next-node route-length next-pos current-pos
  distance-to-next-node remaining-distance rem-fm-prev-run list-of-distances list-of-time list-of-m-distances Transfer-Time]
heli-agents-own [Mode Case helipad-patch hospital-patch current-patch patch-agent-at target-agent distance-to-target remaining-distance  Rescued-Agents-List collected-agent-count collected-agents-TS2 collected-agents-TS3
  list-of-distances list-of-time list-of-m-distances rescue-time transfer-time ]

;Treatment Facilities
PMA's-own [nid node-PMA PMA-capacity Queue-TS1 Queue-Time-TS1 Queue-TS23 Queue-Time-TS23 stabilise-TS1 stabilise-time-TS1 stabilise-TS23 stabilise-time-TS23]
hospitals-own [nid node-hosp Burn-Beds-TS2 Burn-Beds-Time-TS2 Burn-Beds-TS3 Burn-Beds-Time-TS3 Non-Burn-Beds-TS2 Non-Burn-Beds-time-TS2 Non-Burn-Beds-TS3 Non-Burn-Beds-Time-TS3
  Hospital-Queue-TS2 Hospital-Queue-Time-TS2 Hospital-Queue-TS3 Hospital-Queue-Time-TS3]

;Transport Network
nodes-own [linked-to  pop-agent-present-TS1 Count-TS1 pop-agent-present-TS23 count-TS23 PMA-present Hospital-present]
links-own [netlogo-dist]


;SECONDARY AGENT OWN VARIABLES:
Helipad's-own [nid site]
volcanoes-own [nid site]
pma-hosp-heli-nodes-own [ntype nid]
pop-nodes-own [TS1-count TS2-count TS3-count]
dummy-agents-own [used-up?]
;*********************************************************************************************************************************************************************************************************************************************************************
;MAIN SETUP PROCEDURE
to setup
  clear-all

  setup-gis
  setup-road-nodes&links
  setup-PMA-Hosp-heli
  setup-population
  setup-resc-agents
  setup-visual-queue
  setup-labels

  if helicopter-rescue = True [
   setup-helicopter
  ]
end
;*********************************************************************************************************************************************************************************************************************************************************************
; SETUP SUPPORTING FUNCTIONS
; SETUP-GIS : LOADS GIS FILES INTO NETLOGO ENVIRONMENT
to setup-gis
  ; setups the interface coordinates

  set-patch-size 1
  let max-px 780
  let min-px 0
  let max-py 780
  let min-py 0
  resize-world min-px max-px min-py max-py

  ;set current directory: Folder consisting gis files for model
  set-current-directory "D:\\ABM\\Gudaloupe New Model\\Trial Model"

  ;declare global variables for each of the shapefiles and draw
  set guo-boundary gis:load-dataset "Edited_Gudaloupe_boundary.shp"
  gis:set-drawing-color 5
  gis:fill guo-boundary 1.0

  set guo-impactzone gis:load-dataset "LaSoufrière_ImpactZones.shp"
  gis:set-drawing-color 6
  gis:fill guo-impactzone 1.0

  set guo-roads gis:load-dataset "Primaryrds_edited_04_EPSG36320.shp"

  set guo-PMA-Hosp-Airpt gis:load-dataset "PMA_and_Hospital_Airport_Volcano_Nodes_EPSG36320.shp"

  set guo-pop gis:load-dataset "PDC_Humans_default.shp"

  ;for viewing only, to switch world-envelope : NOTE - DISTANCES CHANGE
  gis:set-world-envelope gis:envelope-of guo-boundary
  gis:set-transformation-ds (gis:envelope-of guo-boundary)(list (min-px) (max-px) (min-py) (max-py))

  set avg-time 60
  reset-ticks
  ;tick-advance 60
end

; SETUP-ROAD-NODES-AND-LINKS : CONSTRUCT NODES AT VERTICES OF POLYLINES, CONNECTS NODES THROUGH LINKS
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
  ;print("Gis sum distance")
  show sum dist-list

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
  ;print("Netlogo Sum Distance: ")
  ;show net-logo-dist-list
  show sum netlogo-dist-list

;1 METER in NETLOGO UNITS
  set Net-Gis-Convfac precision ((sum dist-list) / (sum netlogo-dist-list)) 4
  set Gis-Net-Convfac precision ((sum netlogo-dist-list) / (sum dist-list)) 4
  show Net-Gis-Convfac
  show Gis-Net-Convfac

end

; SETUP-PMA-HOSP-HELI : CREATE AGENTS FOR PMA, HOSPITAL AND HELIPAD AT THE SPECIFIED LOCATIONS FROM THE GIS FILES
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
      set Queue-Time-TS1 []
      set Queue-TS23 []
      set Queue-Time-TS23 []
      set stabilise-TS1 []
      set stabilise-time-TS1 []
      set stabilise-TS23 []
      set stabilise-time-TS23 []
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

;SETUP-POPULATION : CREATE CASUALTY-AGENTS BASED ON THE NUMBER AND LOCATION FROM GIS FILE
to setup-population
  ; create pop nodes which are the locations at which pop-agents (casualties) will be created at.
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
  ; Create casualties at the pop nodes
  ask pop-nodes[
    hatch-pop-agents TS1-count [
      set color 44
      set shape "person"
      set size 9.75 ; 0.75 x 13
      set TS 1
      set patch-pop patch-here
      set hidden? False
      set targeted? False
      set Rescue-by-Helicopter? False
      set Rescue-by-ambulance? False
      set awaiting-rescue? True
      set on-route-PMA? False
      set in-queue? False
      set in-stabilisation? False
      set to-be-hospitalised? False
      set on-route-hospital? False
      set recovered? False
      set in-Burn-beds? False
      set in-Non-Burn-Beds? False
      set in-Hospital-Queue? False
      set Deceased? False

    ]
    hatch-pop-agents TS2-count [
      set color 24
      set shape "person"
      set size 9.75 ;size 0.75 x 13
      set TS 2
      set patch-pop patch-here
      set hidden? False
      set targeted? False
      set Rescue-by-Helicopter? False
      set Rescue-by-ambulance? False
      set awaiting-rescue? True
      set on-route-PMA? False
      set in-queue? False
      set in-stabilisation? False
      set to-be-hospitalised? False
      set on-route-hospital? False
      set recovered? False
      set in-Burn-beds? False
      set in-Non-Burn-Beds? False
      set in-Hospital-Queue? False
      set Deceased? False
    ]
    hatch-pop-agents TS3-count [
      set color 13
      set shape "person"
      set size 9.75 ;size 0.75 x 13
      set TS 3
      set patch-pop patch-here
      set hidden? False
      set targeted? False
      set Rescue-by-Helicopter? False
      set Rescue-by-ambulance? False
      set awaiting-rescue? True
      set on-route-PMA? False
      set in-queue? False
      set in-stabilisation? False
      set to-be-hospitalised? False
      set on-route-hospital? False
      set recovered? False
      set in-Burn-beds? False
      set in-Non-Burn-Beds? False
      set in-Hospital-Queue? False
      set Deceased? False
  ]
  ]

  ;distribure pop-agents to any one of the closest vertex based on gis file
  ask pop-agents[
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
    set pop-agent-present-TS1 pop-agents with [TS = 1] in-radius 0.0001
    set pop-agent-present-TS23 pop-agents with [TS = 2 or TS = 3] in-radius 0.0001
  ]

end

;CREATE RESCUE AGENTS (AMBULANCE TYPE-A) BASED ON USER INPUT FROM THE INTERFACE
to setup-resc-agents
  create-resc-agents Number-of-Rescuers[
    set shape "ambulance-shape"
    set size 16.25 ;size 1.25 x 13
    move-to one-of nodes with [PMA-present != nobody]

    set node-resc min-one-of nodes in-radius 0.0001 [distance myself]
    set mode "Searching !!!"
    set list-of-distances []
    set list-of-time []
    set list-of-m-distances []
    set Rescued-Agents-List []
    set collected-agent-count 0
    set target-agent nobody
    set rescue-time rescue-time-mins
    set transfer-time transfer-time-mins
  ]

end

;CREATE HELI AGENTS (HELICOPTERS) BASED ON THE USER INPUT FROM THE INTERFACE
to setup-helicopter
  create-heli-agents Number-of-Helicopters[
    set shape "Helicopter"
    set color red
    set size 22.75 ;size 1.75 x 13
    let hosp-loc [patch-here] of hospitals with[nid = "PtP Hospital"]
    set Hospital-patch item 0 hosp-loc
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
    set collected-agent-count 0
    set collected-agents-TS2 []
    set collected-agents-TS3 []
    set rescue-time rescue-time-mins
    set transfer-time transfer-time-mins
  ]
end

; CREATE BOXES WHICH ARE USED TO REPRESENT THE CURRENT STATUS (I.E ON ROUTE TO PMA, IN STABILISATION ETC) OF CASUALTIES.
to setup-visual-queue
    ;create patches that will represent the queue and stabilisation. When pop agents are added to the queue/stabilisation lists, they are moved to the respective patches
   ask patches with [pxcor >= 540 and pxcor < 620 and pycor >= 0 and pycor <= 80][
    set pcolor 125 ; on-Route-PMA
    ]

  ask patches with [pxcor >= 700 and pxcor <= 780 and pycor >= 0 and pycor <= 80][
    set pcolor 54 ; SM-Queue
    ]
  ask patches with [pxcor >= 620 and pxcor < 700 and pycor >= 0 and pycor <= 80][
    set pcolor 55 ;VH Queue
  ]
  ask patches with [pxcor >= 700 and pxcor <= 780 and pycor > 80 and pycor <= 160][
    set pcolor 64;SM stabiise
  ]
  ask patches with [pxcor >= 620 and pxcor < 700 and pycor > 80 and pycor <= 160][
    set pcolor 63;VH Stabilise
  ]
  ask patches with [pxcor >= 540 and pxcor < 620 and pycor > 80 and pycor <= 160][
    set pcolor 25 ; on-Route-Hosp-ambulance
    ]
  ask patches with [pxcor >= 540 and pxcor < 620 and pycor > 160 and pycor <= 240][
    set pcolor 34 ; on-Route-Hosp-helicopter
    ]
  ask patches with[pxcor >= 700 and pxcor <= 780 and pycor > 160 and pycor <= 320][
    set pcolor 95;NBB
  ]
  ask patches with[pxcor >= 620  and pxcor < 700 and pycor > 240 and pycor <= 320][
    set pcolor 94;BB
  ]
  ask patches with[pxcor >= 380 and pxcor < 620 and pycor  > 240 and pycor <= 320][
   set pcolor 14 ;TS1 Recovered
  ]
  ask patches with[pxcor >= 620 and pxcor <= 700 and pycor  > 160 and pycor <= 240][
   set pcolor 84 ;Hospital Queue
  ]
  ask patches with[pxcor >= 380 and pxcor < 540 and pycor >= 0 and pycor <= 240][
    set pcolor 4 ;Deceased
  ]
  ask patches with [pxcor = 615 and pycor = 40] [set plabel "On Route PMA"]
  ask patches with [pxcor = 767 and pycor = 40] [set plabel "SM Queue "]
  ask patches with [pxcor = 680 and pycor = 40] [set plabel "VH Queue"]
  ask patches with [pxcor = 680 and pycor = 120] [set plabel "VH Stabilise"]
  ask patches with [pxcor = 767 and pycor = 120][set plabel "SM Stabilise"]
  ask patches with [pxcor = 615 and pycor = 125][set plabel "On Route Hosp"]
  ask patches with [pxcor = 610 and pycor = 115][set plabel "(Ambulance)"]
  ask patches with [pxcor = 615 and pycor = 205][set plabel "On Route Hosp"]
  ask patches with [pxcor = 610 and pycor = 195][set plabel "(Helicopter)"]
  ask patches with [pxcor = 775 and pycor = 240][set plabel "Non Burn Beds"]
  ask patches with [pxcor = 680 and pycor = 280][set plabel "Burn Beds"]
  ask patches with [pxcor = 695 and pycor = 200][set plabel "Hospital Queue"]
  ask patches with [pxcor = 540 and pycor = 280][set plabel "TS1 Recovered"]
  ask patches with [pxcor = 480 and pycor = 120][set plabel "Deceased"]

end

; FOR THE PURPOSE OF LABELLING AGENTS
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

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! END SETUP
;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! SUPPORT FUNCTIONS FOR GO PROCEDURE
; SEARCH ALGORITHM, THAT ASSIGNS EACH HELI AGENT (RESCUE HELICOPTER) TO A POP AGENT (CASUALTIES OF CAT 2 OR 3) BASED ON THE MINIMIZMED BEST TOTAL DISTANCE FOR ALL AGENTS
to setup-munkres-heli
  let pop-TS23 pop-agents with [(TS = 2 or TS = 3) and targeted? = False and Deceased? = False] ; list of pop-agents of TS cat 2 or 3
  if count pop-TS23 > 0[
    let searching-heli-agents heli-agents with [target-agent = nobody and Mode = "Searching !!!"] ;set of helicopters who are inacative / havent identied pop-agent to rescue

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
          let dist-to-pop-agent distance j
          set dist-to-TS23-list lput dist-to-pop-agent dist-to-TS23-list

        ]
      ]
    ]
    py:setup py:python3
    py:set "py_who_TS23_list" who-TS23-list
    py:set "py_who_heli_list" who-heli-list
    py:set "py_dist_to_TS23_list" dist-to-TS23-list

        ;running munkres algorithm
    (py:run
      "from munkres import Munkres"
      "import numpy as np"
      "import pandas as pd"
      "dist_arr = np.array(py_dist_to_TS23_list)"
      "dist_mat = dist_arr.reshape(len(py_who_heli_list),len(py_who_TS23_list))"

      ;*************************************   Number of helicopters <= Number of pop_TS23   ******************************************
      "if len(py_who_TS23_list) >= len(py_who_heli_list):"
      "    df_TS23 = pd.DataFrame()"
      "    df_TS23 = pd.concat([df_TS23, pd.DataFrame(dist_mat)],axis = 1)"
      "    df_TS23.columns = py_who_TS23_list"
      "    df_TS23.index = py_who_heli_list"

      "    m = Munkres()"
      "    indexes = m.compute(dist_mat)"
      "    #print('Munkres index (heli-agent, pop-agent) key value pairs: ',indexes)"
      "    #print(' -> heli-agent, pop-agent distance table: ')"
      "    #print(df_TS23)"

      ; To extract pop-agent and resc-agent who numbers from indexes
      "    dist_values = []"
      "    heli_pop_who = []"

      "    for i in indexes:"
      "        dist_values.append(df_TS23.iloc[i[0],i[1]])"
      "        heli_pop_who.append((df_TS23.index[i[0]],df_TS23.columns[i[1]]))"
      "    #print('Distance Values List: ',dist_values)"
      "    #print('heli_pop_who: ',heli_pop_who)"

      ;*************************************   Number of helicopters > Number of pop_TS23   ******************************************

      "else:"
      "    #print('inverse heli pop')"
      "    dist_mat_trans = np.transpose(dist_mat)"
      "    df_TS23 = pd.DataFrame()"
      "    df_TS23 = pd.concat([df_TS23, pd.DataFrame(dist_mat_trans)])"
      "    df_TS23.columns = py_who_heli_list"
      "    df_TS23.index = py_who_TS23_list"

      "    m = Munkres()"
      "    indexes = m.compute(dist_mat_trans)"
      "    #print('Munkres index (pop-agent, heli-agent) key value pairs: ',indexes)"
      "    #print(' -> pop-agent, heli-agent distance table: ')"
      "    #print(df_TS23)"

      ; To extract pop-agent and resc-agent who numbers from indexes
      "    dist_values = []"
      "    pop_heli_who = []"

      "    for i in indexes:"
      "        dist_values.append(df_TS23.iloc[i[0],i[1]])"
      "        pop_heli_who.append((df_TS23.index[i[0]],df_TS23.columns[i[1]]))"
      "    #print('Distance Values List: ',dist_values)"
      "    #print('pop_heli_who: ',pop_heli_who)"
      )


  ;converting python variables to netlogo variables

    ifelse length(who-TS23-list) >= length(who-heli-list)[
      ;*************************************   NETLOGO: Number of rescuers <= Number of pop_TS23   ******************************************
      let heli-pop-who py:runresult "heli_pop_who"
      foreach heli-pop-who[
        i ->
        let heli-who item 0 i
        let pop-who item 1 i

        ask heli-agent heli-who [
          set target-agent pop-agent pop-who
          set patch-agent-at [patch-here] of target-agent
          show target-agent
          show patch-agent-at

          ask target-agent [
            set targeted? True
            set Rescue-by-Helicopter? True
            set targeted-by heli-agent heli-who
          ]
        ]

      ]
    ]
    [
       ;*************************************   NETLOGO: Number of rescuers > Number of pop_TS23   ******************************************
      let pop-heli-who py:runresult "pop_heli_who"
      foreach pop-heli-who[
        i ->
        let pop-who item 0 i
        let heli-who item 1 i
        ask heli-agent heli-who [
          set target-agent pop-agent pop-who
          set patch-agent-at [patch-here] of target-agent
          show target-agent
          show node-agent-at

          ask target-agent [
            set targeted? true
            set Rescue-by-Helicopter? True
            set targeted-by heli-agent heli-who
          ]
        ]
      ]
    ]
]
end

; SAME AS SETUP-MUNKRES-HELI, BUT ASSIGNING RESCUE AGENTS (AMBULANCE TYPE-A) TO ALL CASUALTIES (TS1,TS2,TS3)
to setup-munkres
  ;********************************************************************************************************************************************************************************************************************************   Search TS 2 or 3 Agents

  let pop-TS23 pop-agents with [(TS = 2 or TS = 3) and Targeted? = False and Deceased? = False] ;list of pop-agents with TS cat 2 or 3

  if count pop-TS23 > 0[
    let searching-resc-agents resc-agents with [target-agent = nobody and Mode = "Searching !!!"] ;list of resc-agents who are inactive/havent found an pop-agent to rescue

    let who-TS23-list []
    let pop-TS23-nodes-list []
    let who-resc-list []
    let search-resc-nodes-list []
    let dist-to-TS23-list []

    ask pop-TS23 [
      set who-TS23-list lput who who-TS23-list ;list of TS23 agents who numbers
      set pop-TS23-nodes-list lput node-pop pop-TS23-nodes-list  ;list of pop-agent-nodes for agents in pop-TS23-list
  ]
    ask searching-resc-agents[
      set who-resc-list lput who who-resc-list ;list of resc-agents who are inactive
      set search-resc-nodes-list lput node-resc search-resc-nodes-list ;list of nodes for agents in search-resc-list
    ]
    ;for looping iterating over pop-TS23-nodes and search-resc-nodes-list and calculting the distance between each of the nodes
    foreach search-resc-nodes-list [
      i ->
      foreach pop-TS23-nodes-list[
        j ->
        ask i[
          let dist-to-pop-node nw:weighted-distance-to j netlogo-dist
          set dist-to-TS23-list lput dist-to-pop-node dist-to-TS23-list
        ]
      ]
    ]

    ;print ("Who numbers of pop-TS23: ")
    ;show who-TS23-list
    ;show pop-Ts23-nodes-list
    ;print ("Who numbers of resc-agents: ")
    ;show who-resc-list
    ;show search-resc-nodes-list
    ;show dist-to-TS23-list

    ;converting variables to python
    py:setup py:python3
    py:set "py_who_TS23_list" who-TS23-list
    py:set "py_who_resc_list" who-resc-list
    py:set "py_dist_to_TS23_list" dist-to-TS23-list

    ;running munkres algorithm
    (py:run
      "from munkres import Munkres"
      "import numpy as np"
      "import pandas as pd"
      "dist_arr = np.array(py_dist_to_TS23_list)"
      "dist_mat = dist_arr.reshape(len(py_who_resc_list),len(py_who_TS23_list))"

      ;*************************************   Number of rescuers <= Number of pop_TS23   ******************************************
      "if len(py_who_TS23_list) >= len(py_who_resc_list):"
      "    df_TS23 = pd.DataFrame()"
      "    df_TS23 = pd.concat([df_TS23, pd.DataFrame(dist_mat)],axis = 1)"
      "    df_TS23.columns = py_who_TS23_list"
      "    df_TS23.index = py_who_resc_list"

      "    m = Munkres()"
      "    indexes = m.compute(dist_mat)"
      "    #print('Munkres index (resc-agent, pop-agent) key value pairs: ',indexes)"
      "    #print(' -> resc-agent, pop-agent distance table: ')"
      "    #print(df_TS23)"

      ; To extract pop-agent and resc-agent who numbers from indexes
      "    dist_values = []"
      "    resc_pop_who = []"

      "    for i in indexes:"
      "        dist_values.append(df_TS23.iloc[i[0],i[1]])"
      "        resc_pop_who.append((df_TS23.index[i[0]],df_TS23.columns[i[1]]))"
      "    #print('Distance Values List: ',dist_values)"
      "    #print('resc_pop_who: ',resc_pop_who)"

      ;*************************************   Number of rescuers > Number of pop_TS23   ******************************************

      "else:"
      "    #print('inverse resc pop')"
      "    dist_mat_trans = np.transpose(dist_mat)"
      "    df_TS23 = pd.DataFrame()"
      "    df_TS23 = pd.concat([df_TS23, pd.DataFrame(dist_mat_trans)])"
      "    df_TS23.columns = py_who_resc_list"
      "    df_TS23.index = py_who_TS23_list"

      "    m = Munkres()"
      "    indexes = m.compute(dist_mat_trans)"
      "    #print('Munkres index (pop-agent, resc-agent) key value pairs: ',indexes)"
      "    #print(' -> pop-agent, resc-agent distance table: ')"
      "    #print(df_TS23)"

      ; To extract pop-agent and resc-agent who numbers from indexes
      "    dist_values = []"
      "    pop_resc_who = []"

      "    for i in indexes:"
      "        dist_values.append(df_TS23.iloc[i[0],i[1]])"
      "        pop_resc_who.append((df_TS23.index[i[0]],df_TS23.columns[i[1]]))"
      "    #print('Distance Values List: ',dist_values)"
      "    #print('pop_resc_who: ',pop_resc_who)"
      )

    ;converting python variables to netlogo variables

    ifelse length(who-TS23-list) >= length(who-resc-list)[
      ;*************************************   NETLOGO: Number of rescuers <= Number of pop_TS23   ******************************************
      let resc-pop-who py:runresult "resc_pop_who"
      foreach resc-pop-who[
        i ->
        let resc-who item 0 i
        let pop-who item 1 i

        ask resc-agent resc-who [
          set target-agent pop-agent pop-who
          set node-agent-at [node-pop] of target-agent
          show target-agent
          show node-agent-at

          ask target-agent [
            set targeted? True
            set Rescue-by-ambulance? True
            set targeted-by resc-agent resc-who
            ;set label "targeted"
          ]
        ]

      ]
    ]
    [
       ;*************************************   NETLOGO: Number of rescuers > Number of pop_TS23   ******************************************
      let pop-resc-who py:runresult "pop_resc_who"
      foreach pop-resc-who[
        i ->
        let pop-who item 0 i
        let resc-who item 1 i
        ask resc-agent resc-who [
          set target-agent pop-agent pop-who
          set node-agent-at [node-pop] of target-agent
          show target-agent
          show node-agent-at

          ask target-agent [
            set targeted? true
            set Rescue-by-ambulance? True
            set targeted-by resc-agent resc-who
            ;set label "targeted"
          ]
        ]
      ]
    ]
]

  ;**********************************************************************************************************************************************************************************************************************************   Search TS 1 Agents
  if count pop-TS23 = 0 [
    let searching-resc-agents resc-agents with [target-agent = nobody and Mode = "Searching !!!"] ;list of resc-agents who are inactive/havent found an pop-agent to rescue

    let pop-TS1 pop-agents with [TS = 1 and Targeted? = False and deceased? = False]
    let who-TS1-list []
    let pop-TS1-nodes-list []
    let who-resc-list []
    let search-resc-nodes-list []
    let dist-to-TS1-list []

    ask pop-TS1 [
      set who-TS1-list lput who who-TS1-list ;list of TS1 agents who numbers
      set pop-TS1-nodes-list lput node-pop pop-TS1-nodes-list  ;list of pop-agent-nodes for agents in pop-TS23-list
  ]
    ask searching-resc-agents[
      set who-resc-list lput who who-resc-list ;list of resc-agents who are inactive
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

   ; print ("Who numbers of pop-TS23: ")
   ; show who-TS1-list
   ; show pop-TS1-nodes-list
   ; print ("Who numbers of resc-agents: ")
   ; show who-resc-list
   ; show search-resc-nodes-list
   ; show dist-to-TS1-list

    ;converting variables to python
    py:setup py:python3
    py:set "py_who_TS1_list" who-TS1-list
    py:set "py_who_resc_list" who-resc-list
    py:set "py_dist_to_TS1_list" dist-to-TS1-list

    ;running munkres algorithm
    (py:run
      "from munkres import Munkres"
      "import numpy as np"
      "import pandas as pd"
      "dist_arr = np.array(py_dist_to_TS1_list)"
      "dist_mat = dist_arr.reshape(len(py_who_resc_list),len(py_who_TS1_list))"

      ;*************************************   Number of rescuers <= Number of pop_TS1   ******************************************
      "if len(py_who_TS1_list) >= len(py_who_resc_list):"
      "    df_TS1 = pd.DataFrame()"
      "    df_TS1 = pd.concat([df_TS1, pd.DataFrame(dist_mat)],axis = 1)"
      "    df_TS1.columns = py_who_TS1_list"
      "    df_TS1.index = py_who_resc_list"

      "    m = Munkres()"
      "    indexes = m.compute(dist_mat)"
      "    #print('Munkres index (resc-agent, pop-agent) key value pairs: ',indexes)"
      "    #print(' -> resc-agent, pop-agent distance table: ')"
      "    #print(df_TS1)"

      ; To extract pop-agent and resc-agent who numbers from indexes
      "    dist_values = []"
      "    resc_pop_who = []"

      "    for i in indexes:"
      "        dist_values.append(df_TS1.iloc[i[0],i[1]])"
      "        resc_pop_who.append((df_TS1.index[i[0]],df_TS1.columns[i[1]]))"
      "    #print('Distance Values List: ',dist_values)"
      "    #print('resc_pop_who: ',resc_pop_who)"

      ;*************************************   Number of rescuers > Number of pop_TS1   ******************************************

      "else:"
      "    #print('inverse resc pop')"
      "    dist_mat_trans = np.transpose(dist_mat)"
      "    df_TS1 = pd.DataFrame()"
      "    df_TS1 = pd.concat([df_TS1, pd.DataFrame(dist_mat_trans)])"
      "    df_TS1.columns = py_who_resc_list"
      "    df_TS1.index = py_who_TS1_list"



      "    m = Munkres()"
      "    indexes = m.compute(dist_mat_trans)"
      "    #print('Munkres index (pop-agent, resc-agent) key value pairs: ',indexes)"
      "    #print(' -> pop-agent, resc-agent distance table: ')"
      "    #print(df_TS1)"

      ; To extract pop-agent and resc-agent who numbers from indexes
      "    dist_values = []"
      "    pop_resc_who = []"

      "    for i in indexes:"
      "        dist_values.append(df_TS1.iloc[i[0],i[1]])"
      "        pop_resc_who.append((df_TS1.index[i[0]],df_TS1.columns[i[1]]))"
      "    #print('Distance Values List: ',dist_values)"
      "    #print('pop_resc_who: ',pop_resc_who)"
      )
    ;converting python variables to netlogo variables

    ifelse length(who-TS1-list) >= length(who-resc-list)[
      ;*************************************   NETLOGO: Number of rescuers <= Number of pop_TS1  ******************************************
      let resc-pop-who py:runresult "resc_pop_who"
      foreach resc-pop-who[
        i ->
        let resc-who item 0 i
        let pop-who item 1 i

        ask resc-agent resc-who [
          set target-agent pop-agent pop-who
          set node-agent-at [node-pop] of target-agent
          show target-agent
          show node-agent-at

          ask target-agent [
            set targeted? True
            set Rescue-by-ambulance? True
            set targeted-by resc-agent resc-who
            ;set label "targeted"
          ]
        ]

      ]
    ]
    [
       ;*************************************   NETLOGO: Number of rescuers > Number of pop_TS1   ******************************************
      let pop-resc-who py:runresult "pop_resc_who"
      foreach pop-resc-who[
        i ->
        let pop-who item 0 i
        let resc-who item 1 i
        ask resc-agent resc-who [
          set target-agent pop-agent pop-who
          set node-agent-at [node-pop] of target-agent
          show target-agent
          show node-agent-at

          ask target-agent [
            set targeted? true
            set Rescue-by-ambulance? True
            set targeted-by resc-agent resc-who
            ;set label "targeted"
          ]
        ]
      ]
    ]
]
end

;************************************************************************************************************************************************************************************************************************************ Find Path
; FUNCTION TO IDENTIFY THE NODES BETWEEN RESCUE AGENT (AMBULANCE-TYPE A / AMBULANCE TYPE B) AND THEIR TARGET (POP-AGENT, PMA, HOSPITAL)
to find-path

  set current-node node-resc
  let end-location node-agent-at

  let path []
  ask node-resc [set path nw:turtles-on-weighted-path-to end-location netlogo-dist]
  set commute-path path

  set route-length length commute-path
end


;************************************************************************************************************************************************************************************************************************************ Follow Path
; MOVEMENT FUNCTION FOR HELI-AGENTS (HELICOPTERS) BASED ON THE MOVING FROM PATCH TO PATCH.
to follow-path-heli
  let speed-m-min (Speed-Helicopter * 1000 / 60)
  let jump-dist-m speed-m-min
  let speed-net-min speed-m-min * gis-net-convfac
  let jump-dist-net jump-dist-m * gis-net-convfac

  ;updates
  set distance-to-target distance patch-agent-at
  set current-patch patch-here
  face target-agent

  while [jump-dist-net > 0][

    (ifelse
      ;rem-fm-prev-run: Remaining distance left after jumping to a patch with an population agent
      ;remaining-distance: Remaining distance if the jump distance is greater than distance ot the patch
      ;jump-dist-net: Full jump distance
      ;rem-fm-prev-run > 0 [set Case 0]
      jump-dist-net < distance-to-target and remaining-distance <= 0 [set Case 1]
      jump-dist-net >= distance-to-target and remaining-distance <= 0 [set Case 2]
      remaining-distance < distance-to-target and remaining-distance > 0 [set Case 3]
      remaining-distance > distance-to-target and remaining-distance > 0 [set Case 4]
      )
    ;case 1: There distance to the agent is larger than jump distance so Jump full distance
    if case = 1[
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
    if case = 2[
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
    if case = 3[
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
    if case = 4[
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

;RESCUE AGENT / AMBULANCE AGENT (TYPE A/ TYPE B) MOVEMENT FUNCTION TO MOVE FROM ONE NODE TO ANOTHER.
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
      rem-fm-prev-run > 0 [set Case 0]
      jump-dist-net < distance-to-next-node and remaining-distance <= 0 [set Case 1]
      jump-dist-net >= distance-to-next-node and remaining-distance <= 0 [set Case 2]
      remaining-distance < distance-to-next-node and remaining-distance > 0 [set Case 3]
      remaining-distance > distance-to-next-node [set Case 4]
      )

    if Case = 0[
      set jump-dist-net (jump-dist-net + rem-fm-prev-run)
      set rem-fm-prev-run 0

    ]
   ;Case 1: There is no remaining distance so jump full distance provided that the distance to next node > jump distance
    if Case = 1[
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
    if Case = 2 [
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
        ;else statement: pop-agent present hence cannot jump further in one tick, therfore set jump-dist-net to zero to exit while loop and store the remainder distance in var remaining-distance to jump in the next turn
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
        if Case = 3[
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
    if Case = 4[
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
        ;Else statement: Pop-agent present in next node, hence cannot jump full remaining distance. Therefore jump portion of the remaining distance and add the remainder for the next round (remainder + jump-net-distance)
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

;*************************************************************************************************************************************************************************************************************************On route to hospital
; HELI-AGENT (HELICOPTER) , RESC-AGENT (AMBULANCE TYPE A) FUNCTION TO COLLECT POP-AGENTS (CASUALTIES) UPON ARRIVAL TO THE DESTINATION
to collect-agent
  set Rescued-agents-list lput target-agent Rescued-agents-list
  set collected-agent-count collected-agent-count + 1
  ask target-agent [
    if Rescue-by-ambulance? = True[
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



;************************************************************************************************************************************************************************************************************************************ Return to PMA

; RESC-AGENT (AMBULANCE TYPE-A) FUNCTION : IF THE CAPACITY OF THE NUMBER OF CASUALTIES HAVE REACHED, ASSIGNS THE DESTINATION AS PMA
to return-PMA
  ;Find PMA with least Queue / Closest PMA

  let vh-queue-length [length queue-TS1 + length queue-TS23] of PMA's with [nid = "Vieux Habitants PMA"]
  let sm-queue-length [length queue-TS1 + length queue-TS23] of PMA's with [nid = "Sainte Marie PMA"]

  ifelse vh-queue-length = sm-queue-length [
    ask node-resc[
      set G-target-node min-one-of nodes with [PMA-present != nobody][nw:weighted-distance-to myself netlogo-dist]
    ]
    ask G-target-node [
      set G-target-agent min-one-of PMA's in-radius 0.0001 [distance myself]
    ]
    ;print "Selected closest PMA"
    set node-agent-at G-target-node
    set target-agent G-target-agent
  ]
  [
    let target-PMA min-one-of PMA's [length queue-TS1 + length queue-TS23]
    ;print "Selected PMA with minimum queue"
    set node-agent-at [node-PMA] of target-PMA
    show node-agent-at
    set target-agent target-PMA
    show target-agent
  ]
end

;************************************************************************************************************************************************************************************************************************************ Time to Rescue
;HELI-AGENT (HELICOPTER) / RESC-AGENT (AMBULANCE TYPE-A) FUNCTION : ACTIVATES A TIME COUNTER SET AT THE USER INTERFACE, UPON REACHING ZERO, THE CASUALTY AGENT WILL BE COLLECTED.
to Time-to-Rescue
  set Rescue-time Rescue-time - 1
  set list-of-time lput 1 list-of-time
  ;set label Rescue-time
end

;************************************************************************************************************************************************************************************************************************************ Time to Transfer
;HELI-AGENT (HELICOPTER) / RESC-AGENT (AMBULANCE TYPE-A) FUNCTION : ACTIVATES A TIME COUNTER SET AT THE USER INTERFACE, UPON REACHING ZERO, THE CASUALTY AGENT WILL BE TRANSFERED TO PMA OR HOSPITAL
to Time-to-Transfer
  set Transfer-time Transfer-time - 1
  set list-of-time lput 1 list-of-time
  ;set label Transfer-time
end

;************************************************************************************************************************************************************************************************************************************ Setup PMA Capacity
;PMA FUNCTION : SETS THE PMA CAPACITY BASED ON OPERATIONAL TIMES, THESE ARE SET BY THE USER AT THE INTERFACE
to setup-PMA-capacity
  let time-1 (pma-operational-time-1)
  let time-2 (pma-operational-time-2)

  if ticks >= time-1 and ticks < time-2 [
    set PMA-capacity PMA-capacity-at-time-1
  ]
  if ticks >= time-2 [
    set PMA-capacity PMA-capacity-at-time-2
  ]
end

;*********************************************************************************************************************************************************************************************************************************** Move to Queue or Stabilisation
; RESC-AGENT/ PMA FUNCTION : UPON REACHING THE PMA (BY RESC-AGENT / AMBULANCE TYPE-A), CASUALTIES ARE TRANSFERED TO QUEUE OR STABILISATION. SATBILISATION BEING THE FIRST PREFERENCE UPON AVAILABILITY
to move-to-queue-or-stabilise
  let collected [Rescued-agents-list] of self ;collected: temp variable , collected-pop-agents: resc-agent variable holding the pop-agents that are in the ambulance
  ask target-agent[;ask PMA
    foreach collected[
      i ->
     ifelse length stabilise-TS23 + length stabilise-TS1 < PMA-capacity[
        ;if statement: When summation of stabilise TS23 & TS1 lists < PMA-capacity, MOVE TO STABILISE
        ask i[ ; ask pop-agent in Rescued-agents-list
          ifelse TS = 1[
            let temp-stabilise-TS1 [stabilise-TS1] of myself
            let temp-pop-TS1 self
            set temp-stabilise-TS1 lput temp-pop-TS1 temp-stabilise-TS1
            ask myself[
              set stabilise-TS1 temp-stabilise-TS1
              set stabilise-time-TS1 lput ticks stabilise-time-TS1
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 63]] ;stabilse-TS1 VH
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 64]] ; stabilise-TS1 SM
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
              set stabilise-time-TS23 lput ticks stabilise-time-TS23
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 63]] ;Stabilise-TS23 VH
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 64]] ;stabilise-TS23 SM
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
            ifelse TS = 1[ ; For pop-agent of Trauma scale category 1
            let temp-queue-TS1 [queue-TS1] of myself
            let temp-pop-TS1 self
            set temp-queue-TS1 lput temp-pop-TS1 temp-queue-TS1
            ask myself[
              set queue-TS1 temp-queue-TS1
              set Queue-Time-TS1 lput ticks Queue-Time-TS1
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 55]] ;Queue-TS1 VH
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 54]] ;Queue-TS1 SM
            set Queue-Time ticks
            set on-route-PMA? False
            set in-queue? True
            set hidden? False
            set label ""
          ]
          [
            ; For pop-agent of Trauma scale category 2 or 3
            let temp-queue-TS23 [queue-TS23] of myself
            let temp-pop-TS23 self
            set temp-queue-TS23 lput temp-pop-TS23 temp-queue-TS23
            ask myself[
              set queue-TS23 temp-queue-TS23
              set Queue-time-TS23 lput ticks Queue-Time-TS23
            ]
            set PMA-at myself
            set PMA-name [nid] of myself
            set node-pop [node-PMA] of myself
            if PMA-name = "Vieux Habitants PMA" [move-to one-of patches with [pcolor = 55]] ;Queue-TS23 VH
            if PMA-name = "Sainte Marie PMA"[move-to one-of patches with [pcolor = 54]] ;Queue-TS23 SM
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

;******************************************************************************************************************************************************************************************************************************* Move from Queue to Stabilisation

;PMA FUNCTION : MOVES POP-AGENTS (CASUALTIES) FROM QUEUE TO TO STABILISATION IF THERE IS AVIALBLE CAPACITY IN STABILISATION QUEUE.
to move-from-queue-stabilise
  ;move-from-queue-stabilise: Function to move TS1 & TS23 pop agents from Queue to Stabilisation at PMA

  ; to add TS23 from Queue to stabilisation
  while [ length Queue-TS23 > 0 and ((length stabilise-TS23 + length stabilise-TS1) < PMA-capacity)][
    let agent-to-move item 0 Queue-TS23
    let agent-pos position agent-to-move Queue-TS23
    set stabilise-TS23 lput agent-to-move stabilise-TS23
    set stabilise-time-TS23 lput ticks stabilise-time-TS23
    set Queue-time-TS23 remove-item agent-pos Queue-Time-TS23
    set Queue-TS23 remove agent-to-move Queue-TS23


    ask agent-to-move [
      if PMA-name = "Vieux Habitants PMA" [
        move-to one-of patches with [pcolor = 63] ;Stabilise-TS23 VH
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
      ]
      if PMA-name = "Sainte Marie PMA" [
        move-to one-of patches with [pcolor = 64] ; Stabilise-TS23 SM
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
    set stabilise-time-TS1 lput ticks stabilise-time-TS1
    set Queue-time-TS1 remove-item agent-pos Queue-time-TS1
    set Queue-TS1 remove agent-to-move Queue-TS1

    ask agent-to-move [
      if PMA-name = "Vieux Habitants PMA" [
        move-to one-of patches with [pcolor = 63] ;Stabilise-TS1
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
    ]
      if PMA-name = "Sainte Marie PMA" [
        move-to one-of patches with [pcolor = 64] ;Stabilise-TS1
        set stabilise-time ticks
        set in-stabilisation? True
        set in-queue? False
      ]
    ]
  ]
end

;********************************************************************************************************************************************************************************************************************************************* TS1 Recovered

;TS1-recovered: Function to send TS1 pop-agents home
to TS1-recovered
  foreach stabilise-time-TS1[
    i ->
    let time-passed ticks - i
    ifelse time-passed >= time-to-stabilise[
      let pos position i stabilise-time-TS1
      let recovered-agent item pos stabilise-TS1

      ;add recovered--agent and recovered-time to global list
      set recovered-TS1 lput recovered-agent recovered-TS1
      set recovered-time-TS1 lput ticks recovered-Time-TS1

      ;print ("The recovered agent is: ") show recovered-agent
      set stabilise-time-TS1 remove-item pos stabilise-time-TS1
      set stabilise-TS1 remove recovered-agent stabilise-TS1

      ask recovered-agent[
        move-to one-of patches with [pcolor = 14]
        set in-stabilisation? False
        set recovered? True
        set recovered-time ticks
      ]
    ]
    [
    ;else statement: time passed < time-to-stabilise dont do anything.
    ]
  ]
end

;************************************************************************************************************************************************************************************************************************************* Transfer to ambulance
to transfer-to-ambulance
  foreach stabilise-time-TS23[
    i ->
    let time-passed ticks - i
    ifelse time-passed >= time-to-stabilise[
      let pos position i stabilise-time-TS23
      let hospitalization-agent item pos stabilise-TS23
      set stabilise-time-TS23 remove-item pos stabilise-time-TS23
      set stabilise-TS23 remove hospitalization-agent stabilise-TS23
      ask hospitalization-agent [
        set hidden? False
        set in-stabilisation? False
        set to-be-hospitalised? True
        set to-be-hospitalised-time ticks
        move-to node-pop
      ]
    ]
    [
      ;else statement: if time hasnt exceeded time-to-stabilise do nothing
    ]
  ]
  let agents-to-be-hospitalised pop-agents with [to-be-hospitalised? = True and (TS = 2 or TS = 3)]
  if any? agents-to-be-hospitalised in-radius 0.0001 [
    hatch-ambulances 1[
      set size 16.25
      set shape "ambulance-2-shape"
      set label ""
      set node-resc [node-PMA] of myself
      set collected-agents-TS2 []
      set collected-agents-TS3 []
      set Mode "inactive"
      set list-of-distances []
      set list-of-time []
      set list-of-m-distances []
    ]

    let temp-list-TS2 []
    let temp-list-TS3 []
    ask agents-to-be-hospitalised [
      if TS = 2[
        set temp-list-TS2 fput self temp-list-TS2
        ;print ("Temp list TS2: ")
        show temp-list-TS2
        set to-be-hospitalised? False
      ]
      if TS = 3[
        set temp-list-TS3 fput self temp-list-TS3
        ;print("Temp list TS3: ")
        show temp-list-TS3
        set to-be-hospitalised? False
      ]
    ]

    ask one-of ambulances with [Mode = "inactive"][

      set collected-agents-TS2 temp-list-TS2
      foreach collected-agents-TS2[
        i ->
        ask i[
          set on-route-hospital? True
          set on-route-hospital-time ticks
          move-to one-of patches with [pcolor = 25]
        ]
    ]
      set collected-agents-TS3 temp-list-TS3
      foreach collected-agents-TS3[
        i ->
        ask i[
          set on-route-hospital? True
          set on-route-hospital-time ticks
          move-to one-of patches with [pcolor = 25]
        ]
      ]
      if not empty? collected-agents-TS2 or not empty? collected-agents-TS3 [
        set Mode "Active"
      ]
    ]
  ]
end

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

to reset-lists-variables-heli
  set rescued-agents-list []
  set collected-agents-TS2 []
  set collected-agents-TS3 []
  set target-agent nobody
  set patch-agent-at nobody
  set transfer-time Transfer-time-mins
end

;**************************************************************************************************************************************************************************************************************************************** Select Bed Type
to select-bed-type
  let temp-TS2-list collected-agents-TS2
  let temp-TS3-list collected-agents-TS3
  ask hospitals[
   foreach temp-TS2-list[
     i ->
     (ifelse
        length Burn-Beds-TS2 + length Burn-Beds-TS3 < no-of-burn-beds[
          set Burn-Beds-TS2 lput i Burn-Beds-TS2
          set Burn-Beds-Time-TS2 lput ticks Burn-Beds-Time-TS2
        ]
        length Non-Burn-Beds-TS2 + length Non-Burn-Beds-TS3 < no-of-non-burn-beds[
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
        length Burn-Beds-TS2 + length Burn-Beds-TS3 < no-of-burn-beds[
          set Burn-Beds-TS3 lput i Burn-Beds-TS3
          set Burn-Beds-Time-TS3 lput ticks Burn-Beds-Time-TS3
        ]
        length Non-Burn-Beds-TS2 + length Non-Burn-Beds-TS3 < no-of-non-burn-beds[
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
end

;***************************************************************************************************************************************************************************************************************************** From Non Burn to Burn Beds
to from-non-to-burn-beds
  foreach Non-Burn-Beds-TS2[
    i ->
    ifelse length Burn-beds-TS2 + length Burn-Beds-TS3 < no-of-burn-beds[
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
    ifelse length Burn-Beds-TS2 + length Burn-Beds-TS3 < no-of-burn-beds[
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

;************************************************************************************************************************************************************************************************************************ From Hospital Queue to Non Burn Beds
to from-Hospital-Queue-to-Non-Burn-Beds
  foreach Hospital-Queue-TS2[
    i ->
    if ((length Non-Burn-beds-TS2) + (length Non-Burn-Beds-TS3)) < No-of-Non-Burn-Beds[
      set Non-Burn-Beds-TS2 lput i Non-Burn-Beds-TS2
      set Non-burn-Beds-Time-TS2 lput ticks Non-Burn-Beds-time-TS2

      let i-pos position i  Hospital-Queue-TS2
      set Hospital-Queue-Time-TS2 remove-item i-pos Hospital-Queue-Time-TS2
      set Hospital-Queue-TS2 remove i Hospital-Queue-TS2

      ask i[
        move-to one-of patches with [pcolor = 95]
        set in-Hospital-Queue? False
        set in-Non-Burn-Beds? True
        set NBB-admission-time ticks
      ]
    ]
  ]
    foreach Hospital-Queue-TS3[
    i ->
    if ((length Non-Burn-beds-TS2) + (length Non-Burn-Beds-TS3)) < No-of-Non-Burn-Beds[
      set Non-Burn-Beds-TS3 lput i Non-Burn-Beds-TS3
      set Non-burn-Beds-Time-TS3 lput ticks Non-Burn-Beds-time-TS3

      let i-pos position i  Hospital-Queue-TS3
      set Hospital-Queue-Time-TS3 remove-item i-pos Hospital-Queue-Time-TS3
      set Hospital-Queue-TS3 remove i Hospital-Queue-TS3

      ask i[
        move-to one-of patches with [pcolor = 95]
        set in-Hospital-Queue? False
        set in-Non-Burn-Beds? True
        set NBB-admission-time ticks
      ]
    ]
  ]
end

;******************************************************************************************************************************************************************************************************************************************* Find Hospital
to find-hospital
  set target-agent one-of hospitals
  let hospital-at [node-hosp] of target-agent
  set node-agent-at hospital-at
  set Mode "Find Commute Path"
end


;*******************************************************************************************************************************************************************************************************************************************REMOVE AGENTS
;************************************************************************************************************************************************************************************************************************************** Renew Resc lists
to renew-resc-list
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
end

;************************************************************************************************************************************************************************************************************************************* Renew Ambulance Lists
to renew-ambulance-list
  foreach collected-agents-TS2[
    i ->
    ask i[
      if deceased? = true[
        let agent-to-be-removed self
        ask myself [
          set collected-agents-TS2 remove agent-to-be-removed collected-agents-TS2
        ]
      ]
    ]
  ]
   foreach collected-agents-TS3[
     i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          set collected-agents-TS3 remove agent-to-be-removed collected-agents-TS3
        ]
      ]
    ]
  ]
end

;************************************************************************************************************************************************************************************************************************************** Renew PMA Lists
;remove decesed agents from stabilise and queue list
to renew-PMA-lists

  foreach Queue-TS23[
    i ->
    ask i[
      if deceased? = True[
        let agent-to-be-removed self
        ask myself [
          let agent-pos position agent-to-be-removed Queue-TS23
          set Queue-Time-TS23 remove-item agent-pos Queue-Time-TS23
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
          set stabilise-Time-TS23 remove-item agent-pos stabilise-Time-TS23
          set stabilise-TS23 remove agent-to-be-removed stabilise-TS23
        ]
      ]
    ]
  ]
end

;**************************************************************************************************************************************************************************************************************************************** Renew Hospital lists
;remove decesed agents from Non & Burn Beds list
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

end

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


;*************************************************************************************************************************************************************************************************************************************************** UPDATE LISTS
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
  if ((on-route-hospital? = True or to-be-hospitalised? = true) and (not member? self Decd-OnRout-hosp-TS3))[
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
  if ((on-route-hospital? = True or to-be-hospitalised? = true) and (not member? self Decd-OnRout-hosp-TS2))[
    set Decd-OnRout-hosp-TS2 lput self Decd-OnRout-hosp-TS2
    set Decd-OnRout-hosp-time-TS2 lput ticks Decd-OnRout-hosp-time-TS2
  ]
   if ((in-Hospital-Queue? = True) and (not member? self Decd-Hosp-Q-TS2)) [
    set Decd-Hosp-Q-TS2 lput self Decd-Hosp-Q-TS2
    set Decd-Hosp-Q-time-TS2 lput ticks Decd-Hosp-Q-time-TS2
  ]
end



;************************************************************************************************************************************************************************************************************************************ Apply Mortality Rates

to apply-mortality-rates
  ;Mortality rate for TS3 agents are constant throughout model run
  foreach (range 240 2880 60)[
    i ->
    if ticks = i[
    ;print "chk 1"
      let agent-pecent round (0.8 * (count pop-agents with [TS = 3 and Deceased? = False]))
      ask n-of agent-pecent (pop-agents with [TS = 3 and Deceased? = False]) [
        ;print "chk 2"
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
       ask pop-agents with [TS = 3 and Deceased? = True][
        update-TS3-lists
      ]
    ]
  ]

  ;define agent sets for TS2 based on their current status to apply appropriate mortailty rate
  let TS2-BB-treat pop-agents with [TS = 2 and in-Burn-beds? = True and Deceased? = False]
  let TS2-NB-treat pop-agents with [TS = 2 and in-Non-Burn-beds? = True and deceased? = False]
  let TS2-pretreat pop-agents with [TS = 2 and (in-Burn-beds? = False and in-Non-Burn-Beds? = False) and Deceased? = False]

  ; mortality rate TS2 in Burned Beds
  foreach (range 240 2880 60)[
    i ->
    if ticks = i[
      let agent-percent round (0.00167 * (count TS2-BB-treat))
      ask n-of agent-percent (TS2-BB-Treat) [
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
       ask pop-agents with [TS = 2 and Deceased? = True][
         Update-TS2-BB-lists
      ]
    ]
  ]

  ; mortality rate TS2 in Non Burned Beds
  foreach (range 240 1440 60)[
    i ->
    if ticks = i[
      let agent-percent round (0.0017 * (count TS2-NB-treat))
      ask n-of agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
  foreach (range 1440 2880 60)[
    i ->
    if ticks = i[
      let agent-percent round (0.0066 * (count TS2-NB-treat))
      ask n-of agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
  foreach (range 2880 4320 60)[
    i ->
    if ticks = i[
      let agent-percent (0.0092 * (count TS2-NB-treat))
      ask n-of agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
  foreach (range 4320 5760 60)[
    i ->
    if ticks = i[
      let agent-percent (0.0063 * (count TS2-NB-treat))
      ask n-of agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]
 foreach (range 5760 99999 60)[
    i ->
    if ticks = i[
      let agent-percent (0.0063 * (count TS2-NB-treat))
      ask n-of agent-percent (TS2-NB-Treat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-TS2-NBB-lists
      ]
    ]
  ]

  ;Mortality rate for rest of TS2
  foreach (range 240 480 60)[
    i ->
    if ticks = i[
      let agent-percent (0.0125 * (count TS2-pretreat))
      ask n-of agent-percent (TS2-pretreat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-rest-of-TS2-lists
      ]
    ]
  ]
  foreach (range 480 720 60)[
    i ->
    if ticks = i[
    let agent-percent (0.075 * (count TS2-pretreat))
    ask n-of agent-percent (TS2-pretreat)[
      set deceased? true
      set deceased-time ticks
      move-to one-of patches with [pcolor = 4]
      set hidden? False
      ]
     ask pop-agents with [TS = 2 and Deceased? = True][
      Update-rest-of-TS2-lists
      ]
    ]
  ]
  foreach (range 720 1440 60)[
    i ->
    if ticks = (range 780 1440 60)[
      let agent-percent (0.0333 * (count TS2-pretreat))
      ask n-of agent-percent (TS2-pretreat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
      Update-rest-of-TS2-lists
      ]
    ]
  ]
  foreach (range 1440 99999 60)[
    i ->
    if ticks = i[
      let agent-percent (0.0417 * (count TS2-pretreat))
      ask n-of agent-percent (TS2-pretreat)[
        set deceased? true
        set deceased-time ticks
        move-to one-of patches with [pcolor = 4]
        set hidden? False
      ]
      ask pop-agents with [TS = 2 and Deceased? = True][
        Update-rest-of-TS2-lists
      ]
    ]
  ]

  ask resc-agents [renew-resc-list]
  ask ambulances [renew-ambulance-list]
  ask PMA's [renew-pma-lists]
  ask hospitals [renew-hospital-lists]
  ask heli-agents[renew-helicopter-list]
end


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! END OF SUPPORT FUNCTIONS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO GO

to go

  if ticks >= 60 and ticks <= 7200[

    ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RESCUE AGENT FUNCTIONS
    ask resc-agents with [Mode = "Searching !!!"][
      ifelse count pop-agents with [targeted? = False and deceased? = False] != 0[ ; stops search function if there are no pop-agents left
      ;radius-search
        if target-agent = nobody[
          setup-munkres
        ]
      ]
      ;else statement: if pop-agents are zero
      [
        set mode "Return to PMA"
        ;set label Mode

      ]
      if target-agent != nobody and is-pop-agent? target-agent[
        set color [color] of target-agent
        set Mode "Find Path"
        ;set label Mode
      ]
    ]

   ;***************************************************************************************************** FIND PATH
  ask resc-agents with [Mode = "Find Path"][
    find-path
    ifelse commute-path != False and length commute-path > 1 [
      set Mode "Active"
      ;set label Mode
    ]
    [
      ;else statement: Containing two if statements
      if commute-path = False [
        output-print "ERROR THERE IS NO COMMUTE PATH FOR RESC OR AMBULANCE AGENTS"
      ]
      if length commute-path = 1[
        set Mode "Rescuing !!!"
        ;output-print "Two agents on same Node satisfied"
      ]
    ]
  ]

    ;************************************************************************************************** TRAVEL TO PMA
  ask resc-agents with [Mode = "Travel to PMA"][
    ifelse current-node = node-agent-at and is-PMA? target-agent[
      set Mode "At PMA"
      set rescue-time 10
    ]
    [
      set color green
      follow-path
    ]
  ]

    ;****************************************************************** TRANSFERING AGENTS TO QUEUE OR STABILISATION
    ask resc-agents with [Mode = "At PMA"][
      Time-to-Transfer
      if transfer-time = 0
      [
        set label ""
        move-to-queue-or-stabilise
        set collected-agent-count 0 ; At PMA, after unloading casualties set counter to 0
        ifelse count pop-agents with [targeted? = false] != 0[
          ;At PMA check if there are any pop-agents who havent been targeted
          set Mode "Searching !!!"
          set transfer-time transfer-time-mins
          set target-agent nobody
        ]
        [
          ;else statement: If there are no pop-agents left dont do anything
          set Mode "Return to PMA"
          ;set label Mode
        ]
      ]
    ]



    ;********************************************************************************** RESCUE / TIME TO COLLECT AGENT

  ask resc-agents with [Mode = "Rescuing !!!"][
   Time-to-Rescue
      (ifelse
        rescue-time = 0 and ([deceased?] of target-agent = False)[
          collect-agent
          set label ""
          ifelse (collected-agent-count = resc-agent-capacity) or (count pop-agents with [deceased? = False and awaiting-rescue? = True] = 0)[
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

     ;*********************************************************************************************** FIND CLOSEST PMA
  ask resc-agents with [Mode = "Return to PMA"][
    return-PMA
    find-path
    set Mode "Travel to PMA"
  ]

  ;**************************************************************************************************** FOLLOW PATH
  ask resc-agents with [Mode = "Active"][
      ifelse is-pop-agent? target-agent and [Deceased?] of target-agent = true[
        set mode "Searching !!!"
        set target-agent nobody
      ]
      [
      follow-path
      ]
    if (current-node = node-agent-at)[
        ifelse (is-pop-agent? target-agent) and (length rescued-agents-list < resc-agent-capacity) and ([Deceased?] of target-agent != true )[
          set Mode "Rescuing !!!"

        ]
        [
          ;else statement: if the agent has died
          set Mode "Searching !!!"
        ]
    ]
  ]

  ;**************************************************************************************************  RESCUE ENDED
  ask resc-agents with [Mode = "Rescue Ended"][
    set list-of-time fput 1 list-of-time
  ]
  ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ HELICOPTER RESCUE
    if helicopter-rescue = True [
      ask heli-agents with [Mode = "Searching !!!"][
        ifelse count pop-agents with [(TS = 2 or TS = 3) and targeted? = False and deceased? = False] != 0[
          if target-agent = nobody[
            setup-munkres-heli
          ]
        ]
        [
          ;Else statement: if there are no TS2 or TS3 agents to rescue anymore,
          ;Helicopter already at site and have already rescued more than one agent: go to hospital
          ifelse length Rescued-agents-list > 0 [
            set Mode "Return to Hospital"
            set target-agent one-of hospitals
            set patch-agent-at hospital-patch
          ]
          ;Helicopter at hospital but no agents to rescue: go to helipad
          [
            set Mode "Return to Helipad"
            move-to helipad-patch
            set current-patch helipad-patch
            set target-agent nobody
            set patch-agent-at nobody
          ]
        ]

        if target-agent != nobody and is-pop-agent? target-agent[
          set Mode "Active"
        ]
      ]
      ask heli-agents with [Mode = "Active"][
        follow-path-heli
        if current-patch = patch-agent-at[
          set Mode "Rescuing !!!"
        ]
      ]

      ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Helicopter : Time to Rescue Agent

      ask heli-agents with [Mode = "Rescuing !!!"][
        time-to-rescue
        (ifelse rescue-time = 0 and [deceased?] of target-agent = False[
          collect-agent
          ifelse collected-agent-count =  Helicopter-capacity or (count pop-agents with [ (TS = 2 or TS = 3) and deceased? = False and awaiting-rescue? = True] = 0)[
            set Mode "Return to Hospital"
            set target-agent one-of hospitals
            set patch-agent-at hospital-patch
            set Rescue-time Rescue-time-mins
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

      ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Helicopter : Return to Hospital and at hospital

      ask heli-agents with [Mode = "Return to Hospital"][
        follow-path-heli
        if is-hospital? target-agent and current-patch = patch-agent-at[
          set Mode "At Hospital"
        ]
      ]
      ask heli-agents with [Mode = "At Hospital"][
        Time-to-transfer
        if transfer-time = 0[
          identify-TS2-TS3-Heli
          set collected-agent-count 0
          select-bed-type
          reset-lists-variables-heli
          set Mode "Searching !!!"
        ]
      ]
    ]

  ;######################################################################################################



  ;************************* SETUP PMA CAPACITY, TRANSFERING AGENTS FROM QUEUE TO AT STABILISATION, REMOVING DEAD AGENTS

  ask PMA's [
    setup-PMA-capacity
    renew-PMA-lists ; this is for removeing deceased agents
    move-from-queue-stabilise
    TS1-recovered
    transfer-to-ambulance
  ]

  ;****************************************************************************************** FIND HOSPITAL
  ask ambulances with [Mode = "Active"][
    set Transfer-time Transfer-time-mins
    find-hospital
  ]
  ;***************************************************************************************** HOSPITAL COMMUTE PATH
  ask ambulances with [Mode = "Find Commute Path"][
    ;print "Finding commute path"
    find-path
    Time-To-Transfer
    if transfer-time = 0[
    set Mode "Travel to Hospital"
    set transfer-time transfer-time-mins
    ]
  ]
  ;***************************************************************************************** TRAVEL TO HOSPITAL
  ask ambulances with [Mode = "Travel to Hospital"][
    follow-path
    if (current-node = node-agent-at)[
      Time-to-Transfer
      set label ""
      if Transfer-Time = 0[
      select-bed-type
      die
      ]
    ]
  ]
  ;***************************************************************************************** MOVE AGENTS FROM NON BURN BEDS TO BURN BEDS
  ask hospitals[
    renew-hospital-lists
    from-non-to-burn-beds
    from-Hospital-Queue-to-Non-Burn-Beds
  ]

  ;***************************************************************************************** TIME UPDATE FUNCTIONS
    ask resc-agents with [Mode = "Rescue Ended"][
    set list-of-time fput 1 list-of-time
  ]
  let time-since-eruption 60
  ;set avg-time time-since-eruption + (sum [sum list-of-time] of resc-agents) / count resc-agents
  ]

  ;**************************************************************************************** Update ticks
  if ticks >= 0 and ticks <= 7200 [
  tick

 ;***************************************************************************************** TO APPLY MORTALITY RATES AND REMOVE AGENTS
    apply-mortality-rates

  ]
end

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Print Data    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Print lists
;List Method
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


;Agentset
to print-count-agents
  output-print "Agents on route to PMA : " output-print count pop-agents-on patches with [pcolor = 125]

  output-type "Agents in VH Queue : " output-print count pop-agents-on patches with [pcolor = 55]
  output-type "Agents in SM Queue : " output-print count pop-agents-on patches with [pcolor = 54]
  output-type "Agents in VH Stabilisation : " output-print count pop-agents-on patches with [pcolor = 63]
  output-type "Agents in SM Stabilisation : " output-print count pop-agents-on patches with [pcolor = 64]

  output-type "Agents on route to Hospital (Ambulance) : " output-print count pop-agents-on patches with [pcolor = 25]
  output-type "Agents on route to Hospital (Helicopter) : " output-print count pop-agents-on patches with [pcolor = 34]

  output-type "Agents in hospital queue : " output-print count pop-agents-on patches with [pcolor = 84]
  output-type "Agents in Non Burn Beds : " output-print count pop-agents-on patches with [pcolor = 95]
  output-type "Agents in Burn Beds : " output-print count pop-agents-on patches with [pcolor = 94]

  output-type "Agents Deceased : " output-print count pop-agents-on patches with [pcolor = 4]
  output-type "Recovered-TS1 : " output-print count pop-agents-on patches with [pcolor = 14]

end
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
1. Press Setup to load Gis Environment\n    Press Go to Run Model
11
0.0
1

BUTTON
21
51
85
84
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
91
51
154
84
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
16
266
305
313
3. Select Number of Rescue Agents, Vehical Speed (Km/h), Capacity of casualties that can be carried, Rescue time (mins) and Transfer times to PMA / Hospital (mins)
11
0.0
1

SLIDER
15
329
168
362
Number-of-Rescuers
Number-of-Rescuers
0
50
15.0
1
1
NIL
HORIZONTAL

CHOOSER
215
370
307
415
Speed
Speed
20 30 40 50 60 70 80
4

CHOOSER
15
370
107
415
Rescue-Time-Mins
Rescue-Time-Mins
10 20 30
0

CHOOSER
115
370
207
415
Transfer-Time-Mins
Transfer-Time-Mins
5 10 15
0

SLIDER
175
329
327
362
Resc-Agent-Capacity
Resc-Agent-Capacity
1
5
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
19
448
299
490
4. Select PMA opening hours and corresponding capacity at each time, Time Taken to stabilise casualties
11
0.0
1

SLIDER
18
497
223
530
PMA-Capacity-At-Time-1
PMA-Capacity-At-Time-1
0
50
20.0
1
1
ppl
HORIZONTAL

SLIDER
18
535
223
568
PMA-Capacity-At-Time-2
PMA-Capacity-At-Time-2
PMA-Capacity-At-Time-1
160
60.0
1
1
ppl
HORIZONTAL

CHOOSER
19
573
152
618
PMA-Operational-Time-1
PMA-Operational-Time-1
60 120 180
0

CHOOSER
162
573
295
618
PMA-Operational-Time-2
PMA-Operational-Time-2
60 120 180 240 300
4

SLIDER
20
625
192
658
Time-To-Stabilise
Time-To-Stabilise
0
30
15.0
1
1
mins
HORIZONTAL

TEXTBOX
16
688
325
707
5. Select number of burn beds and regular beds at the hospital
11
0.0
1

SLIDER
20
716
216
749
no-of-burn-beds
no-of-burn-beds
0
100
25.0
1
1
beds
HORIZONTAL

SLIDER
20
760
216
793
no-of-non-burn-beds
no-of-non-burn-beds
0
500
50.0
1
1
beds
HORIZONTAL

PLOT
1623
226
1823
376
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
"TS1" 1.0 0 -4079321 true "" "plot count pop-agents with [TS = 1 and Recovered? = true]"

PLOT
1205
226
1405
376
Casualties in Burn Beds
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
"TS3" 1.0 0 -5298144 true "" "plot count pop-agents with [ TS = 3 and in-burn-beds? = True and Deceased? = False]"
"TS2" 1.0 0 -817084 true "" "plot count pop-agents with [ TS = 2 and in-burn-beds? = True and Deceased? = False]"

PLOT
1413
226
1613
376
Casualties in Non Burn Beds 
Time
No of Casualities 
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"TS3" 1.0 0 -5298144 true "" "plot count pop-agents with [ TS = 3 and in-Non-Burn-Beds? = True and Deceased? = False]"
"TS2" 1.0 0 -817084 true "" "Plot count pop-agents with [ TS = 2 and in-Non-Burn-Beds? = True and Deceased? = False]"

PLOT
1623
68
1823
218
Deceased
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
"TS3" 1.0 0 -5298144 true "" "plot count pop-agents with [ TS = 3 and Deceased? = True]"
"TS2" 1.0 0 -817084 true "" "plot count pop-agents with [ TS = 2 and Deceased? = True]"
"TS1" 1.0 0 -4079321 true "" "plot count pop-agents with [ TS = 1 and Deceased? = True]"

PLOT
1187
387
1512
611
Deceased Casualties
Time
No of Deceased
0.0
10.0
0.0
10.0
true
true
"  ;Recovered-lists for TS1\n  set Recovered-TS1 []\n  set Recovered-Time-TS1 []\n\n  ;Dead Queue PMA lists for TS2 & TS3\n  set Decd-Queue-TS2 []\n  set Decd-Queue-Time-TS2 []\n  set Decd-Queue-TS3 []\n  set Decd-Queue-Time-TS3 []\n\n  ;Dead stabilise PMA lists for TS2 & TS3\n  set Decd-stabilise-TS2 []\n  set Decd-stabilise-Time-TS2 []\n  set Decd-stabilise-TS3 []\n  set Decd-stabilise-Time-TS3 []\n\n  ;Dead Burn Beds Hospital list for TS2 & TS3\n  set Decd-BB-TS2 []\n  set Decd-BB-Time-TS2 []\n  set Decd-BB-TS3 []\n  set Decd-BB-Time-TS3 []\n\n  ;Dead Non Burn Beds Hospital lists for TS2 & TS3\n  set Decd-NBB-TS2 []\n  set Decd-NBB-Time-TS2 []\n  set Decd-NBB-TS3 []\n  set Decd-NBB-Time-TS3 []\n\n  ;Dead Hospital Queue lists for TS2 & TS3\n  set Decd-Hosp-Q-TS2 []\n  set Decd-Hosp-Q-time-TS2 []\n  set Decd-Hosp-Q-TS3 []\n  set Decd-Hosp-Q-Time-TS3 []\n\n  ;Dead Awaiting rescue lists for TS2 & TS3\n  set Decd-AwaResc-TS2 []\n  set Decd-AwaResc-Time-TS2 []\n  set Decd-AwaResc-TS3 []\n  set Decd-AwaResc-Time-TS3 []\n\n  ;Dead on the way to PMA lists for TS2 & TS3\n  set Decd-OnRout-PMA-TS2 []\n  set Decd-OnRout-PMA-Time-TS2 []\n  set Decd-OnRout-PMA-TS3 []\n  set Decd-OnRout-PMA-Time-TS3 []\n\n  ;Dead on the way to hospital lists for TS2 & TS3\n  set Decd-OnRout-Hosp-TS2 []\n  set Decd-OnRout-Hosp-Time-TS2 []\n  set Decd-OnRout-Hosp-TS3 []\n  set Decd-OnRout-Hosp-Time-TS3 []" ""
PENS
"Awaiting Resc" 1.0 0 -7500403 true "" "plot (length Decd-AwaResc-TS3 + length Decd-AwaResc-TS2)"
"Route PMA" 1.0 0 -2674135 true "" "plot (length Decd-OnRout-PMA-TS3 + length Decd-OnRout-PMA-TS2)"
"Queue" 1.0 0 -5825686 true "" "plot (length Decd-Queue-TS3 + length Decd-Queue-TS2)\n"
"Stabilisation" 1.0 0 -6459832 true "" "plot (length Decd-stabilise-TS3 + length Decd-stabilise-TS2)"
"Route Hospital" 1.0 0 -4079321 true "" "plot (length Decd-OnRout-Hosp-TS3 + length Decd-OnRout-Hosp-TS2)"
"Burn Beds" 1.0 0 -13791810 true "" "plot (length Decd-BB-TS3 + length Decd-BB-TS2)"
"Non Burn Beds" 1.0 0 -13840069 true "" "plot (length Decd-NBB-TS3 + length Decd-NBB-TS2)"
"Hospital Q" 1.0 0 -14835848 true "" "plot (length Decd-Hosp-Q-TS3 + length Decd-Hosp-Q-TS2)"

PLOT
1520
387
1846
609
Status of casualties
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
"Awaiting Rescue" 1.0 0 -10899396 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and Awaiting-Rescue? = True and Deceased? = True]\n]"
"on route to pma" 1.0 0 -14835848 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and on-route-PMA? = True and Deceased? = True]\n]"
"in queue" 1.0 1 -4079321 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and in-queue? = True and Deceased? = True]\n]"
"in stabilisation" 1.0 1 -11221820 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and in-stabilisation? = True and deceased? = True]\n]"
"on route to hospital" 1.0 1 -13791810 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and on-route-hospital? = True and deceased? = True]\n]"
"in burn beds" 1.0 1 -13345367 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and in-burn-beds? = True and deceased? = True]\n]"
"in non burn beds" 1.0 1 -8630108 true "" "if ticks = 7200[\nplot count pop-agents with [TS = 2 and in-non-burn-beds? = True and deceased? = True]\n]"
"in hospital queue" 1.0 1 -5825686 true "" "if ticks = 7200[\nplot count pop-agents with[TS = 2 and in-hospital-queue? = True and deceased? = true]\n]"

TEXTBOX
1202
10
1854
78
A Casualty Rescue, Transport and Treatment Model Using Agent Based Simulation
20
105.0
1

SWITCH
188
161
327
194
Helicopter-rescue
Helicopter-rescue
0
1
-1000

TEXTBOX
13
115
316
143
2. Select if Helicopter rescue is considered\n     Select No of Helicopters, capacity of casualties and speed
11
0.0
1

SLIDER
15
202
179
235
Number-of-Helicopters
Number-of-Helicopters
0
5
2.0
1
1
NIL
HORIZONTAL

CHOOSER
188
198
282
243
Speed-Helicopter
Speed-Helicopter
200 300 400
0

SLIDER
15
161
179
194
Helicopter-Capacity
Helicopter-Capacity
0
5
2.0
1
1
NIL
HORIZONTAL

PLOT
1204
69
1404
219
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
"VX" 1.0 0 -13345367 true "" "plot count pop-agents with [pma-name = \"Vieux Habitants PMA\" and in-queue? = True and deceased? = False]"
"SM" 1.0 0 -10899396 true "" "plot count pop-agents with[pma-name = \"Sainte Marie PMA\" and in-queue? = True and deceased? = False]"

PLOT
1412
69
1612
219
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
"VX" 1.0 0 -13345367 true "" "plot count pop-agents with [pma-name = \"Vieux Habitants PMA\" and in-stabilisation? = True and deceased? = False]"
"SM" 1.0 0 -10899396 true "" "plot count pop-agents with[pma-name = \"Sainte Marie PMA\" and in-stabilisation? = True and deceased? = False]"

OUTPUT
1471
636
1853
788
11

BUTTON
1193
734
1317
767
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
1329
734
1453
767
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
1193
688
1291
721
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
1194
645
1344
673
6. View Results\n    
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

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

ambulance-2-shape
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

ambulance-shape
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
NetLogo 6.1.1
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
