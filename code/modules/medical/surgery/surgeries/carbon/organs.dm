/datum/surgery/carbon/category/organ
	id = "torso_surgery"
	name = "Torso Surgery"
	desc = "Modify the patients' torso and organs."
	icon_state = "torso"
	affected_zone = "chest"
	implicit = TRUE
	default_sub_surgeries = list(/datum/surgery/carbon/ribs, /datum/surgery/carbon/subcostal, /datum/surgery/carbon/flanks,
	/datum/surgery/carbon/abdomen, /datum/surgery/carbon/item, /datum/surgery/carbon/chest_clamp)
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/chest/cut(src))
		src.add_next_step(new /datum/surgery_step/fluff/snip(src))

	surgery_possible(mob/living/surgeon)
		if (surgeon.a_intent == INTENT_GRAB) // we're doing tail/butt surgery
			return FALSE
		return ..()
	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet && surgeon)
			var/action = "sew"
			if (istype(tool, /obj/item/staple_gun))
				action = "staple"
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> [action]s the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest closed with [tool]."),\
				SPAN_NOTICE("You [action] the incision on [surgeon == patient ? "your" : "[patient]'s"] chest closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You [action]" : "<b>[surgeon]</b> [action]s"] the incision on your chest closed with [tool]."))
	get_desc(show_vague)
		var/t_his = his_or_her(patient)
		var/Noun = capitalize(t_his)
		var/noun_s = show_vague ? t_his : "[patient.name]'s" // lowercase, for middle of description
		var/Noun_s = show_vague ? capitalize(t_his) : "[patient.name]'s"
		var/steps_complete = src.get_surgery_progress()
		if (complete)
			if (patient.organHolder.heart)
				. += "<br>[SPAN_ALERT("<B>[Noun_s]'s chest is cut wide open!</B>")]"
			else
				. += "<br>[SPAN_ALERT("<B>[Noun_s] chest is cut wide open and [t_his] heart has been removed!</B>")]"
		else if (steps_complete > 0)
			. += "<br>[SPAN_ALERT("<B>[Noun] has an indeterminate number of small surgical scars on [t_his] chest!</B>")]"

/datum/surgery/carbon/chest_clamp
	id = "chest_clamp"
	name = "Chest Clamp"
	desc = "Clamp the patient's chest"
	icon_state = "chest_clamp"
	affected_zone = "chest"
	implicit = TRUE
	visible = FALSE
	generate_surgery_steps()
		src.add_simultaneous_step(new /datum/surgery_step/chest/clamp(src))

	surgery_possible(mob/living/surgeon)
		var/mob/living/carbon/human/C = patient
		return C.chest_cavity_clamped == FALSE

	get_desc(show_vague)
		var/t_his = his_or_her(patient)
		var/noun_s = show_vague ? t_his : "[patient.name]'s" // lowercase, for middle of description
		if (!complete)
			. += "<br>[SPAN_ALERT("<B>Blood is slowly seeping out of [noun_s] un-clamped chest wound.</B>")]"

/datum/surgery/carbon/category/head
	id = "head_surgery"
	name = "Head Surgery"
	desc = "Perform surgery on the patient's head"
	default_sub_surgeries = list(
		/datum/surgery/carbon/organ/head/eye/left, /datum/surgery/carbon/organ_replace/eye/left,
		/datum/surgery/carbon/organ/head/eye/right, /datum/surgery/carbon/organ_replace/eye/right,
		/datum/surgery/carbon/organ/head/brain, /datum/surgery/carbon/organ_replace/brain,
		/datum/surgery/carbon/organ/head/head, /datum/surgery/carbon/organ_replace/head,
		/datum/surgery/carbon/cauterize/head)
	visible = FALSE
	implicit = TRUE
	affected_zone = "head"
	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head closed with [tool]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] head closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your head closed with [tool]."))



/datum/surgery/carbon/ribs
	id = "rib_surgery"
	name = "Rib Surgery"
	desc = "Open the patient's ribcage"
	icon_state = "ribs"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/carbon/organ/heart, /datum/surgery/carbon/organ_replace/heart,
	/datum/surgery/carbon/organ/left_lung, /datum/surgery/carbon/organ_replace/left_lung,
	/datum/surgery/carbon/organ/right_lung, /datum/surgery/carbon/organ_replace/right_lung)
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/fluff/cut(src))
		src.add_next_step(new /datum/surgery_step/fluff/saw(src))
		src.add_next_step(new /datum/surgery_step/fluff/snip(src))

	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet && surgeon)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] ribcage closed with [tool]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] ribcage closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your ribcage closed with [tool]."))
