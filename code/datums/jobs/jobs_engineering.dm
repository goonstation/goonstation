// Engineering Jobs

ABSTRACT_TYPE(/datum/job/engineering)
/datum/job/engineering
	ui_colour = TGUI_COLOUR_ORANGE
	slot_card = /obj/item/card/id/engineering
	job_category = JOB_ENGINEERING

/datum/job/engineering/engineer
	name = "Engineer"
	limit = 8
	wages = PAY_TRADESMAN
	trait_list = list("training_engineer")
	access_string = "Engineer"
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical/engineer_spawn)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_poc1 = list(/obj/item/device/pda2/engine)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
#ifdef HOTSPOTS_ENABLED
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/clothing/shoes/stomp_boots)
#else
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/old_grenade/oxygen)
#endif
	wiki_link = "https://wiki.ss13.co/Engineer"

	derelict
		name = null//"Salvage Engineer"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/space/engineer)
		slot_head = list(/obj/item/clothing/head/helmet/welding)
		slot_belt = list(/obj/item/tank/pocket/oxygen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/device/light/glowstick,/obj/item/gun/kinetic/flaregun,/obj/item/ammo/bullets/flare,/obj/item/cell/cerenkite)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/engineering/technical_assistant
	name = "Technical Trainee"
	limit = 2
	wages = PAY_UNTRAINED
	trait_list = list("training_engineer")
	access_string = "Engineer"
	rounds_allowed_to_play = ROUNDS_MAX_TECHASS
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	slot_jump = list(/obj/item/clothing/under/color/yellow)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical/engineer_spawn)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_poc1 = list(/obj/item/device/pda2/engine)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/engineering)
#ifdef HOTSPOTS_ENABLED
	items_in_backpack = list(/obj/item/clothing/shoes/stomp_boots)
#endif

	wiki_link = "https://wiki.ss13.co/Technical_Assistant"

/datum/job/engineering/quartermaster
	name = "Quartermaster"
	limit = 3
	wages = PAY_TRADESMAN
	trait_list = list("training_quartermaster")
	access_string = "Quartermaster"
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_jump = list(/obj/item/clothing/under/rank/cargo)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	slot_ears = list(/obj/item/device/radio/headset/shipping)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/quartermaster)
	slot_poc2 = list(/obj/item/device/appraisal)
	wiki_link = "https://wiki.ss13.co/Quartermaster"

/datum/job/engineering/miner
	name = "Miner"
	#ifdef UNDERWATER_MAP
	limit = 6
	#else
	limit = 5
	#endif
	wages = PAY_TRADESMAN
	trait_list = list("training_miner")
	access_string = "Miner"
	invalid_antagonist_roles = list(ROLE_VAMPIRE)
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_belt = list(/obj/item/storage/belt/mining/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/miner)
	slot_poc1 = list(/obj/item/device/pda2/mining)
	#ifdef UNDERWATER_MAP
	slot_suit = list(/obj/item/clothing/suit/space/diving/engineering)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	items_in_backpack = list(/obj/item/paper/book/from_file/pocketguide/mining,
							/obj/item/clothing/shoes/flippers,
							/obj/item/item_box/glow_sticker)
	#else
	slot_suit = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	items_in_backpack = list(/obj/item/crowbar,
							/obj/item/paper/book/from_file/pocketguide/mining)
	#endif
	wiki_link = "https://wiki.ss13.co/Miner"
