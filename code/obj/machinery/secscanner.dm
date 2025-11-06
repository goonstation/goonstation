TYPEINFO(/obj/machinery/secscanner)
	mats = 18
	start_speech_modifiers = list(SPEECH_MODIFIER_MACHINERY)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

/obj/machinery/secscanner
	name = "security scanner"
	desc = "The latest innovation in invasive imagery, the programmable NT-X100 will scan anyone who walks through it with fans to simulate being patted down. <em>Nanotrasen is not to be held responsible for any deaths caused by the results the machine gives, or the machine itself.</em>"
	icon = 'icons/obj/machines/scanner.dmi'
	icon_state = "scanner_on"
	density = 0
	opacity = 0
	anchored = ANCHORED
	layer = 2
	deconstruct_flags = DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	power_usage = 5
	speech_verb_say = "beeps"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD

	var/timeBetweenUses = 20//I can see this being fun
	var/success_sound = 'sound/machines/chime.ogg'
	var/fail_sound = 'sound/machines/alarm_a.ogg'

	var/weapon_access = access_carrypermit
	var/contraband_access = access_contrabandpermit
	var/report_scans = 1
	var/check_records = 1

	var/last_perp = 0
	var/last_contraband = 0
	//var/area/area = 0
	var/emagged = 0

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)

	Crossed(atom/movable/AM)
		if(isliving(AM) && !isintangible(AM))
			src.do_scan(AM)
		else if (isobserver(AM) && prob(1))
			src.do_scan(AM)
		else if (istype(AM, /obj/item) && (!src.emagged))
			src.do_scan_item(AM)
		return ..()

	process()
		.=..()
		if (status & NOPOWER)
			icon_state = "scanner_off"
		else
			icon_state = "scanner_on"

	attackby(obj/item/W, mob/user) //If we get emagged...
		if (istype(W, /obj/item/card/emag) && (!emagged))
			src.add_fingerprint(user)
			emagged++
			user.show_text( "You 're-purpose' the [src].", "red" )
		..()

	proc/do_scan_item (var/obj/item/I)
		if( icon_state != "scanner_on" )
			return
		src.use_power(15)

		var/contraband = 0

		contraband += GET_ATOM_PROPERTY(I,PROP_MOVABLE_VISIBLE_CONTRABAND)
		contraband += GET_ATOM_PROPERTY(I,PROP_MOVABLE_VISIBLE_GUNS)

		if (contraband > 2)
			playsound( src.loc, fail_sound, 10, 0 )
			icon_state = "scanner_red"
			src.use_power(15)

			//////PDA NOTIFY/////
			if (src.report_scans && (I.name != last_perp || contraband != last_contraband))
				var/scan_location = get_area(src)

				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=list(MGD_SECURITY, MGA_CHECKPOINT), "sender"="00000000", "message"="Notification: An item [I.name] failed checkpoint scan at [scan_location]! Threat Level : [contraband]")
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal)

				last_perp = I.name
				last_contraband = contraband

			SPAWN(timeBetweenUses)
				icon_state = "scanner_on"




	proc/do_scan( var/mob/target )
		if( icon_state != "scanner_on" )
			return
		src.use_power(15)

		var/contraband = assess_perp(target)
		contraband = min(contraband,10)

		if (src.emagged) //if emagged, instead of properly doing our job as a scanner perform a completely arbitrary vibe check

			if(prob(20)) //vibe check FAILED >:((((
				playsound(src.loc, fail_sound, 10, 1)
				icon_state = "scanner_red"
				target.show_text( "You feel [pick("unfortunate", "bad", "like your fate has been sealed", "anxious", "scared", "overwhelmed")].", "red" )
				if (ishuman(target))
					var/mob/living/carbon/human/H = target
					var/perpname = H.name
					src.use_power(15)
					src.say("[uppertext(perpname)] HAS FAILED THE VIBE CHECK! BAD VIBES! BAD VIBES!!")

				//////PDA NOTIFY/////
				if (src.report_scans)
					var/scan_location = get_area(src)

					if (ishuman(target))
						var/mob/living/carbon/human/H = target
						var/perpname = H.name
						if (H:wear_id && H:wear_id:registered)
							perpname = H.wear_id:registered

						if (perpname != last_perp || contraband != last_contraband)
							var/datum/signal/pdaSignal = get_free_signal()
							pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=list(MGD_SECURITY, MGA_CHECKPOINT), "sender"="00000000", "message"="NOTIFICATION: [uppertext(perpname)] FAILED A VIBE CHECK AT [uppertext(scan_location)]! BAD VIBES LEVEL : [contraband]")
							SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal)

						last_perp = perpname
						last_contraband = contraband





			else  //Vibe check passed everything is good :)))
				target.show_text( "You feel [pick("good", "like you dodged a bullet", "lucky", "clean", "safe", "accepted")].", "blue" )
				playsound(src.loc, success_sound, 10, 1)
				icon_state = "scanner_green"

			SPAWN(timeBetweenUses)
				icon_state = "scanner_on"

			return //no, we're a vibe checker not a security device. our work is done

		if (contraband >= 4)
			contraband = round(contraband)

			playsound( src.loc, fail_sound, 10, 0 )
			icon_state = "scanner_red"
			src.use_power(15)

			//////PDA NOTIFY/////
			if (src.report_scans)
				var/scan_location = get_area(src)

				if (ishuman(target))
					var/mob/living/carbon/human/H = target
					var/perpname = H.name

					if (perpname != last_perp || contraband != last_contraband)
						var/datum/signal/pdaSignal = get_free_signal()
						pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=list(MGD_SECURITY, MGA_CHECKPOINT), "sender"="00000000", "message"="Notification: [perpname] failed checkpoint scan at [scan_location]! Threat Level : [contraband]")
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal)

					last_perp = perpname
					last_contraband = contraband

		else
			playsound(src.loc, success_sound, 10, 1)
			icon_state = "scanner_green"

		SPAWN(timeBetweenUses)
			icon_state = "scanner_on"

	//lol, sort of copied from secbot.dm
	proc/assess_perp(mob/target as mob)
		var/threatcount = 0

		if(src.emagged)
			return rand(99,2000) //very high-end bad vibes level assessor

		var/has_carry_permit = FALSE
		var/has_contraband_permit = FALSE

		if (!ishuman(target))
			if (istype(target, /mob/living/critter/changeling))
				return 6

			if (issilicon(target))
				var/mob/living/silicon/S = target
				var/obj/item/card/id/perp_id = S.botcard
				if(weapon_access in perp_id.access)
					has_carry_permit = TRUE
				if(contraband_access in perp_id.access)
					has_contraband_permit = TRUE

			for(var/obj/item/item in target.contents)
				threatcount += GET_ATOM_PROPERTY(item,PROP_MOVABLE_VISIBLE_CONTRABAND)
				threatcount += GET_ATOM_PROPERTY(item,PROP_MOVABLE_VISIBLE_GUNS)
			return threatcount

		var/mob/living/carbon/human/perp = target

		//yass TODO: move this to a var on mutantrace
		if (istype(perp.mutantrace, /datum/mutantrace/abomination))
			threatcount += 8
		else if (istype(perp.mutantrace, /datum/mutantrace/zombie))
			threatcount += 6
		else if (istype(perp.mutantrace, /datum/mutantrace/werewolf) || istype(perp.mutantrace, /datum/mutantrace/hunter))
			threatcount += 4
		else if (istype(perp.mutantrace, /datum/mutantrace/cat))
			threatcount += 3

		if(perp.traitHolder.hasTrait("stowaway") && perp.traitHolder.hasTrait("jailbird"))
			if(isnull(data_core.security.find_record("name", perp.name)))
				threatcount += 5

		//if((isnull(perp:wear_id)) || (istype(perp:wear_id, /obj/item/card/id/syndicate)))
		var/obj/item/card/id/perp_id = perp.equipped()
		if (!istype(perp_id))
			perp_id = perp.wear_id

		if(perp_id) //Checking for permits
			if(weapon_access in perp_id.access)
				has_carry_permit = TRUE
			if(contraband_access in perp_id.access)
				has_contraband_permit = TRUE

		if (!has_contraband_permit)
			threatcount += GET_ATOM_PROPERTY(perp, PROP_MOVABLE_VISIBLE_CONTRABAND)

			if (istype(perp.l_store))
				threatcount += GET_ATOM_PROPERTY(perp.l_store, PROP_MOVABLE_VISIBLE_CONTRABAND) * 0.5

			if (istype(perp.r_store))
				threatcount += GET_ATOM_PROPERTY(perp.r_store, PROP_MOVABLE_VISIBLE_CONTRABAND) * 0.5

			if (istype(perp.back) && perp.back?.storage)
				for(var/obj/item/item in perp.back.storage.get_contents())
					threatcount += GET_ATOM_PROPERTY(item, PROP_MOVABLE_VISIBLE_CONTRABAND) * 0.5

		if (!has_carry_permit)
			threatcount += GET_ATOM_PROPERTY(perp, PROP_MOVABLE_VISIBLE_GUNS)

			if (istype(perp.l_store))
				threatcount += GET_ATOM_PROPERTY(perp.l_store, PROP_MOVABLE_VISIBLE_GUNS) * 0.5

			if (istype(perp.r_store))
				threatcount += GET_ATOM_PROPERTY(perp.r_store, PROP_MOVABLE_VISIBLE_GUNS) * 0.5

			if (istype(perp.back) && perp.back?.storage)
				for(var/obj/item/item in perp.back.storage.get_contents())
					threatcount += GET_ATOM_PROPERTY(item, PROP_MOVABLE_VISIBLE_GUNS) * 0.5

		//Agent cards lower threatlevel
		if(istype(perp_id, /obj/item/card/id/syndicate))
			threatcount -= 2

		// we have grounds to make an arrest, don't bother with further analysis
		if(threatcount >= 4)
			return threatcount

		if (src.check_records)
			var/perpname = perp.face_visible() ? perp.real_name : perp.name

			for (var/datum/db_record/R as anything in data_core.security.find_records("name", perpname))
				if(R["criminal"] == ARREST_STATE_ARREST)
					threatcount = max(4,threatcount)
					break

		return threatcount

	ex_act(severity)
		switch (severity)
			if (1)
				qdel(src)
			if (2,3)
				if(!prob(60 + severity*10))
					qdel(src)


/obj/machinery/fakesecscanner
	name = "security scanner"
	desc = "The latest innovation in invasive imagery, the programmable NT-X100 will scan anyone who walks through it with fans to simulate being patted down. <em>Nanotrasen is not to be held responsible for any deaths caused by the results the machine gives, or the machine itself. ... Is this one even working properly?</em>"
	icon = 'icons/obj/machines/scanner.dmi'
	icon_state = "scanner_on"
