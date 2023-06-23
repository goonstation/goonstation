/*
Contains:

-T-ray scanner
-Forensic scanner
-Health analyzer
-Reagent scanner
-Atmospheric analyzer
-Prisoner scanner
*/

//////////////////////////////////////////////// T-ray scanner //////////////////////////////////

TYPEINFO(/obj/item/device/t_scanner)
	mats = list("CRY-1", "CON-1")

/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	m_amt = 50
	g_amt = 20
	var/scan_range = 3
	var/client/last_client = null
	var/image/last_display = null
	var/find_interesting = TRUE

	proc/set_on(new_on, mob/user=null)
		on = new_on
		set_icon_state("t-ray[on]")
		if(user)
			boutput(user, "You switch [src] [on ? "on" : "off"].")
		if(!on)
			hide_displays()
		else
			processing_items |= src

	attack_self(mob/user)
		set_on(!on, user)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (istype(A, /turf))
			if (BOUNDS_DIST(A, user) > 0) // Scanning for COOL LORE SECRETS over the camera network is fun, but so is drinking and driving.
				return
			if(A.interesting && src.on)
				animate_scanning(A, "#7693d3")
				user.visible_message("<span class='alert'><b>[user]</b> has scanned the [A].</span>")
				boutput(user, "<br><i>Historical analysis:</i><br><span class='notice'>[A.interesting]</span>")
				return
		else if (istype(A, /obj) && A.interesting)
			animate_scanning(A, "#7693d3")
			user.visible_message("<span class='alert'><b>[user]</b> has scanned the [A].</span>")
			boutput(user, "<br><i>Analysis failed:</i><br><span class='notice'>Unable to determine signature</span>")

	proc/hide_displays()
		if(last_client)
			last_client.images -= last_display
		qdel(last_display)
		last_display = null
		last_client = null

	disposing()
		hide_displays()
		last_display = null
		last_client = null
		..()

	process()
		hide_displays()

		if(!on)
			processing_items.Remove(src)
			return null

		var/mob/our_mob = src
		while(!isnull(our_mob) && !istype(our_mob, /turf) && !ismob(our_mob)) our_mob = our_mob.loc
		if(!istype(our_mob) || !our_mob.client)
			return null
		var/client/C = our_mob.client
		var/turf/center = get_turf(our_mob)

		var/image/main_display = image(null)
		for(var/turf/T in range(src.scan_range, our_mob))
			if(T.interesting && find_interesting)
				our_mob.playsound_local(T, 'sound/machines/ping.ogg', 55, 1)

			var/image/display = new

			for(var/atom/A in T)
				if(A.interesting && find_interesting)
					our_mob.playsound_local(A, 'sound/machines/ping.ogg', 55, 1)
				if(ismob(A))
					var/mob/M = A
					if(M?.invisibility != INVIS_CLOAK || !(BOUNDS_DIST(src, M) == 0))
						continue
				else if(isobj(A))
					var/obj/O = A
					if(O.level != 1 && !istype(O, /obj/disposalpipe)) // disposal pipes handled below
						continue
				var/image/img = image(A.icon, icon_state=A.icon_state, dir=A.dir)
				img.plane = PLANE_SCREEN_OVERLAYS
				img.color = A.color
				img.overlays = A.overlays
				img.alpha = 100
				img.appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
				display.overlays += img

			if (T.disposal_image)
				display.overlays += T.disposal_image

			if( length(display.overlays))
				display.plane = PLANE_SCREEN_OVERLAYS
				display.pixel_x = (T.x - center.x) * 32
				display.pixel_y = (T.y - center.y) * 32
				main_display.overlays += display

		main_display.loc = our_mob.loc

		C.images += main_display
		last_display = main_display
		last_client = C

/obj/item/device/t_scanner/abilities = list(/obj/ability_button/tscanner_toggle)

/obj/item/device/t_scanner/adventure
	name = "experimental scanner"
	desc = "a bodged-together T-Ray scanner with a few coils cut, and a few extra coils tied-in."
	scan_range = 4

/obj/item/device/t_scanner/pda
	name = "PDA T-ray scanner"
	find_interesting = FALSE

/*
he`s got a craving
for american haiku
that cannot be itched
*/

//////////////////////////////////////// Forensic scanner ///////////////////////////////////

TYPEINFO(/obj/item/device/detective_scanner)
	mats = 3

