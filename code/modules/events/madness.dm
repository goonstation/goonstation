//Lovingly Adapted from sleeper agent code
/datum/random_event/major/antag/madness
	name = "Mass Madness"
	centcom_headline = "Abzu Sonar Array Warning"
	centcom_message = ""
	var/num_victims = 0

	admin_call(source)
		. = ..()
		src.num_victims = input(usr, "How many minds to break?", src.name, 0) as num|null
		if (isnull(src.num_victims))
			return
		else if (src.num_victims < 1)
			return
		else
			src.num_victims = round(src.num_victims)
		src.event_effect(source)

	event_effect(source)
		. = ..()
		//TODO: big spooky shapes overhead
		for (var/mob/M in mobs)
			shake_camera(M, 2 SECONDS, 20)
			if (isnpcmonkey(M))
				SPAWN(rand(1, 4) SECONDS)
					M.emote("scream")
		var/list/potential_victims = list()
		for (var/mob/living/carbon/human/H in global.mobs)
			if (H.client && !H.mind?.is_antagonist() && !isVRghost(H) && H.client.preferences.be_misc && isalive(H)) //using "misc" prefs for now
				potential_victims += H
		if (src.num_victims <= 0)
			if (length(potential_victims) <= 10) //some concession for not making everything completely insane on lowpop
				src.num_victims = rand(2, 3)
			else
				src.num_victims = rand(3, 6)
		src.num_victims = min(src.num_victims, length(potential_victims))
		//frick u static
		/datum/antagonist/broken::shared_objective_text = null
		for (var/i in 1 to src.num_victims)
			var/mob/living/carbon/human/victim = pick(potential_victims)
			victim.mind.add_antagonist(ROLE_BROKEN)
			potential_victims -= victim

	cleanup()
		src.num_victims = 0
