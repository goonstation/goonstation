/datum/antagonist/subordinate/mob/intangible/poltergeist
	id = ROLE_POLTERGEIST
	display_name = "poltergeist"
	mob_path = /mob/living/intangible/wraith/poltergeist
	remove_on_death = TRUE
	has_info_popup = FALSE
	wiki_link = "https://wiki.ss13.co/Wraith#Poltergeists"

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/intangible/wraith/poltergeist/poltergeist_mob = null
		//Find our spookmarker and spawn the mob on it
		var/mob/living/intangible/wraith/W = src.master.current
		if (W.spawn_marker)
			poltergeist_mob = new/mob/living/intangible/wraith/poltergeist(get_turf(W.spawn_marker), src.master.current)
		//We couldnt find a spookmarker somehow, spawn on the wraith instead
		else
			poltergeist_mob = new/mob/living/intangible/wraith/poltergeist(get_turf(src.master.current), src.master.current)
		src.owner.transfer_to(poltergeist_mob)
		qdel(current_mob)

	announce()
		. = ..()
		boutput(src.owner.current, SPAN_ALERT("<b>You have been respawned as a poltergeist!</b>"))
		boutput(src.owner.current, SPAN_ALERT("[src.master.current] is your master! Spread mischief and do [his_or_her(src.master.current)] bidding!"))
		boutput(src.owner.current, SPAN_ALERT("Don't venture too far from your portal or your master!"))
