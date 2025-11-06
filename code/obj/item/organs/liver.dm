/obj/item/organ/liver
	name = "liver"
	organ_name = "liver"
	desc = "Ew, this thing is just the wurst."
	organ_holder_name = "liver"
	organ_holder_location = "chest"
	icon = 'icons/obj/items/organs/liver.dmi'
	icon_state = "liver"
	failure_disease = /datum/ailment/disease/liver_failure
	surgery_flags = SURGERY_SNIPPING | SURGERY_CUTTING
	region = SUBCOSTAL

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= fail_damage && prob(src.get_damage() * 0.2))
			donor.contract_disease(failure_disease,null,null,1)
		return 1

	on_broken(var/mult = 1)
		var/damage = 2 * mult
		if (src.donor.hasStatus("dialysis"))
			damage /= 3
		donor.take_toxin_damage(damage, TRUE)

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

TYPEINFO(/obj/item/organ/liver/cyber)
	mats = 6

/obj/item/organ/liver/cyber
	name = "cyberliver"
	desc = "A fancy robotic liver to replace one that someone's lost!"
	icon_state = "cyber-liver"
	// item_state = "heart_robo1"
	default_material = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
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
					boutput(donor, SPAN_ALERT("You feel painfully sober."))
				else if(prob(25)) //20% total
					boutput(donor, SPAN_ALERT("You feel a burning in your liver!"))
					src.take_damage(2 * mult, 2 * mult, 0)
		return 1

	breakme()
		if(..())
			overloading = 0

	on_removal()
		overloading = 0
		. = ..()

/obj/item/organ/liver/amphibian
	name = "amphibian liver"
	desc = "Jesus Christ, this liver's massive... oh. It all makes sense now."
	icon_state = "amphibian_liver"

/obj/item/organ/liver/skeleton
	name = "skeleton liver"
	desc = "This is a skeleton liver. A clear abomination of God."
	icon_state = "skeleton_liver"
	default_material = "bone"
	blood_reagent = "calcium"

/obj/item/organ/liver/martian
	name = "purple slab"
	desc = "A rather strange looking martian liver. Or, at least, you think it's a liver."
	icon_state = "martian_liver"
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	default_material = "viscerite"
