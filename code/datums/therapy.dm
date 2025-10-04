/datum/area_therapy
	var/area/master
	/// traits which have their own cooldown for this area, which makes makes them twice as useful for therapy
	var/list/specialist_traits
	/// Taits which prevent a mob being affected by therapy in this area, although they can still grant it to others
	var/list/trait_exclusions
	/// The value each mob's addictions are changed by
	var/static/addiction_increment = -0.8
	var/static/cooldown = 10 SECONDS


	New(var/area/master, var/list/specialist_traits,var/list/trait_exclusions)
		..()
		src.master = master
		src.specialist_traits = specialist_traits
		src.trait_exclusions = trait_exclusions

	proc/attach_mob(var/mob/mob)
		RegisterSignal(mob, COMSIG_ATOM_SAY, PROC_REF(try_do_therapy))

	proc/detach_mob(var/mob/mob)
		UnregisterSignal(mob, COMSIG_ATOM_SAY)

	proc/do_therapy()
		for(var/datum/mind/mind in master.population)
			var/mob/mob = mind.current
			if (!mob?.hearing_check(TRUE) || mob.traitHolder.hasTraitInList(trait_exclusions))
				continue
			mob.try_affect_all_addictions(addiction_increment)

	proc/try_do_therapy(var/target, var/datum/say_message/said)
		var/mob/mob = said.original_speaker
		if (!mob || !mob.mind || !(said?.flags & SAYFLAG_SPOKEN_BY_PLAYER))
			return

		var/cooldown_id = mob.traitHolder.hasTraitInList(specialist_traits)
		if (cooldown_id)
			cooldown_id = "therapy_[cooldown_id]"
		else
			cooldown_id = "therapy_pleb"

		if (!ON_COOLDOWN(src.master, cooldown_id, cooldown) && (length(master.population) > 1))
			src.do_therapy()





