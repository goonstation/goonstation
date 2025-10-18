/obj/machinery/artifact/singularity_bait
	name = "singularity_bait"
	associated_datum = /datum/artifact/singularity_bait

/datum/artifact/singularity_bait
	associated_object = /obj/machinery/artifact/singularity_bait
	type_size = ARTIFACT_SIZE_LARGE

	type_name = "Singularity Bait"
	rarity_weight = 400
	react_xray = list(5,65,20,11,"ULTRADENSE")
	validtypes = list("ancient", "eldritch", "precursor")
	validtriggers = list(/datum/artifact_trigger/carbon_touch)
	//validtriggers = list(/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch, /datum/artifact_trigger/force, /datum/artifact_trigger/heat, /datum/artifact_trigger/cold, /datum/artifact_trigger/radiation, /datum/artifact_trigger/electric, /datum/artifact_trigger/language)
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
		src.spawn_direction = pick(ordinal)
		if(artitype.name == "eldritch")
			if(prob(25))
				src.clown_seeking_missile = TRUE
		src.alert_delay = rand(30, 90) SECONDS
		src.pull_cooldown = rand(1, 10) SECONDS
		switch(src.spawn_direction)
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
		var/turf/T = get_turf(O)
		//Check if the artifact exists on the station Z plane. If not, refuse to activate.
		if(!isonstationz(O.z))
			T.visible_message("<b>[O]</b>'s stubbornly refuses to activate.") //This probably needs to overwrite ArtifactActivate somewhere.

		//Use a switch to create x and y coordinates
		//var/turf/spawn_location
		//Create a singularity at the coordinates
		T.visible_message("<b>[O]</b> tries to create a singularity at [src.spawn_location.x], [src.spawn_location.y], [src.spawn_location.z]")
		src.linked_singularity = new /obj/machinery/the_singularity(src.spawn_location)
		//var/obj/singularity_object = src.linked_singularity
		//singularity_object.set_loc(spawn_location_x, spawn_location_y)
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
		else
			//Otherwise, the artifact is the target.
			src.target = O
		//If the target is human, send them a creepy message.
		if(istype(src.target, /mob/living/carbon/human))
			boutput(src.target, SPAN_ALERT("Something huge is hunting you."))
		//Create a log entry.
		//Spawn an alert (that checks if the artifact is still active/exists) that tells the station from which direction the singularity is coming.

	effect_deactivate(var/obj/O)
		//Destroy the singularity.
		if(src.linked_singularity)
			qdel(src.linked_singularity)
		//Destroy itself.
		qdel(O)

	effect_process(var/obj/O)
		if (..())
			return
		if(!ON_COOLDOWN(src, "pull_singularity", src.pull_cooldown))
			var/turf/T = get_turf(O)
			//Are we still on the station Z-plane? If not, deactivate.
			if(!isonstationz(O.z))
				T.visible_message("<b>[O]</b> is no longer on the station!")
				O.ArtifactDeactivated()
				return
			//Does the singularity still exist?
			if(!src.linked_singularity)
				T.visible_message("<b>[O]</b> doesn't have a singularity anymore!")
				O.ArtifactDeactivated()
				return
			//Does the target still exist/live? If not, deactivate.
			if(!src.target)
				T.visible_message("<b>[O]</b> no longer has a target!")
				O.ArtifactDeactivated()
				return
			if(istype(src.target, /mob/living/carbon/human))
				var/mob/living/alive_check_mob = src.target
				if(!isalive(alive_check_mob))
					T.visible_message("<b>[O]</b>'s target is no longer alive!")
					O.ArtifactDeactivated()
					return
				if(!isonstationz(alive_check_mob.z))
					T.visible_message("<b>[O]</b>'s target is no longer on the station!")
					O.ArtifactDeactivated()
					return
				//Send them a creepy message.
				boutput(src.target, SPAN_ALERT("It comes closer."))
			//And finally, pull the singularity towards the target.
			step_towards(src.linked_singularity, src.target)
			var/turf/location = get_turf(O)
			location.visible_message("<b>[O]</b> pulses.")

