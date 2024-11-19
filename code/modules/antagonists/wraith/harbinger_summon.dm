/datum/antagonist/subordinate/mob/intangible/harbinger_summon
	id = ROLE_HARBINGER_SUMMON
	display_name = "harbinger summon"
	mob_path = /mob/living/critter/wraith/nascent
	remove_on_clone = TRUE
	has_info_popup = FALSE

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/critter/wraith/nascent/summon_mob = null
		//Find our spookmarker and spawn the mob on it
		var/mob/living/intangible/wraith/W = src.master.current
		if (W.spawn_marker)
			summon_mob = new/mob/living/critter/wraith/nascent(get_turf(W.spawn_marker), src.master.current)
		//We couldnt find a spookmarker somehow, spawn on the wraith instead
		else
			summon_mob = new/mob/living/critter/wraith/nascent(get_turf(src.master.current), src.master.current)
		src.owner.transfer_to(summon_mob)
		qdel(current_mob)

	announce()
		. = ..()
		boutput(src.owner.current, SPAN_ALERT("<b>You have been respawned as a harbinger summon!</b>"))
		boutput(src.owner.current, SPAN_ALERT("[src.master.current] is your master! Use your abilities to choose a path! Work with your master to spread chaos!"))
