/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors_unsimulated.dm & floors_airless.dm
 */

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000

	turf_flags = IS_TYPE_SIMULATED | MOB_SLIP | MOB_STEP

	var/broken = 0
	var/burnt = 0
	var/plate_mat = null
	var/reinforced = FALSE

	New()
		..()
		plate_mat = getMaterial("steel")
		setMaterial(getMaterial("steel"))
		var/obj/plan_marker/floor/P = locate() in src
		if (P)
			src.icon = P.icon
			src.icon_state = P.icon_state
			src.icon_old = P.icon_state
			allows_vehicles = P.allows_vehicles
			var/pdir = P.dir
			SPAWN_DBG(0.5 SECONDS)
				src.set_dir(pdir)
			qdel(P)


/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=FUCK I AM TIRED OF MAPING WITH NON-PATHED FLOORS-=-=-=-*/
/*-=-=-I GUESS I'LL DO THIS FOR EVERY FUCKING FLOOR EVER-=-=-=-*/
/*-=-=-=-=-=-=-=-=-=-=WITH LOVE BY ZEWAKA=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/////////////////////////////////////////

/turf/simulated/floor/plating
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/plating/random
	New()
		..()
		if (prob(20))
			src.icon_state = pick("panelscorched", "platingdmg1", "platingdmg2", "platingdmg3")
		if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt,src)
		if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt2,src)
		if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt3,src)
		if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt4,src)
		if (prob(2))
			make_cleanable(/obj/decal/cleanable/dirt/dirt5,src)
		else if (prob(2))
			var/obj/C = pick(/obj/decal/cleanable/paper, /obj/decal/cleanable/fungus, /obj/decal/cleanable/dirt, /obj/decal/cleanable/ash,\
			/obj/decal/cleanable/molten_item, /obj/decal/cleanable/machine_debris, /obj/decal/cleanable/oil, /obj/decal/cleanable/rust)
			make_cleanable( C ,src)
		else if ((locate(/obj) in src) && prob(3))
			var/obj/C = pick(/obj/item/cable_coil/cut/small, /obj/item/brick, /obj/item/cigbutt, /obj/item/scrap, /obj/item/raw_material/scrap_metal,\
			/obj/item/spacecash, /obj/item/tile/steel, /obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wrench, /obj/item/wirecutters, /obj/item/crowbar)
			new C (src)
		else if (prob(1) && prob(2)) // really rare. not "three space things spawn on destiny during first test with just prob(1)" rare.
			var/obj/C = pick(/obj/item/space_thing, /obj/item/sticker/gold_star, /obj/item/sticker/banana, /obj/item/sticker/heart,\
			/obj/item/reagent_containers/vending/bag/random, /obj/item/reagent_containers/vending/vial/random, /obj/item/clothing/mask/cigarette/random)
			new C (src)
		return

/turf/simulated/floor/plating/airless/random
	New()
		..()
		if (prob(20))
			src.icon_state = pick("panelscorched", "platingdmg1", "platingdmg2", "platingdmg3")


/////////////////////////////////////////

/turf/simulated/floor/scorched
	icon_state = "floorscorched1"

/turf/simulated/floor/scorched2
	icon_state = "floorscorched2"

/turf/simulated/floor/damaged1
	icon_state = "damaged1"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/damaged2
	icon_state = "damaged2"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/damaged3
	icon_state = "damaged3"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/damaged4
	icon_state = "damaged4"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/damaged5
	icon_state = "damaged5"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/////////////////////////////////////////

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0

/turf/simulated/floor/plating/jen
	icon_state = "plating_jen"

/turf/simulated/floor/plating/scorched
	icon_state = "panelscorched"

/turf/simulated/floor/plating/damaged1
	icon_state = "platingdmg1"

/turf/simulated/floor/plating/damaged2
	icon_state = "platingdmg2"

/turf/simulated/floor/plating/damaged3
	icon_state = "platingdmg3"

/////////////////////////////////////////

/turf/simulated/floor/grime
	icon_state = "floorgrime"

/////////////////////////////////////////

/turf/simulated/floor/neutral
	icon_state = "fullneutral"

/turf/simulated/floor/neutral/side
	icon_state = "neutral"

/turf/simulated/floor/neutral/corner
	icon_state = "neutralcorner"

/////////////////////////////////////////

/turf/simulated/floor/white
	icon_state = "white"

/turf/simulated/floor/white/side
	icon_state = "whitehall"

/turf/simulated/floor/white/corner
	icon_state = "whitecorner"

/turf/simulated/floor/white/checker
	icon_state = "whitecheck"

/turf/simulated/floor/white/checker2
	icon_state = "whitecheck2"

/turf/simulated/floor/white/grime
	icon_state = "floorgrime-w"

/////////////////////////////////////////

/turf/simulated/floor/black //Okay so 'dark' is darker than 'black', So 'dark' will be named black and 'black' named grey.
	icon_state = "dark"

/turf/simulated/floor/black/side
	icon_state = "greyblack"

/turf/simulated/floor/black/corner
	icon_state = "greyblackcorner"

/turf/simulated/floor/black/grime
	icon_state = "floorgrime-b"


/turf/simulated/floor/blackwhite
	icon_state = "darkwhite"

/turf/simulated/floor/blackwhite/corner
	icon_state = "darkwhitecorner"

/turf/simulated/floor/blackwhite/side
	icon_state = "whiteblack"

/turf/simulated/floor/blackwhite/whitegrime
	icon_state = "floorgrime_bw1"

/turf/simulated/floor/blackwhite/whitegrime/other
	icon_state = "floorgrime_bw2"

/////////////////////////////////////////

/turf/simulated/floor/grey
	icon_state = "fullblack"

/turf/simulated/floor/grey/side
	icon_state = "black"

/turf/simulated/floor/grey/corner
	icon_state = "blackcorner"

/turf/simulated/floor/grey/checker
	icon_state = "blackchecker"

/turf/simulated/floor/grey/blackgrime
	icon_state = "floorgrime_gb1"

/turf/simulated/floor/grey/blackgrime/other
	icon_state = "floorgrime_gb2"

/turf/simulated/floor/grey/whitegrime
	icon_state = "floorgrime_gw1"

/turf/simulated/floor/grey/whitegrime/other
	icon_state = "floorgrime_gw2"

/////////////////////////////////////////

/turf/simulated/floor/red
	icon_state = "fullred"

/turf/simulated/floor/red/side
	icon_state = "red"

/turf/simulated/floor/red/corner
	icon_state = "redcorner"

/turf/simulated/floor/red/checker
	icon_state = "redchecker"


/turf/simulated/floor/red/redblackchecker
	icon_state = "redblackchecker"


/turf/simulated/floor/redblack
	icon_state = "redblack"

/turf/simulated/floor/redblack/corner
	icon_state = "redblackcorner"


/turf/simulated/floor/redwhite
	icon_state = "redwhite"

/turf/simulated/floor/redwhite/corner
	icon_state = "redwhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/blue
	icon_state = "fullblue"

/turf/simulated/floor/blue/side
	icon_state = "blue"

/turf/simulated/floor/blue/corner
	icon_state = "bluecorner"

/turf/simulated/floor/blue/checker
	icon_state = "bluechecker"


/turf/simulated/floor/blueblack
	icon_state = "blueblack"

/turf/simulated/floor/blueblack/corner
	icon_state = "blueblackcorner"


/turf/simulated/floor/bluewhite
	icon_state = "bluewhite"

/turf/simulated/floor/bluewhite/corner
	icon_state = "bluewhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/darkblue
	icon_state = "fulldblue"

/turf/simulated/floor/darkblue/checker
	icon_state = "blue-dblue"

/turf/simulated/floor/darkblue/checker/other
	icon_state = "blue-dblue2"

/////////////////////////////////////////

/turf/simulated/floor/bluegreen
	icon_state = "blugreenfull"

/turf/simulated/floor/bluegreen/side
	icon_state = "blugreen"

/turf/simulated/floor/bluegreen/corner
	icon_state = "blugreencorner"

/////////////////////////////////////////

/turf/simulated/floor/green
	icon_state = "fullgreen"

/turf/simulated/floor/green/side
	icon_state = "green"

/turf/simulated/floor/green/corner
	icon_state = "greencorner"

/turf/simulated/floor/green/checker
	icon_state = "greenchecker"


/turf/simulated/floor/greenblack
	icon_state = "greenblack"

/turf/simulated/floor/greenblack/corner
	icon_state = "greenblackcorner"


/turf/simulated/floor/greenwhite
	icon_state = "greenwhite"

/turf/simulated/floor/greenwhite/corner
	icon_state = "greenwhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/greenwhite/other
	icon_state = "toxshuttle"

/turf/simulated/floor/greenwhite/other/corner
	icon_state = "toxshuttlecorner"

/////////////////////////////////////////

/turf/simulated/floor/purple
	icon_state = "fullpurple"

/turf/simulated/floor/purple/side
	icon_state = "purple"

/turf/simulated/floor/purple/corner
	icon_state = "purplecorner"

/turf/simulated/floor/purple/checker
	icon_state = "purplechecker"


/turf/simulated/floor/purpleblack
	icon_state = "purpleblack"

/turf/simulated/floor/purpleblack/corner
	icon_state = "purpleblackcorner"


/turf/simulated/floor/purplewhite
	icon_state = "purplewhite"

/turf/simulated/floor/purplewhite/corner
	icon_state = "purplewhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/darkpurple
	icon_state = "fulldpurple"

/turf/simulated/floor/darkpurple/side
	icon_state = "dpurple"

/////////////////////////////////////////

/turf/simulated/floor/yellow
	icon_state = "fullyellow"

/turf/simulated/floor/yellow/side
	icon_state = "yellow"

/turf/simulated/floor/yellow/corner
	icon_state = "yellowcorner"

/turf/simulated/floor/yellow/alt
	icon_state = "fullyellow_alt"

/turf/simulated/floor/yellow/checker
	icon_state = "yellowchecker"

/turf/simulated/floor/yellowblack
	icon_state = "yellowblack"

/turf/simulated/floor/yellowblack/corner
	icon_state = "yellowblackcorner"

/////////////////////////////////////////

/turf/simulated/floor/orange
	icon_state = "fullorange"

/turf/simulated/floor/orange/side
	icon_state = "orange"

/turf/simulated/floor/orange/corner
	icon_state = "orangecorner"


/turf/simulated/floor/orangeblack
	icon_state = "fullcaution"

/turf/simulated/floor/orangeblack/side
	icon_state = "caution"

/turf/simulated/floor/orangeblack/side/white
	icon_state = "cautionwhite"

/turf/simulated/floor/orangeblack/corner
	icon_state = "cautioncorner"

/turf/simulated/floor/orangeblack/corner/white
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/simulated/floor/circuit
	name = "transduction matrix"
	desc = "An elaborate, faintly glowing matrix of isolinear circuitry."
	icon_state = "circuit"
	RL_LumR = 0
	RL_LumG = 0   //Corresponds to color of the icon_state.
	RL_LumB = 0.3
	mat_appearances_to_ignore = list("pharosium")
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		setMaterial(getMaterial("pharosium"))

/turf/simulated/floor/circuit/green
	icon_state = "circuit-green"
	RL_LumR = 0
	RL_LumG = 0.3
	RL_LumB = 0

/turf/simulated/floor/circuit/white
	icon_state = "circuit-white"
	RL_LumR = 0.2
	RL_LumG = 0.2
	RL_LumB = 0.2

/turf/simulated/floor/circuit/purple
	icon_state = "circuit-purple"
	RL_LumR = 0.1
	RL_LumG = 0
	RL_LumB = 0.2

/turf/simulated/floor/circuit/red
	icon_state = "circuit-red"
	RL_LumR = 0.3
	RL_LumG = 0
	RL_LumB = 0

/turf/simulated/floor/circuit/vintage
	icon_state = "circuit-vint1"
	RL_LumR = 0.1
	RL_LumG = 0.1
	RL_LumB = 0.1

/turf/simulated/floor/circuit/off
	icon_state = "circuitoff"
	RL_LumR = 0
	RL_LumG = 0
	RL_LumB = 0

/////////////////////////////////////////

/turf/simulated/floor/carpet
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

/turf/simulated/floor/carpet/grime
	name = "cheap carpet"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/simulated/floor/carpet/arcade
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet"

/turf/simulated/floor/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/simulated/floor/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/simulated/floor/carpet/office
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet"

/turf/simulated/floor/carpet/office/other
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet2"

/////////////////////////////////////////

/turf/simulated/floor/shiny
	icon_state = "shiny"

/turf/simulated/floor/shiny/white
	icon_state = "whiteshiny"

/////////////////////////////////////////

/turf/simulated/floor/sanitary
	icon_state = "freezerfloor"

/turf/simulated/floor/sanitary/white
	icon_state = "freezerfloor2"

/turf/simulated/floor/sanitary/blue
	icon_state = "freezerfloor3"

////////////////////////////////////////

/turf/simulated/floor/specialroom

/turf/simulated/floor/specialroom/arcade
	icon_state = "arcade"

/turf/simulated/floor/specialroom/bar
	icon_state = "bar"

/turf/simulated/floor/specialroom/bar/edge
	icon_state = "bar-edge"

/turf/simulated/floor/specialroom/gym
	name = "boxing mat"
	icon_state = "boxing"

/turf/simulated/floor/specialroom/gym/alt
	name = "gym mat"
	icon_state = "gym_mat"

/turf/simulated/floor/specialroom/cafeteria
	icon_state = "cafeteria"

/turf/simulated/floor/specialroom/chapel
	icon_state = "chapel"

/turf/simulated/floor/specialroom/freezer
	name = "freezer floor"
	icon_state = "freezerfloor"
	temperature = T0C

/turf/simulated/floor/specialroom/freezer/white
	icon_state = "freezerfloor2"

/turf/simulated/floor/specialroom/freezer/blue
	icon_state = "freezerfloor3"

/turf/simulated/floor/specialroom/medbay
	icon_state = "medbay"

/////////////////////////////////////////

/turf/simulated/floor/arrival
	icon_state = "arrival"

/turf/simulated/floor/arrival/corner
	icon_state = "arrivalcorner"

/////////////////////////////////////////

/turf/simulated/floor/escape
	icon_state = "escape"

/turf/simulated/floor/escape/corner
	icon_state = "escapecorner"

/////////////////////////////////////////

/turf/simulated/floor/delivery
	icon_state = "delivery"

/turf/simulated/floor/delivery/white
	icon_state = "delivery_white"

/turf/simulated/floor/delivery/caution
	icon_state = "deliverycaution"


/turf/simulated/floor/bot
	icon_state = "bot"

/turf/simulated/floor/bot/white
	icon_state = "bot_white"

/turf/simulated/floor/bot/blue
	icon_state = "bot_blue"

/turf/simulated/floor/bot/darkpurple
	icon_state = "bot_dpurple"

/turf/simulated/floor/bot/caution
	icon_state = "botcaution"

/////////////////////////////////////////

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

	reinforced = TRUE
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	event_handler_flags = IMMUNE_SINGULARITY_INACTIVE

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/engine/glow
	icon_state = "engine-glow"

/turf/simulated/floor/engine/glow/blue
	icon_state = "engine-blue"


/turf/simulated/floor/engine/caution/south
	icon_state = "engine_caution_south"

/turf/simulated/floor/engine/caution/north
	icon_state = "engine_caution_north"

/turf/simulated/floor/engine/caution/northsouth
	icon_state = "engine_caution_ns"

/turf/simulated/floor/engine/caution/west
	icon_state = "engine_caution_west"

/turf/simulated/floor/engine/caution/east
	icon_state = "engine_caution_east"

/turf/simulated/floor/engine/caution/westeast
	icon_state = "engine_caution_we"

/turf/simulated/floor/engine/caution/corner
	icon_state = "engine_caution_corners"

/turf/simulated/floor/engine/caution/corner2
	icon_state = "engine_caution_corners2"

/turf/simulated/floor/engine/caution/misc
	icon_state = "engine_caution_misc"

/////////////////////////////////////////

/turf/simulated/floor/caution/south
	icon_state = "caution_south"

/turf/simulated/floor/caution/north
	icon_state = "caution_north"

/turf/simulated/floor/caution/northsouth
	icon_state = "caution_ns"

/turf/simulated/floor/caution/west
	icon_state = "caution_west"

/turf/simulated/floor/caution/east
	icon_state = "caution_east"

/turf/simulated/floor/caution/westeast
	icon_state = "caution_we"

/turf/simulated/floor/caution/corner/se
	icon_state = "corner_east"

/turf/simulated/floor/caution/corner/sw
	icon_state = "corner_west"

/turf/simulated/floor/caution/corner/ne
	icon_state = "corner_neast"

/turf/simulated/floor/caution/corner/nw
	icon_state = "corner_nwest"

/turf/simulated/floor/caution/corner/misc
	icon_state = "floor_hazard_corners"

/turf/simulated/floor/caution/misc
	icon_state = "floor_hazard_misc"

/////////////////////////////////////////

/turf/simulated/floor/wood
	icon_state = "wooden-2"
	mat_appearances_to_ignore = list("wood")
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		setMaterial(getMaterial("wood"))

/turf/simulated/floor/wood/two
	icon_state = "wooden"

/turf/simulated/floor/wood/three
	icon_state = "wooden-3"

/turf/simulated/floor/wood/four
	icon_state = "wooden-4"

/turf/simulated/floor/wood/five
	icon_state = "wooden-5"

/turf/simulated/floor/wood/six
	icon_state = "wooden-6"

/turf/simulated/floor/wood/seven
	icon_state = "wooden-7"

/turf/simulated/floor/wood/eight
	icon_state = "wooden-8"

/////////////////////////////////////////

/turf/simulated/floor/sandytile
	name = "sand-covered floor"
	icon_state = "sandytile"

/////////////////////////////////////////
// manta related
/turf/simulated/floor/longtile
	icon_state = "longtile"

/turf/simulated/floor/longtile/black
	icon_state = "longtile-dark"

/turf/simulated/floor/longtile/blue
	icon_state = "longtile-blue"

/turf/simulated/floor/longtile/red
	icon_state = "longtile-red"

/turf/simulated/floor/specialroom/clown
	icon_state = "clownfloor"

/turf/simulated/floor/special
	icon_state = "waithere"

/turf/simulated/floor/special/bridgeup
	icon_state = "bridge_up"

/turf/simulated/floor/special/escapedown
	icon_state = "escape_down"

/turf/simulated/floor/special/submarinesdown
	icon_state = "submarines_down"

/turf/simulated/floor/special/submarinesup
	icon_state = "submarines_up"

/turf/simulated/floor/special/researchdown
	icon_state = "research_down"

/turf/simulated/floor/special/risingtide
	icon_state = "risingtide"
/////////////////////////////////////////
/turf/simulated/floor/stairs
	name = "stairs"
	icon_state = "Stairs_alone"

	Entered(atom/A as mob|obj)
		if (istype(A, /obj/stool/chair/comfy/wheelchair))
			var/obj/stool/chair/comfy/wheelchair/W = A
			if (!W.lying && prob(40))
				if (W.buckled_guy && W.buckled_guy.m_intent == "walk")
					return ..()
				else
					W.fall_over(src)
		..()

/turf/simulated/floor/stairs/wide
	icon_state = "Stairs_wide"

/turf/simulated/floor/stairs/wide/other
	icon_state = "Stairs2_wide"

/turf/simulated/floor/stairs/wide/green
	icon_state = "Stairs_wide_green"

/turf/simulated/floor/stairs/wide/green/other
	icon_state = "Stairs_wide_green_other"

/turf/simulated/floor/stairs/wide/middle
	icon_state = "stairs_middle"


/turf/simulated/floor/stairs/medical
	icon_state = "medstairs_alone"

/turf/simulated/floor/stairs/medical/wide
	icon_state = "medstairs_wide"

/turf/simulated/floor/stairs/medical/wide/other
	icon_state = "medstairs2_wide"

/turf/simulated/floor/stairs/medical/wide/middle
	icon_state = "medstairs_middle"


/turf/simulated/floor/stairs/quilty
	icon_state = "quiltystair"

/turf/simulated/floor/stairs/quilty/wide
	icon_state = "quiltystair2"


/turf/simulated/floor/stairs/wood
	icon_state = "wood_stairs"

/turf/simulated/floor/stairs/wood/wide
	icon_state = "wood_stairs2"


/turf/simulated/floor/stairs/wood2
	icon_state = "wood2_stairs"

/turf/simulated/floor/stairs/wood2/wide
	icon_state = "wood2_stairs2"

/turf/simulated/floor/stairs/wood2/middle
	icon_state = "wood2_stairs2_middle"

/turf/simulated/floor/stairs/wood3
	icon_state = "wood3_stairs"

/turf/simulated/floor/stairs/wood3/wide
	icon_state = "wood3_stairs2"


/turf/simulated/floor/stairs/dark
	icon_state = "dark_stairs"

/turf/simulated/floor/stairs/dark/wide
	icon_state = "dark_stairs2"

/////////////////////////////////////////

/turf/simulated/floor/Vspace
	name = "Vspace"
	icon_state = "flashyblue"
	var/network = "none"
	var/network_ID = "none"
	fullbright = 1

/turf/simulated/floor/Vspace/brig
	name = "Brig"
	icon_state = "floor"
	network = "prison"

/turf/unsimulated/floor/vr
	icon_state = "vrfloor"

/turf/unsimulated/floor/vr/plating
	icon_state = "vrplating"

/turf/unsimulated/floor/vr/space
	icon_state = "vrspace"

/turf/unsimulated/floor/vr/white
	icon_state = "vrwhitehall"

// simulated setpieces

/turf/simulated/floor/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0

	bloodfloor
		name = "bloody floor"
		desc = "Yuck."
		icon_state = "bloodfloor_1"

	hivefloor
		name = "hive floor"
		icon = 'icons/turf/floors.dmi'
		icon_state = "hive"

/////////////////////////////////////////

/turf/simulated/floor/snow
	name = "snow"
	icon_state = "snow1"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	mat_appearances_to_ignore = list("steel")

	New()
		..()
		if (prob(50))
			icon_state = "snow2"
		else if (prob(25))
			icon_state = "snow3"
		else if (prob(5))
			icon_state = "snow4"
		src.set_dir(pick(cardinal))

/turf/simulated/floor/snow/snowball
	var/last_gather_time

	attack_hand(mob/user)
		if ((last_gather_time + 40) >= world.time)
			return
		else
			user.visible_message("<b>[user]</b> gathers up some snow and rolls it into a snowball!",\
			"You gather up some snow and roll it into a snowball!")
			var/obj/item/reagent_containers/food/snacks/snowball/S = new /obj/item/reagent_containers/food/snacks/snowball(user.loc)
			user.put_in_hand_or_drop(S)
			src.last_gather_time = world.time
			return

/turf/simulated/floor/snow/green
	name = "snow-covered floor"
	icon_state = "snowgreen"

/turf/simulated/floor/snow/green/corner
	name = "snow-covered floor"
	icon_state = "snowgreencorner"

/////////////////////////////////////////

/turf/simulated/floor/sand
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		src.set_dir(pick(cardinal))

/////////////////////////////////////////

/turf/simulated/floor/industrial
	icon_state = "diamondtile"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/unsimulated/floor/industrial
	icon_state = "diamondtile"
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/////////////////////////////////////////
/turf/simulated/floor/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		setMaterial(getMaterial("synthrubber"))

/turf/proc/grassify()
	.=0

/turf/simulated/floor/grassify()
	src.icon = 'icons/turf/outdoors.dmi'
	src.icon_state = "grass"
	if(prob(30))
		src.icon_state += pick("_p", "_w", "_b", "_y", "_r", "_a")
	src.name = "grass"
	src.set_dir(pick(cardinal))
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/unsimulated/floor/grassify()
	src.icon = 'icons/turf/outdoors.dmi'
	src.icon_state = "grass"
	if(prob(30))
		src.icon_state += pick("_p", "_w", "_b", "_y", "_r", "_a")
	src.name = "grass"
	src.set_dir(pick(cardinal))
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/grass/leafy
	icon_state = "grass_leafy"

/turf/simulated/floor/grass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/simulated/floor/grass/random/alt
	icon_state = "grass_eh"

/////////////////////////////////////////

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-FUCK THAT SHIT MY WRIST HURTS=-=-=-=-=-=-=-=-=*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */


