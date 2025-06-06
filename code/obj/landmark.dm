
var/global/list/list/turf/landmarks = list()

proc/pick_landmark(name, default = null, ignorespecific = list())
	if(!(name in landmarks))
		return default
	if (ignorespecific == list())
		return pick(landmarks[name])
	else
		return pick(landmarks[name] - ignorespecific)

/obj/landmark
	name = "landmark"
	icon = 'icons/map-editing/landmarks.dmi'
	icon_state = "x2"
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS
	layer = ABOVE_OBJ_LAYER
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

/* ===== Station Jobs ===== */

/obj/landmark/start/job
	icon = 'icons/map-editing/job_start.dmi'

// Command

/obj/landmark/start/job/captain
	name = "Captain"
	icon_state = "captain"

/obj/landmark/start/job/head_of_personnel
	name = "Head of Personnel"
	icon_state = "head_of_personnel"

/obj/landmark/start/job/head_of_security
	name = "Head of Security"
	icon_state = "head_of_security"

/obj/landmark/start/job/medical_director
	name = "Medical Director"
	icon_state = "medical_director"

/obj/landmark/start/job/research_director
	name = "Research Director"
	icon_state = "research_director"

/obj/landmark/start/job/chief_engineer
	name = "Chief Engineer"
	icon_state = "chief_engineer"

// Civillian

/obj/landmark/start/job/assistant
	name = "Staff Assistant"
	icon_state = "assistant"

/obj/landmark/start/job/clown
	name = "Clown"
	icon_state = "clown"

/obj/landmark/start/job/chef
	name = "Chef"
	icon_state = "chef"

/obj/landmark/start/job/bartender
	name = "Bartender"
	icon_state = "bartender"

/obj/landmark/start/job/botanist
	name = "Botanist"
	icon_state = "botanist"

/obj/landmark/start/job/rancher
	name = "Rancher"
	icon_state = "rancher"

/obj/landmark/start/job/janitor
	name = "Janitor"
	icon_state = "janitor"

/obj/landmark/start/job/chaplain
	name = "Chaplain"
	icon_state = "chaplain"

/obj/landmark/start/job/mail_courier
	name = "Mail Courier"
	icon_state = "mail_courier"

// Engineering

/obj/landmark/start/job/engineer
	name = "Engineer"
	icon_state = "engineer"

/obj/landmark/start/job/technical_trainee
	name = "Technical Trainee"
	icon_state = "engineer"
/obj/landmark/start/job/miner
	name = "Miner"
	icon_state = "miner"

/obj/landmark/start/job/quartermaster
	name = "Quartermaster"
	icon_state = "quartermaster"

// Med/Sci

/obj/landmark/start/job/medical_doctor
	name = "Medical Doctor"
	icon_state = "medical_doctor"

/obj/landmark/start/job/medical_trainee
	name = "Medical Trainee"
	icon_state = "medical_doctor"

/obj/landmark/start/job/geneticist
	name = "Geneticist"
	icon_state = "geneticist"

/obj/landmark/start/job/roboticist
	name = "Roboticist"
	icon_state = "roboticist"

/obj/landmark/start/job/scientist
	name = "Scientist"
	icon_state = "scientist"

/obj/landmark/start/job/research_trainee
	name = "Research Trainee"
	icon_state = "scientist"

// Security
/obj/landmark/start/job/security_officer
	name = "Security Officer"
	icon_state = "security_officer"

/obj/landmark/start/job/security_assistant
	name = "Security Assistant"
	icon_state = "security_assistant"

/obj/landmark/start/job/detective
	name = "Detective"
	icon_state = "detective"

// Silicons
/obj/landmark/start/job/AI
	name = "AI"
	icon_state = "ai"

/obj/landmark/start/job/cyborg
	name = "Cyborg"
	icon_state = "cyborg"

// Gimmick / Job of the day

// Podwars
/obj/landmark/start/job/podwars/NT
	name = "NanoTrasen Pod Pilot"
	icon_state = "pod_nt"

/obj/landmark/start/job/podwars/NT/commander
	name = "NanoTrasen Pod Commander"
	icon_state = "pod_nt_commander"

