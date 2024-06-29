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

/turf/simulated/floor/carpet/red
	icon_state = "red1"
/turf/simulated/floor/carpet/blue
	icon_state = "blue1"
/turf/simulated/floor/carpet/green
	icon_state = "green1"
/turf/simulated/floor/carpet/purple
	icon_state = "purple1"

//red carpet/////////////////////////////

/turf/simulated/floor/carpet/red/decal
	icon_state = "fred1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/simulated/floor/carpet/red/standard/edge
	icon_state = "red2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/red/standard/innercorner
	icon_state = "red3"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	ne_triple
		icon_state = "red4"
		dir = NORTHEAST
	se_triple
		icon_state = "red4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "red4"
		dir = NORTHWEST
	sw_triple
		icon_state = "red4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "red1"
		dir = NORTHEAST
	nw_se
		icon_state = "red1"
		dir = NORTHWEST
	omni
		icon_state = "red1"
		dir = WEST

/turf/simulated/floor/carpet/red/standard/narrow
	icon_state = "red6"

	north
		icon_state = "red4"
		dir = NORTH
	south
		icon_state = "red4"
		dir = SOUTH
	east
		icon_state = "red4"
		dir = EAST
	west
		icon_state = "red4"
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	solo
		icon_state = "red1"
		dir = EAST
	northsouth
		icon_state = "red1"
		dir = SOUTHEAST
	eastwest
		icon_state = "red1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/red/standard/junction
	icon_state = "red5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/simulated/floor/carpet/red/fancy/edge
	icon_state = "fred2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/red/fancy/innercorner
	icon_state = "fred3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fred4"
		dir = NORTHEAST
	se_triple
		icon_state = "fred4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fred4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fred4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fred1"
		dir = NORTHEAST
	nw_se
		icon_state = "fred1"
		dir = NORTHWEST
	omni
		icon_state = "fred1"
		dir = WEST

/turf/simulated/floor/carpet/red/fancy/narrow
	icon_state = "fred6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fred4"
		dir = NORTH
	south
		icon_state = "fred4"
		dir = SOUTH
	east
		icon_state = "fred4"
		dir = EAST
	west
		icon_state = "fred4"
		dir = WEST
	northsouth
		icon_state = "fred1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fred1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/red/fancy/junction
	icon_state = "fred5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//blue carpet/////////////////////////////

/turf/simulated/floor/carpet/blue/decal
	icon_state = "fblue1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/simulated/floor/carpet/blue/standard/edge
	icon_state = "blue2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/blue/standard/innercorner
	icon_state = "blue3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "blue4"
		dir = NORTHEAST
	se_triple
		icon_state = "blue4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "blue4"
		dir = NORTHWEST
	sw_triple
		icon_state = "blue4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "blue1"
		dir = NORTHEAST
	nw_se
		icon_state = "blue1"
		dir = NORTHWEST
	omni
		icon_state = "blue1"
		dir = WEST

/turf/simulated/floor/carpet/blue/standard/narrow
	icon_state = "blue6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "blue4"
		dir = NORTH
	south
		icon_state = "blue4"
		dir = SOUTH
	east
		icon_state = "blue4"
		dir = EAST
	west
		icon_state = "blue4"
		dir = WEST
	solo
		icon_state = "blue1"
		dir = EAST
	northsouth
		icon_state = "blue1"
		dir = SOUTHEAST
	eastwest
		icon_state = "blue1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/blue/standard/junction
	icon_state = "blue5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/simulated/floor/carpet/blue/fancy/edge
	icon_state = "fblue2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/blue/fancy/innercorner
	icon_state = "fblue3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fblue4"
		dir = NORTHEAST
	se_triple
		icon_state = "fblue4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fblue4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fblue4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fblue1"
		dir = NORTHEAST
	nw_se
		icon_state = "fblue1"
		dir = NORTHWEST
	omni
		icon_state = "fblue1"
		dir = WEST

/turf/simulated/floor/carpet/blue/fancy/narrow
	icon_state = "fblue6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fblue4"
		dir = NORTH
	south
		icon_state = "fblue4"
		dir = SOUTH
	east
		icon_state = "fblue4"
		dir = EAST
	west
		icon_state = "fblue4"
		dir = WEST
	northsouth
		icon_state = "fblue1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fblue1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/blue/fancy/narrow
	icon_state = "fblue6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fblue4"
		dir = NORTH
	south
		icon_state = "fblue4"
		dir = SOUTH
	east
		icon_state = "fblue4"
		dir = EAST
	west
		icon_state = "fblue4"
		dir = WEST
	northsouth
		icon_state = "fblue1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fblue1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/blue/fancy/junction
	icon_state = "fblue5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//purple carpet/////////////////////////////

