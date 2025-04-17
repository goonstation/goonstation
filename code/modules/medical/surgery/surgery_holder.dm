// Surgery holder - Tracks state of all surgeries in progress
/datum/surgeryHolder
	/// The surgeries that sit at the top level for this surgery holder.
	var/list/datum/surgery/base_surgeries
	/// All surgeries under this holder, and their subsurgeries, flattened out.
	var/list/datum/surgery/all_surgeries
	var/mob/living/patient = null
	/// Flags for tools that initiate surgeries.
	var/relevant_flags = TOOL_CUTTING | TOOL_SAWING | TOOL_SNIPPING
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

	proc/will_perform_surgery(var/mob/living/user, var/obj/item/tool)
		if (get_shortcut(user,tool))
			return TRUE
		if (tool_relevant(user,tool))
			return TRUE
		return FALSE

	proc/perform_surgery(var/mob/living/user, var/obj/item/tool)
		if (do_shortcut(user,tool))
			tool.add_fingerprint(user)
			return TRUE

		if (tool_relevant(user,tool) && start_surgery(user,tool))
			tool.add_fingerprint(user)
			return TRUE
		return FALSE

	/// Naively populate all surgeries under this holder. For indexing surgeries.
	proc/populate_child_surgeries()
		all_surgeries = list()
		var/list/datum/surgery/surgery_list = list()
		for (var/datum/surgery/surgery in base_surgeries)
			surgery_list += surgery
			surgery_list += surgery.get_sub_surgeries()

		for (var/datum/surgery/surgery in surgery_list)
			all_surgeries[surgery.id] = surgery

	/// Enter the top level context menu for this surgery holder. Returns TRUE if a context menu was shown.
	proc/start_surgery(mob/surgeon, obj/tool)
		return show_contexts(surgeon, tool)

	proc/do_life(var/mult)
		return

	/// Get's a surgery's progress by ID.
	proc/get_surgery_progress(var/surgery_id)
		all_surgeries[surgery_id].infer_surgery_stage()
		return all_surgeries[surgery_id].get_surgery_progress()
	proc/get_surgery_complete(var/surgery_id)
		return all_surgeries[surgery_id].surgery_complete()
	proc/get_active_surgeries(var/zone)
		var/list/datum/surgery/surgeries = list()
		for (var/datum/surgery/surgery in all_surgeries)
			if (surgery.affected_zone == zone && surgery.get_surgery_progress() > 0)
				surgeries += surgery
		return surgeries
	proc/get_surgery(var/surgery_id)
		return all_surgeries[surgery_id]
	proc/get_surgeries_by_zone(var/zone)
		var/list/datum/surgery/result = list()
		for (var/surgery in all_surgeries)
			var/datum/surgery/thing = all_surgeries[surgery]
			if (thing.affected_zone == zone)
				result += thing
		return result
	/// Trigger a surgery's context clicked action. Returns TRUE if a context menu was shown.
	proc/surgery_clicked(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.surgery_clicked(surgeon, I)

	/// Returns TRUE if the given tool is relevant to any possible surgery.
	proc/tool_relevant(mob/user, obj/item/tool)
		if (tool.tool_flags & relevant_flags)
			return TRUE
		return FALSE

	/// Cancel all surgeries.
	proc/cancel_all()
		for(var/datum/surgery/surgery in base_surgeries)
			surgery.cancel_surgery(null, null)
	/// Cancel a surgery through the context menu. This will generally re-open the context action menu.
	proc/cancel_surgery_context(datum/surgery/surgery, mob/living/surgeon, obj/item/I)
		if (!surgery)
			return
		surgery.cancel_surgery(surgeon, I, quiet=FALSE)
	/// Cancel a surgery. Does not interact with context menus.
	proc/cancel_surgery(id, mob/living/surgeon, obj/item/I)
		if (!id)
			return
		all_surgeries[id].cancel_surgery(surgeon, I)

	/// Get the top-level surgery context icons for this holder.
	proc/get_contexts(var/surgeon, var/obj/item/tool)
		var/list/datum/contextAction/surgery/contexts = list()
		for (var/datum/surgery/surgery in base_surgeries)
			surgery.infer_surgery_stage()
			if (surgery.surgery_conditions_met(surgeon, tool) && surgery.surgery_possible(surgeon) && surgery.visible)
				contexts += surgery.get_context()
		return contexts

	/// Show the context action ring to the surgeon. Returns TRUE if a context menu was shown.
	proc/show_contexts(mob/surgeon, obj/tool)
		var/list/datum/contextAction/surgery/contexts = get_contexts(surgeon, tool)
		if (!length(contexts))
			return FALSE
		if (length(contexts) == 1) // if only one top-level surgery available. go straight into it. mimics old behavior to instantly enter torso surgery
			surgery_clicked(contexts[1].surgery, surgeon, tool)
		else
			surgeon.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)
		return TRUE


	// 'Shortcuts' are for implicit surgeries that don't use a context menu. For example. Cramming an organ inside someone's chest.
	/// Determine if this surgery will use the item without needing a context popup.
	proc/do_shortcut(mob/surgeon, obj/item/tool)
		var/datum/surgery_step/step = get_shortcut(surgeon, tool)
		if (step)
			step.perform_step(surgeon, tool)
			return TRUE
		return FALSE
	/// Get the surgery step that will be performed. Returns FALSE if no surgery step is possible.
	proc/get_shortcut(mob/surgeon, obj/item/tool)
		for (var/datum/surgery/surgery in base_surgeries)
			surgery.infer_surgery_stage()
		for (var/datum/surgery/surgery in base_surgeries)
			var/result = surgery.get_shortcut(surgeon, tool)
			if (result)
				return result
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
			base_surgeries += new/datum/surgery/parasite(patient, src)
			base_surgeries += new/datum/surgery/lower_back(patient, src)
			base_surgeries += new/datum/surgery/sutures(patient, src)





