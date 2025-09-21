/datum/antagonist/head_revolutionary
	id = ROLE_HEAD_REVOLUTIONARY
	display_name = "head revolutionary"
	antagonist_icon = "rev_head"
	antagonist_panel_tab_type = /datum/antagonist_panel_tab/bundled/revolution
	wiki_link = "https://wiki.ss13.co/Revolutionary"

	var/static/list/datum/mind/heads_of_staff
	/// A list of items that this head revolutionary has purchased using their uplink.
	var/list/datum/syndicate_buylist/purchased_items = list()

	New()
		if (!src.heads_of_staff)
			src.heads_of_staff = list()

			for(var/mob/living/carbon/human/player in mobs)
				if(player.mind?.is_head_of_staff())
					src.heads_of_staff += player.mind

		. = ..()

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/gamemode = ticker.mode
			if (!(src.owner in gamemode.head_revolutionaries))
				gamemode.head_revolutionaries += src.owner

	disposing()
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/gamemode = ticker.mode
			if (src.owner in gamemode.head_revolutionaries)
				gamemode.head_revolutionaries -= src.owner

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	proc/find_uplink(var/mob/living/carbon/human/H, var/type)
		if(!ispath(type) || !istype(H))
			return FALSE
		var/uplink_source
		var/loc_string
		if (istype(H.belt, type))
			uplink_source = H.belt
			loc_string = "on your belt"
		else if (istype(H.wear_id, type))
			uplink_source = H.wear_id
			loc_string = "in your ID slot"
		else if (istype(H.r_store, type))
			uplink_source = H.r_store
			loc_string = "in your pocket"
		else if (istype(H.l_store, type))
			uplink_source = H.l_store
			loc_string = "in your pocket"
		else if (istype(H.ears, type))
			uplink_source = H.ears
			loc_string = "on your head"
		if(!uplink_source || !loc_string)
			return FALSE
		return list(uplink_source, loc_string)

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, SPAN_ALERT("Due to your lack of opposable thumbs, the Syndicate was unable to provide you with an uplink. That's biology for you."))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		var/obj/item/uplink_source = null
		var/loc_string = ""

		var/preferred_uplink = H.client?.preferences.preferred_uplink || PREFERRED_UPLINK_PDA
		// step 1 of uplinkification: find a source! Prioritize the preferred option, then PDA, then headset, then give up and just spawn one.
		if(preferred_uplink != PREFERRED_UPLINK_STANDALONE) //Standalone uplink, skip finding pda or headset
			var/preference_to_type = list(PREFERRED_UPLINK_PDA = /obj/item/device/pda2, PREFERRED_UPLINK_RADIO = /obj/item/device/radio)
			var/found_uplink_data = src.find_uplink(H, preference_to_type[preferred_uplink])
			if(!found_uplink_data) // Couldn't find preferred, let's try PDA
				found_uplink_data = src.find_uplink(H, /obj/item/device/pda2)
			if(!found_uplink_data) // Uh oh, last try!
				found_uplink_data = src.find_uplink(H, /obj/item/device/radio)
			if(found_uplink_data)
				uplink_source = found_uplink_data[1]
				loc_string = found_uplink_data[2]

		// Create the uplink.
		var/obj/item/uplink/uplink
		if (istype(uplink_source, /obj/item/device/pda2))
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/integrated/pda)
			uplink = new uplink_path(uplink_source)
		else if (istype(uplink_source, /obj/item/device/radio))
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/integrated/radio)
			uplink = new uplink_path(uplink_source)
		else
			// If the owner has no PDA or headset, create a Syndicate uplink.
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/syndicate)
			var/obj/item/uplink/syndicate/S = new uplink_path(get_turf(H))
			uplink = S
			uplink_source = S
			S.lock_code_autogenerate = TRUE
			if (!(H.equip_if_possible(S, SLOT_IN_BACKPACK)))
				loc_string = "on the ground beneath you"
			else
				loc_string = "in [H.back] on your back"
		uplink.setup(src.owner, uplink_source)

		// Inform the player about the uplink and save information regarding it to the owner's memory.
		if (istype(uplink_source, /obj/item/device/pda2))
			boutput(H, "The Syndicate have cunningly disguised a head revolutionary uplink as your [uplink_source.name] [loc_string]. Simply enter the the code <b>\"[uplink.lock_code]\"</b> as the ringtone in its Messenger app to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Head revolutionary PDA uplink created: [uplink_source.name]. Location given: [loc_string]. Code: [uplink.lock_code]")
			src.owner.store_memory("<b>Uplink password:</b> [uplink.lock_code].")
		else if (istype(uplink_source, /obj/item/device/radio))
			var/obj/item/device/radio/R = uplink_source
			boutput(H, "The Syndicate have cunningly disguised a head revolutionary uplink as your [uplink_source.name] [loc_string]. Simply dial the frequency <b>\"[R.traitor_frequency]\"</b> to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Head revolutionary uplink created: [uplink_source.name]. Location given: [loc_string]. Frequency: [R.traitor_frequency]")
			src.owner.store_memory("<b>Uplink frequency:</b> [R.traitor_frequency].")
		else
			boutput(H, "The Syndicate have provided you with a standalone head revolutionary uplink [loc_string]. Simply dial the frequency <b>\"[uplink.lock_code]\"</b> to unlock its hidden features.")
			logTheThing(LOG_DEBUG, H, "Head revolutionary standalone uplink created: [uplink_source.name]. Location given: [loc_string]. Frequency: [uplink.lock_code]")
			src.owner.store_memory("<b>Uplink frequency:</b> [uplink.lock_code].")

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_REVOLUTIONARY)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

		get_image_group(CLIENT_IMAGE_GROUP_HEADS_OF_STAFF).add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_REVOLUTIONARY)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)
		var/datum/client_image_group/heads_group = get_image_group(CLIENT_IMAGE_GROUP_HEADS_OF_STAFF)
		heads_group.remove_mind(src.owner)

	assign_objectives()
		for(var/datum/mind/head_mind in src.heads_of_staff)
			var/datum/objective/regular/assassinate/objective = new(null, src.owner, src)
			objective.find_target_by_role(head_mind.assigned_role)

	borged()
		SPAWN(0) //the transfer signals are sent in a funny order so we have to do this in order to prevent borgs being left with orphaned images
			src.remove_from_image_groups()

	unborged()
		SPAWN(0) //see above
			src.add_to_image_groups()

	get_statistics()
		var/list/purchased_items = list()
		for (var/datum/syndicate_buylist/purchased_item as anything in src.purchased_items)
			if(length(purchased_item.items) > 0)
				var/obj/item_type = initial(purchased_item.items[1])
				purchased_items += list(
					list(
						"iconBase64" = "[icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), frame = 1, dir = initial(item_type.dir)))]",
						"name" = "[purchased_item[1].name] ([purchased_item[1].cost] TC)",
					)
				)

		return list(
			list(
				"name" = "Purchased Items",
				"type" = "itemList",
				"value" = purchased_items,
			)
		)
