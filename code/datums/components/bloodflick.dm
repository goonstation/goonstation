TYPEINFO(/datum/component/bloodflick)
	initialization_args = list()

/datum/component/bloodflick

/datum/component/bloodflick/Initialize()
	. = ..()
	if (!isitem(src.parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, PROC_REF(handle_impact))
	RegisterSignal(parent, COMSIG_UPDATE_ICON, PROC_REF(redraw_impacts)) // just in case

/datum/component/bloodflick/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_HITBY_PROJ)
	. = ..()

/datum/component/bloodflick/proc/flick()
	var/isbloody = FALSE
	if (src.blood_DNA)
		isbloody = TRUE
		make_cleanable(/obj/decal/cleanable/blood, get_turf(src))
		src.clean_forensic()
	return isbloody
