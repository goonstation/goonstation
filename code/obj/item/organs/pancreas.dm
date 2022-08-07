/obj/item/organ/pancreas
	name = "pancreas"
	organ_name = "pancreas"
	organ_holder_name = "pancreas"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 6
	icon_state = "pancreas"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/pancreatitis

	on_life(var/mult = 1)
		if (!..())
			return 0
		if(!emagged) //emagged pancreas doesn't regulate sugar for you anymore.
			if (donor.reagents && donor.reagents.get_reagent_amount("sugar") > 80)
				if (prob(50))
					donor.reagents.add_reagent("insulin", 1 * mult)
					if(!robotic) //don't kill a cyberpancreas
						src.take_damage(0, 0, 10)
				else if (prob(50))
					if (donor.reagents.get_reagent_amount("sugar") > 200)
						donor.reagents.add_reagent("insulin", 2 * mult)
						if(!robotic)
							src.take_damage(0, 0, 40)

			if (src.get_damage() >= 65 && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1

	disposing()
		if (holder)
			if (holder.pancreas == src)
				holder.pancreas = null
		..()

/obj/item/organ/pancreas/synth
	name = "synthpancreas"
	organ_name = "synthpancreas"
	icon_state = "plant"
	desc = "A plant-based alternative to the normal pancreas..."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_pancreas", "plant_pancreas_bloom")

/obj/item/organ/pancreas/cyber
	name = "cyberpancreas"
	desc = "A fancy robotic pancreas to replace one that someone's lost!"
	icon_state = "cyber-pancreas"
	// item_state = "heart_robo1"
	made_from = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	mats = 6

	on_life(var/mult = 1)
		if (!..())
			return 0
		if(!donor.reagents)
			return 1
		if((donor.reagents.get_reagent_amount("sugar") < 20 || emagged) && donor.reagents.get_reagent_amount("glaucogen") <= 5)
			donor.reagents.add_reagent("glaucogen", 1 * mult)
		if(emagged) //keep you on a real sugar high. Make sure to pack some insulin!
			if(donor.reagents.get_reagent_amount("epinephrine") < 10)
				donor.reagents.add_reagent("epinephrine", 1 * mult)
			if(donor.reagents.get_reagent_amount("ephedrine") < 10) //this is maybe a bad idea. leaving it in for now
				donor.reagents.add_reagent("ephedrine", 1 * mult)


