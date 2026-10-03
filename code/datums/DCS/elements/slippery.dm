/datum/element/slippery/Attach(atom/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_ATOM_CROSSED, PROC_REF(slip))
	. = ..()

/datum/element/slippery/Detach(atom/target)
	src.UnregisterSignal(target, COMSIG_ATOM_CROSSED)
	. = ..()

/datum/element/slippery/proc/slip(atom/target, mob/living/carbon/victim)
	if (!istype(victim) || istype(target.loc, /turf/space))
		return

	if (isitem(target))
		var/obj/item/I = target
		LAZYLISTADDUNIQUE(victim.attached_objs, I)
		I.glide_size = victim.glide_size
		src.RegisterSignal(victim, COMSIG_MOVABLE_THROW_END, PROC_REF(on_slip_end_wrapper))

	if (victim.slip(walking_matters = TRUE, ignore_actual_delay = TRUE, throw_type = THROW_PEEL_SLIP, params = list("slip_obj" = target)))
		boutput(victim, SPAN_NOTICE("You slip on [target]!"))
		if (victim.bioHolder.HasEffect("clumsy"))
			victim.changeStatus("knockdown", 5 SECONDS)
			JOB_XP(victim, "Clown", 2)

		else if (prob(20))
			var/mob/M = global.ckey_to_mob(target.get_last_ckey())
			JOB_XP(M, "Clown", 1)

	else
		src.on_slip_end(target, victim)

/datum/element/slippery/proc/on_slip_end_wrapper(mob/living/carbon/victim, datum/thrown_thing/thrown)
	src.on_slip_end(thrown.params["slip_obj"], victim)

/datum/element/slippery/proc/on_slip_end(obj/item/target, mob/living/carbon/victim)
	if (!istype(target))
		return

	src.UnregisterSignal(victim, COMSIG_MOVABLE_THROW_END)
	LAZYLISTREMOVE(victim.attached_objs, target)
	target.glide_size = target::glide_size
