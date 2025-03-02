/datum/surgery/organ_surgery
	id = "torso_surgery"
	name = "Torso Surgery"
	desc = "Modify the patients' torso and organs."
	icon_state = "torso"
	default_sub_surgeries = list(/datum/surgery/ribs, /datum/surgery/subcostal, /datum/surgery/flanks, /datum/surgery/abdomen, /datum/surgery/item, )
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/chest/cut(src))
		add_next_step(new /datum/surgery_step/fluff/snip(src))
		add_simultaneous_step(new /datum/surgery_step/chest/clamp(src))

/datum/surgery/head
	id = "head_surgery"
	name = "Head Surgery"
	desc = "Perform surgery on the patient's head"
	default_sub_surgeries = list(/datum/surgery/organ/eye/left, /datum/surgery/organ/eye/right)
	visible = FALSE
	implicit = TRUE
	affected_zone = "head"

/datum/surgery/ribs
	id = "rib_surgery"
	name = "Rib Surgery"
	desc = "Open the patient's ribcage"
	icon_state = "ribs"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/organ/heart, /datum/surgery/organ/replace/heart,
	/datum/surgery/organ/left_lung, /datum/surgery/organ/replace/left_lung,
	/datum/surgery/organ/right_lung, /datum/surgery/organ/replace/right_lung)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/fluff/cut(src))
		add_next_step(new /datum/surgery_step/fluff/saw(src))
		add_next_step(new /datum/surgery_step/fluff/snip(src))

/datum/surgery/subcostal
	id = "subcostal"
	name = "Subcostal"
	desc = "Open the subcostal region"
	icon_state = "subcostal"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/organ/liver, /datum/surgery/organ/replace/liver,
	/datum/surgery/organ/spleen, /datum/surgery/organ/replace/spleen,
	/datum/surgery/organ/pancreas, /datum/surgery/organ/replace/pancreas)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/fluff/cut(src))
		add_next_step(new /datum/surgery_step/fluff/snip(src))

/datum/surgery/flanks
	id = "flank_surgery"
	name = "Flank Surgery"
	desc = "Open the patient's flanks"
	icon_state = "flanks"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/organ/left_kidney, /datum/surgery/organ/replace/left_kidney,
	/datum/surgery/organ/right_kidney, /datum/surgery/organ/replace/right_kidney)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/fluff/cut(src))
		add_next_step(new /datum/surgery_step/fluff/snip(src))

/datum/surgery/abdomen
	id = "abdomen_surgery"
	name = "Abdomen Surgery"
	desc = "Open the patient's abdomen"
	icon_state = "abdominal"
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/organ/stomach, /datum/surgery/organ/replace/stomach,
	/datum/surgery/organ/intestine, /datum/surgery/organ/replace/intestine,
	/datum/surgery/organ/appendix, /datum/surgery/organ/replace/appendix)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/fluff/cut(src))
		add_next_step(new /datum/surgery_step/fluff/snip(src))


/datum/surgery/lower_back
	id = "lower_back_surgery"
	name = "Lower Back Removal"
	desc = "Remove the patients' tail or butt."
	default_sub_surgeries = list(/datum/surgery/organ/butt, /datum/surgery/organ/replace/butt,
		/datum/surgery/organ/tail, /datum/surgery/organ/replace/tail
	)
	implicit = TRUE
	visible = FALSE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/fluff/back_cut(src))
		add_next_step(new /datum/surgery_step/fluff/back_saw(src))
		add_next_step(new /datum/surgery_step/fluff/back_cut_2(src))
	surgery_possible(mob/living/surgeon, obj/item/I)
		if (surgeon?.a_intent != INTENT_GRAB)
			return FALSE
		return ..()


