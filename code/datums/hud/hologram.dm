/datum/hud/silicon/hologram
	var/atom/movable/screen/hud
		pda
		eyecam

	var/mob/living/silicon/hologram/master

	clear_master()
		master = null
		..()

	New(M)
		..()
		master = M

		pda = create_screen("pda", "Cyborg PDA", 'icons/mob/hud_ai.dmi', "pda", "WEST, NORTH+0.5", HUD_LAYER)
		pda.underlays += "button"

		eyecam = create_screen("eyecam", "Eject to eyecam", 'icons/mob/screen1.dmi', "x", "SOUTH,EAST", HUD_LAYER)
		eyecam.underlays += "block"

	relay_click(id)
		if (!master)
			return
		switch (id)
			if ("pda")
				master.access_internal_pda()
			if ("eyecam")
				master.become_eye()
