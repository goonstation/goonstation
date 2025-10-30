// Research Jobs

ABSTRACT_TYPE(/datum/job/research)
/datum/job/research
	ui_colour = TGUI_COLOUR_PURPLE
	slot_card = /obj/item/card/id/research
	job_category = JOB_RESEARCH

/datum/job/research/scientist
	name = "Scientist"
	limit = 5
	wages = PAY_DOCTORATE
	trait_list = list("training_scientist")
	access_string = "Scientist"
	slot_back = list(/obj/item/storage/backpack/research)
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_suit = list(/obj/item/clothing/suit/labcoat/science)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_poc1 = list(/obj/item/pen = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/pen/pencil = 20)
	wiki_link = "https://wiki.ss13.co/Scientist"

/datum/job/research/research_assistant
	name = "Research Trainee"
	limit = 2
	wages = PAY_UNTRAINED
	trait_list = list("training_scientist")
	access_string = "Scientist"
	rounds_allowed_to_play = ROUNDS_MAX_RESASS
	slot_back = list(/obj/item/storage/backpack/research)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_jump = list(/obj/item/clothing/under/color/purple)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_poc1 = list(/obj/item/pen = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/pen/pencil = 20)
	wiki_link = "https://wiki.ss13.co/Research_Assistant"
