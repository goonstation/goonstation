// Mob spawners, for spawning mobs mainly for corpses right now
// Concrete spawners are at the bottom of the file

/obj/mapping_helper/mob_spawn
	name = "Mob Spawn"
	icon = 'icons/map-editing/mob_spawner.dmi'
	icon_state = "corpse-human"
	/// Path to spawn, should be a mob/living and not gib itself on death unless you want a mess
	var/spawn_type = null
	/// Container path such as a locker or crate, spawned with the corpse. It should obviously be openable by some means.
	var/container_type = null

	setup()
		if(isnull(src.spawn_type))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		var/mob/living/M = new spawn_type(src.loc)
		M.unobservable = TRUE //make it not show up in the observer list
		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			M.set_loc(container)

	proc/do_damage(var/mob/living/M)
		return

/obj/mapping_helper/mob_spawn/corpse/critter
	name = "Critter Corpse Spawn"
	icon_state = "corpse-critter"
	spawn_type = /mob/living/critter/small_animal/bee // Type path to spawn
	container_type = null

	setup()
		if(isnull(src.spawn_type))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")
		var/mob/living/M = new spawn_type(src.loc)
		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			M.set_loc(container)
			container.UpdateIcon()
		M.death(FALSE)

/obj/mapping_helper/mob_spawn/corpse/critter/random/martian
	name = "Random Martian Corpse Spawn"
	icon_state = "corpse-critter-rand"
	var/static/list/spawns = list(
		/mob/living/critter/martian,
		/mob/living/critter/martian/warrior,
		/mob/living/critter/martian/mutant,
		/mob/living/critter/martian/soldier)

	initialize()
		src.spawn_type = pick(spawns)
		..()

