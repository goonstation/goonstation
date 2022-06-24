/datum/antagonist/traitor
	id = ROLE_TRAITOR
	display_name = "traitor"
	
	/// Our initial uplink. This is only used to determine the popup shown to the player, so it isn't too important to track.
	var/obj/item/uplink/uplink
	
	give_equipment()
		if (!ishuman(owner.current))
			boutput(owner.current, "<span class='alert'>Due to your lack of opposable thumbs, the Syndicate was unable to provide you with an uplink. That's biology for you.</span>")
			return FALSE
		var/mob/living/carbon/human/H = owner.current
		var/obj/item/uplink_source = null
		var/loc_string = ""

		// step 1 of uplinkification: find a source! prioritize PDAs, then try headsets
		if (istype(H.belt, /obj/item/device/pda2) || istype(H.belt, /obj/item/device/radio))
			uplink_source = H.belt
			loc_string = "on your belt"
		else if (istype(H.r_store, /obj/item/device/pda2))
			uplink_source = H.r_store
			loc_string = "in your pocket"
		else if (!istype(H.l_store, /obj/item/device/pda2))
			uplink_source = H.l_store
			loc_string = "in your pocket"
		else if (istype(H.ears, /obj/item/device/radio))
			uplink_source = H.ears
			loc_string = "on your head"
		
		// step 2 of uplinkification: put the actual uplink into the item, and save info about it to the owner's memory
		// if we find a valid item source, then we create one
		if (istype(uplink_source, /obj/item/device/pda2))
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/integrated/pda)
			src.uplink = new uplink_path (uplink_source)
		else if (istype(uplink_source, /obj/item/device/radio))
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/integrated/radio)
			src.uplink = new uplink_path (uplink_source)
		else
			var/uplink_path = get_uplink_type(H, /obj/item/uplink/syndicate)
			var/obj/item/uplink/syndicate/S = new uplink_path (get_turf(H))
			src.uplink = S
			uplink_source = S
			S.lock_code_autogenerate = TRUE
			loc_string = "on the ground beneath you"
		uplink.setup(owner, uplink_source)

		// step 3 of uplinkification: inform the player about it and store the code in their memory
		if (istype(uplink_source, /obj/item/device/pda2))
			boutput(H, "The Syndicate have cunningly disguised an uplink as your [uplink_source.name] [loc_string]. Simply enter the the code <b>\"[uplink.lock_code]\"</b> as the ringtone in its Messenger app to unlock its hidden features.")
			owner.store_memory("<b>Uplink password:</b> [uplink.lock_code].")
		else if (istype(uplink_source, /obj/item/device/radio))
			boutput(H, "The Syndicate have cunningly disguised an uplink as your [uplink_source.name] [loc_string]. Simply dial the frequency <b>\"[uplink.lock_code]\"</b> to unlock its hidden features.")
			owner.store_memory("<b>Uplink frequency:</b> [uplink.lock_code].")
		else
			boutput(H, "The Syndicate have provided you with a standalone uplink [loc_string]. Simply dial the frequency <b>\"[uplink.lock_code]\"</b> to unlock its hidden features.")
			owner.store_memory("<b>Uplink frequency:</b> [uplink.lock_code].")
	
	assign_objectives()
		var/datum/objective_set/objective_set_path
		#ifdef RP_MODE
		objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
		#else
		objective_set_path = pick(typesof(/datum/objective_set/traitor))
		#endif
		new objective_set_path(owner)

	do_popup(override)
		if (!override) // Display a different popup depending on the type of uplink we got
			if (!uplink)
				override = "traitorhard"
			else if (istype(uplink, /obj/item/uplink/integrated/pda))
				override = "traitorpda"
			else if (istype(uplink, /obj/item/uplink/integrated/radio))
				override = "traitorradio"
			else
				override = "traitorgeneric"
		..(override)
