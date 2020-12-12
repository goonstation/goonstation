/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors_unsimulated.dm & floors.dm
 */

/turf/simulated/floor/airless
	oxygen = 0.001
	nitrogen = 0.001
	temperature = TCMB

//////////////////////////////////////////////////////////// SPECIAL AIRLESS-ONLY TURFS

/turf/simulated/floor/airless/solar
	icon_state = "solarbase"
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED

/turf/unsimulated/floor/airless/solar
	icon_state = "solarbase"
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED

// cogwerks - catwalk plating

/turf/simulated/floor/airless/plating/catwalk
	name = "catwalk support"
	icon_state = "catwalk"
	allows_vehicles = 1
	step_material = "step_lattice"
	step_priority = STEP_PRIORITY_MED

////////////////////////////////////////////////////////////

/turf/simulated/floor/airless/scorched
	icon_state = "floorscorched1"

/turf/simulated/floor/airless/scorched2
	icon_state = "floorscorched2"

/turf/simulated/floor/airless/damaged1
	icon_state = "damaged1"

/turf/simulated/floor/airless/damaged2
	icon_state = "damaged2"

/turf/simulated/floor/airless/damaged3
	icon_state = "damaged3"

/turf/simulated/floor/airless/damaged4
	icon_state = "damaged4"

/turf/simulated/floor/airless/damaged5
	icon_state = "damaged5"

/////////////////////////////////////////

/turf/simulated/floor/airless/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	jen
		icon_state = "plating_jen"

/turf/simulated/floor/airless/plating/scorched
	icon_state = "panelscorched"

/turf/simulated/floor/airless/plating/damaged1
	icon_state = "platingdmg1"

/turf/simulated/floor/airless/plating/damaged2
	icon_state = "platingdmg2"

/turf/simulated/floor/airless/plating/damaged3
	icon_state = "platingdmg3"

/////////////////////////////////////////

/turf/simulated/floor/airless/grime
	icon_state = "floorgrime"

/////////////////////////////////////////

/turf/simulated/floor/airless/neutral
	icon_state = "fullneutral"

/turf/simulated/floor/airless/neutral/side
	icon_state = "neutral"

/turf/simulated/floor/airless/neutral/corner
	icon_state = "neutralcorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/white
	icon_state = "white"

/turf/simulated/floor/airless/white/side
	icon_state = "whitehall"

/turf/simulated/floor/airless/white/corner
	icon_state = "whitecorner"

/turf/simulated/floor/airless/white/checker
	icon_state = "whitecheck"

/turf/simulated/floor/airless/white/checker2
	icon_state = "whitecheck2"

/turf/simulated/floor/airless/white/grime
	icon_state = "floorgrime-w"

/////////////////////////////////////////

/turf/simulated/floor/airless/black //Okay so 'dark' is darker than 'black', So 'dark' will be named black and 'black' named grey.
	icon_state = "dark"

/turf/simulated/floor/airless/black/side
	icon_state = "greyblack"

/turf/simulated/floor/airless/black/corner
	icon_state = "greyblackcorner"

/turf/simulated/floor/airless/black/grime
	icon_state = "floorgrime-b"


/turf/simulated/floor/airless/blackwhite
	icon_state = "darkwhite"

/turf/simulated/floor/airless/blackwhite/corner
	icon_state = "darkwhitecorner"

/turf/simulated/floor/airless/blackwhite/side
	icon_state = "whiteblack"

/turf/simulated/floor/airless/blackwhite/whitegrime
	icon_state = "floorgrime_bw1"

/turf/simulated/floor/airless/blackwhite/whitegrime/other
	icon_state = "floorgrime_bw2"

/////////////////////////////////////////

/turf/simulated/floor/airless/grey
	icon_state = "fullblack"

/turf/simulated/floor/airless/grey/side
	icon_state = "black"

/turf/simulated/floor/airless/grey/corner
	icon_state = "blackcorner"

/turf/simulated/floor/airless/grey/checker
	icon_state = "blackchecker"

/turf/simulated/floor/airless/grey/blackgrime
	icon_state = "floorgrime_gb1"

