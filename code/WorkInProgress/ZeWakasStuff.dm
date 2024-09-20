/*
 * 90 101 87 97 107 97 39 115 83 116 117 102 102
 */

//foo 49: bodacious grandiose bargaloo mambo prime preceed wow github cdn sub jekyll docs rsc ci2 rename profile rat tgui guh mord map


/* 514 checklist
	?[] experimentation perhaps
	make some lib animate stuff better with spaces? (better rainbow anyone?)
	particle abuse
*/

/*
515 stuff

world.Tick
client.RenderIcon
pragmas?
noise_hash()
get_steps_to
refcount
list.removeall
animation delay?
sound pitch, offset, sound end
basic sound end example sound.params
sound time adjustment, SOUND_UPDATE offset var, query with query
atoms can be rendered by reference in browser
*/

// find lagging shitters
// for\(var/([\w/]*)\)

// /client/verb/grab_all_lists()
//     set category = "Debug"
//     set name = "Get all lists"

//     var/list/all_lists_heap = list("No length" = 0)
//     var/list/all_lists_joined = list()
//     for(var/list/thing)
//         if(!length(thing))
//             all_lists_heap["No length"]++
//         else if(all_lists_heap["[thing[1]]"])
//             all_lists_heap["[thing[1]]"]++
//         else
//             all_lists_heap["[thing[1]]"] += 1

//     sortList(all_lists_heap, cmp = GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE)

//     for(var/thing in all_lists_heap)
//         all_lists_joined += "<br>[thing], count: [all_lists_heap[thing]]</br>\n"
//     usr << browse(all_lists_joined.Join(), "window=listlog")


// playsound\(([^,]*), "(sound/[^\[]+)"
// playsound($1, '$2'
// Greek Adventurezone Thingy

/turf/unsimulated/greek
	name = "Greek Adventurezone Sprites"
	icon = 'icons/turf/adventure_gannets.dmi'

/turf/unsimulated/wall/greek
	name = "Greek Adventurezone Sprites"
	icon = 'icons/turf/adventure_gannets.dmi'

/area/greek
	skip_sims = 1
	sims_score = 30

// Beach zone Stuff

/area/greek/beach
	name = "Strange Beach"
	icon_state = "yellow"
	force_fullbright = 1
	sound_environment = 19

/turf/unsimulated/greek/grass
	name = "grass"
	desc = "Some bright green grass on the ground."
	icon_state = "grass"

/obj/fakeobject/greekgrass
	name = "grass"
	icon = 'icons/turf/adventure_gannets.dmi'
	icon_state = "grass"
	mouse_opacity = 0

	curve
		icon_state = "grass-curve"
	diag
		icon_state = "grass-diag"

/turf/unsimulated/greek/beach
	name = "beach"
	desc = "A very strange beach, almost artificial somehow."
	icon_state = "sand"

	curve
		icon_state = "beach-curve"
	bodge //yes, i needed this
		icon_state = "island-1"

/turf/unsimulated/greek/water
	name = "water"
	desc = "Splish splash, it's water."
	icon_state = "water"

// Cave Stuff

/area/greek/caves
	name = "Strange Caves"
	icon_state = "green"
	sound_environment = 8

/area/greek/cliffs
	name = "Strange Cliffs"
	icon_state = "blue"
	sound_environment = 8
	force_fullbright = 1

/turf/unsimulated/greek/cave
	name = "rock"
	desc = "A rocky floor, carved from the cave."
	icon_state = "rock-floor"

	floor
		icon_state = "cave-floor"

	rockwall
		icon_state = "rock-wall"

/turf/unsimulated/wall/greek/cave //flat rock wall
	name = "rock"
	desc = "A flat rocky surface."
	icon_state = "rock"

/obj/greek/rockwall //the rocky cliff objects
	name = "rocky cliff"
	desc = "A sharp cliff face formed by rocks"
	icon = 'icons/turf/adventure_gannets.dmi'
	icon_state = "cave-wall"
	anchored = ANCHORED
	density = 1
	opacity = 1

	alt
		icon_state = "cave-wall-2"

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/fakeobject/rockpile //small rock pile decor
	name = "rock pile"
	desc = "Some rocks that tumbled off of the cliff walls."
	icon = 'icons/turf/adventure_gannets.dmi'
	icon_state = "smallrock"

	big
		icon_state = "bigrock"

/obj/critter/cyclops
	name = "cyclops"
	real_name = "cyclops"
	desc = "The Eye stares straight into your soul. Creepy."
	icon = 'icons/mob/critter/humanoid/cyclops.dmi'
	icon_state = "greek-cyclops"
	density = 1
	health = 70
	wanderer = 0
	aggressive = 1
	defensive = 1
	atkcarbon = 1
	atksilicon = 1

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message(SPAN_COMBAT("<b>[src]</b> charges at [C:name]!"))
				playsound(src.loc, 'sound/voice/MEraaargh.ogg', 40, 0)
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		src.visible_message(SPAN_COMBAT("<B>[src]</B> viciously lunges at [M]!"))
		if (prob(20)) M.changeStatus("stunned", 2 SECONDS)
		random_brute_damage(M, rand(5,20),1)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message(SPAN_COMBAT("<B>[src]</B> bites [src.target] viciously!"))
		random_brute_damage(src.target, rand(5,15),1)
		SPAWN(1 SECOND)
			src.attacking = 0

// Underworld Stuff

/area/greek/underworld
	name = "Strange Depths"
	icon_state = "purple"
	sound_environment = 25

/area/greek/underworld/pit
	icon_state = "white"

/turf/unsimulated/greek/underworld
	name = "brick"
	desc = "Some old and strange weathered bricks, with a bit of dust for good measure."
	icon_state = "under-floor"

	half
		icon_state = "under-halfwall"

/turf/unsimulated/wall/greek/underwall
	name = "brick"
	desc = "A sharp wall composed of old funky bricks."
	icon_state = "under-wall"

/turf/unsimulated/greek/pit
	name = "darkness"
	desc = "You can't see the bottom."
	icon_state = "pit"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0
	pathable = 0

	New()
		. = ..()
		src.AddComponent(/datum/component/pitfall/target_landmark,\
			BruteDamageMax = 50,\
			FallTime = 0 SECONDS,\
			TargetLandmark = LANDMARK_FALL_GREEK)

// Misc Stuff

/obj/decal/lightshaft/rainbow
	name = "rainbow"
	desc = "Oh wow, you finally found the end of the rainbow."
	icon_state = "rainbow"


//th3*vqoE
