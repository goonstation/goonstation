
/datum/surgery/item
	id = "chest_item_surgery"
	name = "Item insertion Surgery"
	desc = "Insert an item into the patients' chest."
	icon_state = "chest_item"
	exit_when_finished = FALSE
	affected_zone = "chest"
	cancel_possible()
		return FALSE
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

