//an intolerable imbalance has developed within. it must be purged.
/datum/random_event/menhir/radwave
	name = "A Tide Which Scours"
	description = "After a brief delay, expanding waves of radiation emanate from the Crown, pushing crew to the edges of the station."
	message_delay = 5 SECONDS
	weight = 10
	announcement_style = EVENT::MENHIR::NOTIFY::GLOBAL
	centcom_headline = "ARTIFACT CONDITION ALERT"
	centcom_message = "VACATE SITE IMMEDIATELY. IONISING RADIATION BUILDUP IN CASING OF TOREADOR-7I-22408. IF UNABLE TO VACATE SITE, MOVE WITHIN TOREADOR-7I-22408 OR AS FAR FROM IT AS POSSIBLE."
	required_elapsed_round_time = 22 MINUTES

	event_effect()
		message_delay = rand(2 SECONDS, 3 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.45)
			SPAWN(message_delay + 12)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.45)
			SPAWN(message_delay + 24)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.45)
			SPAWN(message_delay + 72)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.45)
			SPAWN(message_delay + 84)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.45)
			SPAWN(message_delay + 96)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.45)

		logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered.")
		message_admins("Menhir event [src.name] triggered.")
		src.weight = 1 //should have the agitation worked out by now... usually.

		var/turf/focal_nexus = locate(EVENT::MENHIR::CORE_X, EVENT::MENHIR::CORE_Y, Z_LEVEL_STATION)
		///Key is turf; value is whether it is shielded
		var/list/burst_turfs = list()
		///Maximum radius pulses stretch to
		var/extent_radius = 62
		///Range at which pulses are strongest
		var/radpeak = 50

		SPAWN(1)
			for(var/i in 1 to 9) //windup
				playsound(focal_nexus, 'sound/items/med_scanner.ogg', i*8, 0, pitch = 0.55, extrarange = 48)
				sleep(12)
			for(var/i in 1 to extent_radius)
				playsound(focal_nexus, 'sound/items/med_scanner.ogg', 90, 0, pitch = 0.55, extrarange = i)
				burst_turfs += rangefind_diamond(focal_nexus,i)
				var/fadetime = 25
				if(i == extent_radius) fadetime = 40 //special finishing flash
				var/volmod = ceil(i * 0.4)
				var/radmod = (1 + radpeak - abs(i-radpeak)) CENTI SIEVERTS //.15 when it first breaches the crown, peaks at .51 late in the wave, comes down to .39 at end
				SPAWN(1)
					for (var/turf/T in burst_turfs)
						irradiate_turf(T,radmod,fadetime,burst_turfs[T])
					playsound_global(Z_LEVEL_STATION, 'sound/weapons/ACgun2.ogg', volmod+3, 0)
				LAGCHECK(LAG_LOW)
				sleep(12)

	///Fetch a "ring" of turfs in a diamond based on target radius, and index their rad-safety
	proc/rangefind_diamond(var/turf/T, var/radius = 1)
		. = list()
		var/turf/seekspot = null
		for(var/i = -radius, i <= radius, i++)
			var/bandwidth = radius - abs(i) //example: you're radius 3. this is 0 at Y-peaks, and 3 at Y-center. diamond!
			if(bandwidth)
				seekspot = locate(T.x - bandwidth, T.y + i, T.z)
				if(istype(seekspot.loc,/area/station/crown))
					.[seekspot] = TRUE
				else
					.[seekspot] = FALSE

				seekspot = locate(T.x + bandwidth, T.y + i, T.z)
				if(istype(seekspot.loc,/area/station/crown))
					.[seekspot] = TRUE
				else
					.[seekspot] = FALSE
			else
				seekspot = locate(T.x, T.y + i, T.z)
				if(istype(seekspot.loc,/area/station/crown))
					.[seekspot] = TRUE
				else
					.[seekspot] = FALSE
		return

	proc/irradiate_turf(var/turf/T,var/rad_strength = 1,var/fadetime = 11,var/shielded = FALSE)
		if (!isturf(T))
			return

		//does not use flash-fill animate to avoid double anim calls
		var/color_old = T.color
		if(shielded)
			T.color = "#eeff00"
		else
			//spatial interdictor: nullify radiation pulses. good luck
			//consumes 100 units of charge (50,000 joules) per tile protected
			for_by_tcl(IX, /obj/machinery/interdictor)
				if (IX.expend_interdict(100,T,1))
					animate_flash_color_fill_inherit(T,"#FFDD00",1,5)
					return
			T.color = "#90ff00"
		animate(T, color = color_old, time = fadetime, easing = LINEAR_EASING)
		if(!shielded)
			for (var/mob/M in T.contents)
				logTheThing(LOG_STATION, M, "is hit by a radiation burst at [log_loc(M)].")
				M.take_radiation_dose(rad_strength)
