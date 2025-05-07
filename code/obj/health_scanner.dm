
TYPEINFO(/obj/health_scanner)
	mats = list("conductive" = 5,
				"crystal" = 2)
/obj/health_scanner
	icon = 'icons/obj/items/device.dmi'
	anchored = ANCHORED
	var/id = 0.0 // who are we?
	var/partner_range = 3 // how far away should we look?
	var/find_in_range = 1

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.find_partners(src.find_in_range)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	attackby(obj/item/W, mob/user)
		if (ispulsingtool(W))
			var/new_id = input(user, "Please enter new ID", src.name, src.id) as null|text
			if (!new_id || new_id == src.id)
				return
			src.id = new_id
			boutput(user, "You change [src]'s ID to [new_id].")
			src.find_partners()
		else
			return ..()

	proc/find_partners(var/in_range = 0)
		return // dummy proc that the scanner and screen will define themselves

/obj/health_scanner/wall
	name = "health status screen"
	desc = "A screen that shows health information received from connected floor scanners."
	icon_state = "wallscan1"
	var/list/partners // who do we know?
	var/examine_range = (SQUARE_TILE_WIDTH - 1) / 2 // from how far away can people examine the screen

	New()
		src.partners = list()
		..()

	get_desc(dist)
		if (dist > src.examine_range && !issilicon(usr))
			. += "<br>It's too far away to see what it says.[prob(10) ? " Who decided the text should be <i>that</i> small?!" : null]"
		else
			if (!src.partners || !length(src.partners))
				return . += "<font color='red'>ERROR: NO CONNECTED SCANNERS</font>"
			var/data = null
			for (var/obj/health_scanner/floor/my_partner in src.partners)
				data += my_partner.scan(ignore_cooldown = TRUE)
			if (data)
				. += "<br>It says:<br>[data]"
			else
				. += "<br>It says:<br><font color='red'>ERROR: NO SUBJECT(S) DETECTED</font>"

	attack_hand(mob/user)
		return user.examine_verb(src)

	attack_ai(mob/user)
		return user.examine_verb(src)

	find_partners(var/in_range = 0)
		if (in_range)
			for (var/obj/health_scanner/floor/possible_partner in orange(src.partner_range, src))
				src.add_partner(possible_partner)
		else
			for (var/obj/health_scanner/floor/possible_partner in by_type[/obj/health_scanner])
				LAGCHECK(LAG_LOW)
				if (possible_partner.id == src.id)
					src.add_partner(possible_partner)

	proc/add_partner(obj/health_scanner/floor/F)
		src.partners |= F

/obj/health_scanner/floor
	name = "health scanner"
	desc = "An in-floor health scanner that sends its data to connected status screens."
	icon_state = "floorscan1"
	plane = PLANE_FLOOR
	var/time_between_scans = 3 SECONDS

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)
		AddComponent(/datum/component/mechanics_holder)

	find_partners(var/in_range = 0)
		if (in_range)
			for (var/obj/health_scanner/wall/possible_partner in orange(src.partner_range, src))
				possible_partner.add_partner(src)
		else
			for (var/obj/health_scanner/wall/possible_partner in by_type[/obj/health_scanner])
				LAGCHECK(LAG_LOW)
				if (possible_partner.id == src.id)
					possible_partner.add_partner(src)

	Crossed(atom/movable/AM)
		..()
		if (ishuman(AM))
			boutput(AM, src.scan(TRUE))

	proc/scan(var/alert = FALSE, ignore_cooldown = FALSE)
		var/data = null
		if (!ignore_cooldown && ON_COOLDOWN(src, "scan_cooldown", time_between_scans))
			data += "<font color='red'>ERROR: SCANNER ON COOLDOWN</font>"
		else
			for (var/mob/living/carbon/human/H in get_turf(src))
				data += "[scan_health(H, 0, 0, 0, 1)]"
				DISPLAY_MAPTEXT(H, list(H), MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/health, H)
				if (alert && H.health < 0)
					src.crit_alert(H)

				// signal stuff
				// this all ends up running twice because it's in scan_health too,
				// but not broken out in a way that we need
				var/health_percent = round(100 * H.health / (H.max_health||1))
				var/oxy = round(H.get_oxygen_deprivation())
				var/tox = round(H.get_toxin_damage())
				var/burn = round(H.get_burn_damage())
				var/brute = round(H.get_brute_damage())
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "health=[health_percent]&oxy=[oxy]&tox=[tox]&burn=[burn]&brute=[brute]")

			playsound(src.loc, 'sound/machines/scan2.ogg', 30, 0)
		return data

	proc/crit_alert(var/mob/living/carbon/human/H)
		var/datum/signal/new_signal = get_free_signal()
		new_signal.data = list("command"="text_message", "sender_name"="HEALTH-MAILBOT", "sender"="00000000", "address_1"="00000000", "group"=list(MGD_MEDBAY, MGA_MEDCRIT), "message"="CRIT ALERT: [H] in [get_area(src)].")
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, new_signal, null, "pda")