/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "fs"
	w_class = W_CLASS_SMALL // PDA fits in a pocket, so why not the dedicated scanner (Convair880)?
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT | SUPPRESSATTACK
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
				boutput(usr, "<span class='notice'>You must be holding [src] that made the record in order to print it.</span>")
				return
			var/scan_number = text2num(href_list["print"])
			if (scan_number < number_of_scans - maximum_scans)
				boutput(usr, "<span class='alert'>ERROR: Scanner unable to load report data.</span>")
				return
			if(!ON_COOLDOWN(src, "print", 2 SECOND))
				playsound(src, 'sound/machines/printer_thermal.ogg', 50, 1)
				SPAWN(1 SECONDS)
					var/obj/item/paper/P = new /obj/item/paper
					P.set_loc(get_turf(src))

					var/index = (scan_number % maximum_scans) + 1 // Once a number of scans equal to the maximum number of scans is made, begin to overwrite existing scans, starting from the earliest made.
					P.info = scans[index]
					P.name = "forensic readout"


	attack_self(mob/user as mob)

		src.add_fingerprint(user)

		var/holder = src.loc
		var/search = tgui_input_text(user, "Enter name, fingerprint or blood DNA.", "Find record")
		if (src.loc != holder || !search || user.stat)
			return
		search = copytext(sanitize(search), 1, 200)
		search = lowertext(search)

		for (var/datum/db_record/R as anything in data_core.general.records)
			if (search == lowertext(R["dna"]) || search == lowertext(R["fingerprint"]) || search == lowertext(R["name"]))

				var/data = "--------------------------------<br>\
				<font color='blue'>Match found in security records:<b> [R["name"]]</b> ([R["rank"]])</font><br>\
				<br>\
				<i>Fingerprint:</i><font color='blue'> [R["fingerprint"]]</font><br>\
				<i>Blood DNA:</i><font color='blue'> [R["dna"]]</font>"

				boutput(user, data)
				return

		user.show_text("No match found in security records.", "red")
		return


	pixelaction(atom/target, params, mob/user, reach)
		if(distancescan)
			if(!(BOUNDS_DIST(user, target) == 0) && IN_RANGE(user, target, 3))
				user.visible_message("<span class='notice'><b>[user]</b> takes a distant forensic scan of [target].</span>")
				last_scan = scan_forensic(target, visible = 1)
				boutput(user, last_scan)
				src.add_fingerprint(user)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)

		if (BOUNDS_DIST(A, user) > 0 || istype(A, /obj/ability_button)) // Scanning for fingerprints over the camera network is fun, but doesn't really make sense (Convair880).
			return

		user.visible_message("<span class='alert'><b>[user]</b> has scanned [A].</span>")

		if (scans == null)
			scans = new/list(maximum_scans)
		last_scan = scan_forensic(A, visible = 1) // Moved to scanprocs.dm to cut down on code duplication (Convair880).
		var/index = (number_of_scans % maximum_scans) + 1 // Once a number of scans equal to the maximum number of scans is made, begin to overwrite existing scans, starting from the earliest made.
		scans[index] = last_scan
		var/scan_output = last_scan + "<br>---- <a href='?src=\ref[src];print=[number_of_scans];'>PRINT REPORT</a> ----"
		number_of_scans += 1

		boutput(user, scan_output)
		src.add_fingerprint(user)

		if(!active && istype(A, /obj/decal/cleanable/blood))
			var/obj/decal/cleanable/blood/B = A
			if(B.dry > 0) //Fresh blood is -1
				boutput(user, "<span class='alert'>Targeted blood is too dry to be useful!</span>")
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
			boutput(usr, "<span class='alert'>[src] shuts down because you moved!</span>")
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

///////////////////////////////////// Health analyzer ////////////////////////////////////////

TYPEINFO(/obj/item/device/analyzer/healthanalyzer)
	mats = 5

