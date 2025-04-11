/datum/antagonist/nuclear_operative
	id = ROLE_NUKEOP
	display_name = "\improper Syndicate Operative"
	antagonist_icon = "syndicate"
	antagonist_panel_tab_type = /datum/antagonist_panel_tab/bundled/nuclear_operative
	faction = list(FACTION_SYNDICATE)
	uses_pref_name = FALSE

	var/static/commander_title
	var/static/available_callsigns
	var/list/datum/materiel/purchased_items = list() //Used for adding a nukie's vendor purchases to crew credits. Items are tracked by whoever interacts with the vendor, so if the whole team gives their credits to the commander, the commander will have multiple entries in the crew credits!
	var/list/datum/syndicate_buylist/uplink_items = list() // Same but for custom uplinks and the commander uplink

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
			boutput(src.owner.current, SPAN_ALERT("Due to your lack of opposable thumbs, the Syndicate was unable to provide you with your equipment. That's biology for you."))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		H.unequip_all(TRUE)

		H.equip_if_possible(new /obj/item/clothing/under/misc/syndicate(H), SLOT_W_UNIFORM)
		H.equip_if_possible(new /obj/item/clothing/shoes/swat/noslip(H), SLOT_SHOES)
		H.equip_if_possible(new /obj/item/clothing/gloves/swat/syndicate(H), SLOT_GLOVES)
		H.equip_if_possible(new /obj/item/storage/backpack/syndie/tactical(H), SLOT_BACK)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/swat/syndicate(H), SLOT_WEAR_MASK)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)
		H.equip_if_possible(new /obj/item/requisition_token/syndicate(H), SLOT_R_STORE)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), SLOT_L_STORE)

		if(src.id == ROLE_NUKEOP_COMMANDER)
			H.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/specialist/commissar_cap(H), SLOT_HEAD)
			H.equip_if_possible(new /obj/item/clothing/suit/space/syndicate/specialist/commissar_greatcoat(H), SLOT_WEAR_SUIT)
			H.equip_if_possible(new /obj/item/device/radio/headset/syndicate/leader(H), SLOT_EARS)
			H.equip_if_possible(new /obj/item/swords_sheaths/nukeop(H), SLOT_BELT)
			H.equip_if_possible(new /obj/item/device/nukeop_commander_uplink(H), SLOT_L_HAND)
			H.equip_if_possible(new /obj/item/pinpointer/disk, SLOT_IN_BACKPACK)
		else
			H.equip_if_possible(new /obj/item/device/radio/headset/syndicate(H), SLOT_EARS)

		H.equip_sensory_items()
		H.equip_body_traits(extended_tank=TRUE)

		var/obj/item/card/id/syndicate/ID
		if(src.id == ROLE_NUKEOP_COMMANDER)
			ID = new /obj/item/card/id/syndicate/commander(H)
		else
			ID = new /obj/item/card/id/syndicate(H)

		H.equip_if_possible(ID, SLOT_WEAR_ID)

		new /obj/item/implant/revenge/microbomb(H)

		boutput(H, SPAN_ALERT("Your headset allows you to communicate on the Syndicate radio channel by prefacing messages with :h, as (say \":h Agent reporting in!\")."))
		src.assign_name()

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	relocate()
		var/mob/M = src.owner.current
		if (src.id == ROLE_NUKEOP_COMMANDER)
			M.set_loc(pick_landmark(LANDMARK_SYNDICATE_BOSS))
		else
			//copied from /mob/living/proc/Equip_Rank - try to find an unoccupied chair but not for too long.
			var/tries = 8
			var/turf/T
			do
				T = pick_landmark(LANDMARK_SYNDICATE)
			while((locate(/mob) in T) && tries--)
			M.set_loc(T)
			//for completeness' sake, make em sit properly
			var/obj/stool/an_chair = locate() in T
			if(an_chair)
				M.set_dir(an_chair.dir)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/nuclear, src)

	remove_self()
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if (src.owner in gamemode.syndicates)
				gamemode.syndicates -= src.owner

		. = ..()

	get_statistics()
		var/list/purchases = list()
		// Add items purchased from the nukies weapon vendor
		for (var/datum/materiel/purchased_item in src.purchased_items)
			var/obj/item_type = initial(purchased_item.path)
			purchases += list(
				list(
					"iconBase64" = "[icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), frame = 1, dir = initial(item_type.dir)))]",
					"name" = "[purchased_item]",
				)
			)

		// Add items from custom uplinks and the commander's special uplink
		for (var/datum/syndicate_buylist/purchased_item in src.uplink_items)
			if(length(purchased_item.items) > 0)
				var/obj/item_type = initial(purchased_item.items[1])
				purchases += list(
					list(
						"iconBase64" = "[icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), frame = 1, dir = initial(item_type.dir)))]",
						"name" = "[purchased_item[1].name]", // Dont include TC cost bc commander uplink doesnt use TC
					)
				)

		. = list(
			list(
				"name" = "Purchased Items",
				"type" = "itemList",
				"value" = purchases,
			)
		)


	proc/assign_name()
		if (src.id == ROLE_NUKEOP_COMMANDER)
			src.owner.current.real_name = "[syndicate_name()] [src.commander_title]"
		else
			var/callsign = pick(src.available_callsigns)
			src.available_callsigns -= callsign
			src.owner.current.real_name = "[syndicate_name()] Operative [callsign]"

			// Assign a headset icon to the Operative matching the first letter of their callsign.
			var/obj/item/device/radio/headset/syndicate/headset = src.owner.current.ears
			headset.icon_override = "syndie_letters/[copytext(callsign, 1, 2)]"

/datum/antagonist/nuclear_operative/commander
	id = ROLE_NUKEOP_COMMANDER
	display_name = "\improper Syndicate Operative Commander"
	antagonist_icon = "syndcomm"
