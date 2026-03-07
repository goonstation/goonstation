// Contents
// Handheld device analyzer
// Electronics Scan file
// Ruckingenur Data file

/obj/item/electronics/scanner
	name = "device analyzer"
	icon_state = "deviceana"
	desc = "Used for scanning certain items for use with the ruckingenur kit."
	force = 2
	hit_type = DAMAGE_BLUNT
	throwforce = 5
	w_class = W_CLASS_SMALL
	pressure_resistance = 50
	var/list/scanned = list()
	var/viewstat = 0
	var/scannable_tags = DEVICE_ANALYZER_ALLOWED_TAGS

	New()
		. = ..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby))

	get_desc()
		// We display this on a separate line and with a different color to show emphasis
		. = ..()
		. += "<br>[SPAN_NOTICE("Use the Help, Disarm, or Grab intents to scan objects when you click them. Switch to Harm intent do other things.")]"
		. += "<br>Scanned items:"
		if (!length(src.scanned))
			. += " None"
			return
		for (var/obj/item_type as anything in src.scanned)
			var/typeinfo/obj/typeinfo = get_type_typeinfo(item_type)
			if (typeinfo.analyser_flags & ANALYSER_SYNDIE_ONLY)
				continue
			. += "<br>-" + "\proper[initial(item_type.name)]"

	proc/pre_attackby(obj/item/parent_item, atom/A, mob/user)
		if (user.a_intent == INTENT_HARM)
			return

		var/datum/computer/file/electronics_scan/theScan = new
		var/scan_result = SEND_SIGNAL(A, COMSIG_ATOM_ANALYZE, parent_item, user, DEVICE_ANALYZER_ALLOWED_TAGS, scanned, theScan)

		if(scan_result == ANALYSIS_SIGNAL_SUCCESS)
			if (!isnull(theScan.scannedPath))
				src.scanned += theScan.scannedPath
		else if(scan_result == ANALYSIS_SIGNAL_SKIPPED)
			return

		return TRUE


/obj/item/electronics/scanner/syndicate
	scannable_tags = DEVICE_ANALYZER_ALLOWED_TAGS | ANALYSER_SYNDIE_ONLY //We allow anything we can scan including syndie items


/datum/computer/file/electronics_scan
	name = "scanfile"
	extension = "OSCN"
	var/scannedName = null
	var/scannedPath = null
	var/scannedMats = null

/datum/computer/file/electronics_bundle
	name = "Ruckingenur Data"
	extension = "DSCN"
	var/datum/mechanic_controller/ruckData = null
	var/target = null
	var/known_rucks = null
