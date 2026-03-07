/**
  * Makes an object scannable by the device analyzer.
  * The result type is drawn from either the parent's typepath or its typeinfo.manufactured_type.
  * Syndicate objects can't be scanned by non-Syndicate scanners.
  */
/datum/component/analyzable
	/// When this component is scanned, it will add the following typepath to the device analyzer's database
	var/result_type

TYPEINFO(/datum/component/analyzable)
	initialization_args = list(
		ARG_INFO("type_override", DATA_INPUT_TYPE, "the typepath that scanning this object will provide")
	)

/datum/component/analyzable/Initialize(type_override)
	. = ..()
	if (ismovable(parent))
		var/typeinfo/obj/typeinfo = parent.get_typeinfo()
		if(!(typeinfo.analyser_flags & ANALYSER_ALLOWED))
			return COMPONENT_INCOMPATIBLE
	else
		return COMPONENT_INCOMPATIBLE
	src.result_type = type_override
	RegisterSignal(parent, COMSIG_ATOM_ANALYZE, PROC_REF(attempt_analysis))

/datum/component/analyzable/proc/attempt_analysis(obj/parent_atom, obj/item/I, mob/user, scannable_tags, list/scanned, datum/computer/file/electronics_scan/theScan)
	PRIVATE_PROC(TRUE)
	// parent_atom can be safely cast as an obj in arguments without other checks because the component can only be applied to objs
	if (parent_atom.disposed)
		return
	var/obj/scanned_item = parent_atom

	var/scan_result = MECHANICS_ANALYSIS_SUCCESS
	// if this item doesn't have mats defined or was constructed or
	// attempting to scan a syndicate item and this is a normal scanner
	var/typeinfo/obj/typeinfo = get_type_typeinfo(result_type)

	if (isnull(typeinfo.mats) || typeinfo.mats == 0) //If no mats are defined it's sort of hard to manufacture lol
		scan_result = MECHANICS_ANALYSIS_IMPOSSIBLE
	else if(!(typeinfo.analyser_flags & ANALYSER_ALLOWED)) //Item isn't allowed? ban he
		scan_result = MECHANICS_ANALYSIS_IMPOSSIBLE
	else if(((typeinfo.analyser_flags & ANALYSER_SYNDIE_ONLY) && !(scannable_tags & ANALYSER_SYNDIE_ONLY))) //Some can only be scanned by syndie scanners
		scan_result = MECHANICS_ANALYSIS_ILLEGAL
	else if((typeinfo.analyser_flags & scannable_tags) <= 0)
		scan_result = MECHANICS_ANALYSIS_INCOMPATIBLE
	else if(scanned.Find(src.result_type))
		scan_result = MECHANICS_ANALYSIS_ALREADY_SCANNED


	var/scan_output = null
	switch (scan_result)
		if (MECHANICS_ANALYSIS_IMPOSSIBLE) //Send signal also returns 0 if analysis comp doesn't exist and MECHANICS_ANALYSIS_IMPOSSIBLE == 0
			scan_output = SPAN_ALERT("[scanned_item] cannot be reverse engineered.")
		if (MECHANICS_ANALYSIS_INCOMPATIBLE)
			scan_output = SPAN_ALERT("The structure of \the [scanned_item] is not compatible with [I].")
		if (MECHANICS_ANALYSIS_ILLEGAL)
			playsound(I.loc, 'sound/machines/buzz-sigh.ogg', 10, FALSE)
			scan_output = SPAN_ALERT("The scanner makes a disgruntled beep informing you that would be illegal.")
		if (MECHANICS_ANALYSIS_SUCCESS)
			scan_output = SPAN_NOTICE("[scanned_item] scanned successful.")
			playsound(I.loc, 'sound/machines/tone_beep.ogg', 30, FALSE)
		if (MECHANICS_ANALYSIS_ALREADY_SCANNED)
			scan_output = SPAN_ALERT("You have already scanned \an [scanned_item].")

	if (!isnull(scan_output))
		if((typeinfo.analyser_flags & ANALYSER_FAILFEEDBACK && !(typeinfo.analyser_flags & ANALYSER_SKIP_IF_FAIL)) || scan_result == MECHANICS_ANALYSIS_SUCCESS)
			// this is technically sleight of hand, since the effects of scanning are only shown after the scan is actually done
			// doing this is a lot cleaner, though, than displaying some or all of the messages if the target has ANALYSER_SKIP_IF_FAIL
			do_scan_effects(scanned_item, user, I)
			boutput(user, scan_output)

	if(scan_result == MECHANICS_ANALYSIS_SUCCESS)
		theScan.scannedPath = result_type
		var/atom/atom_cast = theScan.scannedPath
		theScan.scannedName = initial(atom_cast.name)
		theScan.scannedMats = typeinfo.mats

		return ANALYSIS_SIGNAL_SUCCESS
	else
		if(typeinfo.analyser_flags & ANALYSER_SKIP_IF_FAIL)
			return ANALYSIS_SIGNAL_SKIPPED
		else
			return ANALYSIS_SIGNAL_FAILURE

/datum/component/analyzable/proc/do_scan_effects(atom/target, mob/user, obj/item/I)
		// more often than not, this will display for objects, but we include a message to scanned mobs just for consistency's sake
	user.tri_message(target,
		SPAN_NOTICE("[user] scans [user == target ? himself_or_herself(user) : target] with [I]."), \
		SPAN_NOTICE("You run \the [I] over [user == target ? "yourself" : target]..."), \
		SPAN_NOTICE("[user] waves \an [I] at you. You feel [pick("funny", "weird", "odd", "strange", "off")].")
	)
	animate_scanning(target, "#FFFF00")

/datum/component/analyzer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ANALYZE)
	. = ..()
