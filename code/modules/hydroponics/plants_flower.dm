
//flowers n stuff
ABSTRACT_TYPE(/datum/plant/flower)
/datum/plant/flower
	plant_icon = 'icons/obj/hydroponics/plants_flower.dmi'
	category = "Flower" //????
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 12
	genome = 7
	force_seed_on_harvest = 1
	mutations = list()

/datum/plant/flower/rose
	name = "Rose"
	seedcolor = "#AA2222"
	crop = /obj/item/plant/flower/rose
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "luminol")
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/rose/holorose)

/datum/plant/flower/rafflesia
	name = "Rafflesia"
	seedcolor = "#A4000F"
	crop = /obj/item/clothing/head/rafflesia
	growthmode = "weed"
	starthealth = 40
	growtime = 50
	harvtime = 90
	cropsize = 1
	harvests = 1
	endurance = 5
	genome = 9
	force_seed_on_harvest = 1
	special_proc = 1
	mutations = list()
	commuts = list(/datum/plant_gene_strain/resistance_drought)
	assoc_reagents = list("miasma")

	HYPspecial_proc(var/obj/machinery/plantpot/POT) // Smokes miasma and whatever chemicals have been spliced into the plant
		. = ..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		var/spray_prob = max(33,(33 + DNA?.get_effective_value("endurance") / 5))
		var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA?.get_effective_value("cropsize")))) // Creating a temporary chem holder
		reagents_temp.my_atom = POT

		if (POT.growth > (P.harvtime - DNA?.get_effective_value("growtime")) && prob(spray_prob))
			for (var/plantReagent in assoc_reagents)
				reagents_temp.add_reagent(plantReagent, 3 * round(max(1,(1 + DNA?.get_effective_value("potency") / (10 * length(assoc_reagents))))))
			reagents_temp.smoke_start()
			qdel(reagents_temp)

/datum/plant/flower/gardenia
	name = "Gardenia"
	seedcolor = "#d5b984"
	crop = /obj/item/clothing/head/flower/gardenia
	cropsize = 3
	commuts = list(/datum/plant_gene_strain/metabolism_fast, /datum/plant_gene_strain/splicing/disabled)

/datum/plant/flower/bird_of_paradise
	name = "Bird of Paradise"
	sprite = "BirdofParadise"
	seedcolor = "#ffb426"
	crop = /obj/item/clothing/head/flower/bird_of_paradise
	growtime = 300
	harvtime = 400
	cropsize = 1
	nectarlevel = 15
	endurance = 5
	commuts = list(/datum/plant_gene_strain/damage_res, /datum/plant_gene_strain/splicing/disabled)

/datum/plant/flower/hydrangea
	name = "Hydrangea"
	seedcolor = "#875dbc"
	crop = /obj/item/clothing/head/flower/hydrangea
	growtime = 70
	harvtime = 120
	harvests = 3
	commuts = list(/datum/plant_gene_strain/yield, /datum/plant_gene_strain/variable_harvest, /datum/plant_gene_strain/splicing/disabled)
	mutations = list(/datum/plantmutation/hydrangea/pink, /datum/plantmutation/hydrangea/blue, /datum/plantmutation/hydrangea/purple)

	getIconOverlay(grow_level, datum/plantmutation/MUT)
		if (grow_level == 4)
			if (MUT)
				var/datum/plantmutation/hydrangea/H = MUT
				if (H.flower_color)
					return "Hydrangea-[H.flower_color]"
			return "Hydrangea-white"