/obj/item/device/analyzer/healthanalyzer
	name = "health analyzer"
	icon_state = "health-no_up"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "healthanalyzer-no_up" // someone made this sprite and then this was never changed to it for some reason???
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	var/disease_detection = 1
	var/reagent_upgrade = 0
	var/reagent_scan = 0
	var/organ_upgrade = 0
	var/organ_scan = 0
	var/image/scanner_status
	hide_attack = ATTACK_PARTIALLY_HIDDEN

	New()
		..()
		scanner_status = image('icons/obj/items/device.dmi', icon_state = "health_over-basic")
		UpdateOverlays(scanner_status, "status")

	attack_self(mob/user as mob)
		if (!src.reagent_upgrade && !src.organ_upgrade)
			boutput(user, "<span class='alert'>No upgrades detected!</span>")

		else if (src.reagent_upgrade && src.organ_upgrade)
			if (src.reagent_scan && src.organ_scan)				//if both active, make both off
				src.reagent_scan = 0
				src.organ_scan = 0
				scanner_status.icon_state = "health_over-basic"
				UpdateOverlays(scanner_status, "status")
				boutput(user, "<span class='alert'>All upgrades disabled.</span>")

			else if (!src.reagent_scan && !src.organ_scan)		//if both inactive, turn reagent on
				src.reagent_scan = 1
				src.organ_scan = 0
				scanner_status.icon_state = "health_over-reagent"
				UpdateOverlays(scanner_status, "status")
				boutput(user, "<span class='alert'>Reagent scanner enabled.</span>")

			else if (src.reagent_scan)							//if reagent active, turn reagent off, turn organ on
				src.reagent_scan = 0
				src.organ_scan = 1
				scanner_status.icon_state = "health_over-organ"
				UpdateOverlays(scanner_status, "status")
				boutput(user, "<span class='alert'>Reagent scanner disabled. Organ scanner enabled.</span>")

			else if (src.organ_scan)							//if organ active, turn BOTH on
				src.reagent_scan = 1
				src.organ_scan = 1
				scanner_status.icon_state = "health_over-both"
				UpdateOverlays(scanner_status, "status")
				boutput(user, "<span class='alert'>All upgrades enabled.</span>")

		else if (src.reagent_upgrade)
			src.reagent_scan = !(src.reagent_scan)
			scanner_status.icon_state = !reagent_scan ? "health_over-basic" : "health_over-reagent"
			UpdateOverlays(scanner_status, "status")
			boutput(user, "<span class='notice'>Reagent scanner [src.reagent_scan ? "enabled" : "disabled"].</span>")
		else if (src.organ_upgrade)
			src.organ_scan = !(src.organ_scan)
			scanner_status.icon_state = !organ_scan ? "health_over-basic" : "health_over-organ"
			UpdateOverlays(scanner_status, "status")
			boutput(user, "<span class='notice'>Organ scanner [src.organ_scan ? "enabled" : "disabled"].</span>")

	attackby(obj/item/W, mob/user)
		addUpgrade(src, W, user, src.reagent_upgrade)
		..()

	attack(mob/M, mob/user)
		if ((user.bioHolder.HasEffect("clumsy") || user.get_brain_damage() >= 60) && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> slips and drops [src]'s sensors on the floor!</span>")
			user.show_message("Analyzing Results for <span class='notice'>The floor:<br>&emsp; Overall Status: Healthy</span>", 1)
			user.show_message("&emsp; Damage Specifics: <font color='#1F75D1'>[0]</font> - <font color='#138015'>[0]</font> - <font color='#CC7A1D'>[0]</font> - <font color='red'>[0]</font>", 1)
			user.show_message("&emsp; Key: <font color='#1F75D1'>Suffocation</font>/<font color='#138015'>Toxin</font>/<font color='#CC7A1D'>Burns</font>/<font color='red'>Brute</font>", 1)
			user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
			JOB_XP(user, "Clown", 1)
			return

		user.visible_message("<span class='alert'><b>[user]</b> has analyzed [M]'s vitals.</span>",\
		"<span class='alert'>You have analyzed [M]'s vitals.</span>")
		playsound(src.loc , 'sound/items/med_scanner.ogg', 20, 0)
		boutput(user, scan_health(M, src.reagent_scan, src.disease_detection, src.organ_scan, visible = 1))

		scan_health_overhead(M, user)

		update_medical_record(M)

		if (M.stat > 1)
			user.unlock_medal("He's dead, Jim", 1)
		return

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (istype(A, /obj/machinery/clonepod))
			var/obj/machinery/clonepod/P = A
			if(P.occupant)
				user.visible_message("<span class='alert'><b>[user]</b> has analyzed [P.occupant]'s vitals.</span>",\
					"<span class='alert'>You have analyzed [P.occupant]'s vitals.</span>")
				boutput(user, scan_health(P.occupant, src.reagent_scan, src.disease_detection, src.organ_scan))
				update_medical_record(P.occupant)
				return
		..()



/obj/item/device/analyzer/healthanalyzer/upgraded
	icon_state = "health"
	reagent_upgrade = 1
	reagent_scan = 1
	organ_upgrade = 1
	organ_scan = 1

	New()
		..()
		scanner_status.icon_state = "health_over-both"
		UpdateOverlays(scanner_status, "status")

/obj/item/device/analyzer/healthanalyzer/vr
	icon = 'icons/effects/VR.dmi'

TYPEINFO(/obj/item/device/analyzer/healthanalyzer_upgrade)
	mats = 2

/obj/item/device/analyzer/healthanalyzer_upgrade
	name = "health analyzer upgrade"
	desc = "A small upgrade card that allows standard health analyzers to detect reagents present in the patient, and ProDoc Healthgoggles to scan patients' health from a distance."
	icon_state = "health_upgr"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

TYPEINFO(/obj/item/device/analyzer/healthanalyzer_organ_upgrade)
	mats = 2

/obj/item/device/analyzer/healthanalyzer_organ_upgrade
	name = "health analyzer organ scan upgrade"
	desc = "A small upgrade card that allows standard health analyzers to detect the health of induvidual organs in the patient."
	icon_state = "organ_health_upgr"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

///////////////////////////////////// Reagent scanner //////////////////////////////

TYPEINFO(/obj/item/device/reagentscanner)
	mats = 5

/obj/item/device/reagentscanner
	name = "reagent scanner"
	icon_state = "reagentscan"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "reagentscan"
	desc = "A hand-held device that scans and lists the chemicals inside the scanned subject."
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	var/scan_results = null
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	tooltip_flags = REBUILD_DIST

	attack(mob/M, mob/user)
		return

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		user.visible_message("<span class='notice'><b>[user]</b> scans [A] with [src]!</span>",\
		"<span class='notice'>You scan [A] with [src]!</span>")

		src.scan_results = scan_reagents(A, visible = 1)
		tooltip_rebuild = 1

		if (!isnull(A.reagents))
			if (A.reagents.reagent_list.len > 0)
				set_icon_state("reagentscan-results")
			else
				set_icon_state("reagentscan-no")
		else
			set_icon_state("reagentscan-no")

		if (isnull(src.scan_results))
			boutput(user, "<span class='alert'>\The [src] encounters an error and crashes!</span>")
		else
			boutput(user, "[src.scan_results]")

	attack_self(mob/user as mob)
		if (isnull(src.scan_results))
			boutput(user, "<span class='notice'>No previous scan results located.</span>")
			return
		boutput(user, "<span class='notice'>Previous scan's results:<br>[src.scan_results]</span>")

	get_desc(dist)
		if (dist < 3)
			if (!isnull(src.scan_results))
				. += "<br><span class='notice'>Previous scan's results:<br>[src.scan_results]</span>"

/////////////////////////////////////// Atmos analyzer /////////////////////////////////////

TYPEINFO(/obj/item/device/analyzer/atmospheric)
	mats = 3

/obj/item/device/analyzer/atmospheric
	desc = "A hand-held environmental scanner which reports current gas levels and can track nearby hull breaches."
	name = "atmospheric analyzer"
	icon_state = "atmos-no_up"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 5
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	var/analyzer_upgrade = 0
	///The breach we are currently tracking
	var/atom/target = null
	var/hudarrow_color = "#0df0f0"
	///We keep track of the airgroup so we can acquire a new breach after the old one is patched, even if the user is standing on space at the time
	var/datum/air_group/tracking_airgroup = null

	// Distance upgrade action code
	pixelaction(atom/target, params, mob/user, reach)
		var/turf/T = get_turf(target)
		if ((analyzer_upgrade == 1) && (BOUNDS_DIST(user, T) > 0))
			user.visible_message("<span class='notice'><b>[user]</b> takes a distant atmospheric reading of [T].</span>")
			boutput(user, scan_atmospheric(T, visible = 1))
			src.add_fingerprint(user)
			return

	attack_self(mob/user as mob)
		if (user.stat)
			return

		src.add_fingerprint(user)

		if (!src.target)
			src.find_breach()
			if (src.target)
				user.AddComponent(/datum/component/tracker_hud, src.target, src.hudarrow_color)
				src.UpdateOverlays(image('icons/obj/items/device.dmi', "atmos-tracker"), "breach_tracker")
		else
			src.tracker_off(user)

	proc/tracker_off(mob/user)
		src.UpdateOverlays(null, "breach_tracker")
		src.UnregisterSignal(src.target, COMSIG_TURF_REPLACED)
		var/datum/component/tracker_hud/arrow = user.GetComponent(/datum/component/tracker_hud)
		arrow?.RemoveComponent()
		src.target = null
		src.tracking_airgroup = null

	///Search the current airgroup for space borders and point to the closest one
	proc/find_breach()
		var/turf/simulated/T = get_turf(src)
		if (!src.tracking_airgroup)
			if (!istype(T) || !T.parent)
				boutput(src.loc, "<span class='alert'>Unable to read atmospheric flow.</span>")
				return
			src.tracking_airgroup = T.parent

		for (var/turf/breach in src.tracking_airgroup?.space_borders)
			for (var/dir in cardinal)
				var/turf/space/potential_space = get_step(breach, dir)
				if (istype(potential_space) && (!src.target || (GET_DIST(src.target, T) > GET_DIST(potential_space, T))))
					src.target = potential_space
					break
		if (!src.target)
			src.tracking_airgroup = null
			boutput(src.loc, "<span class='alert'>No breaches found in current atmosphere.</span>")
			return
		if (ismob(src.loc))
			var/datum/component/tracker_hud/arrow = src.loc.GetComponent(/datum/component/tracker_hud)
			arrow?.change_target(src.target)
		src.RegisterSignal(src.target, COMSIG_TURF_REPLACED, PROC_REF(update_breach))

	///When our target is replaced (most likely no longer a breach), pick a new one
	proc/update_breach(turf/replaced, turf/new_turf)
		src.UnregisterSignal(src.target, COMSIG_TURF_REPLACED)
		//the signal has to be sent before the turf is replaced, but we need to search after it has been replaced, hence the accursed SPAWN(1)
		SPAWN(1)
			if (!istype(new_turf, /turf/space))
				src.target = null
				src.find_breach()
				if (!src.target)
					src.tracker_off(src.loc)

	//we duplicate a little pinpointer code
	pickup(mob/user)
		. = ..()
		if (src.target)
			user.AddComponent(/datum/component/tracker_hud, src.target, src.hudarrow_color)

	dropped(mob/user)
		. = ..()
		var/datum/component/tracker_hud/arrow = user.GetComponent(/datum/component/tracker_hud)
		arrow?.RemoveComponent()

	attackby(obj/item/W, mob/user)
		addUpgrade(src, W, user, src.analyzer_upgrade)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0 || istype(A, /obj/ability_button))
			return

		if (istype(A, /obj) || isturf(A))
			user.visible_message("<span class='notice'><b>[user]</b> takes an atmospheric reading of [A].</span>")
			boutput(user, scan_atmospheric(A, visible = 1))
		src.add_fingerprint(user)
		return

	is_detonator_attachment()
		return 1

	detonator_act(event, var/obj/item/assembly/detonator/det)
		switch (event)
			if ("pulse")
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src]'s external display turns off for a moment before booting up again.</span>")
			if ("cut")
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src]'s external display turns off.</span>")
				det.attachments.Remove(src)
			if ("leak")
				det.attachedTo.visible_message("<style class='combat bold'>\The [src] picks up the rapid atmospheric change of the canister, and signals the detonator.</style>")
				SPAWN(0)
					det.detonate()
		return

