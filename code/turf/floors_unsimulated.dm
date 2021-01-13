/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors.dm & floors_airless.dm
 */

/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000


/turf/unsimulated/floor/attackby(obj/item/C as obj, mob/user as mob, params)

	if (!C || !user)
		return 0

	if (istype(C, /obj/item/pen))
		var/obj/item/pen/P = C
		P.write_on_turf(src, user, params)
		return

	else if (istype(C, /obj/item/grab/))
		var/obj/item/grab/G = C
		if  (!grab_smash(G, user))
			return ..(C, user)
		else
			return
	..()

/////////////////////////////////////////

/turf/unsimulated/floor/scorched
	icon_state = "floorscorched1"

/turf/unsimulated/floor/scorched2
	icon_state = "floorscorched2"

/turf/unsimulated/floor/damaged1
	icon_state = "damaged1"

/turf/unsimulated/floor/damaged2
	icon_state = "damaged2"

/turf/unsimulated/floor/damaged3
	icon_state = "damaged3"

/turf/unsimulated/floor/damaged4
	icon_state = "damaged4"

/turf/unsimulated/floor/damaged5
	icon_state = "damaged5"

/////////////////////////////////////////

/turf/unsimulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0

/turf/unsimulated/floor/plating/scorched
	icon_state = "panelscorched"

/turf/unsimulated/floor/plating/damaged1
	icon_state = "platingdmg1"

/turf/unsimulated/floor/plating/damaged2
	icon_state = "platingdmg2"

/turf/unsimulated/floor/plating/damaged3
	icon_state = "platingdmg3"

/turf/unsimulated/floor/plating/random
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

/////////////////////////////////////////

/turf/unsimulated/floor/grime
	icon_state = "floorgrime"

/////////////////////////////////////////

/turf/unsimulated/floor/neutral
	icon_state = "fullneutral"

/turf/unsimulated/floor/neutral/side
	icon_state = "neutral"

/turf/unsimulated/floor/neutral/corner
	icon_state = "neutralcorner"

/////////////////////////////////////////

/turf/unsimulated/floor/white
	icon_state = "white"

/turf/unsimulated/floor/white/side
	icon_state = "whitehall"

/turf/unsimulated/floor/white/corner
	icon_state = "whitecorner"

/turf/unsimulated/floor/white/checker
	icon_state = "whitecheck"

/turf/unsimulated/floor/white/checker2
	icon_state = "whitecheck2"

/turf/unsimulated/floor/white/grime
	icon_state = "floorgrime-w"

/////////////////////////////////////////

/turf/unsimulated/floor/black //Okay so 'dark' is darker than 'black', So 'dark' will be named black and 'black' named grey.
	icon_state = "dark"

/turf/unsimulated/floor/black/side
	icon_state = "greyblack"

/turf/unsimulated/floor/black/corner
	icon_state = "greyblackcorner"

/turf/unsimulated/floor/black/grime
	icon_state = "floorgrime-b"


/turf/unsimulated/floor/blackwhite
	icon_state = "darkwhite"

/turf/unsimulated/floor/blackwhite/corner
	icon_state = "darkwhitecorner"

/turf/unsimulated/floor/blackwhite/side
	icon_state = "whiteblack"

/turf/unsimulated/floor/blackwhite/whitegrime
	icon_state = "floorgrime_bw1"

/turf/unsimulated/floor/blackwhite/whitegrime/other
	icon_state = "floorgrime_bw2"

/////////////////////////////////////////

/turf/unsimulated/floor/grey
	icon_state = "fullblack"

/turf/unsimulated/floor/grey/side
	icon_state = "black"

/turf/unsimulated/floor/grey/corner
	icon_state = "blackcorner"

/turf/unsimulated/floor/grey/checker
	icon_state = "blackchecker"

/turf/unsimulated/floor/grey/blackgrime
	icon_state = "floorgrime_gb1"

/turf/unsimulated/floor/grey/blackgrime/other
	icon_state = "floorgrime_gb2"

/turf/unsimulated/floor/grey/whitegrime
	icon_state = "floorgrime_gw1"

/turf/unsimulated/floor/grey/whitegrime/other
	icon_state = "floorgrime_gw2"

