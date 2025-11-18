// Command Jobs

ABSTRACT_TYPE(/datum/job/command)
/datum/job/command
	ui_colour = TGUI_COLOUR_GREEN
	slot_card = /obj/item/card/id/command
	map_can_autooverride = FALSE
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY, ROLE_GANG_MEMBER, ROLE_GANG_LEADER, ROLE_SPY_THIEF, ROLE_CONSPIRATOR)
	job_category = JOB_COMMAND
	unique = TRUE
	world_announce_priority = ANNOUNCE_ORDER_HEADS

	special_setup(mob/M, no_special_spawn)
		. = ..()
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = "head", loc = M)
		image.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
		get_image_group(CLIENT_IMAGE_GROUP_HEADS_OF_STAFF).add_image(image)

/datum/job/command/captain
	name = "Captain"
	limit = 1
	wages = PAY_EXECUTIVE
	access_string = "Captain"
	high_priority_job = TRUE
	receives_miranda = TRUE
	can_roll_antag = FALSE
	world_announce_priority = ANNOUNCE_ORDER_CAPTAIN
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack/command)
	wiki_link = "https://wiki.ss13.co/Captain"

	slot_card = /obj/item/card/id/gold
	slot_belt = list(/obj/item/device/pda2/captain)
	slot_back = list(/obj/item/storage/backpack/captain)
	slot_jump = list(/obj/item/clothing/under/rank/captain)
	slot_suit = list(/obj/item/clothing/suit/armor/captain)
	slot_foot = list(/obj/item/clothing/shoes/swat/captain)
	slot_glov = list(/obj/item/clothing/gloves/swat/captain)
	slot_head = list(/obj/item/clothing/head/caphat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list(/obj/item/device/radio/headset/command/captain)
	slot_poc1 = list(/obj/item/disk/data/floppy/read_only/authentication)
	items_in_backpack = list(/obj/item/storage/box/id_kit,/obj/item/device/flash)
	rounds_needed_to_play = ROUNDS_MIN_CAPTAIN

	derelict
		//name = "NT-SO Commander"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/captain/centcomm)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/centhat)
		slot_belt = list(/obj/item/tank/pocket/extended/oxygen)
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_eyes = list(/obj/item/clothing/glasses/thermal)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/camera,/obj/item/gun/energy/egun)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/head_of_personnel
	name = "Head of Personnel"
	limit = 1
	wages = PAY_IMPORTANT
	access_string = "Head of Personnel"
	wiki_link = "https://wiki.ss13.co/Head_of_Personnel"

	allow_antag_fallthrough = FALSE
	receives_miranda = TRUE
	world_announce_priority = ANNOUNCE_ORDER_HOP


	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/hop)
	slot_jump = list(/obj/item/clothing/under/suit/hop)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/hop)
	slot_poc1 = list(/obj/item/pocketwatch)
	items_in_backpack = list(/obj/item/storage/box/id_kit,/obj/item/device/flash,/obj/item/storage/box/accessimp_kit)

/datum/job/command/head_of_security
	name = "Head of Security"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_drinker", "training_security")
	access_string = "Head of Security"
	requires_whitelist = TRUE
	receives_miranda = TRUE
	can_roll_antag = FALSE
	world_announce_priority = ANNOUNCE_ORDER_HOS
	receives_disk = /obj/item/disk/data/floppy/sec_command
	badge = /obj/item/clothing/suit/security_badge
	show_in_id_comp = FALSE
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack/command)
	items_in_backpack = list(/obj/item/device/flash)
	wiki_link = "https://wiki.ss13.co/Head_of_Security"

	slot_jump = list(/obj/item/clothing/under/rank/head_of_security)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_back = list(/obj/item/storage/backpack/security)
	slot_belt = list(/obj/item/device/pda2/hos)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_poc2 = list(/obj/item/requisition_token/security)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_head = list(/obj/item/clothing/head/hos_hat)
	slot_ears = list(/obj/item/device/radio/headset/command/hos)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)

	derelict
		name = null//"NT-SO Special Operative"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/NT)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/NTberet)
		slot_belt = list(/obj/item/tank/pocket/extended/oxygen)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_glov = list(/obj/item/clothing/gloves/latex)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_eyes = list(/obj/item/clothing/glasses/thermal)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/breaching_charge,/obj/item/breaching_charge,/obj/item/gun/energy/plasma_gun)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/chief_engineer
	name = "Chief Engineer"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_engineer")
	access_string = "Chief Engineer"
	wiki_link = "https://wiki.ss13.co/Chief_Engineer"

	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/storage/belt/utility/prepared/ceshielded)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat/chief_engineer)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_jump = list(/obj/item/clothing/under/rank/chief_engineer)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	slot_poc1 = list(/obj/item/paper/book/from_file/pocketguide/engineering)
	slot_poc2 = list(/obj/item/device/pda2/chiefengineer)
	items_in_backpack = list(/obj/item/device/flash, /obj/item/rcd_ammo/medium)

	derelict
		name = null//"Salvage Chief"
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/space/industrial)
		slot_foot = list(/obj/item/clothing/shoes/magnetic)
		slot_head = list(/obj/item/clothing/head/helmet/space/industrial)
		slot_belt = list(/obj/item/tank/pocket/oxygen)
		slot_mask = list(/obj/item/clothing/mask/gas)
		slot_eyes = list(/obj/item/clothing/glasses/thermal) // mesons look fuckin weird in the dark
		items_in_backpack = list(/obj/item/crowbar,/obj/item/rcd,/obj/item/rcd_ammo,/obj/item/rcd_ammo,/obj/item/device/light/flashlight,/obj/item/cell/cerenkite)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/research_director
	name = "Research Director"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_scientist")
	access_string = "Research Director"
	wiki_link = "https://wiki.ss13.co/Research_Director"

	slot_back = list(/obj/item/storage/backpack/research)
	slot_belt = list(/obj/item/device/pda2/research_director)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/research_director)
	slot_suit = list(/obj/item/clothing/suit/labcoat/research_director)
	slot_rhan = list(/obj/item/clipboard/with_pen)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_ears = list(/obj/item/device/radio/headset/command/rd)
	items_in_backpack = list(/obj/item/device/flash)

	special_setup(var/mob/living/carbon/human/M)
		..()
		for_by_tcl(heisenbee, /obj/critter/domestic_bee/heisenbee)
			if (!heisenbee.beeMom)
				heisenbee.beeMom = M
				heisenbee.beeMomCkey = M.ckey

/datum/job/command/medical_director
	name = "Medical Director"
	limit = 1
	wages = PAY_IMPORTANT
	trait_list = list("training_medical")
	access_string = "Medical Director"
	wiki_link = "https://wiki.ss13.co/Medical_Director"

	slot_back = list(/obj/item/storage/backpack/medic)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_jump = list(/obj/item/clothing/under/rank/medical_director)
	slot_suit = list(/obj/item/clothing/suit/labcoat/medical_director)
	slot_ears = list(/obj/item/device/radio/headset/command/md)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_poc1 = list(/obj/item/device/pda2/medical_director)
	items_in_backpack = list(/obj/item/device/flash)
