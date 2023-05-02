/datum/antagonist/spy_thief
	id = ROLE_SPY_THIEF
	display_name = "spy thief"

	/// A list of items that this traitor has stolen using their uplink. This tracks items stolen with any uplink, so if a spy thief steals another spy thief's uplink, stolen items will show up here too!
	var/list/obj/stolen_items = list()
	/// A list of items that this traitor has redeemed using their uplink. This tracks items redeemed with any uplink, so if a spy thief steals another spy thief's uplink, redeemed items will show up here too!
	var/list/obj/redeemed_items = list()

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
			boutput(src.owner.current, "<span class='alert'>Due to your lack of opposable thumbs, the Syndicate was unable to provide you with an uplink. That's biology for you.</span>")
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		var/obj/item/uplink_source = null
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
			if (istype(H.l_hand, /obj/item/storage))
				var/obj/item/storage/S = H.l_hand
				var/list/L = S.get_contents()
				for (var/obj/item/device/pda2/foo in L)
					uplink_source = foo
					loc_string = "in the [S.name] in your left hand"
					break
			if (istype(H.r_hand, /obj/item/storage))
				var/obj/item/storage/S = H.r_hand
				var/list/L = S.get_contents()
				for (var/obj/item/device/pda2/foo in L)
					uplink_source = foo
					loc_string = "in the [S.name] in your right hand"
					break
			if (istype(H.back, /obj/item/storage))
				var/obj/item/storage/S = H.back
				var/list/L = S.get_contents()
				for (var/obj/item/device/pda2/foo in L)
					uplink_source = foo
					loc_string = "in the [S.name] on your back"
					break
			if (istype(H.belt, /obj/item/storage))
				var/obj/item/storage/S = H.belt
				var/list/L = S.get_contents()
				for (var/obj/item/device/pda2/foo in L)
					uplink_source = foo
					loc_string = "in the [S.name] on your belt"
					break

		// If the owner has no PDA, create one.
		if (!uplink_source)
			uplink_source = new /obj/item/device/pda2(H)
			loc_string = "in your backpack"
			if (H.equip_if_possible(uplink_source, H.slot_in_backpack) == 0)
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
			H.equip_if_possible(new /obj/item/camera/spy(H), H.slot_r_store)
		else if (!H.l_store)
			H.equip_if_possible(new /obj/item/camera/spy(H), H.slot_l_store)
		else if (istype(H.back, /obj/item/storage/) && H.back.contents.len < 7)
			H.equip_if_possible(new /obj/item/camera/spy(H), H.slot_in_backpack)
		else
			var/obj/camera = new /obj/item/camera/spy(get_turf(H))
			H.put_in_hand_or_drop(camera)

	assign_objectives()
		var/datum/objective_set/objective_set_path = pick(typesof(/datum/objective_set/spy_theft))
		new objective_set_path(src.owner, src)

	do_popup(override)
		if (!override)
			override = "spythief"

		..(override)

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat))
			var/num_of_stolen_items = length(src.stolen_items)
			var/stolen_item_detail
			if (num_of_stolen_items)
				stolen_item_detail = "<br>They stole: "
				for (var/obj/stolen_item as anything in src.stolen_items)
					stolen_item_detail += "[bicon(stolen_item)] [stolen_item.name], "
				stolen_item_detail = copytext(stolen_item_detail, 1, -2)
			dat.Insert(2, "They stole [num_of_stolen_items <= 0 ? "nothing" : "[num_of_stolen_items] item[s_es(num_of_stolen_items)]"] with their spy thief uplink![stolen_item_detail]")

			var/num_of_redeemed_items = length(src.redeemed_items)
			var/redeemed_item_detail
			if (num_of_redeemed_items)
				redeemed_item_detail = "<br>They redeemed: "
				for (var/obj/redeemed_item as anything in src.redeemed_items)
					redeemed_item_detail += "[bicon(redeemed_item)] [redeemed_item.name], "
				redeemed_item_detail = copytext(redeemed_item_detail, 1, -2)
			dat.Insert(3, "They redeemed [num_of_redeemed_items <= 0 ? "nothing" : "[num_of_redeemed_items] item[s_es(num_of_redeemed_items)]"] with their spy thief uplink![redeemed_item_detail]")

		if (length(src.stolen_items) >= 7)
			src.owner.current.unlock_medal("Professional thief", TRUE)

		return dat
