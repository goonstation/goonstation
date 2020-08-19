ABSTRACT_TYPE(/datum/plant/herb)
/datum/plant/herb
	plant_icon = 'icons/obj/hydroponics/plants_herb.dmi'
	category = "Herb"

/datum/plant/herb/contusine
	name = "Contusine"
	seedcolor = "#DD00AA"
	crop = /obj/item/plant/herb/contusine
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	nectarlevel = 10
	genome = 3
	assoc_reagents = list("salicylic_acid")
	mutations = list(/datum/plantmutation/contusine/shivering,/datum/plantmutation/contusine/quivering)

/datum/plant/herb/nureous
	name = "Nureous"
	seedcolor = "#226600"
	crop = /obj/item/plant/herb/nureous
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	nectarlevel = 10
	genome = 3
	mutations = list(/datum/plantmutation/nureous/fuzzy)
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)
	assoc_reagents = list("anti_rad")

/datum/plant/herb/asomna
	name = "Asomna"
	seedcolor = "#00AA77"
	crop = /obj/item/plant/herb/asomna
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	nectarlevel = 15
	genome = 3
	assoc_reagents = list("ephedrine")
	mutations = list(/datum/plantmutation/asomna/robust)

/datum/plant/herb/commol
	name = "Commol"
	seedcolor = "#559900"
	crop = /obj/item/plant/herb/commol
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 16
	nectarlevel = 5
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)
	assoc_reagents = list("silver_sulfadiazine")
	mutations = list(/datum/plantmutation/commol/burning)

/datum/plant/herb/ipecacuanha
	name = "Ipecacuanha"
	seedcolor = "#063c0f"
	crop = /obj/item/plant/herb/ipecacuanha
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	genome = 16
	nectarlevel = 5
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)
	assoc_reagents = list("ipecac")
	mutations = list(/datum/plantmutation/ipecacuanha/bilious,/datum/plantmutation/ipecacuanha/invigorating)

/datum/plant/herb/venne
	name = "Venne"
	seedcolor = "#DDFF99"
	crop = /obj/item/plant/herb/venne
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	nectarlevel = 5
	genome = 1
	assoc_reagents = list("charcoal")
	mutations = list(/datum/plantmutation/venne/toxic,/datum/plantmutation/venne/curative)

/datum/plant/herb/mint
	name = "Mint"
	seedcolor = "#258934"
	crop = /obj/item/plant/herb/mint
	starthealth = 20
	growtime = 80
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 3
	nectarlevel = 5
	genome = 1
	assoc_reagents = list("mint")

/datum/plant/herb/cannabis
	name = "Cannabis"
	seedcolor = "#66DD66"
	crop = /obj/item/plant/herb/cannabis
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 0
	isgrass = 1
	vending = 2
	nectarlevel = 5
	genome = 2
	assoc_reagents = list("THC","CBD")
	mutations = list(/datum/plantmutation/cannabis/rainbow,/datum/plantmutation/cannabis/death,
	/datum/plantmutation/cannabis/white,/datum/plantmutation/cannabis/ultimate)
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)

/datum/plant/herb/catnip
	name = "Nepeta Cataria"
	seedcolor = "#00CA70"
	crop = /obj/item/plant/herb/catnip
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 0
	isgrass = 1
	vending = 2
	genome = 1
	assoc_reagents = list("catonium")

/datum/plant/herb/hcordata
	name = "Houttuynia Cordata"
	override_icon_state = "Houttuynia" //To avoid REALLY long icon state names
	seedcolor = "#00CA70"
	crop = /obj/item/plant/herb/hcordata
	mutations = list(/datum/plantmutation/hcordata/fish)
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	force_seed_on_harvest = 1
	special_proc = 1 // for tuna plant
	harvested_proc = 1 // for tuna plant
	isgrass = 0
	endurance = 0
	vending = 1
	genome = 1
	assoc_reagents = list("mercury")

/datum/plant/herb/poppy
	name = "Poppy"
	seedcolor = "#FF1500"
	crop = /obj/item/plant/herb/poppy
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

/datum/plant/herb/aconite
	name = "Aconite"
	seedcolor = "#990099"
	crop = /obj/item/plant/herb/aconite
	starthealth = 10
	growtime = 60
	harvtime = 80
	cropsize = 2
	harvests = 1
	endurance = 0
	isgrass = 0
	vending = 2
	genome = 1
	assoc_reagents = list("wolfsbane")

/datum/plant/herb/tobacco
	name = "Tobacco"
	seedcolor = "#82D213"
	crop = /obj/item/plant/herb/tobacco
	starthealth = 20
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 1
	isgrass = 1
	genome = 2 //no idea if this was set to the right thing aaa
	nectarlevel = 5
	assoc_reagents = list("nicotine")
	mutations = list(/datum/plantmutation/tobacco/twobacco)
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)

/datum/plant/herb/grass
	name = "Grass"
	category = "Miscellaneous" //this seems inconsistent, shouldn't  this mean it belongs in plants_crop?
	seedcolor = "#00CC00"
	crop = /obj/item/plant/herb/grass
	isgrass = 1
	starthealth = 10
	growtime = 15
	harvtime = 50
	harvests = 1
	cropsize = 8
	endurance = 10
	vending = 2
	genome = 4
	assoc_reagents = list("grassgro")
	commuts = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)
