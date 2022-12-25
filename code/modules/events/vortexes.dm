/datum/random_event/major/summonvortexes
	name = "Spawn some spooky vortexes"
	customization_available = 1
	var/derelictchoice = null
#ifdef RP_MODE
	required_elapsed_round_time = 60 MINUTES
#else
	required_elapsed_round_time = 45 MINUTES
#endif

	admin_call(var/source)
		if (..())
			return

		var/derelictchoice = alert(usr, "Use alternate void critter spawns spawns?","Enable Derelict Mode", "Yes","No")
		if (derelictchoice == "Yes")
			derelict_mode = 1
		if (derelictchoice == "No")
			derelict_mode = 0

		src.event_effect(source)
		return

	event_effect(var/source)
		..()

		playsound_global(world, 'sound/machines/engine_alert2.ogg', 40)
		var/sensortext = pick("sensors", "technicians", "probes", "satellites", "monitors", "best chaplains", "worst chaplains", "anomaly detectors", "interns", "void specialists", "best group of staff assistants", "worst group of staff assistants")
		var/pickuptext = pick("picked up", "detected", "found", "sighted", "reported", "accidentally summoned", "purposely summoned", "noticed", "noticed after a night of drinking")
		var/anomlytext = pick("vortex of doom", "spatial disturbance","evil anomaly", "doom portal", "summoning of pain", "really weird portal", "group of dangerous looking portals")
		var/ohshittext = pick("en route for collision with", "rapidly approaching", "heading towards", "gently meandering towards", "headed straight for", "kinda headed in the direction of")
		command_alert("Our [sensortext] have [pickuptext] \a [anomlytext] and it's [ohshittext] the station. You have approximately 60 seconds until it arrives.", "Anomaly Alert", alert_origin = ALERT_ANOMALY)

	event_effect(var/source)
		..()
		var/turf/vortexpick = null

		SPAWN(60 SECONDS)
			for(var/i in 1 to length(random_floor_turfs))
				vortexpick = pick(random_floor_turfs)
				var/obj/vortex/V = new /obj/vortex
				V.set_loc(vortexpick)
				SPAWN(rand(18 SECONDS, 32 SECONDS))
					qdel(V)
				if (rand(1,1000) == 1)
					Artifact_Spawn(vortexpick)
				sleep(rand(1, 15))

		message_admins("<span class='internal'>Spawning some vortexes. Source: [source ? "[source]" : "random"]</span>")
		logTheThing(LOG_ADMIN, null, "Spawning some vortexes. Source: [source ? "[source]" : "random"]")
