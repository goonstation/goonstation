/obj/item/organ/intestines
	name = "intestines"
	organ_name = "intestines"
	desc = "Did you know that if you laid your guts out in a straight line, they'd be about 9 meters long? Also, you'd probably be dying, so it's not something you should do. Probably."
	organ_holder_name = "intestines"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 4.0
	icon_state = "intestines"

	// on_transplant()
	// 	..()
	// 	if (src.donor)
	// 		for (var/datum/ailment_data/disease in src.donor.ailments)
	// 			if (disease.cure == "Intestine Transplant")
	// 				src.donor.cure_disease(disease)
	// 		return


	disposing()
		if (holder)
			if (holder.intestines == src)
				holder.intestines = null
		..()

/obj/item/organ/intestines/cyber
	name = "cyberintestines"
	desc = "A fancy robotic intestines to replace one that someone's lost!"
	icon_state = "cyber-intestines"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6

