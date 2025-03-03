/datum/surgery
	/// The ID of the surgical procedure, for lookups
	var/id = "base_surgery"
	/// The name of the surgical procedure
	var/name = "Base Surgery"
	/// The description of the surgical procedure
	var/desc = "The base surgery. Call a coder if you see this."
	/// The icon that this surgery uses
	var/icon_state = "scissor"
	/// The surgery that this surgery sits inside of. Null if this sits at the top level.
	var/datum/surgery/super_surgery
	/// The remaining steps to perform this surgery
	var/list/datum/surgery_step/surgery_steps
	/// Surgeries inside this surgery
	var/list/sub_surgeries
	var/list/default_sub_surgeries
	/// If FALSE, sub surgeries are hidden until steps are completed.
	var/sub_surgeries_always_visible = FALSE
	/// If TRUE, the surgery will be exited when finished, placing the user up 1 level.
	var/exit_when_finished = FALSE
	/// If TRUE, this surgery will automatically be performed when
	/// the user is hit with a tool that allows surgery_possible() and can_operate().
	var/implicit = FALSE
	/// If TRUE and implicit, then using tools in the wrong order will cause a mess up.
	var/can_mess_up = FALSE
	/// The part of the body this surgery is performed on.
	var/affected_zone

	var/last_surgery_step = 0 //! The last step ID added, used for sequencing steps.
	var/complete = FALSE //! If TRUE, the surgery is complete and will show as green.
	var/visible = TRUE //! if TRUE, the surgery will be visible in the context menu.
	var/datum/surgeryHolder/holder = null
	var/can_cancel = TRUE //! if TRUE, this surgery can be cancelled with a suture.
	var/mob/living/patient = null

	New(var/mob/living/patient, var/datum/surgeryHolder/holder, var/datum/surgery/super_surgery)
		..()
		if (!ishuman(patient))
			return
		src.patient = patient
		src.holder = holder
		if (super_surgery)
			src.super_surgery = super_surgery
		surgery_steps = list()
		sub_surgeries = list()
		regenerate_surgery_steps()
		populate_sub_surgeries()

	proc/can_operate(mob/surgeon, obj/item/tool)
		var/list/completed_ids = list()
		// some steps ahead can be completed automatically, due to not being necessary.
		for(var/datum/surgery_step/step in surgery_steps)
			while (length(completed_ids) < step.step_number)
				completed_ids += TRUE
			completed_ids[step.step_number] = (completed_ids[step.step_number] && step.finished)

		var/max_step_number = 0
		for (var/i=1, i <= length(completed_ids), i++)
			if (completed_ids[i])
				max_step_number = i
			else
				break
		max_step_number++ //non-simultaneous steps start at 1
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.step_number <= max_step_number)
				if (!step.finished && step.can_operate(surgeon, tool))
					return TRUE
		return FALSE

	proc/populate_sub_surgeries()
		for(var/surgery in default_sub_surgeries)
			sub_surgeries += new surgery(patient, holder, src)

	proc/get_sub_surgeries()
		var/list/datum/surgery/response = list()
		for(var/datum/surgery/surgery in sub_surgeries)
			response += surgery
			response += surgery.get_sub_surgeries()
		return sub_surgeries

	proc/surgery_damage_multiplier(mob/living/surgeon, obj/item/tool)
		var/base = 1
		if(patient == surgeon)
			if (patient.reagents)
				if (patient.reagents.get_reagent_amount("ethanol") > 40)
					base *= 3.5
				else if (patient.reagents.get_reagent_amount("morphine") > 5)
					base *= 2
			else
				base *= 3.5
		return 1

	/// Called when the surgery's context menu is entered. This will be called when exiting child surgeries!
	proc/enter_surgery(mob/surgeon)
		infer_surgery_stage()
		var/contexts = get_surgery_contexts(surgeon)
		surgeon.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)

	/// Adds a step to the surgery, that can only be performed after the previous step(s) are complete.
	proc/add_next_step(datum/surgery_step/step)
		last_surgery_step++
		step.step_number = last_surgery_step
		surgery_steps += step

	/// Adds a step to the surgery, that can be performed at the same time as the previous step.
	proc/add_simultaneous_step(datum/surgery_step/step)
		step.step_number = last_surgery_step
		surgery_steps += step

	/// Adds a step to the surgery that can be performed anytime.
	proc/add_free_step(datum/surgery_step/step)
		step.step_number = 0
		surgery_steps += step

	/// Called when the surgery's context is clicked.
	proc/surgery_clicked(mob/living/surgeon, obj/item/I)
		enter_surgery(surgeon)

	/// Called when the last step of a surgery is completed
	proc/complete_surgery(mob/surgeon, obj/item/I)
		on_complete(surgeon, I)
		if (exit_when_finished && !implicit)
			super_surgery?.enter_surgery(surgeon)
		else if (!implicit)
			enter_surgery(surgeon)

	proc/on_cancel(mob/user, obj/item/I)
	/// Called when something cancels the surgery.
	proc/cancel_surgery(mob/user, obj/item/I)
		on_cancel(user, I)
		for(var/datum/surgery_step/step in surgery_steps)
			step.finished = FALSE
		for(var/datum/surgery/surgery in sub_surgeries)
			surgery.cancel_surgery(user, I)

	/// Called when something cancels the surgery from within a context menu. should show another menu
	proc/cancel_surgery_context(mob/surgeon, obj/item/I)
		if (!istype(I, /obj/item/suture))
			boutput(surgeon, SPAN_ALERT("You need a suture to cancel surgery!"))
			return
		cancel_surgery(surgeon, I)
		if (!implicit)
			super_surgery?.enter_surgery(surgeon)

	/// Gets the context action for this surgery.
	proc/get_context()
		var/datum/contextAction/surgery/action= new
		action.name = name
		action.desc = desc
		action.icon_state = icon_state
		action.surgery = src
		action.holder = holder
		if (complete)
			action.icon_background = "greenbg"
		else if (get_surgery_progress())
			action.icon_background = "yellowbg"
		return action

	/// If this is an implicit step, see if we should 'shortcut' past the context menu.
	proc/do_shortcut(mob/surgeon, obj/item/I)
		if ((!super_surgery || super_surgery?.surgery_complete()) && implicit && surgery_possible(surgeon, I) && can_operate(surgeon, I))
			for(var/datum/surgery_step/step in surgery_steps)
				if (step.can_operate(surgeon, I))
					step.perform_step(surgeon, I)
					return TRUE
			return FALSE
		else
			if (surgery_complete()) // only attempt invisible subsurgeries if this surgery is done.
				// do the next implicit step if subsurgeries are implicit
				for(var/datum/surgery/surgery in sub_surgeries)
					surgery.infer_surgery_stage()
					if (surgery.do_shortcut(surgeon, I))
						return TRUE
				// if we've no implicit steps, but have non-implicit children, show the context menu.
				// for weird cases like lower back surgery
				var/contexts = get_surgery_contexts(surgeon, FALSE)
				if (length(contexts) > 0)
					enter_surgery(surgeon)
					return TRUE
		return FALSE

	proc/get_surgery_progress()
		var/complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished)
				complete++
		return complete

	proc/surgery_complete()
		for(var/datum/surgery_step/step in surgery_steps)
			if(!step.optional && !step.finished)
				return FALSE
		return TRUE

	proc/step_accessible(datum/surgery_step/chosen_step)
		if (chosen_step.step_number == 0)
			return TRUE
		var/complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished)
				complete = max (step.step_number, complete)
		return (chosen_step.step_number-1) <= complete
	/// Gets the context actions for this surgeries's steps.
	proc/get_surgery_contexts(surgeon, var/add_navigation = TRUE)
		var/list/datum/contextAction/surgical_step/contexts = list()
		var/completed_stages = 0
		var/optional_contexts = list()

		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished)
				completed_stages = max(completed_stages, step.step_number)

		for (var/datum/surgery_step/step in surgery_steps)
			var/context = step.get_context((step.step_number-1 > completed_stages))
			if (context)
				if (step.optional && step.step_number == 0) // always-available optionals sit counter clockwise of the main step
					optional_contexts += context
				else
					contexts += context


		if (sub_surgeries_always_visible || surgery_complete())
			for (var/datum/surgery/surgery in sub_surgeries)
				if (surgery.surgery_possible(surgeon) && surgery.visible && !surgery.implicit)
					contexts += surgery.get_context()

		//hacky fix to remove the back button if there's only one top-level surgery available.
		//Keeps contexts looking identical to older code.
		if (add_navigation)
			if (super_surgery != null || length(holder.get_contexts()) > 1)
				contexts += new /datum/contextAction/surgery/step_up(holder, src)


			if (can_cancel && get_surgery_progress() > 0)
				contexts += new/datum/contextAction/surgery/cancel(holder,src)

		//place the always-optional steps to the left of the top step.
		contexts += optional_contexts

		return contexts

	proc/step_completed(datum/surgery_step/step, mob/user, obj/item/tool)
		if (surgery_complete())
			complete_surgery(user, tool)
		else if (!implicit)
			enter_surgery(user)

	/// Called before surgery completion is checked. Use this if surgery steps are dependent on some external state. IE: Wizard spells doing butt/limb loosening.
	// See organ surgery for an example.
	proc/infer_surgery_stage()

	/// Clears all surgery steps and regenerates them.
	proc/regenerate_surgery_steps()
		qdel(surgery_steps)
		surgery_steps = list()
		last_surgery_step = 0
		generate_surgery_steps()

	///Create & add the surgery steps for this surgery
	proc/generate_surgery_steps()
	///Whether this surgery is possible on the target - Otherwise, will be hidden from the context menu
	proc/surgery_possible(mob/living/surgeon)
		return TRUE
	proc/on_complete(mob/surgeon, obj/item/I)

