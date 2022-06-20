ABSTRACT_TYPE(/datum/reagent/microbiology)

datum
	reagent
		microbiology
			name = "germs"
			id = "germs"
			description = "A mixture of various germs."
			taste = "neutral"
			fluid_r = 50
			fluid_b = 50
			fluid_g = 180
			transparency = 220
			value = 3
			viscosity = 0.8
			hunger_value = -0.1
			thirst_value = -0.1
			random_chem_blacklisted = 1 //this is pobably temporarily 1 just so I can work out the details

		photovoltaic
			name = "photovoltaics"
			id = "photovoltaic"
			description = "A culture of germs: this one seems to improve the performance of solar panels."
			taste = "sandy"
			fluid_r = 50
			fluid_b = 150
			fluid_g = 180
			transparency = 50
			value = 4 			//2c minimum from blood

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/machinery/power/solar))
					var/obj/machinery/power/solar/S = O
					// Credit to Convair800's silicate code implementation as a reference
					var/max_improve = 5
					if (S.improve >= max_improve)
						return
					var/do_improve = 2.5
					if ((S.improve + do_improve) > max_improve)
						do_improve = max(0, (max_improve - S.improve))
					S.improve += do_improve
				return

		meatspikehelper
			name = "swill reclaimer"
			id = "meatspikehelper"
			description = "A culture of germs: this one seems to facilitate meat extraction. It seems to require the presence of meat."
			taste = "greasy"
			fluid_r = 30
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/kitchenspike))
					var/obj/kitchenspike/K = O
					// Credit to Convair800's silicate code implementation as a reference
					var/add_meat = 3
					if (K.meat <= 1)
						return
					if (K.occupied == FALSE)
						return
					K.meat += add_meat
				return

		bioforensic
			name = "bioforensic autotroph"
			id = "bioforensic"
			description = "A culture of germs: this one seems to enhance the capabilities of a forensic scanner once applied."
			taste = "intimidating"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/item/device/detective_scanner))
					var/obj/item/device/detective_scanner/D = O
					// Credit to Convair800's silicate code implementation as a reference
					if (D.microbioupgrade)
						return
					D.microbioupgrade = 1
				return

		rcdregen
			name = "dense matter autotroph"
			id = "rcdregen"
			description = "A culture of germs: this one seems to regenerate matter in an RCD."
			taste = "heavy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

			reaction_obj(var/obj/O, var/volume) //Mark for use
				if (istype(O,/obj/item/rcd))
					var/obj/item/rcd/R = O
					// Credit to Convair800's silicate code implementation as a reference
					if (R.microbioupgrade)
						return
					R.microbioupgrade = 1
				return

		lastwords
			name = "organic oscillators"
			id = "lastwords"
			description = "A culture of germs: this one seems to recover a dead person's last utterances."
			taste = "sour"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

		organ_drug3
			name = "digestive antibiotics"
			id = "lastwords"
			description = "A culture of germs: this one seems to recover a dead person's last utterances."
			taste = "gross"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

		organ_drug2
			name = "endocrine antibiotics"
			id = "lastwords"
			description = "A culture of germs: this one seems to recover a dead person's last utterances."
			taste = "confusing"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

		organ_drug1
			name = "respiratory antibiotics"
			id = "lastwords"
			description = "A culture of germs: this one seems to recover a dead person's last utterances."
			taste = "dry"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

		o2tankproduction
			name = "Oxygen metabolizing autotroph"
			id = "o2bioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate oxygen gas."
			taste = "smooth"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

		n2tankproduction
			name = "N2 metabolizing autotroph"
			id = "n2bioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate nitrogen gas."
			taste = "icy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4

		plasmatankproduction
			name = "Plasma metabolizing autotroph"
			id = "plasmabioproduction"
			description = "A culture of germs: this one seems to bind to gas canisters and generate plasma gas."
			taste = "appalling"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
