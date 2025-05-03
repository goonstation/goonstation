/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors_unsimulated.dm & floors_airless.dm
 */

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.04
	heat_capacity = 225000
	default_material = "steel"

	turf_flags = MOB_SLIP | MOB_STEP

	can_burn = TRUE
	can_break = TRUE
	/// if this floor can be pried up
	var/pryable = TRUE
	var/has_material = TRUE

	/// Set to instantiated material datum ([getMaterial()]) for custom material floors
	var/reinforced = FALSE
	//Stuff for the floor & wall planner undo mode that initial() doesn't resolve.
	var/tmp/roundstart_icon_state
	var/tmp/roundstart_dir
	/// if this turf is immune to explosion (explosion immune turfs immediately return on ex_act())
	var/explosion_immune = FALSE
	///Things that are hidden "in" this turf that are revealed when it is pried up.
	///Kept in a hidden object on the turf so that `get_turf` works as normal. Yes this is crime, fight me I have a possum.
	var/obj/effects/hidden_contents_holder/hidden_contents = null

	New()
		..()
		roundstart_icon_state = icon_state
		roundstart_dir = dir
		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
			switch(src.icon_state)
				if("caution_north")
					new /obj/decal/tile_edge/stripe/xmas{dir=NORTH}(src)
				if("engine_caution_north")
					new /obj/decal/tile_edge/stripe/xmas{dir=NORTH}(src)
				if("caution_south")
					new /obj/decal/tile_edge/stripe/xmas{dir=SOUTH}(src)
				if("engine_caution_south")
					new /obj/decal/tile_edge/stripe/xmas{dir=SOUTH}(src)
				if("caution_west")
					new /obj/decal/tile_edge/stripe/xmas{dir=WEST}(src)
				if("engine_caution_west")
					new /obj/decal/tile_edge/stripe/xmas{dir=WEST}(src)
				if("caution_east")
					new /obj/decal/tile_edge/stripe/xmas{dir=EAST}(src)
				if("engine_caution_east")
					new /obj/decal/tile_edge/stripe/xmas{dir=EAST}(src)
				if("caution_we")
					new /obj/decal/tile_edge/stripe/xmas{dir=WEST}(src)
					new /obj/decal/tile_edge/stripe/xmas{dir=EAST}(src)
				if("engine_caution_we")
					new /obj/decal/tile_edge/stripe/xmas{dir=WEST}(src)
					new /obj/decal/tile_edge/stripe/xmas{dir=EAST}(src)
				if("caution_ns")
					new /obj/decal/tile_edge/stripe/xmas{dir=NORTH}(src)
					new /obj/decal/tile_edge/stripe/xmas{dir=SOUTH}(src)
				if("engine_caution_ns")
					new /obj/decal/tile_edge/stripe/xmas{dir=NORTH}(src)
					new /obj/decal/tile_edge/stripe/xmas{dir=SOUTH}(src)
				if("corner_neast")
					new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
				if("corner_nwest")
					new /obj/decal/tile_edge/stripe/xmas{dir=NORTHWEST}(src)
				if("corner_east")
					new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHEAST}(src)
				if("corner_west")
					new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
				if("floor_hazard_misc")
					switch(src.dir)
						if(SOUTH)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHEAST}(src)
						if(NORTH)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
						if(EAST)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHEAST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
						if(WEST)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHWEST}(src)
						if(SOUTHEAST)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
				if("engine_caution_misc")
					switch(src.dir)
						if(SOUTH)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHEAST}(src)
						if(NORTH)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
						if(EAST)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHEAST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
						if(WEST)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHWEST}(src)
						if(SOUTHEAST)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
				if("engine_caution_corners")
					switch(src.dir)
						if(SOUTH)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHWEST}(src)
						if(NORTH)
							new /obj/decal/tile_edge/stripe/xmas{dir=SOUTHEAST}(src)
						if(EAST)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHEAST}(src)
						if(WEST)
							new /obj/decal/tile_edge/stripe/xmas{dir=NORTHWEST}(src)
				if("floor_hazard_corners")
					switch(src.dir)
						if(SOUTH)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=SOUTH}(src)
						if(NORTH)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=NORTH}(src)
						if(EAST)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=EAST}(src)
						if(WEST)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=WEST}(src)
						if(SOUTHEAST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=SOUTHEAST}(src)
						if(SOUTHWEST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=SOUTHWEST}(src)
						if(NORTHEAST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=NORTHEAST}(src)
						if(NORTHWEST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=NORTHWEST}(src)
				if("engine_caution_corners2")
					switch(src.dir)
						if(SOUTH)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=SOUTH}(src)
						if(NORTH)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=NORTH}(src)
						if(EAST)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=EAST}(src)
						if(WEST)
							new /obj/decal/tile_edge/stripe/corner/xmas{dir=WEST}(src)
						if(SOUTHEAST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=SOUTHEAST}(src)
						if(SOUTHWEST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=SOUTHWEST}(src)
						if(NORTHEAST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=NORTHEAST}(src)
						if(NORTHWEST)
							new /obj/decal/tile_edge/stripe/corner/xmas2{dir=NORTHWEST}(src)
		#endif
		var/obj/plan_marker/floor/P = locate() in src
		if (P)
			src.icon = P.icon
			src.icon_state = P.icon_state
			src.icon_old = P.icon_state
			allows_vehicles = P.allows_vehicles
			var/pdir = P.dir
			SPAWN(0.5 SECONDS)
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
			if (prob(50))
				src.break_tile()
				src.icon_old = null // we're already plating
			else
				src.burn_tile()
				src.icon_old = null
			src.UpdateIcon()
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
			/obj/item/currency/spacecash, /obj/item/tile/steel, /obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wrench, /obj/item/wirecutters, /obj/item/crowbar)
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
			if (prob(50))
				src.break_tile()
				src.icon_old = null
			else
				src.burn_tile()
				src.icon_old = null


/////////////////////////////////////////

/turf/simulated/floor/scorched
	burnt = 1

	New()
		..()
		var/image/burn_overlay = image('icons/turf/floors.dmi',"floorscorched1")
		burn_overlay.alpha = 200
		AddOverlays(burn_overlay,"burn")

/turf/simulated/floor/scorched2
	burnt = 1

	New()
		..()
		var/image/burn_overlay = image('icons/turf/floors.dmi',"floorscorched2")
		burn_overlay.alpha = 200
		AddOverlays(burn_overlay,"burn")

/turf/simulated/floor/damaged1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"damaged1")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/turf/simulated/floor/damaged2
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"damaged2")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/turf/simulated/floor/damaged3
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"damaged3")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/turf/simulated/floor/damaged4
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"damaged4")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/turf/simulated/floor/damaged5
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"damaged5")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/////////////////////////////////////////

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	layer = PLATING_LAYER

/turf/simulated/floor/plating/jen
	icon_state = "plating_jen"

/turf/simulated/floor/plating/scorched

	New()
		..()
		burn_tile()

/turf/simulated/floor/plating/damaged1
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"platingdmg1")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/turf/simulated/floor/plating/damaged2
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"platingdmg2")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

/turf/simulated/floor/plating/damaged3
	broken = 1

	New()
		..()
		var/image/damage_overlay = image('icons/turf/floors.dmi',"platingdmg3")
		damage_overlay.alpha = 200
		AddOverlays(damage_overlay,"damage")

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

/turf/simulated/floor/darkblue/side
	icon_state = "dblue"

/turf/simulated/floor/darkblue/corner
	icon_state = "dbluecorner"

/turf/simulated/floor/darkblue/checker/white
	icon_state = "dbluechecker"

