/datum/surgery/test
	name = "Test surgery"
	desc = "Heal BRUTE damage."
	restart_when_finished = TRUE

	///Create the surgery steps for this surgery - These will be removed when completed
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))

		add_next_step(new /datum/surgery_step/snip(src))
		add_simultaneous_step(new /datum/surgery_step/saw(src))

		add_next_step(new /datum/surgery_step/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		patient.HealDamage("All", 15, 0)

/datum/surgery/organ_surgery
	name = "Torso Surgery"
	desc = "Modify the patients' torso and organs."
	icon_state = "torso"
	default_sub_surgeries = list(/datum/surgery/ribs, /datum/surgery/subcostal, /datum/surgery/flanks, /datum/surgery/abdomen, /datum/surgery/item)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))
		add_next_step(new /datum/surgery_step/snip(src))

/datum/surgery/ribs
	name = "Rib Surgery"
	desc = "Open the patient's ribcage"
	icon_state = "ribs"
	default_sub_surgeries = list(/datum/surgery/organ/heart, /datum/surgery/organ/replace/heart,
	/datum/surgery/organ/left_lung, /datum/surgery/organ/replace/left_lung,
	/datum/surgery/organ/right_lung, /datum/surgery/organ/replace/right_lung)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))
		add_next_step(new /datum/surgery_step/saw(src))
		add_next_step(new /datum/surgery_step/snip(src))

/datum/surgery/subcostal
	name = "Subcostal"
	desc = "Open the subcostal region"
	icon_state = "subcostal"
	default_sub_surgeries = list(/datum/surgery/organ/liver, /datum/surgery/organ/replace/liver,
	/datum/surgery/organ/spleen, /datum/surgery/organ/replace/spleen,
	/datum/surgery/organ/pancreas, /datum/surgery/organ/replace/pancreas)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))
		add_next_step(new /datum/surgery_step/snip(src))

/datum/surgery/flanks
	name = "Flank Surgery"
	desc = "Open the patient's flanks"
	icon_state = "flanks"
	default_sub_surgeries = list(/datum/surgery/organ/left_kidney, /datum/surgery/organ/replace/left_kidney,
	/datum/surgery/organ/right_kidney, /datum/surgery/organ/replace/right_kidney)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))
		add_next_step(new /datum/surgery_step/snip(src))

/datum/surgery/abdomen
	name = "Abdomen Surgery"
	desc = "Open the patient's abdomen"
	icon_state = "abdominal"
	default_sub_surgeries = list(/datum/surgery/organ/stomach, /datum/surgery/organ/replace/stomach,
	/datum/surgery/organ/intestine, /datum/surgery/organ/replace/intestine,
	/datum/surgery/organ/appendix, /datum/surgery/organ/replace/appendix)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))
		add_next_step(new /datum/surgery_step/snip(src))

/datum/surgery/organ
	name = "Base Organ Surgery"
	desc = "Call a coder if you see this!"
	icon_state = "heart"
	var/organ_var_name = "heart"
	restart_when_finished = TRUE
	exit_when_finished = TRUE
	surgery_possible(mob/living/surgeon)
		if (implicit && surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (patient.organHolder.get_organ(organ_var_name))
			return TRUE
		return FALSE

	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/organ/cut(src, organ_var_name)) // Makes the organ count as 'in surgery'
		add_next_step(new /datum/surgery_step/organ/snip(src, organ_var_name)) // Makes the organ unsecure
		add_next_step(new /datum/surgery_step/organ/remove(src, organ_var_name)) // Removes the organ

	surgery_clicked(mob/living/surgeon, obj/item/I)
		if (!I)
			var/obj/item/organ = patient.organHolder.get_organ(organ_var_name)
			actions.start(new/datum/action/bar/icon/remove_organ(surgeon, patient, organ_var_name, src.name, TRUE, organ.icon, organ.icon_state), surgeon)
			return
		..()
	heart
		name = "Heart Surgery"
		desc = "Remove the patients' heart."
		icon_state = "heart"
		organ_var_name = "heart"
	liver
		name = "Liver Surgery"
		desc = "Remove the patients' liver."
		icon_state = "liver"
		organ_var_name = "liver"
	pancreas
		name = "Pancreas Surgery"
		desc = "Remove the patients' pancreas."
		icon_state = "pancreas"
		organ_var_name = "pancreas"
	left_lung
		name = "Left Lung Surgery"
		desc = "Remove the patients' left lung."
		icon_state = "left_lung"
		organ_var_name = "left_lung"
	right_lung
		name = "Right Lung Surgery"
		desc = "Remove the patients' right lung."
		icon_state = "right_lung"
		organ_var_name = "right_lung"
	stomach
		name = "Stomach Surgery"
		desc = "Remove the patients' stomach."
		icon_state = "stomach"
		organ_var_name = "stomach"
	spleen
		name = "Spleen Surgery"
		desc = "Remove the patients' spleen."
		icon_state = "spleen"
		organ_var_name = "spleen"
	appendix
		name = "Appendix Surgery"
		desc = "Remove the patients' appendix."
		icon_state = "appendix"
		organ_var_name = "appendix"
	intestine
		name = "Intestine Surgery"
		desc = "Remove the patients' intestine."
		icon_state = "intestine"
		organ_var_name = "intestines"
	left_kidney
		name = "Left Kidney Surgery"
		desc = "Remove the patients' left kidney."
		icon_state = "left_kidney"
		organ_var_name = "left_kidney"
	right_kidney
		name = "Right Kidney Surgery"
		desc = "Remove the patients' right kidney."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"


	eye
		generate_surgery_steps(mob/living/surgeon, mob/user)
			add_next_step(new /datum/surgery_step/organ/eye/dislodge(src, organ_var_name)) // Makes the organ count as 'in surgery'
			add_next_step(new /datum/surgery_step/organ/eye/cut(src, organ_var_name)) // Makes the organ unsecure
			add_next_step(new /datum/surgery_step/organ/eye/scoop(src, organ_var_name)) // Removes the organ
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			return TRUE
		left
			name = "Left Eye Surgery"
			desc = "Remove the patients' left eye."
			organ_var_name = "left_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.l_hand)
					return FALSE
				return ..()
		right
			name = "Right Eye Surgery"
			desc = "Remove the patients' right eye."
			organ_var_name = "right_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.r_hand)
					return FALSE
				return ..()

