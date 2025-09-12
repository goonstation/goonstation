ABSTRACT_TYPE(/datum/job/medical)
/datum/job/medical
	ui_colour = TGUI_COLOUR_PINK
	slot_card = /obj/item/card/id/medical
	job_category = JOB_MEDICAL

/datum/job/medical/medical_doctor
	name = "Medical Doctor"
	limit = 5
	wages = PAY_DOCTORATE
	trait_list = list("training_medical")
	access_string = "Medical Doctor"
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/medical)
	slot_suit = list(/obj/item/clothing/suit/labcoat/medical)
	slot_foot = list(/obj/item/clothing/shoes/red)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_poc1 = list(/obj/item/device/pda2/medical)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	items_in_backpack = list(/obj/item/crowbar/blue) // cogwerks: giving medics a guaranteed air tank, stealing it from roboticists (those fucks)
	// 2018: guaranteed air tanks now spawn in boxes (depending on backpack type) to save room
	wiki_link = "https://wiki.ss13.co/Medical_Doctor"

	derelict
		//name = "Salvage Medic"
		name = null
		limit = 0
		slot_suit = list(/obj/item/clothing/suit/armor/vest)
		slot_head = list(/obj/item/clothing/head/helmet/swat)
		slot_belt = list(/obj/item/tank/pocket/oxygen)
		slot_mask = list(/obj/item/clothing/mask/breath)
		slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
		slot_glov = list(/obj/item/clothing/gloves/latex)
		items_in_backpack = list(/obj/item/crowbar,/obj/item/device/light/flashlight,/obj/item/storage/firstaid/regular,/obj/item/storage/firstaid/regular)
		special_spawn_location = LANDMARK_HTR_TEAM

		special_setup(var/mob/living/carbon/human/M)
			..()
			if (!M) return
			M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/medical/geneticist
	name = "Geneticist"
	limit = 2
	wages = PAY_DOCTORATE
	access_string = "Geneticist"
	slot_back = list(/obj/item/storage/backpack/genetics)
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/geneticist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/genetics)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/device/analyzer/genetic)
	wiki_link = "https://wiki.ss13.co/Geneticist"

/datum/job/medical/roboticist
	name = "Roboticist"
	limit = 3
	wages = PAY_DOCTORATE
	trait_list = list("training_medical")
	access_string = "Roboticist"
	slot_back = list(/obj/item/storage/backpack/robotics)
	slot_belt = list(/obj/item/storage/belt/roboticist/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/roboticist)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_suit = list(/obj/item/clothing/suit/labcoat/robotics)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_poc1 = list(/obj/item/device/pda2/medical/robotics)
	slot_poc2 = list(/obj/item/reagent_containers/mender/brute)
	wiki_link = "https://wiki.ss13.co/Roboticist"

/datum/job/medical/medical_assistant
	name = "Medical Trainee"
	limit = 2
	wages = PAY_UNTRAINED
	trait_list = list("training_medical")
	access_string = "Medical Doctor"
	rounds_allowed_to_play = ROUNDS_MAX_MEDASS
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_foot = list(/obj/item/clothing/shoes/red)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_poc1 = list(/obj/item/device/pda2/medical)
	slot_poc2 = list(/obj/item/paper/book/from_file/pocketguide/medical)
	slot_jump = list(/obj/item/clothing/under/scrub = 30,/obj/item/clothing/under/scrub/teal = 14,/obj/item/clothing/under/scrub/blue = 14,/obj/item/clothing/under/scrub/purple = 14,/obj/item/clothing/under/scrub/orange = 14,/obj/item/clothing/under/scrub/pink = 14)
	wiki_link = "https://wiki.ss13.co/Medical_Assistant"
