/**
  * Makes an object scannable by the device analyzer.
  * The result type is drawn from either the parent's typepath or its mechanics_type_override.
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
	if (!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/O = parent
	if (O.mechanics_blacklist)
		return COMPONENT_INCOMPATIBLE
	src.result_type = type_override
	RegisterSignal(parent, list(COMSIG_ATOM_ANALYZE), .proc/attempt_analysis)

/datum/component/analyzable/proc/attempt_analysis(atom/parent_atom, obj/item/I, mob/user)
	PRIVATE_PROC(TRUE)
	var/obj/O = parent_atom
	if (O.disposed || !istype(I, /obj/item/electronics/scanner))
		return
	// in the future, this could be replaced with a component for analyzers themselves, too
	var/obj/item/electronics/scanner/S = I
	S.do_scan_effects(O, user)
	if (isnull(O.mats) || O.mats == 0 || (O.is_syndicate && !S.is_syndicate))
		// if this item doesn't have mats defined or was constructed or
		// attempting to scan a syndicate item and this is a normal scanner
		boutput(user, "<span class='alert'>The structure of [O] is not compatible with [S].</span>")
		return TRUE
	if (S.scanned.Find(src.result_type))
		boutput(user, "<span class='alert'>You have already scanned this type of object.</span>")
		return TRUE
	S.scanned += src.result_type
	boutput(user, "<span class='notice'>Item scan successful.</span>")
	playsound(O.loc, "sound/machines/tone_beep.ogg", 30, FALSE)
	return TRUE

/datum/component/analyzer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ANALYZE)
	. = ..()
