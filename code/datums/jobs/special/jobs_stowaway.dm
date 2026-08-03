/datum/job/special/stowaway
	name = "Stowaway"
	limit = 0 // set in New()
	wages = 0
	trait_list = list("stowaway")
	add_to_manifest = FALSE
	radio_announcement = FALSE
	low_priority_job = TRUE
	rounds_needed_to_play = ROUNDS_MIN_SECASS
	slot_card = null
	slot_head = list(\
	/obj/item/clothing/head/green = 1,
	/obj/item/clothing/head/red = 1,
	/obj/item/clothing/head/constructioncone = 1,
	/obj/item/clothing/head/helmet/welding = 1,
	/obj/item/clothing/head/helmet/hardhat = 1,
	/obj/item/clothing/head/serpico = 1,
	/obj/item/clothing/head/souschefhat = 1,
	/obj/item/clothing/head/maid = 1,
	/obj/item/clothing/head/cowboy = 1)

	slot_mask = list(\
	/obj/item/clothing/mask/gas = 1,
	/obj/item/clothing/mask/surgical = 1,
	/obj/item/clothing/mask/skull = 1,
	/obj/item/clothing/mask/bandana/white = 1)

	slot_ears = list(\
	/obj/item/device/radio/headset/civilian = 8,
	/obj/item/device/radio/headset/engineer = 1,
	/obj/item/device/radio/headset/research = 1,
	/obj/item/device/radio/headset/shipping = 1,
	/obj/item/device/radio/headset/medical = 1,
	/obj/item/device/radio/headset/miner = 1)

	slot_suit = list(\
	/obj/item/clothing/suit/wintercoat/engineering = 1,
	/obj/item/clothing/suit/wintercoat/robotics = 1,
	/obj/item/clothing/suit/labcoat = 1,
	/obj/item/clothing/suit/labcoat/robotics = 1,
	/obj/item/clothing/suit/wintercoat/research = 1)

	slot_jump = list(\
	/obj/item/clothing/under/color/grey = 1,
	/obj/item/clothing/under/rank/security/assistant = 1,
	/obj/item/clothing/under/rank/roboticist = 1,
	/obj/item/clothing/under/rank/engineer = 1,
	/obj/item/clothing/under/rank/orangeoveralls = 1,
	/obj/item/clothing/under/rank/orangeoveralls/yellow = 1,
	/obj/item/clothing/under/gimmick/maid = 1,
	/obj/item/clothing/under/rank/bartender = 1,
	/obj/item/clothing/under/misc/souschef = 1,
	/obj/item/clothing/under/rank/hydroponics = 1,
	/obj/item/clothing/under/rank/rancher = 1,
	/obj/item/clothing/under/rank/overalls = 1,
	/obj/item/clothing/under/rank/cargo = 1,
	/obj/item/clothing/under/rank/assistant = 10,
	/obj/item/clothing/under/rank/janitor = 1)

	slot_glov = list(\
	/obj/item/clothing/gloves/yellow/unsulated = 1,
	/obj/item/clothing/gloves/black = 1,
	/obj/item/clothing/gloves/fingerless = 1,
	/obj/item/clothing/gloves/long = 1)

	slot_foot = list(\
	/obj/item/clothing/shoes/brown = 6,
	/obj/item/clothing/shoes/red = 1,
	/obj/item/clothing/shoes/white = 1,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/shoes/swat = 1,
	/obj/item/clothing/shoes/orange = 1,
	/obj/item/clothing/shoes/westboot/brown/rancher = 1,
	/obj/item/clothing/shoes/galoshes = 1)

	slot_back = list(\
	/obj/item/storage/backpack = 3,
	/obj/item/storage/backpack/anello = 1,
	/obj/item/storage/backpack/security = 1,
	/obj/item/storage/backpack/engineering = 1,
	/obj/item/storage/backpack/research = 1,
	/obj/item/storage/backpack/salvager = 1,
	/obj/item/storage/backpack/syndie/tactical = 0.2) //hehe

	slot_belt = list(\
	/obj/item/crowbar = 6,
	/obj/item/crowbar/red = 1,
	/obj/item/crowbar/yellow = 1,
	/obj/item/crowbar/blue = 1,
	/obj/item/crowbar/grey = 1,
	/obj/item/crowbar/orange = 1)

	slot_poc1 = list(\
	/obj/item/screwdriver = 1,
	/obj/item/screwdriver/yellow = 1,
	/obj/item/screwdriver/grey = 1,
	/obj/item/screwdriver/orange = 1)

	slot_poc2 = list(\
	/obj/item/scissors = 1,
	/obj/item/wirecutters = 1,
	/obj/item/wirecutters/yellow = 1,
	/obj/item/wirecutters/grey = 1,
	/obj/item/wirecutters/orange = 1,
	/obj/item/scissors/surgical_scissors = 1)

	items_in_backpack = list(\
	/obj/item/currency/buttcoin,
	/obj/item/currency/spacecash/fivehundred)

	New()
		. = ..()
		src.limit = rand(0,3)

#ifdef RP_MODE
#define STOWAWAY_ALERT "You are not an antagonist. While you are not employed by NanoTrasen, you should still act like a sane person that wants to remain on the station."
	special_setup(mob/M, no_special_spawn)
		. = ..()
		SPAWN(2) //Ghost spawn panel SPAWN(1) jank...
			if(!M.mind?.is_antagonist())
				tgui_alert(M, STOWAWAY_ALERT, "You are not an antagonist!")
#undef STOWAWAY_ALERT
#endif