/turf/simulated/floor/airless/grey/blackgrime/other
	icon_state = "floorgrime_gb2"

/turf/simulated/floor/airless/grey/whitegrime
	icon_state = "floorgrime_gw1"

/turf/simulated/floor/airless/grey/whitegrime/other
	icon_state = "floorgrime_gw2"

/////////////////////////////////////////

/turf/simulated/floor/airless/red
	icon_state = "fullred"

/turf/simulated/floor/airless/red/side
	icon_state = "red"

/turf/simulated/floor/airless/red/corner
	icon_state = "redcorner"

/turf/simulated/floor/airless/red/checker
	icon_state = "redchecker"


/turf/simulated/floor/airless/redblack
	icon_state = "redblack"

/turf/simulated/floor/airless/redblack/corner
	icon_state = "redblackcorner"


/turf/simulated/floor/airless/redwhite
	icon_state = "redwhite"

/turf/simulated/floor/airless/redwhite/corner
	icon_state = "redwhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/blue
	icon_state = "fullblue"

/turf/simulated/floor/airless/blue/side
	icon_state = "blue"

/turf/simulated/floor/airless/blue/corner
	icon_state = "bluecorner"

/turf/simulated/floor/airless/blue/checker
	icon_state = "bluechecker"


/turf/simulated/floor/airless/blueblack
	icon_state = "blueblack"

/turf/simulated/floor/airless/blueblack/corner
	icon_state = "blueblackcorner"


/turf/simulated/floor/airless/bluewhite
	icon_state = "bluewhite"

/turf/simulated/floor/airless/bluewhite/corner
	icon_state = "bluewhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/darkblue
	icon_state = "fulldblue"

/turf/simulated/floor/airless/darkblue/checker
	icon_state = "blue-dblue"

/turf/simulated/floor/airless/darkblue/checker/other
	icon_state = "blue-dblue2"

/////////////////////////////////////////

/turf/simulated/floor/airless/bluegreen
	icon_state = "blugreenfull"

/turf/simulated/floor/airless/bluegreen/side
	icon_state = "blugreen"

/turf/simulated/floor/airless/bluegreen/corner
	icon_state = "blugreencorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/green
	icon_state = "fullgreen"

/turf/simulated/floor/airless/green/side
	icon_state = "green"

/turf/simulated/floor/airless/green/corner
	icon_state = "greencorner"

/turf/simulated/floor/airless/green/checker
	icon_state = "greenchecker"


/turf/simulated/floor/airless/greenblack
	icon_state = "greenblack"

/turf/simulated/floor/airless/greenblack/corner
	icon_state = "greenblackcorner"


/turf/simulated/floor/airless/greenwhite
	icon_state = "greenwhite"

/turf/simulated/floor/airless/greenwhite/corner
	icon_state = "greenwhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/greenwhite/other
	icon_state = "toxshuttle"

/turf/simulated/floor/airless/greenwhite/other/corner
	icon_state = "toxshuttlecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/purple
	icon_state = "fullpurple"

/turf/simulated/floor/airless/purple/side
	icon_state = "purple"

/turf/simulated/floor/airless/purple/corner
	icon_state = "purplecorner"

/turf/simulated/floor/airless/purple/checker
	icon_state = "purplechecker"


/turf/simulated/floor/airless/purpleblack
	icon_state = "purpleblack"

/turf/simulated/floor/airless/purpleblack/corner
	icon_state = "purpleblackcorner"


/turf/simulated/floor/airless/purplewhite
	icon_state = "purplewhite"

/turf/simulated/floor/airless/purplewhite/corner
	icon_state = "purplewhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/yellow
	icon_state = "fullyellow"

/turf/simulated/floor/airless/yellow/side
	icon_state = "yellow"

/turf/simulated/floor/airless/yellow/corner
	icon_state = "yellowcorner"

/turf/simulated/floor/airless/yellow/checker
	icon_state = "yellowchecker"


/turf/simulated/floor/airless/yellowblack
	icon_state = "yellowblack"

