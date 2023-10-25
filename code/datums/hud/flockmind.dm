
// Very split up so that you, too, can give flockminds more hud elements.
/datum/hud/flockmind
	var/atom/movable/screen/hud/relay/relayInfo
	var/mob/living/intangible/flock/hudOwner
	var/hud_icon = 'icons/mob/flock_ui.dmi'

	New(M)
		..()
		src.hudOwner = M
		src.create_relay_element()

/datum/hud/flockmind/proc/create_relay_element()
	// TODO: early return if relay objective is disabled
	src.relayInfo = src.create_screen("relay", "Relay Race", src.hud_icon, "structure-relay", "EAST,NORTH", HUD_LAYER+1, customType=/atom/movable/screen/hud/relay/)

// TODO: Make this not shitcode
/datum/hud/flockmind/create_screen(id, name, icon, state, loc, layer = HUD_LAYER, dir = SOUTH, tooltipTheme = null, desc = null, customType = null, mouse_opacity = 1)
	if(QDELETED(src))
		CRASH("Tried to create a screen (id '[id]', name '[name]') on a deleted datum/hud")
	var/atom/movable/screen/hud/relay/S = new(src.hudOwner)

	S.id = id
	S.master = src
	S.icon = icon
	S.icon_state = state
	S.screen_loc = loc
	S.layer = layer
	S.set_dir(dir)
	S.tooltipTheme = tooltipTheme
	S.mouse_opacity = mouse_opacity
	src.objects += S

	for (var/client/C in src.clients)
		C.screen += S
	return S