/datum/surgery/carbon/subcostal
	id = "subcostal"
	name = "Subcostal"
	desc = "Open the subcostal region"
	icon_state = "subcostal"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/carbon/organ/liver, /datum/surgery/carbon/organ_replace/liver,
	/datum/surgery/carbon/organ/spleen, /datum/surgery/carbon/organ_replace/spleen,
	/datum/surgery/carbon/organ/pancreas, /datum/surgery/carbon/organ_replace/pancreas)
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/fluff/cut(src))
		src.add_next_step(new /datum/surgery_step/fluff/snip(src))

	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet && surgeon)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] subcostal region closed with [tool]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] subcostal region closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your subcostal region closed with [tool]."))


/datum/surgery/carbon/flanks
	id = "flank_surgery"
	name = "Flank Surgery"
	desc = "Open the patient's flanks"
	icon_state = "flanks"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/carbon/organ/left_kidney, /datum/surgery/carbon/organ_replace/left_kidney,
	/datum/surgery/carbon/organ/right_kidney, /datum/surgery/carbon/organ_replace/right_kidney)
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/fluff/cut(src))
		src.add_next_step(new /datum/surgery_step/fluff/snip(src))

	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet && surgeon)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] flank closed with [tool]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] flank closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your flank closed with [tool]."))
/datum/surgery/carbon/abdomen
	id = "abdomen_surgery"
	name = "Abdomen Surgery"
	desc = "Open the patient's abdomen"
	icon_state = "abdominal"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/carbon/organ/stomach, /datum/surgery/carbon/organ_replace/stomach,
	/datum/surgery/carbon/organ/intestine, /datum/surgery/carbon/organ_replace/intestine,
	/datum/surgery/carbon/organ/appendix, /datum/surgery/carbon/organ_replace/appendix)
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/fluff/cut(src))
		src.add_next_step(new /datum/surgery_step/fluff/snip(src))


	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet && surgeon)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] abdomen closed with [tool]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] abdomen closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your abdomen closed with [tool]."))


/datum/surgery/carbon/category/lower_back
	id = "lower_back_surgery"
	name = "Lower Back Surgery"
	desc = "Remove the patients' tail or butt."
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/carbon/organ/butt, /datum/surgery/carbon/organ_replace/butt,
		/datum/surgery/carbon/organ/tail, /datum/surgery/carbon/organ_replace/tail
	)
	implicit = TRUE
	visible = FALSE
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/fluff/back_cut(src))
		src.add_next_step(new /datum/surgery_step/fluff/back_saw_butt(src))
		src.add_next_step(new /datum/surgery_step/fluff/back_cut_intestine(src))
	surgery_possible(mob/living/surgeon)
		if (surgeon?.a_intent != INTENT_GRAB)
			return FALSE
		return ..()

	on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
		if (!quiet)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] lower back closed with [tool]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] lower back closed with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your lower back closed with [tool]."))

	get_desc()
		var/steps_complete = src.get_surgery_progress()
		var/t_his = his_or_her(patient)
		var/Noun = capitalize(t_his)
		if (steps_complete > 0) // first person to call this a tailhole is getting dropkicked into the sun
			if (patient.mob_flags & SHOULD_HAVE_A_TAIL)
				if (!patient.organHolder.tail)
					if (!patient.organHolder.butt) // Also missing a butt?
						. += "<br>[SPAN_ALERT("<B>[patient.name] has a large incision at the base of [t_his] back where [t_his] tail should be!</B>")]"
					else // has butt
						. += "<br>[SPAN_ALERT("<B>[patient.name] has a large incision above [t_his] butt where [t_his] tail should be!</B>")]"
				else
					if (complete && patient.mob_flags & ~IS_BONEY) // assive ass wound? and not a skeleton?
						. += "<br>[SPAN_ALERT("<B>[Noun] has a long incision around the base of [t_his] tail!</B>")]"
			else // Do they normally not have a tail?
				if (!patient.organHolder.butt) // Also missing a butt?
					. += "<br>[SPAN_ALERT("<B>[patient.name] has a large incision at the base of [t_his] back!</B>")]"
				else // has butt
					. += "<br>[SPAN_ALERT("<B>[patient.name] has a large incision above [t_his] butt!</B>")]"