/turf/simulated/floor/plating/airless
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	//fullbright = 1
	allows_vehicles = 1

	New()
		..()
		name = "plating"

/turf/simulated/floor/plating/airless/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	reinforced = TRUE

/turf/simulated/floor/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	reinforced = TRUE

/turf/simulated/floor/metalfoam
	icon = 'icons/turf/floors.dmi'
	icon_state = "metalfoam"
	var/metal = 1
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	intact = 0
	allows_vehicles = 1 // let the constructor pods move around on these
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	desc = "A flimsy foamed metal floor."

/turf/simulated/floor/blob
	name = "blob floor"
	desc = "Blob floors to lob blobs over."
	icon = 'icons/mob/blob.dmi'
	icon_state = "bridge"
	default_melt_cap = 80
	allows_vehicles = 1

	New()
		..()
		setMaterial(getMaterial("blob"))

	proc/setOvermind(var/mob/living/intangible/blob_overmind/O)
		if (!material)
			setMaterial(getMaterial("blob"))
		material.color = O.color
		color = O.color

	attackby(var/obj/item/W, var/mob/user)
		if (isweldingtool(W))
			visible_message("<b>[user] hits [src] with [W]!</b>")
			if (prob(25))
				ReplaceWithSpace()

	ex_act(severity)
		if (prob(33))
			..(max(severity - 1, 1))
		else
			..(severity)

	burn_tile()
		return

