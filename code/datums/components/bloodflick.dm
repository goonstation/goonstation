TYPEINFO(/datum/component/bloodflick)
	initialization_args = list()

/// a component that makes items flick blood off them and onto the ground when twirled.
/datum/component/bloodflick
	/// is the blood on the parent dried? if so, can't be cleaned by flicking.
	var/hasdry = FALSE
	/// Can blood be flicked off?
	var/haswet = FALSE
	/// a counter. represents how many sets of wet blood are on the parent
	var/iswet = 0
	/// how long the blood takes to dry.
	var/drytime = 30 SECONDS

/datum/component/bloodflick/Initialize()
	if (!isitem(src.parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/blade = src.parent
	RegisterSignal(parent, COMSIG_ITEM_TWIRLED, PROC_REF(flick))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_POST, PROC_REF(wetten))
	RegisterSignal(parent, COMSIG_ATOM_CLEANED, PROC_REF(clean))
	..()

/datum/component/bloodflick/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_TWIRLED)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	UnregisterSignal(parent, COMSIG_ATOM_CLEANED)
	..()

/datum/component/bloodflick/proc/flick()
	var/obj/item/blade = src.parent
	if (!blade.blood_DNA)
		return
	// if all the blood is wet, flicking it off cleans it.
	if (!src.hasdry)
		blade.clean_forensic()
	// if there's wet blood on it, flick it off
	if (src.haswet)
		src.haswet = FALSE
		make_cleanable(/obj/decal/cleanable/blood, get_turf(src.parent))
		playsound(blade.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 40, 1)
		SPAWN(1 DECI SECOND) // so that the twirl emote message appears first (in theory)
			boutput("Blood splatters onto the floor!") // i will be accepting suggestions on this line btw, reviewers

/// applies wet blood to the knife and starts the blood drying countdown
/datum/component/bloodflick/proc/wetten()
	var/obj/item/dummy = src.parent
	if (!dummy.blood_DNA) // not all attacks leave blood on the blade
		return
	if (!src.haswet)
		src.haswet = TRUE
		src.iswet += 1
	SPAWN(drytime)
		// in case
		if (!src)
			return
		// it could get cleaned while it's drying
		if (!dummy.blood_DNA)
			return
		// if the blade is wet, dry it
		if (src.haswet)
			src.hasdry = TRUE
			src.iswet -= 1
		if (!src.iswet)
			src.haswet = FALSE

/// resets the variables
/datum/component/bloodflick/proc/clean()
	src.hasdry = FALSE
	src.haswet = FALSE
	src.iswet = 0
