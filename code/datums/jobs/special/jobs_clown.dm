/*
 * Clown jobs (excluding the main staple one)
 */
ABSTRACT_TYPE(/datum/job/special/clown)
/datum/job/special/clown
	job_category = JOB_CLOWN
	wages = PAY_DUMBCLOWN
	trait_list = list("training_clown")
	access_string = "Clown"
	ui_colour = TGUI_COLOUR_PINK
	limit = 0
	slot_back = list()
	slot_card = /obj/item/card/id/clown
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/plant/banana)
	items_in_belt = list(/obj/item/cloth/towel/clown)
	slot_mask = list(/obj/item/clothing/mask/clown_hat)
	slot_ears = list(/obj/item/device/radio/headset/clown)
	slot_jump = list(/obj/item/clothing/under/misc/clown)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes)
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_poc1 = list(/obj/item/device/pda2/clown)
	slot_lhan = list(/obj/item/instrument/bikehorn)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Clown"
	faction = list(FACTION_CLOWN)

/datum/job/special/clown/blue
	name = "Blue Clown"
	ui_colour = TGUI_COLOUR_NAVY
#ifdef HALLOWEEN
	limit = 1
#else
	limit = 0
#endif
	slot_mask = list(/obj/item/clothing/mask/clown_hat/blue)
	slot_ears = list(/obj/item/device/radio/headset/clown/blue)
	slot_jump = list(/obj/item/clothing/under/misc/clown/blue)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/blue)
	slot_belt = list(/obj/item/storage/fanny/funny/blue)
	slot_poc1 = list(/obj/item/device/pda2/clown/blue)
	slot_lhan = list(/obj/item/instrument/bikehorn/blue)

	special_setup(var/mob/living/carbon/human/M)
		..()
		M.bioHolder.AddEffect("regenerator", magical=1)

/datum/job/special/clown/purple
	name = "Purple Clown"
	ui_colour = TGUI_COLOUR_VIOLET
	slot_mask = list(/obj/item/clothing/mask/clown_hat/purple)
	slot_jump = list(/obj/item/clothing/under/misc/clown/purple)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/purple)

/datum/job/special/clown/yellow
	name = "Yellow Clown"
	ui_colour = TGUI_COLOUR_YELLOW
	slot_mask = list(/obj/item/clothing/mask/clown_hat/yellow)
	slot_jump = list(/obj/item/clothing/under/misc/clown/yellow)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/yellow)
	slot_glov = list(/obj/item/clothing/gloves/yellow/unsulated)

/datum/job/special/clown/pink
	name = "Pink Clown"
	slot_mask = list(/obj/item/clothing/mask/clown_hat/pink)
	slot_jump = list(/obj/item/clothing/under/misc/clown/pink)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes/pink)

/datum/job/special/clown/green
	name = "Green Clown?"
	ui_colour = TGUI_COLOUR_GREEN
	slot_mask = list(/obj/item/clothing/mask/cursedclown_hat)
	slot_jump = list(/obj/item/clothing/under/gimmick/cursedclown)
	slot_foot = list(/obj/item/clothing/shoes/cursedclown_shoes)
	slot_glov = list(/obj/item/clothing/gloves/cursedclown_gloves)