/datum/surgery/organ/replace
	name = "Organ Addition"
	desc = "Replace the patients' organs."
	visible = FALSE
	implicit = TRUE
	restart_when_finished = TRUE
	exit_when_finished = TRUE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/organ/add(src,organ_var_name))
	surgery_possible(mob/living/surgeon)
		if (implicit && surgeon.zone_sel.selecting != "chest")
			return FALSE
		if (patient.organHolder.get_organ(organ_var_name))
			return FALSE
		return TRUE
	heart
		name = "Heart Replacement"
		desc = "Replace the patients' heart."
		icon_state = "heart"
		organ_var_name = "heart"
	liver
		name = "Liver Replacement"
		desc = "Replace the patients' liver."
		icon_state = "liver"
		organ_var_name = "liver"
	pancreas
		name = "Pancreas Replacement"
		desc = "Replace the patients' pancreas."
		icon_state = "pancreas"
		organ_var_name = "pancreas"
	left_lung
		name = "Left Lung Replacement"
		desc = "Replace the patients' left lung."
		icon_state = "left_lung"
		organ_var_name = "left_lung"
	right_lung
		name = "Right Lung Replacement"
		desc = "Replace the patients' right lung."
		icon_state = "right_lung"
		organ_var_name = "right_lung"
	stomach
		name = "Stomach Replacement"
		desc = "Replace the patients' stomach."
		icon_state = "stomach"
		organ_var_name = "stomach"
	spleen
		name = "Spleen Replacement"
		desc = "Replace the patients' spleen."
		icon_state = "spleen"
		organ_var_name = "spleen"
	appendix
		name = "Appendix Replacement"
		desc = "Replace the patients' appendix."
		icon_state = "appendix"
		organ_var_name = "appendix"
	intestine
		name = "Intestine Replacement"
		desc = "Replace the patients' intestine."
		icon_state = "intestine"
		organ_var_name = "intestines"
	left_kidney
		name = "Left Kidney Replacement"
		desc = "Replace the patients' left kidney."
		icon_state = "left_kidney"
		organ_var_name = "left_kidney"
	right_kidney
		name = "Right Kidney Replacement"
		desc = "Replace the patients' right kidney."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"
	right_kidney
		name = "Butt Replacement"
		desc = "Replace the patients' butt."
		icon_state = "right_kidney"
		organ_var_name = "right_kidney"
	eye
		surgery_possible(mob/living/surgeon, obj/item/I)
			if (surgeon.zone_sel.selecting != "head")
				return FALSE
			if (patient.organHolder.get_organ(organ_var_name))
				return FALSE
			return TRUE
		left
			name = "Left Eye Replacement"
			desc = "Replace the patients' left eye."
			organ_var_name = "left_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.l_hand)
					return FALSE
				return ..()
		right
			name = "Right Eye Replacement"
			desc = "Replace the patients' right eye."
			organ_var_name = "right_eye"
			surgery_possible(mob/living/surgeon, obj/item/I)
				if (surgeon.find_in_hand(I) != surgeon.r_hand)
					return FALSE
				return ..()
