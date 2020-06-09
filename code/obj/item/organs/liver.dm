/obj/item/organ/liver
	name = "liver"
	organ_name = "liver"
	desc = "Ew, this thing is just the wurst."
	organ_holder_name = "liver"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 3.0
	icon_state = "liver"
	failure_disease = /datum/ailment/disease/liver_failure

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= FAIL_DAMAGE && prob(src.get_damage() * 0.2))
			donor.contract_disease(failure_disease,null,null,1)
		return 1

	on_broken(var/mult = 1)
		donor.take_toxin_damage(2*mult, 1)				

	disposing()
		if (holder)
			if (holder.liver == src)
				holder.liver = null
		..()

/obj/item/organ/liver/cyber
	name = "cyberliver"
	desc = "A fancy robotic liver to replace one that someone's lost!"
	icon_state = "cyber-liver"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