/obj/landmark/start/job/podwars/syndie
	name = "Syndicate Pod Pilot"
	icon_state = "pod_syndie"

/obj/landmark/start/job/podwars/syndie/commander
	name = "Syndicate Pod Commander"
	icon_state = "pod_syndie_commander"

/* ===== Antagonist Starts ===== */

/obj/landmark/antagonist
	icon = 'icons/map-editing/antag_start.dmi'
	add_to_landmarks = TRUE

// Nuclear Operatives

/obj/landmark/antagonist/operative
	name = LANDMARK_SYNDICATE
	icon_state = "operative"

/obj/landmark/antagonist/operative/commander
	name = LANDMARK_SYNDICATE_BOSS
	icon_state = "commander"

// Pirates

/obj/landmark/antagonist/pirate
	name = LANDMARK_PIRATE
	icon_state = "pirate"

/obj/landmark/antagonist/pirate/first_mate
	name = LANDMARK_PIRATE_FIRST_MATE
	icon_state = "first_mate"

/obj/landmark/antagonist/pirate/captain
	name = LANDMARK_PIRATE_CAPTAIN
	icon_state = "pirate_captain"

// Wizard

/obj/landmark/antagonist/wizard
	name = LANDMARK_WIZARD
	icon_state = "wizard"

// Blob

/obj/landmark/antagonist/blob
	name = LANDMARK_BLOBSTART
	icon_state = "blob"

/* ===== Late Join ===== */

/obj/landmark/start/latejoin
	icon_state = "latejoin"
	name = LANDMARK_LATEJOIN
	add_to_landmarks = TRUE

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

/obj/landmark/latejoin_job
	name = "latejoin spawn marker"
	icon_state = "x"

/obj/landmark/latejoin_job/radio_show_host
	name = "Radio Show Host Spawn"
	name_override = LANDMARK_RADIO_SHOW_HOST_SPAWN

/obj/landmark/latejoin_job/journalist
	name = "Journalist Spawn"
	name_override = LANDMARK_JOURNALIST_SPAWN

/obj/landmark/latejoin_job/actor
	name = "Actor Spawn"
	name_override = LANDMARK_ACTOR_SPAWN

/obj/landmark/latejoin_job/influencer
	name = "Influencer Spawn"
	name_override = LANDMARK_INFLUENCER_SPAWN

/* ===== Misc Spawn/Start ===== */

/obj/landmark/pest
	name = LANDMARK_PESTSTART
	icon_state = "pest_start"

/obj/landmark/observer
	name = LANDMARK_OBSERVER
	icon_state = "observer"

/obj/landmark/kudzu
	name = LANDMARK_KUDZUSTART
	icon_state = "kudzu"

/obj/landmark/arcadevr
	name = LANDMARK_VR_ARCADE
	icon_state = "arcade"

/obj/landmark/bill_spawn
	name = LANDMARK_TWITCHY_BILL_RESPAWN
	icon_state = "bill_spawn"

/obj/landmark/halloween
	name = LANDMARK_HALLOWEEN_SPAWN
	icon_state = "halloween"

/obj/landmark/battle_royale
	name = LANDMARK_BATTLE_ROYALE_SPAWN
	icon_state = "battle_royale"

/obj/landmark/tutorial_start
	name = LANDMARK_TUTORIAL_START
	icon_state = "tutorial_start"

/obj/landmark/ass_arena_spawn
	name = LANDMARK_ASS_ARENA_SPAWN
	icon_state = "x"

/obj/landmark/bubs_job
	name = LANDMARK_BUBS_BEE_JOB
	icon_state = "bubs_job"

/* ===== Misc ===== */

/obj/landmark/cruiser_entrance
	name = LANDMARK_CRUISER_ENTRANCE

/obj/landmark/cruiser_center
	name = LANDMARK_CRUISER_CENTER

/obj/landmark/shuttle_transit
	name = LANDMARK_SHUTTLE_TRANSIT

///emergency shuttle launch sound origin
/obj/landmark/shuttle_subwoofer
	name = LANDMARK_SHUTTLE_SOUND
	icon = 'icons/turf/areas.dmi'
	icon_state = "shuttle_transit_sound"

/obj/landmark/telesci // Allowed turf marker for telesci
	name = LANDMARK_TELESCI
	icon_state = "telesci"