/////////////////////////////////////////

/turf/unsimulated/floor/red
	icon_state = "fullred"

/turf/unsimulated/floor/red/side
	icon_state = "red"

/turf/unsimulated/floor/red/corner
	icon_state = "redcorner"

/turf/unsimulated/floor/red/checker
	icon_state = "redchecker"


/turf/unsimulated/floor/redblack
	icon_state = "redblack"

/turf/unsimulated/floor/redblack/corner
	icon_state = "redblackcorner"

/turf/unsimulated/floor/red/redblackchecker
	icon_state = "redblackchecker"


/turf/unsimulated/floor/redwhite
	icon_state = "redwhite"

/turf/unsimulated/floor/redwhite/corner
	icon_state = "redwhitecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/blue
	icon_state = "fullblue"

/turf/unsimulated/floor/blue/side
	icon_state = "blue"

/turf/unsimulated/floor/blue/corner
	icon_state = "bluecorner"

/turf/unsimulated/floor/blue/checker
	icon_state = "bluechecker"


/turf/unsimulated/floor/blueblack
	icon_state = "blueblack"

/turf/unsimulated/floor/blueblack/corner
	icon_state = "blueblackcorner"


/turf/unsimulated/floor/bluewhite
	icon_state = "bluewhite"

/turf/unsimulated/floor/bluewhite/corner
	icon_state = "bluewhitecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/darkblue
	icon_state = "fulldblue"

/turf/unsimulated/floor/darkblue/checker
	icon_state = "blue-dblue"

/turf/unsimulated/floor/darkblue/checker/other
	icon_state = "blue-dblue2"

/////////////////////////////////////////

/turf/unsimulated/floor/darkpurple
	icon_state = "fulldpurple"

/turf/unsimulated/floor/darkpurple/side
	icon_state = "dpurple"

/////////////////////////////////////////

/turf/unsimulated/floor/bluegreen
	icon_state = "blugreenfull"

/turf/unsimulated/floor/bluegreen/side
	icon_state = "blugreen"

/turf/unsimulated/floor/bluegreen/corner
	icon_state = "blugreencorner"

/////////////////////////////////////////

/turf/unsimulated/floor/green
	icon_state = "fullgreen"

/turf/unsimulated/floor/green/side
	icon_state = "green"

/turf/unsimulated/floor/green/corner
	icon_state = "greencorner"

/turf/unsimulated/floor/green/checker
	icon_state = "greenchecker"


/turf/unsimulated/floor/greenblack
	icon_state = "greenblack"

/turf/unsimulated/floor/greenblack/corner
	icon_state = "greenblackcorner"


/turf/unsimulated/floor/greenwhite
	icon_state = "greenwhite"

/turf/unsimulated/floor/greenwhite/corner
	icon_state = "greenwhitecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/greenwhite/other
	icon_state = "toxshuttle"

/turf/unsimulated/floor/greenwhite/other/corner
	icon_state = "toxshuttlecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/purple
	icon_state = "fullpurple"

/turf/unsimulated/floor/purple/side
	icon_state = "purple"

/turf/unsimulated/floor/purple/corner
	icon_state = "purplecorner"

/turf/unsimulated/floor/purple/checker
	icon_state = "purplechecker"


/turf/unsimulated/floor/purpleblack
	icon_state = "purpleblack"

/turf/unsimulated/floor/purpleblack/corner
	icon_state = "purpleblackcorner"


/turf/unsimulated/floor/purplewhite
	icon_state = "purplewhite"

/turf/unsimulated/floor/purplewhite/corner
	icon_state = "purplewhitecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/yellow
	icon_state = "fullyellow"

/turf/unsimulated/floor/yellow/side
	icon_state = "yellow"

/turf/unsimulated/floor/yellow/corner
	icon_state = "yellowcorner"

/turf/unsimulated/floor/yellow/checker
	icon_state = "yellowchecker"


/turf/unsimulated/floor/yellowblack
	icon_state = "yellowblack"

/turf/unsimulated/floor/yellowblack/corner
	icon_state = "yellowblackcorner"

/////////////////////////////////////////

/turf/unsimulated/floor/orange
	icon_state = "fullorange"

