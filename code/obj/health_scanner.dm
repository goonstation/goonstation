
/obj/health_scanner
	icon = 'icons/obj/items/device.dmi'
	anchored = 1
	var/reagent_upgrade = 0
	var/reagent_scan = 0
	var/id = 0.0 // who are we?
	var/list/partners = list() // who do we know?
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
		else if (istype(W, /obj/item/device/analyzer/healthanalyzer_upgrade))
			src.update_reagent_scan()
			if (src.reagent_upgrade)
				boutput(user, "<span style=\"color:red\">This system already has a reagent scan upgrade!</span>")
				return
			else
				src.reagent_upgrade = 1
				src.reagent_scan = 1
				src.update_reagent_scan()
				boutput(user, "<span style=\"color:blue\">Reagent scan upgrade installed.</span>")
				playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
				qdel(W)
				return
		else
			return ..()

	proc/find_partners(var/in_range = 0)
		return // dummy proc that the scanner and screen will define themselves

	proc/accept_partner(var/obj/health_scanner/H)
		if (!H)
			return
		if (locate(H) in src.partners)
			return
		src.partners += H

	proc/update_reagent_scan()
		if (!src.partners || !src.partners.len)
			return
		for (var/obj/health_scanner/myPartner in src.partners)
			if (src.reagent_upgrade && !myPartner.reagent_upgrade)
				myPartner.reagent_upgrade = 1
			else if (myPartner.reagent_upgrade && !src.reagent_upgrade)
				src.reagent_upgrade = 1
			if (src.reagent_scan && !myPartner.reagent_scan)
				myPartner.reagent_scan = 1
			else if (myPartner.reagent_scan && !src.reagent_scan)
				src.reagent_scan = 1

/obj/health_scanner/wall
	name = "health status screen"
	desc = "A screen that shows health information recieved from connected floor scanners."
	icon_state = "wallscan1"

	find_partners(var/in_range = 0)
		src.partners = list()
		if (in_range)
			for (var/obj/health_scanner/floor/possible_partner in orange(src.partner_range, src))
				if (locate(possible_partner) in src.partners)
					continue
				src.partners += possible_partner
				possible_partner.accept_partner(src)
		else
			for (var/obj/health_scanner/floor/possible_partner in by_type[/obj/health_scanner])
				LAGCHECK(LAG_LOW)
				if (locate(possible_partner) in src.partners)
					continue
				if (possible_partner.id == src.id)
					src.partners += possible_partner
					possible_partner.accept_partner(src)

	proc/scan()
		if (!src.partners || !src.partners.len)
			return "<font color='red'>ERROR: NO CONNECTED SCANNERS</font>"
		var/data = null
		for (var/obj/health_scanner/floor/myPartner in src.partners)
			for (var/mob/M in get_turf(myPartner))
				if (!isobserver(M))
					data += "<br>[scan_health(M, src.reagent_scan, 1, 1, visible = 1)]"
		return data

	get_desc(dist)
		if (dist > 2 && !issilicon(usr))
			. += "<br>It's too far away to see what it says.[prob(10) ? " Who decided the text should be <i>that</i> small?!" : null]"
		else
			var/data = src.scan()
			if (data)
				. += "<br>It says:[data]"
			else
				. += "<br>It says:<br><font color='red'>ERROR: NO SUBJECT(S) DETECTED</font>"

	attack_hand(mob/user as mob)
		return src.examine()

	attack_ai(mob/user as mob)
		return src.examine()

/obj/health_scanner/floor
	name = "health scanner"
	desc = "An in-floor health scanner that sends its data to connected status screens."
	icon_state = "floorscan1"

	find_partners(var/in_range = 0)
		src.partners = list()
		if (in_range)
			for (var/obj/health_scanner/wall/possible_partner in orange(src.partner_range, src))
				if (locate(possible_partner) in src.partners)
					continue
				src.partners += possible_partner
				possible_partner.accept_partner(src)
		else
			for (var/obj/health_scanner/wall/possible_partner in by_type[/obj/health_scanner])
				LAGCHECK(LAG_LOW)
				if (locate(possible_partner) in src.partners)
					continue
				if (possible_partner.id == src.id)
					src.partners += possible_partner
					possible_partner.accept_partner(src)
