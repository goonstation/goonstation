// Security Jobs

ABSTRACT_TYPE(/datum/job/security)
/datum/job/security
	ui_colour = TGUI_COLOUR_RED
	slot_card = /obj/item/card/id/security
	receives_miranda = TRUE
	job_category = JOB_SECURITY

/datum/job/security/security_officer
	name = "Security Officer"
	limit = 5
	lower_limit = 3
	variable_limit = TRUE
	high_priority_job = TRUE
	high_priority_limit = 2 //always try to make sure there's at least a couple of secoffs
	order_priority = 2 //fill secoffs after captain and AI
	wages = PAY_TRADESMAN
	trait_list = list("training_security")
	access_string = "Security Officer"
	can_roll_antag = FALSE
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack)
	receives_disk = /obj/item/disk/data/floppy/security
	badge = /obj/item/clothing/suit/security_badge
	slot_back = list(/obj/item/storage/backpack/security)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/rank/security)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat/security)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_poc2 = list(/obj/item/requisition_token/security)
	rounds_needed_to_play = ROUNDS_MIN_SECURITY
	wiki_link = "https://wiki.ss13.co/Security_Officer"

	assistant
		name = "Security Assistant"
		limit = 3
		lower_limit = 2
		high_priority_job = FALSE //nope
		wages = PAY_UNTRAINED
		access_string = "Security Assistant"
		receives_implants = list(/obj/item/implant/health/security)
		slot_back = list(/obj/item/storage/backpack/security)
		slot_jump = list(/obj/item/clothing/under/rank/security/assistant)
		slot_suit = list()
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_head = list(/obj/item/clothing/head/red)
		slot_foot = list(/obj/item/clothing/shoes/brown)
		slot_poc1 = list(/obj/item/storage/security_pouch/assistant)
		slot_poc2 = list(/obj/item/requisition_token/security/assistant)
		items_in_backpack = list(/obj/item/paper/book/from_file/space_law)
		rounds_needed_to_play = ROUNDS_MIN_SECASS
		wiki_link = "https://wiki.ss13.co/Security_Assistant"

	derelict
		//name = "NT-SO Officer"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/NT_alt)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/helmet/swat)
		slot_glov = list(/obj/item/clothing/gloves/fingerless)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_belt = list(/obj/item/gun/energy/laser_gun)
		slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/baton,/obj/item/breaching_charge,/obj/item/breaching_charge)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M)
				return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/security/detective
	name = "Detective"
	limit = 1
	wages = PAY_TRADESMAN
	trait_list = list("training_drinker")
	access_string = "Detective"
	badge = /obj/item/clothing/suit/security_badge
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY, ROLE_GANG_LEADER, ROLE_GANG_MEMBER, ROLE_CONSPIRATOR)
	allow_antag_fallthrough = FALSE
	unique = TRUE
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/storage/belt/security/shoulder_holster)
	slot_poc1 = list(/obj/item/device/pda2/forensic)
	slot_jump = list(/obj/item/clothing/under/rank/det)
	slot_foot = list(/obj/item/clothing/shoes/detective)
	slot_head = list(/obj/item/clothing/head/det_hat)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_suit = list(/obj/item/clothing/suit/det_suit)
	slot_ears = list(/obj/item/device/radio/headset/detective)
	items_in_backpack = list(/obj/item/clothing/glasses/vr,/obj/item/storage/box/detectivegun,/obj/item/camera/large)
	map_can_autooverride = FALSE
	rounds_needed_to_play = ROUNDS_MIN_DETECTIVE
	wiki_link = "https://wiki.ss13.co/Detective"

	special_setup(var/mob/living/carbon/human/M)
		..()

		if (M.traitHolder && !M.traitHolder.hasTrait("smoker"))
			items_in_backpack += list(/obj/item/device/light/zippo) //Smokers start with a trinket version
