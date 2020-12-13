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

/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT|ONBELT|TABLEPASS
	w_class = 2
	item_state = "electronic"
	m_amt = 150
	mats = 5
	module_research = list("analysis" = 2, "engineering" = 2, "devices" = 1)
	module_research_type = /obj/item/device/t_scanner

	attack_self(mob/user)
		on = !on
		set_icon_state("t-ray[on]")
		boutput(user, "You switch [src] [on ? "on" : "off"].")

		if(on) processing_items |= src

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (istype(A, /turf))
			if (get_dist(A,user) > 1) // Scanning for COOL LORE SECRETS over the camera network is fun, but so is drinking and driving.
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

	process()
		if(!on)
			processing_items.Remove(src)
			return null

		var/loc_to_check = istype(src.loc, /obj/item/magtractor) ? src.loc.loc : src.loc
		src = null
		for(var/turf/T in range(1, loc_to_check))

			if(T.interesting)
				playsound(T, "sound/machines/ping.ogg", 55, 1)

			if(!T.intact)
				continue

			for(var/obj/O in T.contents)

				if(O.level != 1)
					continue

				if(O.invisibility == 101)
					O.invisibility = 0
					O.alpha = 128
					SPAWN_DBG(1 SECOND)
						if(O && isturf(O.loc))
							var/turf/U = O.loc
							if(U.intact)
								O.invisibility = 101
								O.alpha = 255

			var/mob/living/M = locate() in T
			if(M?.invisibility == 2)
				M.invisibility = 0
				SPAWN_DBG(0.6 SECONDS)
					if(M)
						M.invisibility = 2



		for(var/obj/O in range(1, loc_to_check) )
			if(O.interesting)
				playsound(O.loc, "sound/machines/ping.ogg", 55, 1)

/obj/item/device/t_scanner/abilities = list(/obj/ability_button/tscanner_toggle)

/obj/item/device/t_scanner/adventure
	name = "experimental scanner"
	desc = "a bodged-together T-Ray scanner with a few coils cut, and a few extra coils tied-in."
//	var/trange = 2 //depending how sluggish this is, could go up to 3 with a toggle perhaps?

	process()
		if(!on)
			processing_items.Remove(src)
			return null

		var/loc_to_check = istype(src.loc, /obj/item/magtractor) ? src.loc.loc : src.loc
		src = null
		for(var/turf/T in range(2, loc_to_check))

			if(T.interesting)
				playsound(T, "sound/machines/ping.ogg", 55, 1)

			if(!T.intact)
				continue

			var/mob/living/M = locate() in T
			if(M?.invisibility == 2)
				M.invisibility = 0
				SPAWN_DBG(0.6 SECONDS)
					if(M)
						M.invisibility = 2

		for(var/obj/O in range(2, loc_to_check) )
			if(O.interesting)
				playsound(O.loc, "sound/machines/ping.ogg", 55, 1)

/*
he`s got a craving
for american haiku
that cannot be itched
*/

//////////////////////////////////////// Forensic scanner ///////////////////////////////////

