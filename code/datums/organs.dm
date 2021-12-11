/*
/datum/organ
	var/name = "organ"
	var/mob/owner = null
	var/organ_id = "organ"
	var/brute_dam = 0
	var/burn_dam = 0
	var/tox_dam = 0

/datum/organ/proc/process()
	return

// could probably use this with reagents
//datum/organ/proc/receive_chem(datum/reagent/R)
//	return

/datum/organ/proc/take_damage(brute, burn, tox, disallow_limb_loss)
	if (brute <= 0 && burn <= 0 && tox <= 0)
		return 0
	src.brute_dam += brute
	src.burn_dam += burn
	src.tox_dam += tox

	if (ismob(owner))
		var/mob/M = owner
		M.hit_twitch()
		M.UpdateDamage()
	return 1

/datum/organ/proc/heal_damage(brute, burn, tox)
	if (brute_dam <= 0 && burn_dam <= 0 && tox_dam <= 0)
		return 0
	src.brute_dam = max(0, src.brute_dam - brute)
	src.burn_dam = max(0, src.burn_dam - burn)
	src.tox_dam = max(0, src.tox_dam - tox)
	return 1

/datum/organ/proc/get_damage()	//returns total damage
	return src.brute_dam + src.burn_dam	+ src.tox_dam //could use src.health?

/obj/item/organ
	name = "external"
	organ_id = "organ"
	var/icon_name = null
	var/datum/bone/bones = null

	INIT()
		..()
		if (src.owner)
			src.bones = new /datum/bone(src)
			src.bones.donor = src.owner

	take_damage(brute, burn, tox, disallow_limb_loss)
		. = ..()
		if (src.bones && brute > 30 && prob(brute - 30))
			src.bones.take_damage()

/obj/item/organ/chest
	name = "chest"
	icon_name = "chest"
	organ_id = "chest"

/obj/item/organ/head
	name = "head"
	icon_name = "head"
	organ_id = "head"

/obj/item/organ/limb
	name = "limb"
	organ_id = "limb"
	var/obj/item/parts/limb_item = null

	take_damage(brute, burn, tox, disallow_limb_loss)
		. = ..()
		if (brute > 30 && prob(brute - 30) && !disallow_limb_loss)
			if (ishuman(src.owner) && istype(src.limb_item))
				src.limb_item.sever()

/obj/item/organ/limb/l_arm
	name = "left arm"
	icon_name = "l_arm"
	organ_id = "l_arm"

	INIT()
		..()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = src.owner
			if (H.limbs && H.limbs.l_arm)
				limb_item = H.limbs.l_arm

/obj/item/organ/limb/l_leg
	name = "left leg"
	icon_name = "l_leg"
	organ_id = "l_leg"

	INIT()
		..()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = src.owner
			if (H.limbs && H.limbs.l_leg)
				limb_item = H.limbs.l_leg

/obj/item/organ/limb/r_arm
	name = "right arm"
	icon_name = "r_arm"
	organ_id = "r_arm"

	INIT()
		..()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = src.owner
			if (H.limbs && H.limbs.r_arm)
				limb_item = H.limbs.r_arm

/obj/item/organ/limb/r_leg
	name = "right leg"
	icon_name = "r_leg"
	organ_id = "r_leg"

	INIT()
		..()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = src.owner
			if (H.limbs && H.limbs.r_leg)
				limb_item = H.limbs.r_leg

/datum/organ/internal
	name = "internal"

/datum/organ/internal/brain
	name = "brain"
	organ_id = "brain"

/datum/organ/internal/heart
	name = "heart"
	organ_id = "heart"

/datum/organ/internal/lungs
	name = "lungs"
	organ_id = "lungs"

/datum/organ/internal/stomach
	name = "stomach"
	organ_id = "stomach"

/datum/organ/internal/liver
	name = "liver"
	organ_id = "liver"

/datum/organ/internal/intestines
	name = "intestines"
	organ_id = "intestines"
*/
