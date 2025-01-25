/datum/surgery/heal_brute
	name = "Tend wounds"
	desc = "Heal BRUTE damage."
	restart_when_finished = TRUE

	///Create the surgery steps for this surgery - These will be removed when completed
	generate_surgery_steps(mob/living/surgeon, mob/user)
		var/coin_toss = prob(50)
		if(coin_toss)
			surgery_steps += new /datum/surgery_step/cut(src)
		else
			surgery_steps += new /datum/surgery_step/snip(src)
		surgery_steps += new /datum/surgery_step/suture(src)

	on_complete(mob/living/surgeon, mob/user)
		patient.HealDamage("All", 15, 0)

/datum/surgery/heal_burn
	name = "Tend burns"
	desc = "Heal BURN damage with bandages."
	restart_when_finished = TRUE

	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += list(new /datum/surgery_step/bandage(src),
		new /datum/surgery_step/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		..()
		surgeon.HealDamage("All", 0, 15)


/datum/surgery/heal_generic
	name = "Tend wounds"
	desc = "Heal BRUTE or BURN damage with surgery."
	default_sub_surgeries = list(/datum/surgery/heal_brute,	/datum/surgery/heal_burn)

/datum/surgery/organ_surgery
	name = "Organ Surgery"
	desc = "Modify the patients' organs."
	default_sub_surgeries = list(/datum/surgery/ribs, /datum/surgery/subcostal, /datum/surgery/flanks, /datum/surgery/abdomen)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/cut(src)
		surgery_steps += new /datum/surgery_step/snip(src)

/datum/surgery/limb_surgery
	name = "Limb Surgery"
	desc = "Modify the patients' limbs."
	default_sub_surgeries = list()
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/cut(src)
		surgery_steps += new /datum/surgery_step/snip(src)


/datum/surgery/ribs
	name = "Rib Surgery"
	desc = "Open the patient's ribcage"
	icon_state = "ribs"
	default_sub_surgeries = list(/datum/surgery/heart, /datum/surgery/left_lung, /datum/surgery/right_lung)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/cut(src)
		surgery_steps += new /datum/surgery_step/saw(src)
		surgery_steps += new /datum/surgery_step/snip(src)

/datum/surgery/subcostal
	name = "Subcostal"
	desc = "Open the subcostal region"
	icon_state = "subcostal"
	default_sub_surgeries = list(/datum/surgery/liver, /datum/surgery/spleen, /datum/surgery/pancreas)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/cut(src)
		surgery_steps += new /datum/surgery_step/snip(src)

/datum/surgery/flanks
	name = "Flank Surgery"
	desc = "Open the patient's flanks"
	icon_state = "flanks"
	default_sub_surgeries = list(/datum/surgery/left_kidney, /datum/surgery/right_kidney)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/cut(src)
		surgery_steps += new /datum/surgery_step/snip(src)

/datum/surgery/abdomen
	name = "Abdomen Surgery"
	desc = "Open the patient's abdomen"
	icon_state = "abdominal"
	default_sub_surgeries = list(/datum/surgery/stomach, /datum/surgery/intestine, /datum/surgery/appendix)
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/cut(src)
		surgery_steps += new /datum/surgery_step/snip(src)
/datum/surgery/heart
	name = "Heart Surgery"
	desc = "Remove the patients' heart."
	icon_state = "heart"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.heart)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.heart)

/datum/surgery/liver
	name = "Liver Surgery"
	desc = "Remove the patients' liver."
	icon_state = "liver"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.liver)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.liver)

/datum/surgery/pancreas
	name = "Pancreas Surgery"
	desc = "Remove the patients' pancreas."
	icon_state = "pancreas"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.pancreas)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.pancreas)

/datum/surgery/left_lung
	name = "Left Lung Surgery"
	desc = "Remove the patients' left lung."
	icon_state = "left_lung"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.left_lung)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.left_lung)

/datum/surgery/right_lung
	name = "Right Lung Surgery"
	desc = "Remove the patients' right lung."
	icon_state = "right_lung"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.right_lung)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.right_lung)

/datum/surgery/stomach
	name = "Stomach Surgery"
	desc = "Remove the patients' stomach."
	icon_state = "stomach"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.stomach)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.stomach)

/datum/surgery/spleen
	name = "Spleen Surgery"
	desc = "Remove the patients' spleen."
	icon_state = "spleen"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.spleen)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.spleen)

/datum/surgery/appendix
	name = "Appendix Surgery"
	desc = "Remove the patients' appendix."
	icon_state = "appendix"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.appendix)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.appendix)

/datum/surgery/intestine
	name = "Intestine Surgery"
	desc = "Remove the patients' intestine."
	icon_state = "intestine"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.intestines)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.intestines)

/datum/surgery/left_kidney
	name = "Left Kidney Surgery"
	desc = "Remove the patients' left kidney."
	icon_state = "left_kidney"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.left_kidney)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.left_kidney)

/datum/surgery/right_kidney
	name = "Right Kidney Surgery"
	desc = "Remove the patients' right kidney."
	icon_state = "right_kidney"
	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += new /datum/surgery_step/organ/cut(src, src.patient.organHolder.right_kidney)
		surgery_steps += new /datum/surgery_step/organ/snip(src, src.patient.organHolder.right_kidney)