/obj/item/device/analyzer/atmospheric/upgraded //for borgs because JESUS FUCK
	analyzer_upgrade = 1
	icon_state = "atmos"

TYPEINFO(/obj/item/device/analyzer/atmosanalyzer_upgrade)
	mats = 2

/obj/item/device/analyzer/atmosanalyzer_upgrade
	name = "atmospherics analyzer upgrade"
	desc = "A small upgrade card that allows standard atmospherics analyzers to detect environmental information at a distance."
	icon_state = "atmos_upgr" // add this
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

///////////////// method to upgrade an analyzer if the correct upgrade cartridge is used on it /////////////////
/obj/item/device/analyzer/proc/addUpgrade(obj/item/device/src as obj, obj/item/device/W as obj, mob/user as mob, upgraded as num, active as num, iconState as text, itemState as text)
	if (istype(W, /obj/item/device/analyzer/healthanalyzer_upgrade) || istype(W, /obj/item/device/analyzer/healthanalyzer_organ_upgrade) || istype(W, /obj/item/device/analyzer/atmosanalyzer_upgrade))
		//Health Analyzers
		if (istype(src, /obj/item/device/analyzer/healthanalyzer))
			var/obj/item/device/analyzer/healthanalyzer/a = src
			if (istype(W, /obj/item/device/analyzer/healthanalyzer_upgrade))
				if (a.reagent_upgrade)
					boutput(user, "<span class='alert'>This analyzer already has a reagent scan upgrade!</span>")
					return
				a.reagent_scan = 1
				a.reagent_upgrade = 1
				a.icon_state = a.organ_upgrade ? "health" : "health-r-up"
				a.scanner_status.icon_state = a.organ_scan ? "health_over-both" : "health_over-reagent"
				a.UpdateOverlays(a.scanner_status, "status")
				a.item_state = "healthanalyzer"

			else if (istype(W, /obj/item/device/analyzer/healthanalyzer_organ_upgrade))
				if (a.organ_upgrade)
					boutput(user, "<span class='alert'>This analyzer already has an internal organ scan upgrade!</span>")
					return
				a.organ_upgrade = 1
				a.organ_scan = 1
				a.icon_state = a.reagent_upgrade ? "health" : "health-o-up"
				a.scanner_status.icon_state = a.reagent_scan ? "health_over-both" : "health_over-organ"
				a.UpdateOverlays(a.scanner_status, "status")
				a.item_state = "healthanalyzer"
		else if(istype(src, /obj/item/device/analyzer/atmospheric) && istype(W, /obj/item/device/analyzer/atmosanalyzer_upgrade))
			if (upgraded)
				boutput(user, "<span class='alert'>This analyzer already has a distance scan upgrade!</span>")
				return
			var/obj/item/device/analyzer/atmospheric/a = src
			a.analyzer_upgrade = 1
			a.icon_state = "atmos"
			a.item_state = "atmosphericnalyzer"

		else
			boutput(user, "<span class='alert'>That cartridge won't fit in there!</span>")
			return
		boutput(user, "<span class='notice'>Upgrade cartridge installed.</span>")
		playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
		user.u_equip(W)
		qdel(W)


