// Surgery holder - Tracks state of all surgeries in progress
/datum/surgeryHolder
	var/list/datum/surgery/surgeries
	var/mob/living/patient = null

	New(var/mob/living/L)
		..()
		if (!ishuman(L))
			return
		if (istype(L))
			src.patient = L
		setup_surgeries()

	/// Add possible surgeries

	proc/add_surgeries()

	proc/setup_surgeries()
		surgeries = list()
		add_surgeries()
		//TODO: does the organholder need to be authority here? probly.
//		if (patient.organHolder)
//			for(var/surgery in patient.organHolder.get_possible_surgeries())
//				surgeries += surgery

	/// Enter the top level menu for this surgery holder
	proc/start_surgery(mob/surgeon, obj/tool)
		show_contexts(surgeon, tool)

	/// Enter a specific surgery, used here for tracking state of each surgeon
	proc/enter_surgery(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.enter_surgery(surgeon, I)

	proc/cancel_surgery(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.cancel_surgery(surgeon, I)

	proc/show_contexts(mob/surgeon, obj/tool)
		var/list/datum/contextAction/surgery/contexts = list()
		for (var/datum/surgery/surgery in surgeries)
			if (surgery.surgery_possible(patient))
				contexts += surgery.get_context()
		surgeon.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)

	proc/can_operate(obj/tool)
		for(var/datum/surgery/surgery in surgeries)
			if (surgery.can_operate(tool))
				return TRUE
	/// called when wanting to 'go up' a level
	proc/exit_surgery(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		if (surgery.super_surgery)
			surgery.super_surgery.enter_surgery(surgeon, I)
		else
			//go back to the start if we've no more supersurgeries
			src.start_surgery(surgeon, I)


	living
		add_surgeries()
			..()
			surgeries += new/datum/surgery/heal_brute(patient, src)
			surgeries += new/datum/surgery/heal_burn(patient, src)
			surgeries += new/datum/surgery/brainsurg(patient, src)


