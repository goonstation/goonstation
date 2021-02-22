/*
 * Hey! You!
 * You don't have to mirror your changes!
 * This is a special file just for carpets!
 */

//Pathed Floors 2: Carpet Boogaloo
//Submitted by Kubius

//pathing for all carpet states and colors, organized by intuitive grouping

//I have opted for a different path for each object due to the fact that carpet icons
//are split across multiple icon states in a way that makes them irritating to expand

//hi im putting the root /carpet stuff here ~ f191
/turf/simulated/floor/pattern/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"
	mat_appearances_to_ignore = list("cloth")
	mat_changename = 0
	step_material = "step_carpet"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		setMaterial(getMaterial("cloth"))

	break_tile()
		..()
		icon = 'icons/turf/floors.dmi'

	burn_tile()
		..()
		icon = 'icons/turf/floors.dmi'

/turf/simulated/floor/pattern/carpet/grime
	name = "cheap carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/simulated/floor/pattern/carpet/arcade
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet"

/turf/simulated/floor/pattern/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/simulated/floor/pattern/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/simulated/floor/pattern/carpet/office
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet"

/turf/simulated/floor/pattern/carpet/office/other
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet2"
//
/turf/simulated/floor/pattern/carpet/red
	icon_state = "red1"
/turf/simulated/floor/pattern/carpet/blue
	icon_state = "blue1"
/turf/simulated/floor/pattern/carpet/green
	icon_state = "green1"
/turf/simulated/floor/pattern/carpet/purple
	icon_state = "purple1"

//red carpet/////////////////////////////

/turf/simulated/floor/pattern/carpet/red/decal
	icon_state = "fred1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/simulated/floor/pattern/carpet/red/standard/edge
	icon_state = "red2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/red/standard/innercorner
	icon_state = "red3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "red4"
		dir = 5
	se_triple
		icon_state = "red4"
		dir = 6
	nw_triple
		icon_state = "red4"
		dir = 9
	sw_triple
		icon_state = "red4"
		dir = 10
	ne_sw
		icon_state = "red1"
		dir = 5
	nw_se
		icon_state = "red1"
		dir = 9
	omni
		icon_state = "red1"
		dir = 8

/turf/simulated/floor/pattern/carpet/red/standard/narrow
	icon_state = "red6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "red4"
		dir = 1
	south
		icon_state = "red4"
		dir = 2
	east
		icon_state = "red4"
		dir = 4
	west
		icon_state = "red4"
		dir = 8
	solo
		icon_state = "red1"
		dir = 4
	northsouth
		icon_state = "red1"
		dir = 6
	eastwest
		icon_state = "red1"
		dir = 10

/turf/simulated/floor/pattern/carpet/red/standard/junction
	icon_state = "red5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/simulated/floor/pattern/carpet/red/fancy/edge
	icon_state = "fred2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/red/fancy/innercorner
	icon_state = "fred3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fred4"
		dir = 5
	se_triple
		icon_state = "fred4"
		dir = 6
	nw_triple
		icon_state = "fred4"
		dir = 9
	sw_triple
		icon_state = "fred4"
		dir = 10
	ne_sw
		icon_state = "fred1"
		dir = 5
	nw_se
		icon_state = "fred1"
		dir = 9
	omni
		icon_state = "fred1"
		dir = 8

/turf/simulated/floor/pattern/carpet/red/fancy/narrow
	icon_state = "fred6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fred4"
		dir = 1
	south
		icon_state = "fred4"
		dir = 2
	east
		icon_state = "fred4"
		dir = 4
	west
		icon_state = "fred4"
		dir = 8
	northsouth
		icon_state = "fred1"
		dir = 6
	eastwest
		icon_state = "fred1"
		dir = 10

/turf/simulated/floor/pattern/carpet/red/fancy/junction
	icon_state = "fred5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//blue carpet/////////////////////////////

