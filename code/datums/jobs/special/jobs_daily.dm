ABSTRACT_TYPE(/datum/job/daily)
/datum/job/daily //Special daily jobs
	job_category = JOB_DAILY
	request_limit = 2
	request_cost = PAY::DOCTORATE*4
	email_group = MGD_CIVILIAN
	var/day = ""
/datum/job/daily/boxer
	day = "Sunday"
	name = "Boxer"
	wages = PAY::UNTRAINED
	access_string = "Boxer"
	limit = 4
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Boxer"

/datum/job/daily/dungeoneer
	day = "Monday"
	name = "Dungeoneer"
	limit = 1
	wages = PAY::UNTRAINED
	access_string = "Dungeoneer"
	slot_belt = list(/obj/item/device/pda2)
	slot_mask = list(/obj/item/clothing/mask/skull)
	slot_jump = list(/obj/item/clothing/under/color/brown)
	slot_suit = list(/obj/item/clothing/suit/cultist/nerd)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_poc1 = list(/obj/item/pen/omni)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/storage/box/nerd_kit)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Jobs#Job_of_the_Day" // no wiki page yet

/datum/job/daily/barber
	day = "Tuesday"
	name = "Barber"
	wages = PAY::UNTRAINED
	access_string = "Barber"
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/barber)
	slot_head = list(/obj/item/clothing/head/boater_hat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/scissors)
	slot_poc2 = list(/obj/item/razor_blade)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	alt_names = list("Barber", "Hairdresser")
	wiki_link = "https://wiki.ss13.co/Barber"

/datum/job/daily/waiter
	day = "Wednesday"
	name = "Waiter"
	wages = PAY::UNTRAINED
	access_string = "Waiter"
	slot_belt = list(/obj/item/device/pda2/chef)
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_suit = list(/obj/item/clothing/suit/wcoat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian/catering)
	slot_lhan = list(/obj/item/plate/tray)
	slot_poc1 = list(/obj/item/cloth/towel/white)
	items_in_backpack = list(/obj/item/storage/box/glassbox,/obj/item/storage/box/cutlery)
	wiki_link = "https://wiki.ss13.co/Jobs#Job_of_the_Day" // no wiki page yet
	email_group = MGD_CIVILIAN

/datum/job/daily/lawyer
	day = "Thursday"
	name = "Lawyer"
	ui_colour = /datum/job/security::ui_colour
	wages = PAY::DOCTORATE
	access_string = "Lawyer"
	limit = 4
	badge = /obj/item/clothing/suit/security_badge/attorney
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	alt_names = list("Lawyer", "Attorney")
	wiki_link = "https://wiki.ss13.co/Lawyer"


/datum/job/daily/tourist
	day = "Friday"
	name = "Tourist"
	limit = 100
	request_limit = 0
	wages = 0
	slot_back = null
	slot_belt = list(/obj/item/storage/fanny)
	slot_jump = list(/obj/item/clothing/under/misc/tourist)
	slot_poc1 = list(/obj/item/camera_film)
	slot_poc2 = list(/obj/item/currency/spacecash/tourist) // Exact amount is randomized.
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_lhan = list(/obj/item/camera)
	slot_rhan = list(/obj/item/storage/photo_album)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Tourist"
	email_group = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		SPAWN(0)
			var/selection = null
			var/list/options = list(/datum/mutantrace/lizard::name = /datum/mutantrace/lizard,
									/datum/mutantrace/skeleton::name  = /datum/mutantrace/skeleton,
									/datum/mutantrace/ithillid::name = /datum/mutantrace/ithillid,
									/datum/mutantrace/martian::name = /datum/mutantrace/martian,
									/datum/mutantrace/frog/abzunian::name = /datum/mutantrace/frog/abzunian,
									/datum/mutantrace/blob::name  = /datum/mutantrace/blob,
									/datum/mutantrace/cow::name = /datum/mutantrace/cow)

			selection = tgui_input_list(M,"Pick a Mutantrace. Cancel to be Human.","Pick a Mutantrace. Cancel to be Human.",options)
			var/datum/mutantrace/morph = options[selection]

			if (morph && (morph == /datum/mutantrace/martian || morph == /datum/mutantrace/blob)) // doesn't wear human clothes
				M.equip_if_possible(new /obj/item/storage/backpack/empty(src), SLOT_BACK)
				var/obj/item/backpack = M.back

				var/obj/item/storage/fanny/belt_storage = M.belt
				if(istype(belt_storage))
					for(var/obj/item/I in belt_storage.storage.get_contents())
						belt_storage.storage.transfer_stored_item(I, backpack, TRUE, M)
				qdel(belt_storage)

				M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_IN_BACKPACK)

				M.stow_in_available(M.l_store, FALSE)
				M.stow_in_available(M.r_store, FALSE)

				var/obj/item/shirt = M.get_slot(SLOT_W_UNIFORM)
				M.drop_from_slot(shirt)
				qdel(shirt)

				var/obj/item/shoes = M.get_slot(SLOT_SHOES)
				M.drop_from_slot(shoes)
				qdel(shoes)

			else
				var/obj/item/clothing/lanyard/L = new /obj/item/clothing/lanyard(M.loc)
				var/obj/item/card/id = locate() in M
				if (id)
					L.storage.add_contents(id, M, FALSE)
				if (M.l_store)
					M.stow_in_available(M.l_store)
				M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_L_STORE)
				M.equip_if_possible(L, SLOT_WEAR_ID, TRUE)

			if(morph) // now that we've handled weird mutantrace cases, morph them
				M.set_mutantrace(morph)

/datum/job/daily/musician
	day = "Saturday"
	name = "Musician"
	limit = 3
	wages = PAY::UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/pinstripe)
	slot_head = list(/obj/item/clothing/head/flatcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/storage/briefcase/instruments)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Musician"