// metal foam floors

/turf/simulated/floor/metalfoam/update_icon()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironform"

/turf/simulated/floor/metalfoam/ex_act()
	ReplaceWithSpace()

/turf/simulated/floor/metalfoam/attackby(obj/item/C as obj, mob/user as mob)

	if(!C || !user)
		return 0
	if (istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			T.build(src)
			if(T.material) src.setMaterial(T.material)

		if (T.amount < 1 && !issilicon(user))
			user.u_equip(T)
			qdel(T)
			return
		return

	if(prob(75 - metal * 25))
		ReplaceWithSpace()
		boutput(user, "You easily smash through the foamed metal floor.")
	else
		boutput(user, "Your attack bounces off the foamed metal floor.")

/turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/shuttle/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		return 0
	return ..()

/turf/unsimulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/floor/burn_down()
	src.ex_act(2)

/turf/simulated/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ReplaceWithSpace()
#ifdef UNDERWATER_MAP
			//if (prob(10))
			//	src.ex_act(severity+1)
#endif

		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					if(prob(33))
						var/obj/item/I = unpool(/obj/item/raw_material/scrap_metal)
						I.set_loc(src)
						if (src.material)
							I.setMaterial(src.material)
						else
							var/datum/material/M = getMaterial("steel")
							I.setMaterial(M)
					src.ReplaceWithLattice()
				if(2)
					src.ReplaceWithSpace()
				if(3)
					if(prob(33))
						var/obj/item/I = unpool(/obj/item/raw_material/scrap_metal)
						I.set_loc(src)
						if (src.material)
							I.setMaterial(src.material)
						else
							var/datum/material/M = getMaterial("steel")
							I.setMaterial(M)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act(var/power)
	return

/turf/simulated/floor/proc/update_icon()

/turf/simulated/attack_hand(mob/user as mob)
	if (src.density == 1)
		return
	if (!user.canmove || user.restrained())
		return
	if (!user.pulling || user.pulling.anchored || (user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		//get rid of click delay since we didn't do anything
		user.next_click = world.time
		return
	//duplicate user.pulling for RTE fix
	if (user.pulling && user.pulling.loc == user)
		user.pulling = null
		return
	//if the object being pulled's loc is another object (being in their contents) return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/simulated/floor/proc/to_plating(var/force_break)
	if(!force_break)
		if(src.reinforced) return
	if(!intact) return
	if (!icon_old)
		icon_old = icon_state
	if (!name_old)
		name_old = name
	src.name = "plating"
	src.icon_state = "plating"
	intact = 0
	broken = 0
	burnt = 0
	if(plate_mat)
		src.setMaterial(plate_mat)
	else
		src.setMaterial(getMaterial("steel"))
	levelupdate()

/turf/simulated/floor/proc/dismantle_wall()//can get called due to people spamming weldingtools on walls
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(intact) to_plating()
	break_tile()

/turf/simulated/floor/proc/break_tile(var/force_break)
	if(!force_break)
		if(src.reinforced) return

	if(broken) return
	if (!icon_old)
		icon_old = icon_state
	if(intact)
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(broken || burnt || reinforced) return
	if (!icon_old)
		icon_old = icon_state
	if(intact)
		src.icon_state = "floorscorched[pick(1,2)]"
	else
		src.icon_state = "panelscorched"
	burnt = 1

/turf/simulated/floor/shuttle/burn_tile()
	return

/turf/simulated/floor/proc/restore_tile()
	if(intact) return
	intact = 1
	broken = 0
	burnt = 0
	icon = initial(icon)
	if(icon_old)
		icon_state = icon_old
	else
		icon_state = "floor"
	if (name_old)
		name = name_old
	levelupdate()

/turf/simulated/floor/var/global/girder_egg = 0

//basically the same as walls.dm sans the
/turf/simulated/floor/proc/attach_light_fixture_parts(var/mob/user, var/obj/item/W)
	if (!user || !istype(W, /obj/item/light_parts/floor))
		return

	// the wall is the target turf, the source is the turf where the user is standing
	var/obj/item/light_parts/parts = W
	var/turf/target = src


	playsound(src, "sound/items/Screwdriver.ogg", 50, 1)
	boutput(user, "You begin to attach the light fixture to [src]...")

	if (!do_after(user, 4 SECONDS))
		user.show_text("You were interrupted!", "red")
		return

	if (!parts) //ZeWaka: Fix for null.fixture_type
		return

	// if they didn't move, put it up
	boutput(user, "You attach the light fixture to [src].")

	var/obj/machinery/light/newlight = new parts.fixture_type(target)
	newlight.icon_state = parts.installed_icon_state
	newlight.base_state = parts.installed_base_state
	newlight.fitting = parts.fitting
	newlight.status = 1 // LIGHT_EMPTY

	newlight.add_fingerprint(user)
	src.add_fingerprint(user)

	user.u_equip(parts)
	qdel(parts)
	return

/turf/simulated/floor/proc/pry_tile(obj/item/C as obj, mob/user as mob, params)
	if (!intact)
		return
	if(src.reinforced)
		boutput(user, "<span class='alert'>You can't pry apart reinforced flooring! You'll have to loosen it with a welder or wrench instead.</span>")
		return

	if(broken || burnt)
		boutput(user, "<span class='alert'>You remove the broken plating.</span>")
	else
		var/atom/A = new /obj/item/tile(src)
		if(src.material)
			A.setMaterial(src.material)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)
		.= A //return tile for crowbar special attack ok

	to_plating()
	playsound(src, "sound/items/Crowbar.ogg", 80, 1)

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob, params)

	if (!C || !user)
		return 0

	if (ispryingtool(C))
		src.pry_tile(C,user,params)
		return

	if (istype(C, /obj/item/pen))
		var/obj/item/pen/P = C
		P.write_on_turf(src, user, params)
		return

	if (istype(C, /obj/item/light_parts/floor))
		src.attach_light_fixture_parts(user, C) // Made this a proc to avoid duplicate code (Convair880).
		return

	if (src.reinforced && ((isweldingtool(C) && C:try_weld(user,0,-1,0,1)) || iswrenchingtool(C)))
		boutput(user, "<span class='notice'>Loosening rods...</span>")
		if(iswrenchingtool(C))
			playsound(src, "sound/items/Ratchet.ogg", 80, 1)
		if(do_after(user, 3 SECONDS))
			if(!src.reinforced)
				return
			var/obj/R1 = new /obj/item/rods(src)
			var/obj/R2 = new /obj/item/rods(src)
			if (material)
				R1.setMaterial(material)
				R2.setMaterial(material)
			else
				R1.setMaterial(getMaterial("steel"))
				R2.setMaterial(getMaterial("steel"))
			ReplaceWithFloor()
			src.to_plating()
			return

	if(istype(C, /obj/item/rods))
		if (!src.intact)
			if (C:amount >= 2)
				boutput(user, "<span class='notice'>Reinforcing the floor...</span>")
				if(do_after(user, 3 SECONDS))
					ReplaceWithEngineFloor()

					if (C)
						C:amount -= 2
						if (C:amount <= 0)
							qdel(C) //wtf

						if (C.material)
							src.setMaterial(C.material)

					playsound(src, "sound/items/Deconstruct.ogg", 80, 1)
			else
				boutput(user, "<span class='alert'>You need more rods.</span>")
		else
			boutput(user, "<span class='alert'>You must remove the plating first.</span>")
		return

	if(istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount < 1)
			if(!issilicon(user))
				user.u_equip(T)
				qdel(T)
			return
		if(intact)
			var/obj/P = user.find_tool_in_hand(TOOL_PRYING)
			if (!P)
				return
			// Call ourselves w/ the tool, then continue
			src.attackby(P, user)

		// Don't replace with an [else]! If a prying tool is found above [intact] might become 0 and this runs too, which is how floor swapping works now! - BatElite
		if (!intact)
			restore_tile()
			src.plate_mat = src.material
			if(C.material)
				src.setMaterial(C.material)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)

			if(!istype(src.material, /datum/material/metal/steel))
				logTheThing("station", user, null, "constructs a floor (<b>Material:</b>: [src.material && src.material.name ? "[src.material.name]" : "*UNKNOWN*"]) at [log_loc(src)].")

			T.change_stack_amount(-1)
			//if(T && (--T.amount < 1))
			//	qdel(T)
			//	return


	if(istype(C, /obj/item/sheet))
		if (!(C?.material?.material_flags & (MATERIAL_METAL | MATERIAL_CRYSTAL))) return
		if (!C:amount_check(2,usr)) return

		var/msg = "a girder"

		if(!girder_egg)
			var/count = 0
			for(var/obj/structure/girder in src)
				count++
			var/static/list/insert_girder = list(
			"a girder",
			"another girder",
			"yet another girder",
			"oh god it's another girder",
			"god save the queen its another girder",
			"sweet christmas its another girder",
			"the 6th girder",
			"you're not sure but you think it's a girder",
			"um... ok. a girder, I guess",
			"what does girder even mean, anyway",
			"the strangest girder",
			"the girder that confuses you",
			"the metallic support frame",
			"a very untrustworthy girder",
			"the \"i'm concerned about the sheer number of girders\" girder",
			"a broken wall",
			"the 16th girder",
			"the 17th girder",
			"the 18th girder",
			"the 19th girder",
			"the 20th century girder",
			"the 21th girder",
			"the mfin girder coming right atcha",
			"the girder you cant believe is a girder",
			"rozenkrantz \[sic?\] and girderstein",
			"a.. IS THAT?! no, just a girder",
			"a gifter",
			"a shitty girder",
			"a girder potato",
			"girded loins",
			"the platonic ideal of stacked girders",
			"a complete goddamn mess of girders",
			"FUCK",
			"a girder for ants",
			"a girder of a time",
			"a girder girder girder girder girder girder girder girder girder girder girder girder.. mushroom MUSHROOM",
			"an attempted girder",
			"a failed girder",
			"a girder most foul",
			"a girder who just wants to be a wall",
			"a human child",//40
			"ett gürdür",
			"a girdle",
			"a g--NOT NOW MOM IM ALMOST AT THE 100th GIRDER--irder",
			"a McGirder",
			"a Double Cheesegirder",
			"an egg salad",
			"the ugliest damn girder you've ever seen in your whole fucking life",
			"the most magnificent goddamn girder that you've ever seen in your entire fucking life",
			"the constitution of the old republic, and also a girder",
			"a waste of space, which is crazy when you consider where you built this",//50
			"pure girder vibrations",
			"a poo containment girder",
			"an extremely solid girder, your parents would be proud",
			"the girder who informs you to the authorities",
			"a discount girder",
			"a counterfeit girder",
			"a construction",
			"readster's very own girder",
			"just a girder",
			"a gourder",//60
			"a fuckable girder",
			"a herd of girders",
			"an A.D.G.S",
			"the... thing",
			"the.. girder?",
			"a girder. one that girds if you girder it.",
			"the frog(?)",
			"the unstable relationship",
			"nice",
			"the girder egg")
			msg = insert_girder[min(count+1, insert_girder.len)]
			if(count >= 70)
				girder_egg = 1
				actions.start(new /datum/action/bar/icon/build(C, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard/passive, 2, null, 1, 'icons/obj/structures.dmi', "girder egg", msg, null), user)
			else
				actions.start(new /datum/action/bar/icon/build(C, /obj/structure/girder, 2, C:material, 1, 'icons/obj/structures.dmi', "girder", msg, null, spot = src), user)
		else
			actions.start(new /datum/action/bar/icon/build(C, /obj/structure/girder, 2, C:material, 1, 'icons/obj/structures.dmi', "girder", msg, null, spot = src), user)


	if(istype(C, /obj/item/cable_coil))
		if(!intact)
			var/obj/item/cable_coil/coil = C
			coil.turf_place(src, user)
		else
			boutput(user, "<span class='alert'>You must remove the plating first.</span>")

