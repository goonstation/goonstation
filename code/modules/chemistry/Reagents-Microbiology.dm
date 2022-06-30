var/global/list/biochemistry_whitelist = list("copper","silicon","carbon","ldmatter",\
"luminol","oxygen","nitrogen","plasma","synthflesh","sonic_powder","perfluorodecalin",\
"insulin","calomel","spaceacillin", "space_cleaner")

ABSTRACT_TYPE(/datum/reagent/microbiology)

datum
	reagent
		microbiology/
			name = "germs"
			id = "germs"
			data = null				//The precursor reagent

		microbiology/exclusiveimmunity
			name = "Toggleable Immunizers"
			id = "exlusiveimmunity"
			description = "A culture of germs: this one allows a person to choose if they wish to interact with custom microbes. Works on ingestion."
			taste = "sharp"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
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
				return

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

		microbiology/drycleaner
			name = "Organic Sanitizer"
			id = "drycleaner"
			description = "A culture of germs: this one seems to live on fabrics and feeds off of filth."
			taste = "slimy"
			fluid_r = 150
			fluid_b = 15
			fluid_g = 20
			transparency = 50
			value = 4
			data = "space_cleaner"

			reaction_obj(var/obj/O, var/volume)
				if(!(istype(O,/obj/item/clothing)))
					return
				var/obj/item/clothing/C = O
				if (C.can_stain)
					C.can_stain = 0
					return
				return

//datum/microbioeffects/service/drycleaning
	//On object:
		//Define a durability var
		//If the object gets bloody (clothing), clean it and reduce durability

//datum/microbioeffects/material/weldingtool
	//On object:
		//Check if its a welding tool
		//If it is...
		//Disable the passive fuel drain when active!

//datum/microbioeffects/forensics/sherlock

	//On Dead Mob: Reveals the dead player's last spoken words.

	//Expected effect: Sec gains another possible lead.
	//Probable effect: Nobody uses final words to out murderers and players won't bother to try

//datum/microbioeffects/material/mininghelper
	//On Turf:
		//Check if its the tough rock
		//if it is...
		//qdel it after 3-5 seconds and drop any minerals it would have had

//datum/microbioeffects/service/breadmoonrising
	//On object:
		//Check if it is bread
		//???
		//Make bread
		//Make more bread

/*
/datum/microbioeffects/material/organicglass
	name = "Organic Glass"
	desc = "The microbes produce silicate, reinforcing and repairing glass structures."

	object_act(var/obj/O, var/datum/microbe/origin)				//integers good
		var/max_reinforce = 500
		if(istype(O,/obj/window))						//Convair880's silicate code used here
			var/obj/window/W = O
			if (W.health >= max_reinforce)
				return
			var/do_reinforce = W.health + origin.probability
			if ((W.health + do_reinforce) > max_reinforce)
				do_reinforce = max(0, (max_reinforce - W.health))
			W.health += do_reinforce
			W.health_max = W.health
			var/icon/I = icon(W.icon)
			I.ColorTone(rgb(165,242,243))
			W.icon = I

	may_react_to()
		return "The pathogen appears to produce a large volume of solids."

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is oxidized by the gas."
*/
//datum/microbioeffects/material/regenerativesteel
	//On Object:
		//check if istype("grille,wall,reinforcedwall")
		//getturf
		//increment health stat of steel obj.

//datum/microbioeffects/material/rcdregen
	//On Object:
		//check if its an RCD
		//if yes...
		//check if it has max ammo
		//if no...
		//roll (probability*10) to add 5 units of ammo.

/**
 * Gas Production
 * Using the old fart symptoms, effects would replenish canisters/tanks with gas
 * On splash/apply microbe to tank
 * If tank/canister is overpressured, pass. Otherwise
 * Add probability # of moles to tank/canister
 */
/*
/datum/microbioeffects/tells/farts
	name = "Farts"
	desc = "The infected individual occasionally farts."

	var/cooldown = 200 // we just use the name of the symptom to keep track of different fart effects, so their cooldowns do not interfere
	var/doInfect = 1 // smoke farts were just too good

	proc/fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		if(doInfect)
			src.infect_cloud(M, origin, origin.spread/5)
		if(voluntary)
			origin.effectdata[name] = TIME

	onemote(mob/M as mob, act, voluntary, param, datum/pathogen/P)
		// involuntary farts are free, but the others use the cooldown
		if(voluntary && TIME-P.master.effectdata[name] < cooldown)
			return
		if(act == "fart")
			fart(M, P, voluntary)

	mob_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		if (prob(origin.stage))
			M.emote("fart")

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

*/
/*
/datum/microbioeffects/material/smokegas
	name = "Smoke Farts"
	desc = "The infected individual occasionally farts reagent smoke."
	cooldown = 600
	doInfect = 0 // the whole point is to not instantly infect a huge area, that's what got us into this mess >.>

	fart(var/mob/M, var/datum/microbe/origin, var/voluntary)
		if (M.reagents.total_volume)
			smoke_reaction(M.reagents, 1, get_turf(M))
			..()			// only trigger if we actually have chems, else no infection or cooldown

	may_react_to()
		return "The pathogen appears to produce a large volume of gas."

	react_to(var/R, var/zoom)
		var/datum/reagents/H = new /datum/reagents(5)
		H.add_reagent(R, 5)
		var/datum/reagent/RE = H.get_reagent(R)
		return "The [RE.name] violently explodes into a puff of smoke when coming into contact with the pathogen."
*/
/*
/datum/pathogeneffects/material/plasmagas
	name = "Plasma Generator"
	desc = "The germ appears to generate gaseous plasma."
	cooldown = 600

	mob_act(var/mob/M, var/datum/microbe/origin)
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.toxins = 3			//origin.stage * (voluntary ? 0.6 : 3) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The gas lights up in a puff of flame."
*/
/*
datum/microbioeffects/material/co2gas
	name = "CO2 Farts"
	desc = "The infected individual occasionally farts. Carbon dioxide."
	cooldown = 600

	fart(var/mob/M, var/datum/microbe/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.carbon_dioxide = origin.stage * (voluntary ? 1.4 : 7) // only a fifth for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	mob_act(var/mob/M, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		..()
		if (origin.stage > 2 && prob(origin.stage * 3))
			M.take_toxin_damage(1)
			M.take_oxygen_deprivation(4)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is snuffed by the gas."
*/
/*
datum/microbioeffects/malevolent/o2
	name = "O2 Farts"
	desc = "The infected individual occasionally farts. Pure oxygen."
	cooldown = 50
	// ahahahah this is so stupid
	// i have no idea what these numbers mean but i hope it's funny

	fart(var/mob/M, var/datum/pathogen/origin, var/voluntary)
		..()
		var/turf/T = get_turf(M)
		var/datum/gas_mixture/gas = new /datum/gas_mixture
		gas.zero()
		gas.oxygen = origin.stage * (voluntary ? 20 : 2) // ten times as much for voluntary farts
		gas.temperature = T20C
		gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
		if (T)
			T.assume_air(gas)

	react_to(var/R, var/zoom)
		if (R == "infernite" || R == "phlogiston")
			return "The flame of the hot reagents is oxidized by the gas."
*/


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
