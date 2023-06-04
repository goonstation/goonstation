
var/global/list/list/turf/landmarks = list()

proc/pick_landmark(name, default=null)
	if(!(name in landmarks))
		return default
	return pick(landmarks[name])

/obj/landmark
	name = "landmark"
	icon = 'icons/map-editing/landmarks.dmi'
	icon_state = "x2"
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS
	var/deleted_on_start = TRUE
	var/add_to_landmarks = TRUE
	var/data = null // data to associatively save with the landmark
	var/name_override = null

	ex_act()
		return

/obj/landmark/proc/init(delay_qdel=FALSE)
	if(src.add_to_landmarks)
		if(src.name == "landmark")
			CRASH("Landmark [src] at [log_loc(src)] has no name override!")
		if(!landmarks)
			landmarks = list()
		var/name = src.name_override ? src.name_override : src.name
		if(!landmarks[name])
			landmarks[name] = list()
		landmarks[name][src.loc] = src.data
	if(src.deleted_on_start)
		if(delay_qdel)
			SPAWN(0)
				qdel(src)
		else
			qdel(src)

/obj/landmark/New()
	..()
	if(current_state > GAME_STATE_MAP_LOAD)
		src.init(delay_qdel=TRUE)
	else
		src.init()

var/global/list/job_start_locations = list()

/obj/landmark/start
	name = "start"
	icon_state = "player-start"
	add_to_landmarks = FALSE
	var/static/list/aliases = list(
		"Mechanic" = "Engineer"
	)

	init(delay_qdel=FALSE)
		if(src.name in src.aliases)
			src.name = src.aliases[src.name]
		if (job_start_locations)
			if (!islist(job_start_locations[src.name]))
				job_start_locations[src.name] = list(src.loc)
			else
				job_start_locations[src.name] += src.loc
		..()

// actual landmarks follow
// most of these are here just for backwards compatibility

/obj/landmark/start/latejoin
	icon_state = "latejoin"
	name = LANDMARK_LATEJOIN
	add_to_landmarks = TRUE

/obj/landmark/cruiser_entrance
	name = LANDMARK_CRUISER_ENTRANCE

/obj/landmark/cruiser_center
	name = LANDMARK_CRUISER_CENTER

/obj/landmark/escape_pod_succ
	name = LANDMARK_ESCAPE_POD_SUCCESS
	icon_state = "xp"

	New()
		src.data = src.dir
		..()

	north
		dir = NORTH

	south
		dir = SOUTH

	east
		dir = EAST

	west
		dir = WEST

/obj/landmark/tutorial_start
	name = LANDMARK_TUTORIAL_START

/obj/landmark/shuttle_transit
	name= LANDMARK_SHUTTLE_TRANSIT

/obj/landmark/halloween
	name = LANDMARK_HALLOWEEN_SPAWN

/obj/landmark/asteroid_spawn_blocker //Blocks the creation of an asteroid on this tile, as you would expect
	name = "asteroid blocker"
	icon_state = "x4"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

/obj/landmark/magnet_center
	name = LANDMARK_MAGNET_CENTER
	icon_state = "magnet-center"
	var/width = 15
	var/height = 15
	var/obj/machinery/mining_magnet/magnet

	New()
		var/turf/T = locate(src.x-round(width/2), src.y-round(height/2), src.z)
		var/obj/magnet_target_marker/M = new /obj/magnet_target_marker(T)
		M.width = src.width
		M.height = src.height
		..()

/obj/landmark/magnet_shield
	name = LANDMARK_MAGNET_SHIELD
	icon_state = "magnet-shield"

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
	icon_state = "artifact-spawn"
	var/spawnchance = 100 // prob chance out of 100 to spawn artifact at game start
	New()
		src.data = src.spawnchance
		..()

	random_room
		name = LANDMARK_RANDOM_ROOM_ARTIFACT_SPAWN

		New()
			if (prob(src.spawnchance))
				Artifact_Spawn(get_turf(src))
			..()

