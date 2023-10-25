/datum/antagonist/subordinate/mob/plague_rat
	id = ROLE_PLAGUE_RAT
	display_name = "plague rat"
	mob_path = /mob/living/critter/wraith/plaguerat/young

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/critter/wraith/plaguerat/young/plague_rat_mob = null
		//Find our spookmarker and spawn the mob on it
		var/mob/living/intangible/wraith/W = src.master.current
		if (W.spawn_marker)
			plague_rat_mob = new/mob/living/critter/wraith/plaguerat/young/(get_turf(W.spawn_marker), src.master.current)
		//We couldnt find a spookmarker somehow, spawn on the wraith instead
		else
			plague_rat_mob = new/mob/living/critter/wraith/plaguerat/young/(get_turf(src.master.current), src.master.current)
		src.owner.transfer_to(plague_rat_mob)
		qdel(current_mob)

	announce()
		. = ..()
		boutput(src.owner.current, "<span class='alert'><b>You have been respawned as a plague rat!</b></span>")
		boutput(src.owner.current, "<span class='alert'>[src.master.current] is your master! Use your abilities to spread disease and consume rot! Work with your master to turn the station into a rat den!</span>")