/obj/mapping_helper/mob_spawn/corpse/human // Human spawner handles some randomisation / customisation
	name = "Human Corpse Spawn"
	icon_state = "corpse-human"
	spawn_type = /mob/living/carbon/human/normal/assistant
	container_type = null

	/// If TRUE we husk the corpse on spawn and disfigure face
	var/husked = FALSE
	/// If TRUE we skeletonize the corpse on spawn
	var/skeletonized = FALSE
	/// If TRUE we decapitate the corpse on spawn
	var/headless = FALSE
	/// If TRUE we sever the arms of the corpse on spawn
	var/armless = FALSE
	/// If TRUE we sever the legs of the corpse on spawn
	var/legless = FALSE
	/// If TRUE we buckle corpse to chair if there is one
	var/try_buckle = TRUE
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
	/// If this has a value, remove a random number of limbs between 0 and this max
	var/max_limbs_removed = 1

	/// If TRUE we delete the contents of the backpack after spawning
	var/empty_bag = TRUE
	/// If TRUE delete the pocket contents if any
	var/empty_pockets = TRUE
	/// If TRUE we delete the ID slot contents after spawning
	var/delete_id = TRUE
	/// If TRUE we break the headset and make it unscannable after spawning
	var/break_headset = TRUE
	/// Can be used to override default mutant race
	var/datum/mutantrace/muterace = null
	/// Sent in if we are spawned by a human critter that drops a spawner
	var/datum/bioHolder/appearance_override = null
	/// Used to track the created corpse after setup
	var/mob/living/carbon/human/corpse = null

	setup()
		if (isnull(src.spawn_type))
			CRASH("Spawner [src] at [src.x] [src.y] [src.z] had no type.")

		src.corpse = new spawn_type(src.loc)

		if (!istype(src.corpse))
			CRASH("Human corpse spawner [src] at [src.x] [src.y] [src.z] had non-human type.")

		if (src.corpse.l_hand)
			qdel(src.corpse.l_hand)
		if (src.corpse.r_hand)
			qdel(src.corpse.r_hand)

		SPAWN(1)
			for (var/obj/item/implant/health/implant as anything in src.corpse.implant)
				qdel(implant)
			src.corpse.implant = list()
			for (var/obj/item/device/pda2/pda in src.corpse.contents)
				pda.scannable = FALSE

		if (src.try_buckle)
			var/obj/stool/S = (locate(/obj/stool) in src.corpse.loc)
			if (S)
				S.buckle_in(src.corpse, src.corpse, TRUE)
				src.corpse.dir = S.dir // Face properly

		APPLY_ATOM_PROPERTY(src.corpse, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "corpse_spawn")
		APPLY_ATOM_PROPERTY(src.corpse, PROP_MOB_SUPPRESS_DEATH_SOUND, "corpse_spawn")
		src.corpse.traitHolder.addTrait("puritan")
		src.corpse.death(FALSE)
		src.corpse.is_npc = TRUE

		if (src.no_decomp)
			APPLY_ATOM_PROPERTY(src.corpse, PROP_MOB_NO_DECOMPOSITION, "corpse_spawn")
		if (src.no_miasma)
			APPLY_ATOM_PROPERTY(src.corpse, PROP_MOB_NO_MIASMA, "corpse_spawn")

		if (src.randomise_decomp_stage)
			src.corpse.decomp_stage = rand(DECOMP_STAGE_NO_ROT, DECOMP_STAGE_HIGHLY_DECAYED)
		else
			src.corpse.decomp_stage = src.decomp_stage

		if (src.skeletonized)
			src.corpse.decomp_stage = DECOMP_STAGE_SKELETONIZED
			src.corpse.set_mutantrace(/datum/mutantrace/skeleton)
			if (prob(90))
				src.corpse.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none
				src.corpse.bioHolder.mobAppearance.customizations["hair_middle"].style = new /datum/customization_style/none
				src.corpse.bioHolder.mobAppearance.customizations["hair_top"].style = new /datum/customization_style/none

		if (istype(src.muterace))
			src.corpse.set_mutantrace(src.muterace)

		if (src.husked)
			src.corpse.disfigured = TRUE
			src.corpse.UpdateName()
			src.corpse.bioHolder?.AddEffect("husk")

		if (src.do_damage)
			src.do_damage(src.corpse)

		if (src.max_organs_removed)
			for (var/i in 1 to rand(0, src.max_organs_removed))
				var/obj/item/organ/organ = src.corpse.drop_organ(pick("left_eye","right_eye","left_lung","right_lung","butt","left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas","appendix"))
				qdel(organ)

		if (src.max_limbs_removed)
			var/list/obj/item/parts/limb_list = list(src.corpse.limbs.l_arm, src.corpse.limbs.r_arm, src.corpse.limbs.l_leg, src.corpse.limbs.r_leg)
			for (var/i in 1 to rand(0, src.max_limbs_removed))
				var/obj/item/parts/limb_to_delete = pick(limb_list)
				limb_to_delete.delete()
				limb_list -= limb_to_delete

		if (src.headless)
			var/obj/item/organ/head/noggin = src.corpse.organHolder.drop_organ("head")
			qdel(noggin)

		if (src.armless)
			for (var/obj/item/parts/limb in list(src.corpse.limbs.l_arm, src.corpse.limbs.r_arm))
				limb.delete()

		if (src.legless)
			for (var/obj/item/parts/limb in list(src.corpse.limbs.l_leg, src.corpse.limbs.r_leg))
				limb.delete()

		if (src.delete_id)
			qdel(src.corpse.wear_id)

		if (src.empty_bag)
			if (istype(src.corpse.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/backpack = src.corpse.back
				for (var/obj/item as anything in backpack)
					qdel(item)
			else if (istype(src.corpse.belt, /obj/item/storage/fanny))
				var/obj/item/storage/fanny/fanny = src.corpse.belt
				for (var/obj/item as anything in fanny)
					qdel(item)

		if (src.empty_pockets)
			if (src.corpse.l_store)
				qdel(src.corpse.l_store)
			if (src.corpse.r_store)
				qdel(src.corpse.r_store)

		if (src.break_headset)
			if (istype(src.corpse.ears, /obj/item/device/radio/headset))
				var/obj/item/device/radio/headset/headset = src.corpse.ears
				headset.bricked = TRUE
				headset.mechanics_interaction = MECHANICS_INTERACTION_BLACKLISTED // No getting smart

		if (src.container_type)
			var/obj/container = new container_type(src.loc)
			src.corpse.set_loc(container)
			container.UpdateIcon()

		if (src.appearance_override)
			src.corpse.bioHolder.CopyOther(src.appearance_override, TRUE, FALSE, FALSE, FALSE)

	do_damage(var/mob/living/carbon/human/H) // Override if you want specific damage numbers / types
		H.TakeDamage("all", brute = rand(100, 150), burn = rand(100, 150), tox = rand(40, 80), disallow_limb_loss = TRUE)
		H.take_oxygen_deprivation(rand(250, 300))

	clown
		spawn_type = /mob/living/carbon/human/normal/clown

	engineer
		spawn_type = /mob/living/carbon/human/normal/engineer

	miner
		spawn_type = /mob/living/carbon/human/normal/miner

	janitor
		spawn_type = /mob/living/carbon/human/normal/janitor

	chaplain
		spawn_type = /mob/living/carbon/human/normal/chaplain

	botanist
		spawn_type = /mob/living/carbon/human/normal/botanist

	chef
		spawn_type = /mob/living/carbon/human/normal/chef

	bartender
		spawn_type = /mob/living/carbon/human/normal/bartender

	security_officer
		spawn_type = /mob/living/carbon/human/normal/securityofficer

	scientist
		spawn_type = /mob/living/carbon/human/normal/scientist

	roboticist
		spawn_type = /mob/living/carbon/human/normal/roboticist

	geneticist
		spawn_type = /mob/living/carbon/human/normal/geneticist

	medical_doctor
		spawn_type = /mob/living/carbon/human/normal/medicaldoctor

	captain
		spawn_type = /mob/living/carbon/human/normal/captain

	head_of_personnel
		spawn_type = /mob/living/carbon/human/normal/headofpersonnel

/obj/mapping_helper/mob_spawn/corpse/human/random
	name = "Random Human Corpse Spawn"
	icon_state = "corpse-human-rand"
	randomise_decomp_stage = TRUE

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
		/mob/living/carbon/human/normal/bartender = 5,
		/mob/living/carbon/human/normal/securityofficer = 1)

	initialize()
		if (prob(20))
			src.max_limbs_removed = 4
			src.max_organs_removed = 10
		if (prob(5))
			src.headless = TRUE
		if (prob(5))
			src.spawn_type = weighted_pick(rare_spawns)
			src.delete_id = TRUE
		else
			src.spawn_type = weighted_pick(spawns)
		..()

/obj/mapping_helper/mob_spawn/corpse/human/random/body_bag
	icon_state = "bodybag-random"
	container_type = /obj/item/body_bag

	initialize()
		src.randomise_decomp_stage = TRUE
		src.no_decomp = FALSE
		..()

/obj/mapping_helper/mob_spawn/corpse/human/random/webbed
	icon_state = "webbed-random"
	container_type = /obj/icecube/spider
	husked = TRUE

	clown
		icon_state = "webbed-random_c"
		container_type = /obj/icecube/spider/clown


// Real spawns go here:

//////////////////////// Human corpses ////////////////////////

/obj/mapping_helper/mob_spawn/corpse/human/skeleton
	spawn_type = /mob/living/carbon/human/normal
	skeletonized = TRUE

/obj/mapping_helper/mob_spawn/corpse/human/syndicate/old
	spawn_type = /mob/living/carbon/human/normal/syndicate_old
	break_headset = TRUE

/obj/mapping_helper/mob_spawn/corpse/human/owlery_security
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

/obj/mapping_helper/mob_spawn/corpse/human/soviet
	spawn_type = /mob/living/carbon/human/normal
	skeletonized = TRUE

	setup()
		..()
		src.corpse.equip_new_if_possible(/obj/item/clothing/suit/space/soviet, SLOT_W_UNIFORM)
		src.corpse.equip_new_if_possible(/obj/item/clothing/head/helmet/space/soviet, SLOT_HEAD)

/obj/mapping_helper/mob_spawn/corpse/human/hazmat
	spawn_type = /mob/living/carbon/human/normal
	skeletonized = TRUE

	setup()
		..()
		src.corpse.equip_new_if_possible(/obj/item/clothing/suit/hazard/rad/iomoon, SLOT_W_UNIFORM)
		src.corpse.equip_new_if_possible(/obj/item/clothing/head/rad_hood/iomoon, SLOT_HEAD)

//////////////////////// Critter corpses ////////////////////////

/obj/mapping_helper/mob_spawn/corpse/critter/owl
	spawn_type = /mob/living/critter/small_animal/bird/owl


/obj/mapping_helper/mob_spawn/critter/random
	name = "Random Spawn"
	icon_state = "random-critter-base"


/obj/mapping_helper/mob_spawn/critter/random/gunbot
	name = "Random Gunbot Spawn"
	icon_state = "random-gunbot"
	var/list/spawns = list(/mob/living/critter/robotic/gunbot=50,
							/mob/living/critter/robotic/gunbot/chainsaw=5,
							/mob/living/critter/robotic/gunbot/light=25
						)

	initialize()
		src.spawn_type = weighted_pick(spawns)
		..()

/obj/mapping_helper/mob_spawn/critter/random/gunbot/danger
	spawns = list(/mob/living/critter/robotic/gunbot=50,
				/mob/living/critter/robotic/gunbot/minigun=5,
				/mob/living/critter/robotic/gunbot/flame=5,
				/mob/living/critter/robotic/gunbot/striker=10,
				/mob/living/critter/robotic/gunbot/cannon=2,
				/mob/living/critter/robotic/gunbot/mrl=1
				)