/datum/surgery_step
	var/flags_required = 0 //! Flags for tools that are accepted for this step
	var/tools_required = list() //! Explicit tools required, alongside their failure chance, if you want ghetto analogs
	var/step_number = 0 //! The step number in the surgery. Set by the surgery when added.
	var/name = "Base surgery step"
	var/desc = "Call 1-800-IMCODER."
	var/icon_state = "scissor"
	var/success_sound = 'sound/items/Scissor.ogg'
	var/optional = FALSE //! Whether this step is optional
	var/visible = TRUE //! Whether this step is visible
	var/datum/surgery/parent_surgery = null //! The surgery this step is a part of
	var/hide_when_finished = TRUE //! Whether this step should be hidden when finished
	var/finished = FALSE //! Whether this step is finished

	New(datum/surgery/parent_surgery)
		src.parent_surgery = parent_surgery
		..()
	proc/valid_subtype(obj/item/tool)
		if (length(tools_required) == 0)
			return TRUE
		for(var/type in tools_required)
			if (istype(tool,type))
				return TRUE

	/// Whether this step is actually possible.
	proc/step_possible(mob/surgeon, obj/item/tool)
		return TRUE
	proc/can_operate(mob/surgeon, obj/item/tool, quiet = TRUE)
		if (finished)
			return FALSE
		if (!IN_RANGE(surgeon, parent_surgery.patient, 1))
			if (!quiet)
				boutput(surgeon,SPAN_ALERT("You're too far away!"))
			return FALSE
		if (!parent_surgery.step_accessible(src))
			if (!quiet)
				boutput(surgeon,SPAN_ALERT("You need to complete the previous steps first!"))
			return FALSE
		if (!tool)
			if (flags_required == 0 && !length(tools_required))
				return TRUE
			else
				if (!quiet)
					if (flags_required)
						boutput(surgeon,SPAN_ALERT(get_flag_message()))
					else
						boutput(surgeon,SPAN_ALERT("You need a tool for this step!"))
				return FALSE
		if ((!flags_required || tool?.tool_flags & flags_required) && valid_subtype(tool) && tool_requirement(surgeon, tool))
			return TRUE
		else
			if (!quiet)
				if ((flags_required && !(tool?.tool_flags & flags_required)))
					boutput(surgeon,SPAN_ALERT(get_flag_message()))
				else
					boutput(surgeon,SPAN_ALERT("You can't use that tool for this step."))
			return FALSE

	///Code based object requirement, IE. contains 50 units of ethanol or something
	proc/tool_requirement(mob/surgeon, obj/item/tool)
		return TRUE

	///Calculate if this step succeeds, apply failure effects here
	proc/attempt_surgery_step(mob/surgeon, obj/item/tool)
		//todo: migrate all these over
		if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
			surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!"), \
			SPAN_ALERT("You fumble and stab yourself in the eye with [src]!"))
			surgeon.bioHolder.AddEffect("blind")
			surgeon.changeStatus("knockdown", 4 SECONDS)
			JOB_XP(surgeon, "Clown", 1)
			var/damage = rand(5, 15)
			random_brute_damage(surgeon, damage)
			take_bleeding_damage(surgeon, null, damage)
			return FALSE
		return TRUE

	proc/perform_step(mob/surgeon, obj/item/tool) //! Perform the surgery step
		if (can_operate(surgeon, tool, FALSE) && step_possible(surgeon, tool) && attempt_surgery_step(surgeon, tool))
			if (success_sound)
				playsound(parent_surgery.patient, success_sound, 50, TRUE)
			on_complete(surgeon, tool)
			finish_step(surgeon, tool)
		else
			if (!parent_surgery.implicit)
				parent_surgery.enter_surgery(surgeon)


	/// Mark this step as finished. It's better to override on_complete unless you know what you're doing.
	proc/finish_step(mob/user, obj/item/tool)
		finished = TRUE
		parent_surgery.step_completed(src, user, tool)

	/// Override this to add completion effects to this surgery step.
	proc/on_complete(mob/user, obj/item/tool)

	proc/get_context(var/locked) //! Get the context for this step
		if (finished && hide_when_finished || !visible)
			return null
		var/datum/contextAction/surgical_step/step_context = new
		step_context.name = name
		step_context.desc = desc
		step_context.icon_state = icon_state
		step_context.step = src
		if (finished)
			step_context.icon_background = "greenbg"
			step_context.pip_state = "check"
		else if (locked)
			step_context.icon_background = "redbg"
			step_context.pip_state = "cross"
		else if (optional)
			step_context.icon_background = "bluebg"
			step_context.pip_state = "squiggle"
		else if (!locked)
			step_context.icon_background = "yellowbg"
			step_context.pip_state = "circle"
		return step_context

	proc/get_flag_message()
		if (flags_required & TOOL_CHOPPING)
			return "You need a chopping tool for this step!"
		else if (flags_required & TOOL_SCREWING)
			return "You need a screwing tool for this step!"
		else if (flags_required & TOOL_CUTTING)
			return "You need a cutting tool for this step!"
		else if (flags_required & TOOL_CLAMPING)
			return "You need a clamp for this step!"
		else if (flags_required & TOOL_PRYING)
			return "You need a prying tool for this step!"
		else if (flags_required & TOOL_PULSING)
			return "You need a pulsing tool for this step!"
		else if (flags_required & TOOL_SAWING)
			return "You need a sawing tool for this step!"
		else if (flags_required & TOOL_SCREWING)
			return "You need a screwing tool for this step!"
		else if (flags_required & TOOL_SPOONING)
			return "You need a spooning tool for this step!"
		else if (flags_required & TOOL_SNIPPING)
			return "You need a snipping tool for this step!"
		else if (flags_required & TOOL_WELDING)
			return "You need a welding tool for this step!"
		else if (flags_required	& TOOL_WRENCHING)
			return "You need a wrenching tool for this step!"
		else if (flags_required & TOOL_SOLDERING)
			return "You need a soldering tool for this step!"
		else if (flags_required & TOOL_WIRING)
			return "You need wires for this step!"
		else
			return "You can't use that tool for this step."
	screw
		name = "Screw"
		desc = "Screw the thing into place."
		icon_state = "screw"
		success_sound = 'sound/items/Ratchet.ogg'
		flags_required = TOOL_SCREWING
	smack
		name = "Smack"
		desc = "Hit with something heavy."
		icon_state = "wrench"
		success_sound = 'sound/impact_sounds/meat_smack.ogg'
		tool_requirement(mob/surgeon, obj/item/tool)
			if (tool.force >= 5 && (tool.hit_type == DAMAGE_BLUNT || tool.hit_type == DAMAGE_CRUSH))
				return TRUE
			return FALSE
