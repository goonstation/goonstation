//the crown could just use a minute ok
/datum/random_event/menhir/closure
	name = "The Crown Reclusive"
	description = "The entrance to the Crown momentarily vanishes. Can occur once per round."
	message_delay = 1 MINUTE
	announcement_style = EVENT::MENHIR::NOTIFY::NONE

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/obj/machinery/door/unpowered/blue/entrance = locate("menhir_entrance_bluedoor")
			if(entrance && entrance.density) //event hasn't triggered & no entrance has been made
				. = FALSE

	event_effect()
		var/obj/machinery/door/unpowered/blue/entrance = locate("menhir_entrance_bluedoor")
		if (!entrance) //in case of manual call
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find the Crown's entrance door; aborting event.")
			message_admins("Menhir event [src.name] couldn't find the Crown's entrance door; aborting event.")
			return
		var/turf/eventlandmark = get_turf(entrance)
		entrance.locks_on_open = FALSE
		var/delay = rand(2,12)
		SPAWN(delay)
			entrance.close()
			entrance.locked = TRUE
		SPAWN(delay+38)
			entrance.revoke_door()
		SPAWN(rand(2 MINUTES, 3 MINUTES))
			playsound(eventlandmark, 'sound/effects/ring_happi.ogg', 55, 0, extrarange = 24, pitch = 0.3)
			new /obj/machinery/door/unpowered/blue(eventlandmark)

		playsound(eventlandmark, 'sound/effects/ring_happi.ogg', 45, 0, extrarange = 24, pitch = 0.3)

		..()

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [log_loc(eventlandmark)]")
		message_admins("Menhir event [src.name] triggered at [log_loc(eventlandmark)]")
