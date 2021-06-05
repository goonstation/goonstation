// some special stuff for flockdrones.
/datum/hud/critter/flock/drone
	hud_icon = 'icons/mob/flock_ui.dmi'

	New(M)
		..(M)
		var/atom/movable/screen/releaseButton = create_screen("release", "Eject from Drone", 'icons/mob/flock_ui.dmi', "eject", "NORTH,WEST", HUD_LAYER+1, tooltipTheme = "flock")
		releaseButton.desc = "Remove yourself from this drone and become intangible."
		var/atom/movable/screen/eggButton = create_screen("spawn", "Generate Egg", 'icons/mob/flock_ui.dmi', "spawn_egg", "SOUTH,EAST", HUD_LAYER+1, tooltipTheme = "flock")
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
