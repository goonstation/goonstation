
//flowers n stuff
ABSTRACT_TYPE(/datum/plant/flower)
/datum/plant/flower
	plant_icon = 'icons/obj/hydroponics/plants_flower.dmi'
	category = "Flower" //????
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

/datum/plant/flower/rose
	name = "Rose"
	seedcolor = "#AA2222"
	crop = /obj/item/clothing/head/flower/rose
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)
	mutations = list(/datum/plantmutation/rose/holorose)

/datum/plant/flower/sunflower
	name = "Sunflower"
	seedcolor = "#695b59"
	crop = /obj/item/plant/flower/sunflower
	cropsize = 1
	force_seed_on_harvest = -1
	commuts = list(/datum/plant_gene_strain/growth_fast)

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
		. = ..()
		if (.) return

		#ifdef RP_MODE
		var/area/A = get_area(POT)
		if (A)
			if (emergency_shuttle.location == SHUTTLE_LOC_STATION)
				if (istype(A, /area/shuttle/escape/station))
					return
			else if (emergency_shuttle.location == SHUTTLE_LOC_TRANSIT)
				if (istype(A, /area/shuttle/escape/transit))
					return
		#endif

		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		var/spray_prob = max(33,(33 + DNA?.get_effective_value("endurance") / 5))
		var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA?.get_effective_value("cropsize")))) // Creating a temporary chem holder
		reagents_temp.my_atom = POT

		if (POT.get_current_growth_stage() >= HYP_GROWTH_MATURED && prob(spray_prob))
			var/list/plant_complete_reagents = HYPget_assoc_reagents(P, DNA)
			for (var/plantReagent in plant_complete_reagents)
				reagents_temp.add_reagent(plantReagent, 3 * max(1, HYPfull_potency_calculation(DNA, 0.1 / length(plant_complete_reagents))))
			reagents_temp.smoke_start()
			qdel(reagents_temp)

/datum/plant/flower/gardenia
	name = "Gardenia"
	seedcolor = "#d5b984"
	crop = /obj/item/clothing/head/flower/gardenia
	cropsize = 3
	commuts = list(/datum/plant_gene_strain/metabolism_fast)
	innate_commuts = list(/datum/plant_gene_strain/splicing/disabled)

/datum/plant/flower/bird_of_paradise
	name = "Bird of Paradise"
	sprite = "BirdofParadise"
	seedcolor = "#ffb426"
	crop = /obj/item/clothing/head/flower/bird_of_paradise
	growtime = 300
	harvtime = 400
	cropsize = 1
	nectarlevel = 15
	endurance = 5
	commuts = list(/datum/plant_gene_strain/damage_res)
	innate_commuts = list(/datum/plant_gene_strain/splicing/disabled)

/datum/plant/flower/hydrangea
	name = "Hydrangea"
	seedcolor = "#875dbc"
	crop = /obj/item/clothing/head/flower/hydrangea
	growtime = 70
	harvtime = 120
	harvests = 3
	commuts = list(/datum/plant_gene_strain/yield, /datum/plant_gene_strain/variable_harvest)
	innate_commuts = list(/datum/plant_gene_strain/splicing/disabled)
	mutations = list(/datum/plantmutation/hydrangea/pink, /datum/plantmutation/hydrangea/blue, /datum/plantmutation/hydrangea/purple)

	getIconOverlay(grow_level, datum/plantmutation/MUT)
		if (grow_level == 4)
			if (MUT)
				var/datum/plantmutation/hydrangea/H = MUT
				if (H.flower_color)
					return "Hydrangea-[H.flower_color]"
			return "Hydrangea-white"

