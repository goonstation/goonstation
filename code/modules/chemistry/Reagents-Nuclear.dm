/*
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
	reagent
		var
			nuke_compat = 1
			fissile = 0
			part_type = "neutron"
			epv = 0
			hpe = 0
			absorb = 0
			k_factor = 0

datum
	reagent
		u238
			name = "uranium-238"
			id = "u238"
			desc = "A slightly radioactive heavy metal not suitable for nuclear fission. This is the unenriched byproduct form."
			color = "#1E461E"
			alpha = 255

			nuke_compat = 1
			fissile = 1
			part_type = "neutron"
			epv = 0.1
			hpe = 20
			absorb = 0.9
			k_factor = 0.3

			on_mob_life(var/mob/M, var/mult = 1 )
				if(!M) M = holder.my_atom
				M.changeStatus("radiation", 0.5 SECONDS * mult, 1)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("radiation",2)
				if (prob(24)) P.HYPmutateplant(1)

		u235
			name = "uranium-235"
			id = "u235"
			desc = "A radioactive dull silver-green heavy metal. This is the enriched form suitable for use as nuclear fuel."
			reagent_state = SOLID
			color = "#286428"
			alpha = 255

			nuke_compat = 1
			fissile = 1
			part_type = "neutron"
			epv = 5
			hpe = 20
			absorb = 0.8
			k_factor = 3

			on_mob_life(var/mob/M, var/mult = 1 )
				if(!M) M = holder.my_atom
				M.changeStatus("radiation", 4 SECONDS * mult, 1)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("radiation",2)
				if (prob(24)) P.HYPmutateplant(1)

		pu239
			name = "plutonium-239"
			id = "pu239"
			desc = "A highly radioactive dull silver-blue heavy metal. This is the enriched form suitable for use as nuclear fuel."
			reagent_state = SOLID
			color = "#282864"
			alpha = 255

			nuke_compat = 1
			fissile = 1
			part_type = "neutron"
			epv = 7
			hpe = 30
			absorb = 0.85
			k_factor = 5

			on_mob_life(var/mob/M, var/mult = 1 )
				if(!M) M = holder.my_atom
				M.changeStatus("radiation", 5.5 SECONDS * mult, 1)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("radiation",2)
				if (prob(24)) P.HYPmutateplant(1)


		kremfuel
			name = "kremlinium"
			id = "kremfuel"
			desc = "debug metal"
			reagent_state = SOLID
			fluid_r = 150
			fluid_g = 0
			fluid_b = 0
			alpha = 255

			nuke_compat = 1
			fissile = 1
			part_type = "neutron"
			epv = 400
			hpe = 400
			absorb = 1
			k_factor = 20
