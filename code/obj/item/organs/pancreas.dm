/obj/item/organ/pancreas
	name = "pancreas"
	organ_name = "pancreas"
	organ_holder_name = "pancreas"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 6.0
	icon_state = "pancreas"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/pancreatitis

	on_life(var/mult = 1)
		if (!..())
			return 0

		if (donor.reagents && donor.reagents.get_reagent_amount("sugar") > 80)	
			if (prob(50))
				donor.reagents.add_reagent("insulin", 1 * mult)
				src.take_damage(0, 0, 10)
			else if (prob(50))
				if (donor.reagents.get_reagent_amount("sugar") > 200)	
					donor.reagents.add_reagent("insulin", 2 * mult)
					src.take_damage(0, 0, 40)

			if (src.get_damage() >= 65 && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1
		
	disposing()
		if (holder)
			if (holder.pancreas == src)
				holder.pancreas = null
		..()

/obj/item/organ/pancreas/cyber
	name = "cyberpancreas"
	desc = "A fancy robotic pancreas to replace one that someone's lost!"
	icon_state = "cyber-pancreas"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
