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
	var/list/current_sub_surgeries
	var/list/default_sub_surgeries
	/// If FALSE, sub surgeries are inaccessible until steps are completed.
	var/sub_surgeries_always_possible = FALSE
	/// If TRUE, the surgery will be exited when finished, placing the user up 1 level.
	var/exit_when_finished = FALSE
	/// If TRUE, this surgery will automatically be performed when
	/// the user is hit with a tool that allows surgery_possible() and can_operate().
	var/implicit = FALSE

	/// Roughly the part of the body this surgery is performed on. Used for cancelling surgeries.
	var/affected_zone = "chest"

	var/last_surgery_step = 0 //! The last step ID added, used for sequencing steps.
	var/complete = FALSE //! If TRUE, the surgery is complete and will show as green.
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
		last_surgery_step = 0
		generate_surgery_steps()

	/// Create the default sub-surgeries for this surgery
	proc/populate_sub_surgeries()
		for(var/surgery in default_sub_surgeries)
			current_sub_surgeries += new surgery(patient, holder, src)

	/// Adds a step to the surgery that can only be performed after the previous step(s) are complete.
	proc/add_next_step(datum/surgery_step/step)
		last_surgery_step++
		step.step_number = last_surgery_step
		surgery_steps += step

	/// Adds a step to the surgery that can be performed at the same time as the previous step.
	proc/add_simultaneous_step(datum/surgery_step/step)
		step.step_number = last_surgery_step
		surgery_steps += step

	/// Adds a step to the surgery that can be performed anytime.
	proc/add_free_step(datum/surgery_step/step)
		step.step_number = 0
		surgery_steps += step


	// ----------
	// Internal Surgery logic
	// ----------


	/// Perform a given step with a given tool.
	proc/perform_step(datum/surgery_step/step, mob/surgeon, obj/item/tool)
		step.perform_step(surgeon, tool)

	/// Check if any steps are possible on the target using the given tool. Return the first possible step.
	proc/surgery_step_possible(mob/surgeon, obj/item/tool)
		var/list/completed_ids = list()
		completed_ids += TRUE // Simultaneous steps are always complete

		// Create a list, where each index is the step number, and the value is whether all steps matching that step number are complete
		for(var/datum/surgery_step/step in surgery_steps)
			if (step.step_number == 0)
				continue
			while (length(completed_ids)-1 < step.step_number)
				completed_ids += TRUE
			completed_ids[step.step_number] = (completed_ids[step.step_number] && step.finished)

		// Some steps will be completed out of order, due to being unnecessary etc.
		// Find the highest consecutive step number that is complete.
		var/max_step_number = 0
		for (var/i=1, i <= length(completed_ids), i++)
			if (completed_ids[i])
				max_step_number = i
			else
				break
		max_step_number++

		// Now check if any steps are possible with the given tool, at this point in time.
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.step_number <= max_step_number)
				if (!step.finished && step.can_operate(surgeon, tool))
					return step
		return FALSE

	/// Called when the last step of a surgery is completed. Override on_complete to handle completion.
	proc/complete_surgery(mob/surgeon, obj/item/I)
		complete = TRUE
		on_complete(surgeon, I)
		if (exit_when_finished && !implicit)
			super_surgery?.enter_surgery(surgeon)
		else if (!implicit)
			enter_surgery(surgeon)


	/// Cancel the surgery. Override on_cancel to handle cancellation.
	proc/cancel_surgery(mob/surgeon, obj/item/I, var/from_context = FALSE, var/quiet = TRUE)
		if (!istype(I, /obj/item/suture) && !istype(I, /obj/item/staple_gun))
			boutput(surgeon, SPAN_ALERT("You need a suture or staple gun to cancel surgery!"))
			return
		if (istype(I, /obj/item/staple_gun))
			var/obj/item/staple_gun/stapler = I
			if (stapler.ammo < 1)
				boutput(surgeon, SPAN_ALERT("Your staple gun is out of staples!"))
				return
			stapler.ammo--
		on_cancel(surgeon, I, quiet=quiet)
		complete = FALSE
		for(var/datum/surgery_step/step in surgery_steps)
			step.finished = FALSE
		for(var/datum/surgery/surgery in current_sub_surgeries)
			surgery.cancel_surgery(surgeon, I, quiet=TRUE)
		if (from_context)
			super_surgery?.enter_surgery(surgeon)


	/// If this surgery is implicit, attempt to complete a step with this tool. If complete, attempt to complete a sub-surgery step.
	proc/do_shortcut(mob/surgeon, obj/item/I)
		if ((!super_surgery || super_surgery?.complete) && implicit && can_perform_surgery(surgeon, I))
			var/datum/surgery_step/step = surgery_step_possible(surgeon, I)
			if (step)
				step.perform_step(surgeon, I)
				return TRUE
		if (sub_surgery_possible(surgeon)) // only attempt subsurgeries if this surgery is done.
			// do the next implicit step if subsurgeries are implicit
			for(var/datum/surgery/surgery in current_sub_surgeries)
				surgery.infer_surgery_stage()
				if (surgery.do_shortcut(surgeon, I))
					return TRUE
		return FALSE

	/// Can this step be performed - Are all previous steps complete?
	proc/step_accessible(datum/surgery_step/chosen_step)
		if (chosen_step.step_number == 0)
			return TRUE
		var/steps_complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished)
				steps_complete = max (step.step_number, steps_complete)
		return (chosen_step.step_number-1) <= steps_complete


	/// Called when a step is completed. Handles if the surgery is complete and re-entering the surgery UI.
	proc/step_completed(datum/surgery_step/step, mob/user, obj/item/tool)
		if (surgery_complete())
			complete_surgery(user, tool)
		else if (!implicit)
			enter_surgery(user)


	/// Determine if this surgery is possible on the target.
	proc/can_perform_surgery(mob/living/surgeon, obj/item/tool)
		return surgery_conditions_met(surgeon, tool) && surgery_possible(surgeon)

	// ----------
	// UI Interaction
	// ----------

	/// Called when the surgery's context icon is clicked.
	proc/surgery_clicked(mob/living/surgeon, obj/item/I)
		if (super_surgery && !super_surgery.complete)
			super_surgery.enter_surgery(surgeon)
		else
			enter_surgery(surgeon)

	/// Called when the surgery's context menu is entered.
	proc/enter_surgery(mob/surgeon, obj/item/tool)
		infer_surgery_stage()
		if (super_surgery && !super_surgery.complete) // hop up a level if this surgery is no longer accessible
			super_surgery.enter_surgery(surgeon)
		else
			var/contexts = get_surgery_contexts(surgeon, tool)
			surgeon.showContextActions(contexts, patient, new /datum/contextLayout/experimentalcircle)

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

	/// Gets the context actions for this surgeries's steps.
	proc/get_surgery_contexts(surgeon, obj/item/tool, var/add_navigation = TRUE)
		var/list/datum/contextAction/surgical_step/contexts = list()
		var/completed_stages = 0
		var/optional_contexts = list()

		if (!implicit)
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
		if (sub_surgery_possible(surgeon, tool))
			for (var/datum/surgery/surgery in current_sub_surgeries)
				if (surgery.can_perform_surgery(surgeon, tool) && surgery.visible)
					contexts += surgery.get_context()

		//hacky fix to remove the back button if there's only one top-level surgery available.
		//Keeps contexts looking identical to older code.
		if (add_navigation)
			if (super_surgery != null || length(holder.get_contexts(surgeon)) > 1)
				contexts += new /datum/contextAction/surgery/step_up(holder, src)

			if (cancel_possible() && get_surgery_progress() > 0)
				contexts += new/datum/contextAction/surgery/cancel(holder,src)

		//place the always-optional steps to the left of the top step.
		contexts += optional_contexts

		return contexts

	// ----------
	// Getters
	// ----------

	/// Check if all steps are complete.
	proc/surgery_complete()
		for(var/datum/surgery_step/step in surgery_steps)
			if(!step.optional && !step.finished)
				return FALSE
		return TRUE

	/// Get all sub surgeries, including their sub-surgeries, etc.
	proc/get_sub_surgeries()
		var/list/datum/surgery/response = list()
		for(var/datum/surgery/surgery in current_sub_surgeries)
			response += surgery
			response += surgery.get_sub_surgeries()
		return current_sub_surgeries

	/// Get the progress of the surgery. Returns how many non-optional steps are complete.
	proc/get_surgery_progress()
		var/complete = 0
		for (var/datum/surgery_step/step in surgery_steps)
			if (step.finished && !step.optional)
				complete++
		return complete

	// ----------
	// Surgery logic
	// ----------

	/// Returns true if sub surgeries are possible.
	proc/sub_surgery_possible(mob/surgeon, obj/item/I)
		return (sub_surgeries_always_possible || complete)

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


	/// Calculate how much damage should be multiplied by, when being performed.
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

	proc/cancel_possible()
		return (get_surgery_progress() > 0)

	//-----
	// Hooks
	//-----

	/// Determine which steps are already complete based upon the patient's current state.
	proc/infer_surgery_stage()

	///Create & add the surgery steps for this surgery
	proc/generate_surgery_steps()

	///Whether this surgery is possible on the target - Otherwise, will be hidden from the context menu
	proc/surgery_possible()
		return TRUE

	/// Called on completion of the surgery.
	proc/on_complete(mob/surgeon, obj/item/I)
	/// Called when something cancels the surgery.
	proc/on_cancel(mob/user, obj/item/I, quiet)

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
	var/success_chance = 90 //! The chance of success for this step, before modifiers
	var/repeatable = FALSE //! Whether this step can be repeated. If TRUE, the step won't automatically be marked as finished.
	var/damage_dealt = 5 //! The damage dealt by this step
	var/damage_type = DAMAGE_CUT
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

	proc/calculate_failure_chance(mob/surgeon, obj/item/tool)
		var/screw_up_prob = 0
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

	///Calculate if this step succeeds, apply failure effects here
	proc/attempt_surgery_step(mob/surgeon, obj/item/tool)
		if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
			if (flags_required)
				if (flags_required & TOOL_CUTTING)
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!"), \
					SPAN_ALERT("You fumble and stab yourself in the eye with [src]!"))
					surgeon.bioHolder.AddEffect("blind")
					surgeon.changeStatus("knockdown", 4 SECONDS)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(5, 15)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, null, damage)

				if (flags_required & TOOL_SAWING )
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> mishandles [src] and cuts [him_or_her(surgeon)]self!"),\
					SPAN_ALERT("You mishandle [src] and cut yourself!"))
					surgeon.changeStatus("knockdown", 1 SECOND)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(10, 20)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, damage)
					return FALSE
				if (flags_required & TOOL_SNIPPING )
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!"), \
					SPAN_ALERT("You fumble and stab yourself in the eye with [src]!"))
					surgeon.bioHolder.AddEffect("blind")
					surgeon.changeStatus("knockdown", 0.4 SECONDS)

					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(5, 15)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, null, damage)
					return FALSE
				if (flags_required & TOOL_PRYING)
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and clubs [him_or_her(surgeon)]self upside the head with [src]!"), \
					SPAN_ALERT("You fumble and club yourself in the head with [src]!"))
					surgeon.changeStatus("knockdown", 0.4 SECONDS)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(5, 15)
					random_brute_damage(surgeon, damage)
					return FALSE
				if (flags_required & TOOL_CAUTERY)
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> burns [him_or_her(surgeon)]self with [src]!"),\
					SPAN_ALERT("You burn yourself with [src]"))

					JOB_XP(surgeon, "Clown", 1)
					surgeon.changeStatus("knockdown", 4 SECONDS)
					var/damage = rand(5, 15)
					random_burn_damage(surgeon, damage)
					return FALSE

			else if (istype(tool, /obj/item/suture))
				if (surgeon.bioHolder.HasEffect("clumsy") && prob(33))
					surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> pricks [his_or_her(surgeon)] finger with [src]!"),\
					SPAN_ALERT("You prick your finger with [src]"))

					//surgeon.bioHolder.AddEffect("blind") // oh my god I'm the biggest idiot ever I forgot to get rid of this part
					// I'm not deleting it I'm just commenting it out so my shame will be eternal and perhaps future generations of coders can learn from my mistake
					// - Haine
					surgeon.changeStatus("knockdown", 4 SECONDS)
					JOB_XP(surgeon, "Clown", 1)
					var/damage = rand(1, 10)
					random_brute_damage(surgeon, damage)
					take_bleeding_damage(surgeon, damage)
					return FALSE

		var/mess_up_odds = calculate_failure_chance(surgeon,tool)
		if (prob(mess_up_odds))
			on_mess_up(surgeon,tool)
			boutput(world, "mess up")
			return FALSE

		var/success = do_surgery_step(surgeon, tool)
		if (success && damage_dealt > 0)
			parent_surgery.patient.TakeDamage("chest",damage_dealt,0,damage_type=damage_type)
			if (damage_type in list(DAMAGE_CRUSH,DAMAGE_CUT,DAMAGE_STAB))
				take_bleeding_damage(parent_surgery.patient, tool.the_mob, damage = damage_dealt, damage_type = damage_type, surgery_bleed = TRUE)
		return success

	proc/on_mess_up(mob/surgeon, obj/item/tool)
		return

	proc/perform_step(mob/surgeon, obj/item/tool) //! Perform the surgery step
		if (parent_surgery.super_surgery && !parent_surgery.super_surgery.surgery_complete())
			return FALSE
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
		if (!repeatable)
			finished = TRUE
		parent_surgery.step_completed(src, user, tool)

	/// Perform the surgery step. return TRUE if successful.
	proc/do_surgery_step(mob/surgeon, obj/item/tool)
		return TRUE

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
		step_context.surgery = parent_surgery
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
