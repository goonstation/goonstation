/datum/antagonist/subordinate/mob/intangible/poltergeist
	id = ROLE_POLTERGEIST
	display_name = "poltergeist"
	mob_path = /mob/living/intangible/wraith/poltergeist
	remove_on_death = TRUE

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
		boutput(src.owner.current, "<span class='alert'><b>You have been respawned as a poltergeist!</b></span>")
		boutput(src.owner.current, "<span class='alert'>[src.master.current] is your master! Spread mischeif and do their bidding!</span>")
		boutput(src.owner.current, "<span class='alert'>Don't venture too far from your portal or your master!</span>")
