/datum/plant/tomato
	name = "Tomato" // You want to capitalise this, it shows up in the seed vendor and plant pot
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit" // This is either Fruit, Vegetable, Herb or Miscellaneous
	seedcolor = "#CC0000" // Hex string for color. Don't forget the hash!
	crop = /obj/item/reagent_containers/food/snacks/plant/tomato
	starthealth = 20
	growtime = 75
	harvtime = 110
	cropsize = 3
	harvests = 3
	endurance = 3
	nectarlevel = 5
	genome = 18
	assoc_reagents = list("juice_tomato")
	commuts = list(/datum/plant_gene_strain/splicing,/datum/plant_gene_strain/quality/inferior)

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("phlogiston","infernite","thalmerite","sorium")
				if (prob(33))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tomato/explosive)
			if("strange_reagent")
				if (prob(50))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tomato/killer)
			if("nicotine")
				if (prob(80))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tomato/tomacco)

/datum/plant/grape
	name = "Grape"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#8800CC"
	crop = /obj/item/reagent_containers/food/snacks/plant/grape
	starthealth = 5
	growtime = 40
	harvtime = 120
	cropsize = 5
	harvests = 2
	endurance = 0
	genome = 20
	nectarlevel = 10
	mutations = list(/datum/plantmutation/grapes/green, /datum/plantmutation/grapes/fruit)
	commuts = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/seedless)

/datum/plant/cherry
	name = "Cherry"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#CC0000"
	crop = /obj/item/reagent_containers/food/snacks/plant/cherry
	starthealth = 5
	growtime = 40
	harvtime = 120
	cropsize = 5
	harvests = 2
	endurance = 0
	genome = 20
	nectarlevel = 10
	assoc_reagents = list("juice_cherry")
	commuts = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/seedless)

/datum/plant/orange
	name = "Orange"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#FF8800"
	crop = /obj/item/reagent_containers/food/snacks/plant/orange
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 2
	harvests = 3
	endurance = 3
	genome = 21
	nectarlevel = 10
	mutations = list(/datum/plantmutation/orange/blood, /datum/plantmutation/orange/clockwork)
	commuts = list(/datum/plant_gene_strain/splicing,/datum/plant_gene_strain/damage_res/bad)
	assoc_reagents = list("juice_orange")

/datum/plant/melon
	name = "Melon"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#33BB00"
	crop = /obj/item/reagent_containers/food/snacks/plant/melon
	starthealth = 80
	growtime = 120
	harvtime = 200
	cropsize = 2
	harvests = 5
	endurance = 5
	genome = 19
	assoc_reagents = list("water")
	nectarlevel = 15
	mutations = list(/datum/plantmutation/melon/george, /datum/plantmutation/melon/bowling)
	commuts = list(/datum/plant_gene_strain/immortal,/datum/plant_gene_strain/seedless)
	special_proc = 1 // my sincerest apologies for this, it's there only for a dumb effect on the bowling melons

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("helium")
				if (prob(50))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/melon/balloon)
			if("hydrogen")
				if (prob(50))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/melon/hindenballoon)

/datum/plant/chili
	name = "Chili"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#FF0000"
	crop = /obj/item/reagent_containers/food/snacks/plant/chili
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 3
	endurance = 3
	genome = 17
	assoc_reagents = list("capsaicin")
	mutations = list(/datum/plantmutation/chili/chilly,/datum/plantmutation/chili/ghost)
	commuts = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/growth_slow)

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("cryostylane")
				if (prob(80))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/chilly)
			if("cryoxadone")
				if (prob(40))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/chilly)
			if("el_diablo")
				if (prob(60))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/ghost)
			if("phlogiston")
				if (prob(95))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/ghost)

/datum/plant/apple
	name = "Apple"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#00AA00"
	crop = /obj/item/reagent_containers/food/snacks/plant/apple
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 19
	mutations = list(/datum/plantmutation/apple/poison)
	assoc_reagents = list("juice_apple")
	commuts = list(/datum/plant_gene_strain/quality,/datum/plant_gene_strain/unstable)

