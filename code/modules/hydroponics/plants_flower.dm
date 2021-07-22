
//flowers n stuff
ABSTRACT_TYPE(/datum/plant/flower)
/datum/plant/flower
	plant_icon = 'icons/obj/hydroponics/plants_flower.dmi'
	category = "Flower" //????

/datum/plant/flower/rose
	name = "Rose"
	seedcolor = "#AA2222"
	crop = /obj/item/plant/flower/rose
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
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)

/datum/plant/flower/rafflesia
	name = "Rafflesia"
	seedcolor = "#A4000F"
	crop = /obj/item/clothing/head/rafflesia
	starthealth = 40
	growtime = 50
	harvtime = 90
	cropsize = 1
	harvests = 1
	isgrass = 1
	endurance = 5
	genome = 9
	force_seed_on_harvest = 1
	special_proc = 1
	mutations = list()
	commuts = list(/datum/plant_gene_strain/resistance_drought)
	assoc_reagents = list("miasma")
	
	HYPspecial_proc(var/obj/machinery/plantpot/POT) // Smokes miasma and whatever chemicals have been spliced into the plant
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes	
		var/spray_prob = max(30,(30 + DNA.endurance / 10))
	
		if (POT.growth > (P.harvtime - DNA.growtime) && prob(spray_prob))
			POT.reagents.clear_reagents() // Prevents smoking anything you spill into the pot,  that and pottasium water explosions.
			for(var/REAG in assoc_reagents)
				POT.reagents.add_reagent(REAG, max(1,(1 + DNA.potency / 5)))
			POT.reagents.add_reagent("sugar", max(1,(1 + DNA.potency / 5)))
			POT.reagents.add_reagent("phosphorus", max(1,(1 + DNA.potency / 5)))
			POT.reagents.add_reagent("potassium", max(1,(1 + DNA.potency / 5)))
