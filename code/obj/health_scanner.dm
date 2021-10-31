
/obj/health_scanner
	icon = 'icons/obj/items/device.dmi'
	anchored = 1
	var/id = 0.0 // who are we?
	var/partner_range = 3 // how far away should we look?
	var/find_in_range = 1

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			src.find_partners(src.find_in_range)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	attackby(obj/item/W as obj, mob/user as mob)
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
	desc = "A screen that shows health information recieved from connected floor scanners."
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
				data += my_partner.scan()
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
	var/time_between_scans = 3 SECONDS
	var/on_cooldown = FALSE

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

	proc/scan(var/alert = FALSE)
		var/data = null
		if (on_cooldown)
			data += "<font color='red'>ERROR: SCANNER ON COOLDOWN</font>"
		else
			on_cooldown = TRUE
			for (var/mob/living/carbon/human/H in get_turf(src))
				data += "[scan_health(H, 1, 1, 1, 1)]"
				scan_health_overhead(H, H)
				if (alert && H.health < 0)
					src.crit_alert(H)
			playsound(src.loc, "sound/machines/scan2.ogg", 30, 0)
			SPAWN_DBG(time_between_scans)
				on_cooldown = FALSE
		return data

	proc/crit_alert(var/mob/living/carbon/human/H)
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/new_signal = get_free_signal()
		new_signal.data = list("command"="text_message", "sender_name"="HEALTH-MAILBOT", "sender"="00000000", "address_1"="00000000", "group"=list(MGD_MEDBAY, MGA_MEDCRIT), "message"="CRIT ALERT: [H] in [get_area(src)].")
		new_signal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection)
			transmit_connection.post_signal(src, new_signal)