/turf/simulated/floor/pattern/carpet/blue/decal
	icon_state = "fblue1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/simulated/floor/pattern/carpet/blue/standard/edge
	icon_state = "blue2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/blue/standard/innercorner
	icon_state = "blue3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "blue4"
		dir = 5
	se_triple
		icon_state = "blue4"
		dir = 6
	nw_triple
		icon_state = "blue4"
		dir = 9
	sw_triple
		icon_state = "blue4"
		dir = 10
	ne_sw
		icon_state = "blue1"
		dir = 5
	nw_se
		icon_state = "blue1"
		dir = 9
	omni
		icon_state = "blue1"
		dir = 8

/turf/simulated/floor/pattern/carpet/blue/standard/narrow
	icon_state = "blue6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "blue4"
		dir = 1
	south
		icon_state = "blue4"
		dir = 2
	east
		icon_state = "blue4"
		dir = 4
	west
		icon_state = "blue4"
		dir = 8
	solo
		icon_state = "blue1"
		dir = 4
	northsouth
		icon_state = "blue1"
		dir = 6
	eastwest
		icon_state = "blue1"
		dir = 10

/turf/simulated/floor/pattern/carpet/blue/standard/junction
	icon_state = "blue5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/simulated/floor/pattern/carpet/blue/fancy/edge
	icon_state = "fblue2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/blue/fancy/innercorner
	icon_state = "fblue3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fblue4"
		dir = 5
	se_triple
		icon_state = "fblue4"
		dir = 6
	nw_triple
		icon_state = "fblue4"
		dir = 9
	sw_triple
		icon_state = "fblue4"
		dir = 10
	ne_sw
		icon_state = "fblue1"
		dir = 5
	nw_se
		icon_state = "fblue1"
		dir = 9
	omni
		icon_state = "fblue1"
		dir = 8

/turf/simulated/floor/pattern/carpet/blue/fancy/narrow
	icon_state = "fblue6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fblue4"
		dir = 1
	south
		icon_state = "fblue4"
		dir = 2
	east
		icon_state = "fblue4"
		dir = 4
	west
		icon_state = "fblue4"
		dir = 8
	northsouth
		icon_state = "fblue1"
		dir = 6
	eastwest
		icon_state = "fblue1"
		dir = 10

/turf/simulated/floor/pattern/carpet/blue/fancy/junction
	icon_state = "fblue5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//purple carpet/////////////////////////////

/turf/simulated/floor/pattern/carpet/purple/decal
	icon_state = "fpurple1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/simulated/floor/pattern/carpet/purple/standard/edge
	icon_state = "purple2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/purple/standard/innercorner
	icon_state = "purple3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "purple4"
		dir = 5
	se_triple
		icon_state = "purple4"
		dir = 6
	nw_triple
		icon_state = "purple4"
		dir = 9
	sw_triple
		icon_state = "purple4"
		dir = 10
	ne_sw
		icon_state = "purple1"
		dir = 5
	nw_se
		icon_state = "purple1"
		dir = 9
	omni
		icon_state = "purple1"
		dir = 8

/turf/simulated/floor/pattern/carpet/purple/standard/narrow
	icon_state = "purple6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "purple4"
		dir = 1
	south
		icon_state = "purple4"
		dir = 2
	east
		icon_state = "purple4"
		dir = 4
	west
		icon_state = "purple4"
		dir = 8
	solo
		icon_state = "purple1"
		dir = 4
	northsouth
		icon_state = "purple1"
		dir = 6
	eastwest
		icon_state = "purple1"
		dir = 10

/turf/simulated/floor/pattern/carpet/purple/standard/junction
	icon_state = "purple5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/simulated/floor/pattern/carpet/purple/fancy/edge
	icon_state = "fpurple2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/purple/fancy/innercorner
	icon_state = "fpurple3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fpurple4"
		dir = 5
	se_triple
		icon_state = "fpurple4"
		dir = 6
	nw_triple
		icon_state = "fpurple4"
		dir = 9
	sw_triple
		icon_state = "fpurple4"
		dir = 10
	ne_sw
		icon_state = "fpurple1"
		dir = 5
	nw_se
		icon_state = "fpurple1"
		dir = 9
	omni
		icon_state = "fpurple1"
		dir = 8