/turf/unsimulated/floor/orange/side
	icon_state = "orange"

/turf/unsimulated/floor/orange/corner
	icon_state = "orangecorner"


/turf/unsimulated/floor/orangeblack
	icon_state = "fullcaution"

/turf/unsimulated/floor/orangeblack/side
	icon_state = "caution"

/turf/unsimulated/floor/orangeblack/side/white
	icon_state = "cautionwhite"

/turf/unsimulated/floor/orangeblack/corner
	icon_state = "cautioncorner"

/turf/unsimulated/floor/orangeblack/corner/white
	icon_state = "cautionwhitecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/circuit
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

/turf/unsimulated/floor/circuit/green
	icon_state = "circuit-green"
	RL_LumR = 0
	RL_LumG = 0.3
	RL_LumB = 0

/turf/unsimulated/floor/circuit/white
	icon_state = "circuit-white"
	RL_LumR = 0.2
	RL_LumG = 0.2
	RL_LumB = 0.2

/turf/unsimulated/floor/circuit/purple
	icon_state = "circuit-purple"
	RL_LumR = 0.1
	RL_LumG = 0
	RL_LumB = 0.2

/turf/unsimulated/floor/circuit/red
	icon_state = "circuit-red"
	RL_LumR = 0.3
	RL_LumG = 0
	RL_LumB = 0

/turf/unsimulated/floor/circuit/vintage
	icon_state = "circuit-vint1"
	RL_LumR = 0.1
	RL_LumG = 0.1
	RL_LumB = 0.1

/turf/unsimulated/floor/circuit/off
	icon_state = "circuitoff"
	RL_LumR = 0
	RL_LumG = 0
	RL_LumB = 0

/////////////////////////////////////////

/turf/unsimulated/floor/carpet
	name = "carpet"
	icon = 'icons/turf/carpet.dmi'
	icon_state = "red1"
	mat_appearances_to_ignore = list("cloth")
	mat_changename = 0

	New()
		..()
		setMaterial(getMaterial("cloth"))

/turf/unsimulated/floor/carpet/grime
	icon = 'icons/turf/floors.dmi'
	icon_state = "grimy"

/turf/unsimulated/floor/carpet/arcade
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade_carpet"

/turf/unsimulated/floor/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/unsimulated/floor/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/unsimulated/floor/carpet/office
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet"

/turf/unsimulated/floor/carpet/office/other
	icon = 'icons/turf/floors.dmi'
	icon_state = "office_carpet2"

/////////////////////////////////////////

/turf/unsimulated/floor/shiny
	icon_state = "shiny"

/turf/unsimulated/floor/shiny/white
	icon_state = "whiteshiny"

/////////////////////////////////////////

/turf/unsimulated/floor/sanitary
	icon_state = "freezerfloor"

/turf/unsimulated/floor/sanitary/white
	icon_state = "freezerfloor2"

/turf/unsimulated/floor/sanitary/blue
	icon_state = "freezerfloor3"

////////////////////////////////////////

/turf/unsimulated/floor/specialroom

/turf/unsimulated/floor/specialroom/arcade
	icon_state = "arcade"

/turf/unsimulated/floor/specialroom/bar
	icon_state = "bar"

/turf/unsimulated/floor/specialroom/bar/edge
	icon_state = "bar-edge"

/turf/unsimulated/floor/specialroom/gym
	name = "boxing mat"
	icon_state = "boxing"

/turf/unsimulated/floor/specialroom/gym/alt
	name = "gym mat"
	icon_state = "gym_mat"

/turf/unsimulated/floor/specialroom/cafeteria
	icon_state = "cafeteria"

/turf/unsimulated/floor/specialroom/chapel
	icon_state = "chapel"

/turf/unsimulated/floor/specialroom/freezer
	name = "freezer floor"
	icon_state = "freezerfloor"
	temperature = T0C

/turf/unsimulated/floor/specialroom/freezer/white
	icon_state = "freezerfloor2"

/turf/unsimulated/floor/specialroom/freezer/blue
	icon_state = "freezerfloor3"

/turf/unsimulated/floor/specialroom/medbay
	icon_state = "medbay"

