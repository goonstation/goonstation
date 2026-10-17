/datum/surgery
	/// The ID of the surgical procedure, for lookups
	var/id = "base_surgery"
	/// The name of the surgical procedure
	var/name = "Base Surgery"
	/// The description of the surgical procedure
	var/desc = "The base surgery. Call a coder if you see this."
	/// The icon that this surgery uses
	var/icon_state = "scissor"
	/// The steps that make up this surgery
	var/list/datum/surgery_step/surgery_steps
	//! If non-nil, when these steps are complete, all steps will be cancelled.
	var/list/datum/surgery_step/cancel_steps
	/// If TRUE, this surgery will automatically be performed when the patient is hit with a relevant tool
	var/implicit = FALSE

	/// If FALSE, sub surgeries are inaccessible until steps are completed.
	var/sub_surgeries_always_accessible = FALSE
	/// If TRUE, the surgery will be exited when completed, placing the user in the super-surgery.
	var/exit_when_completed = FALSE

	/// The surgery that this surgery sits inside of. Null if this sits at the top level.
	var/datum/surgery/super_surgery
	/// Surgeries inside this surgery
	var/list/current_sub_surgeries
	/// Surgeries to add to this surgery by default.
	var/list/default_sub_surgeries
	/// The body zone this surgery affects, for suturing and checking what surgeries can be performed.
	var/affected_zone = "chest"

	var/last_surgery_step = 0 //! Do not modify - Tracks the last step ID added, used for ordering steps.
	var/complete = FALSE //! If TRUE, the surgery is complete.
	var/visible = TRUE //! if TRUE, the surgery will be visible in the context menu.
	var/datum/surgeryHolder/holder = null
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
		current_sub_surgeries = list()
		regenerate_surgery_steps()
		populate_sub_surgeries()
		complete = surgery_complete() // in case this surgery has no steps

	// ----------
	// Sub-surgery & step generation
	// ----------

	/// Clears all surgery steps and regenerates them.
	proc/regenerate_surgery_steps()
		qdel(surgery_steps)
		surgery_steps = list()
		cancel_steps = list()
		last_surgery_step = 0
		generate_surgery_steps()
		generate_cancel_steps()

	/// Create the default sub-surgeries for this surgery
	proc/populate_sub_surgeries()
		for(var/surgery in default_sub_surgeries)
			current_sub_surgeries += new surgery(patient, holder, src)

	/// Adds a step to the surgery that can only be performed after the previous step(s) are complete.
	proc/add_next_step(datum/surgery_step/step)
		last_surgery_step++
		step.step_number = last_surgery_step
		surgery_steps += step

	/// Adds a step to the surgery that can be performed at the same time as the previously added step.
	proc/add_simultaneous_step(datum/surgery_step/step)
		step.step_number = last_surgery_step
		surgery_steps += step

	/// Adds a step to the surgery that can be performed anytime.
	proc/add_free_step(datum/surgery_step/step)
		step.step_number = 0
		surgery_steps += step

	/// Adds a step to the surgery that can only be performed after the previous step(s) are complete.
	proc/add_cancel_step(datum/surgery_step/step)
		cancel_steps += step

	// ----------
	// Internal Surgery logic
	// ----------

	/// Attempts the first possible step in this surgery, returns TRUE if one was found & attempted.
	proc/attempt_implicit(mob/surgeon, obj/item/tool)
		var/datum/surgery_step/step = step_possible(surgeon, tool)
		if (step)
			step.attempt_surgery_step(surgeon, tool)
			return TRUE
		return FALSE

	// Check if the provided tool is relevant to this surgery, even if not in use
	proc/tool_relevant(mob/surgeon, obj/item/tool)
		for(var/datum/surgery_step/step in surgery_steps)
			if (step.tool_relevant(surgeon, tool))
				return TRUE
		return FALSE

	/// Check if any of this surgeries' steps are possible using the given tool. Returns the first possible step.
	proc/step_possible(mob/surgeon, obj/item/tool)
		var/completed_count = 0
		for(var/datum/surgery_step/step in surgery_steps)
			if (step.completed && step.step_number != 0)
				completed_count = max(step.step_number, completed_count)

		var/max_allowed_step = completed_count + 1
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.step_number <= max_allowed_step)
				if (!step.completed && step.can_operate(surgeon, tool))
					return step

		if (implicit && src.implicit)
			if (cancel_possible())
				for (var/datum/surgery_step/step in cancel_steps)
					if (!step.completed && step.can_operate(surgeon, tool))
						return step
		return FALSE

	/// Called when the last step of a surgery is completed. Override on_complete to add completion effects.
	proc/complete_surgery(mob/surgeon, obj/item/I)
		complete = TRUE
		on_complete(surgeon, I)

	/// Shows the context menu of the surgery containing this surgery.
	proc/step_up(mob/surgeon, obj/item/I)
		if (src.super_surgery)
			src.super_surgery.show_contexts(surgeon)
		else
			//go back to the holder if we've no supersurgery
			holder.show_contexts(surgeon, I)

	/// Cancel this surgery. Override on_cancel to handle cancellation.
	/// Note that all sub-surgeries will also be cancelled.
	/// - from_context_menu: Opens the context menu afterwards if TRUE.
	/// - forced: Forces the cancellation for behaviour like admin heals.
	proc/cancel(mob/surgeon, obj/item/I, var/from_context_menu = FALSE, var/forced = FALSE, var/quiet = FALSE)
		on_cancel(surgeon, I, quiet=quiet, forced=forced)
		for(var/datum/surgery_step/step in surgery_steps)
			step.cancel(surgeon, I)
		for(var/datum/surgery_step/step in cancel_steps)
			step.cancel(surgeon, I)
		complete = FALSE
		for(var/datum/surgery/surgery in current_sub_surgeries)
			// sub-surgeries always cancel quietly, to avoid spamming -every- subsurgeries' "You suture <X> shut!"
			if (surgery.cancel_possible() || forced)
				surgery.cancel(surgeon, I, from_context_menu=from_context_menu, quiet=TRUE,forced=forced)
		check_surgery_stage()
		if (from_context_menu)
			src.super_surgery?.show_contexts(surgeon)

	/// Determine if this surgery is possible on the target.
	proc/can_perform_surgery(mob/living/surgeon, obj/item/tool)
		return surgery_conditions_met(surgeon, tool) && surgery_possible(surgeon)

	/// Check the provided step is doable - IE. Are all previous steps complete?
	proc/step_accessible(datum/surgery_step/chosen_step)
		if (chosen_step.step_number == 0)
			return TRUE
		var/steps_complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.completed)
				steps_complete = max (step.step_number, steps_complete)
		return (chosen_step.step_number-1) <= steps_complete

	/// Called when a step is completed. Handles if the surgery is complete/cancelled and re-entering the surgery UI.
	proc/step_completed(mob/user, obj/item/tool, from_context_menu=FALSE)
		if (cancel_possible() && surgery_cancelled())
			cancel(user, tool, from_context_menu=from_context_menu, forced=FALSE)
		else if (surgery_complete())
			complete_surgery(user, tool)

	// Appends flavor text when examining the patient. Ie '<Patient> has a large incision...'
	// If not overridden, this will append the descriptions of all current sub-surgeries.
	proc/get_desc(show_vague)
		for (var/datum/surgery/surgery in current_sub_surgeries)
			. += surgery.get_desc(show_vague)
		return

	// ----------
	// Implicit surgeries
	// ----------
	// Covers old style 'implicit' surgeries that are performed when the patient is hit with the correct tool.

	/// Returns the surgery (or sub-surgery) that will be performed with the given tool. Returns FALSE if no implicit surgery is possible.
	proc/get_implicit_surgery(mob/surgeon, obj/item/tool)
		if (!can_perform_surgery(surgeon, tool))
			return FALSE
		// If not complete & this is an implicit surgery, return the first possible step.
		if ( implicit)
			var/datum/surgery_step/step = step_possible(surgeon, tool)
			if (step)
				return src

		// If sub-surgeries are accessible, attempt to get an implicit step from them.
		if (sub_surgeries_accessible(surgeon, tool))
			for(var/datum/surgery/surgery in current_sub_surgeries)
				surgery.check_surgery_stage()
				var/result = surgery.get_implicit_surgery(surgeon, tool)
				if (result)
					return result
		return FALSE

	/// Returns the implicit surgery step that will be performed with the given tool.
	proc/get_implicit_step(mob/surgeon, obj/item/tool)
		if ((!super_surgery || super_surgery?.complete) && implicit && can_perform_surgery(surgeon, tool))
			var/datum/surgery_step/step = step_possible(surgeon, tool)
			if (step)
				return step
		return FALSE


	// ----------
	// UI Interaction
	// ----------

	/// Called when the surgery's context icon is clicked. Returns TRUE if context was shown.
	proc/surgery_clicked(mob/living/surgeon, obj/item/tool)
		if (super_surgery && !super_surgery.complete)
			return super_surgery.show_contexts(surgeon, tool)
		else
			return show_contexts(surgeon, tool)

	/// Show the surgery's context menu. Returns TRUE if context was shown.
	proc/show_contexts(mob/surgeon, obj/item/tool)
		check_surgery_stage()
		if (super_surgery && !super_surgery.complete) // hop up a level if this surgery is no longer accessible
			return super_surgery.show_contexts(surgeon, tool)
		else
			var/contexts = get_surgery_contexts(surgeon, tool)
			if (length(contexts) > 0)
				surgeon.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)
				return TRUE
		return FALSE

	/// Gets the context action for this surgery.
	proc/get_context()
		var/datum/contextAction/surgery/action= new
		action.name = name
		action.desc = desc
		action.icon_state = icon_state
		action.surgery = src
		action.holder = holder
		complete = surgery_complete()
		if (complete)
			action.icon_background = "greenbg"
		else if (get_surgery_progress())
			action.icon_background = "yellowbg"
		return action

	/// Gets the context actions for this surgeries' steps.
	proc/get_surgery_contexts(surgeon, obj/item/tool, var/add_navigation = TRUE)
		var/list/datum/contextAction/surgical_step/contexts = list()
		var/completed_stages = 0
		var/optional_contexts = list()

		if (!implicit)
			for (var/datum/surgery_step/step in surgery_steps)
				if (step.completed)
					completed_stages = max(completed_stages, step.step_number)

			for (var/datum/surgery_step/step in surgery_steps)
				var/context = step.get_context((step.step_number-1 > completed_stages))
				if (context)
					if (step.optional && step.step_number == 0) // always-available optionals sit counter clockwise of the main step
						optional_contexts += context
					else
						contexts += context
		if (sub_surgeries_accessible(surgeon, tool))
			for (var/datum/surgery/surgery in current_sub_surgeries)
				if (surgery.can_perform_surgery(surgeon, tool) && surgery.visible)
					contexts += surgery.get_context()

		if (add_navigation)
			//remove the back button if there's only one top-level surgery available.
			if (super_surgery != null || length(holder.get_contexts(surgeon)) > 1)
				contexts += new /datum/contextAction/surgery/step_up(holder, src)

		if (cancel_possible() && cancel_steps && get_surgery_progress() > 0 && !implicit)
			for (var/datum/surgery_step/step in cancel_steps)
				if (!step.completed)
					contexts += step.get_context()
					break

		//place the always-optional steps to the left of the top step.
		contexts += optional_contexts

		return contexts


	/// Called whenever a step is attempted, failure or not.
	proc/step_attempted(datum/surgery_step/step, mob/surgeon, obj/item/tool)
		if (!implicit)
			if (exit_when_completed && complete)
				super_surgery?.show_contexts(surgeon)
			else
				show_contexts(surgeon)


	// ----------
	// Surgery logic
	// ----------

	/// Check if all steps are complete.
	proc/surgery_complete()
		for(var/datum/surgery_step/step in surgery_steps)
			if(!step.optional && !step.completed)
				return FALSE
		return TRUE

	/// Check if all cancel steps are complete
	proc/surgery_cancelled()
		for(var/datum/surgery_step/step in cancel_steps)
			if(!step.completed)
				return FALSE
		return TRUE

	/// Get all sub surgeries, including their sub-surgeries, etc.
	proc/get_sub_surgeries()
		var/list/datum/surgery/response = list()
		for(var/datum/surgery/surgery in current_sub_surgeries)
			response += surgery
			response += surgery.get_sub_surgeries()
		return response

	/// Get the progress of the surgery. 1 = first step completed, etc.
	proc/get_surgery_progress()
		var/lowest_incomplete = 99
		var/any_complete = FALSE
		var/any_incomplete = FALSE
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.completed && !step.optional)
				any_complete = TRUE
			if (!step.completed && !step.optional)
				lowest_incomplete = min(step.step_number, lowest_incomplete)
				any_incomplete = TRUE
		if (!any_complete)
			return 0
		else if (any_incomplete)
			return lowest_incomplete - 1
		else
			return last_surgery_step

	/// Returns true if sub surgeries are possible.
	proc/sub_surgeries_accessible(mob/surgeon, obj/item/tool)
		return (sub_surgeries_always_accessible || complete)

	/// Check if the patient can have this surgery performed on them here. IE: on a table.
	/// Use 'tool' here to see if an item could ignore being on a table.
	proc/surgery_conditions_met(mob/surgeon, obj/item/tool)
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
	/// Checks if the surgery can be canceled.
	proc/cancel_possible()
		return (cancel_steps && get_surgery_progress() > 0)


	//-----
	// Hooks
	//-----

	/// Set this surgery's progress based on the patient.
	/// For example, if a non-surgery thing chopped their limbs off.
	proc/check_surgery_stage()
		SHOULD_CALL_PARENT(TRUE)
		complete = surgery_complete()

	///Create & add the surgery steps for this surgery
	proc/generate_surgery_steps()

	///Create & add the cancel steps for this surgery.
	proc/generate_cancel_steps()

	///Whether this surgery is possible on the target - Otherwise, will be hidden from the context menu
	proc/surgery_possible(mob/living/surgeon)
		if (surgeon.zone_sel.selecting != affected_zone)
			return FALSE
		return TRUE

	/// Called on completion of the surgery.
	proc/on_complete(mob/surgeon, obj/item/I)
	/// Called when something cancels the surgery.
	proc/on_cancel(mob/user, obj/item/I, quiet, forced = FALSE)

