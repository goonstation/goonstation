
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
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes	
		var/spray_prob = max(33,(33 + DNA.endurance / 5))
		var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA.cropsize))) // Creating a temporary chem holder
		reagents_temp.my_atom = POT
		var/reag_smoke_list = list()
		
		for(var/REAG in assoc_reagents)
			reag_smoke_list = reag_smoke_list + REAG
		
		if (POT.growth > (P.harvtime - DNA.growtime) && prob(spray_prob))
			for (var/obj/machinery/plantpot/POT2 in view(3,POT))
				var/datum/plant/growing = POT2.current
				for(var/REAG2 in growing.assoc_reagents)
					reag_smoke_list = reag_smoke_list + REAG2
					
			for(var/num in range(round(max(1,(1 + DNA.potency / 10)))))
				for(var/REAG3 in reag_smoke_list)
					reagents_temp.add_reagent(REAG3, (3/(max(1,(length(reag_smoke_list))))))
			reagents_temp.smoke_start()
			qdel(reagents_temp)