///////////////////////////////////////////////// Prisoner scanner ////////////////////////////////////

TYPEINFO(/obj/item/device/prisoner_scanner)
	mats = 3

/obj/item/device/prisoner_scanner
	name = "security RecordTrak"
	desc = "A device used to scan in prisoners and update their security records."
	icon_state = "recordtrak"
	var/datum/db_record/active1 = null
	var/datum/db_record/active2 = null
	item_state = "recordtrak"
	flags = FPRINT | TABLEPASS | CONDUCT | EXTRADELAY
	c_flags = ONBELT

	#define PRISONER_MODE_NONE 1
	#define PRISONER_MODE_PAROLED 2
	#define PRISONER_MODE_RELEASED 3
	#define PRISONER_MODE_INCARCERATED 4

	///List of record settings
	var/static/list/modes = list(PRISONER_MODE_NONE, PRISONER_MODE_PAROLED, PRISONER_MODE_INCARCERATED, PRISONER_MODE_RELEASED)
	///The current setting
	var/mode = PRISONER_MODE_NONE
	/// The sechud flag that will be applied when scanning someone
	var/sechud_flag = "None"

	var/list/datum/contextAction/contexts = list()

	New()
		var/datum/contextLayout/experimentalcircle/context_menu = new
		context_menu.center = TRUE
		src.contextLayout = context_menu
		..()
		for(var/actionType in childrentypesof(/datum/contextAction/prisoner_scanner))
			var/datum/contextAction/prisoner_scanner/action = new actionType()
			if (action.mode in src.modes)
				src.contexts += action

	get_desc()
		. = ..()
		var/mode_string = "None"
		if (src.mode == PRISONER_MODE_PAROLED)
			mode_string = "Paroled"
		else if (src.mode == PRISONER_MODE_RELEASED)
			mode_string = "Released"
		else if (src.mode == PRISONER_MODE_INCARCERATED)
			mode_string = "Incarcerated"

		. += "<br>Arrest mode: <span class='notice'>[mode_string]</span>"
		if (sechud_flag != initial(src.sechud_flag))
			. += "<br>Active SecHUD Flag: <span class='notice'>[src.sechud_flag]</span>"

	attack(mob/living/carbon/human/M, mob/user)
		if (!istype(M))
			boutput(user, "<span class='alert'>The device displays an error about an \"incompatible target\".</span>")
			return

		////General Records
		var/found = 0
		//if( !istype(get_area(src), /area/security/prison) && !istype(get_area(src), /area/security/main))
		//	boutput(user, "<span class='alert'>Device only works in designated security areas!</span>")
		//	return
		boutput(user, "<span class='notice'>You scan in [M].</span>")
		boutput(M, "<span class='alert'>[user] scans you with the RecordTrak!</span>")
		for(var/datum/db_record/R as anything in data_core.general.records)
			if (lowertext(R["name"]) == lowertext(M.name))
				//Update Information
				R["name"] = M.name
				R["sex"] = M.gender
				R["pronouns"] = M.get_pronouns().name
				R["age"] = M.bioHolder.age
				if (M.gloves)
					R["fingerprint"] = "Unknown"
				else
					R["fingerprint"] = M.bioHolder.fingerprints
				R["p_stat"] = "Active"
				R["m_stat"] = "Stable"
				src.active1 = R
				found = 1

		if(found == 0)
			src.active1 = new /datum/db_record()
			src.active1["id"] = num2hex(rand(1, 1.6777215E7),6)
			src.active1["rank"] = "Unassigned"
			//Update Information
			src.active1["name"] = M.name
			src.active1["sex"] = M.gender
			src.active1["pronouns"] = M.get_pronouns().name
			src.active1["age"] = M.bioHolder.age
			/////Fingerprint record update
			if (M.gloves)
				src.active1["fingerprint"] = "Unknown"
			else
				src.active1["fingerprint"] = M.bioHolder.fingerprints
			src.active1["p_stat"] = "Active"
			src.active1["m_stat"] = "Stable"
			data_core.general.add_record(src.active1)
			found = 0

		////Security Records
		var/datum/db_record/E = data_core.security.find_record("name", src.active1["name"])
		if(E)
			switch (mode)
				if(PRISONER_MODE_NONE)
					E["criminal"] = "None"

				if(PRISONER_MODE_PAROLED)
					E["criminal"] = "Parolled"

				if(PRISONER_MODE_RELEASED)
					E["criminal"] = "Released"

				if(PRISONER_MODE_INCARCERATED)
					E["criminal"] = "Incarcerated"
			E["sec_flag"] = src.sechud_flag
			return

		src.active2 = new /datum/db_record()
		src.active2["name"] = src.active1["name"]
		src.active2["id"] = src.active1["id"]
		switch (mode)
			if(PRISONER_MODE_NONE)
				src.active2["criminal"] = "None"

			if(PRISONER_MODE_PAROLED)
				src.active2["criminal"] = "Parolled"

			if(PRISONER_MODE_RELEASED)
				src.active2["criminal"] = "Released"

			if(PRISONER_MODE_INCARCERATED)
				src.active2["criminal"] = "Incarcerated"

		src.active2["sec_flag"] = src.sechud_flag
		src.active2["mi_crim"] = "None"
		src.active2["mi_crim_d"] = "No minor crime convictions."
		src.active2["ma_crim"] = "None"
		src.active2["ma_crim_d"] = "No major crime convictions."
		src.active2["notes"] = "No notes."
		data_core.security.add_record(src.active2)

		return

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)

	proc/switch_mode(var/mode, set_flag, var/mob/user)
		if (set_flag)
			var/flag = tgui_input_text(user, "Flag:", "Set SecHUD Flag", initial(src.sechud_flag), SECHUD_FLAG_MAX_CHARS)
			if (!isnull(flag) && src.sechud_flag != flag)
				src.sechud_flag = flag
				tooltip_rebuild = TRUE
		else if (src.mode != mode)
			src.mode = mode
			tooltip_rebuild = TRUE

			switch (mode)
				if(PRISONER_MODE_NONE)
					boutput(user, "<span class='notice'>you switch the record mode to None.</span>")

				if(PRISONER_MODE_PAROLED)
					boutput(user, "<span class='notice'>you switch the record mode to Paroled.</span>")

				if(PRISONER_MODE_RELEASED)
					boutput(user, "<span class='notice'>you switch the record mode to Released.</span>")

				if(PRISONER_MODE_INCARCERATED)
					boutput(user, "<span class='notice'>you switch the record mode to Incarcerated.</span>")

		add_fingerprint(user)
		return

	dropped(var/mob/user)
		. = ..()
		if (src.sechud_flag != initial(src.sechud_flag))
			src.sechud_flag = initial(src.sechud_flag)
			tooltip_rebuild = TRUE
		user.closeContextActions()