//grabsmash??
	else if (istype(C, /obj/item/grab/))
		var/obj/item/grab/G = C
		if  (!grab_smash(G, user))
			return ..(C, user)
		else
			return

	// hi i don't know where else to put this :D - cirr
	else if (istype(C, /obj/item/martianSeed))
		var/obj/item/martianSeed/S = C
		if(S)
			S.plant(src)
			logTheThing("station", user, null, "plants a martian biotech seed (<b>Structure:</b> [S.spawn_path]) at [log_loc(src)].")
			return

	//also in turf.dm. Put this here for lowest priority.
	else if (src.temp_flags & HAS_KUDZU)
		var/obj/spacevine/K = locate(/obj/spacevine) in src.contents
		if (K)
			K.attackby(C, user, params)

	else
		return attack_hand(user)

/turf/simulated/floor/MouseDrop_T(atom/A, mob/user as mob)
	..(A,user)
	if(istype(A,/turf/simulated/floor))
		var/turf/simulated/floor/F = A
		var/obj/item/I = user.equipped()
		if(I)
			if(istype(I,/obj/item/cable_coil))
				var/obj/item/cable_coil/C = I
				if((get_dist(user,F)<2) && (get_dist(user,src)<2))
					C.move_callback(user, F, src)

////////////////////////////////////////////ADVENTURE SIMULATED FLOORS////////////////////////
DEFINE_FLOORS_SIMMED_UNSIMMED(racing,
	icon = 'icons/misc/racing.dmi';\
	icon_state = "track_1")

