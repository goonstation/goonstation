ABSTRACT_TYPE(/datum/random_event/respawn)
ABSTRACT_TYPE(/datum/random_event/respawn/player)
ABSTRACT_TYPE(/datum/random_event/respawn/antag)

/datum/random_event/respawn
	///Can this event be given a custom spawn location
	var/targetable = FALSE
	/// The turf to spawn things at
	var/turf/custom_spawn_turf = null

	admin_call(var/source)
		if (src.targetable)
			var/custom_loc = alert("Custom spawn location?","[src.name]","Default","Custom") == "Custom"
			if (custom_loc)
				src.custom_spawn_turf = get_turf(pick_ref(usr))

	cleanup()
		src.custom_spawn_turf = null
