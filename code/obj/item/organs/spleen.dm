/obj/item/organ/spleen
	name = "spleen"
	organ_name = "spleen"
	organ_holder_name = "spleen"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 6
	icon_state = "spleen"
	body_side = L_ORGAN


	on_life(var/mult = 1)
		if (!..())
			return 0
		if (donor.blood_volume < 500 && donor.blood_volume > 0) // if we're full or empty, don't bother v
			if (prob(66))
				donor.blood_volume += 1 * mult // maybe get a little blood back ^
			else if (src.robotic)  // garuanteed extra blood with robotic spleen
				donor.blood_volume += 2 * mult
		else if (donor.blood_volume > 500)
			if (prob(20))
				donor.blood_volume -= 1 * mult
		if(emagged)
			donor.blood_volume += 2 * mult //Don't worry friend, you'll have /plenty/ of blood!
		return 1

	on_broken(var/mult = 1)
		donor.blood_volume -= 2 * mult

	disposing()
		if (holder)
			if (holder.spleen == src)
				holder.spleen = null
		..()

/obj/item/organ/spleen/synth
	name = "synthspleen"
	organ_name = "synthspleen"
	icon_state = "plant"
	desc = "I guess you could say, the person missing this has spleen better days!"
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_spleen", "plant_spleen_bloom")

TYPEINFO(/obj/item/organ/spleen/cyber)
	mats = 6

/obj/item/organ/spleen/cyber
	name = "cyberspleen"
	desc = "A fancy robotic spleen to replace one that someone's lost!"
	icon_state = "cyber-spleen"
	made_from = "pharosium"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	created_decal = /obj/decal/cleanable/oil
