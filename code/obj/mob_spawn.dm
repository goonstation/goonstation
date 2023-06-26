// Mob spawners, for spawning mobs mainly for corpses right now
// Concrete spawners are at the bottom of the file

/obj/mob_spawn
	name = "Mob Spawn"
	icon = 'icons/map-editing/mob_spawner.dmi'
	icon_state = "corpse-human"
	anchored = ANCHORED
	invisibility = INVIS_ALWAYS
	/// Path to spawn, should be a mob/living and not gib itself on death unless you want a mess
	var/spawn_type = null
	/// Container path such as a locker or crate, spawned with the corpse. It should obviously be openable by some means.
	var/container_type = null

	New()
		if(current_state >= GAME_STATE_WORLD_INIT)
			SPAWN(0) // bluh, replace with some `initialize` variant later when someone makes it (needs to work with dmm loader)
				if(!src.disposed)
					src.initialize()
		..()

	initialize()
		src.spawn_the_thing()

	proc/spawn_the_thing()
		if(isnull(src.spawn_type))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		var/mob/living/M = new spawn_type(src.loc)
		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			M.set_loc(container)
		qdel(src)

	proc/do_damage(var/mob/living/M)
		return

/obj/mob_spawn/corpse/critter
	name = "Critter Corpse Spawn"
	icon_state = "corpse-critter"
	spawn_type = /mob/living/critter/small_animal/bee // Type path to spawn
	container_type = null

	spawn_the_thing()
		if(isnull(src.spawn_type))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		var/mob/living/M = new spawn_type(src.loc)
		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			M.set_loc(container)
		M.death(FALSE)
		qdel(src)

/obj/mob_spawn/corpse/human // Human spawner handles some randomisation / customisation
	name = "Human Corpse Spawn"
	icon_state = "corpse-human"
	spawn_type = /mob/living/carbon/human/normal/assistant
	container_type = null

	/// If TRUE we husk the corpse on spawn and disfigure face
	var/husked = FALSE
	/// If TRUE randomise the decomp stage of the body after spawning
	var/randomise_decomp_stage = FALSE
	/// Override this if you want a specific decomp stage
	var/decomp_stage = DECOMP_STAGE_NO_ROT
	/// If TRUE we are magically preserved and don't decay
	var/no_decomp = TRUE
	/// If TRUE we make no miasma, since filling prefabs or maint etc with that would suck
	var/no_miasma = TRUE

	/// If TRUE we call do_damage() by default this is random damage of every type
	var/do_damage = TRUE
	/// If this has a value, remove a random number of organs between 0 and this max
	var/max_organs_removed = 4

	/// If TRUE we delete the contents of the backpack after spawning
	var/empty_bag = FALSE
	/// If TRUE delete the pocket contents if any
	var/empty_pockets = FALSE
	/// If TRUE we delete the ID slot contents after spawning
	var/delete_id = FALSE
	/// If TRUE we break the headset and make it unscannable after spawning
	var/break_headset = FALSE

	spawn_the_thing()
		if (isnull(src.spawn_type))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")

		var/mob/living/carbon/human/H = new spawn_type(src.loc)

		if (!istype(H))
			CRASH("Human corpse spawner [src] at [src.x] [src.y] [src.z] had non-human type.")

		if (H.l_hand)
			qdel(H.l_hand)
		if (H.r_hand)
			qdel(H.r_hand)

		APPLY_ATOM_PROPERTY(H, PROP_MOB_SUPPRESS_DEATH_SOUND, "corpse_spawn")
		H.death(FALSE)

		if (src.no_decomp)
			APPLY_ATOM_PROPERTY(H, PROP_MOB_NO_DECOMPOSITION, "corpse_spawn")
		if (src.no_miasma)
			APPLY_ATOM_PROPERTY(H, PROP_MOB_NO_MIASMA, "corpse_spawn")

		if (src.randomise_decomp_stage)
			H.decomp_stage = rand(DECOMP_STAGE_NO_ROT, DECOMP_STAGE_HIGHLY_DECAYED)
		else
			H.decomp_stage = src.decomp_stage

		if (src.husked)
			H.disfigured = TRUE
			H.UpdateName()
			H.bioHolder?.AddEffect("husk")

		if (src.do_damage)
			src.do_damage(H)

		if (src.max_organs_removed)
			for (var/i in 1 to rand(0, src.max_organs_removed))
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

		if (src.empty_pockets)
			if (H.l_store)
				qdel(H.l_store)
			if (H.r_store)
				qdel(H.r_store)

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

	do_damage(var/mob/living/carbon/human/H) // Override if you want specific damage numbers / types
		H.TakeDamage("all", brute = rand(100, 150), burn = rand(100, 150), tox = rand(40, 80), disallow_limb_loss = TRUE)
		H.take_oxygen_deprivation(rand(250, 300))

/obj/mob_spawn/corpse/human/random
	name = "Random Human Corpse Spawn"
	icon_state = "corpse-human-rand"
	var/static/list/spawns = list(
		/mob/living/carbon/human/normal/assistant = 30,
		/mob/living/carbon/human/normal/miner = 20,
		/mob/living/carbon/human/normal/botanist = 20,
		/mob/living/carbon/human/normal/chef = 10,
		/mob/living/carbon/human/normal/janitor = 5,
		/mob/living/carbon/human/normal/roboticist = 5,
		/mob/living/carbon/human/normal = 5)

	var/static/list/rare_spawns = list(
		/mob/living/carbon/human/normal/engineer = 30,
		/mob/living/carbon/human/normal/clown = 25,
		/mob/living/carbon/human/normal/medicaldoctor = 15,
		/mob/living/carbon/human/normal/bartender = 5)

	initialize()
		if (prob(5))
			src.spawn_type = weighted_pick(rare_spawns)
			src.delete_id = TRUE
		else
			src.spawn_type = weighted_pick(spawns)
		..()

/obj/mob_spawn/corpse/human/random/body_bag
	icon_state = "bodybag-random"
	container_type = /obj/item/body_bag

	initialize()
		src.randomise_decomp_stage = TRUE
		src.no_decomp = FALSE
		..()

/obj/mob_spawn/corpse/human/random/webbed
	icon_state = "webbed-random"
	container_type = /obj/icecube/spider
	husked = TRUE

	clown
		icon_state = "webbed-random_c"
		container_type = /obj/icecube/spider/clown


// Real spawns go here:

//////////////////////// Human corpses ////////////////////////

/obj/mob_spawn/corpse/human/skeleton
	spawn_type = /mob/living/carbon/human/normal
	decomp_stage = DECOMP_STAGE_SKELETONIZED

/obj/mob_spawn/corpse/human/owlery_security
	spawn_type = /mob/living/carbon/human/normal/securityofficer
	decomp_stage = DECOMP_STAGE_BLOATED
	delete_id = TRUE
	empty_pockets = TRUE
	break_headset = TRUE
	max_organs_removed = 5

	do_damage(var/mob/living/carbon/human/H)
		H.TakeDamage("all", brute = rand(100, 150))
		H.take_oxygen_deprivation(rand(250, 300))
		H.blood_volume -= rand(200, 350)
		if (prob(80))
			qdel(H.glasses)

	assistant
		spawn_type = /mob/living/carbon/human/normal/securityassistant

//////////////////////// Critter corpses ////////////////////////

/obj/mob_spawn/corpse/critter/owl
	spawn_type = /mob/living/critter/small_animal/bird/owl
