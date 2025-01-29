/datum/surgery
	/// The name of the surgical procedure
	var/name = "Base Surgery"
	/// The description of the surgical procedure
	var/desc = "The base surgery. Call a coder if you see this."
	/// The icon that this surgery uses
	var/icon_state = "scissor"
	/// The surgery that this surgery sits inside of. Null if this sits at the top level.
	var/datum/surgery/super_surgery
	/// The remaining steps to perform this surgery
	var/list/surgery_steps
	/// Surgeries inside this surgery
	var/list/sub_surgeries
	var/list/default_sub_surgeries
	/// If FALSE, sub surgeries are hidden until steps are completed.
	var/sub_surgeries_always_visible = FALSE
	/// If TRUE, the surgery will be restarted when finished.
	var/restart_when_finished = FALSE
	/// If TRUE, the surgery will be exited when finished, placing the user up 1 level.
	var/exit_when_finished = FALSE
	/// If TRUE, and this surgery's is accessible, it will be performed whenever the patient is hit with an appropriate tool.
	/// For example, you could hit a patient with an organ and it would be crammed inside them.
	var/can_shortcut = FALSE

	var/last_surgery_step = 0 //! The last step ID added, used for sequencing steps.
	var/active = FALSE //! If TRUE, the surgery is partially complete.
	var/complete = FALSE //! If TRUE, the surgery is complete and will show as green.
	var/visible = TRUE //! if TRUE, the surgery will be visible in the context menu.
	var/holder = null
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
		last_surgery_step = 0
		generate_surgery_steps()
		get_sub_surgeries()

	proc/can_operate(mob/surgeon, obj/item/tool)
		for(var/datum/surgery_step/step in surgery_steps)
			if (step.can_operate(surgeon, tool))
				return TRUE
		return FALSE
	///Create the sub-surgeries for this surgery
	proc/get_sub_surgeries()
		for(var/surgery in default_sub_surgeries)
			sub_surgeries += new surgery(patient, holder, src)


	proc/surgery_damage_multiplier(mob/living/surgeon)
		if(patient == surgeon)
			if (patient.reagents)
				if (patient.reagents.get_reagent_amount("ethanol") > 40)
					return 3.5
				if (patient.reagents.get_reagent_amount("morphine") > 5)
					return 2
			return 3.5
		return 1

	proc/complete_step(datum/surgery_step/step)
		step.finished = TRUE
		step.on_complete(patient, null)
		step_completed(step, patient)

	/// Called when the surgery's context option is entered. This will be called when exiting subsurgeries!
	proc/enter_surgery(mob/surgeon)
		var/contexts = get_surgery_contexts()
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
		on_complete()
		if (restart_when_finished)
			for(var/datum/surgery_step/step in surgery_steps)
				qdel(step)
			surgery_steps = list()
			generate_surgery_steps()
			active = FALSE
		if (exit_when_finished)
			super_surgery?.enter_surgery(surgeon)
		else
			enter_surgery(surgeon)

	/// Called when something cancels the surgery.
	proc/cancel_surgery(mob/user, obj/item/I)
		for(var/datum/surgery_step/step in surgery_steps)
			step.finished = FALSE
		for(var/datum/surgery/surgery in sub_surgeries)
			surgery.cancel_surgery(user, I)
		active = FALSE
	/// Called when something cancels the surgery.
	proc/cancel_surgery_context(mob/surgeon, obj/item/I)
		cancel_surgery(surgeon, I)
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
		else if (active)
			action.icon_background = "yellowbg"
		return action


	proc/do_shortcut(mob/surgeon, obj/item/I)
		if (super_surgery?.surgery_complete() && can_shortcut && surgery_possible(surgeon, I) && can_operate(surgeon, I))
			for(var/datum/surgery_step/step in surgery_steps)
				if (step.can_operate(surgeon, I))
					step.perform_step(surgeon, I)
					return TRUE
		else
			if (surgery_complete()) // only pass this down to subsurgeries if they can be performed
				for(var/datum/surgery/surgery in sub_surgeries)
					if (surgery.do_shortcut(surgeon, I))
						return TRUE
		return FALSE



	proc/get_surgery_progress()
		var/complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished)
				complete++
		return complete / length(surgery_steps)

	proc/surgery_complete()
		for(var/datum/surgery_step/step in surgery_steps)
			if(!step.optional && !step.finished)
				return FALSE
		return TRUE
	/// Gets the context actions for this surgeries's steps.
	proc/get_surgery_contexts()
		var/list/datum/contextAction/surgical_step/contexts = list()
		var/step_locked = FALSE
		var/completed_stages = 0
		var/optional_contexts = list()
		for (var/datum/surgery_step/step in surgery_steps)
			var/context = step.get_context((step_locked && step.step_number > completed_stages))
			if (!step.finished && !step_locked)
				completed_stages = max(completed_stages, step.step_number)
				step_locked = TRUE
			if (context)
				if (step.optional && step.step_number == 0) // always-available optionals sit counter clockwise of the main step
					optional_contexts += context
				else
					contexts += context

		if (sub_surgeries_always_visible || surgery_complete())
			for (var/datum/surgery/surgery in sub_surgeries)
				if (surgery.surgery_possible(patient) && surgery.visible)
					contexts += surgery.get_context()

		contexts += new /datum/contextAction/surgery/step_up(holder, src)
		contexts += new/datum/contextAction/surgery/cancel(holder,src)
		contexts += optional_contexts


		return contexts
	proc/step_completed(datum/surgery_step/step, mob/user, obj/item/tool)
		active = TRUE
		if (surgery_complete())
			complete_surgery(user, tool)
		else
			enter_surgery(user)

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
	var/success_text = "Manages to manifest coder magic and perform the basest of all surgeries."
	var/success_sound = 'sound/items/Scissor.ogg'
	var/slipup_text = "Fails to manifest coder magic and screws up the surgery."
	var/optional = FALSE //! Whether this step is optional
	var/datum/surgery/parent_surgery = null //! The surgery this step is a part of
	var/hide_when_finished = TRUE //! Whether this step should be hidden when finished
	var/finished = FALSE //! Whether this step is finished
	var/obvious = FALSE //! Would an untrained medical

	New(datum/surgery/parent_surgery)
		src.parent_surgery = parent_surgery
		..()
	proc/valid_subtype(obj/item/tool)
		for(var/type in tools_required)
			if (istype(tool,type))
				return TRUE
	proc/can_operate(mob/surgeon, obj/item/tool, quiet = TRUE)
		if (!IN_RANGE(surgeon, parent_surgery.patient, 1))
			if (!quiet)
				boutput(surgeon,SPAN_ALERT("You're too far away!"))
			return FALSE
		if (!tool)
			if (flags_required == 0 && !length(tools_required))
				return TRUE
			else
				if (!quiet)
					boutput(surgeon,SPAN_ALERT("You need a tool for this step!"))
				return FALSE
		if (tool?.tool_flags & flags_required || valid_subtype(tool) || tool_requirement(surgeon, tool))
			return TRUE
		else
			if (!quiet)
				boutput(surgeon,SPAN_ALERT("You can't use that tool for this step."))
			return FALSE

	///Code based object requirement, IE. contains 50 units of ethanol or something
	proc/tool_requirement(mob/surgeon, obj/item/tool)
		return FALSE

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
		if (can_operate(surgeon, tool, FALSE) && attempt_surgery_step(surgeon, tool))
			if (success_sound)
				playsound(parent_surgery.patient, success_sound, 50, TRUE)
			surgeon.visible_message(success_text)
			on_complete(surgeon, tool)
			finish_step(surgeon, tool)
		else
			parent_surgery.enter_surgery(surgeon)


	/// Mark this step as finished and call on_complete. It's better to override on_complete unless you know what you're doing.
	proc/finish_step(mob/user, obj/item/tool)
		finished = TRUE
		parent_surgery.step_completed(src, user)

	/// Override this to add completion effects to this surgery step.
	proc/on_complete(mob/user, obj/item/tool)

	proc/get_context(var/locked) //! Get the context for this step
		if (finished && hide_when_finished)
			return null
		var/datum/contextAction/surgical_step/step_context = new
		step_context.name = name
		step_context.desc = desc
		step_context.icon_state = icon_state
		step_context.step = src
		if (finished)
			step_context.icon_background = "greenbg"
			step_context.pip_state = "check"
		else if (optional)
			step_context.icon_background = "bluebg"
			step_context.pip_state = "squiggle"
		else if (!locked)
			step_context.icon_background = "yellowbg"
			step_context.pip_state = "circle"
		else
			step_context.icon_background = "redbg"
			step_context.pip_state = "cross"
		return step_context

	screw
		name = "Screw"
		desc = "Screw the thing into place."
		icon_state = "screw"
		success_text = "cuts through the flesh"
		success_sound = 'sound/items/Ratchet.ogg'
		slipup_text = "cuts too deep and messes up!"
		flags_required = TOOL_SCREWING
	smack
		name = "Smack"
		desc = "Hit with something heavy."
		icon_state = "wrench"
		success_text = "whacks really hard"
		success_sound = 'sound/impact_sounds/meat_smack.ogg'
		slipup_text = "cuts too deep and messes up!"
		tool_requirement(mob/surgeon, obj/item/tool)
			if (tool.force >= 5 && (tool.hit_type == DAMAGE_BLUNT || tool.hit_type == DAMAGE_CRUSH))
				return TRUE
			return FALSE
