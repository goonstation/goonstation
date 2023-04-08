/datum/antagonist/macho_man
	id = ROLE_MACHO_MAN
	display_name = "macho man"

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/carbon/human/machoman/macho_man = new/mob/living/carbon/human/machoman(get_turf(current_mob), src.pseudo)
		src.owner.transfer_to(macho_man)
		qdel(current_mob)

		if (src.pseudo)
			src.display_name = "faustian macho man"
			src.owner.current.real_name = "[pick("Faustian", "Fony", "Fake", "False","Fraudulent", "Fragile")] [src.owner.current.real_name]"
			src.owner.current.name = src.owner.current.real_name
			src.owner.current.traitHolder.addTrait("deathwish")
			src.owner.current.traitHolder.addTrait("glasscannon")
			boutput(src.owner.current, "<span class='notice'>You weren't able to absorb all the macho waves you were bombarded with! You have been left an incomplete macho man, with a frail body, and only one macho power. However, you inflict double damage with most melee weapons. Use your newfound form wisely to prove your worth as a macho champion of justice. Do not kill innocent crewmembers.</span>")

		else
			src.owner.current.assign_gimmick_skull()

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)

		src.owner.current.traitHolder.removeTrait("deathwish")
		src.owner.current.traitHolder.removeTrait("glasscannon")

		SPAWN(2.5 SECONDS)
			src.owner.current.assign_gimmick_skull()

	relocate()
		var/turf/T = get_turf(src.owner.current)
		if (!(T && isturf(T)) || (T.z != Z_LEVEL_STATION))
			var/spawn_loc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, Z_LEVEL_STATION))
			if (spawn_loc)
				src.owner.current.set_loc(spawn_loc)
			else
				src.owner.current.z = Z_LEVEL_STATION
		else
			src.owner.current.set_loc(T)
