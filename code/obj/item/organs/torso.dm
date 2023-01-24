/*===========================*/
/*---------- Torso ----------*/
/*===========================*/

/obj/item/organ/chest // basically a dummy thing right now, this shouldn't do anything or go anywhere
	name = "chest"
	organ_name = "chest"
	desc = "Oh, crap."
	icon_state = "chest_m"
	edible = 0
	max_damage = INFINITY

	var/datum/appearanceHolder/donor_appearance = null
	//var/datum/mutantrace/donor_mutantrace = null

	var/icon/body_icon = null

	New()
		..()
		SPAWN(1 SECOND)
			if (src.donor)
				if(!src.bones)
					src.bones = new /datum/bone(src)
				src.bones.donor = src.donor
				src.bones.parent_organ = src.organ_name
				src.bones.name = "ribs"
				if (src.donor.bioHolder && src.donor.bioHolder.mobAppearance)
					src.donor_appearance = new(src)
					src.donor_appearance.CopyOther(src.donor.bioHolder.mobAppearance)
				src.UpdateIcon()

	disposing()
		if (holder)
			holder.chest = null
		..()

	update_icon()
		if (!src.donor || !src.donor_appearance)
			return // vOv

		src.body_icon = new /icon(src.icon, src.icon_state)

		if (src.donor_appearance.s_tone)
			src.body_icon.Blend(src.donor_appearance.s_tone, ICON_MULTIPLY)

		src.body_icon.Blend(icon(src.icon, "chest_blood"), ICON_OVERLAY)

		src.icon = src.body_icon

	//damage/heal obj. Provide negative values for healing.	//maybe I'll change cause I don't like this. But this functionality is found in some other damage procs for other things, might as well keep it consistent.
	take_damage(brute, burn, tox, damage_type)
		..()

		if (brute > 5 && holder)
			if(prob(60))
				src.holder.damage_organs(brute/5, 0, 0, list("liver", "left_kidney", "right_kidney", "stomach", "intestines","appendix", "pancreas", "tail"), 30)
			else if (prob(30))
				src.holder.damage_organs(brute/10, 0, 0, list("spleen", "left_lung", "right_lung"), 50)

	heal_damage(brute, burn, tox)
		if (brute_dam <= 0 && burn_dam <= 0 && tox_dam <= 0)
			return 0
		src.brute_dam = max(0, src.brute_dam - brute)
		src.burn_dam = max(0, src.burn_dam - burn)
		src.tox_dam = max(0, src.tox_dam - tox)
		return 1
