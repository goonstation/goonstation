TYPEINFO(/datum/component/area_therapy)
		initialization_args = list(
		ARG_INFO("specialist_traits", DATA_INPUT_LIST_VAR, "A list of trait ids which have their own cooldown for this area", null),
		ARG_INFO("trait_exclusions", DATA_INPUT_LIST_VAR, "A list of traits ids which prevent a mob being affected by therapy in this area", null)
	)

/datum/component/area_therapy
	var/area/master
	/// Traits which have their own cooldown for this area, which makes makes them twice as useful for therapy
	var/list/specialist_traits
	/// Traits which prevent a mob being affected by therapy in this area, although they can still grant it to others
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
		RegisterSignal(src.parent, COMSIG_AREA_ENTERED_BY_MOB, PROC_REF(attach_mob))
		RegisterSignal(src.parent, COMSIG_AREA_EXITED_BY_MOB, PROC_REF(detach_mob))

	proc/attach_mob(var/area, var/mob/mob)
		// Not going to have any additional exceptions for player critters or wraiths etc, because it's a slow system and as long as another player
		// is being encouraged to hang out with you, rubber ducking your problems with a sentient cockroach or the shade of Amhunatep XI seems fine.
		// The area's Entered() filters out ghosts already.
		RegisterSignal(mob, COMSIG_ATOM_SAY, PROC_REF(try_do_therapy))
		// Don't set the status for anyone unless they specifically have an addiction
		if (istype(mob, /mob/living) && !mob?.traitHolder?.hasTraitInList(trait_exclusions))
			var/mob/living/living = mob
			if (!living.find_ailment_by_type(/datum/ailment/addiction))
				return
			mob.setStatus("therapy_zone", INFINITE_STATUS)

	proc/detach_mob(var/area, var/mob/mob)
		UnregisterSignal(mob, COMSIG_ATOM_SAY)
		mob.delStatus("therapy_zone")

	proc/do_therapy()
		for(var/datum/mind/mind in src.master.population)
			var/mob/mob = mind.current
			// In a perfect world there'd be checks for 'did mob hear/understand', maybe handled using callbacks attached to say messages.
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
		UnregisterSignal(src.parent, COMSIG_AREA_ENTERED_BY_MOB)
		UnregisterSignal(src.parent, COMSIG_AREA_EXITED_BY_MOB)
		for(var/mob/mob in src.master)
			UnregisterSignal(mob, COMSIG_ATOM_SAY)



