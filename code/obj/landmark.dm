
var/global/list/landmarks = list()

/obj/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	invisibility = 101
	var/deleted_on_start = 0

	ex_act()
		return

/obj/landmark/cruiser_entrance

/obj/landmark/alterations
	name = "alterations"

/obj/landmark/miniworld
	name = "worldsetup"
	var/id = 0

/obj/landmark/escape_pod_succ
	name = "escape_pod_success"
	icon_state = "xp"

/obj/landmark/miniworld/w1

/obj/landmark/miniworld/w2

/obj/landmark/miniworld/w3

/obj/landmark/miniworld/w4

/obj/landmark/New()
	..()
	src.tag = "landmark*[src.name]"
	//src.invisibility = 101

	switch(src.name)
		if ("monkey")
			monkeystart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("start")
			newplayer_start += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("wizard")
			wizardstart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("hunter")
			predstart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("Syndicate-Spawn")
			syndicatestart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("SR Syndicate-Spawn")
			syndicatestart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("JoinLate")
			latejoin += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("Observer-Start")
			observer_start += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("shitty_bill")
			SPAWN_DBG(3 SECONDS)
				new /mob/living/carbon/human/biker(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("john_bill")
			SPAWN_DBG(3 SECONDS)
				new /mob/living/carbon/human/john(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("big_yank")
			SPAWN_DBG(3 SECONDS)
				new /mob/living/carbon/human/big_yank(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("shitty_bill_respawn")
#ifdef TWITCH_BOT_ALLOWED
			billspawn += src.loc
#endif
			deleted_on_start = 1
			qdel(src)


		if ("father_jack")
			SPAWN_DBG(3 SECONDS)
				new /mob/living/carbon/human/fatherjack(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("don_glab")
			SPAWN_DBG(3 SECONDS)
				new /mob/living/carbon/human/don_glab(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_normal")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_inside")
			SPAWN_DBG(6 SECONDS)
				var/obj/storage/S = locate() in src.loc
				new /mob/living/carbon/human/npc/monkey(S)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_albert")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/albert(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_rathen")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/mr_rathen(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_mrmuggles")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/mr_muggles(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_mrsmuggles")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/mrs_muggles(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_syndicate")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/von_braun(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_horse")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/horse(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_krimpus")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/krimpus(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_tanhony")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/tanhony(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("monkeyspawn_stirstir")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/stirstir(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("seamonkeyspawn")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/sea(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("seamonkeyspawn_gang")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/sea/gang(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("seamonkeyspawn_gang_gun")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/sea/gang_gun(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("seamonkeyspawn_rich")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/sea/rich(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("seamonkeyspawn_lab")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/npc/monkey/sea/lab(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("waiter")
			SPAWN_DBG(6 SECONDS)
				new /mob/living/carbon/human/waiter(src.loc)
				deleted_on_start = 1
				qdel(src)

		if ("Clown")
			clownstart += src.loc
			//dispose()

		//prisoners
		if ("prisonwarp")
			prisonwarp += src.loc
			deleted_on_start = 1
			qdel(src)
		//if ("mazewarp")
		//	mazewarp += src.loc
		if ("tdome1")
			tdome1	+= src.loc
		if ("tdome2")
			tdome2 += src.loc
		//not prisoners
		if ("prisonsecuritywarp")
			prisonsecuritywarp += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("blobstart")
			blobstart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("kudzustart")
			kudzustart += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("telesci")
			telesci += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("icefall")
			icefall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("polarisfall")
			polarisfall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("deepfall")
			deepfall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("ancientfall")
			ancientfall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("greekfall")
			greekfall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("iceelefall")
			iceelefall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("bioelefall")
			bioelefall += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("moonfall_hemera")
			moonfall_hemera += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("moonfall_museum")
			moonfall_museum += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("samostrel")
			samostrel_warps += src.loc
			deleted_on_start = 1
			qdel(src)

		if ("seafall")
			seafall += src.loc
			deleted_on_start = 1
			qdel(src)

		if("escape_pod_success")
			escape_pod_success += src

		if("battle-royale-spawn")
			battle_royale_spawn += src.loc
			deleted_on_start = 1
			qdel(src)

	if (!deleted_on_start)
		if (!islist(landmarks))
			landmarks = list()
		landmarks.Add(src)

	return 1

/obj/landmark/disposing()
	if (!deleted_on_start && islist(landmarks))
		landmarks.Remove(src)
	..()

var/global/list/job_start_locations = list()

/obj/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

	New()
		..()
		src.tag = "start*[src.name]"
		if (job_start_locations)
			if (!islist(job_start_locations[src.name]))
				job_start_locations[src.name] = list(src)
			else
				job_start_locations[src.name] += src
		//src.invisibility = 101

	disposing()
		job_start_locations[src.name] -= src
		..()

/obj/landmark/start/latejoin
	name = "JoinLate"

/obj/landmark/tutorial_start
	name = "Tutorial Start Marker"

/obj/landmark/asteroid_spawn_blocker //Blocks the creation of an asteroid on this tile, as you would expect
	name = "asteroid blocker"
	icon_state = "x4"

/obj/landmark/magnet_center
	name = "magnet center"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/landmark/magnet_shield
	name = "magnet shield"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/landmark/block_waypoint
	name = "anti-nullspace waypoint"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1
	shuttle
		name = "shuttle anti-nullspace waypoint"

/obj/landmark/latejoin_missile
	name = "missile latejoin spawn marker"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1
	dir = NORTH

	New()
		//FFFUCK the parent has no framework for a landmark that is both a latejoin and should not be deleted immediately
		src.tag = "landmark*[src.name]"

		latejoin += src.loc
		deleted_on_start = 1

		if (!islist(landmarks))
			landmarks = list()
		landmarks.Add(src)


	north
		name = "missile latejoin spawn marker (north)"
		dir = NORTH

/obj/landmark/ass_arena_spawn
	name = "ass_arena_spawn"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1

	New()
		..()
		ass_arena_spawn.Add(src)

obj/landmark/interesting
	// Use this to place cryptic clues to be picked up by the T-ray, because trying to remember which floortile you varedited is shit. For objects and mobs, just varedit.
	name = "Interesting turf spawner"
	desc = "Sets the var/interesting of the target turf, then deletes itself"
	interesting = ""

	New() //use initialize() later and test ok
		..()
		SPAWN_DBG(1 DECI SECOND)
			src.setup()
			SPAWN_DBG(1 SECOND)
				qdel(src)

	proc/setup()
		var/turf/T = src.loc
		T.interesting = src.interesting

obj/landmark/lrt //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name = "lrt landmark"
	var/turf/held_turf = null //a reference to the turf its on

	New()
		..()
		if (get_turf(src))
			src.held_turf = get_turf(src)

/obj/landmark/lrt/gemv
	name = "Geminorum V"

/obj/landmark/lrt/workshop
	name = "Hidden Workshop"
