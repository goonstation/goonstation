ABSTRACT_TYPE(/datum/reagent/microbiology)

datum
	reagent
		microbiology/
			name = "germs"
			id = "germs"
			data = null				//The precursor reagent

		/*microbiology/exclusiveimmunity
			name = "Toggleable Immunizers"
			id = "exlusiveimmunity"
			description = "A culture of germs: this one allows a person to choose if they wish to interact with custom microbes. Works on ingestion."
			taste = "sharp"
			fluid_r = 7
			fluid_b = 7
			fluid_g = 7
			transparency = 7
			value = 6	// 3 2 1
			data = "spaceacillin"
			var/special_chem_processed = 0

			reaction_mob(var/mob/M, var/method=INGEST, var/volume_passed)
				if (!(istype(M, /mob/living/carbon/human)))
					return
				var/mob/living/carbon/human/H = M
				if(!(H.totalimmunity) && !(special_chem_processed))
					H.totalimmunity = 1
					special_chem_processed = 1
				else
					H.totalimmunity = 0
					special_chem_processed = 1
				..()
				return*/

		microbiology/photovoltaic
			name = "photovoltaic cyanobacteria"
			id = "photovoltaic"
			description = "A culture of germs: this one seems to improve the performance of solar panels."
			taste = "sandy"
			fluid_r = 50
			fluid_b = 150
			fluid_g = 180
			transparency = 50
			value = 4 			//1 2 1 	//Take value of egg = 1
			data = "silicon"

			reaction_obj(var/obj/O, var/volume)
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
					boutput(usr,"<span class='notice'>The solar panel seems less reflective.</span>")	//It's absorbing more light -> more energy
				return

		microbiology/meatspikehelper
			name = "swill-reclaiming parasites"
			id = "meatspikehelper"
			description = "A culture of parasites: this one seems to facilitate meat extraction. It seems to require the presence of meat."
			taste = "greasy"
			fluid_r = 120
			fluid_b = 15
			fluid_g = 20
			transparency = 100
			value = 12			//9 2 1
			data = "synthflesh"

			reaction_obj(var/obj/O, var/volume)
				if (istype(O,/obj/kitchenspike))
					var/obj/kitchenspike/K = O
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
			fluid_r = 250
			fluid_b = 15
			fluid_g = 20
			transparency = 210
			value = 7		// 1+1+1+1+2+1
			data = "luminol"

			reaction_obj(var/obj/O, var/volume)
				if (istype(O,/obj/item/device/detective_scanner))
					var/obj/item/device/detective_scanner/D = O
					if (D.microbioupgrade)
						return
					D.microbioupgrade = 1
					boutput(usr,"<span class='notice'>The forensic scanner seems more... robust.</span>")
				return

		microbiology/rcdregen
			name = "dense matter autotrophes"
			id = "rcdregen"
			description = "A culture of germs: this one seems to improve the efficiency of an RCD."
			taste = "heavy"
			fluid_r = 25
			fluid_b = 100
			fluid_g = 200
			transparency = 240
			value = 9		// 6 + 2 + 1
			data = "ldmatter"

			reaction_obj(var/obj/O, var/volume)
				if (istype(O,/obj/item/rcd))
					var/obj/item/rcd/R = O
					/* construction cost and time */
					R.matter_create_wall = max(1,R.matter_create_wall--)
					R.time_create_wall = max(3,R.time_create_wall--) SECONDS
					R.matter_reinforce_wall = max(1,R.matter_reinforce_wall--)
					R.time_reinforce_wall = max(4,R.time_reinforce_wall--) SECONDS
					R.time_create_wall_girder = 1 SECONDS
					R.matter_create_door = max(2,R.matter_create_door--)
					R.time_create_door = max(3,R.time_create_door--) SECONDS
					R.matter_create_window = 1
					R.time_create_window = 1 SECONDS
					R.matter_create_light_fixture = max(0.5,R.matter_create_light_fixture--)
					R.time_create_light_fixture = max(0.5,R.time_create_light_fixture--) SECONDS
					//No deconstruction buffs because that would have big grief potential
					boutput(usr,"<span class='notice'>The RCD feels lighter, but the ammo indicator hasn't changed.</span>")
				return

		microbiology/bioopamp
			name = "operational-bioamplifiers"
			id = "bioopamp"
			description = "A culture of germs: this one seems to boost the electrical current in rechargers."
			taste = "fizzy"
			fluid_r = 200
			fluid_b = 5
			fluid_g = 120
			transparency = 120
			value = 4		//1+2+1
			data = "copper"

			reaction_obj(var/obj/O, var/volume)
				if (istype(O,/obj/machinery/recharger))
					var/obj/machinery/recharger/R = O
					if (R.secondarymult <= 2)
						boutput(usr,"<span class='notice'>The lights on the recharger seem more intense.</span>")
						R.secondarymult = 2
						return
				return

		microbiology/drycleaner
			name = "organic sanitizer"
			id = "drycleaner"
			description = "A culture of germs: this one seems to live on fabrics and feeds off of filth."
			taste = "slimy"
			fluid_r = 130
			fluid_b = 170
			fluid_g = 115
			transparency = 125
			value = 7		//4 2 1
			data = "cleaner"

			reaction_obj(var/obj/O, var/volume)
				if(!(istype(O,/obj/item/clothing)))
					return
				var/obj/item/clothing/C = O
				if (C.can_stain)
					C.can_stain = 0
					boutput(usr,"<span class='notice'>You see some stains fading from the [C]. A washing would help.</span>")
					return
				return

		microbiology/weldingregen
			name = "naphthalene crystallizers"
			id = "weldingregen"
			description = "A culture of germs: this one seems to facilitate the binding of hydrocarbons into more efficient molecules."
			taste = "oily"
			fluid_r = 25
			fluid_g = 10
			fluid_b = 10
			transparency = 210
			value = 6			// 3 2 1
			data = "napalm_goo"

			reaction_obj(var/obj/O, var/volume)
				if(!(istype(O,/obj/item/weldingtool)))
					return
				var/obj/item/weldingtool/tool = O
				if (tool.microbioupgrade)
					return
				tool.microbioupgrade = 1
				boutput(usr,"<span class='notice'>The [tool] gives off a pungent, octane smell.</span>")
				return

