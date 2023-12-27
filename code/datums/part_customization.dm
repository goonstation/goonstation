ABSTRACT_TYPE(/datum/part_customization)
/datum/part_customization
	var/id = "INVALID"
	var/slot = "INVALID"
	///Can be a type or a list of types to randomly pick from
	var/part_type = null
	var/base_64_cache = null
	var/trait_cost = 0 //idk let's keep using trait points for now

	proc/apply_to(mob/M)
		return

	///UI helper proc so we don't have to manage static data caches
	proc/get_base64_icon()
		if (!src.base_64_cache)
			var/obj/item/part_type = pick(src.part_type) //funny initial abuse
			src.base_64_cache = icon2base64(icon(initial(part_type.icon), initial(part_type.icon_state), dir=SOUTH, frame=1, moving=0))
		return src.base_64_cache

	proc/get_name()
		var/obj/item/part_type = pick(src.part_type)
		return initial(part_type.name)

ABSTRACT_TYPE(/datum/part_customization/human)
/datum/part_customization/human

	apply_to(mob/living/carbon/human/human)
		if (!istype(human))
			return
		//assume it's only limbs for humans for now, maybe also include eyes and stuff in future??
		human.limbs.replace_with(src.slot, pick(src.part_type), null, FALSE, TRUE) //pick can totally handle single values apparently

	default_left
		id = "arm_default_left"
		slot = "l_arm"
		part_type = /obj/item/parts/human_parts/arm/left

		apply_to(mob/living/carbon/human/human)
			if (ishuman(human) && istype(human.limbs.l_arm, human.mutantrace.l_limb_arm_type_mutantrace))
				return
			..()

	default_right
		id = "arm_default_right"
		slot = "r_arm"
		part_type = /obj/item/parts/human_parts/arm/right

		apply_to(mob/living/carbon/human/human)
			if (ishuman(human) && istype(human.limbs.r_arm, human.mutantrace.r_limb_arm_type_mutantrace))
				return
			..()

	robo_left
		id = "arm_robo_left"
		slot = "l_arm"
		part_type = /obj/item/parts/robot_parts/arm/left/light

	robo_right
		id = "arm_robo_right"
		slot = "r_arm"
		part_type = /obj/item/parts/robot_parts/arm/right/light

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
