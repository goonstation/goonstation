/datum/element/slippery/Attach(atom/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_ATOM_CROSSED, PROC_REF(slip))
	src.RegisterSignal(target, COMSIG_ATOM_SLIP_END, PROC_REF(on_slip_end))
	. = ..()

/datum/element/slippery/Detach(atom/target)
	src.UnregisterSignal(target, COMSIG_ATOM_CROSSED)
	src.UnregisterSignal(target, COMSIG_ATOM_SLIP_END)
	. = ..()

/datum/element/slippery/proc/slip(atom/target, mob/living/carbon/victim)
	if (!istype(victim) || istype(target.loc, /turf/space))
		return

	if (isitem(target))
		var/obj/item/I = target
		LAZYLISTADDUNIQUE(victim.attached_objs, I)
		I.glide_size = victim.glide_size

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

/datum/element/slippery/proc/on_slip_end(atom/target, mob/living/carbon/victim)
	if (!istype(victim))
		return

	if (isitem(target))
		var/obj/item/I = target
		LAZYLISTREMOVE(victim.attached_objs, I)
		I.glide_size = I::glide_size
