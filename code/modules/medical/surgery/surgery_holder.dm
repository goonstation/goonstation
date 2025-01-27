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

	proc/do_life(var/mult)
		for(var/datum/surgery/surgery in surgeries)
			if (surgery.active)
				take_bleeding_damage(src, null, rand(5, 10))


	/// Enter a specific surgery, used here for tracking state of each surgeon
	proc/surgery_clicked(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.surgery_clicked(surgeon, I)

	proc/cancel_all()
		for(var/datum/surgery/surgery in surgeries)
			surgery.cancel_surgery(null, null)
	/// Cancel a surgery through the context menu. Places player 1 layer up.
	proc/cancel_surgery_context(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.cancel_surgery_context(surgeon, I)
	/// Cancel a surgery. Does not interact with context menus.
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

	proc/can_operate(mob/surgeon, obj/item/tool)
		if (!patient)
			return FALSE
		if (!ishuman(patient)) // is the patient not a human?
			return FALSE
		// is the patient on an optable and lying?
		if (locate(/obj/machinery/optable, patient.loc))
			if(patient.lying || patient == surgeon)
				return TRUE
		// is the patient on a table and paralyzed or dead?
		else if ((locate(/obj/stool/bed, patient.loc) || locate(/obj/table, patient.loc)) && (patient.getStatusDuration("unconscious") || patient.stat))
			return TRUE
		// is the patient really drunk and also the surgeon?
		else if (patient.reagents && (patient.reagents.get_reagent_amount("ethanol") > 40 || patient.reagents.get_reagent_amount("morphine") > 5) && (patient == surgeon || (locate(/obj/stool/bed, patient.loc) && patient.lying)))
			return TRUE
		return FALSE

	// 'Shortcuts' are for surgeries that might not need the context menu. For example. Cramming an organ inside someone's chest.
	// Use them sparingly - obviously, in the case of conflict, a surgeon may end up doing something unintentional.
	/// Determine if this surgery will use the item without needing a context popup.
	proc/shortcut(mob/surgeon, obj/item/tool)
		if (!can_operate(surgeon, tool))
			return FALSE
		for (var/datum/surgery/surgery in surgeries)
			if (surgery.do_shortcut(patient, tool))
				return TRUE
		return FALSE

	/// called when wanting to 'go up' a level
	proc/exit_surgery(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		if (surgery.super_surgery)
			surgery.super_surgery.enter_surgery()
		else
			//go back to the start if we've no more supersurgeries
			src.start_surgery(surgeon, I)


	living
		add_surgeries()
			..()
			surgeries += new/datum/surgery/heal_generic(patient, src)
			surgeries += new/datum/surgery/limb_surgery(patient, src)
			surgeries += new/datum/surgery/test(patient, src)
			//these two might need subtypes for different organ havers?
			surgeries += new/datum/surgery/organ_surgery(patient, src)



