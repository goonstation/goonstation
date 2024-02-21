ABSTRACT_TYPE(/datum/antagonist/mob)
/datum/antagonist/mob
	var/mob_path = /mob/living

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/intangible/new_mob = new mob_path(get_turf(current_mob))
		src.owner.transfer_to(new_mob)
		qdel(current_mob)

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)


ABSTRACT_TYPE(/datum/antagonist/subordinate/mob)
/datum/antagonist/subordinate/mob
	var/mob_path = /mob/living

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/intangible/new_mob = new mob_path(get_turf(current_mob))
		src.owner.transfer_to(new_mob)
		qdel(current_mob)

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)
