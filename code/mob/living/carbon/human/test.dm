/mob/living/carbon/human/tdummy
	real_name = "Target Dummy"
	var/shutup = FALSE
	var/stam_monitor

	New()
		. = ..()
		src.maptext_y = 32
		src.stam_monitor = new /obj/machinery/maptext_monitor/stamina(src)


	say(message, ignore_stamina_winded)
		if(!shutup)
			. = ..()

	disposing()
		qdel(src.stam_monitor)
		. = ..()