/turf/simulated/floor/darkblueblack
	icon_state = "dblueblack"

/turf/simulated/floor/darkblueblack/corner
	icon_state = "dblueblackcorner"

/turf/simulated/floor/darkbluewhite
	icon_state = "dbluewhite"

/turf/simulated/floor/darkbluewhite/corner
	icon_state = "dbluewhitecorner"

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

/turf/simulated/floor/darkpurple/corner
	icon_state = "dpurplecorner"

/turf/simulated/floor/darkpurple/checker
	icon_state = "dpurplechecker"

/turf/simulated/floor/darkpurpleblack
	icon_state = "dpurpleblack"

/turf/simulated/floor/darkpurpleblack/corner
	icon_state = "dpurpleblackcorner"


/turf/simulated/floor/darkpurplewhite
	icon_state = "dpurplewhite"

/turf/simulated/floor/darkpurplewhite/corner
	icon_state = "dpurplewhitecorner"
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

TYPEINFO(/turf/simulated/floor/circuit)
	mat_appearances_to_ignore = list("pharosium")
/turf/simulated/floor/circuit
	name = "transduction matrix"
	desc = "An elaborate, faintly glowing matrix of isolinear circuitry."
	icon_state = "circuit"
	RL_LumR = 0
	RL_LumG = 0   //Corresponds to color of the icon_state.
	RL_LumB = 0.3
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	default_material = "pharosium"

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

TYPEINFO(/turf/simulated/floor/carpet)
	mat_appearances_to_ignore = list("cotton")
/turf/simulated/floor/carpet
	name = "carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "red1"
	step_material = "step_carpet"
	step_priority = STEP_PRIORITY_MED
	mat_changename = 0
	default_material = "cotton"

/turf/simulated/floor/carpet/grime
	name = "cheap carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "grimy"

/turf/simulated/floor/carpet/arcade
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "arcade_carpet"

/turf/simulated/floor/carpet/arcade/half
	icon_state = "arcade_carpet_half"

/turf/simulated/floor/carpet/arcade/blank
	icon_state = "arcade_carpet_blank"

/turf/simulated/floor/carpet/office
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "office_carpet"

/turf/simulated/floor/carpet/office/other
	icon_state = "office_carpet2"

