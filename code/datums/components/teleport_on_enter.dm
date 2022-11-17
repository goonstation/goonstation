/datum/component/teleport_on_enter
	var/atom/destination
	var/noisy

TYPEINFO(/datum/component/teleport_on_enter)
	initialization_args = list(
		ARG_INFO("destination", DATA_INPUT_REFPICKER, "Atom that this will teleport people to. IF YOU USE A NON-TURF, PEOPLE MAY BE STUCK INSIDE THE THING", null),
		ARG_INFO("noisy", DATA_INPUT_BOOL, "Should this make a zappy teleport noise when it teleports someone?", TRUE)
	)

/datum/component/teleport_on_enter/Initialize(var/destination, var/noisy = TRUE)
	if (!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE
	if (!destination)
		return COMPONENT_INCOMPATIBLE
	src.destination = destination
	src.noisy = noisy
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/teleport)
	RegisterSignal(destination, COMSIG_PARENT_PRE_DISPOSING, .proc/UnregisterFromParent)


/datum/component/teleport_on_enter/proc/teleport(var/teleporter, var/atom/movable/teleportee)
	return_if_overlay_or_effect(teleportee)
	if (teleportee.invisibility >= INVIS_ALWAYS_ISH || teleportee:anchored) //minor safety. this is currently intended for admin usage, so intangible things can still tele
		return
	if (src.noisy)
		playsound(get_turf(parent), "warp", 50, 1, 0.2, 1.2)

	teleportee.set_loc(src.destination)

/datum/component/teleport_on_enter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	UnregisterSignal(destination, COMSIG_PARENT_PRE_DISPOSING)