/obj/item/device/detective_scanner
	name = "forensic scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "fs"
	w_class = 2 // PDA fits in a pocket, so why not the dedicated scanner (Convair880)?
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | SUPPRESSATTACK
	mats = 3
	hide_attack = 2
	var/active = 0
	var/target = null

	attack_self(mob/user as mob)

		src.add_fingerprint(user)

		var/search = input(user, "Enter name, fingerprint or blood DNA.", "Find record", "") as null|text
		if (!search || user.stat)
			return
		search = copytext(sanitize(search), 1, 200)
		search = lowertext(search)

		for (var/datum/data/record/R in data_core.general)
			if (search == lowertext(R.fields["dna"]) || search == lowertext(R.fields["fingerprint"]) || search == lowertext(R.fields["name"]))

				var/data = "--------------------------------<br>\
				<font color='blue'>Match found in security records:<b> [R.fields["name"]]</b> ([R.fields["rank"]])</font><br>\
				<br>\
				<i>Fingerprint:</i><font color='blue'> [R.fields["fingerprint"]]</font><br>\
				<i>Blood DNA:</i><font color='blue'> [R.fields["dna"]]</font>"

				boutput(user, data)
				return

		user.show_text("No match found in security records.", "red")
		return

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)

		if (get_dist(A,user) > 1 || istype(A, /obj/ability_button)) // Scanning for fingerprints over the camera network is fun, but doesn't really make sense (Convair880).
			return

		user.visible_message("<span class='alert'><b>[user]</b> has scanned [A].</span>")
		boutput(user, scan_forensic(A, visible = 1)) // Moved to scanprocs.dm to cut down on code duplication (Convair880).
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
		switch(get_dist(src,target))
			if(0)
				icon_state = "fs_pindirect"
			if(1 to 8)
				icon_state = "fs_pinclose"
			if(9 to 16)
				icon_state = "fs_pinmedium"
			if(16 to INFINITY)
				icon_state = "fs_pinfar"
		SPAWN_DBG(0.5 SECONDS)
			.(T)

///////////////////////////////////// Health analyzer ////////////////////////////////////////

