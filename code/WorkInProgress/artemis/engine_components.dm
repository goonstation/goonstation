#if ENABLE_ARTEMIS
ABSTRACT_TYPE(/obj/item/artemis_engine_component)
/obj/item/artemis_engine_component
		name = "default engine component"
		desc = "OUUUUUUGHHGHHHHGHGHHGH(you shouldn't be seeing this please report this)"
		icon = 'icons/obj/items/device.dmi'
		icon_state = "signaller"

/obj/item/artemis_engine_component/proc/setup_material()

/obj/item/artemis_engine_component/New(material_name = "steel")
		..()
		src.setMaterial(getMaterial(material_name))
		setup_material()

/obj/item/artemis_engine_component/plasma_exciter
		name = "engine ionizer"
		desc = "engine ionizer"
		icon = 'icons/obj/items/device.dmi'
		icon_state = "signaller"

		var/conversion_rate = 0

/obj/item/artemis_engine_component/plasma_exciter/setup_material()
		conversion_rate = src.material.getProperty("radioactive") / 10

/obj/item/artemis_engine_component/casing
	name = "engine casing"
	desc = "engine casing"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "powersink0"

	var/integrity = 0
	///full integrity for tgui purposes
	var/full_integrity
	var/degredation_rate = 0

/obj/item/artemis_engine_component/casing/setup_material()
		var/chem_resist = src.material.getProperty("chemical")
		src.integrity = (src.material.getProperty("density") / 2) * 100
		src.full_integrity = integrity

		if(chem_resist<1)
				src.degredation_rate = null
		else
				src.degredation_rate = max(1 - log(11 , chem_resist) , 0.01)

/obj/item/artemis_engine_component/coil
	name = "engine coil"
	desc = "engine coil"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "scanner"
	var/field_strength = 0
	// var/malfunction_prob

/obj/item/artemis_engine_component/coil/setup_material()
		field_strength = src.material.getProperty("electrical") / 10
#endif
