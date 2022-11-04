
#define BONE_HEALTHY 0
#define BONE_BRUISED 1
#define BONE_CRACKED 2
#define BONE_FRACTURED 4
#define BONE_SHATTERED 8

/* sticking these here just for reference
#define DAMAGE_BLUNT 1
#define DAMAGE_CUT 2
#define DAMAGE_STAB 4
#define DAMAGE_BURN 8
#define DAMAGE_CRUSH 16
*/
/proc/bone_num2name(var/damtype)
	if (isnull(damtype))
		return "error"
	switch (damtype)
		if (BONE_HEALTHY)
			return "bone_healthy"
		if (BONE_BRUISED)
			return "bone_bruised"
		if (BONE_CRACKED)
			return "bone_cracked"
		if (BONE_FRACTURED)
			return "bone_fractured"
		if (BONE_SHATTERED)
			return "bone_shattered"
	return "error"

#define BONE_DEBUG(x) if (bone_system) message_coders(x)

/datum/bone
	var/name = "bone" // what we are
	var/mob/living/carbon/human/donor = null // our house
	var/parent_organ = null // where we are in our house
	var/damage = 0 // how many times we've stubbed our toe on that table we hate
	var/damage_status = 0 // puts us into groups of table hatred

	disposing()
		donor = null
		..()

	proc/take_damage(var/damage_type, var/amt = 1)
		if (!bone_system)
			return 0

		if (!donor || !src.parent_organ) // I can't see a reason we'd still need to damage this thing if it's just kinda floating in the void somewhere
			BONE_DEBUG("a bone datum lacks a donor or parent_organ so take_damage() was canceled, oops")
			return 0 // ghostbones

		BONE_DEBUG("[donor]'s [parent_organ]'s bones.take_damage() entered")

		var/damtype_modifier = 1
		if (damage_type == DAMAGE_BURN)
			damtype_modifier = 0.6
		else if (damage_type == DAMAGE_STAB)
			damtype_modifier = 0.6
		else if (damage_type == DAMAGE_BLUNT)
			damtype_modifier = 1.3
		else if (damage_type == DAMAGE_CRUSH)
			damtype_modifier = 1.5

		if (!((amt * damtype_modifier) > 0))
			return 0

		BONE_DEBUG("[donor]'s [parent_organ]'s bones.take_damage() amt: [amt], damage_type: [dam_num2name(damage_type)], damtype_modifier: [damtype_modifier], initial bone damage: [src.damage], damage changing to [src.damage + (amt * damtype_modifier)], initial damage_status: [bone_num2name(src.damage_status)]")
		src.damage += (amt * damtype_modifier)

		if (prob((10 + src.damage) * damtype_modifier))
			src.damage_status = max(1, src.damage_status * 2) // a chance to bump up the current damage_status level
			BONE_DEBUG("[donor]'s [parent_organ]'s bones rolled increase in damage level at prob (20 + [src.damage]) * [damtype_modifier] = [(20 + src.damage) * damtype_modifier]")

		switch (src.damage_status)
			if (BONE_HEALTHY)
				BONE_DEBUG("[donor]'s [parent_organ]'s bones bruised")
				src.damage_status = BONE_BRUISED
				src.donor.show_text("Your [src.parent_organ] hurts!", "red")

			if (BONE_BRUISED)
				BONE_DEBUG("[donor]'s [parent_organ]'s bones cracked")
				src.damage_status = BONE_CRACKED
				src.donor.show_text("Your [src.parent_organ] hurts like hell!", "red")

			if (BONE_CRACKED)
				BONE_DEBUG("[donor]'s [parent_organ]'s bones fractured")
				src.damage_status = BONE_FRACTURED
				src.donor.visible_message("<span class='alert'>[src.donor]'s [src.parent_organ] emits a [pick("", "disturbing ", "unsettling ", "worrying ")][pick("crack", "crunch", "snap")]!</span>",\
				"<span class='alert'><b>You feel something in your [src.parent_organ] break!</b></span>")

			if (BONE_FRACTURED)
				BONE_DEBUG("[donor]'s [parent_organ]'s bones shattered")
				src.damage_status = BONE_SHATTERED
				src.donor.visible_message("<span class='alert'>[src.donor]'s [src.parent_organ] emits a [pick("", "disturbing ", "unsettling ", "worrying ")][pick("crack", "crunch", "snap")]!</span>",\
				"<span class='alert'><b>You feel something in your [src.parent_organ] shatter!</b></span>")

	proc/repair_damage(var/amt)
		if (!amt)
			return 0
		if (istext(amt) && lowertext(amt) == "all")
			src.damage = 0
			src.damage_status = BONE_HEALTHY

#undef BONE_HEALTHY
#undef BONE_BRUISED
#undef BONE_CRACKED
#undef BONE_FRACTURED
#undef BONE_SHATTERED
