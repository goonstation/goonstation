
// Very split up so that you, too, can give flockminds more hud elements.
/datum/hud/flock_intangible
	var/atom/movable/screen/hud/relay/relayInfo

	New(M)
		..()
		if (istype(M, /mob/living/intangible/flock/))
			var/mob/living/intangible/flock/F = M
			if (F.flock.relay_allowed)
				src.create_relay_element()

/datum/hud/flock_intangible/proc/create_relay_element()
	create_screen("relayBack", "", 'icons/mob/flock_ui.dmi', "template-full", "EAST,NORTH", HUD_LAYER)
	src.relayInfo = create_screen("relay", "Relay Progress", 'icons/mob/flock_ui.dmi', "structure-relay", "EAST,NORTH", HUD_LAYER_1, customType=/atom/movable/screen/hud/relay/)
