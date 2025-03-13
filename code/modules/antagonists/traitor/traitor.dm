/datum/antagonist/traitor
	id = ROLE_TRAITOR
	display_name = "traitor"
	antagonist_icon = "traitor"
	popup_name_override = "traitorhard" //Will be set to ROLE_TRAITOR once given an uplink

	/// Our initial uplink. This is only used to determine the popup shown to the player, so it isn't too important to track.
	var/obj/item/uplink/uplink
	/// A list of items that this traitor has purchased using their uplink. This tracks purchases made with any uplink, not just our own, so if a traitor is sassy and steals another antagonist's uplink, purchases will show up here too!
	var/list/datum/syndicate_buylist/purchased_items = list()
	/// If the traitor got a surplus crate, this list contains info about the items that were inside that crate.
	var/list/datum/syndicate_buylist/surplus_crate_items = list()

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, SPAN_ALERT("Due to your lack of opposable thumbs, the Syndicate was unable to provide you with an uplink. That's biology for you."))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		var/obj/item/uplink_source = null
		var/loc_string = ""

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/assday))
			boutput(H, "The Syndicate have clearly forgotten to give you a Syndicate Uplink. Lazy idiots.")
			H.show_antag_popup("traitorhard")
			return

		// step 1 of uplinkification: find a source! prioritize PDAs, then try headsets
		if (istype(H.belt, /obj/item/device/pda2) || istype(H.belt, /obj/item/device/radio))
			uplink_source = H.belt
			loc_string = "on your belt"
		else if (istype(H.wear_id, /obj/item/device/pda2))
			uplink_source = H.wear_id
			loc_string = "in your ID slot"
		else if (istype(H.r_store, /obj/item/device/pda2))
			uplink_source = H.r_store
			loc_string = "in your pocket"
		else if (istype(H.l_store, /obj/item/device/pda2))
			uplink_source = H.l_store
			loc_string = "in your pocket"
		else if (istype(H.ears, /obj/item/device/radio))
			uplink_source = H.ears
			loc_string = "on your head"

		// step 2 of uplinkification: put the actual uplink into the item, and save info about it to the owner's memory
		// if we find a valid item source, then we create one
		if (istype(uplink_source, /obj/item/device/pda2))
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/integrated/pda)
			src.uplink = new uplink_path(uplink_source)
		else if (istype(uplink_source, /obj/item/device/radio))
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/integrated/radio)
			src.uplink = new uplink_path(uplink_source)
		else
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/syndicate)
			var/obj/item/uplink/syndicate/S = new uplink_path(get_turf(H))
			src.uplink = S
			uplink_source = S
			S.lock_code_autogenerate = TRUE
			if (!(H.equip_if_possible(S, SLOT_IN_BACKPACK)))
				loc_string = "on the ground beneath you"
			else
				loc_string = "in [H.back] on your back"

		src.popup_name_override = ROLE_TRAITOR

		uplink.setup(src.owner, uplink_source)

		// step 3 of uplinkification: inform the player about it and store the code in their memory
		if (istype(uplink_source, /obj/item/device/pda2))
			boutput(H, "The Syndicate have cunningly disguised an uplink as your [uplink_source.name] [loc_string]. Simply enter the the code <b>\"[uplink.lock_code]\"</b> as the ringtone in its Messenger app to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Traitor PDA uplink created: [uplink_source.name]. Location given: [loc_string]. Code: [uplink.lock_code]")
			src.owner.store_memory("<b>Uplink password:</b> [uplink.lock_code].")
		else if (istype(uplink_source, /obj/item/device/radio))
			var/obj/item/device/radio/R = uplink_source
			boutput(H, "The Syndicate have cunningly disguised an uplink as your [uplink_source.name] [loc_string]. Simply dial the frequency <b>\"[R.traitor_frequency]\"</b> to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Traitor uplink created: [uplink_source.name]. Location given: [loc_string]. Frequency: [R.traitor_frequency]")
			src.owner.store_memory("<b>Uplink frequency:</b> [R.traitor_frequency].")
		else
			boutput(H, "The Syndicate have provided you with a standalone uplink [loc_string]. Simply dial the frequency <b>\"[uplink.lock_code]\"</b> to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Traitor standalone uplink created: [uplink_source.name]. Location given: [loc_string]. Frequency: [uplink.lock_code]")
			src.owner.store_memory("<b>Uplink frequency:</b> [uplink.lock_code].")

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_TRAITOR)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())

	remove_from_image_groups()
		. = ..()
		get_image_group(ROLE_TRAITOR).remove_mind_mob_overlay(src.owner)

	assign_objectives()
		var/datum/objective_set/objective_set_path
		#ifdef RP_MODE
		objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
		#else
		objective_set_path = pick(typesof(/datum/objective_set/traitor))
		#endif
		new objective_set_path(src.owner, src)

	get_statistics()
		var/list/purchased_items = list()
		for (var/datum/syndicate_buylist/purchased_item as anything in src.purchased_items)
			if(length(purchased_item.items) > 0)
				var/obj/item_type = initial(purchased_item.items[1])
				purchased_items += list(
					list(
						"iconBase64" = "[icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), frame = 1, dir = initial(item_type.dir)))]",
						"name" = "[purchased_item.name] ([purchased_item.cost] TC)",
					)
				)

		. = list(
			list(
				"name" = "Purchased Items",
				"type" = "itemList",
				"value" = purchased_items,
			)
		)

		var/list/crate_items = list()
		if (length(src.surplus_crate_items))
			for (var/datum/syndicate_buylist/crate_item as anything in src.surplus_crate_items)
				if(length(crate_item.items) > 0)
					var/obj/item_type = initial(crate_item.items[1])
					crate_items += list(
						list(
							"iconBase64" = "[icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), frame = 1, dir = initial(item_type.dir)))]",
							"name" = "[crate_item.name]",
						)
					)

			. += list(
				list(
					"name" = "Surplus Crate Items",
					"type" = "itemList",
					"value" = crate_items,
				)
			)