/turf/simulated/floor/airless/yellowblack/corner
	icon_state = "yellowblackcorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/orange
	icon_state = "fullorange"

/turf/simulated/floor/airless/orange/side
	icon_state = "orange"

/turf/simulated/floor/airless/orange/corner
	icon_state = "orangecorner"


/turf/simulated/floor/airless/orangeblack
	icon_state = "fullcaution"

/turf/simulated/floor/airless/orangeblack/side
	icon_state = "caution"

/turf/simulated/floor/airless/orangeblack/side/white
	icon_state = "cautionwhite"

/turf/simulated/floor/airless/orangeblack/corner
	icon_state = "cautioncorner"

/turf/simulated/floor/airless/orangeblack/corner/white
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/circuit
	name = "transduction matrix"
	desc = "An elaborate, faintly glowing matrix of isolinear circuitry."
	icon_state = "circuit"
	RL_LumR = 0
	RL_LumG = 0   //Corresponds to color of the icon_state.
	RL_LumB = 0.3
	mat_appearances_to_ignore = list("pharosium")

	New()
		..()
		setMaterial(getMaterial("pharosium"))

/turf/simulated/floor/airless/circuit/green
	icon_state = "circuit-green"
	RL_LumR = 0
	RL_LumG = 0.3
	RL_LumB = 0

/turf/simulated/floor/airless/circuit/white
	icon_state = "circuit-white"
	RL_LumR = 0.2
	RL_LumG = 0.2
	RL_LumB = 0.2

/turf/simulated/floor/airless/circuit/purple
	icon_state = "circuit-purple"
	RL_LumR = 0.1
	RL_LumG = 0
	RL_LumB = 0.2

/turf/simulated/floor/airless/circuit/red
	icon_state = "circuit-red"
	RL_LumR = 0.3
	RL_LumG = 0
	RL_LumB = 0

/turf/simulated/floor/airless/circuit/vintage
	icon_state = "circuit-vint1"
	RL_LumR = 0.1
	RL_LumG = 0.1
	RL_LumB = 0.1

/turf/simulated/floor/airless/circuit/off
	icon_state = "circuitoff"
	RL_LumR = 0
	RL_LumG = 0
	RL_LumB = 0

/////////////////////////////////////////

/turf/simulated/floor/airless/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"
	mat_appearances_to_ignore = list("cloth")
	mat_changename = 0

	New()
		..()
		setMaterial(getMaterial("cloth"))

	break_tile()
		..()
		icon = 'icons/turf/floors.dmi'

	burn_tile()
		..()
		icon = 'icons/turf/floors.dmi'

/turf/simulated/floor/airless/carpet/grime
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/simulated/floor/airless/carpet/arcade
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet"

/turf/simulated/floor/airless/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/simulated/floor/airless/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/simulated/floor/airless/carpet/office
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet"

/turf/simulated/floor/airless/carpet/office/other
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet2"

/////////////////////////////////////////

/turf/simulated/floor/airless/shiny
	icon_state = "shiny"

/turf/simulated/floor/airless/shiny/white
	icon_state = "whiteshiny"

/////////////////////////////////////////

/turf/simulated/floor/airless/sanitary
	icon_state = "freezerfloor"

/turf/simulated/floor/airless/sanitary/white
	icon_state = "freezerfloor2"

/turf/simulated/floor/airless/sanitary/blue
	icon_state = "freezerfloor3"

////////////////////////////////////////

/turf/simulated/floor/airless/specialroom

/turf/simulated/floor/airless/specialroom/arcade
	icon_state = "arcade"

/turf/simulated/floor/airless/specialroom/bar
	icon_state = "bar"

/turf/simulated/floor/airless/specialroom/bar/edge
	icon_state = "bar-edge"

/turf/simulated/floor/airless/specialroom/gym
	name = "boxing mat"
	icon_state = "boxing"

/turf/simulated/floor/airless/specialroom/gym/alt
	name = "gym mat"
	icon_state = "gym_mat"

/turf/simulated/floor/airless/specialroom/cafeteria
	icon_state = "cafeteria"

