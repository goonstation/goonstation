/datum/hud/nukewires
	var/atom/movable/screen/hud
		boxes
		close
	var/obj/machinery/nuclearbomb/master


	New(master)
		..()
		src.master = master
		src.boxes = create_screen("boxes", "Wiring Panel", 'icons/mob/screen1.dmi', "block", "6, 6 to 10, 10")
		src.close = create_screen("close", "Close Panel", 'icons/mob/screen1.dmi', "x", "10, 11", HUD_LAYER+1)
		update()

	relay_click(id, mob/user)
		switch (id)
			if ("close")
				user.detach_hud(src)
				user.s_active = null

	clear_master()
		master = null
		..()

	proc/update()
		if (!boxes)
			return
		boxes.screen_loc = "6, 6 to 10, 10"
		if (!close)
			src.close = create_screen("close", "Close Panel", 'icons/mob/screen1.dmi', "x", "10, 11", HUD_LAYER+1)
		close.screen_loc = "11, 10"
