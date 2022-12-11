/datum/hud/hologram
	var/atom/movable/screen/hud
		eyecam

	var/mob/living/silicon/hologram/master

	New(M)
		..()
		master = M

		eyecam = create_screen("eyecam", "Eject to eyecam", 'icons/mob/screen1.dmi', "x", "SOUTH,EAST", HUD_LAYER)
		eyecam.underlays += "block"

	clear_master()
		master = null
		..()

	relay_click(id)
		if (!master)
			return

		if (id == "eyecam")
			master.become_eye()
