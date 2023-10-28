
// Very split up so that you, too, can give flockminds more hud elements.
/datum/hud/flock_intangible
	var/atom/movable/screen/hud/relay/relayInfo
	var/mob/living/intangible/flock/hudOwner
	var/hud_icon = 'icons/mob/flock_ui.dmi'

	New(M)
		..()
		src.hudOwner = M
		src.create_relay_element()

/datum/hud/flock_intangible/proc/create_relay_element()
	// TODO: early return if relay objective is disabled
	src.relayInfo = create_screen("relay", "Relay Progress", src.hud_icon, "structure-relay", "EAST,NORTH", HUD_LAYER+1, customType=/atom/movable/screen/hud/relay/)
	src.relayInfo.F = src.hudOwner.flock
