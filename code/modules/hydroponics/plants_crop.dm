ABSTRACT_TYPE(/datum/plant/crop)
/datum/plant/crop
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"

/datum/plant/crop/bamboo
	name = "Bamboo"
	seedcolor = "#FCDA91"
	crop = /obj/item/material_piece/organic/bamboo
	starthealth = 15
	growtime = 20
	harvtime = 40
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 10
	commuts = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)

/datum/plant/crop/wheat
	name = "Wheat"
	seedcolor = "#FFFF88"
	crop = /obj/item/plant/wheat
	starthealth = 15
	growtime = 40
	harvtime = 80
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 10
	mutations = list(/datum/plantmutation/wheat/steelwheat, /datum/plantmutation/wheat/durum)
	commuts = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)


/datum/plant/crop/oat
	name = "Oat"
	seedcolor = "#CCFF88"
	crop = /obj/item/plant/oat
	starthealth = 20
	growtime = 60
	harvtime = 120
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 10
	commuts = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)
	mutations = list(/datum/plantmutation/oat/salt)

/datum/plant/crop/rice
	name = "Rice"
	seedcolor = "#FFFFAA"
	crop = /obj/item/reagent_containers/food/snacks/ingredient/rice_sprig
	starthealth = 20
	growtime = 30
	harvtime = 70
	cropsize = 4
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 8
	commuts = list(/datum/plant_gene_strain/yield,/datum/plant_gene_strain/health_poor)
	mutations = list(/datum/plantmutation/rice/ricein)

/datum/plant/crop/synthmeat
	name = "Synthmeat"
	seedcolor = "#550000"
	crop = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	starthealth = 5
	growtime = 60
	harvtime = 120
	cropsize = 3
	harvests = 2
	endurance = 3
	force_seed_on_harvest = 1
	genome = 7
	special_proc = 1
	assoc_reagents = list("synthflesh")
	commuts = list(/datum/plant_gene_strain/yield,/datum/plant_gene_strain/unstable)
	mutations = list(
		/datum/plantmutation/synthmeat/butt/buttbot, //only if already butt
		/datum/plantmutation/synthmeat/butt,
		/datum/plantmutation/synthmeat/limb,
		/datum/plantmutation/synthmeat/brain,
		/datum/plantmutation/synthmeat/heart,
		/datum/plantmutation/synthmeat/eye,
		/datum/plantmutation/synthmeat/lung,
		/datum/plantmutation/synthmeat/appendix,
		/datum/plantmutation/synthmeat/pancreas,
		/datum/plantmutation/synthmeat/liver,
		/datum/plantmutation/synthmeat/kidney,
		/datum/plantmutation/synthmeat/spleen,
		/datum/plantmutation/synthmeat/stomach
	)

/datum/plant/crop/sugar
	name = "Sugar"
	seedcolor = "#BBBBBB"
	crop = /obj/item/plant/sugar
	starthealth = 10
	growtime = 30
	harvtime = 60
	cropsize = 7
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 8
	commuts = list(/datum/plant_gene_strain/quality,/datum/plant_gene_strain/terminator)
	assoc_reagents = list("sugar")

/datum/plant/crop/peanut
	name = "Peanut"
	seedcolor = "#999900"
	crop = /obj/item/reagent_containers/food/snacks/plant/peanuts
	starthealth = 40
	growtime = 80
	harvtime = 160
	cropsize = 4
	harvests = 1
	isgrass = 1
	endurance = 10
	genome = 6
	mutations = list(/datum/plantmutation/peanut/sandwich)

/datum/plant/crop/cotton
	name = "Cotton"
	seedcolor = "#FFFFFF"
	dont_rename_crop = TRUE
	crop = /obj/item/raw_material/cotton
	starthealth = 10
	growtime = 40
	harvtime = 150
	cropsize = 4
	harvests = 4
	endurance = 0
	genome = 5
	force_seed_on_harvest = 1
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/metabolism_slow)

/datum/plant/crop/tree // :effort:
	name = "Tree"
	seedcolor = "#9C5E13"
	dont_rename_crop = TRUE
	crop = /obj/item/material_piece/organic/wood
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 20
	force_seed_on_harvest = 1
	special_proc = 1 // for dogwood tree
	vending = 1
	attacked_proc = 1 // for dogwood tree
	harvested_proc = 1 // for glowstick tree
	mutations = list(/datum/plantmutation/tree/money, /datum/plantmutation/tree/rubber,/datum/plantmutation/tree/sassafras, /datum/plantmutation/tree/dog,/datum/plantmutation/tree/paper, /datum/plantmutation/tree/glowstick)
	commuts = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/metabolism_slow,/datum/plant_gene_strain/resistance_drought)

/datum/plant/crop/coffee
	name = "Coffee"
	seedcolor = "#302013"
	crop = /obj/item/reagent_containers/food/snacks/plant/coffeeberry
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 4
	harvests = 5
	endurance = 0
	genome = 6
	assoc_reagents = list("coffee")
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
	mutations = list(/datum/plantmutation/coffee/mocha, /datum/plantmutation/coffee/latte)
