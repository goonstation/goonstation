/obj/machinery/artifact/singularity_bait
	name = "singularity_bait"
	associated_datum = /datum/artifact/singularity_bait

	disposing()
		var/datum/artifact/singularity_bait/artifact = src.artifact
		var/obj/machinery/the_singularity/singularity
		new /obj/whitehole(singularity.loc, 0 SECONDS, 30 SECONDS)
		logTheThing(LOG_STATION, null, "[src] has deleted the linked singularity at [singularity.x], [singularity.y] due to being disposed.")
		qdel(artifact.linked_singularity)
		. = ..()

	ArtifactActivated()
		//Lets limit this thing to the station Z-plane only.
		if(!isonstationz(src.z))
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
	deact_text = "crumbles into dust!"
	examine_hint = "It looks vaguely foreboding."
	var/cooldowns = new/list()
	var/linked_singularity
	var/target
	var/spawn_direction
	var/turf/spawn_location
	var/alert_delay = 60 SECONDS
	var/pull_cooldown = 5 SECONDS
	var/clown_seeking_missile = FALSE

	post_setup()
		. = ..()

		if(artitype.name == "eldritch")
			if(prob(25))
				src.clown_seeking_missile = TRUE
		src.alert_delay = rand(30, 90) SECONDS
		src.pull_cooldown = rand(5, 50) DECI SECONDS // 0.5 to 5 seconds
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

	effect_activate(var/obj/O)
		if (..())
			return

		//Create a singularity at the coordinates
		src.linked_singularity = new /obj/machinery/the_singularity(src.spawn_location)
		logTheThing(LOG_STATION, null, "[O] has created a singularity at  [src.spawn_location.x], [src.spawn_location.y].")

		if(src.clown_seeking_missile)
			//Find the station clown and set it as target
			var/db_record = data_core.general.find_record("rank", "Clown")
			if(db_record)
				for_by_tcl(H, /mob/living/carbon/human)
					if(H.name == db_record["name"])
						if(isonstationz(H))
							src.target = H
							break
						else
							break
		else if (!src.target && artitype.name == "eldritch")
			//Find a nearby scientist and set it as target
			var/list/valid_targets = list()
			for (var/mob/living/carbon/human/H in view(3, O))
				valid_targets += H
			if (length(valid_targets) > 0)
				src.target = pick(valid_targets)
		else if (!src.target)
			//Otherwise, the artifact is the target.
			src.target = O
		//If the target is human, send them a creepy message.
		if(istype(src.target, /mob/living/carbon/human))
			boutput(src.target, SPAN_ALERT("Something huge is hunting you."))
		//Spawn an alert (that checks if the artifact is still active/exists) that tells the station from which direction the singularity is coming.
		SPAWN(src.alert_delay)
			//If the artifact has been destroyed, don't send the alert.
			if(O && src.linked_singularity)
				command_alert("Sensors indicate an object of great mass is being pulled towards the station from the [src.spawn_direction] by an artifact of [artitype.name] origin. The crew should eject any recently activated artifacts.", "Station Threat Detected", alert_origin = ALERT_ANOMALY)

	effect_deactivate(var/obj/O)
		//This artifact is one time use.
		O.ArtifactDestroyed()

	effect_process(var/obj/O)
		if (..())
			return
		if(!ON_COOLDOWN(src, "pull_singularity", src.pull_cooldown))
			var/turf/T = get_turf(O)
			//Are we still on the station Z-plane? If not, deactivate.
			if(!isonstationz(O.z))
				O.ArtifactDeactivated()
				return
			//Does the singularity still exist?
			if(!src.linked_singularity)
				O.ArtifactDeactivated()
				return
			//Does the target still exist/live? If not, deactivate.
			if(!src.target)
				O.ArtifactDeactivated()
				return
			if(istype(src.target, /mob/living/carbon/human))
				var/mob/living/alive_check_mob = src.target
				if(!isalive(alive_check_mob))
					O.ArtifactDeactivated()
					return
				if(!isonstationz(alive_check_mob.z))
					O.ArtifactDeactivated()
					return
				//Send them a creepy message.
				boutput(src.target, SPAN_ALERT("It comes closer."))
			//And finally, pull the singularity towards the target.
			step_towards(src.linked_singularity, src.target)
			T.visible_message("<b>[O]</b> pulses.")
