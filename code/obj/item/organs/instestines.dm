/obj/item/organ/intestines
	name = "intestines"
	organ_name = "intestines"
	desc = "Did you know that if you laid your guts out in a straight line, they'd be about 9 meters long? Also, you'd probably be dying, so it's not something you should do. Probably."
	organ_holder_name = "intestines"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 4
	icon_state = "intestines"
	var/digestion_efficiency = 1

	// on_transplant()
	// 	..()
	// 	if (src.donor)
	// 		for (var/datum/ailment_data/disease in src.donor.ailments)
	// 			if (disease.cure == "Intestine Transplant")
	// 				src.donor.cure_disease(disease)
	// 		return

	on_transplant(mob/M)
		. = ..()
		if(!broken)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_DIGESTION_EFFICIENCY, src, digestion_efficiency)

	on_removal()
		REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_DIGESTION_EFFICIENCY, src)
		. = ..()

	unbreakme()
		..()
		if(..() && donor)
			APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_DIGESTION_EFFICIENCY, src, digestion_efficiency)

	breakme()
		if(..() && donor)
			REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_DIGESTION_EFFICIENCY, src)

	disposing()
		if (holder)
			if (holder.intestines == src)
				holder.intestines = null
		..()

/obj/item/organ/intestines/synth
	name = "synthintestines"
	organ_name = "synthintestines"
	icon_state = "plant"
	desc = "The large intestine is made from a root like material... that's a bit unsettling."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_intestines", "plant_intestines_bloom")

/obj/item/organ/intestines/cyber
	name = "cyberintestines"
	desc = "A fancy robotic intestines to replace one that someone's lost!"
	icon_state = "cyber-intestines"
	// item_state = "heart_robo1"
	made_from = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	mats = 6

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		organ_abilities = list(/datum/targetable/organAbility/quickdigest)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W)) //TODO kyle's robotics configuration console/machine/thing
			digestion_efficiency = input(user, "Set the digestion efficiency of the cyberintestines, from 0 to 200 percent.", "Digenstion efficincy", "100") as num
			digestion_efficiency = clamp(digestion_efficiency, 0, 200) / 100
		else
			. = ..()
