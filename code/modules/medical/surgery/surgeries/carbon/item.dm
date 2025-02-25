
/datum/surgery/item
	name = "Item insertion Surgery"
	desc = "Insert an item into the patients' chest."
	icon_state = "chest_item"
	sub_surgeries = list(/datum/surgery/item_removal)
	can_cancel = FALSE
	restart_when_finished = TRUE
	exit_when_finished = FALSE
	affected_zone = "chest"
	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		return TRUE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new/datum/surgery_step/item/insert(src))
		add_next_step(new/datum/surgery_step/item/secure(src))
		add_simultaneous_step(new/datum/surgery_step/item/remove(src))
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		var/item_present = (C.chest_item != null)
		surgery_steps[1].finished = item_present
		surgery_steps[1].visible = !item_present
		surgery_steps[2].finished = (C.chest_item_sewn)
		surgery_steps[3].finished = !item_present
		surgery_steps[3].visible = item_present

/datum/surgery/item_removal
	name = "Item removal Surgery"
	desc = "Remove the item from the patients' chest."
	icon_state = "out"
	implicit = TRUE
	restart_when_finished = TRUE
	exit_when_finished = TRUE
	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		var/mob/living/carbon/human/C = patient
		if (C.chest_item == null)
			return FALSE
		return TRUE
	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		surgery_steps[1].finished = (!C.chest_item_sewn)
		surgery_steps[2].finished = (C.chest_item != null)