/datum/surgery/carbon/organ
	id = "base_organ_surgery"
	name = "Base Organ Surgery"
	desc = "Call a coder if you see this!"
	icon_state = "heart"
	var/organ_var_name = "thing"
	var/organ_pretty_name
	exit_when_completed = TRUE

	affected_zone = "chest"

	surgery_possible(mob/living/surgeon)
		if (implicit && surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (patient.organHolder.get_organ(organ_var_name))
			return TRUE
		return FALSE

	on_cancel(mob/living/surgeon, obj/item/tool, quiet, forced = FALSE)
		var/obj/O = patient.organHolder.vars[organ_var_name]

		var/organ_name = organ_pretty_name? organ_pretty_name : organ_var_name
		if (O)
			if (!quiet && surgeon)
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> secures [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [organ_name] back into place with [tool]."),\
				SPAN_NOTICE("You secure [surgeon == patient ? "your" : "[patient]'s"] [organ_name] back into place with [tool]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your [organ_name] back  into place closed with [tool]."))

	on_complete(mob/surgeon, obj/item/I)
		var/obj/item/organ/O = patient.organHolder.vars[organ_var_name]
		surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> takes out [surgeon == patient ? "[his_or_her(patient)]" : "[patient]'s"] [O.name]."),\
			SPAN_NOTICE("You take out [surgeon == patient ? "your" : "[patient]'s"] [O.name]."),\
			SPAN_ALERT("[patient == surgeon ? "You take" : "<b>[surgeon]</b> takes"] out your [O.name]!"))
		logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [organ_var_name].")
		patient.organHolder.drop_organ(organ_var_name)
		. = ..()
		// Re-open context buttons for the surgeon, so the replaced organ shows up for surgery again.
		for (var/atom/movable/screen/contextButton/C in surgeon.contextButtons)
			if (istype(C.action, /datum/contextAction/surgery))
				var/datum/contextAction/surgery/surgeryAction = C.action
				if (surgeryAction.surgery.super_surgery == src.super_surgery)
					surgeon.closeContextActions()
					src.super_surgery.show_contexts(surgeon, I)



	generate_surgery_steps()
		src.add_free_step(new /datum/surgery_step/organ/grab(src, organ_var_name))
		src.add_next_step(new /datum/surgery_step/organ/cut(src, organ_var_name)) // Makes the organ count as 'in surgery'
		src.add_next_step(new /datum/surgery_step/organ/snip(src, organ_var_name)) // Makes the organ unsecure
		src.add_next_step(new /datum/surgery_step/organ/remove(src, organ_var_name)) // Removes the organ


	heart
		id = "heart_surgery"
		name = "Heart Surgery"
		desc = "Remove the patients' heart."
		icon_state = "heart"
		organ_var_name = "heart"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/cut(src))
			src.add_next_step(new /datum/surgery_step/organ/snip(src))
			src.add_next_step(new /datum/surgery_step/organ/saw(src))
			src.add_next_step(new /datum/surgery_step/organ/remove(src))
	liver
		id = "liver_surgery"
		name = "Liver Surgery"
		desc = "Remove the patients' liver."
		icon_state = "liver"
		organ_var_name = "liver"
	pancreas
		id = "pancreas_surgery"
		name = "Pancreas Surgery"
		desc = "Remove the patients' pancreas."
		icon_state = "pancreas"
		organ_var_name = "pancreas"
	left_lung
		id = "left_lung_surgery"
		name = "Left Lung Surgery"
		desc = "Remove the patients' left lung."
		icon_state = "left_lung"
		organ_var_name = "left_lung"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/cut(src))
			src.add_next_step(new /datum/surgery_step/organ/snip(src))
			src.add_next_step(new /datum/surgery_step/organ/saw(src))
			src.add_next_step(new /datum/surgery_step/organ/remove(src))
	right_lung
		id = "right_lung_surgery"
		name = "Right Lung Surgery"
		desc = "Remove the patients' right lung."
		icon_state = "right_lung"
		organ_var_name = "right_lung"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/cut(src))
			src.add_next_step(new /datum/surgery_step/organ/snip(src))
			src.add_next_step(new /datum/surgery_step/organ/saw(src))
			src.add_next_step(new /datum/surgery_step/organ/remove(src))
	stomach
		id = "stomach_surgery"
		name = "Stomach Surgery"
		desc = "Remove the patients' stomach."
		icon_state = "stomach"
		organ_var_name = "stomach"
	spleen
		id = "spleen_surgery"
		name = "Spleen Surgery"
		desc = "Remove the patients' spleen."
		icon_state = "spleen"
		organ_var_name = "spleen"
	appendix
		id = "appendix_surgery"
		name = "Appendix Surgery"
		desc = "Remove the patients' appendix."
		icon_state = "appendix"
		organ_var_name = "appendix"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/snip(src))
			src.add_next_step(new /datum/surgery_step/organ/cut(src))
	intestine
		id = "intestines_surgery"
		name = "Intestine Surgery"
		desc = "Remove the patients' intestines."
		icon_state = "intestines"
		organ_var_name = "intestines"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/cut(src))
			src.add_next_step(new /datum/surgery_step/organ/saw(src))
			src.add_next_step(new /datum/surgery_step/organ/cut(src))
	left_kidney
		id = "left_kidney_surgery"
		name = "Left Kidney Surgery"
		desc = "Remove the patients' left kidney."
		icon_state = "left_kidney"
		organ_var_name = "left_kidney"
		organ_pretty_name = "left kidney"
	right_kidney
		id = "right_kidney_surgery"
		name = "Right Kidney Surgery"
		desc = "Remove the patients' right kidney."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"
		organ_pretty_name = "right kidney"

	head // Base type to cover helmet blocking
		attempt_implicit(mob/living/surgeon, tool)
			if (!headSurgeryCheck(patient))
				surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
				return TRUE
			return ..()
		eye
			affected_zone = "head"
			implicit = TRUE

			generate_surgery_steps()
				src.add_next_step(new /datum/surgery_step/organ/eye/dislodge(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/organ/eye/cut(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/organ/eye/scoop(src, organ_var_name))

			surgery_possible(mob/living/surgeon)
				if (surgeon.zone_sel.selecting != "head")
					return FALSE
				return TRUE

			left
				id = "left_eye_surgery"
				name = "Left Eye Surgery"
				desc = "Remove the patients' left eye."
				organ_var_name = "left_eye"
				organ_pretty_name = "left eye"
				step_possible(mob/living/surgeon, obj/item/I, implicit=FALSE)
					if (!surgeon.find_in_hand(I, "left"))
						return FALSE
					return ..()
				on_cancel(mob/living/surgeon, obj/item/tool, quiet, forced = FALSE)
					if (!quiet && surgeon)
						surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] left eye socket closed with [tool]."),\
							SPAN_NOTICE("You sew the incision in [surgeon == patient ? "your" : "[patient]'s"] left eye socket closed with [tool]."),\
							SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision in your left eye socket closed with [tool]."))

			right
				id = "right_eye_surgery"
				name = "Right Eye Surgery"
				desc = "Remove the patients' right eye."
				organ_var_name = "right_eye"
				organ_pretty_name = "right eye"
				step_possible(mob/living/surgeon, obj/item/I, implicit=FALSE)
					if (!surgeon.find_in_hand(I, "right"))
						return FALSE
					return ..()
				on_cancel(mob/living/surgeon, obj/item/tool, quiet, forced = FALSE)
					if (!quiet && surgeon)
						surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right eye socket closed with [tool]."),\
							SPAN_NOTICE("You sew the incision in [surgeon == patient ? "your" : "[patient]'s"] right eye socket closed with [tool]."),\
							SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision in your right eye socket closed with [tool]."))
		skull
			id = "skull_surgery"
			name = "Skull Surgery"
			desc = "Remove the patients' skull."
			icon_state = "skull"
			organ_var_name = "skull"
			implicit = TRUE
			affected_zone = "head"

			check_surgery_stage()
				var/mob/living/carbon/human/C = patient
				var/organ = C.organHolder.get_organ(organ_var_name)
				if (organ)
					surgery_steps[2].completed = (!organ)
				..()
			surgery_possible(mob/living/surgeon)
				if (surgeon.zone_sel.selecting != "head")
					return FALSE
				if (surgeon.a_intent == INTENT_HARM) // head removal
					return FALSE
				return TRUE
			on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
				if (!quiet && surgeon)
					surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
							SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
							SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your neck closed with [tool]."))

			generate_surgery_steps()
				src.add_next_step(new /datum/surgery_step/skull/cut(src))
				src.add_next_step(new /datum/surgery_step/skull/remove(src))
				src.add_next_step(new /datum/surgery_step/organ/add/skull(src, organ_var_name))
		brain
			id = "brain_surgery"
			name = "Brain Surgery"
			desc = "Perform surgery on the patients' brain."
			affected_zone = "head"
			organ_var_name = "brain"
			implicit = TRUE
			default_sub_surgeries = list(/datum/surgery/carbon/organ/head/skull, /datum/surgery/carbon/organ_replace/skull)
			check_surgery_stage()
				var/mob/living/carbon/human/C = patient
				if (C.organHolder.brain)
					surgery_steps[4].completed = FALSE
				else
					surgery_steps[4].completed = TRUE
				..()
			generate_surgery_steps()
				src.add_next_step(new /datum/surgery_step/organ/brain/cut(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/organ/brain/saw(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/organ/brain/cut2(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/organ/brain/remove(src, organ_var_name))

			on_cancel(mob/surgeon, obj/item/tool, quiet, forced = FALSE)
				if (!quiet)
					surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head closed with [tool]."),\
						SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] head closed with [tool]."),\
						SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your head closed with [tool]."))
			surgery_possible(mob/living/surgeon)
				if (surgeon.zone_sel.selecting != "head")
					return FALSE
				if (surgeon.a_intent == INTENT_HARM)
					return FALSE
				return TRUE
			get_desc(show_vague)
				var/steps_complete = src.get_surgery_progress()
				var/t_his = his_or_her(patient)
				var/Noun = show_vague ? "[capitalize(t_his)]" : "[patient.name]"
				var/noun_s = show_vague ? t_his : "[patient.name]'s" // lowercase, for middle of description
				var/Noun_s = show_vague ? capitalize(t_his) : "[patient.name]'s"
				if (steps_complete > 0)
					if (steps_complete >= 3.0)
						if (!patient.organHolder.skull)
							. += "<br>[SPAN_ALERT("<B>There's a gaping hole in [noun_s] head and [t_his] skull is gone!</B>")]"
						else if (!patient.organHolder.brain)
							. += "<br>[SPAN_ALERT("<B>There's a gaping hole in [noun_s] head and [t_his] brain is gone!</B>")]"
						else
							. += "<br>[SPAN_ALERT("<B>There's a gaping hole in [noun_s] head!</B>")]"
					else if (steps_complete >= 2.0)
						if (!patient.organHolder.brain)
							. += "<br>[SPAN_ALERT("<B>[Noun_s] head has been cut open and [t_his] brain is gone!</B>")]"
						else
							. += "<br>[SPAN_ALERT("<B>[Noun_s] head has been cut open!</B>")]"
					else
						. += "<br>[SPAN_ALERT("<B>[Noun] has an open incision on [t_his] head!</B>")]"
		head
			id = "head_removal"
			name = "Head Removal"
			desc = "Remove the patients' head."
			affected_zone = "head"
			organ_var_name = "head"
			implicit = TRUE
			check_surgery_stage()
				var/mob/living/carbon/human/C = patient
				var/no_head = !C.organHolder.get_organ(organ_var_name)
				surgery_steps[4].completed = no_head
				..()
			generate_surgery_steps()
				src.add_next_step(new /datum/surgery_step/head/cut(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/head/saw(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/head/cut2(src, organ_var_name))
				src.add_next_step(new /datum/surgery_step/head/remove(src, organ_var_name))
			surgery_possible(mob/living/surgeon)
				if (surgeon.zone_sel.selecting != "head")
					return FALSE
				if (surgeon.a_intent != INTENT_HARM)
					return FALSE
				return TRUE
			get_desc(show_vague)
				var/t_his = his_or_her(patient)
				var/t_he = he_or_she(patient)
				var/Noun_has = show_vague ? "[capitalize(t_he)] [has_or_have(src)]" : "[patient.name] has"
				var/Noun_s = show_vague ? capitalize(t_his) : "[patient.name]'s"
				var/steps_complete = src.get_surgery_progress()
				if (steps_complete > 0)
					if (steps_complete == 3.0)
						. += "<br>[SPAN_ALERT("<B>[Noun_s] head is barely attached!</B>")]"
					else
						. += "<br>[SPAN_ALERT("<B>[Noun_has] a huge incision across [t_his] neck!</B>")]"


	butt
		id = "butt_surgery"
		name = "Butt Surgery"
		desc = "Remove the patients' butt."
		icon_state = "butt"
		organ_var_name = "butt"
		exit_when_completed = TRUE
		implicit = TRUE
		affected_zone = "chest"

		cancel_possible()
			return FALSE
		check_surgery_stage()
			var/mob/living/carbon/human/C = patient
			var/organ = C.organHolder.get_organ(organ_var_name)
			surgery_steps[1].completed = (organ == null)
			return ..()
		surgery_possible(mob/living/surgeon)
			if (surgeon?.a_intent != INTENT_GRAB)
				return FALSE
			return ..()
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/remove/saw(src, organ_var_name))

	tail
		id = "tail_surgery"
		name = "Tail Surgery"
		desc = "Remove the patients' tail."
		icon_state = "tail"
		organ_var_name = "tail"
		exit_when_completed = TRUE
		implicit = TRUE
		check_surgery_stage()
			var/mob/living/carbon/human/C = patient
			var/organ = C.organHolder.get_organ(organ_var_name)
			surgery_steps[1].completed = (organ == null)
			..()
		cancel_possible()
			return FALSE
		surgery_possible(mob/living/surgeon)
			if (surgeon?.a_intent != INTENT_GRAB)
				return FALSE
			return ..()
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/remove/saw(src, organ_var_name))


/datum/surgery/carbon/organ_replace
	id = "organ_addition"
	name = "Organ Addition"
	desc = "Replace the patients' organs."
	visible = FALSE
	implicit = TRUE
	exit_when_completed = TRUE
	var/auto_connect_organ = TRUE //! Automatically connect the new organ if applicable.
	var/organ_var_name = "thing"
	var/organ_pretty_name

	check_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/organ = C.organHolder.get_organ(organ_var_name)
		surgery_steps[1].completed = (organ != null)
		..()
	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/organ/add(src,organ_var_name))
	surgery_possible(mob/living/surgeon)
		if (implicit && surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (patient.organHolder.get_organ(organ_var_name))
			return FALSE
		return TRUE
	on_complete(mob/surgeon, obj/item/tool)
		// Old organ behaviour - Upon insertion of a new organ, reset all steps so the next organ is good as new.
		if (auto_connect_organ)
			var/datum/surgery/removal_surgery = src.holder.get_surgery("[organ_var_name]_surgery") // this is icky! gross! but it works.
			removal_surgery.cancel(surgeon, tool, quiet=TRUE, forced=TRUE)
		return

	// Cancelling this would only involve removing the organ. Not useful unless you wanted to have a multi-step addition
	cancel_possible()
		return FALSE

	heart
		id = "heart_replacement"
		name = "Heart Replacement"
		desc = "Replace the patients' heart."
		icon_state = "heart"
		organ_var_name = "heart"
	liver
		id = "liver_replacement"
		name = "Liver Replacement"
		desc = "Replace the patients' liver."
		icon_state = "liver"
		organ_var_name = "liver"
	pancreas
		id = "pancreas_replacement"
		name = "Pancreas Replacement"
		desc = "Replace the patients' pancreas."
		icon_state = "pancreas"
		organ_var_name = "pancreas"
	left_lung
		id = "left_lung_replacement"
		name = "Left Lung Replacement"
		desc = "Replace the patients' left lung."
		icon_state = "left_lung"
		organ_var_name = "left_lung"
		organ_pretty_name = "left lung"
	right_lung
		id = "right_lung_replacement"
		name = "Right Lung Replacement"
		desc = "Replace the patients' right lung."
		icon_state = "right_lung"
		organ_var_name = "right_lung"
		organ_pretty_name = "right lung"
	stomach
		id = "stomach_replacement"
		name = "Stomach Replacement"
		desc = "Replace the patients' stomach."
		icon_state = "stomach"
		organ_var_name = "stomach"
	spleen
		id = "spleen_replacement"
		name = "Spleen Replacement"
		desc = "Replace the patients' spleen."
		icon_state = "spleen"
		organ_var_name = "spleen"
	appendix
		id = "appendix_replacement"
		name = "Appendix Replacement"
		desc = "Replace the patients' appendix."
		icon_state = "appendix"
		organ_var_name = "appendix"
	intestine
		id = "intestines_replacement"
		name = "Intestine Replacement"
		desc = "Replace the patients' intestine."
		icon_state = "intestine"
		organ_var_name = "intestines"
	left_kidney
		id = "left_kidney_replacement"
		name = "Left Kidney Replacement"
		desc = "Replace the patients' left kidney."
		icon_state = "left_kidney"
		organ_var_name = "left_kidney"
		organ_pretty_name = "left kidney"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/add/kidney(src,organ_var_name))

	right_kidney
		id = "right_kidney_replacement"
		name = "Right Kidney Replacement"
		desc = "Replace the patients' right kidney."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"
		organ_pretty_name = "right kidney"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/add/kidney(src,organ_var_name))
	butt
		id = "butt_replacement"
		name = "Butt Replacement"
		desc = "Replace the patients' butt."
		icon_state = "butt"
		organ_var_name = "butt"
		affected_zone = "butt"
		get_desc(show_vague)
			var/t_his = his_or_her(patient)
			var/t_he = he_or_she(patient)
			var/Noun_has = show_vague ? "[capitalize(t_he)] [has_or_have(src)]" : "[patient.name] has"
			var/Noun_s = show_vague ? capitalize(t_his) : "[patient.name]'s"
			return "<br>[SPAN_ALERT("<B>[Noun_has] an open incision on [t_his] butt!</B>")]"
	tail
		id = "tail_replacement"
		name = "Tail Replacement"
		desc = "Replace the patients' tail."
		icon_state = "tail"
		organ_var_name = "tail"
		affected_zone = "tail"

	eye
		generate_surgery_steps()
			// Custom step to handle eyes being indifferent to which side they are on
			src.add_next_step(new /datum/surgery_step/organ/add/eye(src))
		surgery_possible(mob/living/surgeon)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			return TRUE
		left
			id = "left_eye_replacement"
			name = "Left Eye Replacement"
			desc = "Replace the patients' left eye."
			organ_var_name = "left_eye"
			organ_pretty_name = "left eye"
		right
			id = "right_eye_replacement"
			name = "Right Eye Replacement"
			desc = "Replace the patients' right eye."
			organ_var_name = "right_eye"
			organ_pretty_name = "right eye"
	brain
		id = "brain_replacement"
		name = "Brain Replacement"
		desc = "Replace the	patients' brain."
		affected_zone = "head"
		organ_var_name = "brain"
		auto_connect_organ = FALSE
		implicit = TRUE
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/add(src, organ_var_name))
		surgery_possible(mob/living/surgeon)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			if (surgeon.a_intent == INTENT_HARM)
				return FALSE
			return TRUE
	skull
		id = "skull_replacement"
		name = "Skull Replacement"
		desc = "Replace the patients' skull."
		affected_zone = "head"
		organ_var_name = "skull"
		implicit = TRUE
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/add(src, organ_var_name))
		surgery_possible(mob/living/surgeon)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			if (surgeon.a_intent == INTENT_HARM)
				return FALSE
			return TRUE
	head
		id = "head_replacement"
		name = "Head Replacement"
		desc = "Replace the patients' head."
		affected_zone = "head"
		organ_var_name = "head"
		implicit = TRUE
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/organ/add/head(src, organ_var_name))
		surgery_possible(mob/living/surgeon)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			if (surgeon.a_intent == INTENT_HARM)
				return FALSE
			return TRUE
		surgery_conditions_met(mob/surgeon, obj/item/tool)
			return (isskeleton(patient) || ..())
