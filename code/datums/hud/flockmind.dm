
// Very split up so that you, too, can give flockminds more hud elements.
/datum/hud/flockmind
	var/atom/movable/screen/hud/relay/relayInfo = null
	var/mob/living/intangible/flock/hudOwner

	New(M)
		..()
		src.hudOwner = M
		src.create_relay_element()

	proc/create_relay_element()
		src.relayInfo = new()

