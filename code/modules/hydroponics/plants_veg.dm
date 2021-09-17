ABSTRACT_TYPE(/datum/plant/veg)
/datum/plant/veg
	plant_icon = 'icons/obj/hydroponics/plants_veg.dmi'
	category = "Vegetable"

/datum/plant/veg/lettuce
	name = "Lettuce"
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

/datum/plant/veg/cucumber
	name = "Cucumber"
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

/datum/plant/veg/carrot
	name = "Carrot"
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

/datum/plant/veg/potato
	name = "Potato"
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

/datum/plant/veg/onion
	name = "Onion"
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

/datum/plant/veg/garlic
	name = "Garlic"
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
	assoc_reagents = list("water_holy")

/datum/plant/veg/turmeric
	name = "Turmeric"
	seedcolor = "#e0a80c"
	crop = /obj/item/reagent_containers/food/snacks/plant/turmeric
	starthealth = 40
	growtime = 80
	harvtime = 140
	cropsize = 4
	harvests = 1
	isgrass = 1
	endurance = 3
	genome = 13
	commuts = list(/datum/plant_gene_strain/metabolism_slow,/datum/plant_gene_strain/immunity_toxin)
	assoc_reagents = list("currypowder")