/datum/surgery_step
	var/tool_flags_required = 0 //! Flags for tools that are accepted for this step
	var/tool_types_required = list() //! Explicit tools required, alongside their failure chance, if you want ghetto analogs
	var/allow_no_tool = FALSE //! Whether this step can be performed without a tool, if the tool requirements are met.
	var/step_number = 0 //! The step number in the surgery. Set by the surgery when added. '0' means the step can be performed at any time.
	var/name = "Base surgery step"
	var/desc = "Call 0118-999-881-999-IMCODER-3."
	var/icon_state = "scissor"
	var/success_sound = 'sound/items/Scissor.ogg'
	var/optional = FALSE //! Whether this step is optional
	var/visible = TRUE //! Whether this step is visible
	var/datum/surgery/parent_surgery = null //! The surgery this step is a part of
	var/hide_when_completed = TRUE //! Whether this step should be hidden when completed
	var/completed = FALSE //! Whether this step is completed
	var/failure_chance = 0 //! Flat chance of failure for this step, before modifiers. People with no training will always raise to 5%
	var/can_fail = TRUE //! Whether this step can fail
	var/success_damage = 15 //! The damage this step deals on success
	var/success_damage_variance = 5 //! The variance of the damage dealt on success
	var/fail_damage = 25 //! The damage dealt by this step on failure
	var/fail_damage_variance = 5 //! How much this damage can vary, positive and negative.
	var/damage_type = DAMAGE_CUT
	var/repeatable = FALSE //! Whether this step can be repeated. If TRUE, the step won't automatically be marked as completed.

	New(datum/surgery/parent_surgery)
		src.parent_surgery = parent_surgery
		..()


	/// Attempts to perform this surgery step with the given tool. Returns TRUE on success, FALSE on failure.
	proc/attempt_surgery_step(mob/surgeon, obj/item/tool, from_context_menu=FALSE)
		if (parent_surgery.super_surgery && !parent_surgery.super_surgery.surgery_complete())
			return FALSE
		if (!can_operate(surgeon, tool, FALSE))
			if (from_context_menu)
				parent_surgery.show_contexts(surgeon)
			return FALSE
		if (special_fumble(surgeon, tool))
			if (from_context_menu)
				parent_surgery.show_contexts(surgeon)
			return FALSE

		var/mess_up_odds = calculate_failure_chance(surgeon,tool)
		if (surgeon.a_intent == INTENT_DISARM && can_fail)
			if (from_context_menu)
				parent_surgery.show_contexts(surgeon)
			boutput(surgeon, SPAN_NOTICE("You mess up [parent_surgery.patient]'s surgery on purpose."))
			on_mess_up(surgeon,tool, forced=TRUE)
			return FALSE
		else if (can_fail && prob(mess_up_odds))
			if (from_context_menu)
				parent_surgery.show_contexts(surgeon)
			on_mess_up(surgeon,tool)
			return FALSE

		var/success = do_surgery_step(surgeon, tool)
		if (success)
			if (success_damage > 0)
				var/dealt_damage = max(0,rand(success_damage-success_damage_variance, success_damage+success_damage_variance))
				parent_surgery.patient.TakeDamage("chest",dealt_damage,0,damage_type=damage_type)
				if (damage_type in list(DAMAGE_CRUSH,DAMAGE_CUT,DAMAGE_STAB))
					take_bleeding_damage(parent_surgery.patient, tool.the_mob, damage = dealt_damage, damage_type = damage_type, surgery_bleed = TRUE)

			if (success_sound)
				playsound(parent_surgery.patient, success_sound, 50, TRUE)
			on_complete(surgeon, tool)
			complete(surgeon, tool)
		parent_surgery.step_attempted(src,surgeon, tool)
		return success

	/// Returns a random mess-up text for this surgery step based on the tool used.
	proc/get_mess_up_text(damage, obj/item/tool)
		var/list/messup_texts
		if (tool_flags_required)
			if (tool_flags_required & TOOL_CUTTING)
				messup_texts = list(" messes up", "'s hand slips", " fumbles with [tool]", " nearly drops [tool]", "'s hand twitches", " makes a really messy cut")
			else if (tool_flags_required & TOOL_SAWING)
				messup_texts = list(" messes up", "'s hand slips", " fumbles with [tool]", " nearly drops [tool]", "'s hand twitches", " nicks an artery")
			else if (tool_flags_required & TOOL_SPOONING)
				messup_texts = list(" messes up", "'s hand slips", " fumbles with [tool]", " nearly drops [tool]", "'s hand twitches", " jabs [tool] in too far")
			else if (tool_flags_required & TOOL_SNIPPING)
				messup_texts = list(" messes up", "'s hand slips", " fumbles with [tool]", " nearly drops [tool]", "'s hand twitches", "gets [tool] stuck")
		else
			if (istype(tool, /obj/item/suture))
				messup_texts = list(" messes up", " fumbles with [tool]", " nearly drops [tool]", "'s hand twitches", " knots up [tool]")
			else if (istype(tool, /obj/item/staple_gun))
				messup_texts = list(" messes up", " fumbles with [tool]", " nearly drops [tool]", "'s hand twitches", " jams [tool]")

		if (!messup_texts)
			messup_texts = list(" messes up", "'s hand slips", "'s hand twitches")
		return pick(messup_texts)

	// Check if a specific tool is explicitly required for this step
	proc/tool_path_required(obj/item/tool)
		if (length(tool_types_required) == 0)
			return TRUE
		for(var/type in tool_types_required)
			if (istype(tool,type))
				return TRUE

	// Check if the tool is relevant for this surgery step
	proc/tool_relevant(mob/surgeon, obj/item/tool)
		if (tool)
			var/flags_suitable = (!tool_flags_required || tool?.tool_flags & tool_flags_required)
			var/type_suitable = tool_path_required(tool)
			var/custom_suitable = tool_suitable(surgeon, tool)
			return flags_suitable && type_suitable && custom_suitable
		else if (allow_no_tool)
			return TRUE
		return FALSE

	// Checks if the surgeon can perform this surgery step with the given tool.
	proc/can_operate(mob/surgeon, obj/item/tool, quiet = TRUE)
		if (completed)
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
			if (tool_relevant(surgeon, tool))
				return TRUE
			else
				if (!quiet)
					if (tool_flags_required)
						boutput(surgeon,SPAN_ALERT(get_flag_message()))
					else
						boutput(surgeon,SPAN_ALERT("You need a tool for this step!"))
				return FALSE
		if (tool_relevant(surgeon, tool))
			return TRUE
		else
			if (!quiet)
				if ((tool_flags_required && !(tool?.tool_flags & tool_flags_required)))
					boutput(surgeon,SPAN_ALERT(get_flag_message()))
				else
					boutput(surgeon,SPAN_ALERT("You can't use that tool for this step."))
			return FALSE


	/// Calculates the chance of failure for this surgery step with the given tool.
	proc/calculate_failure_chance(mob/surgeon, obj/item/tool)
		var/screw_up_prob = failure_chance
		var/mob/living/patient = parent_surgery.patient
		if (!patient) // did we not get passed a patient?
			return FALSE // uhhh
		if (!ishuman(patient)) // is the patient not a human?
			return FALSE // welp vOv

		if (surgeon.bioHolder.HasEffect("clumsy")) // is the surgeon clumsy?
			screw_up_prob += 35
		if (patient == surgeon) // is the patient doing self-surgery?
			screw_up_prob += 15
		if (patient.jitteriness) // is the patient all twitchy?
			screw_up_prob += 15
		if (surgeon.reagents)
			var/drunken_surgeon = surgeon.reagents.get_reagent_amount("ethanol") // has the surgeon had a drink (or two (or three (or four (etc))))?
			if (drunken_surgeon > 0 && drunken_surgeon < 5) // it steadies the hand a bit
				screw_up_prob -= 10
			else if (drunken_surgeon >= 5) // but too much and that might be bad
				screw_up_prob += 10
				if(surgeon.traitHolder.hasTrait("training_partysurgeon") && drunken_surgeon >= 100)
					screw_up_prob = 0 //ayyyyy

		if (patient.stat) // is the patient dead?
			screw_up_prob -= 30
		if (patient.getStatusDuration("unconscious")) // unable to move?
			screw_up_prob -= 15
		if (patient.sleeping) // asleep?
			screw_up_prob -= 10
		if (patient.getStatusDuration("stunned")) // stunned?
			screw_up_prob -= 5
		if (patient.hasStatus("drowsy")) // sleepy?
			screw_up_prob -= 5

		if (patient.reagents) // check for anesthetics/analgetics
			if (patient.reagents.get_reagent_amount("morphine") >= 10)
				screw_up_prob -= 10
			if (patient.reagents.get_reagent_amount("haloperidol") >= 10)
				screw_up_prob -= 10
			if (patient.reagents.get_reagent_amount("ethanol") >= 5)
				screw_up_prob -= 5
			if (patient.reagents.get_reagent_amount("salicylic_acid") >= 5)
				screw_up_prob -= 5
			if (patient.reagents.get_reagent_amount("antihistamine") >= 5)
				screw_up_prob -= 5

		if (surgeon.traitHolder.hasTrait("training_medical"))
			screw_up_prob = clamp(screw_up_prob, 0, 100) // if they're a doctor they can have no chance to mess up
		else
			screw_up_prob = clamp(screw_up_prob, 5, 100) // otherwise there'll always be a slight chance

		DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) has screw_up_prob set to [screw_up_prob]</b>")
		return screw_up_prob

	/// Mark this step as completed. It's better to override on_complete unless you know what you're doing.
	proc/complete(mob/user, obj/item/tool)
		if (!repeatable)
			completed = TRUE
		parent_surgery.step_completed(user, tool)

	proc/cancel(mob/surgeon, mob/I)
		completed = FALSE

	proc/get_context(var/locked) //! Get the context icon for this step
		if (completed && hide_when_completed || !visible)
			return null
		var/datum/contextAction/surgical_step/step_context = new
		step_context.name = name
		step_context.desc = desc
		step_context.icon_state = icon_state
		step_context.step = src
		step_context.surgery = parent_surgery
		if (completed)
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
		if (tool_flags_required & TOOL_CHOPPING)
			return "You need a chopping tool for this step!"
		else if (tool_flags_required & TOOL_SCREWING)
			return "You need a screwing tool for this step!"
		else if (tool_flags_required & TOOL_CUTTING)
			return "You need a cutting tool for this step!"
		else if (tool_flags_required & TOOL_CLAMPING)
			return "You need a clamp for this step!"
		else if (tool_flags_required & TOOL_PRYING)
			return "You need a prying tool for this step!"
		else if (tool_flags_required & TOOL_PULSING)
			return "You need a pulsing tool for this step!"
		else if (tool_flags_required & TOOL_SAWING)
			return "You need a sawing tool for this step!"
		else if (tool_flags_required & TOOL_SCREWING)
			return "You need a screwing tool for this step!"
		else if (tool_flags_required & TOOL_SPOONING)
			return "You need a spooning tool for this step!"
		else if (tool_flags_required & TOOL_SNIPPING)
			return "You need a snipping tool for this step!"
		else if (tool_flags_required & TOOL_WELDING)
			return "You need a welding tool for this step!"
		else if (tool_flags_required	& TOOL_WRENCHING)
			return "You need a wrenching tool for this step!"
		else if (tool_flags_required & TOOL_SOLDERING)
			return "You need a soldering tool for this step!"
		else if (tool_flags_required & TOOL_WIRING)
			return "You need wires for this step!"
		else
			return "You can't use that tool for this step."

	///-- STUFF YOU MIGHT WANT TO OVERRIDE/EXTEND:
	/// Called when the surgery step fails.
	proc/on_mess_up(mob/surgeon, obj/item/tool, forced = FALSE)
		var/damage_value = max(0,rand(fail_damage-fail_damage_variance, fail_damage+fail_damage_variance))
		if (forced)
			damage_value = rand(15,25)
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon][get_mess_up_text(damage_value,tool)]!</b>"))
		parent_surgery.patient.TakeDamage(parent_surgery.affected_zone, damage_value, 0)
		take_bleeding_damage(parent_surgery.patient, surgeon, damage_value, surgery_bleed = TRUE)
		create_blood_sploosh(parent_surgery.patient)
		display_slipup_image(surgeon, parent_surgery.patient.loc)
		return

	/// If types and/or tool flags aren't enough - override this to determine if the provided tool is suitable for this surgery step.
	/// NOTE: If the tool is 'correct' but missing something like ammo or charge, this should be TRUE.
	/// Instead, return the error message in the step's 'do_surgery_step()'!
	proc/tool_suitable(mob/surgeon, obj/item/tool)
		return TRUE

	/// Perform the surgery step. return TRUE if successful.
	/// This is performed AFTER checking for fuck-ups.
	proc/do_surgery_step(mob/surgeon, obj/item/tool)
		return TRUE

	/// Override this to add completion effects to this surgery step.
	proc/on_complete(mob/user, obj/item/tool)

	proc/on_cancel(mob/surgeon, obj/item/I, var/from_context_menu = FALSE, var/forced = FALSE)


	/// Handles the old clown fumbles.
	proc/special_fumble(mob/surgeon, obj/item/tool)
		if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
			if (tool_flags_required)
				if (tool_flags_required & TOOL_CUTTING)
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [tool]!"), \
					SPAN_ALERT("You fumble and stab yourself in the eye with [tool]!"))
					surgeon.bioHolder.AddEffect("blind")
					surgeon.changeStatus("knockdown", 4 SECONDS)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(5, 15)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, null, damage)
					return TRUE

				if (tool_flags_required & TOOL_SAWING )
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> mishandles [tool] and cuts [him_or_her(surgeon)]self!"),\
					SPAN_ALERT("You mishandle [tool] and cut yourself!"))
					surgeon.changeStatus("knockdown", 1 SECOND)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(10, 20)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, damage)
					return TRUE
				if (tool_flags_required & TOOL_SNIPPING )
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [tool]!"), \
					SPAN_ALERT("You fumble and stab yourself in the eye with [tool]!"))
					surgeon.bioHolder.AddEffect("blind")
					surgeon.changeStatus("knockdown", 0.4 SECONDS)

					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(5, 15)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, null, damage)
					return TRUE
				if (tool_flags_required & TOOL_PRYING)
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and clubs [him_or_her(surgeon)]self upside the head with [tool]!"), \
					SPAN_ALERT("You fumble and club yourself in the head with [tool]!"))
					surgeon.changeStatus("knockdown", 0.4 SECONDS)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(5, 15)
					random_brute_damage(surgeon, damage)
					return TRUE
				if (tool_flags_required & TOOL_CAUTERY)
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> burns [him_or_her(surgeon)]self with [tool]!"),\
					SPAN_ALERT("You burn yourself with [tool]"))

					JOB_XP(surgeon, "Clown", 1)
					surgeon.changeStatus("knockdown", 4 SECONDS)
					var/damage = rand(5, 15)
					random_burn_damage(surgeon, damage)
					return TRUE

			else if (istype(tool, /obj/item/suture))
				if (surgeon.bioHolder.HasEffect("clumsy") && prob(33))
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> pricks [his_or_her(surgeon)] finger with [tool]!"),\
					SPAN_ALERT("You prick your finger with [tool]"))

					//surgeon.bioHolder.AddEffect("blind") // oh my god I'm the biggest idiot ever I forgot to get rid of this part
					// I'm not deleting it I'm just commenting it out so my shame will be eternal and perhaps future generations of coders can learn from my mistake
					// - Haine
					surgeon.changeStatus("knockdown", 4 SECONDS)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(1, 10)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, damage)
					return TRUE
		return FALSE