/turf/simulated/floor/pattern/carpet/purple/fancy/narrow
	icon_state = "fpurple6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fpurple4"
		dir = 1
	south
		icon_state = "fpurple4"
		dir = 2
	east
		icon_state = "fpurple4"
		dir = 4
	west
		icon_state = "fpurple4"
		dir = 8
	northsouth
		icon_state = "fpurple1"
		dir = 6
	eastwest
		icon_state = "fpurple1"
		dir = 10

/turf/simulated/floor/pattern/carpet/purple/fancy/junction
	icon_state = "fpurple5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//green carpet/////////////////////////////

/turf/simulated/floor/pattern/carpet/green/decal
	icon_state = "fgreen1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/simulated/floor/pattern/carpet/green/standard/edge
	icon_state = "green2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/green/standard/innercorner
	icon_state = "green3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "green4"
		dir = 5
	se_triple
		icon_state = "green4"
		dir = 6
	nw_triple
		icon_state = "green4"
		dir = 9
	sw_triple
		icon_state = "green4"
		dir = 10
	ne_sw
		icon_state = "green1"
		dir = 5
	nw_se
		icon_state = "green1"
		dir = 9
	omni
		icon_state = "green1"
		dir = 8

/turf/simulated/floor/pattern/carpet/green/standard/narrow
	icon_state = "green6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "green4"
		dir = 1
	south
		icon_state = "green4"
		dir = 2
	east
		icon_state = "green4"
		dir = 4
	west
		icon_state = "green4"
		dir = 8
	solo
		icon_state = "green1"
		dir = 4
	northsouth
		icon_state = "green1"
		dir = 6
	eastwest
		icon_state = "green1"
		dir = 10

/turf/simulated/floor/pattern/carpet/green/standard/junction
	icon_state = "green5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/simulated/floor/pattern/carpet/green/fancy/edge
	icon_state = "fgreen2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/simulated/floor/pattern/carpet/green/fancy/innercorner
	icon_state = "fgreen3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fgreen4"
		dir = 5
	se_triple
		icon_state = "fgreen4"
		dir = 6
	nw_triple
		icon_state = "fgreen4"
		dir = 9
	sw_triple
		icon_state = "fgreen4"
		dir = 10
	ne_sw
		icon_state = "fgreen1"
		dir = 5
	nw_se
		icon_state = "fgreen1"
		dir = 9
	omni
		icon_state = "fgreen1"
		dir = 8

/turf/simulated/floor/pattern/carpet/green/fancy/narrow
	icon_state = "fgreen6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fgreen4"
		dir = 1
	south
		icon_state = "fgreen4"
		dir = 2
	east
		icon_state = "fgreen4"
		dir = 4
	west
		icon_state = "fgreen4"
		dir = 8
	northsouth
		icon_state = "fgreen1"
		dir = 6
	eastwest
		icon_state = "fgreen1"
		dir = 10

/turf/simulated/floor/pattern/carpet/green/fancy/junction
	icon_state = "fgreen5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//UNSIMULATED GREEN CARPET//
/turf/unsimulated/floor/pattern/carpet/green
	icon_state = "green1"

/turf/unsimulated/floor/pattern/carpet/green/decal
	icon_state = "fgreen1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/unsimulated/floor/pattern/carpet/green/standard/edge
	icon_state = "green2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/unsimulated/floor/pattern/carpet/green/standard/innercorner
	icon_state = "green3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "green4"
		dir = 5
	se_triple
		icon_state = "green4"
		dir = 6
	nw_triple
		icon_state = "green4"
		dir = 9
	sw_triple
		icon_state = "green4"
		dir = 10
	ne_sw
		icon_state = "green1"
		dir = 5
	nw_se
		icon_state = "green1"
		dir = 9
	omni
		icon_state = "green1"
		dir = 8

/turf/unsimulated/floor/pattern/carpet/green/standard/narrow
	icon_state = "green6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "green4"
		dir = 1
	south
		icon_state = "green4"
		dir = 2
	east
		icon_state = "green4"
		dir = 4
	west
		icon_state = "green4"
		dir = 8
	solo
		icon_state = "green1"
		dir = 4
	northsouth
		icon_state = "green1"
		dir = 6
	eastwest
		icon_state = "green1"
		dir = 10

