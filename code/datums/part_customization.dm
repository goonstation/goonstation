ABSTRACT_TYPE(/datum/part_customization)
///These are SINGLETONS
/datum/part_customization
	var/id = "INVALID"
	var/slot = "INVALID"
	///Can be a type or a list of types to randomly pick from
	var/part_type = null
	var/base_64_cache = null
	var/trait_cost = 0 //idk let's keep using trait points for now
	///Cannot be added alongside these part IDs
	var/incompatible_parts = list()
	///Custom icon overrides, otherwise just uses the part icon
	var/custom_icon = null
	var/custom_icon_state = null

	///Check if we can, then apply the part
	proc/try_apply(mob/M, list/custom_parts = null)
		if (src.can_apply(M, custom_parts))
			src.apply_to(M)
			return TRUE
		return FALSE

	///Actually add the part
	proc/apply_to(mob/M)
		PROTECTED_PROC(TRUE)
		return

	///Can we add the part, `custom_parts` is an associative list of slot IDs to part IDs
	proc/can_apply(mob/M, list/custom_parts = null)
		SHOULD_CALL_PARENT(TRUE)
		for (var/slot_id in custom_parts)
			if (custom_parts[slot_id] in src.incompatible_parts)
				return FALSE
		return TRUE

	///UI helper proc so we don't have to manage static data caches
	proc/get_base64_icon()
		if (!src.base_64_cache)
			if (!src.custom_icon)
				var/obj/item/part_type = pick(src.part_type) //funny initial abuse
				src.base_64_cache = icon2base64(icon(initial(part_type.icon), initial(part_type.icon_state), dir=SOUTH, frame=1, moving=0))
			else
				src.base_64_cache = icon2base64(icon(src.custom_icon, src.custom_icon_state))
		return src.base_64_cache

	///Defaults to just the name of the part type, can be overridden
	proc/get_name()
		var/obj/item/part_type = pick(src.part_type)
		return initial(part_type.name)

ABSTRACT_TYPE(/datum/part_customization/human)
/datum/part_customization/human

	apply_to(mob/living/carbon/human/human)
		//assume it's only limbs for humans for now, maybe also include eyes and stuff in future??
		var/limb_type = pick(src.part_type)
		if(human.limbs.get_limb(slot)?.type != limb_type)
			human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE) //pick can totally handle single values apparently

	can_apply(mob/M)
		return ..() && ishuman(M)

	default_left
		id = "arm_default_left"
		slot = "l_arm"
		part_type = /obj/item/parts/human_parts/arm/left

		apply_to(mob/living/carbon/human/human)
			var/limb_type = human.mutantrace.l_limb_arm_type_mutantrace
			if (human.gender == FEMALE) //gendered limbs???
				limb_type = human.mutantrace.l_limb_arm_type_mutantrace_f || limb_type
			if (!limb_type)
				limb_type = src.part_type
			if(human.limbs.l_arm?.type != limb_type)
				human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE)

	default_right
		id = "arm_default_right"
		slot = "r_arm"
		part_type = /obj/item/parts/human_parts/arm/right

		apply_to(mob/living/carbon/human/human)
			var/limb_type = human.mutantrace.r_limb_arm_type_mutantrace
			if (human.gender == FEMALE) //gendered limbs???
				limb_type = human.mutantrace.r_limb_arm_type_mutantrace_f || limb_type
			if (!limb_type)
				limb_type = src.part_type
			if(!human.limbs.r_arm?.type == limb_type)
				human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE)

	robo_left
		id = "arm_robo_left"
		slot = "l_arm"
		part_type = /obj/item/parts/robot_parts/arm/left/light

	robo_right
		id = "arm_robo_right"
		slot = "r_arm"
		part_type = /obj/item/parts/robot_parts/arm/right/light

	robo_standard_left
		id = "arm_robo_standard_left"
		slot = "l_arm"
		part_type = /obj/item/parts/robot_parts/arm/left/standard
		trait_cost = 1
		incompatible_parts = list("arm_robo_standard_right")

	robo_standard_right
		id = "arm_robo_standard_right"
		slot = "r_arm"
		part_type = /obj/item/parts/robot_parts/arm/right/standard
		trait_cost = 1
		incompatible_parts = list("arm_robo_standard_left")

	plant_left
		id = "arm_plant_left"
		slot = "l_arm"
		trait_cost = 1
		part_type = list(/obj/item/parts/human_parts/arm/left/synth/bloom, /obj/item/parts/human_parts/arm/left/synth)

	plant_right
		id = "arm_plant_right"
		slot = "r_arm"
		trait_cost = 1
		part_type = list(/obj/item/parts/human_parts/arm/right/synth/bloom, /obj/item/parts/human_parts/arm/right/synth)

ABSTRACT_TYPE(/datum/part_customization/human/missing)
/datum/part_customization/human/missing
	custom_icon = 'icons/ui/character_editor.dmi'
	custom_icon_state = "missing"

	apply_to(mob/living/carbon/human/human)
		var/obj/item/parts/limb = human.limbs.get_limb(src.slot)
		limb?.remove(0)
		qdel(limb)

	left
		id = "arm_missing_left"
		slot = "l_arm"
		incompatible_parts = list("arm_missing_right")

		get_name()
			return "missing left arm"

	right
		id = "arm_missing_right"
		slot = "r_arm"
		incompatible_parts = list("arm_missing_left")

		get_name()
			return "missing right arm"

///Lazy init singleton list
var/list/datum/part_customization/part_customizations = null

proc/get_part_customization(id)
	if (!part_customizations)
		part_customizations = list()
		for (var/datum/part_customization/type as anything in concrete_typesof(/datum/part_customization))
			part_customizations[initial(type.id)] = new type
	return part_customizations[id]

//TODO: extend this to work with borgs too

// /datum/part_customization/cyborg
// 	var/complexity_cost = 1 //idk

// 	screen_head
// 		slot = "head"
// 		part_type =