/////////////////////////////////////////

/turf/unsimulated/floor/arrival
	icon_state = "arrival"

/turf/unsimulated/floor/arrival/corner
	icon_state = "arrivalcorner"

/////////////////////////////////////////

/turf/unsimulated/floor/escape
	icon_state = "escape"

/turf/unsimulated/floor/escape/corner
	icon_state = "escapecorner"

/////////////////////////////////////////

/turf/unsimulated/floor/delivery
	icon_state = "delivery"

/turf/unsimulated/floor/delivery/white
	icon_state = "delivery_white"

/turf/unsimulated/floor/delivery/caution
	icon_state = "deliverycaution"


/turf/unsimulated/floor/bot
	icon_state = "bot"

/turf/unsimulated/floor/bot/white
	icon_state = "bot_white"

/turf/unsimulated/floor/bot/blue
	icon_state = "bot_blue"

/turf/unsimulated/floor/bot/caution
	icon_state = "botcaution"

/turf/unsimulated/floor/bot/darkpurple
	icon_state = "bot_dpurple"

/////////////////////////////////////////

/turf/unsimulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

	allows_vehicles = 1

/turf/unsimulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/unsimulated/floor/engine/glow
	icon_state = "engine-glow"

/turf/unsimulated/floor/engine/glow/blue
	icon_state = "engine-blue"


/turf/unsimulated/floor/engine/caution/south
	icon_state = "engine_caution_south"

/turf/unsimulated/floor/engine/caution/north
	icon_state = "engine_caution_north"

/turf/unsimulated/floor/engine/caution/west
	icon_state = "engine_caution_west"

/turf/unsimulated/floor/engine/caution/east
	icon_state = "engine_caution_east"

/turf/unsimulated/floor/engine/caution/westeast
	icon_state = "engine_caution_we"

/turf/unsimulated/floor/engine/caution/corner
	icon_state = "engine_caution_corners"

/turf/unsimulated/floor/engine/caution/corner2
	icon_state = "engine_caution_corners2"

/turf/unsimulated/floor/engine/caution/misc
	icon_state = "engine_caution_misc"

/////////////////////////////////////////

/turf/unsimulated/floor/caution/south
	icon_state = "caution_south"

/turf/unsimulated/floor/caution/north
	icon_state = "caution_north"

/turf/unsimulated/floor/caution/northsouth
	icon_state = "caution_ns"

/turf/unsimulated/floor/caution/west
	icon_state = "caution_west"

/turf/unsimulated/floor/caution/east
	icon_state = "caution_east"

/turf/unsimulated/floor/caution/westeast
	icon_state = "caution_we"

/turf/unsimulated/floor/caution/corner/se
	icon_state = "corner_east"

/turf/unsimulated/floor/caution/corner/sw
	icon_state = "corner_west"

/turf/unsimulated/floor/caution/corner/ne
	icon_state = "corner_neast"

/turf/unsimulated/floor/caution/corner/nw
	icon_state = "corner_nwest"

/turf/unsimulated/floor/caution/corner/misc
	icon_state = "floor_hazard_corners"

/turf/unsimulated/floor/caution/misc
	icon_state = "floor_hazard_misc"

/////////////////////////////////////////

/turf/unsimulated/floor/wood
	icon_state = "wooden-2"
	mat_appearances_to_ignore = list("wood")

	New()
		..()
		setMaterial(getMaterial("wood"))

/turf/unsimulated/floor/wood/two
	icon_state = "wooden"

/turf/unsimulated/floor/wood/three
	icon_state = "wooden-3"

/turf/unsimulated/floor/wood/four
	icon_state = "wooden-4"

/turf/unsimulated/floor/wood/five
	icon_state = "wooden-5"

/turf/unsimulated/floor/wood/six
	icon_state = "wooden-6"

/turf/unsimulated/floor/wood/seven
	icon_state = "wooden-7"

/turf/unsimulated/floor/wood/eight
	icon_state = "wooden-8"

/////////////////////////////////////////

/turf/unsimulated/floor/sandytile
	name = "sand-covered floor"
	icon_state = "sandytile"

/////////////////////////////////////////
/turf/unsimulated/floor/stairs
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