/obj/landmark/spawner
	name = "spawner"
	add_to_landmarks = FALSE
	deleted_on_start = FALSE
	var/type_to_spawn = null
	var/spawnchance = 100
	var/static/list/name_to_type = list(
		"juicer_gene" = /mob/living/carbon/human/geneticist,
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
		"monkeyspawn_syndicate" = /mob/living/carbon/human/npc/monkey/oppenheimer,
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
		"monkeyspawn_inside" = /mob/living/carbon/human/npc/monkey,
		"dolly" = /mob/living/critter/small_animal/ranch_base/sheep/white/dolly/ai_controlled
	)

	New()
		if(current_state >= GAME_STATE_WORLD_INIT && prob(spawnchance) && !src.disposed)
			SPAWN(6 SECONDS) // bluh, replace with some `initialize` variant later when someone makes it (needs to work with dmm loader)
				if(!src.disposed)
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

		#ifdef BAD_MONKEY_NO_BANANA
		if (findtext("[src.type_to_spawn]", "monkey")) //ugly
			qdel(src)
			return
		#endif

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
	spawnchance = 10

/obj/landmark/spawner/corpse // For critters
	name = "Corpse Spawn"
	type_to_spawn = null // Type path to spawn
	spawnchance = 100
	var/container_type = null // Container path such as a locker or crate is spawned with the corpse

	spawn_the_thing()
		if(isnull(src.type_to_spawn))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		var/mob/living/M = new type_to_spawn(src.loc)
		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			M.set_loc(container)
		M.death()
		qdel(src)

	jones
		type_to_spawn = /mob/living/critter/small_animal/cat/jones

