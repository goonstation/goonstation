
var/global/list/list/turf/landmarks = list()

proc/pick_landmark(name, default=null)
	if(!(name in landmarks))
		return default
	return pick(landmarks[name])

/obj/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = 101
	var/deleted_on_start = TRUE
	var/add_to_landmarks = TRUE
	var/data = null // data to associatively save with the landmark
	var/name_override = null

	ex_act()
		return

/obj/landmark/New()
	if(src.add_to_landmarks)
		if(!landmarks)
			landmarks = list()
		var/name = src.name_override ? src.name_override : src.name
		if(!landmarks[name])
			landmarks[name] = list()
		landmarks[name][src.loc] = src.data
	if(src.deleted_on_start)
		qdel(src)
	else
		..()

var/global/list/job_start_locations = list()

/obj/landmark/start
	name = "start"
	icon_state = "x"
	add_to_landmarks = FALSE

	New()
		if (job_start_locations)
			if (!islist(job_start_locations[src.name]))
				job_start_locations[src.name] = list(src.loc)
			else
				job_start_locations[src.name] += src.loc
		..()

// actual landmarks follow
// most of these are here just for backwards compatibility

/obj/landmark/start/latejoin
	name = LANDMARK_LATEJOIN
	add_to_landmarks = TRUE

/obj/landmark/cruiser_entrance
	name = LANDMARK_CRUISER_ENTRANCE

/obj/landmark/escape_pod_succ
	name = LANDMARK_ESCAPE_POD_SUCCESS
	icon_state = "xp"
	New()
		src.data = src.dir // save dir
		..()

/obj/landmark/tutorial_start
	name = LANDMARK_TUTORIAL_START

/obj/landmark/halloween
	name = LANDMARK_HALLOWEEN_SPAWN

/obj/landmark/asteroid_spawn_blocker //Blocks the creation of an asteroid on this tile, as you would expect
	name = "asteroid blocker"
	icon_state = "x4"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

/obj/landmark/magnet_center
	name = LANDMARK_MAGNET_CENTER
	icon_state = "x"

/obj/landmark/magnet_shield
	name = LANDMARK_MAGNET_SHIELD
	icon_state = "x"

/obj/landmark/latejoin_missile
	name = "missile latejoin spawn marker"
	name_override = LANDMARK_LATEJOIN_MISSILE
	icon_state = "x"
	dir = NORTH

	New()
		src.data = src.dir // save dir
		..()
	north
		name = "missile latejoin spawn marker (north)"
		dir = NORTH

/obj/landmark/ass_arena_spawn
	name = LANDMARK_ASS_ARENA_SPAWN
	icon_state = "x"

/obj/landmark/interesting
	// Use this to place cryptic clues to be picked up by the T-ray, because trying to remember which floortile you varedited is shit. For objects and mobs, just varedit.
	name = "Interesting turf spawner"
	desc = "Sets the var/interesting of the target turf, then deletes itself"
	interesting = ""
	add_to_landmarks = FALSE

	New() //use initialize() later and test ok
		var/turf/T = src.loc
		T.interesting = src.interesting
		..()

/obj/landmark/artifact
	name = LANDMARK_ARTIFACT_SPAWN
	icon_state = "x3"
	var/spawnchance = 100 // prob chance out of 100 to spawn artifact at game start
	New()
		src.data = src.spawnchance
		..()

/obj/landmark/spawner
	name = "spawner"
	add_to_landmarks = FALSE
	deleted_on_start = FALSE
	var/type_to_spawn = null
	var/spawnchance = 100
	var/static/list/name_to_type = list(
		"shitty_bill" = /mob/living/carbon/human/biker,
		"john_bill" = /mob/living/carbon/human/john,
		"big_yank" = /mob/living/carbon/human/big_yank,
		"father_jack" = /mob/living/carbon/human/fatherjack,
		"don_glab" = /mob/living/carbon/human/don_glab,
		"monkeyspawn_normal" = /mob/living/carbon/human/npc/monkey,
		"monkeyspawn_albert" = /mob/living/carbon/human/npc/monkey/albert,
		"monkeyspawn_rathen" = /mob/living/carbon/human/npc/monkey/mr_rathen,
		"monkeyspawn_mrmuggles" = /mob/living/carbon/human/npc/monkey/mr_muggles,
		"monkeyspawn_mrsmuggles" = /mob/living/carbon/human/npc/monkey/mrs_muggles,
		"monkeyspawn_syndicate" = /mob/living/carbon/human/npc/monkey/von_braun,
		"monkeyspawn_horse" = /mob/living/carbon/human/npc/monkey/horse,
		"monkeyspawn_krimpus" = /mob/living/carbon/human/npc/monkey/krimpus,
		"monkeyspawn_tanhony" = /mob/living/carbon/human/npc/monkey/tanhony,
		"monkeyspawn_stirstir" = /mob/living/carbon/human/npc/monkey/stirstir,
		"seamonkeyspawn" = /mob/living/carbon/human/npc/monkey/sea,
		"seamonkeyspawn_gang" = /mob/living/carbon/human/npc/monkey/sea/gang,
		"seamonkeyspawn_gang_gun" = /mob/living/carbon/human/npc/monkey/sea/gang_gun,
		"seamonkeyspawn_rich" = /mob/living/carbon/human/npc/monkey/sea/rich,
		"seamonkeyspawn_lab" = /mob/living/carbon/human/npc/monkey/sea/lab,
		"waiter" = /mob/living/carbon/human/waiter,
		"monkeyspawn_inside" = /mob/living/carbon/human/npc/monkey
	)

	New()
		if(current_state >= GAME_STATE_WORLD_INIT && prob(spawnchance))
			SPAWN_DBG(6 SECONDS) // bluh, replace with some `initialize` variant later when someone makes it (needs to work with dmm loader)
				initialize()
		..()

	initialize()
		if(prob(spawnchance))
			spawn_the_thing()
		..()

	proc/spawn_the_thing()
		if(isnull(src.type_to_spawn))
			src.type_to_spawn = name_to_type[src.name]
		if(isnull(src.type_to_spawn))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		new type_to_spawn(src.loc)
		qdel(src)

/obj/landmark/spawner/inside
	New()
		var/obj/storage/S = locate() in src.loc
		src.set_loc(S)
		..()

/obj/landmark/spawner/inside/monkey
	name = "monkeyspawn_inside"

/obj/landmark/spawner/loot
	name = "Loot spawn"
	type_to_spawn = /obj/storage/crate/loot
	spawnchance = 75

// LONG RANGE TELEPORTER
// consider refactoring to be associative the other way around later

/obj/landmark/lrt //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name = "lrt landmark"
	name_override = LANDMARK_LRT

	New()
		src.data = src.name // store name
		..()

/obj/landmark/lrt/gemv
	name = "Geminorum V"

/obj/landmark/lrt/workshop
	name = "Hidden Workshop"