DEFINE_FLOORS_SIMMED_UNSIMMED(racing/edge,
	icon = 'icons/misc/racing.dmi';\
	icon_state = "track_2")

DEFINE_FLOORS_SIMMED_UNSIMMED(racing/rainbow_road,
	icon = 'icons/misc/racing.dmi';\
	icon_state = "rainbow_road")

//////////////////////////////////////////////UNSIMULATED//////////////////////////////////////

/////////////////////// cogwerks - setpiece stuff

/turf/unsimulated/wall/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0

	bloodwall
		name = "bloody wall"
		desc = "Gross."
		icon = 'icons/misc/meatland.dmi'
		icon_state = "bloodwall_1"

	leadwall
		name = "shielded wall"
		desc = "Seems pretty sturdy."
		icon_state = "leadwall"

		junction
			icon_state = "leadjunction"

		junction_four
			icon_state = "leadjunction_4way"

		cap
			icon_state = "leadcap"

		gray
			icon_state = "leadwall_gray"

		white
			name = "Microwave Power Transmitter"
			desc = "The outer shell of some large microwave array thing."
			icon_state = "leadwall_white"

	leadwindow
		name = "shielded window"
		desc = "Seems pretty sturdy."
		icon_state = "leadwindow_1"
		opacity = 0

		full
			icon_state = "leadwindow_2"

		gray
			icon_state = "leadwindow_gray_1"

	rootwall
		name = "overgrown wall"
		desc = "This wall is covered in vines."
		icon_state = "rootwall"

	bluewall
		name = "blue wall"
		desc = "This doesn't look normal at all."
		icon_state = "bluewall"

	bluewall_glowing
		name = "glowing wall"
		desc = "It seems to be humming slightly. Huh."
		luminosity = 2
		icon_state = "bluewall_glow"
		can_replace_with_stuff = 1

		attackby(obj/item/W as obj, mob/user as mob)
			if (istype(W, /obj/item/device/key))
				playsound(src, "sound/effects/mag_warp.ogg", 50, 1)
				src.visible_message("<span class='notice'><b>[src] slides away!</b></span>")
				src.ReplaceWithSpace() // make sure the area override says otherwise - maybe this sucks

	hive
		name = "hive wall"
		desc = "Honeycomb's big, yeah yeah yeah."
		icon = 'icons/turf/walls.dmi'
		icon_state = "hive"

