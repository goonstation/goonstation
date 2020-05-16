/datum/plant/bamboo
	name = "Bamboo"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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

/datum/plant/wheat
	name = "Wheat"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "iron")
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/wheat/steelwheat)

/datum/plant/oat
	name = "Oat"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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

/datum/plant/rice
	name = "Rice"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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

/datum/plant/beans
	name = "Bean"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
	seedcolor = "#AA7777"
	crop = /obj/item/reagent_containers/food/snacks/plant/bean
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 2
	harvests = 4
	endurance = 0
	vending = 1
	genome = 6
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
	assoc_reagents = list("nitrogen")

/datum/plant/corn
	name = "Corn"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
	seedcolor = "#FFFF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/corn
	starthealth = 20
	growtime = 60
	harvtime = 110
	cropsize = 3
	harvests = 3
	endurance = 2
	genome = 10
	mutations = list(/datum/plantmutation/corn/clear)
	commuts = list(/datum/plant_gene_strain/photosynthesis,/datum/plant_gene_strain/splicing/bad)
	assoc_reagents = list("cornstarch")

/datum/plant/synthmeat
	name = "Synthmeat"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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
	mutations = list(/datum/plantmutation/synthmeat/butt,/datum/plantmutation/synthmeat/limb,/datum/plantmutation/synthmeat/brain,/datum/plantmutation/synthmeat/heart,/datum/plantmutation/synthmeat/eye)
	commuts = list(/datum/plant_gene_strain/yield,/datum/plant_gene_strain/unstable)

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "nanites" && (DNA.mutation && istype(DNA.mutation,/datum/plantmutation/synthmeat/butt)))
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/butt/buttbot)

/obj/machinery/bot/buttbot/synth
	name = "Organic Buttbot"
	desc = "What part of this even makes any sense."

/datum/plant/sugar
	name = "Sugar"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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

/datum/plant/soy
	name = "Soybean"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
	seedcolor = "#CCCC88"
	crop = /obj/item/reagent_containers/food/snacks/plant/soy
	starthealth = 15
	growtime = 60
	harvtime = 105
	cropsize = 4
	harvests = 3
	endurance = 1
	genome = 7
	commuts = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/quality/inferior)
	assoc_reagents = list("grease")
	mutations = list(/datum/plantmutation/soy/soylent)

/datum/plant/peanut
	name = "Peanut"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("bread")
				if (prob(10))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/peanut/sandwich)

/datum/plant/cotton
	name = "Cotton"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
	seedcolor = "#FFFFFF"
	dont_rename_crop = true
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

/datum/plant/tree // :effort:
	name = "Tree"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
	seedcolor = "#9C5E13"
	dont_rename_crop = true
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
	mutations = list(/datum/plantmutation/tree/money, /datum/plantmutation/tree/rubber,/datum/plantmutation/tree/sassafras, /datum/plantmutation/tree/dog,/datum/plantmutation/tree/paper)
	commuts = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/metabolism_slow,/datum/plant_gene_strain/resistance_drought)

/datum/plant/coffee
	name = "Coffee"
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'
	category = "Miscellaneous"
	seedcolor = "#302013"
	crop = /obj/item/reagent_containers/food/snacks/plant/coffeeberry
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 4
	harvests = 5
	endurance = 0
	genome = 6
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
