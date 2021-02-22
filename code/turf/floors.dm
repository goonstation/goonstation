/*
 * Hey! You!
 * Remember to mirror your changes (unless you use the [DEFINE_FLOORS] macro)
 * floors_unsimulated.dm & floors_airless.dm
 */


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
	layer = PLATING_LAYER

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


/////////////////////////////////////////

/turf/simulated/floor/darkblue
	icon_state = "fulldblue"

/turf/simulated/floor/darkblue/checker
	icon_state = "blue-dblue"

/turf/simulated/floor/darkblue/checker/other
	icon_state = "blue-dblue2"

/////////////////////////////////////////

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

/////////////////////////////////////////



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

/////////////////////////////////////////

/turf/simulated/floor/escape
	icon_state = "escape"

/turf/simulated/floor/escape/corner
	icon_state = "escapecorner"

/////////////////////////////////////////

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

/turf/simulated/floor/grasstodirt
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "grasstodirt"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0

/turf/simulated/floor/dirt
	name = "dirt"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "dirt"
	mat_appearances_to_ignore = list("steel","synthrubber")
	mat_changename = 0
	mat_changedesc = 0

/////////////////////////////////////////

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-FUCK THAT SHIT MY WRIST HURTS=-=-=-=-=-=-=-=-=*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

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
