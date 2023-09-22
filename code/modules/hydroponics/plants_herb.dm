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

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_CANNABIS_OBJ_ITEMS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_CANNABIS_OBJ_ITEMS)
		. = ..()

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

/datum/plant/herb/stinging_nettle
	name = "Nettle"
	override_icon_state = "Nettle"
	seedcolor = "#2ecc43"
	crop = /obj/item/plant/herb/nettle
	mutations = list(/datum/plantmutation/stinging_nettle/smooth)
	cropsize = 3
	starthealth = 20
	growtime = 40
	harvtime = 100
	cropsize = 4
	harvests = 3
	proximity_proc = 1
	harvested_proc = 1
	force_seed_on_harvest = 1
	vending = 2
	genome = 7

	ProximityProc(var/obj/machinery/plantpot/POT, mob/victim)
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		var/sting_cooldown = clamp((30 - DNA?.get_effective_value("endurance") / 2), 5, 30) // Cooldown reduced based off endurance
		var/chem_protection = 1

		if (POT.growth > (P.growtime + DNA?.get_effective_value("growtime")) && !ON_COOLDOWN(POT, "nettle_sting", sting_cooldown SECONDS))
			for (var/mob/living/M in range(1,POT))
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (istype(H.w_uniform, /obj/item/clothing/under/rank/hydroponics) || istype(H.w_uniform, /obj/item/clothing/under/misc/hydroponics))
						return  //botanist jumpsuits are expecially good at keeping nettles away
					chem_protection = ((100 - M.get_chem_protection())/100) //not gonna inject people with bio suits (1 is no chem prot, 0 is full prot for maths)

				if (!(DNA.mutation && istype(DNA.mutation,/datum/plantmutation/stinging_nettle/smooth))) //dead nettles don't inject histamine
					M.reagents?.add_reagent("histamine", 5 * chem_protection) //separated from regular reagents so it's never more than 5 units
					boutput(M, "<span class='alert'><b>You feel stinging as [POT] brushes against you!<b></span>")
				else
					boutput(M, "<span class='notice'>You feel something brush against you.</span>")
				var/list/plant_complete_reagents = HYPget_assoc_reagents(P, DNA)
				for (var/plantReagent in plant_complete_reagents) //amount of delivered chems is based on potency
					M.reagents?.add_reagent(plantReagent, 5 * chem_protection * round(max(1,(1 + DNA?.get_effective_value("potency") / (10 * (length(plant_complete_reagents) ** 0.5))))))


	HYPharvested_proc(var/obj/machinery/plantpot/POT,var/mob/user) //better not try to harvest these without gloves
		. = ..()
		if (.) return
		var/datum/plantgenes/DNA = POT.plantgenes
		var/mob/living/carbon/human/H = user

		if (H.hand)//gets active arm - left arm is 1, right arm is 0
			if (istype(H.limbs.l_arm,/obj/item/parts/robot_parts) || istype(H.limbs.l_arm,/obj/item/parts/human_parts/arm/left/synth))
				return
		else
			if (istype(H.limbs.r_arm,/obj/item/parts/robot_parts) || istype(H.limbs.r_arm,/obj/item/parts/human_parts/arm/right/synth))
				return
		if(istype(H))
			if(H.gloves)
				return

		if (!(DNA.mutation && istype(DNA.mutation,/datum/plantmutation/stinging_nettle/smooth))) //smooth nettles don't inject histamine
			H.reagents?.add_reagent("histamine", 5)
			boutput(user, "<span class='alert'>Your hands itch from touching [POT]!</span>")
			H.changeStatus("weakened", 4 SECONDS)
		else
			boutput(user, "<span class='notice'>You feel something brush against you.</span>")
		var/list/plant_complete_reagents = HYPget_assoc_reagents(src, DNA)
		for (var/plantReagent in plant_complete_reagents)
			H.reagents?.add_reagent(plantReagent, 5 * round(max(1,(1 + DNA?.get_effective_value("potency") / (10 * (length(plant_complete_reagents) ** 0.5))))))

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
	genome = 11
	nectarlevel = 5
	assoc_reagents = list("nicotine")
	mutations = list(/datum/plantmutation/tobacco/twobacco)
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)

/datum/plant/herb/tea
	name = "Tea"
	seedcolor = "#377a41"
	crop = /obj/item/plant/herb/tea
	starthealth = 20
	growtime = 20
	harvtime = 60
	cropsize = 5
	harvests = 1
	isgrass = TRUE
	endurance = 3
	nectarlevel = 5
	genome = 1
	assoc_reagents = list("tea")

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

/datum/plant/herb/lavender
	name = "Lavender"
	seedcolor = "#be9ffe"
	crop = /obj/item/clothing/head/flower/lavender
	starthealth = 20
	growtime = 80
	harvtime = 120
	cropsize = 3
	harvests = 3
	nectarlevel = 10
	force_seed_on_harvest = TRUE
	genome = 3
	assoc_reagents = list("lavender_essence")
	commuts = list(/datum/plant_gene_strain/variable_harvest, /datum/plant_gene_strain/quality)
