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

	effect_activate(var/obj/O)
		if (..())
			return
		//Check if the artifact exists on the station Z plane. If not, refuse to activate.
		//Use a switch to create x and y coordinates
		//Create a singularity at the coordinates
		if(artitype.name == "eldritch")
			if(src.clown_seeking_missile)
				//Find a clown and set it as target
			else
				//Find a nearby scientist and set it as target
			//Send them a creepy message about being hunted.
			//Create a log entry.
		else
			//Otherwise, the artifact is the target.
			src.target = O
			//Create a log entry.
		//Spawn an alert (that checks if the artifact is still active/exists) that tells the station from which direction the singularity is coming.

	effect_deactivate(var/obj/O)
		//Destroy the singularity.
		//Destroy itself.

	effect_process(var/obj/O)
		if (..())
			return
		if(!ON_COOLDOWN(src, "pull_singularity", src.pull_cooldown))
			//Are we still on the station Z-plane? If not, deactivate.
			//Does the target still exist/live? If not, deactivate.
			//Is this an eldritch artifact? If so, send the target a creepy message about it coming closer.
			//Then determine the direction of the target from the linked singularity.
			//And finally, pull the singularity towards the target.
			step_towards(src.linked_singularity, src.target)
			var/turf/location = get_turf(O)
			location.visible_message("<b>[O]</b> pulses.")

