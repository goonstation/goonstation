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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "iron")
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/wheat/steelwheat)

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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "insulin")
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/rice/ricein)

/datum/plant/crop/beans
	name = "Bean"
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
	mutations = list(/datum/plantmutation/beans/jelly)
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
	assoc_reagents = list("nitrogen")

/datum/plant/crop/peas
	name = "Peas"
	seedcolor = "#77AA77"
	crop = /obj/item/reagent_containers/food/snacks/plant/peas
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 2
	harvests = 4
	endurance = 0
	vending = 1
	genome = 8
	mutations = list(/datum/plantmutation/peas/ammonia)
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)

/datum/plant/crop/corn
	name = "Corn"
	seedcolor = "#FFFF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/corn
	starthealth = 20
	growtime = 60
	harvtime = 110
	cropsize = 3
	harvests = 3
	endurance = 2
	genome = 10
	mutations = list(/datum/plantmutation/corn/clear, /datum/plantmutation/corn/pepper)
	commuts = list(/datum/plant_gene_strain/photosynthesis,/datum/plant_gene_strain/splicing/bad)
	assoc_reagents = list("cornstarch")

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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "nanites" && (DNA.mutation && istype(DNA.mutation,/datum/plantmutation/synthmeat/butt)))
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/butt/buttbot)
		switch(reagent)
			if("anti_fart")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/butt)
			if("synthflesh")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/limb)
			if("mannitol")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/brain)
			if("blood")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/heart)
			if("oculine")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/eye)
			if("salbutamol")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/lung)
			if("poo")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/appendix)
			if("sugar")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/pancreas)
			if("ethanol")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/liver)
			if("urine")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/kidney)
			if("proconvertin")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/spleen)
			if("charcoal")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/stomach)

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

/datum/plant/crop/soy
	name = "Soybean"
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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("bread")
				if (prob(10))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/peanut/sandwich)

/datum/plant/crop/cotton
	name = "Cotton"
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

/datum/plant/crop/tree // :effort:
	name = "Tree"
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

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch (reagent)
			if ("radium")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tree/glowstick)
			if ("paper")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tree/paper)
			if ("wolfsbane")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tree/dog)
			if ("spaceglue")
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tree/rubber)


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