/turf/simulated/floor/carpet/purple/decal
	icon_state = "fpurple1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/simulated/floor/carpet/purple/standard/edge
	icon_state = "purple2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/purple/standard/innercorner
	icon_state = "purple3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "purple4"
		dir = NORTHEAST
	se_triple
		icon_state = "purple4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "purple4"
		dir = NORTHWEST
	sw_triple
		icon_state = "purple4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "purple1"
		dir = NORTHEAST
	nw_se
		icon_state = "purple1"
		dir = NORTHWEST
	omni
		icon_state = "purple1"
		dir = WEST

/turf/simulated/floor/carpet/purple/standard/narrow
	icon_state = "purple6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "purple4"
		dir = NORTH
	south
		icon_state = "purple4"
		dir = SOUTH
	east
		icon_state = "purple4"
		dir = EAST
	west
		icon_state = "purple4"
		dir = WEST
	solo
		icon_state = "purple1"
		dir = EAST
	northsouth
		icon_state = "purple1"
		dir = SOUTHEAST
	eastwest
		icon_state = "purple1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/purple/standard/junction
	icon_state = "purple5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/simulated/floor/carpet/purple/fancy/edge
	icon_state = "fpurple2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/purple/fancy/innercorner
	icon_state = "fpurple3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fpurple4"
		dir = NORTHEAST
	se_triple
		icon_state = "fpurple4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fpurple4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fpurple4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fpurple1"
		dir = NORTHEAST
	nw_se
		icon_state = "fpurple1"
		dir = NORTHWEST
	omni
		icon_state = "fpurple1"
		dir = WEST

/turf/simulated/floor/carpet/purple/fancy/narrow
	icon_state = "fpurple6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fpurple4"
		dir = NORTH
	south
		icon_state = "fpurple4"
		dir = SOUTH
	east
		icon_state = "fpurple4"
		dir = EAST
	west
		icon_state = "fpurple4"
		dir = WEST
	northsouth
		icon_state = "fpurple1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fpurple1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/purple/fancy/junction
	icon_state = "fpurple5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//green carpet/////////////////////////////

/turf/simulated/floor/carpet/green/decal
	icon_state = "fgreen1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/simulated/floor/carpet/green/standard/edge
	icon_state = "green2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/green/standard/innercorner
	icon_state = "green3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "green4"
		dir = NORTHEAST
	se_triple
		icon_state = "green4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "green4"
		dir = NORTHWEST
	sw_triple
		icon_state = "green4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "green1"
		dir = NORTHEAST
	nw_se
		icon_state = "green1"
		dir = NORTHWEST
	omni
		icon_state = "green1"
		dir = WEST

/turf/simulated/floor/carpet/green/standard/narrow
	icon_state = "green6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "green4"
		dir = NORTH
	south
		icon_state = "green4"
		dir = SOUTH
	east
		icon_state = "green4"
		dir = EAST
	west
		icon_state = "green4"
		dir = WEST
	solo
		icon_state = "green1"
		dir = EAST
	northsouth
		icon_state = "green1"
		dir = SOUTHEAST
	eastwest
		icon_state = "green1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/green/standard/junction
	icon_state = "green5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/simulated/floor/carpet/green/fancy/edge
	icon_state = "fgreen2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/simulated/floor/carpet/green/fancy/innercorner
	icon_state = "fgreen3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fgreen4"
		dir = NORTHEAST
	se_triple
		icon_state = "fgreen4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fgreen4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fgreen4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fgreen1"
		dir = NORTHEAST
	nw_se
		icon_state = "fgreen1"
		dir = NORTHWEST
	omni
		icon_state = "fgreen1"
		dir = WEST

/turf/simulated/floor/carpet/green/fancy/narrow
	icon_state = "fgreen6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fgreen4"
		dir = NORTH
	south
		icon_state = "fgreen4"
		dir = SOUTH
	east
		icon_state = "fgreen4"
		dir = EAST
	west
		icon_state = "fgreen4"
		dir = WEST
	northsouth
		icon_state = "fgreen1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fgreen1"
		dir = SOUTHWEST

/turf/simulated/floor/carpet/green/fancy/junction
	icon_state = "fgreen5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//UNSIMULATED GREEN CARPET//
/turf/unsimulated/floor/carpet/green
	icon_state = "green1"

/turf/unsimulated/floor/carpet/green/decal
	icon_state = "fgreen1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/unsimulated/floor/carpet/green/standard/edge
	icon_state = "green2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/green/standard/innercorner
	icon_state = "green3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "green4"
		dir = NORTHEAST
	se_triple
		icon_state = "green4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "green4"
		dir = NORTHWEST
	sw_triple
		icon_state = "green4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "green1"
		dir = NORTHEAST
	nw_se
		icon_state = "green1"
		dir = NORTHWEST
	omni
		icon_state = "green1"
		dir = WEST