//Auxillary Reagents

		microbiology/organ_drug3
			name = "digestive antibiotics"
			id = "digestiveprobio"
			description = "A culture of germs: this one seems to strengthen digestive organ tissues."
			taste = "gross"
			fluid_r = 125
			fluid_b = 100
			fluid_g = 180
			transparency = 50
			value = 9	// 6 2 1
			data = "insulin"

		microbiology/organ_drug2
			name = "endocrine antibiotics"
			id = "endocrineprobio"
			description = "A culture of germs: this one seems to bolster the endocrine system."
			taste = "confusing"
			fluid_r = 80
			fluid_b = 190
			fluid_g = 65
			transparency = 80
			value = 6	// 3 2 1
			data = "calomel"

		microbiology/organ_drug1
			name = "respiratory antibiotics"
			id = "respiraprobio"
			description = "A culture of germs: this one seems to remedy damage to the respiratory system."
			taste = "dry"
			fluid_r = 25
			fluid_b = 240
			fluid_g = 140
			transparency = 50
			value = 9	// 6 2 1
			data = "perfluorodecalin"

//No code infrastructure for these...
/*
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
			data = "sonicpowder"

	//On Dead Mob: Reveals the dead player's last spoken words.

	//Expected effect: Sec gains another possible lead.
	//Probable effect: Nobody uses final words to out murderers and players won't bother to try

*/
//datum/microbioeffects/material/mininghelper
	//On Turf:
		//Check if its the tough rock
		//if it is...
		//qdel it after 3-5 seconds and drop any minerals it would have had

//More lag than worthwhile. If Goon ever moves on from BYOND these might be explorable
//Turfs =/= reagent containers
/*
		microbiology/organicglass
			name = "Organic Glass"
			id = "organicglass"
			description = "A culture of germs: this one produces silicate, reinforcing and repairing windows."
			taste = "sandy"
			fluid_r = 40
			fluid_g = 130
			fluid_b = 190
			transparency = 40
			value = 6	// 3 2 1
			data = "silicate"

			reation_obj(var/obj/O, var/volume)
				if(!(istype(O,/obj/window)))
					return
				var/obj/window/W = O
				if (W.microbioupgrade)
					return
				W.microbioupgrade = 1
				boutput(usr,"<span class='notice'>Microscratches on the [W] begin to heal.</span>")
				return
*/
/*
		microbiology/regensteel
			name = "Regenerative Steel"
			id = "regensteel"
			description = "A culture of germs: this one removes crystallographic dislocations from steel."
			taste = "like blood"
			fluid_r = 40
			fluid_g = 130
			fluid_b = 190
			transparency = 40
			value = 4	// 1 2 1
			data = "iron"

			reaction_turf(var/turf/T, var/volume)
				if (!(issimulatedturf(T)))
					return
				if (isrwall(T))
					var/turf/simulated/wall/r_wall/wall = T
				else if(istype(T,/turf/simulated/wall))
					var/turf/simulated/wall/wall = T
				else return
				if (T.microbioupgrade)
					return
				T.microbioupgrade = 1
				boutput(usr,"<span class='notice'>The surface of the [T] gradually becomes more reflective.</span>")
				return
*/