/turf/simulated/floor/airless/specialroom/chapel
	icon_state = "chapel"

/turf/simulated/floor/airless/specialroom/freezer
	name = "freezer floor"
	icon_state = "freezerfloor"

/turf/simulated/floor/airless/specialroom/freezer/white
	icon_state = "freezerfloor2"

/turf/simulated/floor/airless/specialroom/freezer/blue
	icon_state = "freezerfloor3"

/turf/simulated/floor/airless/specialroom/medbay
	icon_state = "medbay"

/////////////////////////////////////////

/turf/simulated/floor/airless/arrival
	icon_state = "arrival"

/turf/simulated/floor/airless/arrival/corner
	icon_state = "arrivalcorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/escape
	icon_state = "escape"

/turf/simulated/floor/airless/escape/corner
	icon_state = "escapecorner"

/////////////////////////////////////////

/turf/simulated/floor/airless/delivery
	icon_state = "delivery"

/turf/simulated/floor/airless/delivery/white
	icon_state = "delivery_white"

/turf/simulated/floor/airless/delivery/caution
	icon_state = "deliverycaution"


/turf/simulated/floor/airless/bot
	icon_state = "bot"

/turf/simulated/floor/airless/bot/white
	icon_state = "bot_white"

/turf/simulated/floor/airless/bot/blue
	icon_state = "bot_blue"

/turf/simulated/floor/airless/bot/caution
	icon_state = "botcaution"

/////////////////////////////////////////

/turf/simulated/floor/airless/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	reinforced = TRUE
	allows_vehicles = 1

/turf/simulated/floor/airless/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/airless/engine/glow
	icon_state = "engine-glow"

/turf/simulated/floor/airless/engine/glow/blue
	icon_state = "engine-blue"


/turf/simulated/floor/airless/engine/caution/south
	icon_state = "engine_caution_south"

/turf/simulated/floor/airless/engine/caution/north
	icon_state = "engine_caution_north"

/turf/simulated/floor/airless/engine/caution/west
	icon_state = "engine_caution_west"

/turf/simulated/floor/airless/engine/caution/east
	icon_state = "engine_caution_east"

/turf/simulated/floor/airless/engine/caution/westeast
	icon_state = "engine_caution_we"

/turf/simulated/floor/airless/engine/caution/corner
	icon_state = "engine_caution_corners"

/turf/simulated/floor/airless/engine/caution/corner2
	icon_state = "engine_caution_corners2"

/turf/simulated/floor/airless/engine/caution/misc
	icon_state = "engine_caution_misc"

/////////////////////////////////////////

/turf/simulated/floor/airless/caution/south
	icon_state = "caution_south"

/turf/simulated/floor/airless/caution/north
	icon_state = "caution_north"

/turf/simulated/floor/airless/caution/northsouth
	icon_state = "caution_ns"

/turf/simulated/floor/airless/caution/west
	icon_state = "caution_west"

/turf/simulated/floor/airless/caution/east
	icon_state = "caution_east"

/turf/simulated/floor/airless/caution/westeast
	icon_state = "caution_we"

/turf/simulated/floor/airless/caution/corner/se
	icon_state = "corner_east"

/turf/simulated/floor/airless/caution/corner/sw
	icon_state = "corner_west"

/turf/simulated/floor/airless/caution/corner/ne
	icon_state = "corner_neast"

/turf/simulated/floor/airless/caution/corner/nw
	icon_state = "corner_nwest"

/turf/simulated/floor/airless/caution/corner/misc
	icon_state = "floor_hazard_corners"

/turf/simulated/floor/airless/caution/misc
	icon_state = "floor_hazard_misc"

/////////////////////////////////////////

/turf/simulated/floor/airless/wood
	icon_state = "wooden-2"
	mat_appearances_to_ignore = list("wood")
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		setMaterial(getMaterial("wood"))

/turf/simulated/floor/airless/wood/two
	icon_state = "wooden"

/turf/simulated/floor/airless/wood/three
	icon_state = "wooden-3"