/turf/unsimulated/floor/carpet/green/standard/narrow
	icon_state = "green6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "green4"
		dir = NORTH
	south
		icon_state = "green4"
		dir = SOUTH
	east
		icon_state = "green4"
		dir = EAST
	west
		icon_state = "green4"
		dir = WEST
	solo
		icon_state = "green1"
		dir = EAST
	northsouth
		icon_state = "green1"
		dir = SOUTHEAST
	eastwest
		icon_state = "green1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/green/standard/junction
	icon_state = "green5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/unsimulated/floor/carpet/green/fancy/edge
	icon_state = "fgreen2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/green/fancy/innercorner
	icon_state = "fgreen3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fgreen4"
		dir = NORTHEAST
	se_triple
		icon_state = "fgreen4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fgreen4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fgreen4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fgreen1"
		dir = NORTHEAST
	nw_se
		icon_state = "fgreen1"
		dir = NORTHWEST
	omni
		icon_state = "fgreen1"
		dir = WEST

/turf/unsimulated/floor/carpet/green/fancy/narrow
	icon_state = "fgreen6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fgreen4"
		dir = NORTH
	south
		icon_state = "fgreen4"
		dir = SOUTH
	east
		icon_state = "fgreen4"
		dir = EAST
	west
		icon_state = "fgreen4"
		dir = WEST
	northsouth
		icon_state = "fgreen1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fgreen1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/green/fancy/junction
	icon_state = "fgreen5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//UNSIMULATED RED CARPET//

/turf/unsimulated/floor/carpet/red
	icon_state = "red1"


/turf/unsimulated/floor/carpet/red/decal
	icon_state = "fred1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/unsimulated/floor/carpet/red/standard/edge
	icon_state = "red2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/red/standard/innercorner
	icon_state = "red3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "red4"
		dir = NORTHEAST
	se_triple
		icon_state = "red4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "red4"
		dir = NORTHWEST
	sw_triple
		icon_state = "red4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "red1"
		dir = NORTHEAST
	nw_se
		icon_state = "red1"
		dir = NORTHWEST
	omni
		icon_state = "red1"
		dir = WEST

/turf/unsimulated/floor/carpet/red/standard/narrow
	icon_state = "red6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "red4"
		dir = NORTH
	south
		icon_state = "red4"
		dir = SOUTH
	east
		icon_state = "red4"
		dir = EAST
	west
		icon_state = "red4"
		dir = WEST
	solo
		icon_state = "red1"
		dir = EAST
	northsouth
		icon_state = "red1"
		dir = SOUTHEAST
	eastwest
		icon_state = "red1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/red/standard/junction
	icon_state = "red5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/unsimulated/floor/carpet/red/fancy/edge
	icon_state = "fred2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/red/fancy/innercorner
	icon_state = "fred3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fred4"
		dir = NORTHEAST
	se_triple
		icon_state = "fred4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fred4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fred4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fred1"
		dir = NORTHEAST
	nw_se
		icon_state = "fred1"
		dir = NORTHWEST
	omni
		icon_state = "fred1"
		dir = WEST

/turf/unsimulated/floor/carpet/red/fancy/narrow
	icon_state = "fred6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fred4"
		dir = NORTH
	south
		icon_state = "fred4"
		dir = SOUTH
	east
		icon_state = "fred4"
		dir = EAST
	west
		icon_state = "fred4"
		dir = WEST
	northsouth
		icon_state = "fred1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fred1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/red/fancy/junction
	icon_state = "fred5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//Wizard Carpet Variant

/turf/unsimulated/floor/carpet/wizard
	icon_state = "wizard1"

/turf/unsimulated/floor/carpet/wizard/standard/edge
	icon_state = "wizard2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/wizard/standard/innercorner
	icon_state = "wizard3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "wizard4"
		dir = NORTHEAST
	se_triple
		icon_state = "wizard4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "wizard4"
		dir = NORTHWEST
	sw_triple
		icon_state = "wizard4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "wizard1"
		dir = NORTHEAST
	nw_se
		icon_state = "wizard1"
		dir = NORTHWEST
	omni
		icon_state = "wizard1"
		dir = WEST

/turf/unsimulated/floor/carpet/wizard/standard/narrow
	icon_state = "wizard6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "wizard4"
		dir = NORTH
	south
		icon_state = "wizard4"
		dir = SOUTH
	east
		icon_state = "wizard4"
		dir = EAST
	west
		icon_state = "wizard4"
		dir = WEST
	solo
		icon_state = "wizard1"
		dir = EAST
	northsouth
		icon_state = "wizard1"
		dir = SOUTHEAST
	eastwest
		icon_state = "wizard1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/wizard/standard/junction
	icon_state = "wizard5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST
