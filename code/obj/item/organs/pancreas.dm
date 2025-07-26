/obj/item/organ/pancreas
	name = "pancreas"
	organ_name = "pancreas"
	organ_holder_name = "pancreas"
	organ_holder_location = "chest"
	icon_state = "pancreas"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/pancreatitis
	surgery_flags = SURGERY_SNIPPING | SURGERY_CUTTING
	region = SUBCOSTAL

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

TYPEINFO(/obj/item/organ/pancreas/cyber)
	mats = 6

/obj/item/organ/pancreas/cyber
	name = "cyberpancreas"
	desc = "A fancy robotic pancreas to replace one that someone's lost!"
	icon_state = "cyber-pancreas"
	// item_state = "heart_robo1"
	default_material = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0

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

/obj/item/organ/pancreas/amphibian
	name = "amphibian pancreas"
	organ_name = "amphibian pancreas"
	icon_state = "amphibian_pancreas"
	desc = "Are you sure this is a pancreas?"

/obj/item/organ/pancreas/skeleton
	name = "skeleton pancreas"
	desc = "This is, allegedly, a skeleton pancreas. Not that you'd be able to tell by looking."
	icon_state = "skeleton_pancreas"
	default_material = "bone"
	blood_reagent = "calcium"

/obj/item/organ/pancreas/martian
	name = "pliable lump"
	desc = "This is... probably a pancreas."
	icon_state = "martian_pancreas"
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	default_material = "viscerite"