//// Prisoner Scanner Context Action
/datum/contextAction/prisoner_scanner
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = FALSE
	desc = ""
	icon_state = "wrench"
	var/mode = PRISONER_MODE_NONE

	execute(var/obj/item/device/prisoner_scanner/prisoner_scanner, var/mob/user)
		if(!istype(prisoner_scanner))
			return
		prisoner_scanner.switch_mode(src.mode, istype(src, /datum/contextAction/prisoner_scanner/set_sechud_flag), user)

	checkRequirements(var/obj/item/device/prisoner_scanner/prisoner_scanner, var/mob/user)
		return prisoner_scanner in user

	// a "mode" that acts as a simple way to set the sechud flag
	set_sechud_flag
		name = "Set Flag"
		icon_state = "flag"
	Paroled
		name = "Paroled"
		icon_state = "paroled"
		mode = PRISONER_MODE_PAROLED
	incarcerated
		name = "Incarcerated"
		icon_state = "incarcerated"
		mode = PRISONER_MODE_INCARCERATED
	released
		name = "Released"
		icon_state = "released"
		mode = PRISONER_MODE_RELEASED
	none
		name = "None"
		icon_state = "none"
		mode = PRISONER_MODE_NONE

#undef PRISONER_MODE_NONE
#undef PRISONER_MODE_PAROLED
#undef PRISONER_MODE_RELEASED
#undef PRISONER_MODE_INCARCERATED

