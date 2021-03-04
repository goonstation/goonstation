/obj/machinery/artifact/plant_helper
	name = "artifact plant_helper"
	associated_datum = /datum/artifact/plant_helper

/datum/artifact/plant_helper
	associated_object = /obj/machinery/artifact/plant_helper
	type_name = "Plant waterer"
	rarity_weight = 350
	validtypes = list("martian","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/carbon_touch)
	activated = 0
	activ_text = "begins to radiate a strange energy field!"
	deact_text = "shuts down, causing the energy field to vanish!"
	react_xray = list(9,45,85,11,"ORGANIC")
	var/field_radius = 7
	var/list/helpers = list("water") // make it a bit more modular

	New()
		..()
		src.react_heat[2] = "SUPERFICIAL DAMAGE DETECTED"
		src.field_radius = rand(2,9) // field radius
		if (prob(80))
			src.helpers.Add("growth")
		if (prob(60))
			src.helpers.Add("health")
		if (prob(40))
			src.helpers.Add("weedkiller")
		if (prob(20))
			src.helpers.Add("mutation")

	effect_process(var/obj/O)
		if (..())
			return
		for (var/obj/machinery/plantpot/P in range(O,src.field_radius))
			var/datum/plant/growing = P.current
			for (var/X in src.helpers)
				if (X == "water")
					var/wateramt = P.reagents.get_reagent_amount("water")
					if(wateramt > 200)
						P.reagents.remove_reagent("water", 1)
					if(wateramt < 100)
						P.reagents.add_reagent("water", 1)
				if (X == "growth" && growing)
					P.growth++
				if (X == "health" && growing)
					P.health++
				if (X == "weedkiller" && growing)
					if (growing.growthmode == "weed")
						P.health -= 3
				if (X == "mutation" && growing)
					if (prob(8))
						P.HYPmutateplant()