/datum/surgery/organ
	id = "base_organ_surgery"
	name = "Base Organ Surgery"
	desc = "Call a coder if you see this!"
	icon_state = "heart"
	var/organ_var_name = "thing"
	exit_when_finished = TRUE
	affected_zone = "chest"
	surgery_possible(mob/living/surgeon)
		if (implicit && surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (patient.organHolder.get_organ(organ_var_name))
			return TRUE
		return FALSE
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/organ = C.organHolder.get_organ(organ_var_name)
		if (organ)
			surgery_steps[1].finished = (organ:in_surgery == TRUE)
			surgery_steps[2].finished = (organ:secure == FALSE)
			surgery_steps[3].finished = FALSE
		else
			surgery_steps[1].finished = TRUE
			surgery_steps[2].finished = TRUE
			surgery_steps[3].finished = TRUE

	on_cancel(mob/user, obj/item/I)
		var/obj/item/organ/O = patient.organHolder.vars[organ_var_name]
		if (O)
			O.in_surgery = FALSE
			O.secure = TRUE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/organ/cut(src, organ_var_name)) // Makes the organ count as 'in surgery'
		add_next_step(new /datum/surgery_step/organ/snip(src, organ_var_name)) // Makes the organ unsecure
		add_next_step(new /datum/surgery_step/organ/remove(src, organ_var_name)) // Removes the organ

	surgery_clicked(mob/living/surgeon, obj/item/tool)
		var/obj/item/organ = patient.organHolder.get_organ(organ_var_name)
		if (!tool)
			actions.start(new/datum/action/bar/icon/remove_organ(surgeon, patient, organ_var_name, src.name, TRUE, organ.icon, organ.icon_state), surgeon)
			return
		..()
	heart
		id = "heart_surgery"
		name = "Heart Surgery"
		desc = "Remove the patients' heart."
		icon_state = "heart"
		organ_var_name = "heart"
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
	right_lung
		id = "right_lung_surgery"
		name = "Right Lung Surgery"
		desc = "Remove the patients' right lung."
		icon_state = "right_lung"
		organ_var_name = "right_lung"
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
	intestine
		id = "intestine_surgery"
		name = "Intestine Surgery"
		desc = "Remove the patients' intestine."
		icon_state = "intestine"
		organ_var_name = "intestines"
	left_kidney
		id = "left_kidney_surgery"
		name = "Left Kidney Surgery"
		desc = "Remove the patients' left kidney."
		icon_state = "left_kidney"
		organ_var_name = "left_kidney"
	right_kidney
		id = "right_kidney_surgery"
		name = "Right Kidney Surgery"
		desc = "Remove the patients' right kidney."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"
	eye
		affected_zone = "head"
		implicit = TRUE
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/eye/dislodge(src, organ_var_name))
			add_next_step(new /datum/surgery_step/organ/eye/cut(src, organ_var_name))
			add_next_step(new /datum/surgery_step/organ/eye/scoop(src, organ_var_name))
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (!patient.organHolder.get_organ(organ_var_name))
				return FALSE
			return TRUE
		left
			id = "left_eye_surgery"
			name = "Left Eye Surgery"
			desc = "Remove the patients' left eye."
			organ_var_name = "left_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.l_hand)
					return FALSE
				return ..()
		right
			id = "right_eye_surgery"
			name = "Right Eye Surgery"
			desc = "Remove the patients' right eye."
			organ_var_name = "right_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.r_hand)
					return FALSE
				return ..()
	butt
		id = "butt_surgery"
		name = "Butt Surgery"
		desc = "Remove the patients' butt."
		icon_state = "butt"
		organ_var_name = "butt"

		infer_surgery_stage()
			var/mob/living/carbon/human/C = patient
			var/organ = C.organHolder.get_organ(organ_var_name)
			surgery_steps[1].finished = (organ == null)
			return
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon?.a_intent != INTENT_GRAB)
				return FALSE
			return ..()
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/remove/saw(src, organ_var_name))
	tail
		id = "tail_surgery"
		name = "Tail Surgery"
		desc = "Remove the patients' tail."
		icon_state = "tail"
		organ_var_name = "tail"
		infer_surgery_stage()
			var/mob/living/carbon/human/C = patient
			var/organ = C.organHolder.get_organ(organ_var_name)
			surgery_steps[1].finished = (organ == null)
			return
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon?.a_intent != INTENT_GRAB)
				return FALSE
			return ..()
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/remove/saw(src, organ_var_name))
	brain
		id = "brain_surgery"
		name = "Brain Surgery"
		desc = "Perform surgery on the patients' brain."
		affected_zone = "head"
		organ_var_name = "brain"
		implicit = TRUE
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/brain/cut(src, organ_var_name))
			add_next_step(new /datum/surgery_step/organ/brain/saw(src, organ_var_name))
			add_next_step(new /datum/surgery_step/organ/brain/cut2(src, organ_var_name))
			add_next_step(new /datum/surgery_step/organ/brain/remove(src, organ_var_name))
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (!patient.organHolder.get_organ(organ_var_name))
				return FALSE
			if (surgeon.a_intent == INTENT_HARM)
				return FALSE
			return TRUE
	skull
		id = "skull_surgery"
		name = "Skull Surgery"
		desc = "Perform surgery on the patients' brain."
		affected_zone = "head"
		organ_var_name = "skull"
		implicit = TRUE
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/skull/cut(src, organ_var_name))
			add_next_step(new /datum/surgery_step/skull/saw(src, organ_var_name))
			add_next_step(new /datum/surgery_step/skull/cut2(src, organ_var_name))
			add_next_step(new /datum/surgery_step/skull/remove(src, organ_var_name))
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (!patient.organHolder.get_organ(organ_var_name))
				return FALSE
			if (surgeon.a_intent != INTENT_HARM)
				return FALSE
			return TRUE
