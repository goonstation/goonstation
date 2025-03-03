// Surgery holder - Tracks state of all surgeries in progress
/datum/surgeryHolder
	/// The surgeries that sit at the top level for this surgery holder.
	var/list/datum/surgery/base_surgeries
	/// All surgeries under this holder, and their subsurgeries, flattened out.
	var/list/datum/surgery/all_surgeries
	var/mob/living/patient = null

	New(var/mob/living/L)
		..()
		if (!ishuman(L))
			return
		if (istype(L))
			src.patient = L
		setup_surgeries()


	proc/setup_surgeries()
		base_surgeries = list()
		add_surgeries()
		populate_child_surgeries()

	/// Naively populate all surgeries under this holder. For indexing surgeries.
	proc/populate_child_surgeries()
		all_surgeries = list()
		var/list/datum/surgery/surgery_list = list()
		for (var/datum/surgery/surgery in base_surgeries)
			surgery_list += surgery
			surgery_list += surgery.get_sub_surgeries()

		for (var/datum/surgery/surgery in surgery_list)
			all_surgeries[surgery.id] = surgery

	/// Enter the top level context menu for this surgery holder
	proc/start_surgery(mob/surgeon, obj/tool)
		show_contexts(surgeon, tool)

	proc/do_life(var/mult)
		for(var/datum/surgery/surgery in base_surgeries)
			if (surgery.get_surgery_progress() > 0)
				boutput(world, "Surgery: " + surgery.id + " Progress: " + surgery.get_surgery_progress())

	/// Get's a surgery's progress by ID.
	proc/get_surgery_progress(var/surgery_id)
		return all_surgeries[surgery_id].get_surgery_progress()
	proc/get_surgery_complete(var/surgery_id)
		return all_surgeries[surgery_id].surgery_complete()
	/// Trigger a surgery's context clicked action.
	proc/surgery_clicked(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.surgery_clicked(surgeon, I)

	/// Cancel all surgeries.
	proc/cancel_all()
		for(var/datum/surgery/surgery in base_surgeries)
			surgery.cancel_surgery(null, null)
	/// Cancel a surgery through the context menu. This will generally re-open the context action menu.
	proc/cancel_surgery_context(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.cancel_surgery_context(surgeon, I)
	/// Cancel a surgery. Does not interact with context menus.
	proc/cancel_surgery(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.cancel_surgery(surgeon, I)

	/// Get the top-level surgery context icons for this holder.
	proc/get_contexts()
		var/list/datum/contextAction/surgery/contexts = list()
		for (var/datum/surgery/surgery in base_surgeries)
			surgery.infer_surgery_stage()
			if (surgery.surgery_possible(patient) && surgery.visible && !surgery.implicit)
				contexts += surgery.get_context()
		return contexts

	/// Show the context action ring to the surgeon.
	proc/show_contexts(mob/surgeon, obj/tool)
		var/list/datum/contextAction/surgery/contexts = get_contexts()
		if (length(contexts) == 1)
			surgery_clicked(contexts[1].surgery, surgeon, tool)
		else
			surgeon.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)

	/// Determine if surgery is even possible on the holder's owner.
	proc/can_operate(mob/surgeon, obj/item/tool)
		if (!patient)
			return FALSE
		if (!ishuman(patient)) // is the patient not a human?
			return FALSE

		// Is this a limb that can easily be attached?
		if (istype(tool, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/limb = tool
			if (limb.easy_attach)
				return TRUE
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

	// 'Shortcuts' are for implicit surgeries that don't use a context menu. For example. Cramming an organ inside someone's chest.
	/// Determine if this surgery will use the item without needing a context popup.
	proc/shortcut(mob/surgeon, obj/item/tool)
		for (var/datum/surgery/surgery in base_surgeries)
			surgery.infer_surgery_stage()
		if (!can_operate(surgeon, tool))
			return FALSE
		for (var/datum/surgery/surgery in base_surgeries)
			if (surgery.do_shortcut(surgeon, tool))
				return TRUE
		return FALSE

	/// called when wanting to 'go up' a level
	proc/exit_surgery(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		if (surgery.super_surgery)
			surgery.super_surgery.enter_surgery(surgeon)
		else
			//go back to the start if we've no more supersurgeries
			src.start_surgery(surgeon, I)

	/// Setup top-level surgeries. If you want to add more after this is created, you'll need a new proc that updates all_surgeries.
	proc/add_surgeries()


	living
		add_surgeries()
			..()
			base_surgeries += new/datum/surgery/limb_surgery(patient, src)
			base_surgeries += new/datum/surgery/organ_surgery(patient, src)
			base_surgeries += new/datum/surgery/head(patient, src)
			base_surgeries += new/datum/surgery/implant(patient, src)
			base_surgeries += new/datum/surgery/lower_back(patient, src)




