//Contains disease reagents.

datum
	reagent
		disease/
			name = "disease reagent"
			id = "ohfuck!"
			description = "if you're seeing this ingame something has fucked up!"
			reagent_state = LIQUID
			viscosity = 0.6
			var/disease = null
			var/minimum_to_infect = 4.5

			/* this wont work properly and has been driving me fucking insane so disabling it for now
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if(!M)
					M = holder.my_atom
				var/mob/living/L = M
				if (method == INGEST || prob(25))
					L.contract_disease(disease, null, null, 1) // path, name, strain, bypass resist
			*/

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				if(!M)
					M = holder.my_atom
				if (!isliving(M) || !ispath(disease))
					return
				if (src.volume < minimum_to_infect)
					return
				var/mob/living/L = M
				L.contract_disease(disease, null, null, 1)

		disease/rainbow_fluid // Clowning Around
			name = "rainbow fluid"
			id = "rainbow fluid"
			description = "It is every colour of the rainbow."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 0
			disease = /datum/ailment/disease/clowning_around

		disease/vampire_serum
			name = "vampire serum"
			id = "vampire_serum"
			description = "A sinister blood-like fluid. It smells evil, somehow."
			reagent_state = LIQUID
			fluid_r = 150
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			disease = /datum/ailment/disease/vampiritis

		disease/painbow_fluid // CLUWNE VIRUS
			name = "painbow fluid"
			id = "painbow fluid"
			description = "It is every colour of the pain spectrum. It even hurts to look at it."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 0
			disease = /datum/ailment/disease/cluwneing_around

		disease/lycanthropy //Please never give this an actual recipe .I
			name = "werewolf serum"
			id = "werewolf_serum"
			description = "A mutagenic substance associated with a mythical beast."
			reagent_state = LIQUID
			minimum_to_infect = 0
			fluid_r = 173
			fluid_g = 65
			fluid_b = 133
			transparency = 0
			disease = /datum/ailment/disease/lycanthropy

		disease/mucus // Cold
			name = "mucus"
			id = "mucus"
			description = "The stuff that comes from your throat."
			reagent_state = LIQUID
			minimum_to_infect = 0
			fluid_r = 245
			fluid_g = 255
			fluid_b = 245
			transparency = 235
			disease = /datum/ailment/disease/cold

		disease/stringy_gibbis // Fake GBS
			name = "stringy gibbis"
			id = "stringy gibbis"
			description = "Liquid gibbis that is very stringy."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			transparency = 60
			disease = /datum/ailment/disease/fake_gbs

		disease/green_mucus // Flu
			name = "green Mucus"
			id = "green mucus"
			description = "Mucus. Thats green."
			reagent_state = LIQUID
			minimum_to_infect = 0
			fluid_r = 215
			fluid_g = 255
			fluid_b = 215
			transparency = 235
			disease = /datum/ailment/disease/flu

		disease/gibbis // GBS
			name = "gibbis"
			id = "gibbis"
			description = "Liquid gibbis."
			reagent_state = LIQUID
			minimum_to_infect = 2.5
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			transparency = 150
			disease = /datum/ailment/disease/gbs

		disease/banana_peel // Jungle Fever
			name = "banana peel"
			id = "banana peel"
			description = "Banana peel crushed up to a liquid."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 0
			transparency = 150
			disease = /datum/ailment/disease/jungle_fever

		disease/liquid_plasma // Plasmatoid
			name = "liquid plasma"
			id = "liquid plasma"
			description = "Liquid plasma."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 0
			fluid_b = 200
			transparency = 80
			disease = /datum/ailment/disease/plasmatoid

		disease/hootonium // Owlstone juice
			name = "Hootonium"
			id = "hootonium"
			description = "A dangerous cocktail of mutagens and Owl DNA."
			reagent_state = LIQUID
			fluid_r = 138
			fluid_g = 87
			fluid_b = 44
			transparency = 80
			disease = /datum/ailment/disease/hootonium

		disease/nanites // Robot Transformation
			name = "nanomachines"
			id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			minimum_to_infect = 1.5
			fluid_r = 101
			fluid_g = 101
			fluid_b = 101
			transparency = 110
			disease = /datum/ailment/disease/robotic_transformation

		disease/goodnanites
			name = "Directed nanites"
			id = "goodnanites"
			description = "Microscopic construction robots that have been reprogrammed to only replace a small part of their host. First discovered by Edgar Palmer and Camryn Stern."
			reagent_state = LIQUID
			minimum_to_infect = 1.5
			fluid_r = 101
			fluid_g = 101
			fluid_b = 101
			transparency = 110
			disease = /datum/ailment/disease/good_robotic_transformation


		disease/corruptednanites // Robot Transformation with a dark, sinister twist.
			name = "corrupted nanomachines"
			id = "corruptnanites"
			description = "Microscopic construction robots. Although they seem to be moving in an unusual pattern. Huh."
			reagent_state = LIQUID
			minimum_to_infect = 1.5
			fluid_r = 90
			fluid_g = 85
			fluid_b = 85
			transparency = 110
			disease = /datum/ailment/disease/corrupt_robotic_transformation

		disease/medusa
			name = "Petrification"
			id = "medusa"
			description = "The patient is slowly turning to stone! Oh shit!"
			reagent_state = SOLID
			minimum_to_infect = 4
			fluid_r = 128
			fluid_g = 128
			fluid_b = 128
			disease = /datum/ailment/disease/medusa

		disease/liquid_spacetime // Teleportitis
			name = "liquid spacetime"
			id = "liquid spacetime"
			description = "A drop of liquid spacetime."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 60
			disease = /datum/ailment/disease/teleportitis

		disease/pubbie_tears // Berserker
			name = "pubbie tears"
			id = "pubbie tears"
			description = "The most bitter of all liquids."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			transparency = 30
			disease = /datum/ailment/disease/berserker

		disease/salts1 //cogwerks drugs
			name = "jagged crystals"
			id = "salts1"
			description = "Rapid chemical decomposition has warped these crystals into twisted spikes."
			reagent_state = SOLID
			minimum_to_infect = 0
			fluid_r = 250
			fluid_g = 0
			fluid_b = 0
			transparency = 30
			disease = /datum/ailment/disease/berserker

		disease/salmonella // Food Poisoning
			name = "salmonella bacteria"
			id = "salmonella"
			description = "A nasty bacteria found in spoiled food."
			reagent_state = LIQUID
			minimum_to_infect = 0
			fluid_r = 30
			fluid_g = 70
			fluid_b = 0
			transparency = 255
			disease = /datum/ailment/disease/food_poisoning

		disease/ecoli // Food Poisoning 2
			name = "e.coli bacteria"
			id = "e.coli"
			description = "A nasty bacteria found in contaminated food and biological waste products."
			reagent_state = LIQUID
			//minimum_to_infect = 0
			fluid_r = 30
			fluid_g = 70
			fluid_b = 0
			transparency = 255
			disease = /datum/ailment/disease/food_poisoning

		disease/MRSA // for infected wounds
			name = "MRSA"
			id = "MRSA"
			description = "A virulent bacteria that often strikes dirty hospitals."
			reagent_state = LIQUID
			fluid_r = 30
			fluid_g = 70
			fluid_b = 0
			transparency = 255
			disease = /datum/ailment/disease/infection

		disease/necrovirus // Necrotic Degeneration
			name = "necrovirus"
			id = "necrovirus"
			description = "An extremely dangerous virus."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 220
			fluid_b = 200
			transparency = 170
			disease = /datum/ailment/disease/necrotic_degeneration

		disease/viral_curative // Panacaea
			name = "viral curative"
			id = "viral curative"
			description = "A virus that feeds on other virii and bacteria."
			reagent_state = LIQUID
			minimum_to_infect = 0
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 10
			disease = /datum/ailment/disease/panacaea

		disease/rotting // Tissue Necrosis
			name = "rotting"
			id = "rotting"
			description = "A virus that causes tissue to rot."
			reagent_state = LIQUID
			fluid_r = 192
			fluid_g = 0
			fluid_b = 0
			transparency = 10
			penetrates_skin = 1
			disease = /datum/ailment/disease/tissue_necrosis

		disease/plague // Space Plague
			name = "rat venom"
			id = "rat_venom"
			description = "Unbelievably deadly. Not to be mistaken with rat poison."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 40
			fluid_b = 40
			transparency = 50
			disease = /datum/ailment/disease/space_plague

		disease/loose_screws // Space Madness
			name = "loose screws"
			id = "loose_screws"
			description = "Liquefied screws that were screwy."
			reagent_state = LIQUID
			fluid_r = 70
			fluid_g = 70
			fluid_b = 70
			transparency = 70
			disease = /datum/ailment/disease/space_madness

		disease/grave_dust // Vampire Plague
			name = "grave dust"
			id = "grave dust"
			description = "Moldy old dust taken from a grave site."
			reagent_state = LIQUID
			fluid_r = 70
			fluid_g = 80
			fluid_b = 70
			transparency = 255
			disease = /datum/ailment/disease/vamplague

		disease/prions // Kuru.
			name = "prions"
			id = "prions"
			description = "A disease-causing agent that is neither bacterial nor fungal nor viral and contains no genetic material."
			reagent_state = LIQUID
			minimum_to_infect = 5.1
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 60
			disease = /datum/ailment/disease/kuru

		disease/spidereggs // oh god
			name = "spider eggs"
			id = "spidereggs"
			description = "A fine dust containing ice spider eggs. Oh god."
			reagent_state = SOLID
			minimum_to_infect = 2.5
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 60
			disease = /datum/ailment/parasite/spidereggs

		disease/bee
			name = "bee"
			id = "bee"
			description = "The yolk from a space bee egg."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 100
			transparency = 40
			minimum_to_infect = 0.4
			disease = /datum/ailment/parasite/bee_larva

		disease/concentrated_initro // please do not give a recipe, just a thing for testing heart-related things atm
			name = "concentrated initropidril"
			id = "concentrated_initro"
			description = "A guaranteed heart-stopper!"
			reagent_state = LIQUID
			fluid_r = 192
			fluid_g = 32
			fluid_b = 232
			transparency = 0
			disease = /datum/ailment/malady/flatline

		disease/bacon_grease // please do not give a recipe, just a thing for testing heart-related things atm
			name = "pure bacon grease"
			id = "bacon_grease"
			description = "Hook me up to an IV of that sweet, sweet stuff!"
			reagent_state = LIQUID
			fluid_r = 247
			fluid_g = 230
			fluid_b = 177
			transparency = 0
			disease = /datum/ailment/malady/heartfailure
		#if ASS_JAM
		disease/toomuch // High Fever
			name = "too much" //your'e
			id = "too much"
			description = "bad pear, that"
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 255
			fluid_b = 100
			transparency = 255
			disease = /datum/ailment/disease/high_fever

		#endif

		disease/heartworms // please do not give a recipe, just a thing for testing heart-related things atm
			name = "space heartworms"
			id = "heartworms"
			description = "Aww, gross! These things can't be good for your heart. They're gunna eat it!"
			reagent_state = SOLID
			fluid_r = 146
			fluid_g = 93
			fluid_b = 108
			transparency = 0
			disease = /datum/ailment/disease/noheart

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder && H.organHolder.heart)
						qdel(H.organHolder.heart)
				..()
				return

		disease/feather_fluid
			name = "feather fluid"
			id = "feather_fluid"
			description = "Liquid feather. It's quite pretty."
			reagent_state = LIQUID
			fluid_r = 146
			fluid_g = 186
			fluid_b = 121
			transparency = 180
			disease = /datum/ailment/disease/avian_flu

		disease/mewtini
			name = "Mewtini"
			id = "mewtini"
			fluid_r = 255
			fluid_g = 165
			fluid_b = 0
			transparency = 190
			description = "A mysterious mutagenic slurry that will drive anyone catty."
			reagent_state = LIQUID
			taste = "hairy"
			thirst_value = -0.5
			disease = /datum/ailment/disease/going_catty

		disease/cocktail_sheltestgrog
			name = "sheltestgrog"
			id = "sheltestgrog"
			description = "The essence of pure frogness."
			reagent_state = LIQUID
			taste = "heavenly"
			disease = /datum/ailment/disease/frog_flu
			fluid_r = 145
			fluid_g = 185
			fluid_b = 120
			transparency = 255

		// Marquesas' one stop pathology shop
		blood/pathogen
			name = "pathogen"
			id = "pathogen"
			description = "A liquid sample of one (or multiple) pathogens."
			reagent_state = LIQUID
			fluid_r = 50
			fluid_b = 50
			fluid_g = 180
			transparency = 200
			depletion_rate = 0.8
			smoke_spread_mod = 5

			reaction_turf(var/turf/T, var/volume)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				// sure just fucking splash around in the stuff
				// this is mainly so puddles from the sweating symptom can infect
				for (var/uid in src.pathogens)
					var/datum/pathogen/P = src.pathogens[uid]
					logTheThing("pathology", M, null, "is splashed with [src] containing pathogen [P].")
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						if(prob(100-H.get_disease_protection()))
							if(H.infected(P))
								H.show_message("Ew, some of that disgusting green stuff touched you!")
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				return

		antiviral
			name = "Viral Serum"
			id = "antiviral"
			description = "An agent which can be used to create a specialized cure for a viral pathogen."
			reagent_state = 2

		// To make matters easier, fungi and parasites are both cured by the same biocides
		biocide
			name = "Biocide"
			id = "biocide"
			description = "An agent which can be used to create a specialized cure for a fungal or parasitic pathogen."
			reagent_state = 2

		// A mutation inhibitor that should destroy great mutatis cells.
		// A derivative of mutadone.
		inhibitor
			name = "Mutation Inhibitor"
			id = "inhibitor"
			description = "An agent which can be used to create a specialized cure for a cellular mutative pathogen"
			reagent_state = 2

		bacterialmedium
			name = "Bacterial Medium"
			id = "bacterialmedium"
			description = "A solution useful for the cultivation of bacteria."
			reagent_state = 2
			pathogen_nutrition = list("water", "sugar", "sodium", "iron", "nitrogen")

		parasiticmedium
			name = "Parasitic Medium"
			id = "parasiticmedium"
			description = "A solution useful for the cultivation of parasites."
			reagent_state = 2
			pathogen_nutrition = list("water", "sugar", "sodium", "iron", "nitrogen")

		fungalmedium
			name = "Fungal Medium"
			id = "fungalmedium"
			description = "A solution encouraging the growth of fungi."
			reagent_state = 2
			pathogen_nutrition = list("water", "sugar", "sodium", "iron", "nitrogen")
