// some special stuff for flockdrones.
/datum/hud/critter/flock/drone
	hud_icon = 'icons/mob/flock_ui.dmi'

	var/atom/movable/screen/hud/charge_overlay
	var/icon/overlay_mask

	New(M)
		..(M)
		var/atom/movable/screen/releaseButton = create_screen("release", "Eject from Drone", 'icons/mob/flock_ui.dmi', "eject", "SOUTH,EAST", HUD_LAYER+1, tooltipTheme = "flock")
		releaseButton.desc = "Remove yourself from this drone and become intangible."
		var/atom/movable/screen/eggButton = create_screen("spawn", "Generate Egg", 'icons/mob/flock_ui.dmi', "spawn_egg", "SOUTH,WEST", HUD_LAYER+1, tooltipTheme = "flock")
		eggButton.desc = "Lay egg is true! Requires 100 resources."

	relay_click(id, mob/user, list/params)
		var/mob/living/critter/flock/drone/F = master
		if(F)
			if (id == "release")
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
