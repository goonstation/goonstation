var/global/list/biochemistry_whitelist = list("copper","silicon","carbon",/*"cblood"*/,"ldmatter",\
"luminol","oxygen","nitrogen","plasma","synthflesh","sonic_powder","perfluorodecalin",\
"insulin","calomel")

ABSTRACT_TYPE(/datum/reagent/microbiology)

datum
	reagent
		microbiology/
			name = "germs"
			id = "germs"
			data = null				//The precursor reagent

		microbiology/photovoltaic
			name = "photovoltaic cyanobacteria"
			id = "photovoltaic"
			description = "A culture of germs: this one seems to improve the performance of solar panels."
			taste = "sandy"
			fluid_r = 50
			fluid_b = 150
			fluid_g = 180
			transparency = 50
			value = 4 			//2c minimum from blood
			data = "silicon"

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/machinery/power/solar))
					var/obj/machinery/power/solar/S = O
					// Credit to Convair800's silicate code implementation as a reference
					var/max_improve = 2
					if (S.improve >= max_improve)
						return
					var/do_improve = 0.5
					if ((S.improve + do_improve) > max_improve)
						do_improve = max(0, (max_improve - S.improve))
					S.improve += do_improve
					boutput(usr,"<span class='notice'>The solar panel seems less reflective.</span>")
				return

		microbiology/meatspikehelper
			name = "swill-reclaiming microbes"
			id = "meatspikehelper"
			description = "A culture of germs: this one seems to facilitate meat extraction. It seems to require the presence of meat."
			taste = "greasy"
			fluid_r = 30
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "synthflesh"

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/kitchenspike))
					var/obj/kitchenspike/K = O
					// Credit to Convair800's silicate code implementation as a reference
					if (K.meat <= 1)
						return
					if (K.occupied == FALSE)
						return
					boutput(usr,"<span class='notice'>You think you can extract a little more meat from the spike.</span>")
					var/add_meat = 3
					K.meat += add_meat
				return

		microbiology/bioforensic
			name = "bioforensic autotrophes"
			id = "bioforensic"
			description = "A culture of germs: this one seems to enhance the capabilities of a forensic scanner once applied."
			taste = "intimidating"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "luminol"

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/item/device/detective_scanner))
					var/obj/item/device/detective_scanner/D = O
					// Credit to Convair800's silicate code implementation as a reference
					if (D.microbioupgrade)
						return
					D.microbioupgrade = 1
					boutput(usr,"<span class='notice'>The forensic scanner seems more... robust.</span>")
				return

		microbiology/rcdregen
			name = "dense matter autotrophes"
			id = "rcdregen"
			description = "A culture of germs: this one seems to regenerate matter in an RCD."
			taste = "heavy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "ldmatter"

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/item/rcd))
					var/obj/item/rcd/R = O
					// Credit to Convair800's silicate code implementation as a reference
					if (R.microbioupgrade)
						return
					R.microbioupgrade = 1
					boutput(usr,"<span class='notice'>The weight of the RCD seems to increase gradually.</span>")
				return

		microbiology/bioopamp
			name = "Operational-Bioamplifiers"
			id = "bioopamp"
			description = "A culture of germs: this one seems to boost the electrical current in rechargers."
			taste = "like blood"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "copper"

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/machinery/recharger))
					var/obj/machinery/recharger/R = O
					// Credit to Convair800's silicate code implementation as a reference
					if (R.secondarymult <= 2)
						boutput(usr,"<span class='notice'>The lights on the recharger seem more intense.</span>")
						R.secondarymult = 2
						return
				return

//Auxillary Reagents

		microbiology/organ_drug3
			name = "digestive antibiotics"
			id = "digestiveprobio"
			description = "A culture of germs: this one seems to strengthen digestive organ tissues."
			taste = "gross"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "insulin"

		microbiology/organ_drug2
			name = "endocrine antibiotics"
			id = "endocrineprobio"
			description = "A culture of germs: this one seems to bolster the endocrine system."
			taste = "confusing"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "calomel"

		microbiology/organ_drug1
			name = "respiratory antibiotics"
			id = "respiraprobio"
			description = "A culture of germs: this one seems to remedy damage to the respiratory system."
			taste = "dry"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "perfluorodecalin"

//WIP reagents

		microbiology/o2tankproduction
			name = "Oxygen metabolizing autotrophes"
			id = "o2bioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate oxygen gas."
			taste = "smooth"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "oxygen"

			/*reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/machinery/portable_atmospherics/canister))

					boutput(src,"<span class='notice'>You think you hear fizzling inside the canister.</span>")
					var/obj/machinery/portable_atmospherics/canister/C = O
					// Credit to Convair800's silicate code implementation as a reference
					if (C.o2microbioupgrade)
						return
					C.o2microbioupgrade = 1
				return*/

		microbiology/n2tankproduction
			name = "N2 metabolizing autotrophes"
			id = "n2bioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate nitrogen gas."
			taste = "icy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "nitrogen"

			/*reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/machinery/portable_atmospherics/canister))

					boutput(src,"<span class='notice'>You think you hear fizzling inside the canister.</span>")
					var/obj/machinery/portable_atmospherics/canister/C = O
					// Credit to Convair800's silicate code implementation as a reference
					if (C.n2microbioupgrade)
						return
					C.n2microbioupgrade = 1
				return*/

		microbiology/plasmatankproduction
			name = "Plasma metabolizing autotrophes"
			id = "plasmabioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate plasma gas."
			taste = "appalling"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "plasma"

			/*reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/machinery/portable_atmospherics/canister))

					boutput(src,"<span class='notice'>You think you hear fizzling inside the canister.</span>")
					var/obj/machinery/portable_atmospherics/canister/C = O
					// Credit to Convair800's silicate code implementation as a reference
					if (C.plasmamicrobioupgrade)
						return
					C.plasmamicrobioupgrade = 1
				return*/

		microbiology/lastwords
			name = "organic oscillators"
			id = "lastwords"
			description = "A culture of germs: this one seems to recover a dead person's last utterances."
			taste = "sour"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "sonic_powder"

		microbiology/charcoalproduction
			name = "Pyrolytic Algae"
			id = "charprod"
			description = "A culture of germs: this one seems to metabolize pure carbon into charcoal microstructures."
			taste = "malt"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "carbon"

		microbiology/botanicalalgae
			name = "Botanical Algae"
			id = "botanicalalgae"
			description = "A culture of germs: this one seems to reduce the power consumption of hydroponics trays."
			taste = "mossy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "carpet"
