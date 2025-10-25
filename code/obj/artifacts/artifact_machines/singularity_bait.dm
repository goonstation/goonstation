/obj/machinery/artifact/singularity_bait
	name = "singularity_bait"
	associated_datum = /datum/artifact/singularity_bait

	disposing()
		var/datum/artifact/singularity_bait/artifact = src.artifact
		if(artifact.activated)
			logTheThing(LOG_STATION, null, "[src] deleted the linked singularity at [artifact.linked_singularity.x], [artifact.linked_singularity.y].")
			artifact.kill_singularity()

		. = ..()

	ArtifactActivated()
		//Lets limit this thing to the station Z-plane only.
		if(!inonstationz(src))
			var/turf/T = get_turf(src)
			T.visible_message("<b>[src]</b>'s stubbornly refuses to activate.")
		else
			. = ..()

/datum/artifact/singularity_bait
	associated_object = /obj/machinery/artifact/singularity_bait
	type_size = ARTIFACT_SIZE_LARGE

	type_name = "Singularity Bait"
	rarity_weight = 400
	react_xray = list(5,65,20,11,"ULTRADENSE")
	validtypes = list("ancient", "eldritch", "precursor")
	validtriggers = list(/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch, /datum/artifact_trigger/force, /datum/artifact_trigger/heat, /datum/artifact_trigger/cold, /datum/artifact_trigger/radiation, /datum/artifact_trigger/electric, /datum/artifact_trigger/language)
	activated = 0
	activ_text = "starts pulling something from a great distance away!"
	deact_text = "disappears!"
	var/cooldowns = new/list()
	var/obj/machinery/the_singularity/linked_singularity
	var/target
	var/spawn_direction = NORTH
	var/turf/spawn_location
	var/alert_delay = 60 SECONDS
	var/pull_cooldown = 5 SECONDS
	var/steps_per_pull = 2
	var/clown_seeking_missile = FALSE
	var/obj/effect/grav_pulse/lense

	post_setup()
		. = ..()
		if(artitype.name == "eldritch")
			if(prob(25))
				src.clown_seeking_missile = TRUE
		src.alert_delay = rand(30, 90) SECONDS
		src.pull_cooldown = rand(1, 15) SECONDS
		src.steps_per_pull = rand(1, 3)
		if(length(landmarks[LANDMARK_ARTIFACT_SINGULARITY_SPAWN]) >= 1)
			src.spawn_location = pick(landmarks[LANDMARK_ARTIFACT_SINGULARITY_SPAWN])
			src.spawn_direction = get_dir(locate(round(world.maxx/2, 1), round(world.maxy/2, 1), 1), src.spawn_location)
		else
			src.spawn_direction = pick(ordinal)
			switch(src.spawn_direction) //Determine spawn location in advance rather than on activation just in case.
				if(NORTHEAST)
					src.spawn_location = get_turf(locate(world.maxx-5, world.maxy-5, 1))
				if(NORTHWEST)
					src.spawn_location = get_turf(locate(5, world.maxy-5, 1))
				if(SOUTHEAST)
					src.spawn_location = get_turf(locate(world.maxx-5, 5, 1))
				if(SOUTHWEST)
					src.spawn_location = get_turf(locate(5, 5, 1))
		src.lense = new()

	disposing()
		qdel(src.lense)
		src.lense = null
		. = ..()

	effect_activate(var/obj/O)
		if (..())
			return
		O.vis_contents += src.lense
		var/turf/T = get_turf(O)

		//Create a singularity at the coordinates
		src.linked_singularity = new /obj/machinery/the_singularity(src.spawn_location)
		logTheThing(LOG_STATION, null, "[O] has created a singularity at  [src.spawn_location.x], [src.spawn_location.y].")

		//Determine a target.
		if(src.clown_seeking_missile)
			//Find the station clown and set it as target
			var/db_record = data_core.general.find_record("rank", "Clown")
			if(db_record)
				for_by_tcl(H, /mob/living/carbon/human)
					if(H.name == db_record["name"])
						if(inonstationz(H))
							src.target = H
						break
		if (!src.target && artitype.name == "eldritch")
			//Find a nearby scientist and set it as target
			var/list/valid_targets = list()
			//TODO: Find a way to pick a random person in the same room (area?) as the artifact. Right now it cannot pick a target if it's inside an xray machine.
			for (var/mob/living/carbon/human/H in range(7, T))
				if(H.client)
					valid_targets += H
			if (length(valid_targets) > 0)
				src.target = pick(valid_targets)
		if (!src.target)
			//Otherwise, the artifact is the target.
			src.target = O
		//If the target is human, send them a creepy message.
		if(istype(src.target, /mob/living/carbon/human))
			boutput(src.target, SPAN_ALERT("Something huge is hunting you."))
		//Spawn an alert (that checks if the artifact is still active/exists) that tells the station from which direction the singularity is coming.
		SPAWN(src.alert_delay)
			//If the artifact has been destroyed, don't send the alert.
			if(!src.disposed && !src.linked_singularity.disposed)
				command_alert("Sensors indicate an object of great mass is approaching the station from the [dir2text(src.spawn_direction)]. Stand by for more information.", "Station Threat Detected", alert_origin = ALERT_ANOMALY)
		SPAWN(src.alert_delay + 30 SECONDS)
			if(!src.disposed && !src.linked_singularity.disposed)
				if(istype(src.target, /obj/machinery/artifact/singularity_bait))
					command_alert("The object is being pulled by an artifact of [artitype.name] origin toward itself! Find it and eject it!", "Station Threat Detected", alert_origin = ALERT_ANOMALY)
				else if(istype(src.target, /mob/living/carbon/human))
					var/mob/living/carbon/human/human_target = src.target
					command_alert("The object is being pulled by an artifact of [artitype.name] origin toward [human_target.name]! Find it and eject it!", "Station Threat Detected", alert_origin = ALERT_ANOMALY)

	effect_deactivate(obj/O)
		O.vis_contents -= src.lense
		src.kill_singularity() //For whatever reason this doesn't get called during O.ArtifactDestroyed
		O.ArtifactDestroyed()
		. = ..()

	effect_process(var/obj/O)
		if (..())
			return
		if(!ON_COOLDOWN(src, "pull_singularity", src.pull_cooldown))
			var/turf/T = get_turf(O)
			//Are we still on the station Z-plane? If not, deactivate.
			if(!inonstationz(O))
				O.ArtifactDestroyed()
				return
			//Does the singularity still exist?
			if(src.linked_singularity.disposed)
				O.ArtifactDestroyed()
				return
			//Does the target still exist/live? If not, deactivate.
			if(istype(src.target, /obj/machinery/artifact/singularity_bait))
				if(src.disposed)
					O.ArtifactDestroyed()
					return
			else if(istype(src.target, /mob/living/carbon/human))
				var/mob/living/carbon/human/human_checks = src.target
				if(!isalive(human_checks))
					O.ArtifactDestroyed()
					return
				if(!inonstationz(human_checks))
					O.ArtifactDestroyed()
					return
				//Send them a creepy message.
				boutput(src.target, SPAN_ALERT("It comes closer."))
			//And finally, pull the singularity towards the target.
			for(var/i = 1 to src.steps_per_pull)
				SPAWN(0.3 * i SECONDS)
					step_towards(src.linked_singularity, src.target)
					playsound(O.loc, 'sound/effects/lit.ogg', 50, 1, -1)
					src.lense.pulse()
					T.visible_message("<b>[O]</b> pulses.")

	proc/kill_singularity()
		if(!src.linked_singularity.disposed)
			new /obj/whitehole(src.linked_singularity.loc, 0 SECONDS, 30 SECONDS)
			qdel(src.linked_singularity)
