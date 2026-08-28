/datum/element/biodegradable/Attach(obj/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_ATOM_REAGENT_CHANGE, PROC_REF(biodegrade))
	. = ..()

/datum/element/biodegradable/Detach(obj/target)
	src.UnregisterSignal(target, COMSIG_ATOM_REAGENT_CHANGE)
	. = ..()

/datum/element/biodegradable/proc/biodegrade(obj/target)
	if (target.reagents?.total_volume > 0)
		return

	target.setStatus("acid", 1 DECI SECOND, list("do_color" = FALSE, "message" = " biodegrades instantly.[prob(95) ? "" : " DO NOT QUESTION THIS."]"))
