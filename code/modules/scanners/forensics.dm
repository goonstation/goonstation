// Contents
// global scan forensic proc
// handheld forensic scanner

/proc/scan_forensic(var/atom/A as turf|obj|mob, visible = FALSE)
	RETURN_TYPE(/datum/forensic_scan)
	if (istype(A, /obj/ability_button)) // STOP THAT
		return
	if (!A)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if(visible)
		animate_scanning(A, "#b9d689")
	var/datum/forensic_scan/scan = new(A)
	return scan


TYPEINFO(/obj/item/device/detective_scanner)
	mats = 3

/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "fs"
	w_class = W_CLASS_SMALL // PDA fits in a pocket, so why not the dedicated scanner (Convair880)?
	item_state = "accessgun"
	flags = TABLEPASS | CONDUCT | SUPPRESSATTACK
	c_flags = ONBELT
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	var/active = 0
	var/distancescan = 0
	var/target = null

	var/list/scans
	var/maximum_scans = 25
	var/number_of_scans = 0
	var/last_scan = "No scans have been performed yet."

	Topic(href, href_list)
		..()
		if (href_list["print"])
			if (!(src in usr.contents))
				boutput(usr, SPAN_NOTICE("You must be holding [src] that made the record in order to print it."))
				return
			var/scan_number = text2num(href_list["print"])
			if (scan_number < number_of_scans - maximum_scans)
				boutput(usr, SPAN_ALERT("ERROR: Scanner unable to load report data."))
				return
			if(!ON_COOLDOWN(src, "print", 2 SECOND))
				playsound(src, 'sound/machines/printer_thermal.ogg', 50, TRUE)
				SPAWN(1 SECONDS)
					var/obj/item/paper/P = new /obj/item/paper
					usr.put_in_hand_or_drop(P)

					var/index = (scan_number % maximum_scans) + 1 // Once a number of scans equal to the maximum number of scans is made, begin to overwrite existing scans, starting from the earliest made.
					P.info = scans[index]
					var/print_title = href_list["title"]
					if (print_title)
						P.name = print_title
					else
						P.name = "forensic readout"


	attack_self(mob/user as mob)

		src.add_fingerprint(user)

		var/holder = src.loc
		var/search = tgui_input_text(user, "Enter name, full/partial fingerprint, or blood DNA.", "Find record")
		if (src.loc != holder || !search || user.stat)
			return
		search = copytext(sanitize(search), 1, 200)
		boutput(user, data_core.general.forensic_search(search))
		return


	pixelaction(atom/target, params, mob/user, reach)
		if(distancescan)
			if(!(BOUNDS_DIST(user, target) == 0) && IN_RANGE(user, target, 3))
				user.visible_message(SPAN_NOTICE("<b>[user]</b> takes a distant forensic scan of [target]."))
				scan_target(target, user)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0 || istype(A, /obj/ability_button)) // Scanning for fingerprints over the camera network is fun, but doesn't really make sense (Convair880).
			return
		user.visible_message(SPAN_ALERT("<b>[user]</b> has scanned [A]."))
		scan_target(A, user)


	proc/scan_target(var/atom/target, var/mob/user)
		if (scans == null)
			scans = new/list(maximum_scans)
		var/datum/forensic_scan/scan = scan_forensic(target, visible = TRUE)
		last_scan = scan.build_report(compress = FALSE)
		var/index = (number_of_scans % maximum_scans) + 1 // Once a number of scans equal to the maximum number of scans is made, begin to overwrite existing scans, starting from the earliest made.
		scans[index] = last_scan
		var/scan_output = "--- <a href='byond://?src=\ref[src];print=[number_of_scans];title=Analysis of [target];'>PRINT REPORT</a> ---<br>" + scan.build_report(compress = TRUE)
		number_of_scans += 1
		boutput(user, scan_output)

		if(!active && istype(target, /obj/decal/cleanable/blood))
			var/obj/decal/cleanable/blood/B = target
			if(B.dry > 0) //Fresh blood is -1
				boutput(user, SPAN_ALERT("Targeted blood is too dry to be useful!"))
				return
			for(var/mob/living/carbon/human/H in mobs)
				if(B.blood_DNA == H.bioHolder.Uid)
					target = H
					break
			active = 1
			work()

	proc/work(var/turf/T)
		if(!active) return
		if(!T)
			T = get_turf(src)
		if(get_turf(src) != T)
			icon_state = "fs"
			active = 0
			boutput(usr, SPAN_ALERT("[src] shuts down because you moved!"))
			return
		if(!target)
			icon_state = "fs"
			active = 0
			return
		src.set_dir(get_dir(src,target))
		switch(GET_DIST(src,target))
			if(0)
				icon_state = "fs_pindirect"
			if(1 to 8)
				icon_state = "fs_pinclose"
			if(9 to 16)
				icon_state = "fs_pinmedium"
			if(16 to INFINITY)
				icon_state = "fs_pinfar"
		SPAWN(0.5 SECONDS)
			.(T)


/obj/item/device/detective_scanner/detective
	name = "cool forensic scanner"
	desc = "Used to scan objects for DNA and fingerprints. This model seems to have an upgrade that lets it scan for prints at a distance. You feel cool holding it."
	distancescan = 1