/obj/item/device/ticket_writer
	name = "Security TicketWriter 2000"
	desc = "A device used to issue tickets from the security department."
	icon_state = "ticketwriter"
	item_state = "electronic"
	w_class = W_CLASS_SMALL

	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT

	attack_self(mob/user)
		var/menuchoice = tgui_alert(user, "What would you like to do?", "Ticket writer", list("Ticket", "Nothing"))
		if (!menuchoice || menuchoice == "Nothing")
			return
		else if (menuchoice == "Ticket")
			src.ticket(user)

	proc/ticket(mob/user)
		var/obj/item/card/id/I
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			I = H.wear_id
		else if (ismobcritter(user))
			I = locate(/obj/item/card/id) in user.contents
		else if (issilicon(user))
			var/mob/living/silicon/S = user
			I = S.botcard
		if (!I || !(access_security in I.access))
			boutput(user, "<span class='alert'>Insufficient access.</span>")
			return
		playsound(src, 'sound/machines/keyboard3.ogg', 30, 1)
		var/issuer = I.registered
		var/issuer_job = I.assignment
		var/ticket_target = input(user, "Ticket recipient:", "Recipient", "Ticket Recipient") as text
		if (!ticket_target)
			return
		ticket_target = copytext(sanitize(html_encode(ticket_target)), 1, MAX_MESSAGE_LEN)
		var/ticket_reason = input(user, "Ticket reason:", "Reason") as text
		if (!ticket_reason)
			return
		ticket_reason = copytext(sanitize(html_encode(ticket_reason)), 1, MAX_MESSAGE_LEN)

		var/ticket_text = "[ticket_target] has been officially [pick("cautioned","warned","told off","yelled at","berated","sneered at")] by Nanotrasen Corporate Security for [ticket_reason] on [time2text(world.realtime, "DD/MM/53")].<br>Issued by: [issuer] - [issuer_job]<br>"

		var/datum/ticket/T = new /datum/ticket()
		T.target = ticket_target
		T.reason = ticket_reason
		T.issuer = issuer
		T.issuer_job = issuer_job
		T.text = ticket_text
		T.target_byond_key = get_byond_key(T.target)
		T.issuer_byond_key = user.key
		data_core.tickets += T

		logTheThing(LOG_ADMIN, user, "tickets <b>[ticket_target]</b> with the reason: [ticket_reason].")
		playsound(src, 'sound/machines/printer_thermal.ogg', 50, 1)
		SPAWN(3 SECONDS)
			var/obj/item/paper/p = new /obj/item/paper
			p.set_loc(get_turf(src))
			p.name = "Official Caution - [ticket_target]"
			p.info = ticket_text
			p.icon_state = "paper_caution"

		return T.target_byond_key




