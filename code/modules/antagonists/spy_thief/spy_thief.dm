/datum/antagonist/spy_thief
	id = ROLE_SPY_THIEF
	display_name = "spy thief"
	antagonist_icon = "spy_thief"

	/// A list of mutable appearnces of items that this traitor has stolen using their uplink. This tracks items stolen with any uplink, so if a spy thief steals another spy thief's uplink, stolen items will show up here too!
	/// Associative list of string names to mutable appearances
	var/list/mutable_appearance/stolen_items = list()
	/// A list of buylist datums that this traitor has redeemed using their uplink.
	///
	///This tracks items redeemed with any uplink, so if a spy thief steals another spy thief's uplink, redeemed items will show up here too!
	var/list/datum/syndicate_buylist/redeemed_items = list()


	New()
		if (!ticker?.mode?.spy_market)
			ticker.mode.spy_market = new /datum/game_mode/spy_theft
			SPAWN(5 SECONDS)
				ticker.mode.spy_market.build_bounty_list()
				ticker.mode.spy_market.update_bounty_readouts()

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, SPAN_ALERT("Due to your lack of opposable thumbs, the Syndicate was unable to provide you with an uplink. That's biology for you."))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		var/obj/item/device/pda2/uplink_source = null
		var/loc_string = ""

		// Attempt to locate the owner's PDA.
		if (istype(H.belt, /obj/item/device/pda2))
			uplink_source = H.belt
			loc_string = "on your belt"
		else if (istype(H.wear_id, /obj/item/device/pda2))
			uplink_source = H.wear_id
			loc_string = "in your ID slot"
		else if (istype(H.r_store, /obj/item/device/pda2))
			uplink_source = H.r_store
			loc_string = "in your right pocket"
		else if (istype(H.l_store, /obj/item/device/pda2))
			uplink_source = H.l_store
			loc_string = "in your left pocket"
		else if (istype(H.l_hand, /obj/item/device/pda2))
			uplink_source = H.l_hand
			loc_string = "in your left hand"
		else if (istype(H.r_hand, /obj/item/device/pda2))
			uplink_source = H.r_hand
			loc_string = "in your right hand"
		else
			for (var/obj/item/device/pda2/foo in H.l_hand?.storage?.get_contents())
				uplink_source = foo
				loc_string = "in the [H.l_hand.name] in your left hand"
				break
			for (var/obj/item/device/pda2/foo in H.r_hand?.storage?.get_contents())
				uplink_source = foo
				loc_string = "in the [H.r_hand.name] in your right hand"
				break
			for (var/obj/item/device/pda2/foo in H.back?.storage?.get_contents())
				uplink_source = foo
				loc_string = "in the [H.back.name] on your back"
				break
			for (var/obj/item/device/pda2/foo in H.belt?.storage?.get_contents())
				uplink_source = foo
				loc_string = "in the [H.belt.name] on your belt"
				break

		// If the owner has no PDA, create one.
		if (!uplink_source)
			uplink_source = new /obj/item/device/pda2(H)
			uplink_source.owner = H.real_name // So they don't need to get an ID first
			loc_string = "in your backpack"
			if (H.equip_if_possible(uplink_source, SLOT_IN_BACKPACK) == 0)
				uplink_source.set_loc(get_turf(H))
				loc_string = "on the floor"

		// Create the uplink, and save information regarding it to the owner's memory.
		if (istype(uplink_source, /obj/item/device/pda2))
			var/obj/item/device/pda2/PDA = uplink_source
			var/obj/item/uplink/integrated/pda/spy/uplink = new /obj/item/uplink/integrated/pda/spy(PDA)
			uplink.setup(H.mind, PDA)

			boutput(H, "The Syndicate have cunningly disguised a spy thief uplink as your [uplink_source.name] [loc_string]. Simply enter the the code <b>\"[uplink.lock_code]\"</b> as the ringtone in its Messenger app to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Spy Thief PDA uplink created: [uplink_source.name]. Location given: [loc_string]. Code: [uplink.lock_code]")
			src.owner.store_memory("<b>Uplink password:</b> [uplink.lock_code].")

		// Provide the owner with a spy camera.
		if (!H.r_store)
			H.equip_if_possible(new /obj/item/camera/spy(H), SLOT_R_STORE)
		else if (!H.l_store)
			H.equip_if_possible(new /obj/item/camera/spy(H), SLOT_L_STORE)
		else if (H.back?.storage && !H.back.storage.is_full())
			H.equip_if_possible(new /obj/item/camera/spy(H), SLOT_IN_BACKPACK)
		else
			var/obj/camera = new /obj/item/camera/spy(get_turf(H))
			H.put_in_hand_or_drop(camera)

	assign_objectives()
		var/datum/objective_set/objective_set_path = pick(typesof(/datum/objective_set/spy_theft))
		new objective_set_path(src.owner, src)

	handle_round_end()
		. = ..()

		if (length(src.stolen_items) >= 7)
			src.owner.current.unlock_medal("Professional thief", TRUE)

	get_statistics()
		var/list/stolen_items = list()
		for (var/item_name in src.stolen_items)
			var/mutable_appearance/stolen_item = src.stolen_items[item_name]
			var/icon/stolen_icon
			if (stolen_item)
				stolen_icon = getFlatIcon(stolen_item, no_anim=TRUE)
			else
				stolen_icon = icon('icons/obj/decals/writing.dmi', "cQuestion Mark")

			stolen_items += list(
				list(
					"iconBase64" = icon2base64(stolen_icon),
					"name" = "[item_name]",
				)
			)

		var/list/redeemed_items = list()
		for (var/datum/syndicate_buylist/redeemed_entry as anything in src.redeemed_items)
			if(length(redeemed_entry.items) > 0)
				var/obj/item_type = initial(redeemed_entry.items[1])
				redeemed_items += list(
					list(
						"iconBase64" = "[icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), frame = 1, dir = initial(item_type.dir)))]",
						"name" = "[initial(redeemed_entry.name)]",
					)
				)

		return list(
			list(
				"name" = "Stolen Items",
				"type" = "itemList",
				"value" = stolen_items,
			),
			list(
				"name" = "Redeemed Items",
				"type" = "itemList",
				"value" = redeemed_items,
			),
		)
