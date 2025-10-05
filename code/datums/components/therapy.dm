TYPEINFO(/datum/component/area_therapy)
		initialization_args = list(
		ARG_INFO("specialist_traits", DATA_INPUT_NUM, "A list of trait ids which have their own cooldown for this area", null),
		ARG_INFO("trait_exclusions", DATA_INPUT_NUM, "A list of taits ids which prevent a mob being affected by therapy in this area", null)
	)

/datum/component/area_therapy
	var/area/master
	/// traits which have their own cooldown for this area, which makes makes them twice as useful for therapy
	var/list/specialist_traits
	/// Taits which prevent a mob being affected by therapy in this area, although they can still grant it to others
	var/list/trait_exclusions
	/// The value each mob's addictions are changed by
	var/static/addiction_increment = -0.8
	var/static/cooldown = 10 SECONDS

	Initialize(var/list/specialist_traits,var/list/trait_exclusions)
		if (!isarea(src.parent))
			return COMPONENT_INCOMPATIBLE

		. = ..()
		src.master = src.parent
		src.specialist_traits = specialist_traits
		src.trait_exclusions = trait_exclusions
		RegisterSignal(src.parent, COMSIG_MOB_ENTERED_AREA, PROC_REF(attach_mob))
		RegisterSignal(src.parent, COMSIG_MOB_EXITED_AREA, PROC_REF(detach_mob))

	proc/attach_mob(var/area, var/mob/mob)
		RegisterSignal(mob, COMSIG_ATOM_SAY, PROC_REF(try_do_therapy))
		if (!mob?.traitHolder?.hasTraitInList(trait_exclusions))
			mob.setStatus("therapy_zone", INFINITE_STATUS)

	proc/detach_mob(var/area, var/mob/mob)
		UnregisterSignal(mob, COMSIG_ATOM_SAY)
		mob.delStatus("therapy_zone")

	proc/do_therapy()
		for(var/datum/mind/mind in src.master.population)
			var/mob/mob = mind.current
			if (!mob?.hearing_check(TRUE) || mob.traitHolder.hasTraitInList(trait_exclusions))
				continue
			mob.try_affect_all_addictions(addiction_increment)

	proc/try_do_therapy(var/target, var/datum/say_message/said)
		var/mob/mob = said?.original_speaker
		if (!mob || !mob.mind || !(said.flags & SAYFLAG_SPOKEN_BY_PLAYER))
			return

		var/cooldown_id = mob.traitHolder.hasTraitInList(specialist_traits)
		if (cooldown_id)
			cooldown_id = "therapy_[cooldown_id]"
		else
			cooldown_id = "therapy_pleb"

		if (!ON_COOLDOWN(src.master, cooldown_id, cooldown) && (length(src.master.population) > 1))
			src.do_therapy()

	UnregisterFromParent()
		UnregisterSignal(src.parent, COMSIG_MOB_ENTERED_AREA)
		UnregisterSignal(src.parent, COMSIG_MOB_EXITED_AREA)
		// TODO unregister from mobs in the area. How do? I don't know that areas hold a list of all their own turfs, let alone the non-player
		// mobs in that area. Yet we have to register all mobs for therapy in case of mindswaps