DEFINE_FLOORS(carpet/regalcarpet,
	name = "regal carpet";\
	icon = 'icons/turf/floors/carpet.dmi';\
	icon_state = "regal_carpet";\
	step_material = "step_carpet";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(carpet/regalcarpet/border,
	icon_state = "regal_carpet_border")

DEFINE_FLOORS(carpet/regalcarpet/innercorner,
	icon_state = "regal_carpet_corner")

DEFINE_FLOORS(carpet/darkcarpet,
	name = "dark carpet";\
	icon = 'icons/turf/floors/carpet.dmi';\
	icon_state = "dark_carpet";\
	step_material = "step_carpet";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(carpet/darkcarpet/border,
	icon_state = "dark_carpet_border")

DEFINE_FLOORS(carpet/darkcarpet/innercorner,
	icon_state = "dark_carpet_corner")

DEFINE_FLOORS(carpet/clowncarpet,
	name = "clown carpet";\
	icon = 'icons/turf/floors/carpet.dmi';\
	icon_state = "clown_carpet";\
	step_material = "step_carpet";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(carpet/clowncarpet/border,
	icon_state = "clown_carpet_border")

DEFINE_FLOORS(carpet/clowncarpet/innercorner,
	icon_state = "clown_carpet_corner")

/////////////////////////////////////////

/turf/simulated/floor/shiny
	icon_state = "shiny"

/turf/simulated/floor/shiny/white
	icon_state = "whiteshiny"

/////////////////////////////////////////

/turf/simulated/floor/pool/lightblue
	icon_state = "pooltiles_lightblue"

/turf/simulated/floor/pool/white
	icon_state = "pooltiles_white"

/turf/simulated/floor/pool/blue
	icon_state = "pooltiles_blue"

/turf/simulated/floor/pool/bluewhite
	icon_state = "pooltiles_bluew"

/turf/simulated/floor/pool/lightbluewhite
	icon_state = "pooltiles_lightbluew"

/turf/simulated/floor/pool/bluewhitecorner
	icon_state = "pooltiles_bluewcorner"

/turf/simulated/floor/pool/lightbluewhitecorner
	icon_state = "pooltiles_lightbluewcorner"

//////////////////////////////////////////

/turf/simulated/floor/sanitary
	icon_state = "freezerfloor"

/turf/simulated/floor/sanitary/white
	icon_state = "freezerfloor2"

/turf/simulated/floor/sanitary/blue
	icon_state = "freezerfloor3"

////////////////////////////////////////

DEFINE_FLOORS(twotone,
	name = "two-tone checker floor";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "twotone_grey";\
	step_material = "step_plating";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(twotone/red,
	icon_state = "twotone_red")

DEFINE_FLOORS(twotone/purple,
	icon_state = "twotone_purple")

DEFINE_FLOORS(twotone/green,
	icon_state = "twotone_green")

DEFINE_FLOORS(twotone/blue,
	icon_state = "twotone_blue")

DEFINE_FLOORS(twotone/yellow,
	icon_state = "twotone_yellow")

DEFINE_FLOORS(twotone/white,
	icon_state = "twotone_white")

DEFINE_FLOORS(twotone/black,
	icon_state = "twotone_black")

/////////////////////////////////////////

DEFINE_FLOORS(terrazzo,
	name = "terrazzo tiling";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "terrazzo_beige";\
	step_material = "step_wood";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(terrazzo/black,
	icon_state = "terrazzo_black")

DEFINE_FLOORS(terrazzo/white,
	icon_state = "terrazzo_white")

/////////////////////////////////////////

DEFINE_FLOORS(marble,
	name = "marble tiling";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "marble_white";\
	step_material = "step_wood";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(marble/black,
	icon_state = "marble_black")

DEFINE_FLOORS(marble/border_bw,
	icon_state = "marble_border_bw")

DEFINE_FLOORS(marble/border_wb,
	icon_state = "marble_border_wb")

/////////////////////////////////////////

TYPEINFO(/turf/simulated/floor/glassblock)
	mat_appearances_to_ignore = list("steel","synthrubber","glass")
/turf/simulated/floor/glassblock
	name = "glass block tiling"
	icon = 'icons/turf/floors.dmi'
	icon_state = "glass_small"
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED
	mat_changename = FALSE
	can_burn = FALSE
	can_break = FALSE

	pry_tile(obj/item/C as obj, mob/user as mob, params)
		boutput(user, SPAN_ALERT("This is glass flooring, you can't pry this up!"))

	to_plating()
		return

	break_tile_to_plating()
		return

	break_tile()
		return

	// unburnable, otherwise floorbots use steel sheets for repair which doesn't make sense
	burn_tile()
		return

	attackby(obj/item/C, mob/user, params)
		if (istype(C, /obj/item/rods))
			boutput(user, SPAN_ALERT("You can't reinforce this tile."))
			return
		if(istype(C, /obj/item/cable_coil))
			boutput(user, SPAN_ALERT("You can't put cable over this tile, it would be too exposed."))
			return
		..()

/turf/simulated/floor/glassblock/large
	icon_state = "glass_large"

/turf/simulated/floor/glassblock/transparent
	icon_state = "glasstr_cyan"
	default_material = "glass"

	New()
		..()
		#ifndef CI_RUNTIME_CHECKING
		var/image/I
		#ifdef UNDERWATER_MAP
		var/sand_icon
		var/direction
		switch(rand(1, 3))
			if(1)
				sand_icon = "sand_other_texture"
				direction = pick(alldirs)
			if(2)
				sand_icon = "sand_other_texture2"
				direction = pick(alldirs)
			if(3)
				sand_icon = "sand_other_texture3"
				direction = pick(cardinal)
		I = image('icons/turf/outdoors.dmi', sand_icon, dir = direction)
		#else
		src.underlays += /turf/space::starlight
		I = mutable_appearance('icons/turf/space.dmi', "[rand(1, 25)]")
		I.color = /turf/space::space_color
		#endif
		I.plane = PLANE_SPACE
		src.underlays += I
		#endif

/turf/simulated/floor/glassblock/transparent/cyan
	icon_state = "glasstr_cyan"

/turf/simulated/floor/glassblock/transparent/indigo
	icon_state = "glasstr_indigo"

/turf/simulated/floor/glassblock/transparent/red
	icon_state = "glasstr_red"

/turf/simulated/floor/glassblock/transparent/grey
	icon_state = "glasstr_grey"

/turf/simulated/floor/glassblock/transparent/purple
	icon_state = "glasstr_purple"

/turf/simulated/floor/glassblock/transparent/large
	icon_state = "glasstr_large_cyan"

/turf/simulated/floor/glassblock/transparent/large/cyan
	icon_state = "glasstr_large_cyan"

/turf/simulated/floor/glassblock/transparent/large/indigo
	icon_state = "glasstr_large_indigo"

/turf/simulated/floor/glassblock/transparent/large/red
	icon_state = "glasstr_large_red"

/turf/simulated/floor/glassblock/transparent/large/grey
	icon_state = "glasstr_large_grey"

/turf/simulated/floor/glassblock/transparent/large/purple
	icon_state = "glasstr_large_purple"

/////////////////////////////////////////

DEFINE_FLOORS(minitiles,
	name = "mini tiles";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "minitiles_grey";\
	step_material = "step_plating";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(minitiles/white,
	icon_state = "minitiles_white")

DEFINE_FLOORS(minitiles/black,
	icon_state = "minitiles_black")

/////////////////////////////////////////

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

	Entered(atom/movable/M, atom/OldLoc)
		..()
		if (!istype(OldLoc, /turf/simulated/floor/specialroom/gym))
			M.setStatus("wrestler")

	Exited(atom/movable/M, atom/newloc)
		..()
		if (!istype(newloc, /turf/simulated/floor/specialroom/gym))
			M.delStatus("wrestler")

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

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	reinforced = TRUE
	allows_vehicles = TRUE
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	can_burn = FALSE
	can_break = FALSE

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

TYPEINFO(/turf/simulated/floor/wood)
	mat_appearances_to_ignore = list("wood")
/turf/simulated/floor/wood
	icon_state = "wooden-2"
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED
	default_material = "wood"

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
			if (!W.lying && prob(10))
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


TYPEINFO(/turf/simulated/floor/stairs/wood)
	mat_appearances_to_ignore = list("wood")
/turf/simulated/floor/stairs/wood
	default_material = "wood"
	icon_state = "wood_stairs"

/turf/simulated/floor/stairs/wood/wide
	default_material = "wood"
	icon_state = "wood_stairs2"


TYPEINFO(/turf/simulated/floor/stairs/wood2)
	mat_appearances_to_ignore = list("wood")
/turf/simulated/floor/stairs/wood2
	default_material = "wood"
	icon_state = "wood2_stairs"

/turf/simulated/floor/stairs/wood2/wide
	default_material = "wood"
	icon_state = "wood2_stairs2"

/turf/simulated/floor/stairs/wood2/middle
	default_material = "wood"
	icon_state = "wood2_stairs2_middle"

TYPEINFO(/turf/simulated/floor/stairs/wood3)
	mat_appearances_to_ignore = list("wood")
/turf/simulated/floor/stairs/wood3
	default_material = "wood"
	icon_state = "wood3_stairs"

/turf/simulated/floor/stairs/wood3/wide
	default_material = "wood"
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

TYPEINFO(/turf/simulated/floor/snow)
	mat_appearances_to_ignore = list("steel")
/turf/simulated/floor/snow
	name = "snow"
	default_material = null
	icon_state = "snow1"
	step_material = "step_snow"
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

	Uncrossed(atom/movable/AM)
		. = ..()
		src.snow_prints(AM)

/turf/simulated/floor/snow/snowball

	New()
		..()
		AddComponent(/datum/component/snowballs)

/turf/simulated/floor/snow/green
	name = "snow-covered floor"
	icon_state = "snowgreen"

/turf/simulated/floor/snow/green/corner
	name = "snow-covered floor"
	icon_state = "snowgreencorner"

DEFINE_FLOORS(snowcalm,
	name = "snow";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "snow_calm";\
	step_material = "step_snow";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(snowcalm/border,
	icon_state = "snow_calm_border")

DEFINE_FLOORS(snowrough,
	name = "snow";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "snow_rough";\
	step_material = "step_snow";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(snowrough/border,
	icon_state = "snow_rough_border")

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

/* Animated turf - Walp */

DEFINE_FLOORS(techfloor,
	name = "data tech flooring";\
	icon = 'icons/turf/floors.dmi';\
	icon_state = "techfloor_blue";\
	step_material = "step_plating";\
	step_priority = STEP_PRIORITY_MED;\
	RL_LumR = 0;\
	RL_LumG = 0;\
	RL_LumB = 0.3)

DEFINE_FLOORS(techfloor/red,
	icon_state = "techfloor_red";\
	RL_LumR = 0.3;\
	RL_LumG = 0;\
	RL_LumB = 0)

DEFINE_FLOORS(techfloor/purple,
	icon_state = "techfloor_purple";\
	RL_LumR = 0.1;\
	RL_LumG = 0;\
	RL_LumB = 0.2)

DEFINE_FLOORS(techfloor/yellow,
	icon_state = "techfloor_yellow";\
	RL_LumR = 0.2;\
	RL_LumG = 0.1;\
	RL_LumB = 0)

DEFINE_FLOORS(techfloor/green,
	icon_state = "techfloor_green";\
	RL_LumR = 0;\
	RL_LumG = 0.3;\
	RL_LumB = 0)

/////////////////////////////////////////

TYPEINFO(/turf/simulated/floor/grass)
	mat_appearances_to_ignore = list("steel","synthrubber")
/turf/simulated/floor/grass
	name = "grass"
	icon = 'icons/turf/outdoors.dmi'
	#ifdef SEASON_AUTUMN
	icon_state = "grass_autumn"
	#else
	icon_state = "grass"
	#endif
	mat_changename = 0
	mat_changedesc = 0
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED
	default_material = "synthrubber"

	#ifdef SEASON_WINTER
	New()
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
			if(prob(10))
				new /obj/item/reagent_containers/food/snacks/snowball/unmelting(src)
			..()
			SPAWN(0)
				src.ReplaceWith(/turf/simulated/floor/snow/snowball, keep_old_material=FALSE, handle_air = FALSE)
			return
		..()
	#endif

/turf/proc/grassify()
	.=0

/turf/proc/snow_prints(atom/movable/AM)
	if (isliving(AM) && !HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING))
		var/mob/living/M = AM
		if (M.lying)
			var/obj/effect/snow_step/dragged = new(src)
			dragged.icon_state = "tracks" // TODO: tracks but the middle is filled in a little
			dragged.dir = AM.dir
			return


		var/l_leg_icon_state
		var/r_leg_icon_state

		if (ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if (H.limbs?.l_leg)
				if (H.limbs.l_leg.kind_of_limb & LIMB_TREADS)
					l_leg_icon_state = "tracks"
				else
					l_leg_icon_state = "footprints"
			if (H.limbs?.r_leg)
				if (H.limbs.r_leg.kind_of_limb & LIMB_TREADS)
					r_leg_icon_state = "tracks"
				else
					r_leg_icon_state = "footprints"

		else if (isrobot(AM))
			var/mob/living/silicon/robot/R = AM
			if (R.part_leg_l)
				if (R.part_leg_l.kind_of_limb & LIMB_TREADS)
					l_leg_icon_state = "tracks"
				else
					l_leg_icon_state = "footprints"
			if (R.part_leg_r)
				if (R.part_leg_r.kind_of_limb & LIMB_TREADS)
					r_leg_icon_state = "tracks"
				else
					r_leg_icon_state = "footprints"

		// both legs are the same, use a single combined iconstate
		if (l_leg_icon_state == r_leg_icon_state)
			var/obj/effect/snow_step/both_steppy = new(src)
			if(l_leg_icon_state == "footprints")
				l_leg_icon_state = pick("footprints1","footprints2")
			both_steppy.icon_state = l_leg_icon_state
			both_steppy.dir = AM.dir
			return

		// separate or one leg
		if (l_leg_icon_state)
			var/obj/effect/snow_step/left_steppy = new(src)
			left_steppy.icon_state = "[l_leg_icon_state]L"
			left_steppy.dir = AM.dir
		if (r_leg_icon_state)
			var/obj/effect/snow_step/right_steppy = new(src)
			right_steppy.icon_state = "[r_leg_icon_state]R"
			right_steppy.dir = AM.dir
		return

/// wetType: [-2 = glue, -1 = slime, 0 = dry, 1 = water, 2 = lube, 3 = superlube]
/// silent: makes the overlay invisible and prevents the sound effect
/turf/simulated/proc/wetify(var/wetType = 2, var/timeout = 80 SECONDS, var/color = null, var/silent = FALSE)
	var/obj/mesh/catwalk/catwalk = null
	var/image/overlay = null
	var/alpha = 60

	if (wetType <= 0)
		overlay = image('icons/effects/water.dmi', "sticky_floor")
	else
		overlay = image('icons/effects/water.dmi', "wet_floor")

	if (!silent)
		playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
	else
		alpha = 0

	overlay.blend_mode = BLEND_ADD
	overlay.alpha = alpha
	overlay.color = color

	if (istype(src, /turf/simulated/floor/airless/plating/catwalk)) // "Guh" - Leah
		catwalk = locate() in src
		catwalk.AddOverlays(overlay, "wet_overlay")

	src.AddOverlays(overlay, "wet_overlay")
	src.wet = wetType

	SPAWN(timeout)
		src.dryify()

/turf/simulated/proc/dryify()
	src.ClearSpecificOverlays("wet_overlay")
	if(istype(src, /turf/simulated/floor/airless/plating/catwalk)) // ""Guh" - Leah" - Me
		var/obj/mesh/catwalk/catwalk = locate() in src
		catwalk?.ClearSpecificOverlays("wet_overlay")
	src.wet = 0


/obj/effect/snow_step
	icon = 'icons/obj/decals/blood/blood.dmi'
	layer = DECAL_LAYER
	plane = PLANE_FLOOR
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | NO_CLIENT_COLOR | TILE_BOUND
	color = "#91b8d0"

	New()
		. = ..()
		var/weather_severity = 0
		src.fade_away((10-(weather_severity*3)) * 10 DECI SECONDS)
		return

	proc/weather_fade()
		var/weather_severity = 0
		if (isnull(weather_severity) || weather_severity < 1)
			return

		// todo: Add dynamic selection of weather severity
		// Using active events, parallax, or other indicators
		// sev0 = 10 seconds (clear skies)
		// sev1 = 7 seconds (light snow)
		// sev2 = 4 seconds (heavy snow)
		// sev3 = 1 second (blizzard)
		src.fade_away((10-(weather_severity*3)) * 10 DECI SECONDS)

	proc/fade_away(time)
		animate_buff_out_time(src, time)
		SPAWN(time)
			qdel(src)

/turf/simulated/floor/grassify()
	src.icon = 'icons/turf/outdoors.dmi'
	src.icon_state = pick("grass", "grass_1", "grass_2", "grass_3")
	src.UpdateIcon()
	if(prob(30))
		src.icon_state = pick("grass_p", "grass_w", "grass_b", "grass_y", "grass_r", "grass_a")
	src.name = "grass"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/unsimulated/floor/grassify()
	src.icon = 'icons/turf/outdoors.dmi'
	src.icon_state = pick("grass", "grass_1", "grass_2", "grass_3")
	src.UpdateIcon()
	if(prob(30))
		src.icon_state = pick("grass_p", "grass_w", "grass_b", "grass_y", "grass_r", "grass_a")
	src.name = "grass"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/grass/leafy
#ifdef SEASON_AUTUMN
	icon_state = "grass_leafy_autumn"
#else
	icon_state = "grass_leafy"
#endif

/turf/simulated/floor/grass/random
	New()
		..()
		src.set_dir(pick(cardinal))

/turf/simulated/floor/grass/random/alt
	icon_state = "grass_eh"

TYPEINFO(/turf/simulated/floor/grasstodirt)
	mat_appearances_to_ignore = list("steel","synthrubber")
/turf/simulated/floor/grasstodirt
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	#ifdef SEASON_AUTUMN
	icon_state = "autumntodirt"
	#else
	icon_state = "grasstodirt"
	#endif
	mat_changename = 0
	mat_changedesc = 0

TYPEINFO(/turf/simulated/floor/dirt)
	mat_appearances_to_ignore = list("steel","synthrubber")
/turf/simulated/floor/dirt
	name = "dirt"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "dirt"
	mat_changename = 0
	mat_changedesc = 0

/////////////////////////////////////////

//// some other floors ////

TYPEINFO(/turf/simulated/floor/marslike)
	mat_appearances_to_ignore = list("steel")
/turf/simulated/floor/marslike
	name = "imitation martian dirt"
	desc = "Wow, you almost believed it was real martian dirt for a moment!"
	icon = 'icons/misc/mars_outpost.dmi'
	icon_state = "placeholder"
	step_material = "step_outdoors"
	step_priority = STEP_PRIORITY_MED

/turf/simulated/floor/marslike/t1
	icon_state = "t1"
/turf/simulated/floor/marslike/t2
	icon_state = "t2"
/turf/simulated/floor/marslike/t3
	icon_state = "t4"
/turf/simulated/floor/marslike/t4
	icon_state = "t4"

TYPEINFO(/turf/simulated/floor/stone)
	mat_appearances_to_ignore = list("steel","rock")
/turf/simulated/floor/stone
	name = "stone"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "stone"
	mat_changename = 0
	mat_changedesc = 0
	default_material = "rock"

/////////////////////////////////////////

/* Misc Adventure tilesets - Walp */

TYPEINFO(/turf/simulated/floor/honeyblocks)
	mat_appearances_to_ignore = list("steel","synthrubber")

DEFINE_FLOORS(honeyblocks,
	name = "crystallized honey";\
	desc = "Probably not edible.";\
	icon = 'icons/turf/adventure_walpvrgis.dmi';\
	icon_state = "honeyblock";\
	mat_changename = 0;\
	mat_changedesc = 0;\
	step_material = "step_plating";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(honeyblocks/border,
	icon_state = "honeyblock_border")

DEFINE_FLOORS(honeyblocks/corner,
	icon_state = "honeyblock_corner")

/////////////////////////////////////////

/* Outdoors tilesets - Walp */

TYPEINFO(/turf/simulated/floor/grasslush)
	mat_appearances_to_ignore = list("steel","synthrubber")
TYPEINFO(/turf/simulated/floor/grasslush/airless)
	mat_appearances_to_ignore = list("steel","synthrubber")
TYPEINFO(/turf/unsimulated/floor/grasslush)
	mat_appearances_to_ignore = list("steel","synthrubber")
TYPEINFO(/turf/unsimulated/floor/grasslush/airless)
	mat_appearances_to_ignore = list("steel","synthrubber")
DEFINE_FLOORS(grasslush,
	name = "lush grass";\
	desc = "This grass somehow thrives in space.";\
	icon = 'icons/turf/outdoors.dmi';\
	icon_state = "grass_lush";\
	mat_changename = 0;\
	mat_changedesc = 0;\
	step_material = "step_outdoors";\
	step_priority = STEP_PRIORITY_MED)

DEFINE_FLOORS(grasslush/border,
	icon_state = "grass_lush_border")

DEFINE_FLOORS(grasslush/corner,
	icon_state = "grass_lush_corner")

DEFINE_FLOORS(grasslush/thinner,
	icon_state = "grass_lesslush")

DEFINE_FLOORS(grasslush/thin,
	icon_state = "grass_thin")

/////////////////////////////////////////

DEFINE_FLOORS(solidcolor,
	icon_state = "solid_white")

DEFINE_FLOORS(solidcolor/fullbright,
	fullbright = 1)

DEFINE_FLOORS(solidcolor/black,
	icon_state = "solid_black")

DEFINE_FLOORS(solidcolor/black/fullbright,
	fullbright = 1)

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
	can_burn = FALSE
	can_break = FALSE

/turf/simulated/floor/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	reinforced = TRUE
	can_burn = FALSE
	can_break = FALSE

/turf/simulated/floor/metalfoam
	icon = 'icons/turf/floors.dmi'
	icon_state = "metalfoam"
	var/metal = 1
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	intact = 0
	layer = PLATING_LAYER
	allows_vehicles = 1 // let the constructor pods move around on these
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	desc = "A flimsy foamed metal floor."

/turf/simulated/floor/blob
	name = "blob floor"
	desc = "Blob floors to lob blobs over."
	icon = 'icons/mob/blob_organs.dmi'
	icon_state = "bridge"
	default_melt_chance = 80
	allows_vehicles = 1
	default_material = "blob"
	mat_changename = FALSE
	can_burn = FALSE
	can_break = FALSE

	proc/setOvermind(var/mob/living/intangible/blob_overmind/O)
		setMaterial(O.my_material)
		color = material.getColor()

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
	. = ..()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"

/turf/simulated/floor/metalfoam/ex_act()
	ReplaceWithSpace()

/turf/simulated/floor/metalfoam/attackby(obj/item/C, mob/user)

	if(!C || !user)
		return 0
	if (istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, TRUE)
			T.build(src)
		return

	if(prob(75 - metal * 25))
		ReplaceWithSpace()
		boutput(user, "You easily smash through the foamed metal floor.")
	else
		boutput(user, "Your attack bounces off the foamed metal floor.")

/turf/simulated/floor/Cross(atom/movable/mover)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			var/obj/machinery/vehicle/O = mover
			if (istype(O?.sec_system, /obj/item/shipcomponent/secondary_system/crash)) //For ships crashing with the SEED
				var/obj/item/shipcomponent/secondary_system/crash/I = O.sec_system
				if (I.crashable)
					mover.Bump(src)
					return TRUE
			return FALSE
	return ..()

/turf/simulated/shuttle/Cross(atom/movable/mover)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		return 0
	return ..()

/turf/unsimulated/floor/Cross(atom/movable/mover)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/floor/burn_down()
	if (src.intact)
		src.ex_act(2)
	else //make sure plating always burns down to space and not... plating
		src.ex_act(1)

/turf/simulated/floor/ex_act(severity)
	if(src.explosion_immune)
		return
	switch(severity)
		if(1)
			src.ReplaceWithSpace()
		if(2)
			switch(pick(1,2;75,3))
				if (1)
					if(prob(33))
						var/obj/item/I = new /obj/item/raw_material/scrap_metal
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
						var/obj/item/I = new /obj/item/raw_material/scrap_metal
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
		if(3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act(var/power)
	return

/turf/simulated/attack_hand(mob/user)
	if (src.density == 1)
		return
	if (!user.canmove || user.restrained())
		return
	if (!user.pulling || user.pulling.anchored || (user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0))
		//get rid of click delay since we didn't do anything
		user.next_click = world.time
		return
	//duplicate user.pulling for RTE fix
	if (user.pulling && user.pulling.loc == user)
		user.remove_pulling()
		return
	//if the object being pulled's loc is another object (being in their contents) return
	if (!isturf(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.remove_pulling()
		step(M, get_dir(fuck_u, src))
		M.set_pulling(t)
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
	src.UpdateIcon()
	setIntact(FALSE)
	broken = 0
	burnt = 0
	if(default_material)
		var/datum/material/mat = istext(default_material) ? getMaterial(default_material) : default_material
		src.setMaterial(mat)
	else
		src.setMaterial(getMaterial("steel"))
	levelupdate()

/turf/simulated/floor/proc/dismantle_wall()//can get called due to people spamming weldingtools on walls
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if (intact)
		to_plating()
	break_tile()

/turf/simulated/floor/var/global/girder_egg = 0

/turf/simulated/floor/proc/pry_tile(obj/item/C as obj, mob/user as mob, params)
	if (!intact)
		return
	if (!src.pryable)
		return
	if(src.reinforced)
		boutput(user, SPAN_ALERT("You can't pry apart reinforced flooring! You'll have to loosen it with a welder or wrench instead."))
		return

	if(broken || burnt)
		boutput(user, SPAN_ALERT("You remove the broken plating."))
		ClearSpecificOverlays("burn", "damage")
	else
		var/atom/A = new /obj/item/tile(src)
		if(src.material)
			A.setMaterial(src.material)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)
		.= A //return tile for crowbar special attack ok
		user?.unlock_medal("Misclick", 1)
		var/datum/gang/gang = user?.get_gang()
		if (gang && !params["quick_replace"])
			gang.do_vandalism(GANG_VANDALISM_FLOORTILE_POINTS,src)


	to_plating()
	playsound(src, 'sound/items/Crowbar.ogg', 80, TRUE)

/turf/simulated/floor/levelupdate()
	..()
	if (!src.intact && src.hidden_contents)
		for(var/atom/movable/AM as anything in src.hidden_contents)
			AM.set_loc(src)
			SEND_SIGNAL(AM, COMSIG_MOVABLE_FLOOR_REVEALED, src)
		qdel(src.hidden_contents) //it's an obj, see the definition for crime justification
		src.hidden_contents = null


/turf/simulated/floor/attackby(obj/item/C, mob/user, params)

	if (!C || !user)
		return 0

	if (ispryingtool(C))
		if(src.name == "grass")
			src.step_material = initial(step_material)
		src.pry_tile(C,user,params)
		return

	if (istype(C, /obj/item/pen))
		var/obj/item/pen/P = C
		P.write_on_turf(src, user, params)
		return

	if (src.reinforced && ((isweldingtool(C) && C:try_weld(user,0,-1,1,1)) || iswrenchingtool(C)))
		boutput(user, SPAN_NOTICE("Loosening rods..."))
		if(iswrenchingtool(C))
			playsound(src, 'sound/items/Ratchet.ogg', 80, TRUE)
		SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /turf/simulated/floor/proc/remove_reinforcement, null, C.icon, C.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
		return

	if(istype(C, /obj/item/rods))
		if (!src.intact)
			if (C.amount >= 2)
				boutput(user, SPAN_NOTICE("Reinforcing the floor..."))

				SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /turf/simulated/floor/proc/reinforce, C, C.icon, C.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
			else
				boutput(user, SPAN_ALERT("You need more rods."))
		else
			boutput(user, SPAN_ALERT("You must remove the plating first."))
		return

	if(istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		var/do_hide = TRUE
		if(intact)
			var/obj/P = user.find_tool_in_hand(TOOL_PRYING)
			if (!P)
				return
			// Call ourselves w/ the tool, then continue
			var/list/newParams = list()
			newParams["quick_replace"] = TRUE
			src.Attackby(P, user, newParams)
			do_hide = FALSE //don't stuff things under the floor if we're just swapping/replacing a broken tile
			if(src.name == "grass")
				src.step_material = initial(step_material)

		// Don't replace with an [else]! If a prying tool is found above [intact] might become 0 and this runs too, which is how floor swapping works now! - BatElite
		if (!intact)
			if(T.amount >= 1)
				restore_tile(do_hide)
				src.default_material = src.material

				// if we have a special icon state and it doesn't have a material variant
				// and at the same time the base floor icon state does have a material variant
				// we use the material variant from the base floor
				var/potential_new_icon_state = "[materialless_icon_state()]$$[C.material?.getID()]"
				var/potential_new_base_icon_state = "floor$$[C.material?.getID()]"
				if(!src.is_valid_icon_state(potential_new_icon_state) && is_valid_icon_state(potential_new_base_icon_state, 'icons/turf/floors.dmi'))
					src.icon_state = "floor"
					src.icon = 'icons/turf/floors.dmi'

				if(C.material)
					src.setMaterial(C.material)
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, TRUE)

				if(!istype(src.material, /datum/material/metal/steel))
					logTheThing(LOG_STATION, user, "constructs a floor (<b>Material:</b>: [src.material && src.material.getName() ? "[src.material.getName()]" : "*UNKNOWN*"]) at [log_loc(src)].")
				T.change_stack_amount(-1)
			//if(T && (--T.amount < 1))
			//	qdel(T)
			//	return


	if(istype(C, /obj/item/sheet))
		var/obj/item/sheet/S = C
		if (!S.amount_check(2,user)) return
		if (S?.material?.getMaterialFlags() & MATERIAL_METAL)
			var/msg = "the girder"

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
				"an owl?",
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
				if(count >= 70) //nice
					girder_egg = 1
					actions.start(new /datum/action/bar/icon/build(/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard/passive, src, 1, 3 SECONDS, S, 2, null, null, S.material, 'icons/obj/structures.dmi', "girder egg", name = msg), user)
				else
					actions.start(new /datum/action/bar/icon/build(/obj/structure/girder, src, 1, 3 SECONDS, S, 2, null, null, S.material, 'icons/obj/structures.dmi', "girder", name = msg), user)
			else
				actions.start(new /datum/action/bar/icon/build(/obj/structure/girder, src, 1, 3 SECONDS, S, 2, null, null, S.material, 'icons/obj/structures.dmi', "girder", name = msg), user)
		else if ((S?.material?.getMaterialFlags() & MATERIAL_CRYSTAL) && !(locate(/obj/window) in src))
			if(S.reinforcement)
				actions.start(new /datum/action/bar/icon/build(map_settings ? map_settings.rwindows : /obj/window/reinforced, src, 1, 3 SECONDS, S, 2, null, null, S.material, 'icons/obj/window.dmi', "window", /proc/window_reinforce_full_callback, "a full window"), user)
			else
				actions.start(new /datum/action/bar/icon/build(map_settings ? map_settings.windows : /obj/window, 			  src, 1, 3 SECONDS, S, 2, null, null, S.material, 'icons/obj/window.dmi', "window", /proc/window_reinforce_full_callback, "a full window"), user)

	if(istype(C, /obj/item/cable_coil))
		if(!intact)
			var/obj/item/cable_coil/coil = C
			coil.turf_place(src, get_turf(user), user)
		else
			boutput(user, SPAN_ALERT("You must remove the plating first."))

//grabsmash??
	else if (istype(C, /obj/item/grab/))
		var/obj/item/grab/G = C
		if  (!grab_smash(G, user))
			return ..(C, user)
		else
			return

	//also in turf.dm. Put this here for lowest priority.
	else if (src.temp_flags & HAS_KUDZU)
		var/obj/spacevine/K = locate(/obj/spacevine) in src.contents
		if (K)
			K.Attackby(C, user, params)

	else if (!user.pulling || user.pulling.anchored || (user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0)) // this seemed like the neatest way to make attack_hand still trigger when needed
		src.material_trigger_when_attacked(C, user, 1)
	else
		return attack_hand(user)

/turf/simulated/floor/proc/reinforce(obj/item/rods/I)
	src.ReplaceWithEngineFloor()
	if (I.material)
		src.setMaterial(I.material)
	I.change_stack_amount(-2)
	playsound(src, 'sound/items/Deconstruct.ogg', 80, TRUE)

/turf/simulated/floor/proc/remove_reinforcement()
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

/turf/simulated/floor/proc/hide_inside(atom/movable/AM)
	if (!src.hidden_contents)
		src.hidden_contents = new(src)
	AM.set_loc(src.hidden_contents)

/turf/simulated/floor/MouseDrop_T(atom/A, mob/user as mob)
	..(A,user)
	if(istype(A,/turf/simulated/floor))
		var/turf/simulated/floor/F = A
		var/obj/item/I = user.equipped()
		if(I)
			if(istype(I,/obj/item/cable_coil))
				var/obj/item/cable_coil/C = I
				if(BOUNDS_DIST(user,F) == 0 && BOUNDS_DIST(user,src) == 0)
					C.move_callback(user, F, 0, src)

/turf/simulated/floor/ReplaceWith(what, keep_old_material, handle_air, handle_dir, force)
	var/obj/effects/hidden_contents_holder/old_hidden_contents = src.hidden_contents //we have to do this because src will be the new turf after the replace due to byond
	var/turf/simulated/floor/newfloor = ..()
	if (istype(newfloor))
		newfloor.hidden_contents = old_hidden_contents
	else
		qdel(old_hidden_contents)
	return newfloor

/turf/simulated/floor/restore_tile(do_hide = TRUE)
	..()
	if (!do_hide)
		return
	for (var/obj/item/item in src.contents)
		if (item.w_class <= W_CLASS_TINY && !item.anchored) //I wonder if this will cause problems
			src.hide_inside(item)

///CRIME
/obj/effects/hidden_contents_holder
	name = ""
	desc = ""
	icon = null
	anchored = ANCHORED_ALWAYS
	invisibility = INVIS_ALWAYS
	alpha = 0

	set_loc(newloc)
		if (!isnull(newloc))
			return
		. = ..()


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

		white_2
			icon_state = "leadwall_white"

			junction
				name = "shielded wall"
				desc
				icon_state = "leadjunction_white"

			junction_four
				icon_state = "leadjunction_white_4way"

	leadwindow
		name = "shielded window"
		desc = "Seems pretty sturdy."
		icon_state = "leadwindow_1"
		opacity = 0

		full
			icon_state = "leadwindow_2"

		gray
			icon_state = "leadwindow_gray_1"

		white
			icon_state = "leadwindow_white_1"

			full
				icon_state = "leadwindow_white_2"

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

		attackby(obj/item/W, mob/user)
			if (istype(W, /obj/item/device/key/generic/coldsteel))
				playsound(src, 'sound/effects/mag_warp.ogg', 50, TRUE)
				src.visible_message(SPAN_NOTICE("<b>[src] slides away!</b>"))
				src.ReplaceWithSpace() // make sure the area override says otherwise - maybe this sucks

	hive
		name = "hive wall"
		desc = "Honeycomb's big, yeah yeah yeah."
		icon = 'icons/turf/walls.dmi'
		icon_state = "hive"

	stranger
		name = "stranger wall"
		desc = "A weird jet black metal wall indented with strange grooves and lines."
		icon = 'icons/turf/walls.dmi'
		icon_state = "ancient"


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

/turf/unsimulated/floor/setpieces
	icon = 'icons/misc/worlds.dmi'
	fullbright = 0

	ancient_pit
		name = "broken staircase"
		desc = "You can't see the bottom."
		icon_state = "black"
		var/falltarget = LANDMARK_FALL_ANCIENT

		New()
			. = ..()
			src.AddComponent(/datum/component/pitfall/target_landmark,\
				BruteDamageMax = 50,\
				FallTime = 0 SECONDS,\
				TargetLandmark = src.falltarget)

		hole_xy
			name = "deep pit"
			falltarget = LANDMARK_FALL_DEBUG

	bloodfloor
		name = "bloody floor"
		desc = "Yuck."
		icon_state = "bloodfloor_1"

	rootfloor
		name = "overgrown floor"
		desc = "This floor is covered in vines."
		icon_state = "rootfloor_1"

		random
			New()
				. = ..()
				icon_state = "rootfloor_[rand(1,3)]"

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

			New()
				. = ..()
				src.AddComponent(/datum/component/pitfall/target_landmark,\
					BruteDamageMax = 50,\
					FallTime = 0 SECONDS,\
					TargetLandmark = LANDMARK_FALL_DEEP)

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

TYPEINFO(/turf/simulated/floor/auto)
	/// List of types this autowall connects to
	var/list/connects_to = null
	/// Because connections now work by parent type searches, this is for when you don't want certain subtypes to connect.
	/// This must be a typecache ([/proc/typecachesof]) list
	var/list/connects_to_exceptions = null
	/// do we have wall connection overlays, ex nornwalls?
	var/connect_overlay = 0
	var/list/connects_with_overlay = null
	var/list/connects_with_overlay_exceptions = null // same as above comment
	var/connect_across_areas = TRUE
	/// 0 = no diagonal sprites, 1 = diagonal only if both adjacent cardinals are present, 2 = always allow diagonals
	var/connect_diagonal = 0

/turf/simulated/floor/auto
	name = "auto edging turf"

	var/mod = null
	var/light_mod = null
	/// The image we're using to connect to stuff with
	var/image/connect_image = null
	///turf won't draw edges on turfs with higher or equal priority
	var/edge_priority_level = 0
	var/icon_state_edge = null

	New()
		. = ..()
		src.layer += src.edge_priority_level / 1000
		if (current_state > GAME_STATE_WORLD_NEW)
			SPAWN(0) //worldgen overrides ideally
				UpdateIcon()
				if(istype(src))
					update_neighbors()
		else
			worldgenCandidates += src

	generate_worldgen()
		src.UpdateIcon()
		if(istype(src))
			update_neighbors()

	update_icon()
		. = ..()
		src.edge_overlays()
		if(src.mod)
			var/typeinfo/turf/simulated/floor/auto/typinfo = get_typeinfo()
			var/connectdir = get_connected_directions_bitflag(typinfo.connects_to, typinfo.connects_to_exceptions, typinfo.connect_across_areas, typinfo.connect_diagonal)
			var/the_state = "[mod][connectdir]"
			icon_state = the_state

			// if (light_mod)
			// 	src.RL_SetSprite("[light_mod][connectdir]")

			if (typinfo.connect_overlay)
				var/overlaydir = get_connected_directions_bitflag(typinfo.connects_with_overlay, typinfo.connects_with_overlay_exceptions, typinfo.connect_across_areas)
				if (overlaydir)
					if (!src.connect_image)
						src.connect_image = image(src.icon, "connect[overlaydir]")
					else
						src.connect_image.icon_state = "connect[overlaydir]"
					src.AddOverlays(src.connect_image, "connect")
				else
					src.ClearSpecificOverlays("connect")

	proc/update_neighbors()
		for (var/turf/simulated/floor/auto/T in orange(1,src))
			T.UpdateIcon()

	proc/edge_overlays()
		if(src.icon_state_edge)
			for (var/turf/T in orange(src,1))
				if (istype(T, /turf/simulated/floor/auto))
					var/turf/simulated/floor/auto/TA = T
					if (TA.edge_priority_level >= src.edge_priority_level)
						continue
				var/direction = get_dir(T,src)
				var/image/edge_overlay = image(src.icon, "[icon_state_edge][direction]")
				edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
				edge_overlay.layer = src.layer + (src.edge_priority_level / 1000)
				edge_overlay.plane = PLANE_FLOOR
				T.AddOverlays(edge_overlay, "edge_[direction]")

/turf/simulated/floor/auto/grass/swamp_grass
	name = "swamp grass"
	desc = "Grass. In a swamp. Truly fascinating."
	icon = 'icons/turf/forest.dmi'
	icon_state = "grass1"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS
	icon_state_edge = "grassedge"

	New()
		. = ..()
		src.icon_state = "grass[rand(1,9)]"

/turf/simulated/floor/auto/grass/leafy
	name = "grass"
	desc = "some leafy grass."
	icon = 'icons/turf/outdoors.dmi'
#ifdef SEASON_AUTUMN
	icon_state = "grass_leafy_autumn"
	icon_state_edge = "leafy_edge_autumn"
#else
	icon_state = "grass_leafy"
	icon_state_edge = "grass_leafyedge"
#endif
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS - 1

/turf/simulated/floor/auto/dirt
	name = "dirt"
	desc = "earth."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "dirt"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT
	icon_state_edge = "dirtedge"

/turf/simulated/floor/auto/sand
	name = "sand"
	desc = "finest earth."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand_other"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT + 1
	icon_state_edge = "sand_edge"
	var/tuft_prob = 2

	New()
		..()
		src.set_dir(pick(cardinal))

		if(prob(tuft_prob))
			var/rand_x = rand(-5,5)
			var/rand_y = rand(-5,5)
			var/image/tuft
			var/hue_shift = rand(80,95)

			tuft = image('icons/turf/outdoors.dmi', "grass_tuft", src, pixel_x=rand_x, pixel_y=rand_y)
			tuft.color = hsv_transform_color_matrix(h=hue_shift)
			AddOverlays(tuft,"grass_turf")

	rough
		tuft_prob = 0.8
		New()
			..()
			icon_state_edge = "sand_r_edge"
			edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT + 2
			switch(rand(1,3))
				if(1)
					icon_state = "sand_other_texture"
					src.set_dir(pick(alldirs))
				if(2)
					icon_state = "sand_other_texture2"
					src.set_dir(pick(alldirs))
				if(3)
					icon_state = "sand_other_texture3"


/turf/simulated/floor/auto/water
	name = "water"
	desc = "Who knows what could be hiding in there."
	icon = 'icons/turf/water.dmi'
	icon_state = "swamp0"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_WATER
	icon_state_edge = "swampedge"

	New()
		. = ..()
		if (prob(8))
			src.icon_state = "swamp[rand(1, 4)]"


TYPEINFO(/turf/simulated/floor/auto/water/ice)
	mat_appearances_to_ignore = list("ice")
/turf/simulated/floor/auto/water/ice
	name = "ice"
	desc = "Frozen water."
	icon = 'icons/turf/water.dmi'
	icon_state = "ice"
	icon_state_edge = "ice_edge"
	default_material = "ice"
	mat_changename = FALSE

/turf/simulated/floor/auto/water/ice/rough
	name = "ice"
	desc = "Rough frozen water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "ice1"

	New()
		..()
		src.icon_state = "ice[rand(1, 6)]"

	edge_overlays()
		return

/turf/simulated/floor/auto/swamp
	name = "swamp"
	desc = "Who knows what could be hiding in there."
	icon = 'icons/turf/water.dmi'
	icon_state = "swamp0"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_WATER
	icon_state_edge = "swampedge"

	New()
		. = ..()
		if (prob(10))
			src.icon_state = "swamp_decor[rand(1, 10)]"
		else
			src.icon_state = "swamp0"

/turf/simulated/floor/auto/swamp/rain
	New()
		. = ..()
		var/image/R = image('icons/turf/water.dmi', "ripple", dir=pick(alldirs),pixel_x=rand(-10,10),pixel_y=rand(-10,10))
		R.alpha = 180
		src.AddOverlays(R, "ripple")

/turf/simulated/floor/auto/snow
	name = "snow"
	desc = "Snow. Soft and fluffy."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow1"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS + 1
	icon_state_edge = "snow_edge"
	step_material = "step_snow"
	step_priority = STEP_PRIORITY_MED

	New()
		. = ..()
		if(src.type == /turf/simulated/floor/auto/snow && prob(10))
			src.icon_state = "snow[rand(1,5)]"

	Uncrossed(atom/movable/AM)
		. = ..()
		src.snow_prints(AM)

/turf/simulated/floor/auto/snow/rough
	name = "snow"
	desc = "some piled snow."
	icon =  'icons/turf/snow.dmi'
	icon_state = "snow_rough1"
	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_GRASS + 2
	icon_state_edge = "snow_r_edge"

	New()
		. = ..()
		if(prob(10))
			src.icon_state = "snow_rough[rand(1,3)]"

/turf/simulated/floor/swampgrass
	name = "reedy grass"
	desc = ""
	icon = 'icons/misc/worlds.dmi'
	icon_state = "swampgrass"

	New()
		..()
		set_dir(pick(1,2,4,8))
		return

/turf/simulated/floor/swampgrass_edging
	name = "reedy grass"
	desc = ""
	icon = 'icons/misc/worlds.dmi'
	icon_state = "swampgrass_edge"

TYPEINFO(/turf/simulated/floor/auto/glassblock)
	mat_appearances_to_ignore = list("steel","synthrubber","glass")
	connect_diagonal = 1

//dont use please
/turf/simulated/floor/auto/glassblock
	name = "glass block tiling"
	step_material = "step_wood"
	step_priority = STEP_PRIORITY_MED
	mat_changename = FALSE
	can_burn = FALSE
	can_break = FALSE
	icon_state = "glass-0"
	mod = "glass-"
	default_material = "glass"
	var/static/image/starlight

	New()
		..()
		#ifndef CI_RUNTIME_CHECKING
		var/image/I
		#ifdef UNDERWATER_MAP
		var/sand_icon
		var/direction
		switch(rand(1, 3))
			if(1)
				sand_icon = "sand_other_texture"
				direction = pick(alldirs)
			if(2)
				sand_icon = "sand_other_texture2"
				direction = pick(alldirs)
			if(3)
				sand_icon = "sand_other_texture3"
				direction = pick(cardinal)
		I = image('icons/turf/outdoors.dmi', sand_icon, dir = direction)
		#else
		src.underlays += /turf/space::starlight
		I = mutable_appearance('icons/turf/space.dmi', "[rand(1, 25)]")
		I.color = /turf/space::space_color
		#endif
		I.plane = PLANE_SPACE
		src.underlays += I
		#endif

	pry_tile(obj/item/C as obj, mob/user as mob, params)
		boutput(user, SPAN_ALERT("This is glass flooring, you can't pry this up!"))

	to_plating()
		return

	break_tile_to_plating()
		return

	break_tile()
		return

	// unburnable, otherwise floorbots use steel sheets for repair which doesn't make sense
	burn_tile()
		return

	attackby(obj/item/C, mob/user, params)
		if (istype(C, /obj/item/rods))
			boutput(user, SPAN_ALERT("You can't reinforce this tile."))
			return
		if(istype(C, /obj/item/cable_coil))
			boutput(user, SPAN_ALERT("You can't put cable over this tile, it would be too exposed."))
			return
		..()

TYPEINFO(/turf/simulated/floor/auto/glassblock/grey)
TYPEINFO_NEW(/turf/simulated/floor/auto/glassblock/grey)
	. = ..()
	connects_to = typecacheof(/turf/simulated/floor/auto/glassblock/grey)
/turf/simulated/floor/auto/glassblock/grey
	icon = 'icons/turf/glass_floors/grey_glass_floor_auto.dmi'

TYPEINFO(/turf/simulated/floor/auto/glassblock/cyan)
TYPEINFO_NEW(/turf/simulated/floor/auto/glassblock/cyan)
	. = ..()
	connects_to = typecacheof(/turf/simulated/floor/auto/glassblock/cyan)
/turf/simulated/floor/auto/glassblock/cyan
	icon = 'icons/turf/glass_floors/cyan_glass_floor_auto.dmi'

TYPEINFO(/turf/simulated/floor/auto/glassblock/indigo)
TYPEINFO_NEW(/turf/simulated/floor/auto/glassblock/indigo)
	. = ..()
	connects_to = typecacheof(/turf/simulated/floor/auto/glassblock/indigo)
/turf/simulated/floor/auto/glassblock/indigo
	icon = 'icons/turf/glass_floors/indigo_glass_floor_auto.dmi'

TYPEINFO(/turf/simulated/floor/auto/glassblock/red)
TYPEINFO_NEW(/turf/simulated/floor/auto/glassblock/red)
	. = ..()
	connects_to = typecacheof(/turf/simulated/floor/auto/glassblock/red)
/turf/simulated/floor/auto/glassblock/red
	icon = 'icons/turf/glass_floors/red_glass_floor_auto.dmi'

TYPEINFO(/turf/simulated/floor/auto/glassblock/purple)
TYPEINFO_NEW(/turf/simulated/floor/auto/glassblock/purple)
	. = ..()
	connects_to = typecacheof(/turf/simulated/floor/auto/glassblock/purple)
/turf/simulated/floor/auto/glassblock/purple
	icon = 'icons/turf/glass_floors/purple_glass_floor_auto.dmi'


/turf/unsimulated/floor/pool
	mat_changename = FALSE
	mat_changedesc = FALSE
	name = "water"
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/unsimulated/floor/pool/no_animate
	name = "pool floor"
	icon_state = "poolwaterfloor_static"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/simulated/floor/pool
	mat_changename = FALSE
	mat_changedesc = FALSE
	name = "water"
	icon_state = "poolwaterfloor"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

/turf/simulated/floor/pool/no_animate
	name = "pool floor"
	icon_state = "poolwaterfloor_static"

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))

// Material flooring

DEFINE_FLOORS(mauxite,
	icon = 'icons/turf/floors.dmi';\
	icon_state = "floor$$mauxite";\
	default_material = "mauxite";\
	uses_default_material_appearance = TRUE)

DEFINE_FLOORS(bamboo,
	icon = 'icons/turf/floors.dmi';\
	icon_state = "floor$$bamboo";\
	default_material = "bamboo";\
	uses_default_material_appearance = TRUE)
