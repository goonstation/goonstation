/datum/area_therapy
	var/area/master
	/// traits which have their own cooldown for this area, which makes makes them twice as useful for therapy
	var/list/trait_exceptions
	var/static/cooldown = 10 SECONDS

	New(var/area/master, var/list/trait_exceptions)
		..()
		src.master = master
		src.trait_exceptions = trait_exceptions

	proc/attach_mob(var/mob/mob)
		RegisterSignal(mob, COMSIG_ATOM_SAY, PROC_REF(try_do_therapy))

	proc/detach_mob(var/mob/mob)
		UnregisterSignal(mob, COMSIG_ATOM_SAY)

	proc/do_therapy()
		for(var/datum/mind/mind in master.population)
			var/mob/mob = mind.current
			if (!mob?.hearing_check(TRUE))
				continue
			mob.try_affect_all_addictions(-1)

	proc/try_do_therapy(var/target, var/datum/say_message/said)
		var/mob/mob = said.original_speaker
		if (!mob || !mob.mind || !(said?.flags & SAYFLAG_SPOKEN_BY_PLAYER))
			return

		var/cooldown_id = "therapy"

		for(var/trait in trait_exceptions)
			if(mob.traitHolder.hasTrait(trait))
				cooldown_id = "therapy_[trait]"
				break

		if (!ON_COOLDOWN(src.master, cooldown_id, cooldown) && (length(master.population) > 0))
			src.do_therapy()





