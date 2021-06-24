/*
	-- D E F S --

	vars:
		nuke_compat: 1 to mark reagent as suitable for nuclear reactor input. all reagents in this file should set this
		fissile: 1 if reagent emits particle radition suitable for fission-type reactions. "is it nuclear fuel"
		part_type: emission particle type. currently only 'neutron' is valid
		epv: emissivity per volume unit -- rate at which particles emit per mass (err, "vol") unit
		hpe: heat generated per emission -- rate at which heat is generated per scalar emission amount
		absorb: percentage of incoming particle flux absorbed -- 1.0 = perfect particle shield, 0 = vaccum
		k_factor: criticality factor, rate at which new particles are generated/emitted per particle absorbtion. "The six factor formula effective neutron multiplication factor"
		products: list of byproducts created when parent reagent undergoes fission. requires products_r
		products_r: percentage at which the above byproducts are created. 1-to-1, must match index of above. requires products
*/
datum
	material
		fissile
			var
				nuke_compat = 1
				fissile = 0
				part_type = "neutron"
				epv = 0
				hpe = 0
				absorb = 0.0
				k_factor = 0

datum
	material
		fissile
			u238
				name = "uranium-238"
				mat_id = "u-238"
				desc = "A slightly radioactive heavy metal not suitable for nuclear fission. This is the unenriched byproduct form."
				color = "#1E461E"
				alpha = 255
				material_flags = MATERIAL_METAL

				nuke_compat = 1
				fissile = 1
				part_type = "neutron"
				epv = 0.1
				hpe = 20
				absorb = 0.90
				k_factor = 0.3

				New()
					..()
					setProperty("density", 75)
					setProperty("fissile", 10)
					setProperty("radioactive", 25)
					setProperty("hard", 50)
					setProperty("thermal", 50)
					setProperty("stability", 80)

			u235
				name = "uranium-235"
				mat_id = "u-235"
				desc = "A radioactive dull silver-green heavy metal. This is the enriched form suitable for use as nuclear fuel."
				color = "#286428"
				alpha = 255
				material_flags = MATERIAL_METAL | MATERIAL_ENERGY

				nuke_compat = 1
				fissile = 1
				part_type = "neutron"
				epv = 5
				hpe = 20
				absorb = 0.80
				k_factor = 3.0

				New()
					..()
					setProperty("density", 75)
					setProperty("fissile", 75)
					setProperty("radioactive", 55)
					setProperty("hard", 40)
					setProperty("thermal", 45)
					setProperty("stability", 20)

			pu239
				name = "plutonium-239"
				mat_id = "pu-239"
				desc = "A highly radioactive dull silver-blue heavy metal. This is the enriched form suitable for use as nuclear fuel."
				color = "#282864"
				alpha = 255
				material_flags = MATERIAL_METAL | MATERIAL_ENERGY

				nuke_compat = 1
				fissile = 1
				part_type = "neutron"
				epv = 7
				hpe = 30
				absorb = 0.85
				k_factor = 5.0

				New()
					..()
					setProperty("density", 85)
					setProperty("radioactive", 65)
					setProperty("fissile", 85)
					setProperty("hard", 40)
					setProperty("thermal", 40)
					setProperty("stability", 20)

			kremfuel
				name = "kremlinium"
				mat_id = "kmetal"
				desc = "debug metal"
				color = "#DEDEFF"
				alpha = 255
				material_flags = MATERIAL_METAL | MATERIAL_ENERGY

				nuke_compat = 1
				fissile = 1
				part_type = "neutron"
				epv = 400
				hpe = 400
				absorb = 1.0
				k_factor = 20.0

				New()
					..()
					setProperty("density", 90)
					setProperty("radioactive", 100)
					setProperty("fissile", 100)
					setProperty("hard", 50)
					setProperty("thermal", 80)
					setProperty("stability", 5)


/obj/item/material_piece/u235_o
	desc = "dev ore u235"
	default_material = "u-235"

/obj/item/material_piece/p239_o
	desc = "dev ore p239"
	default_material = "pu-239"

/obj/item/material_piece/kremfuel_o
	desc = "dev ore kremfuel"
	default_material = "kmetal"


/* -- P R O C S -- */

/proc/merge_mat_nuke(var/datum/material/Out, var/datum/material/fissile/FP, var/datum/material/fissile/SP) {
	var/datum/material/fissile/Ret = copyMaterialNuke(Out)

	DEBUG_MESSAGE_VARDBG("asdf_pre", Ret)

	Ret.epv = (FP.epv + SP.epv) * 0.5
	Ret.hpe = (FP.hpe + SP.hpe) * 0.5
	Ret.absorb = (FP.absorb + SP.absorb) * 0.5
	Ret.k_factor = (FP.k_factor + SP.k_factor) * 0.5

	DEBUG_MESSAGE_VARDBG("asdf", Ret)

	return Ret
}

/proc/copyMaterialNuke(var/datum/material/base)
	if(!base || !istype(base, /datum/material))
		var/datum/material/fissile/M = new/datum/material/fissile()
		return M
	else
		var/datum/material/fissile/M = new/datum/material/fissile()
		M.properties = mergeProperties(base.properties)
		for(var/X in base.vars)
			if(X == "type" || X == "parent_type" || X == "tag" || X == "vars" || X == "properties") continue

			if(X in triggerVars)
				M.vars[X] = getFusedTriggers(base.vars[X], list(), M) //Pass in an empty list to basically copy the first one.
			else
				if(M.vars.Find(X))
					if(istype(base.vars[X],/list))
						var/list/oldList = base.vars[X]
						M.vars[X] = oldList.Copy()
					else
						M.vars[X] = base.vars[X]
		return M
