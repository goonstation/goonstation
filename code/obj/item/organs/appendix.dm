/obj/item/organ/appendix
	name = "appendix"
	organ_name = "appendix"
	organ_holder_name = "appendix"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 3.0
	icon_state = "appendix"
	failure_disease = /datum/ailment/disease/appendicitis

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= FAIL_DAMAGE && prob(src.get_damage() * 0.2))
			donor.contract_disease(failure_disease,null,null,1)
		return 1

/obj/item/organ/appendix/cyber
	name = "cyberappendix"
	desc = "A fancy robotic appendix to replace one that someone's lost!"
	icon_state = "cyber-appendix"
	// item_state = "cyber-"
	robotic = 1
	edible = 0
	mats = 6

	//A bad version of the robutsec... For now.
	on_life()
		if (src.get_damage() < FAIL_DAMAGE && prob(10))
			donor.reagents.add_reagent(pick("saline", "salbutamol", "salicylic_acid", "charcoal"), 4)
