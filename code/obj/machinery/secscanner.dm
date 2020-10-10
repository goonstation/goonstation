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
	appearance_flags = TILE_BOUND
	var/timeBetweenUses = 20//I can see this being fun
	var/success_sound = "sound/machines/chime.ogg"
	var/fail_sound = 'sound/machines/alarm_a.ogg'

	var/weapon_access = access_carrypermit
	var/contraband_access = access_contrabandpermit
	var/report_scans = 1
	var/check_records = 1

	var/last_perp = 0
	var/last_contraband = 0
	//var/area/area = 0
	var/emagged = 0

	Crossed( atom/movable/O )
		if(isliving(O))
			do_scan(O)
		if (istype(O,/obj/item) && (!emagged))
			do_scan_item(O)
		return ..()
	process()
		.=..()
		if (status & NOPOWER)
			icon_state = "scanner_off"
		else
			icon_state = "scanner_on"

	disposing()
		radio_controller.remove_object(src, "1149")
		..()

	attackby(obj/item/W as obj, mob/user as mob) //If we get emagged...
		if (istype(W, /obj/item/card/emag) && (!emagged))
			src.add_fingerprint(user)
			emagged++
			user.show_text( "You 're-purpose' the [src].", "red" )
		..()

	proc/do_scan_item (var/obj/item/I)
		if( icon_state != "scanner_on" )
			return
		src.use_power(15)
		var/contraband = I.contraband

		if (contraband >= 2)

			playsound( src.loc, fail_sound, 10, 0 )
			icon_state = "scanner_red"
			src.use_power(15)

			//////PDA NOTIFY/////
			if (src.report_scans && (I.name != last_perp || contraband != last_contraband))
				var/scan_location = get_area(src)

				var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=MGD_SECURITY, "sender"="00000000", "message"="Notification: An item [I.name] failed checkpoint scan at [scan_location]! Threat Level : [contraband]")
				pdaSignal.transmission_method = TRANSMISSION_RADIO
				if(transmit_connection != null)
					transmit_connection.post_signal(src, pdaSignal)

				last_perp = I.name
				last_contraband = contraband

			SPAWN_DBG(timeBetweenUses)
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
							var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
							var/datum/signal/pdaSignal = get_free_signal()
							pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=MGD_SECURITY, "sender"="00000000", "message"="NOTIFICATION: [uppertext(perpname)] FAILED A VIBE CHECK AT [uppertext(scan_location)]! BAD VIBES LEVEL : [contraband]")
							pdaSignal.transmission_method = TRANSMISSION_RADIO
							if(transmit_connection != null)
								transmit_connection.post_signal(src, pdaSignal)

						last_perp = perpname
						last_contraband = contraband





			else  //Vibe check passed everything is good :)))
				target.show_text( "You feel [pick("good", "like you dodged a bullet", "lucky", "clean", "safe", "accepted")].", "blue" )
				playsound(src.loc, success_sound, 10, 1)
				icon_state = "scanner_green"

			SPAWN_DBG(timeBetweenUses)
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
						var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
						var/datum/signal/pdaSignal = get_free_signal()
						pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="SECURITY-MAILBOT",  "group"=MGD_SECURITY, "sender"="00000000", "message"="Notification: [perpname] failed checkpoint scan at [scan_location]! Threat Level : [contraband]")
						pdaSignal.transmission_method = TRANSMISSION_RADIO
						if(transmit_connection != null)
							transmit_connection.post_signal(src, pdaSignal)

					last_perp = perpname
					last_contraband = contraband

		else
			playsound(src.loc, success_sound, 10, 1)
			icon_state = "scanner_green"

		SPAWN_DBG(timeBetweenUses)
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
				threatcount += item.contraband
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
			else
				threatcount += 2

		//if((isnull(perp:wear_id)) || (istype(perp:wear_id, /obj/item/card/id/syndicate)))
		var/obj/item/card/id/perp_id = perp.equipped()
		if (!istype(perp_id))
			perp_id = perp.wear_id

		var/has_carry_permit = 0
		var/has_contraband_permit = 0

		if(perp_id) //Checking for permits
			if(weapon_access in perp_id.access)
				has_carry_permit = 1
			if(contraband_access in perp_id.access)
				has_contraband_permit = 1

		if (istype(perp.l_hand))
			if (istype(perp.l_hand, /obj/item/gun/))  // perp is carrying a gun
				if(!has_carry_permit)
					threatcount += perp.l_hand.contraband
			else // not carrying a gun
				if(!has_contraband_permit)
					threatcount += perp.l_hand.contraband

		if (istype(perp.r_hand))
			if (istype(perp.r_hand, /obj/item/gun/)) // perp is carrying a gun
				if(!has_carry_permit)
					threatcount += perp.r_hand.contraband
			else // not carrying a gun, but potential contraband?
				if(!has_contraband_permit)
					threatcount += perp.r_hand.contraband

		if (istype(perp.wear_suit))
			if (!has_contraband_permit)
				threatcount += perp.wear_suit.contraband

		if (istype(perp.belt))
			if (istype(perp.belt, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.belt.contraband * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.belt.contraband * 0.5
				for( var/obj/item/item in perp.belt.contents )
					if (istype(item, /obj/item/gun/))
						if (!has_carry_permit)
							threatcount += item.contraband * 0.5
					else
						if (!has_contraband_permit)
							threatcount += item.contraband * 0.5

		if (istype(perp.l_store))
			if (istype(perp.l_store, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.l_store.contraband * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.l_store.contraband * 0.5

		if (istype(perp.r_store))
			if (istype(perp.r_store, /obj/item/gun/))
				if (!has_carry_permit)
					threatcount += perp.r_store.contraband * 0.5
			else
				if (!has_contraband_permit)
					threatcount += perp.r_store.contraband * 0.5

		if (istype(perp.back))
			if (istype(perp.back, /obj/item/gun/)) // some weapons can be put on backs
				if (!has_carry_permit)
					threatcount += perp.back.contraband * 0.5
			else // at moment of doing this we don't have other contraband back items, but maybe that'll change
				if (!has_contraband_permit)
					threatcount += perp.back.contraband * 0.5
			if (istype(perp.back, /obj/item/storage/))
				for( var/obj/item/item in perp.back.contents )
					if (istype(item, /obj/item/gun/))
						if (!has_carry_permit)
							threatcount += item.contraband * 0.5
					else
						if (!has_contraband_permit)
							threatcount += item.contraband * 0.5

		//Agent cards lower threatlevel
		if((istype(perp.wear_id, /obj/item/card/id/syndicate)))
			threatcount -= 2

		// we have grounds to make an arrest, don't bother with further analysis
		if(threatcount >= 4)
			return threatcount

		if (src.check_records)
			var/see_face = 1
			if (istype(perp.wear_mask) && !perp.wear_mask.see_face)
				see_face = 0
			else if (istype(perp.head) && !perp.head.see_face)
				see_face = 0
			else if (istype(perp.wear_suit) && !perp.wear_suit.see_face)
				see_face = 0

			var/perpname = see_face ? perp.real_name : perp.name

			for (var/datum/data/record/E as() in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R as() in data_core.security)
						if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
							threatcount = max(4,threatcount)
							break
					break
				LAGCHECK(LAG_REALTIME)

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
