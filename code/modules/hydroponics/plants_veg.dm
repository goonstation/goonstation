/datum/plant/lettuce
	name = "Lettuce"
	category = "Vegetable"
	seedcolor = "#006622"
	crop = /obj/item/reagent_containers/food/snacks/plant/lettuce
	starthealth = 30
	growtime = 40
	harvtime = 80
	cropsize = 8
	harvests = 1
	isgrass = 1
	endurance = 5
	genome = 12
	commuts = list(/datum/plant_gene_strain/reagent_adder,/datum/plant_gene_strain/damage_res/bad)

/datum/plant/cucumber
	name = "Cucumber"
	category = "Vegetable"
	seedcolor = "#005622"
	crop = /obj/item/reagent_containers/food/snacks/plant/cucumber
	starthealth = 25
	growtime = 50
	harvtime = 100
	cropsize = 8
	harvests = 1
	isgrass = 1
	endurance = 6
	genome = 19
	commuts = list(/datum/plant_gene_strain/damage_res,/datum/plant_gene_strain/stabilizer)

/datum/plant/carrot
	name = "Carrot"
	category = "Vegetable"
	seedcolor = "#774400"
	crop = /obj/item/reagent_containers/food/snacks/plant/carrot
	starthealth = 20
	growtime = 50
	harvtime = 100
	cropsize = 6
	harvests = 1
	isgrass = 1
	endurance = 5
	genome = 16
	nectarlevel = 10
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/mutations/bad)

/datum/plant/potato
	name = "Potato"
	category = "Vegetable"
	seedcolor = "#555500"
	crop = /obj/item/reagent_containers/food/snacks/plant/potato
	starthealth = 40
	growtime = 80
	harvtime = 160
	cropsize = 4
	harvests = 1
	isgrass = 1
	endurance = 10
	genome = 16
	nectarlevel = 6
	commuts = list(/datum/plant_gene_strain/damage_res,/datum/plant_gene_strain/stabilizer)

/datum/plant/onion
	name = "Onion"
	category = "Vegetable"
	seedcolor = "#DDFFDD"
	crop = /obj/item/reagent_containers/food/snacks/plant/onion
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 1
	endurance = 3
	genome = 13
	commuts = list(/datum/plant_gene_strain/splicing,/datum/plant_gene_strain/reagent_adder/toxic)

/datum/plant/garlic
	name = "Garlic"
	category = "Vegetable"
	seedcolor = "#BBDDBB"
	crop = /obj/item/reagent_containers/food/snacks/plant/garlic
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 1
	endurance = 3
	genome = 13
	commuts = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/terminator)