/datum/plant/banana
	name = "Banana"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#CCFF99"
	crop = /obj/item/reagent_containers/food/snacks/plant/banana
	starthealth = 15
	growtime = 120
	harvtime = 160
	cropsize = 5
	harvests = 4
	endurance = 3
	genome = 15
	assoc_reagents = list("potassium")
	commuts = list(/datum/plant_gene_strain/immortal,/datum/plant_gene_strain/growth_slow)

/datum/plant/lime
	name = "Lime"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#00FF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/lime
	starthealth = 30
	growtime = 30
	harvtime = 100
	cropsize = 3
	harvests = 3
	endurance = 3
	genome = 21
	commuts = list(/datum/plant_gene_strain/photosynthesis,/datum/plant_gene_strain/splicing/bad)
	assoc_reagents = list("juice_lime")

/datum/plant/lemon
	name = "Lemon"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#FFFF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/lemon
	starthealth = 30
	growtime = 100
	harvtime = 130
	cropsize = 3
	harvests = 3
	endurance = 3
	genome = 21
	assoc_reagents = list("juice_lemon")

/datum/plant/pumpkin
	name = "Pumpkin"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#DD7733"
	crop = /obj/item/reagent_containers/food/snacks/plant/pumpkin
	starthealth = 60
	growtime = 100
	harvtime = 175
	cropsize = 2
	harvests = 4
	endurance = 10
	genome = 19
	commuts = list(/datum/plant_gene_strain/damage_res,/datum/plant_gene_strain/stabilizer)

/datum/plant/avocado
	name = "Avocado"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#00CC66"
	crop = /obj/item/reagent_containers/food/snacks/plant/avocado
	starthealth = 20
	growtime = 65
	harvtime = 110
	cropsize = 3
	harvests = 2
	endurance = 4
	genome = 18

/datum/plant/eggplant
	name = "Eggplant"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#CCCCCC"
	crop = /obj/item/reagent_containers/food/snacks/plant/eggplant
	starthealth = 25
	growtime = 70
	harvtime = 110
	cropsize = 4
	harvests = 2
	endurance = 2
	genome = 18
	commuts = list(/datum/plant_gene_strain/mutations,/datum/plant_gene_strain/terminator)
	mutations = list(/datum/plantmutation/eggplant/literal)
	assoc_reagents = list("nicotine")

	HYPinfusionP(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if(reagent == "eggnog" && prob(80))
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/eggplant/literal)

/datum/plant/strawberry
	name = "Strawberry"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#FF2244"
	crop = /obj/item/reagent_containers/food/snacks/plant/strawberry
	starthealth = 10
	growtime = 60
	harvtime = 120
	cropsize = 2
	harvests = 3
	endurance = 1
	genome = 18
	nectarlevel = 10
	assoc_reagents = list("juice_strawberry")

/datum/plant/blueberry
	name = "Blueberry"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#0000FF"
	crop = /obj/item/reagent_containers/food/snacks/plant/blueberry
	starthealth = 10
	growtime = 60
	harvtime = 120
	cropsize = 2
	harvests = 3
	endurance = 1
	genome = 18
	nectarlevel = 10
	assoc_reagents = list("juice_blueberry")

/datum/plant/coconut
	name = "Coconut"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#4D2600"
	crop = /obj/item/reagent_containers/food/snacks/plant/coconut
	starthealth = 80
	growtime = 120
	harvtime = 200
	cropsize = 2
	harvests = 5
	endurance = 5
	genome = 19
	assoc_reagents = list("coconut_milk")

/datum/plant/pineapple
	name = "Pineapple"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#F8D016"
	crop = /obj/item/reagent_containers/food/snacks/plant/pineapple
	starthealth = 30
	growtime = 100
	harvtime = 175
	cropsize = 3
	harvests = 4
	endurance = 10
	genome = 21

/datum/plant/pear
	name = "Pear"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#3FB929"
	crop = /obj/item/reagent_containers/food/snacks/plant/pear
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 19
	nectarlevel = 10
	commuts = list(/datum/plant_gene_strain/quality)

/datum/plant/peach
	name = "Peach"
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'
	category = "Fruit"
	seedcolor = "#DEBA5F"
	crop = /obj/item/reagent_containers/food/snacks/plant/peach
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 17
	nectarlevel = 10
	assoc_reagents = list("juice_peach")
	commuts = list(/datum/plant_gene_strain/quality)
