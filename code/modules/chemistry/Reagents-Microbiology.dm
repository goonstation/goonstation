var/global/list/biochemistry_whitelist = list("copper","silicon","carbon","cblood","ldmatter",\
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
			name = "photovoltaics"
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
				return

		microbiology/meatspikehelper
			name = "swill reclaimer"
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
					boutput(src,"<span class='notice'>You think you can extract a little more meat from the spike.</span>")
					var/add_meat = 3
					if (K.meat <= 1)
						return
					if (K.occupied == FALSE)
						return
					K.meat += add_meat
				return

		microbiology/bioforensic
			name = "bioforensic autotroph"
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
					boutput(src,"<span class='notice'>The forensic scanner seems more... robust.</span>")
					var/obj/item/device/detective_scanner/D = O
					// Credit to Convair800's silicate code implementation as a reference
					if (D.microbioupgrade)
						return
					D.microbioupgrade = 1
				return

		microbiology/rcdregen
			name = "dense matter autotroph"
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
					boutput(src,"<span class='notice'>The weight of the RCD seems to increase gradually.</span>")
					var/obj/item/rcd/R = O
					// Credit to Convair800's silicate code implementation as a reference
					if (R.microbioupgrade)
						return
					R.microbioupgrade = 1
				return

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

		microbiology/o2tankproduction
			name = "Oxygen metabolizing autotroph"
			id = "o2bioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate oxygen gas."
			taste = "smooth"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "oxygen"

		microbiology/n2tankproduction
			name = "N2 metabolizing autotroph"
			id = "n2bioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate nitrogen gas."
			taste = "icy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "nitrogen"

		microbiology/plasmatankproduction
			name = "Plasma metabolizing autotroph"
			id = "plasmabioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate plasma gas."
			taste = "appalling"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "plasma"