// -------------------- VR --------------------
/turf/unsimulated/floor/setpieces/gauntlet
	name = "Gauntlet Floor"
	desc = "Artist needs effort badly."
	icon = 'icons/effects/VR.dmi'
	icon_state = "gauntfloorDefault"

/turf/unsimulated/wall/setpieces/gauntlet
	name = "Gauntlet Wall"
	desc = "Is this retro? Thank god it's not team ninja."
	icon = 'icons/effects/VR.dmi'
	icon_state = "gauntwall"
// --------------------------------------------

/turf/proc/fall_to(var/turf/T, var/atom/movable/A)
	if(istype(A, /obj/overlay/tile_effect)) //Ok enough light falling places. Fak.
		return
	if (isturf(T))
		visible_message("<span class='alert'>[A] falls into [src]!</span>")
		if (ismob(A))
			var/mob/M = A
			if(!M.stat && ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.gender == MALE) playsound(H.loc, "sound/voice/screams/male_scream.ogg", 100, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else playsound(H.loc, "sound/voice/screams/female_scream.ogg", 100, 0, 0, H.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			random_brute_damage(M, 50)
			M.changeStatus("paralysis", 70)
			SPAWN_DBG(0)
				playsound(M.loc, pick('sound/impact_sounds/Slimy_Splat_1.ogg', 'sound/impact_sounds/Flesh_Break_1.ogg'), 75, 1)
		A.set_loc(T)
		return

/turf/unsimulated/floor/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0

	ancient_pit
		name = "broken staircase"
		desc = "You can't see the bottom."
		icon_state = "black"
		var/target_landmark = LANDMARK_FALL_ANCIENT

		Entered(atom/A as mob|obj)
			if (isobserver(A) || (istype(A, /obj/critter) && A:flying))
				return ..()

			var/turf/T = pick_landmark(target_landmark)
			if(T)
				fall_to(T, A)
				return
			else ..()

		shaft
			name = "Elevator Shaft"
			target_landmark = LANDMARK_FALL_BIO_ELE

			Entered(atom/A as mob|obj)
				if (istype(A, /mob) && !istype(A, /mob/dead))
					bioele_accident()
				return ..()

	bloodfloor
		name = "bloody floor"
		desc = "Yuck."
		icon_state = "bloodfloor_1"

	rootfloor
		name = "overgrown floor"
		desc = "This floor is covered in vines."
		icon_state = "rootfloor_1"

	oldfloor
		name = "floor"
		desc = "Looks a bit different."
		icon_state = "old_floor1"

	bluefloor
		name = "blue floor"
		desc = "This floor looks awfully strange."
		icon_state = "bluefloor"

		pit
			name = "ominous pit"
			desc = "You can't see the bottom."
			icon_state = "deeps"

			Entered(atom/A as mob|obj)
				if (istype(A, /obj/overlay/tile_effect) || istype(A, /mob/dead) || istype(A, /mob/wraith) || istype(A, /mob/living/intangible))
					return ..()

				var/turf/T = pick_landmark(LANDMARK_FALL_DEEP)
				if(T)
					fall_to(T, A)
					return
				else ..()

	hivefloor
		name = "hive floor"
		desc = ""
		icon = 'icons/turf/floors.dmi'
		icon_state = "hive"

	swampgrass
		name = "reedy grass"
		desc = ""
		icon = 'icons/misc/worlds.dmi'
		icon_state = "swampgrass"

		New()
			..()
			set_dir(pick(1,2,4,8))
			return

	swampgrass_edging
		name = "reedy grass"
		desc = ""
		icon = 'icons/misc/worlds.dmi'
		icon_state = "swampgrass_edge"