/turf/unsimulated/floor/stairs/wide
	icon_state = "Stairs_wide"

/turf/unsimulated/floor/stairs/wide/other
	icon_state = "Stairs2_wide"

/turf/unsimulated/floor/stairs/wide/green
	icon_state = "Stairs_wide_green"

/turf/unsimulated/floor/stairs/wide/middle
	icon_state = "stairs_middle"


/turf/unsimulated/floor/stairs/medical
	icon_state = "medstairs_alone"

/turf/unsimulated/floor/stairs/medical/wide
	icon_state = "medstairs_wide"

/turf/unsimulated/floor/stairs/medical/wide/other
	icon_state = "medstairs2_wide"

/turf/unsimulated/floor/stairs/medical/wide/middle
	icon_state = "medstairs_middle"


/turf/unsimulated/floor/stairs/quilty
	icon_state = "quiltystair"

/turf/unsimulated/floor/stairs/quilty/wide
	icon_state = "quiltystair2"


/turf/unsimulated/floor/stairs/wood
	icon_state = "wood_stairs"

/turf/unsimulated/floor/stairs/wood/wide
	icon_state = "wood_stairs2"


/turf/unsimulated/floor/stairs/wood2
	icon_state = "wood2_stairs"

/turf/unsimulated/floor/stairs/wood2/wide
	icon_state = "wood2_stairs2"


/turf/unsimulated/floor/stairs/wood3
	icon_state = "wood3_stairs"

/turf/unsimulated/floor/stairs/wood3/wide
	icon_state = "wood3_stairs2"


/turf/unsimulated/floor/stairs/dark
	icon_state = "dark_stairs"

/turf/unsimulated/floor/stairs/dark/wide
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

///////////

/turf/unsimulated/floor/airless/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

/turf/unsimulated/floor/airless/plating/scorched
	icon_state = "panelscorched"

/turf/unsimulated/floor/airless/plating/damaged1
	icon_state = "platingdmg1"

/turf/unsimulated/floor/airless/plating/damaged2
	icon_state = "platingdmg2"

/turf/unsimulated/floor/airless/plating/damaged3
	icon_state = "platingdmg3"

//////////////

/turf/unsimulated/floor/airless/grime
	icon_state = "floorgrime"

/////////////

/turf/unsimulated/floor/airless/white
	icon_state = "white"

/turf/unsimulated/floor/airless/white/side
	icon_state = "whitehall"

/turf/unsimulated/floor/airless/white/corner
	icon_state = "whitecorner"

/turf/unsimulated/floor/airless/white/checker
	icon_state = "whitecheck"

/turf/unsimulated/floor/airless/white/checker2
	icon_state = "whitecheck2"

/turf/unsimulated/floor/airless/white/grime
	icon_state = "floorgrime-w"

/////////////////////////////////////////

/turf/unsimulated/floor/snow
	name = "snow"
	icon_state = "snow1"

	New()
		..()
		if (prob(50))
			icon_state = "snow2"
		else if (prob(25))
			icon_state = "snow3"
		else if (prob(5))
			icon_state = "snow4"
		src.set_dir(pick(cardinal))

/turf/unsimulated/floor/snow/green
	name = "snow-covered floor"
	icon_state = "snowgreen"

/turf/unsimulated/floor/snow/green/corner
	name = "snow-covered floor"
	icon_state = "snowgreencorner"

/////////////////////////////////////////

/turf/unsimulated/floor/sand
	name = "sand"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand"

	New()
		..()
		src.set_dir(pick(cardinal))

/////////////////////////////////////////

/turf/unsimulated/floor/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0

	New()
		..()
		setMaterial(getMaterial("synthrubber"))

/turf/unsimulated/floor/grass/leafy
	icon_state = "grass_leafy"

/turf/unsimulated/floor/grass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/unsimulated/floor/grass/random/alt
	icon_state = "grass_eh"

/////////////////////////////////////////
//manta related//
/turf/unsimulated/floor/longtile
	icon_state = "longtile"

/turf/unsimulated/floor/longtile/black
	icon_state = "longtile-dark"

/////////////////////////////////////////

/turf/unsimulated/floor/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