/obj/landmark/samostrel // Hospital chaser warp landmarks
	name = LANDMARK_SAMOSTREL_WARP
	icon_state = "soviet"

/obj/landmark/escape_pod_succ
	name = LANDMARK_ESCAPE_POD_SUCCESS
	icon_state = "escape_pod_succ"

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

/* ===== Spawner ===== */

// TODO REMOVE ALL THIS REPLACE WITH SOMETHING SANE

/obj/landmark/spawner
	name = "spawner"
	add_to_landmarks = FALSE
	deleted_on_start = FALSE
	/// Type this landmark should spawn. Do not edit this on a map instance. Create a subtype.
	var/type_to_spawn = null
	var/spawnchance = 100

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
	type_to_spawn = /mob/living/carbon/human/npc/monkey

/obj/landmark/spawner/loot
	name = "Loot Spawn (10%)"
	icon_state = "loot"
	type_to_spawn = /obj/storage/crate/loot
	spawnchance = 10

/obj/landmark/spawner/artifact
	name = "Artifact Spawn"
	icon_state = "artifact"

	spawn_the_thing()
		Artifact_Spawn(get_turf(src))
		qdel(src)

/obj/landmark/spawner/artifact/one_in_ten
	name = "Artifact Spawn (10%)"
	icon_state = "artifact_10"
	spawnchance = 10

/* ===== LRT Landmarks ===== */

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

/obj/landmark/lrt/icemoon
	name = "Senex"

/obj/landmark/lrt/icemoon2
	name = "Senex II"

/obj/landmark/lrt/solarium
	name = "Sol"

/obj/landmark/lrt/biodome
	name = "Fatuus"

/obj/landmark/lrt/mars_outpost
	name = "Mars"

/obj/landmark/lrt/io
	name = "Io"

/obj/landmark/lrt/luna_museum
	name = "Luna"

/obj/landmark/lrt/ainley
	name = "Ainley Staff Retreat"

/obj/landmark/lrt/meat_derelict
	name = "Derelict Station"

/obj/landmark/lrt/observatory
	name = "Observatory"

/obj/landmark/lrt/watchfuleye
	name = "Watchful-Eye Sensor"

/obj/landmark/icemoon_medal
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	Crossed(atom/movable/AM)
		. = ..()
		var/mob/living/L = AM
		if (istype(L) && !isintangible(L))
			L.unlock_medal("Ice Cold", TRUE)

/obj/landmark/character_preview_spawn
	name = LANDMARK_CHARACTER_PREVIEW_SPAWN

/obj/landmark/tutorial/flock_conversion
	name = LANDMARK_TUTORIAL_FLOCK_CONVERSION
	icon_state = "tutorial"

/* ===== Falling Landmarks ===== */

/obj/landmark/fall
	icon_state = "fall"

// Icemoon

/obj/landmark/fall/ice
	name = LANDMARK_FALL_ICE

/obj/landmark/fall/ice/elevator
	name = LANDMARK_FALL_ICE_ELE

/obj/landmark/fall/ice/deep
	name = LANDMARK_FALL_DEEP

// Biodome

/obj/landmark/fall/biodome
	name = LANDMARK_FALL_BIO_ELE

/obj/landmark/fall/biodome/ancient
	name = LANDMARK_FALL_ANCIENT

// Underwater

/obj/landmark/fall/sea/elevator
	name = LANDMARK_FALL_SEA

/obj/landmark/fall/sea/polaris
	name = LANDMARK_FALL_POLARIS

/obj/landmark/fall/sea/marj
	name = LANDMARK_FALL_MARJ

/* ===== Visual Contents ===== */

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
			W.warptarget_modifier = warptarget_modifier
		else
			T.appearance_flags |= KEEP_TOGETHER
			T.vistarget = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
			if (T.vistarget)
				if(warptarget_modifier)
					T.vistarget.warptarget = T
					T.vistarget.warptarget_modifier = warptarget_modifier
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
/// turfs to project speech to (overlaps with vistarget speech)
/turf/var/list/listening_turfs = null
/// turfs to project reachability of objects to  (overlaps somewhat with vistarget)
/turf/var/list/reachable_turfs = null
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
