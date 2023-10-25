// some special stuff for flockdrones.
/datum/hud/critter/flock/drone
	hud_icon = 'icons/mob/flock_ui.dmi'

	var/atom/movable/screen/hud/relay/relayInfo
	var/atom/movable/screen/hud/charge_overlay
	var/icon/overlay_mask

	New(M)
		..(M)
		var/atom/movable/screen/releaseButton = create_screen("release", "Eject from Drone", 'icons/mob/flock_ui.dmi', "eject", "SOUTH,EAST", HUD_LAYER+1, tooltipTheme = "flock")
		releaseButton.desc = "Remove yourself from this drone and become intangible."
		var/atom/movable/screen/eggButton = create_screen("spawn", "Generate Egg", 'icons/mob/flock_ui.dmi', "spawn_egg", "CENTER-3,SOUTH", HUD_LAYER+1, tooltipTheme = "flock")
		eggButton.desc = "Lay egg is true! Starts at [FLOCK_LAY_EGG_COST] and scales with number of drones."
		src.create_relay_element()

	relay_click(id, mob/user, list/params)
		var/mob/living/critter/flock/drone/F = master
		if(F)
			if (id == "release")
				if (!F.flock) //we are a lone drone!
					boutput(user, "<span class='alert'>You have no flock to return to.")
					return
				if (!F.flock.flockmind?.tutorial || F.flock.flockmind.tutorial.PerformAction(FLOCK_ACTION_DRONE_RELEASE))
					F.release_control()
			else if(id == "spawn")
				F.create_egg()
			else
				..(id, user, params)

/datum/hud/critter/flock/drone/create_hand_element()
	..()
	var/datum/handHolder/HH = src.hands[3]
	src.charge_overlay = src.create_screen("stunner_charge", "Stunner charge", 'icons/mob/flock_ui.dmi', "charge_overlay", HH.screenObj.screen_loc, HUD_LAYER + 2)
	src.overlay_mask = new('icons/mob/flock_ui.dmi', "darkener")
	src.charge_overlay.add_filter("mask", 1, alpha_mask_filter(0, 0, src.overlay_mask))

///Charge is given as a ratio from 0 to 1
/datum/hud/critter/flock/drone/proc/set_stunner_charge(var/charge)
	src.charge_overlay.transition_filter("mask", 0.5 SECONDS, list("y" = -24 * (1 - charge)), SINE_EASING, FALSE)

/datum/hud/critter/flock/drone/proc/create_relay_element()
	// TODO: early return if relay objective is disabled
	src.relayInfo = src.create_screen("relay", "Relay Race", src.hud_icon, "structure-relay", "EAST-1,NORTH", HUD_LAYER+1, customType=/atom/movable/screen/hud/relay/)

// TODO: Make this not shitcode
/datum/hud/critter/flock/drone/create_screen(id, name, icon, state, loc, layer = HUD_LAYER, dir = SOUTH, tooltipTheme = null, desc = null, customType = null, mouse_opacity = 1)
	if(QDELETED(src))
		CRASH("Tried to create a screen (id '[id]', name '[name]') on a deleted datum/hud")
	var/atom/movable/screen/hud/relay/S = new(src.master)

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

