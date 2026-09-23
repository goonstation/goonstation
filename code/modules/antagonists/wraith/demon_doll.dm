/datum/antagonist/subordinate/mob/demon_doll
	id = ROLE_DEMON_DOLL
	display_name = "demon doll"
	antagonist_icon = "wraithsummon"
	mob_path = /mob/living/critter/wraith/demon_doll
	wiki_link = "https://wiki.ss13.co/Wraith#Path_2:_The_Trickster"

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/critter/wraith/demon_doll/demon_doll_mob = null
		//Find our spookmarker and spawn the mob on it
		var/mob/living/intangible/wraith/W = src.master.current
		if (W.spawn_marker)
			demon_doll_mob = new/mob/living/critter/wraith/demon_doll/(get_turf(W.spawn_marker), src.master.current)
		//We couldnt find a spookmarker somehow, spawn on the wraith instead
		else
			demon_doll_mob = new/mob/living/critter/wraith/demon_doll/(get_turf(src.master.current), src.master.current)
		src.owner.transfer_to(demon_doll_mob)
		qdel(current_mob)

	announce()
		. = ..()
		boutput(src.owner.current, SPAN_ALERT("<b>You have been respawned as a demon!</b>"))
		boutput(src.owner.current, SPAN_ALERT("[src.master.current] is your master! Use your abilities to destroy lights and spread chaos!"))
