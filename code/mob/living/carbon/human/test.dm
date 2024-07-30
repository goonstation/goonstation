/mob/living/carbon/human/tdummy
	real_name = "Target Dummy"
	var/shutup = FALSE
	var/stam_monitor

	New()
		. = ..()
		src.stam_monitor = new /obj/machinery/maptext_monitor/stamina(src)
		src.AddComponent(/datum/component/health_maptext)


	say(message, flags, list/message_params, list/atom/atom_listeners_override)
		if(!shutup)
			. = ..()

	disposing()
		qdel(src.stam_monitor)
		src.stam_monitor = null
		. = ..()
