TYPEINFO(/datum/component/bloodflick)
	initialization_args = list()

/datum/component/bloodflick
	/// typecasted thing that we're flicking blood off.
	var/obj/item/blade

/datum/component/bloodflick/Initialize()
	if (isitem(src.parent))
		src.blade = src.parent
	else
		return COMPONENT_INCOMPATIBLE
	..()

/datum/component/bloodflick/proc/flick()
	var/isbloody = FALSE
	if (src.blade.blood_DNA)
		isbloody = TRUE
		make_cleanable(/obj/decal/cleanable/blood, get_turf(src))
		src.blade.clean_forensic()
	return isbloody