/obj/item/device/analyzer/healthanalyzer
	name = "health analyzer"
	icon_state = "health-no_up"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "healthanalyzer-no_up" // someone made this sprite and then this was never changed to it for some reason???
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	mats = 5
	var/disease_detection = 1
	var/reagent_upgrade = 0
	var/reagent_scan = 0
	var/organ_upgrade = 0
	var/organ_scan = 0
	module_research = list("analysis" = 2, "medicine" = 2, "devices" = 1)
	module_research_type = /obj/item/device/analyzer/healthanalyzer
	hide_attack = 2

	attack_self(mob/user as mob)
		if (!src.reagent_upgrade && !src.organ_upgrade)
			boutput(user, "<span class='alert'>No upgrades detected!</span>")

		else if (src.reagent_upgrade && src.organ_upgrade)
			if (src.reagent_scan && src.organ_scan)				//if both active, make both off
				src.reagent_scan = 0
				src.organ_scan = 0
				boutput(user, "<span class='alert'>All upgrades disabled.</span>")

			else if (!src.reagent_scan && !src.organ_scan)		//if both inactive, turn reagent on
				src.reagent_scan = 1
				src.organ_scan = 0
				boutput(user, "<span class='alert'>Reagent scanner enabled.</span>")

			else if (src.reagent_scan)							//if reagent active, turn reagent off, turn organ on
				src.reagent_scan = 0
				src.organ_scan = 1
				boutput(user, "<span class='alert'>Reagent scanner disabled. Organ scanner enabled.</span>")

			else if (src.organ_scan)							//if organ active, turn BOTH on
				src.reagent_scan = 1
				src.organ_scan = 1
				boutput(user, "<span class='alert'>All upgrades enabled.</span>")

		else if (src.reagent_upgrade)
			src.reagent_scan = !(src.reagent_scan)
			boutput(user, "<span class='notice'>Reagent scanner [src.reagent_scan ? "enabled" : "disabled"].</span>")
		else if (src.organ_upgrade)
			src.organ_scan = !(src.organ_scan)
			boutput(user, "<span class='notice'>Organ scanner [src.organ_scan ? "enabled" : "disabled"].</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		addUpgrade(src, W, user, src.reagent_upgrade)
		..()

	attack(mob/M as mob, mob/user as mob)
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
		boutput(user, scan_health(M, src.reagent_scan, src.disease_detection, src.organ_scan, visible = 1))
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



/obj/item/device/analyzer/healthanalyzer/borg
	icon_state = "health"
	reagent_upgrade = 1
	reagent_scan = 1
	organ_upgrade = 1
	organ_scan = 1

/obj/item/device/analyzer/healthanalyzer/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/device/analyzer/healthanalyzer_upgrade
	name = "health analyzer upgrade"
	desc = "A small upgrade card that allows standard health analyzers to detect reagents present in the patient, and ProDoc Healthgoggles to scan patients' health from a distance."
	icon_state = "health_upgr"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	mats = 2

/obj/item/device/analyzer/healthanalyzer_organ_upgrade
	name = "health analyzer organ scan upgrade"
	desc = "A small upgrade card that allows standard health analyzers to detect the health of induvidual organs in the patient."
	icon_state = "organ_health_upgr"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	mats = 2

///////////////////////////////////// Reagent scanner //////////////////////////////

/obj/item/device/reagentscanner
	name = "reagent scanner"
	icon_state = "reagentscan"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "reagentscan"
	desc = "A hand-held device that scans and lists the chemicals inside the scanned subject."
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	mats = 5
	var/scan_results = null
	module_research = list("analysis" = 2, "science" = 2, "devices" = 1)
	module_research_type = /obj/item/device/reagentscanner
	hide_attack = 2
	tooltip_flags = REBUILD_DIST

	attack(mob/M as mob, mob/user as mob)
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

/obj/item/device/analyzer/atmospheric
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "atmospheric analyzer"
	icon_state = "atmos-no_up"
	item_state = "analyzer"
	w_class = 2
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 5
	w_class = 2
	throw_speed = 4
	throw_range = 20
	mats = 3
	module_research = list("analysis" = 2, "atmospherics" = 2, "devices" = 1)
	module_research_type = /obj/item/device/analyzer/atmospheric
	var/analyzer_upgrade = 0

	// Distance upgrade action code
	pixelaction(atom/target, params, mob/user, reach)
		var/turf/T = get_turf(target)
		if ((analyzer_upgrade == 1) && (get_dist(user, T)>1))
			usr.visible_message("<span class='notice'><b>[user]</b> takes a distant atmospheric reading of [T].</span>")
			boutput(user, scan_atmospheric(T, visible = 1))
			src.add_fingerprint(user)
			return

	attack_self(mob/user as mob)
		if (user.stat)
			return

		src.add_fingerprint(user)

		var/turf/location = get_turf(user)
		if (isnull(location))
			user.show_text("Unable to obtain a reading.", "red")
			return

		user.visible_message("<span class='notice'><b>[user]</b> takes an atmospheric reading of [location].</span>")
		boutput(user, scan_atmospheric(location, visible = 1)) // Moved to scanprocs.dm to cut down on code duplication (Convair880).
		return

	attackby(obj/item/W as obj, mob/user as mob)
		addUpgrade(src, W, user, src.analyzer_upgrade)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (get_dist(A, user) > 1 || istype(A, /obj/ability_button))
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
				SPAWN_DBG(0)
					det.detonate()
		return

/obj/item/device/analyzer/atmospheric/upgraded //for borgs because JESUS FUCK
	analyzer_upgrade = 1
	icon_state = "atmos"

/obj/item/device/analyzer/atmosanalyzer_upgrade
	name = "atmospherics analyzer upgrade"
	desc = "A small upgrade card that allows standard atmospherics analyzers to detect environmental information at a distance."
	icon_state = "atmos_upgr" // add this
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	mats = 2

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
				a.item_state = "healthanalyzer"

			else if (istype(W, /obj/item/device/analyzer/healthanalyzer_organ_upgrade))
				if (a.organ_upgrade)
					boutput(user, "<span class='alert'>This analyzer already has an internal organ scan upgrade!</span>")
					return
				a.organ_upgrade = 1
				a.organ_scan = 1
				a.icon_state = a.reagent_upgrade ? "health" : "health-o-up"
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
		playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
		user.u_equip(W)
		qdel(W)


///////////////////////////////////////////////// Prisoner scanner ////////////////////////////////////

/obj/item/device/prisoner_scanner
	name = "Security RecordTrak"
	desc = "A device used to scan in prisoners and update their security records."
	icon_state = "recordtrak"
	var/mode = 1
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	w_class = 3.0
	item_state = "recordtrak"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | EXTRADELAY
	mats = 3

	attack(mob/living/carbon/human/M as mob, mob/user as mob)
		////General Records
		var/found = 0
		//if( !istype(get_area(src), /area/security/prison) && !istype(get_area(src), /area/security/main))
		//	boutput(user, "<span class='alert'>Device only works in designated security areas!</span>")
		//	return
		boutput(user, "<span class='notice'>You scan in [M]</span>")
		boutput(M, "<span class='alert'>[user] scans you with the Securotron-5000</span>")
		for(var/datum/data/record/R in data_core.general)
			if (lowertext(R.fields["name"]) == lowertext(M.name))
				//Update Information
				R.fields["name"] = M.name
				R.fields["sex"] = M.gender
				R.fields["age"] = M.bioHolder.age
				if (M.gloves)
					R.fields["fingerprint"] = "Unknown"
				else
					R.fields["fingerprint"] = M.bioHolder.uid_hash
				R.fields["p_stat"] = "Active"
				R.fields["m_stat"] = "Stable"
				src.active1 = R
				found = 1

		if(found == 0)
			src.active1 = new /datum/data/record()
			src.active1.fields["id"] = num2hex(rand(1, 1.6777215E7),6)
			src.active1.fields["rank"] = "Unassigned"
			//Update Information
			src.active1.fields["name"] = M.name
			src.active1.fields["sex"] = M.gender
			src.active1.fields["age"] = M.bioHolder.age
			/////Fingerprint record update
			if (M.gloves)
				src.active1.fields["fingerprint"] = "Unknown"
			else
				src.active1.fields["fingerprint"] = M.bioHolder.uid_hash
			src.active1.fields["p_stat"] = "Active"
			src.active1.fields["m_stat"] = "Stable"
			data_core.general += src.active1
			found = 0

		////Security Records
		for(var/datum/data/record/E in data_core.security)
			if (E.fields["name"] == src.active1.fields["name"])
				if(src.mode == 1)
					E.fields["criminal"] = "Incarcerated"
				else if(src.mode == 2)
					E.fields["criminal"] = "Parolled"
				else if(src.mode == 3)
					E.fields["criminal"] = "Released"
				else
					E.fields["criminal"] = "None"
				return

		src.active2 = new /datum/data/record()
		src.active2.fields["name"] = src.active1.fields["name"]
		src.active2.fields["id"] = src.active1.fields["id"]
		src.active2.name = text("Security Record #[]", src.active1.fields["id"])
		if(src.mode == 1)
			src.active2.fields["criminal"] = "Incarcerated"
		else if(src.mode == 2)
			src.active2.fields["criminal"] = "Parolled"
		else if(src.mode == 3)
			src.active2.fields["criminal"] = "Released"
		else
			src.active2.fields["criminal"] = "None"
		src.active2.fields["mi_crim"] = "None"
		src.active2.fields["mi_crim_d"] = "No minor crime convictions."
		src.active2.fields["ma_crim"] = "None"
		src.active2.fields["ma_crim_d"] = "No major crime convictions."
		src.active2.fields["notes"] = "No notes."
		data_core.security += src.active2

		return

	attack_self(mob/user as mob)

		if (src.mode == 1)
			src.mode = 2
			boutput(user, "<span class='notice'>you switch the record mode to Parolled</span>")
		else if (src.mode == 2)
			src.mode = 3
			boutput(user, "<span class='notice'>you switch the record mode to Released</span>")
		else if (src.mode == 3)
			src.mode = 4
			boutput(user, "<span class='notice'>you switch the record mode to None</span>")
		else
			src.mode = 1
			boutput(user, "<span class='notice'>you switch the record mode to Incarcerated</span>")

		add_fingerprint(user)
		return
