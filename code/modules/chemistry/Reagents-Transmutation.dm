#define MIN_REAGENT_FOR_CONVERSION 5
ABSTRACT_TYPE(/datum/reagent/transmutation)
/datum/reagent/transmutation
	var/material_name = "steel"

	reaction_turf(var/turf/T, var/volume)
		. = ..()
		if (volume < MIN_REAGENT_FOR_CONVERSION)
			return

		if (!T)
			return

		T.setMaterial(getMaterial(src.material_name))

	reaction_obj(var/obj/O, var/volume)
		. = ..()
		if (volume < MIN_REAGENT_FOR_CONVERSION)
			return

		if (!O)
			return

		O.setMaterial(getMaterial(src.material_name))

/datum/reagent/transmutation/custom
	name = "transmutium"
	id = "custom_transmutation"
	random_chem_blacklisted = TRUE

	on_add()
		. = ..()
		if (!istext(src.data))
			return

		src.material_name = data
		var/datum/material/material = getMaterial(src.material_name)
		var/colorList = hex_to_rgb_list(material.getColor())

		fluid_r = colorList[1]
		fluid_g = colorList[2]
		fluid_b = colorList[3]


/// Jeans reagent turns turfs and objects into jeans
/// and on touch on humans will convert their clothes into jeans material
/datum/reagent/transmutation/jeans
	name = "liquid jeans"
	id = "jeans"
	fluid_r = 39
	fluid_g = 78
	fluid_b = 133
	taste = "like a good quality all wear garment"
	reagent_state = LIQUID
	material_name = "jean"

	var/list/jean_affected_slots = list(
		SLOT_BACK,
		SLOT_WEAR_MASK,
		SLOT_BELT,
		SLOT_WEAR_ID,
		SLOT_EARS,
		SLOT_GLASSES,
		SLOT_GLOVES,
		SLOT_HEAD,
		SLOT_SHOES,
		SLOT_WEAR_SUIT,
		SLOT_W_UNIFORM)

	proc/handle_mob_touch(mob/living/M, volume)
		if (!ishuman(M))
			return

		if (volume < MIN_REAGENT_FOR_CONVERSION)
			return

		var/mob/living/carbon/human/human = M
		var/update_required = FALSE
		for (var/slot in jean_affected_slots)
			var/obj/item/I = human.get_slot(slot)

			if (!I)
				continue

			if (I.material?.isSameMaterial(getMaterial(src.material_name)))
				continue

			volume = max(0, volume - MIN_REAGENT_FOR_CONVERSION)
			if (volume == 0)
				break

			I.setMaterial(getMaterial(src.material_name))
			update_required = TRUE

		if (update_required)
			human.update_clothing()

	reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
		. = ..()
		if (!M || volume <= 0)
			return

		if (method != TOUCH)
			return

		handle_mob_touch(M, volume)

/datum/reagent/transmutation/carpet
	name = "carpet"
	id = "carpet"
	description = "A covering of thick fabric used on floors. This type looks particularly gross."
	reagent_state = LIQUID
	fluid_r = 112
	fluid_b = 69
	fluid_g = 19
	transparency = 255
	value = 4 // 2 2
	viscosity = 0.3
	material_name = "carpet"
#undef MIN_REAGENT_FOR_CONVERSION