/turf/simulated/floor/airless/wood/four
	icon_state = "wooden-4"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_LOW

/////////////////////////////////////////

/turf/simulated/floor/airless/sandytile
	name = "sand-covered floor"
	icon_state = "sandytile"

/////////////////////////////////////////
/turf/simulated/floor/airless/stairs
	name = "stairs"
	icon_state = "Stairs_alone"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	Entered(atom/A as mob|obj)
		if (istype(A, /obj/stool/chair/comfy/wheelchair))
			var/obj/stool/chair/comfy/wheelchair/W = A
			if (!W.lying && prob(40))
				if (W.buckled_guy && W.buckled_guy.m_intent == "walk")
					return ..()
				else
					W.fall_over(src)
		..()

/turf/simulated/floor/airless/stairs/wide
	icon_state = "Stairs_wide"

/turf/simulated/floor/airless/stairs/wide/other
	icon_state = "Stairs2_wide"

/turf/simulated/floor/airless/stairs/wide/green
	icon_state = "Stairs_wide_green"

/turf/simulated/floor/airless/stairs/wide/middle
	icon_state = "stairs_middle"


/turf/simulated/floor/airless/stairs/medical
	icon_state = "medstairs_alone"

/turf/simulated/floor/airless/stairs/medical/wide
	icon_state = "medstairs_wide"

/turf/simulated/floor/airless/stairs/medical/wide/other
	icon_state = "medstairs2_wide"

/turf/simulated/floor/airless/stairs/medical/wide/middle
	icon_state = "medstairs_middle"


/turf/simulated/floor/airless/stairs/quilty
	icon_state = "quiltystair"

/turf/simulated/floor/airless/stairs/quilty/wide
	icon_state = "quiltystair2"


/turf/simulated/floor/airless/stairs/wood
	icon_state = "wood_stairs"

/turf/simulated/floor/airless/stairs/wood/wide
	icon_state = "wood_stairs2"


/turf/simulated/floor/airless/stairs/wood2
	icon_state = "wood2_stairs"

/turf/simulated/floor/airless/stairs/wood2/wide
	icon_state = "wood2_stairs2"


/turf/simulated/floor/airless/stairs/wood3
	icon_state = "wood3_stairs"

/turf/simulated/floor/airless/stairs/wood3/wide
	icon_state = "wood3_stairs2"


/turf/simulated/floor/airless/stairs/dark
	icon_state = "dark_stairs"

/turf/simulated/floor/airless/stairs/dark/wide
	icon_state = "dark_stairs2"

/////////////////////////////////////////

/turf/unsimulated/floor/vr
	icon_state = "vrfloor"

/turf/unsimulated/floor/vr/plating
	icon_state = "vrplating"

/turf/unsimulated/floor/vr/space
	icon_state = "vrspace"

/turf/unsimulated/floor/vr/white
	icon_state = "vrwhitehall"

/turf/simulated/floor/airless/vr/flashy
	name = "Vspace"
	icon_state = "flashyblue"

/////////////////////////////////////////

/turf/simulated/floor/airless/snow
	name = "snow"
	icon_state = "snow1"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		if (prob(50))
			icon_state = "snow2"
		else if (prob(25))
			icon_state = "snow3"
		else if (prob(5))
			icon_state = "snow4"
		src.set_dir(pick(cardinal))

/turf/simulated/floor/airless/snow/green
	name = "snow-covered floor"
	icon_state = "snowgreen"

/turf/simulated/floor/airless/snow/green/corner
	name = "snow-covered floor"
	icon_state = "snowgreencorner"

/////////////////////////////////////////

/turf/unsimulated/floor/airless/sand
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"

	New()
		..()
		src.set_dir(pick(cardinal))

/////////////////////////////////////////

/turf/simulated/floor/airless/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0

	New()
		..()
		setMaterial(getMaterial("synthrubber"))

/turf/simulated/floor/airless/grass/leafy
	icon_state = "grass_leafy"

/turf/simulated/floor/airless/grass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/simulated/floor/airless/grass/random/alt
	icon_state = "grass_eh"

/////////////////////////////////////////
