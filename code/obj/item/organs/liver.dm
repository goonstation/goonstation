/obj/item/organ/liver
	name = "liver"
	organ_name = "liver"
	desc = "Ew, this thing is just the wurst."
	organ_holder_name = "liver"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 3
	icon_state = "liver"
	failure_disease = /datum/ailment/disease/liver_failure

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= fail_damage && prob(src.get_damage() * 0.2))
			donor.contract_disease(failure_disease,null,null,1)
		return 1

	on_broken(var/mult = 1)
		donor.take_toxin_damage(2*mult, 1)

	disposing()
		if (holder)
			if (holder.liver == src)
				holder.liver = null
		..()

/obj/item/organ/liver/synth
	name = "synthliver"
	organ_name = "synthliver"
	icon_state = "plant"
	desc = "For all you vegan Hannibal Lecters."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_liver", "plant_liver_bloom")

/obj/item/organ/liver/cyber
	name = "cyberliver"
	desc = "A fancy robotic liver to replace one that someone's lost!"
	icon_state = "cyber-liver"
	// item_state = "heart_robo1"
	made_from = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	mats = 6
	var/overloading = 0

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		organ_abilities = list(/datum/targetable/organAbility/liverdetox)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)

	on_life(var/mult = 1)
		if(!..())
			return 0
		if(overloading)
			if(donor.reagents.get_reagent_amount("ethanol") >= 5 * mult)
				donor.reagents.remove_reagent("ethanol", 5 * mult)
				donor.reagents.add_reagent("omnizine", 0.4 * mult)
				src.take_damage(0, 0, 3 * mult)
			else
				donor.reagents.remove_reagent("ethanol", 5 * mult)
				if(prob(20))
					boutput(donor, "<span class='alert'>You feel painfully sober.</span>")
				else if(prob(25)) //20% total
					boutput(donor, "<span class='alert'>You feel a burning in your liver!</span>")
					src.take_damage(2 * mult, 2 * mult, 0)
		return 1

	breakme()
		if(..())
			overloading = 0

	on_removal()
		overloading = 0
		. = ..()
