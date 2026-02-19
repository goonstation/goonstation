// Civilian Jobs

ABSTRACT_TYPE(/datum/job/civilian)
/datum/job/civilian
	ui_colour = TGUI_COLOUR_BLUE
	slot_card = /obj/item/card/id/civilian
	job_category = JOB_CIVILIAN

/datum/job/civilian/chef
	name = "Chef"
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_chef")
	access_string = "Chef"
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/rank/chef)
	slot_foot = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/chefhat)
	slot_suit = list(/obj/item/clothing/suit/chef)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/kitchen/rollingpin, /obj/item/kitchen/utensil/knife/cleaver, /obj/item/bell/kitchen)
	wiki_link = "https://wiki.ss13.co/Chef"

/datum/job/civilian/bartender
	name = "Bartender"
	alias_names = list("Barman")
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_drinker", "training_bartender")
	access_string = "Bartender"
	slot_belt = list(/obj/item/device/pda2/bartender)
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_suit = list(/obj/item/clothing/suit/armor/vest)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/cloth/towel/bar)
	slot_poc2 = list(/obj/item/reagent_containers/food/drinks/cocktailshaker)
	items_in_backpack = list(/obj/item/gun/kinetic/sawnoff, /obj/item/ammo/bullets/abg, /obj/item/paper/book/from_file/pocketguide/bartending)
	wiki_link = "https://wiki.ss13.co/Bartender"

/datum/job/civilian/botanist
	name = "Botanist"
	#ifdef MAP_OVERRIDE_DONUT3
	limit = 7
	#else
	limit = 5
	#endif
	wages = PAY_TRADESMAN
	access_string = "Botanist"
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_jump = list(/obj/item/clothing/under/rank/hydroponics)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/paper/botany_guide)
	slot_poc2 = list(/obj/item/plantanalyzer)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Botanist"

	faction = list(FACTION_BOTANY)

/datum/job/civilian/rancher
	name = "Rancher"
	limit = 1
	wages = PAY_TRADESMAN
	access_string = "Rancher"
	slot_belt = list(/obj/item/storage/belt/rancher/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/rancher)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_foot = list(/obj/item/clothing/shoes/westboot/brown/rancher)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/paper/ranch_guide)
	slot_poc2 = list(/obj/item/device/pda2/botanist)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	items_in_backpack = list(/obj/item/device/camera_viewer/ranch,/obj/item/storage/box/knitting)
	wiki_link = "https://wiki.ss13.co/Rancher"

/datum/job/civilian/janitor
	name = "Janitor"
	limit = 3
	wages = PAY_TRADESMAN
	access_string = "Janitor"
	slot_belt = list(/obj/item/storage/fanny/janny)
	slot_jump = list(/obj/item/clothing/under/rank/janitor)
	slot_foot = list(/obj/item/clothing/shoes/galoshes)
	slot_glov = list(/obj/item/clothing/gloves/long)
	slot_rhan = list(/obj/item/mop)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_poc1 = list(/obj/item/device/pda2/janitor)
	items_in_backpack = list(/obj/item/reagent_containers/glass/bucket, /obj/item/lamp_manufacturer/organic)
	wiki_link = "https://wiki.ss13.co/Janitor"

/datum/job/civilian/chaplain
	name = "Chaplain"
	limit = 1
	wages = PAY_UNTRAINED
	trait_list = list("training_chaplain")
	access_string = "Chaplain"
	slot_jump = list(/obj/item/clothing/under/rank/chaplain)
	slot_belt = list(/obj/item/device/pda2/chaplain)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/bible/loaded)
	wiki_link = "https://wiki.ss13.co/Chaplain"

	special_setup(var/mob/living/carbon/human/M)
		..()
		OTHER_START_TRACKING_CAT(M, TR_CAT_CHAPLAINS)

/datum/job/civilian/staff_assistant
	name = "Staff Assistant"
	wages = PAY_UNTRAINED
	access_string = "Staff Assistant"
	no_jobban_from_this_job = TRUE
	low_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	map_can_autooverride = FALSE
	slot_jump = list(/obj/item/clothing/under/rank/assistant)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	wiki_link = "https://wiki.ss13.co/Staff_Assistant"

	special_setup(mob/living/carbon/human/M, no_special_spawn)
		..()
		if (prob(20))
			M.stow_in_available(new /obj/item/paper/businesscard/seneca)


/datum/job/civilian/mail_courier
	name = "Mail Courier"
	alias_names = "Mailman"
	wages = PAY_TRADESMAN
	access_string = "Mail Courier"
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/mail/syndicate)
	slot_head = list(/obj/item/clothing/head/mailcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_ears = list(/obj/item/device/radio/headset/mail)
	slot_poc1 = list(/obj/item/pinpointer/mail_recepient)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	items_in_backpack = list(/obj/item/wrapping_paper, /obj/item/satchel/mail, /obj/item/scissors, /obj/item/stamp)
	alt_names = list("Head of Deliverying", "Mail Bringer")
	wiki_link = "https://wiki.ss13.co/Mailman"

/datum/job/civilian/clown
	name = "Clown"
	limit = 1
	wages = PAY_DUMBCLOWN
	request_limit = 3 //this is definitely a bad idea
	request_cost = PAY_TRADESMAN*4
	trait_list = list("training_clown")
	access_string = "Clown"
	ui_colour = TGUI_COLOUR_PINK
	slot_back = list()
	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_mask = list(/obj/item/clothing/mask/clown_hat)
	slot_jump = list(/obj/item/clothing/under/misc/clown)
	slot_foot = list(/obj/item/clothing/shoes/clown_shoes)
	slot_lhan = list(/obj/item/instrument/bikehorn)
	slot_poc1 = list(/obj/item/device/pda2/clown)
	slot_poc2 = list(/obj/item/reagent_containers/food/snacks/plant/banana)
	slot_card = /obj/item/card/id/clown
	slot_ears = list(/obj/item/device/radio/headset/clown)
	items_in_belt = list(/obj/item/cloth/towel/clown)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Clown"

	faction = list(FACTION_CLOWN)

// AI and Cyborgs

/datum/job/civilian/AI
	name = "AI"
	ui_colour = TGUI_COLOUR_GREY
	limit = 1
	no_late_join = TRUE
	high_priority_job = TRUE
	can_roll_antag = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()
	uses_character_profile = FALSE
	show_in_id_comp = FALSE
	wiki_link = "https://wiki.ss13.co/Artificial_Intelligence"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.removeTrait("cyber_incompatible")
		return M.AIize()

/datum/job/civilian/cyborg
	name = "Cyborg"
	ui_colour = TGUI_COLOUR_GREY
	limit = 8
	no_late_join = TRUE
	can_roll_antag = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	slot_belt = list()
	items_in_backpack = list()
	uses_character_profile = FALSE
	show_in_id_comp = FALSE
	wiki_link = "https://wiki.ss13.co/Cyborg"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/silicon/S = M.Robotize_MK2()
		APPLY_ATOM_PROPERTY(S, PROP_ATOM_ROUNDSTART_BORG, "borg")
		S.traitHolder.removeTrait("cyber_incompatible")
		return S
