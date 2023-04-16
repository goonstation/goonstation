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
	. = ..()
	if (!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/O = parent
	if (O.mechanics_interaction == MECHANICS_INTERACTION_BLACKLISTED)
		return COMPONENT_INCOMPATIBLE
	src.result_type = type_override
	RegisterSignal(parent, COMSIG_ATOM_ANALYZE, .proc/attempt_analysis)

/datum/component/analyzable/proc/attempt_analysis(obj/parent_atom, obj/item/I, mob/user)
	PRIVATE_PROC(TRUE)
	// parent_atom can be safely cast as an obj in arguments without other checks because the component can only be applied to objs
	if (parent_atom.disposed)
		return
	// if this item doesn't have mats defined or was constructed or
	// attempting to scan a syndicate item and this is a normal scanner
	var/typeinfo/obj/typeinfo = parent_atom.get_typeinfo()
	if (isnull(typeinfo.mats) || typeinfo.mats == 0 || (parent_atom.is_syndicate && !I.is_syndicate))
		return MECHANICS_ANALYSIS_INCOMPATIBLE
	var/obj/item/electronics/scanner/S = I
	if (istype(S))
		if (S.scanned.Find(src.result_type))
			return MECHANICS_ANALYSIS_ALREADY_SCANNED
		S.scanned += src.result_type
	return MECHANICS_ANALYSIS_SUCCESS

/datum/component/analyzer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ANALYZE)
	. = ..()