/datum/surgery/organ/replace
	id = "organ_addition"
	name = "Organ Addition"
	desc = "Replace the patients' organs."
	visible = FALSE
	implicit = TRUE
	exit_when_finished = TRUE
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/organ = C.organHolder.get_organ(organ_var_name)
		surgery_steps[1].finished = (organ != null)

	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/organ/add(src,organ_var_name))
	surgery_possible(mob/living/surgeon)
		if (implicit && surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (patient.organHolder.get_organ(organ_var_name))
			return FALSE
		return TRUE
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
	right_lung
		id = "right_lung_replacement"
		name = "Right Lung Replacement"
		desc = "Replace the patients' right lung."
		icon_state = "right_lung"
		organ_var_name = "right_lung"
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
		id = "intestine_replacement"
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
	right_kidney
		id = "right_kidney_replacement"
		name = "Right Kidney Replacement"
		desc = "Replace the patients' right kidney."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"
	butt
		id = "butt_replacement"
		name = "Butt Replacement"
		desc = "Replace the patients' butt."
		icon_state = "butt"
		organ_var_name = "butt"
		affected_zone = "butt"
	tail
		id = "tail_replacement"
		name = "Tail Replacement"
		desc = "Replace the patients' tail."
		icon_state = "tail"
		organ_var_name = "tail"
		affected_zone = "tail"

	eye
		surgery_possible(mob/living/surgeon, obj/item/I)
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
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.l_hand)
					return FALSE
				return ..()
		right
			id = "right_eye_replacement"
			name = "Right Eye Replacement"
			desc = "Replace the patients' right eye."
			organ_var_name = "right_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.r_hand)
					return FALSE
				return ..()
	brain
		id = "brain_replacement"
		name = "Brain Replacement"
		desc = "Replace the	patients' brain."
		affected_zone = "head"
		organ_var_name = "brain"
		implicit = TRUE
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/add(src, organ_var_name))
		surgery_possible(mob/living/surgeon, obj/item/I)
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
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/add(src, organ_var_name))
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			if (surgeon.a_intent != INTENT_HARM)
				return FALSE
			return TRUE


