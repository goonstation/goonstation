#if ENABLE_ARTEMIS
ABSTRACT_TYPE(/obj/item/artemis_engine_component)
/obj/item/artemis_engine_component
		name = "default engine component"
		desc = "OUUUUUUGHHGHHHHGHGHHGH(you shouldn't be seeing this please report this)"
		icon = 'icon/obj/items/device.dmi'
		icon_state = "signaller"

/obj/item/artemis_engine_component/plasma_exciter/New(material_name="steel")
		..()
		src.setMaterial(getMaterial(material_name))

/obj/item/artemis_engine_component/plasma_exciter
		name = "engine ionizer"
		desc = "engine ionizer"
		icon = 'icon/obj/items/device.dmi'
		icon_state = "signaller"
		var/conversion_rate = 0

/obj/item/artemis_engine_component/plasma_exciter/setupMaterial()
		conversion_rate = src.material.getProperty("radioactive")/10

/obj/item/artemis_engine_compoenent/casing
	name = "engine casing"
	desc = "engine casing"
	icon = 'icon/obj/items/device.dmi'
	icon_state = "powersink0"
	/// The integrity of the artemis engine casing
	var/integrity = 0
	/// Amount by which the integrity decreases
	var/degredation_rate = 0

/obj/item/artemis_engine_compoenent/casing/setupMaterial()
		var/chem_resist = src.material.getProperty("chemical")
		integrity = (src.material.getProperty("density")/2)*100
		if(chem_resist<1)
				degredation_rate = null
		else
				degredation_rate = max(1-log(chem_resist,11),0.01)
/obj/item/artemis_engine_compnent/coil
	name = "engine coil"
	desc = "engine coil"
	icon = 'icon/obj/items/device.dmi'
	icon_state = "scanner"
	var/field_strength = 0
	// var/malfunction_prob
/obj/item/artemis_engine_compnent/coil/setupMaterial()
		field_strength = src.material.getProperty("electrical")/10
#endif
