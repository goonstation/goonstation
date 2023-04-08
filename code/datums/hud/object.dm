/datum/hud/object
	var/mob/living/object/master
	var/atom/movable/screen/intent

	New(M)
		..()
		master = M
		var/atom/movable/screen/S = create_screen("release", "release", 'icons/mob/screen1.dmi', "x", "NORTH,EAST", HUD_LAYER)
		S.underlays += "block"
		intent = create_screen("intent", "action intent", 'icons/mob/hud_human.dmi', "intent-help", "SOUTH,EAST-2", HUD_LAYER)

	clear_master()
		master = null
		..()

	relay_click(id, mob/user, list/params)
		if (id == "release")
			if (master)
				master.death(FALSE)