TYPEINFO(/obj/item/device/appraisal)
	mats = 5

/obj/item/device/appraisal
	name = "cargo appraiser"
	desc = "Handheld scanner hooked up to Cargo's market computers. Estimates sale value of various items."
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	m_amt = 150
	icon_state = "CargoA"
	item_state = "electronic"

	attack(mob/M, mob/user)
		return

	// attack_self
	// would be neat to maybe add an option to print a receipt or invoice?
	// like if you wanna buy botany's stuff, this can print out what's inside
	// and the cargo value, and then
	// i dunno, who knows. at least you'd be able to take stock easier.

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0)
			return

		var/datum/artifact/art = null
		var/obj/O = A
		if (isobj(A))
			art = O.artifact
		else
			// objs only
			return

		var/sell_value = 0
		var/out_text = ""
		if (art)
			var/obj/item/sticker/postit/artifact_paper/pap = locate(/obj/item/sticker/postit/artifact_paper/) in O.vis_contents
			if (pap?.artifactType)
				out_text = "<strong>The following values depend on correct analysis of the artifact<br>Average price for [pap.artifactType] type artifacts</strong><br>"
				// the unrandomized sell value for an artifact of the type detailed on the form, with perfect analysis
				sell_value = shippingmarket.calculate_artifact_price(artifact_controls.artifact_types_from_name[pap.artifactType].get_rarity_modifier(), 3)
				sell_value = round(sell_value, 5)
			else if (pap)
				boutput(user, "<span class='alert'>Attached Analysis Form&trade; needs to be filled out!</span>")
				return
			else
				boutput(user, "<span class='alert'>Artifact appraisal is only possible via an attached Analysis Form&trade;!</span>")
				return

		else if (istype(A, /obj/storage/crate))
			sell_value = -1
			var/obj/storage/crate/C = A
			if (C.delivery_destination)
				for (var/datum/trader/T in shippingmarket.active_traders)
					if (T.crate_tag == C.delivery_destination)
						sell_value = shippingmarket.appraise_value(C.contents, T.goods_buy, sell = 0)
						out_text = "<strong>Prices from [T.name]</strong><br>"
				for (var/datum/req_contract/RC in shippingmarket.req_contracts)
					if(C.delivery_destination == "REQ_THIRDPARTY")
						out_text = "<strong>Cannot evaluate third-party sales.</strong><br>"
					else if (RC.req_code == C.delivery_destination)
						var/evaluated = RC.requisify(C,TRUE)
						if(evaluated == "Contents sufficient for marked requisition.")
							sell_value = RC.payout
						out_text = "<strong>[evaluated]</strong><br>"

			if (sell_value == -1)
				// no trader on the crate
				sell_value = shippingmarket.appraise_value(A.contents, sell = 0)

		else if (istype(A, /obj/storage))
			var/obj/storage/S = A
			if (S.welded)
				// you cant do this
				boutput(user, "<span class='alert'>\The [A] is welded shut and can't be scanned.</span>")
				return
			if (S.locked)
				// you cant do this either
				boutput(user, "<span class='alert'>\The [A] is locked closed and can't be scanned.</span>")
				return

			out_text = "<span class='alert'>Contents must be placed in a crate to be sold!</span><br>"
			sell_value = shippingmarket.appraise_value(S.contents, sell = 0)

		else if (istype(A, /obj/item/satchel))
			out_text = "<span class='alert'>Contents must be placed in a crate to be sold!</span><br>"
			sell_value = shippingmarket.appraise_value(A.contents, sell = 0)

		else if (istype(A, /obj/item))
			sell_value = shippingmarket.appraise_value(list( A ), sell = 0)

		// replace with boutput
		boutput(user, "<span class='notice'>[out_text]Estimated value: <strong>[sell_value] credit\s.</strong></span>")
		if (sell_value > 0)
			playsound(src, 'sound/machines/chime.ogg', 10, 1)

		if (user.client && !user.client.preferences?.flying_chat_hidden)
			var/image/chat_maptext/chat_text = null
			var/popup_text = "<span class='ol c pixel'[sell_value == 0 ? " style='color: #bbbbbb;'>No value" : ">[round(sell_value)][CREDIT_SIGN]"]</span>"
			chat_text = make_chat_maptext(A, popup_text, alpha = 180, force = 1, time = 1.5 SECONDS)
			// many of the artifacts are upside down and stuff, it makes text a bit hard to read!
			chat_text.appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | PIXEL_SCALE
			if (chat_text)
				// don't bother bumping up other things
				chat_text.show_to(user.client)