/obj/landmark/spawner/corpse/human // Human spawner handles some randomisation / customisation
	icon_state = "corpse-human"
	type_to_spawn = /mob/living/carbon/human/normal/assistant
	container_type = null

	var/husked = FALSE
	var/decomp_stage = DECOMP_STAGE_NO_ROT
	var/no_decomp = TRUE // If true we are magically preserved and don't decay
	var/no_miasma = TRUE // If true we emit no miasma since that would kinda suck

	var/random_damage = TRUE // Fuck up the body with lots of damage
	var/random_organ_removal = TRUE

	var/empty_bag = FALSE /// If TRUE we delete the contents of the backpack after spawning
	var/delete_id = FALSE /// If TRUE we delete the ID slot contents after spawning
	var/break_headset = FALSE /// If TRUE we break the headset and make it unscannable after spawning

	spawn_the_thing()
		if (isnull(src.type_to_spawn))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")

		var/mob/living/carbon/human/H = new type_to_spawn(src.loc)

		if (H.slot_l_hand)
			qdel(H.slot_l_hand)
		if (H.slot_r_hand)
			qdel(H.slot_r_hand)

		H.death(FALSE)
		H.decomp_stage = src.decomp_stage
		H.no_decomp = src.no_decomp
		H.no_miasma = src.no_miasma

		if (src.husked)
			H.disfigured = TRUE
			H.UpdateName()
			H.bioHolder.AddEffect("husk")

		if (src.random_damage)
			src.do_damage(H)

		if (src.random_organ_removal)
			for (var/i in 1 to rand(1, 4))
				var/obj/item/organ/organ = H.drop_organ(pick("left_eye","right_eye","left_lung","right_lung","butt","left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas","appendix"))
				qdel(organ)

		if (src.delete_id)
			qdel(H.wear_id)

		if (src.empty_bag)
			if (istype(H.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/backpack = H.back
				for (var/obj/item as anything in backpack)
					qdel(item)
			else if (istype(H.belt, /obj/item/storage/fanny))
				var/obj/item/storage/fanny/fanny = H.belt
				for (var/obj/item as anything in fanny)
					qdel(item)

		if (src.break_headset)
			if (istype(H.ears, /obj/item/device/radio/headset))
				var/obj/item/device/radio/headset/headset = H.ears
				headset.bricked = TRUE
				headset.mechanics_interaction = MECHANICS_INTERACTION_BLACKLISTED // No getting smart

		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			container.update_icon()
			H.set_loc(container)

		qdel(src)

	proc/do_damage(var/mob/living/carbon/human/H) // Override if you want specific damage numbers / types
		H.TakeDamage("all", brute = rand(100, 150), burn = rand(100, 150), tox = rand(40, 80), disallow_limb_loss = TRUE)
		H.take_oxygen_deprivation(rand(250, 300))
		H.update_body()

/obj/landmark/spawner/corpse/human/random
	icon_state = "corpse-human-rand"
	var/static/list/spawns = list(
		/mob/living/carbon/human/normal/assistant = 20,
		/mob/living/carbon/human/normal/miner = 20,
		/mob/living/carbon/human/normal/botanist = 20,
		/mob/living/carbon/human/normal/chef = 10,
		/mob/living/carbon/human/normal/janitor = 10,
		/mob/living/carbon/human/normal/clown = 5,
		/mob/living/carbon/human/normal = 5)

	New()
		type_to_spawn = weighted_pick(spawns)
		..()

/obj/landmark/spawner/corpse/human/random/body_bag
	container_type = /obj/item/body_bag

	New()
		decomp_stage = rand(DECOMP_STAGE_NO_ROT, DECOMP_STAGE_DECAYED)
		no_decomp = FALSE
		..()

/obj/landmark/spawner/corpse/human/random/webbed
	container_type = /obj/icecube/spider

	clown
		container_type = /obj/icecube/spider/clown

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

/obj/landmark/lrt/voiddiner
	name = "Void Diner"

/obj/landmark/character_preview_spawn
	name = LANDMARK_CHARACTER_PREVIEW_SPAWN

/obj/landmark/tutorial/flock_conversion
	name = LANDMARK_TUTORIAL_FLOCK_CONVERSION

/obj/landmark/viscontents_spawn
	name = "visual mirror spawn"
	desc = "Links a pair of corresponding turfs in holy Viscontent Matrimony. You shouldnt be seeing this."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "landmark"
	color = "#FF0000"
	/// target z-level to push it's contents to
	var/targetZ = 1
	/// x offset relative to the landmark, will cause visual jump effect due to set_loc not gliding
	var/xOffset = 0
	/// /y offset relative to the landmark, will cause visual jump effect due to set_loc not gliding
	var/yOffset = 0
	add_to_landmarks = FALSE
	/// modifier for restricting criteria of what gets warped by mirror
	var/warptarget_modifier = LANDMARK_VM_WARP_ALL
	var/novis = FALSE

	New(var/loc, var/man_xOffset, var/man_yOffset, var/man_targetZ, var/man_warptarget_modifier)
		if (man_xOffset) src.xOffset = man_xOffset
		if (man_yOffset) src.yOffset = man_yOffset
		if (man_targetZ) src.targetZ = man_targetZ
		if (!isnull(man_warptarget_modifier)) src.warptarget_modifier = man_warptarget_modifier
		var/turf/T = get_turf(src)
		if (!T) return
		if(novis)
			var/turf/W = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
			W.warptarget = T
		else
			T.appearance_flags |= KEEP_TOGETHER
			T.vistarget = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
			if (T.vistarget)
				if(warptarget_modifier)
					T.vistarget.warptarget = T
				T.updateVis()
				T.vistarget.fullbright = TRUE
				T.vistarget.RL_Init()
		..()

/obj/landmark/viscontents_spawn/no_vis
	name = "instant hole spawn"
	desc = "Point it at a turf. Stuff that goes there? goes here instead. Got it?"
	novis = TRUE

/obj/landmark/viscontents_spawn/no_warp
	warptarget_modifier = LANDMARK_VM_WARP_NONE
/// target turf for projecting its contents elsewhere
/turf/var/turf/vistarget = null
/// target turf for teleporting its contents elsewhere
/turf/var/turf/warptarget = null
/// control who gets warped to warptarget
/turf/var/turf/warptarget_modifier = null

/turf/proc/updateVis()
	if(vistarget)
		vistarget.overlays.Cut()
		vistarget.vis_contents += src
		var/obj/overlay/tile_effect/lighting/L = locate() in vistarget.vis_contents
		if(L)
			vistarget.vis_contents -= L
