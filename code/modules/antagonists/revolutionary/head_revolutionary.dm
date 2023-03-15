/datum/antagonist/head_revolutionary
	id = ROLE_HEAD_REVOLUTIONARY
	display_name = "head revolutionary"

	var/static/list/datum/mind/heads_of_staff

	New()
		if (!src.heads_of_staff)
			src.heads_of_staff = list()

			for(var/mob/living/carbon/human/player in mobs)
				if(player.mind)
					var/role = player.mind.assigned_role
					if(role in list(
							"Captain",
							"Head of Security",
							"Head of Personnel",
							"Chief Engineer",
							"Research Director",
							"Medical Director",
							"Communications Officer"
							))
						src.heads_of_staff += player.mind

		. = ..()

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/gamemode = ticker.mode
			if (!(src.owner in gamemode.head_revolutionaries))
				gamemode.head_revolutionaries += src.owner
			gamemode.update_rev_icons_added(src.owner)

	disposing()
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/gamemode = ticker.mode
			if (src.owner in gamemode.head_revolutionaries)
				gamemode.head_revolutionaries -= src.owner

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

		// Attempt to locate the owner's PDA or radio headset.
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
			if (!(H.equip_if_possible(S, H.slot_in_backpack)))
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

	assign_objectives()
		for(var/datum/mind/head_mind in src.heads_of_staff)
			var/datum/objective/regular/assassinate/objective = new(null, src.owner, src)
			objective.find_target_by_role(head_mind.assigned_role)