/turf/unsimulated/floor/pattern/carpet/green/standard/junction
	icon_state = "green5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/unsimulated/floor/pattern/carpet/green/fancy/edge
	icon_state = "fgreen2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/unsimulated/floor/pattern/carpet/green/fancy/innercorner
	icon_state = "fgreen3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fgreen4"
		dir = 5
	se_triple
		icon_state = "fgreen4"
		dir = 6
	nw_triple
		icon_state = "fgreen4"
		dir = 9
	sw_triple
		icon_state = "fgreen4"
		dir = 10
	ne_sw
		icon_state = "fgreen1"
		dir = 5
	nw_se
		icon_state = "fgreen1"
		dir = 9
	omni
		icon_state = "fgreen1"
		dir = 8

/turf/unsimulated/floor/pattern/carpet/green/fancy/narrow
	icon_state = "fgreen6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fgreen4"
		dir = 1
	south
		icon_state = "fgreen4"
		dir = 2
	east
		icon_state = "fgreen4"
		dir = 4
	west
		icon_state = "fgreen4"
		dir = 8
	northsouth
		icon_state = "fgreen1"
		dir = 6
	eastwest
		icon_state = "fgreen1"
		dir = 10

/turf/unsimulated/floor/pattern/carpet/green/fancy/junction
	icon_state = "fgreen5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//UNSIMULATED RED CARPET//

/turf/unsimulated/floor/pattern/carpet/red
	icon_state = "red1"


/turf/unsimulated/floor/pattern/carpet/red/decal
	icon_state = "fred1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/unsimulated/floor/pattern/carpet/red/standard/edge
	icon_state = "red2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/unsimulated/floor/pattern/carpet/red/standard/innercorner
	icon_state = "red3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "red4"
		dir = 5
	se_triple
		icon_state = "red4"
		dir = 6
	nw_triple
		icon_state = "red4"
		dir = 9
	sw_triple
		icon_state = "red4"
		dir = 10
	ne_sw
		icon_state = "red1"
		dir = 5
	nw_se
		icon_state = "red1"
		dir = 9
	omni
		icon_state = "red1"
		dir = 8

/turf/unsimulated/floor/pattern/carpet/red/standard/narrow
	icon_state = "red6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "red4"
		dir = 1
	south
		icon_state = "red4"
		dir = 2
	east
		icon_state = "red4"
		dir = 4
	west
		icon_state = "red4"
		dir = 8
	solo
		icon_state = "red1"
		dir = 4
	northsouth
		icon_state = "red1"
		dir = 6
	eastwest
		icon_state = "red1"
		dir = 10

/turf/unsimulated/floor/pattern/carpet/red/standard/junction
	icon_state = "red5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/unsimulated/floor/pattern/carpet/red/fancy/edge
	icon_state = "fred2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/unsimulated/floor/pattern/carpet/red/fancy/innercorner
	icon_state = "fred3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fred4"
		dir = 5
	se_triple
		icon_state = "fred4"
		dir = 6
	nw_triple
		icon_state = "fred4"
		dir = 9
	sw_triple
		icon_state = "fred4"
		dir = 10
	ne_sw
		icon_state = "fred1"
		dir = 5
	nw_se
		icon_state = "fred1"
		dir = 9
	omni
		icon_state = "fred1"
		dir = 8

/turf/unsimulated/floor/pattern/carpet/red/fancy/narrow
	icon_state = "fred6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fred4"
		dir = 1
	south
		icon_state = "fred4"
		dir = 2
	east
		icon_state = "fred4"
		dir = 4
	west
		icon_state = "fred4"
		dir = 8
	northsouth
		icon_state = "fred1"
		dir = 6
	eastwest
		icon_state = "fred1"
		dir = 10

/turf/unsimulated/floor/pattern/carpet/red/fancy/junction
	icon_state = "fred5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10
