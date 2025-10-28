ABSTRACT_TYPE(/datum/job/special/syndicate)
/datum/job/special/syndicate
	ui_colour = TGUI_COLOUR_CRIMSON
	job_category = JOB_SYNDICATE
	limit = 0
	wages = 0
	name = "YOU SHOULDN'T SEE ME OPERATIVE"
	access_string = "Syndicate Operative" // "All Access" + Syndie Shuttle
	radio_announcement = FALSE
	add_to_manifest = FALSE
	//Always a generic antagonist, don't allow normal antag roles.
	can_roll_antag = FALSE

	slot_back = list(/obj/item/storage/backpack/syndie)
	slot_jump = list(/obj/item/clothing/under/misc/syndicate)
	slot_foot = list(/obj/item/clothing/shoes/swat/noslip)
	slot_glov = list(/obj/item/clothing/gloves/swat/syndicate)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_mask = list(/obj/item/clothing/mask/gas/swat/syndicate)
	slot_ears = list(/obj/item/device/radio/headset/syndicate) //needs their own secret channel
	slot_belt = null //No PDA
	slot_card = /obj/item/card/id/syndicate //Job setup registers an owner, so custom agent ID setup won't be available.
	slot_poc2 = list(/obj/item/tank/pocket/extended/oxygen)
	faction = list(FACTION_SYNDICATE)

	special_setup(var/mob/living/carbon/human/M)
		..()
		SPAWN(0) //Let the ID actually spawn
			var/obj/item/card/id/ID = M.get_id()
			if(istype(ID))
				ID.icon_state = "id_syndie" //Syndie ID normally starts with basic sprite
		SPAWN(2) //Ghost respawn panel has a SPAWN(1) that clears all antag roles. Apply specialist role if no other role was picked
			if(!M.mind?.is_antagonist())
				M.mind?.add_generic_antagonist(ROLE_SYNDICATE_AGENT, src.name, source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/syndicate/weak
	name = "Junior Syndicate Operative"
	slot_belt = list(/obj/item/gun/kinetic/pistol)
	slot_ears = list() //No Headset
	slot_card = null //No Access
	slot_poc1 = list(/obj/item/storage/pouch/bullet_9mm)
	items_in_backpack = list(
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/suit/space/syndicate)

/datum/job/special/syndicate/weak/no_ammo
	name = "Poorly Equipped Junior Syndicate Operative"
	slot_poc1 = list() //And also no ammo.

//Specialist operatives using nukie class gear
ABSTRACT_TYPE(/datum/job/special/syndicate/specialist)
/datum/job/special/syndicate/specialist
	name = "Syndicate Specialist"
	special_spawn_location = LANDMARK_SYNDICATE
	receives_implants = list(/obj/item/implant/revenge/microbomb)
	slot_back = list(/obj/item/storage/backpack/syndie/tactical)
	slot_lhan = list(/obj/item/remote/syndicate_teleporter) //To get off the cairngorm with
	slot_rhan = list(/obj/item/tank/jetpack/syndicate) //To get off the listening post with

/datum/job/special/syndicate/specialist/demo
	name = "Syndicate Grenadier"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/grenadier)
	slot_poc1 = list(/obj/item/storage/pouch/grenade_round)
	items_in_backpack = list(/obj/item/gun/kinetic/grenade_launcher,
		/obj/item/storage/grenade_pouch/mixed_explosive)

/datum/job/special/syndicate/specialist/heavy
	name = "Syndicate Heavy Weapons Specialist"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/heavy)
	slot_poc1 = list(/obj/item/storage/pouch/lmg)
	slot_back = list(/obj/item/gun/kinetic/light_machine_gun)
	slot_belt = list(/obj/item/storage/fanny/syndie/large)
	items_in_belt = list(/obj/item/storage/grenade_pouch/high_explosive)

/datum/job/special/syndicate/specialist/assault
	name = "Syndicate Assault Trooper"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist)
	slot_poc1 = list(/obj/item/storage/pouch/assault_rifle/mixed)
	items_in_backpack = list(/obj/item/gun/kinetic/assault_rifle,
		/obj/item/storage/grenade_pouch/mixed_standard,
		/obj/item/breaching_charge,
		/obj/item/breaching_charge)

