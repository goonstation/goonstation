/datum/antagonist/nuclear_operative
	id = ROLE_NUKEOP
	display_name = "\improper Syndicate Operative"

	var/static/commander_title
	var/static/available_callsigns

	New(datum/mind/new_owner)
		if (!src.commander_title)
			src.commander_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord", "General", "Warlord", "Commissar")

		if (!src.available_callsigns)
			var/list/callsign_pool_keys = list("nato", "melee_weapons", "colors", "birds", "mammals", "moons", "arthurian")
			src.available_callsigns = strings("agent_callsigns.txt", pick(callsign_pool_keys))

		src.owner = new_owner
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if (!(src.owner in gamemode.syndicates))
				gamemode.syndicates += src.owner

		. = ..()

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, "<span class='alert'>Due to your lack of opposable thumbs, the Syndicate was unable to provide you with your equipment. That's biology for you.</span>")
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		H.unequip_all(TRUE)

		H.equip_if_possible(new /obj/item/clothing/under/misc/syndicate(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/swat/noslip(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/gloves/swat(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/storage/backpack/syndie/tactical(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/swat/syndicate(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/requisition_token/syndicate(H), H.slot_r_store)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), H.slot_l_store)

		if(src.id == ROLE_NUKEOP_COMMANDER)
			H.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/commissar_cap(H), H.slot_head)
			H.equip_if_possible(new /obj/item/clothing/suit/space/syndicate/commissar_greatcoat(H), H.slot_wear_suit)
			H.equip_if_possible(new /obj/item/device/radio/headset/syndicate/leader(H), H.slot_ears)
			H.equip_if_possible(new /obj/item/swords_sheaths/nukeop(H), H.slot_belt)
			H.equip_if_possible(new /obj/item/device/nukeop_commander_uplink(H), H.slot_l_hand)
		else
			H.equip_if_possible(new /obj/item/device/radio/headset/syndicate(H), H.slot_ears)

		H.equip_sensory_items()

		var/obj/item/card/id/syndicate/ID
		if(src.id == ROLE_NUKEOP_COMMANDER)
			ID = new /obj/item/card/id/syndicate/commander(H)
		else
			ID = new /obj/item/card/id/syndicate(H)

		H.equip_if_possible(ID, H.slot_wear_id)

		new /obj/item/implant/revenge/microbomb(H)

		boutput(H, "<span class='alert'>Your headset allows you to communicate on the Syndicate radio channel by prefacing messages with :h, as (say \":h Agent reporting in!\").</span>")
		src.assign_name()

	relocate()
		var/mob/M = src.owner.current
		if (src.id == ROLE_NUKEOP_COMMANDER)
			M.set_loc(pick_landmark(LANDMARK_SYNDICATE_BOSS))
		else
			M.set_loc(pick_landmark(LANDMARK_SYNDICATE))

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/nuclear, src)

	remove_self()
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if (src.owner in gamemode.syndicates)
				gamemode.syndicates -= src.owner

		. = ..()

	proc/assign_name()
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/nuclear))
			if (src.id == ROLE_NUKEOP_COMMANDER)
				src.owner.current.real_name = "[syndicate_name()] [src.commander_title]"
			else
				var/callsign = pick(src.available_callsigns)
				src.available_callsigns -= callsign
				src.owner.current.real_name = "[syndicate_name()] Operative [callsign]"

				// Assign a headset icon to the Operative matching the first letter of their callsign.
				var/obj/item/device/radio/headset/syndicate/headset = src.owner.current.ears
				headset.icon_override = "syndie_letters/[copytext(callsign, 1, 2)]"

		else
			if (src.id == ROLE_NUKEOP_COMMANDER)
				src.owner.current.real_name = "Syndicate Commander [src.owner.current.real_name]"
			else
				src.owner.current.real_name = "Syndicate Operative [src.owner.current.real_name]"

/datum/antagonist/nuclear_operative/commander
	id = ROLE_NUKEOP_COMMANDER
	display_name = "\improper Syndicate Operative Commander"
