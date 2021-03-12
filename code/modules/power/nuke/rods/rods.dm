/obj/item/nuke/rod

	icon = 'icons/obj/machines/nuclear.dmi'
	icon_state = "fr0"

	var
		initial_volume = 100
		//datum/material/fissile/initial_materials[] = list();
		sv_ratio = 1.0

		/* emission ratio per cardinal direction -- these should all add up to 1.0, default is to emit radiation omnidirectionally in equal ratios */
		flux_card_n = 0.25
		flux_card_e = 0.25
		flux_card_s = 0.25
		flux_card_w = 0.25

		internal_heat = 0
		amb_heat = 0

	proc/get_flux()
		var/datum/material/fissile/mat = src.material
		return initial_volume * mat.epv

	u235_test
		name = "U235 for testing"
		desc = "todo"

		initial_volume = 50

		sv_ratio = 1.22

		New()
			..()
			var/datum/material/fissile/u238/m1 = new/datum/material/fissile/u235()
			material = m1
			setMaterial(/datum/material/fissile/u238)

	pu239_test
		name = "Pu239 for testing"
		desc = "todo"

		initial_volume = 50

		sv_ratio = 1.22

		New()
			..()
			var/datum/material/fissile/pu239/D = new/datum/material/fissile/pu239()
			material = D
			setMaterial(/datum/material/fissile/pu239)


	kfuel_test
		name = "kremlin's fuel for testing"
		desc = "todo"

		initial_volume = 50

		sv_ratio = 1.22

		New()
			..()
			var/datum/material/fissile/kremfuel/D = new/datum/material/fissile/kremfuel
			material = D
			setMaterial(/datum/material/fissile/kremfuel)
