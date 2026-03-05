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

	syndicate
		is_syndicate = TRUE

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
			if (initial(item_type.is_syndicate))
				continue
			. += "<br>-" + "\proper[initial(item_type.name)]"

	proc/pre_attackby(obj/item/parent_item, atom/A, mob/user)
		if (user.a_intent == INTENT_HARM)
			return
		var/skip_if_fail = FALSE
		var/scan_result
		if (isobj(A))
			var/obj/O = A
			if (O.mechanics_interaction == MECHANICS_INTERACTION_BLACKLISTED)
				return
			if (O.mechanics_interaction == MECHANICS_INTERACTION_ALWAYS_INCOMPATIBLE)
				scan_result = MECHANICS_ANALYSIS_INCOMPATIBLE
			skip_if_fail = O.mechanics_interaction == MECHANICS_INTERACTION_SKIP_IF_FAIL
		if (!scan_result)
			scan_result = SEND_SIGNAL(A, COMSIG_ATOM_ANALYZE, parent_item, user)
		if (scan_result != MECHANICS_ANALYSIS_SUCCESS && skip_if_fail)
			return
		var/scan_output = null
		switch (scan_result)
			if (MECHANICS_ANALYSIS_SUCCESS)
				scan_output = SPAN_NOTICE("Item scan successful.")
				playsound(A.loc, 'sound/machines/tone_beep.ogg', 30, FALSE)
			if (MECHANICS_ANALYSIS_INCOMPATIBLE, 0) // 0 is returned by SEND_SIGNAL if the component is not present, so we use it here too
				scan_output = SPAN_ALERT("The structure of [A] is not compatible with [parent_item].")
			if (MECHANICS_ANALYSIS_ALREADY_SCANNED)
				scan_output = SPAN_ALERT("You have already scanned this type of object.")
		if (!isnull(scan_output))
			// this is technically sleight of hand, since the effects of scanning are only shown after the scan is actually done
			// doing this is a lot cleaner, though, than displaying some or all of the messages if the target has MECHANICS_INTERACTION_SKIP_IF_FAIL
			do_scan_effects(A, user)
			boutput(user, scan_output)
		return TRUE

	proc/do_scan_effects(atom/target, mob/user)
		// more often than not, this will display for objects, but we include a message to scanned mobs just for consistency's sake
		user.tri_message(target,
			SPAN_NOTICE("[user] scans [user == target ? himself_or_herself(user) : target] with [src]."), \
			SPAN_NOTICE("You run [src] over [user == target ? "yourself" : target]..."), \
			SPAN_NOTICE("[user] waves [src] at you. You feel [pick("funny", "weird", "odd", "strange", "off")].")
		)
		animate_scanning(target, "#FFFF00")


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