//Incredibly bloated :/
/datum/job/special/syndicate/specialist/infiltrator
	name = "Syndicate Infiltrator"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/infiltrator)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist)
	slot_poc1 = list(/obj/item/storage/pouch/tranq_pistol_dart)
	slot_lhan = list(/obj/item/storage/backpack/chameleon)
	items_in_backpack = list(/obj/item/gun/kinetic/tranq_pistol,
		/obj/item/dna_scrambler,
		/obj/item/voice_changer,
		/obj/item/card/emag,
		/obj/item/device/chameleon,
		/obj/item/remote/syndicate_teleporter) //Because their hands are filled with their chameleon gear

	special_setup(var/mob/living/carbon/human/M)
		..()
		var/obj/item/remote/chameleon/remote = locate(/obj/item/remote/chameleon) in M
		M.stow_in_available(remote)

/datum/job/special/syndicate/specialist/scout
	name = "Syndicate Scout"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/infiltrator)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/infiltrator)
	slot_eyes = list(/obj/item/clothing/glasses/nightvision)
	slot_poc1 = list(/obj/item/storage/pouch/bullet_9mm/smg)
	items_in_backpack = list(/obj/item/gun/kinetic/smg,
		/obj/item/card/emag,
		/obj/item/cloaking_device,
		/obj/item/lightbreaker)

/datum/job/special/syndicate/specialist/medic
	name = "Syndicate Field Medic"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/medic)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/medic)
	slot_poc1 = list(/obj/item/storage/pouch/veritate)
	slot_belt = list(/obj/item/storage/belt/syndicate_medic_belt)
	items_in_backpack = list(/obj/item/gun/kinetic/veritate,
		/obj/item/storage/medical_pouch,
		/obj/item/device/analyzer/healthanalyzer/upgraded,
		/obj/item/robodefibrillator,
		/obj/item/extinguisher/large)

/datum/job/special/syndicate/specialist/engineer
	name = "Syndicate Combat Engineer"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/engineer)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/engineer)
	slot_poc1 = list(/obj/item/storage/pouch/shotgun/weak)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	items_in_backpack = list(/obj/item/gun/kinetic/spes/engineer,
		/obj/item/turret_deployer/syndicate,
		/obj/item/paper/nast_manual,
		/obj/item/wrench/battle,
		/obj/item/weldingtool/high_cap)

/datum/job/special/syndicate/specialist/firebrand
	name = "Syndicate Firebrand"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/firebrand)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/firebrand)
	slot_poc1 = list(/obj/item/storage/grenade_pouch/napalm)
	slot_belt = list(/obj/item/storage/fanny/syndie/large)
	slot_back = null //flamethrower given in special setup
	slot_rhan = null //napalm tank is a jetpack
	items_in_belt = list(/obj/item/fireaxe,
		/obj/item/storage/grenade_pouch/incendiary)

	special_setup(var/mob/living/carbon/human/M)
		..()
		var/obj/item/gun/flamethrower/backtank/flamethrower = new /obj/item/gun/flamethrower/backtank/napalm(M)
		var/obj/item/tank/jetpack/backtank/our_tank = flamethrower.fueltank
		our_tank.insert_flamer(flamethrower, M)
		M.equip_if_possible(our_tank, SLOT_BACK)

/datum/job/special/syndicate/specialist/marksman
	name = "Syndicate Marksman"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/sniper)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/sniper)
	slot_poc1 = list(/obj/item/storage/pouch/sniper)
	slot_eyes = list(/obj/item/clothing/glasses/thermal/traitor)
	slot_back = list(/obj/item/gun/kinetic/sniper)
	slot_belt = list(/obj/item/storage/fanny/syndie/large)
	items_in_belt = list(/obj/item/storage/grenade_pouch/smoke)

/datum/job/special/syndicate/specialist/knight
	name = "Syndicate Knight"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/knight)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/knight)
	slot_foot = list(/obj/item/clothing/shoes/swat/knight)
	slot_glov = list(/obj/item/clothing/gloves/swat/syndicate/knight)
	slot_back = list(/obj/item/heavy_power_sword)
	slot_belt = list(/obj/item/storage/fanny/syndie/large)

/datum/job/special/syndicate/specialist/bard
	name = "Syndicate Bard"
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist/bard)
	slot_suit = list(/obj/item/clothing/suit/space/syndicate/specialist/bard)
	slot_ears = list(/obj/item/device/radio/headset/syndicate/bard)
	slot_back = null //Special setup will put a speaker here
	slot_belt = list(/obj/item/storage/fanny/syndie/large)

	special_setup(var/mob/living/carbon/human/M)
		..()
		var/obj/item/breaching_hammer/rock_sledge/guitar = new /obj/item/breaching_hammer/rock_sledge(M)
		for(var/obj/item/device/radio/nukie_studio_monitor/speaker in guitar.speakers)
			if(!M.equip_if_possible(speaker, SLOT_BACK))
				M.stow_in_available(speaker)
		M.stow_in_available(guitar)
