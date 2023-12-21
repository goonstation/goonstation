/obj/item/organ/flock_crystal
	name = "jagged crystal"
	organ_name = "jagged crystal"
	blood_type = "flockdrone_fluid"
	blood_color = "#1bdebd"
	desc = "That thing should not be in there, nopenopenope."
	icon = 'icons/obj/materials.dmi'
	icon_state = "ore$$starstone" //wooo reused sprites
	mat_changename = FALSE
	broken = TRUE
	unusual = TRUE
	surgery_flags = SURGERY_CUTTING | SURGERY_SNIPPING

	New(loc, datum/organHolder/nholder)
		. = ..()
		var/datum/material/M = getMaterial("gnesis")
		src.setMaterial(M, appearance = TRUE, setname = FALSE) //default_material breaks for some reason
		src.icon_state = initial(src.icon_state) //stop the material resetting the icon state

	on_life(var/mult = 1)
		if (probmult(7))
			src.donor.visible_message(SPAN_ALERT("[src.donor] vomits up a viscous teal liquid!"), SPAN_ALERT("You vomit up a viscous teal liquid!"))
			src.donor.vomit(0, /obj/decal/cleanable/flockdrone_debris/fluid)

	get_damage()
		return 500
