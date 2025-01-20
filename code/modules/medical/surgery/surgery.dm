/datum/surgery
	/// The name of the surgical procedure
	var/name = "Base Surgery"
	/// The description of the surgical procedure
	var/desc = "The base surgery. Call a coder if you see this."
	/// The icon that this surgery uses
	var/icon_state = "scissor"
	/// The surgery that this surgery sits inside of. Null if this sits at the top level.
	var/datum/surgery/super_surgery
	/// The remaining steps to perform this surgery (grey bg)
	var/list/surgery_steps
	/// Surgeries inside this surgery (green bg)
	var/list/sub_surgeries
	/// If FALSE, sub surgeries are hidden until steps are completed.
	var/sub_surgeries_always_visible = FALSE
	/// If TRUE, the surgery will be restarted when finished.
	var/restart_when_finished = FALSE
	var/holder = null
	var/patient = null
	var/started = FALSE


	New(var/mob/living/patient, var/datum/surgeryHolder/holder, var/datum/surgery/super_surgery)
		..()
		if (!ishuman(patient))
			return
		src.patient = patient
		src.holder = holder
		if (super_surgery)
			src.super_surgery = super_surgery
		surgery_steps = list()
		generate_surgery_steps()

	proc/can_operate(obj/item/tool)
		for(var/datum/surgery_step/step in surgery_steps)
			if (step.can_operate(tool))
				return TRUE
		return FALSE
	///Create & add the surgery steps for this surgery
	proc/generate_surgery_steps()

	///Whether this surgery is possible on the target - Otherwise, will be hidden from the context menu
	proc/surgery_possible(mob/living/target, mob/user)
		return TRUE

	/// Called when the surgery's context option is clicked
	proc/enter_surgery(mob/living/user, obj/item/I)
		if (!started)
			start_surgery(user, I)
			started = TRUE
		var/contexts = get_surgery_contexts()
		contexts += new/datum/contextAction/surgery/cancel(holder,src)
		contexts += new /datum/contextAction/surgery/step_up(holder, src)

		user.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)

	/// Called the first time a surgery is entered
	proc/start_surgery(mob/user, obj/item/I)

	/// Called when the last step of a surgery is completed
	proc/complete_surgery(obj/item/I, mob/user)
		if (restart_when_finished)
			for(var/datum/surgery_step/step in surgery_steps)
				qdel(step)
			surgery_steps = list()
			generate_surgery_steps()
			started = FALSE


	/// Called when something cancels the surgery.
	proc/cancel_surgery(obj/item/I, mob/user)
		for(var/datum/surgery_step/step in surgery_steps)
			step.finished = FALSE

	/// Gets the context action for this surgery - For when you're selecting a surgery.
	proc/get_context()
		var/datum/contextAction/surgery/action= new
		action.name = name
		action.desc = desc
		action.icon_state = icon_state
		action.surgery = src
		action.holder = holder
		return action

	proc/get_surgery_progress()
		var/complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished)
				complete++
		return complete / length(surgery_steps)

	proc/surgery_complete()
		for(var/datum/surgery_step/step in surgery_steps)
			if(!step.finished)
				return FALSE
		return TRUE
	/// Gets the context actions for this surgeries's steps - For when you're performing the surgery.
	proc/get_surgery_contexts()
		var/list/datum/contextAction/surgical_step/contexts = list()
		var/step_locked = FALSE
		for (var/datum/surgery_step/step in surgery_steps)
			var/context = step.get_context(step_locked)
			if (!step.finished)
				step_locked = TRUE
			if (context)
				contexts += context

		if (sub_surgeries_always_visible || surgery_complete())
			for (var/datum/surgery/surgery in sub_surgeries)
				contexts += surgery.get_context()
		return contexts
	proc/step_completed(datum/surgery_step/step, mob/user)
		if (surgery_complete())
			complete_surgery(user)
		else
			enter_surgery(user, null)

/datum/surgery_step
	var/flags_required = 0 //! Flags for tools that are accepted for this step
	var/tools_required = list() //! Explicit tools required, alongside their failure chance, if you want ghetto analogs
	var/name = "Base surgery step"
	var/desc = "Call 1-800-IMCODER."
	var/icon_state = "scissor"
	var/success_text = "Manages to manifest coder magic and perform the basest of all surgeries."
	var/success_sound = 'sound/items/Scissor.ogg'
	var/slipup_text = "Fails to manifest coder magic and screws up the surgery."
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
	proc/can_operate(obj/item/tool)
		return (tool.tool_flags & flags_required || valid_subtype(tool) || tool_requirement(tool))

	///Code based object requirement, IE. contains 50 units of ethanol or something
	proc/tool_requirement(obj/item/tool)
		return FALSE
	proc/perform_step(obj/item/tool, mob/user) //! Perform the surgery step
		if (can_operate(tool))
			if (success_sound)
				playsound(parent_surgery.patient, success_sound, 50, TRUE)
			user.visible_message(success_text)
			step_completed(tool,user)
		else
			boutput(user,SPAN_ALERT("You can't use that tool for this step."))

	proc/step_completed(obj/tool, mob/user) //! Called when the step is completed
		finished = TRUE
		parent_surgery.step_completed(src, user)

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
		else if (!locked)
			step_context.icon_background = "yellowbg"
			step_context.pip_state = "circle"
		else
			step_context.icon_background = "redbg"
			step_context.pip_state = "cross"
		return step_context

	suture
		name = "Suture"
		desc = "Suture the wound."
		icon_state = "suture"
		success_text = "sutures the wound"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "screws up!"

		tools_required = list(/obj/item/suture)
	snip
		name = "Snip"
		desc = "Snip out some tissue."
		icon_state = "scissor"
		success_text = "snips out various tissues and tendons"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = " loses control of the scissors and drags it across the patient's entire chest"
		flags_required = TOOL_SNIPPING

	cut
		name = "Cut"
		desc = "Cut through the flesh."
		icon_state = "scalpel"
		success_text = "cuts through the flesh"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "cuts too deep and messes up!"
		flags_required = TOOL_CUTTING
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
		tool_requirement(obj/item/tool)
			if (tool.force >= 5 && (tool.hit_type == DAMAGE_BLUNT || tool.hit_type == DAMAGE_CRUSH))
				return TRUE
			return FALSE

	whack
		name = "Whack"
		desc = "Hit with something kinda heavy."
		icon_state = "bar"
		success_text = "whacks really hard"
		success_sound = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg'
		slipup_text = "cuts too deep and messes up!"
		tool_requirement(obj/item/tool)
			if (tool.force >= 5 && (tool.hit_type == DAMAGE_BLUNT || tool.hit_type == DAMAGE_CRUSH))
				return TRUE
			return FALSE
	gun
		name = "Gun"
		desc = "what?."
		icon_state = "gun"
		success_text = "shoots really hard"
		success_sound = 'sound/weapons/kuvalda.ogg'
		slipup_text = "cuts too deep and messes up!"
		tools_required = list(/obj/item/gun/kinetic)
	saw
		name = "Saw"
		desc = "Saw through the bone."
		icon_state = "saw"
		success_text = "cuts through the flesh"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "cuts too deep and messes up!"
		flags_required = TOOL_SAWING
	bandage
		name = "Bandage"
		desc = "Bandage the wound."
		icon_state = "bandage"
		success_text = "bandages the wound"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "screws up!"
		tools_required = list(/obj/item/bandage)
