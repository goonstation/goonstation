
//flowers n stuff
//TO-DO
//Alterations of each flower type
//special stuff for each of them
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
	nectarlevel = 0 //roses make no nectar, poor bees.
	genome = 7
	force_seed_on_harvest = 1
	mutations = list()
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)

/datum/plant/flower/hibiscus
	name = "Hibiscus"
	seedcolor = "#d52c53"
	crop = /obj/item/plant/flower/hibiscus
	starthealth = 20
	growtime = 45
	harvtime = 130
	cropsize = 3
	harvests = 1
	endurance = 2
	nectarlevel =  19 //these things literally drip nectar from time to time
	genome = 11
	force_seed_on_harvest = 1
	assoc_reagents = list("hibiscus_petals")

/datum/plant/flower/poppy
	name = "Poppy"
	seedcolor = "#FF1500"
	crop = /obj/item/plant/flower/poppy
	starthealth = 10
	growtime = 50
	harvtime = 80
	cropsize = 4
	harvests = 1
	isgrass = 1
	endurance = 0
	vending = 2
	genome = 1
	assoc_reagents = list("morphine")

/datum/plant/flower/bluebonnet //research this one and edit it
	name = "Blue Bonnet"
	override_icon_state = "Bbonnet" //thank you houttuynia cordata
	seedcolor = "#1a378d"
	crop = /obj/item/plant/flower/bluebonnet
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 0
	genome = 7
	force_seed_on_harvest = 1

/datum/plant/flower/daisy //code chamomile
	name = "Daisy"
	seedcolor = "#fafff4"
	crop = /obj/item/plant/flower/daisy
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 0
	genome = 7
	force_seed_on_harvest = 1

/datum/plant/flower/daffodil //this one too
	name = "Daffodil"
	seedcolor = "#ffca00"
	crop = /obj/item/plant/flower/daffodil
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 0
	genome = 7
	force_seed_on_harvest = 1

/datum/plant/flower/morningglory //no clue how these work
	name = "Morning Glory"
	override_icon_state = "Mglory"
	seedcolor = "#7a27d9"
	crop = /obj/item/plant/flower/morningglory
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 0
	genome = 7
	force_seed_on_harvest = 1
