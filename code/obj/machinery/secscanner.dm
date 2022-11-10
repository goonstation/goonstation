/obj/machinery/secscanner
	name = "security scanner"
	desc = "The latest innovation in invasive imagery, the programmable NT-X100 will scan anyone who walks through it with fans to simulate being patted down. <em>Nanotrasen is not to be held responsible for any deaths caused by the results the machine gives, or the machine itself.</em>"
	icon = 'icons/obj/machines/scanner.dmi'
	icon_state = "scanner_on"
	density = 0
	opacity = 0
	anchored = 1
	layer = 2
	mats = 18
	deconstruct_flags = DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	appearance_flags = TILE_BOUND | PIXEL_SCALE
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
		MAKE_SENDER_RADIO_PACKET_COMPONENT("pda", FREQ_PDA)

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
		var/contraband = I.get_contraband()

		if (contraband >= 2)

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
					src.speak("[uppertext(perpname)] HAS FAILED THE VIBE CHECK! BAD VIBES! BAD VIBES!!")

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

		target.show_text( "You feel [pick("funny", "wrong", "confused", "dangerous", "sickly", "puzzled", "happy")].", "blue" )

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

		if (!ishuman(target))
			if (istype(target, /mob/living/critter/changeling))
				return 6
			for( var/obj/item/item in target.contents )
				threatcount += item.get_contraband()
			return threatcount

		var/mob/living/carbon/human/perp = target

		if (perp.mutantrace)
			if (istype(perp.mutantrace, /datum/mutantrace/abomination))
				threatcount += 8
			else if (istype(perp.mutantrace, /datum/mutantrace/zombie))
				threatcount += 6
			else if (istype(perp.mutantrace, /datum/mutantrace/werewolf) || istype(perp.mutantrace, /datum/mutantrace/hunter))
				threatcount += 4
			else if (istype(perp.mutantrace, /datum/mutantrace/cat))
				threatcount += 3

		if(perp.traitHolder.hasTrait("immigrant") && perp.traitHolder.hasTrait("jailbird"))
			if(isnull(data_core.security.find_record("name", perp.name)))
				threatcount += 5

		//if((isnull(perp:wear_id)) || (istype(perp:wear_id, /obj/item/card/id/syndicate)))
		var/obj/item/card/id/perp_id = perp.equipped()
		if (!istype(perp_id))
			perp_id = perp.wear_id

		var/has_carry_permit = 0
		var/has_contraband_permit = 0

		if (!has_contraband_permit)
			threatcount += GET_ATOM_PROPERTY(perp, PROP_MOVABLE_CONTRABAND_OVERRIDE)

		if(perp_id) //Checking for permits
			if(weapon_access in perp_id.access)
				has_carry_permit = 1
			if(contraband_access in perp_id.access)
				has_contraband_permit = 1

		if (istype(perp.l_hand))
			if (istype(perp.l_hand, /obj/item/gun/))  // perp is carrying a gun
				if(!has_carry_permit)
					threatcount += perp.l_hand.get_contraband()
			else // not carrying a gun
				if(!has_contraband_permit)
					threatcount += perp.l_hand.get_contraband()

		if (istype(perp.r_hand))
			if (istype(perp.r_hand, /obj/item/gun/)) // perp is carrying a gun
				if(!has_carry_permit)
					threatcount += perp.r_hand.get_contraband()
			else // not carrying a gun, but potential contraband?
				if(!has_contraband_permit)
					threatcount += perp.r_hand.get_contraband()

		if (istype(perp.wear_suit))
			if (!has_contraband_permit)
				threatcount += perp.wear_suit.get_contraband()

		if (istype(perp.belt))
			if (istype(perp.belt, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.belt.get_contraband() * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.belt.get_contraband() * 0.5
				for( var/obj/item/item in perp.belt.contents )
					if (istype(item, /obj/item/gun/))
						if (!has_carry_permit)
							threatcount += item.get_contraband() * 0.5
					else
						if (!has_contraband_permit)
							threatcount += item.get_contraband() * 0.5

		if (istype(perp.l_store))
			if (istype(perp.l_store, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.l_store.get_contraband() * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.l_store.get_contraband() * 0.5

		if (istype(perp.r_store))
			if (istype(perp.r_store, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.r_store.get_contraband() * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.r_store.get_contraband() * 0.5

		if (istype(perp.back))
			if (istype(perp.back, /obj/item/gun/)) // some weapons can be put on backs
				if (!has_carry_permit)
					threatcount += perp.back.get_contraband() * 0.5
			else // at moment of doing this we don't have other contraband back items, but maybe that'll change
				if (!has_contraband_permit)
					threatcount += perp.back.get_contraband() * 0.5
			if (istype(perp.back, /obj/item/storage/))
				for( var/obj/item/item in perp.back.contents )
					if (istype(item, /obj/item/gun/))
						if (!has_carry_permit)
							threatcount += item.get_contraband() * 0.5
					else
						if (!has_contraband_permit)
							threatcount += item.get_contraband() * 0.5

		//Agent cards lower threatlevel
		if((istype(perp.wear_id, /obj/item/card/id/syndicate)))
			threatcount -= 2

		// we have grounds to make an arrest, don't bother with further analysis
		if(threatcount >= 4)
			return threatcount

		if (src.check_records)
			var/perpname = perp.face_visible() ? perp.real_name : perp.name

			for (var/datum/db_record/R as anything in data_core.security.find_records("name", perpname))
				if(R["criminal"] == "*Arrest*")
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

	proc/speak(var/message)
		if (status & NOPOWER)
			return

		if (!message)
			return

		for (var/mob/O in hearers(src, null))
			O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span></span>", 2)


/obj/machinery/fakesecscanner
	name = "security scanner"
	desc = "The latest innovation in invasive imagery, the programmable NT-X100 will scan anyone who walks through it with fans to simulate being patted down. <em>Nanotrasen is not to be held responsible for any deaths caused by the results the machine gives, or the machine itself. ... Is this one even working properly?</em>"
	icon = 'icons/obj/machines/scanner.dmi'
	icon_state = "scanner_on"
