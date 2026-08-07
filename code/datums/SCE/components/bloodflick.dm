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
	/// typecasted parent
	var/obj/item/weapon

/datum/component/bloodflick/Initialize()
	if (!isitem(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.weapon = src.parent
	RegisterSignal(parent, COMSIG_ITEM_TWIRLED, PROC_REF(flickblood))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_POST, PROC_REF(wetten))
	RegisterSignal(parent, COMSIG_ATOM_CLEANED, PROC_REF(clean))
	..()

/datum/component/bloodflick/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_TWIRLED)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	UnregisterSignal(parent, COMSIG_ATOM_CLEANED)
	src.weapon = null
	..()

/datum/component/bloodflick/proc/flickblood()
	if (!src.weapon.blood_DNA)
		return
	// if all the blood is wet, flicking it off cleans it.
	if (!src.hasdry)
		src.weapon.clean_forensic()
	// if there's wet blood on it, flick it off
	if (src.haswet)
		src.haswet = FALSE
		var/turf/our_floor = get_turf(src.weapon)
		if (!our_floor)
			return
		make_cleanable(/obj/decal/cleanable/blood, our_floor)
		playsound(our_floor, 'sound/impact_sounds/Slimy_Splat_1.ogg', 40, 1)
		SPAWN(1 DECI SECOND) // so that the twirl emote message appears first (in theory)
			our_floor?.visible_message(SPAN_NOTICE("Blood splatters onto the floor!"), SPAN_NOTICE("You hear a splatter!"), "bloodsplat")

/// applies wet blood to the knife and starts the blood drying countdown
/datum/component/bloodflick/proc/wetten()
	var/obj/item/dummy = src.parent
	if (!dummy.blood_DNA) // not all attacks leave blood on the parent
		return
	if (!src.haswet)
		src.haswet = TRUE
		src.iswet += 1
	SPAWN(drytime)
		// it could get cleaned while it's drying
		if (!dummy.blood_DNA)
			src.hasdry = FALSE
			src.haswet = FALSE
			src.iswet = 0
			// just in case
			return
		// if the parent is wet, dry it
		if (src.haswet)
			src.hasdry = TRUE
			src.iswet -= 1
		// if there's no more lingering sets of wet blood waiting to dry, dry the parent
		if (!src.iswet)
			src.haswet = FALSE

/// resets the variables
/datum/component/bloodflick/proc/clean()
	src.hasdry = FALSE
	src.haswet = FALSE
	src.iswet = 0
