/obj/machinery/artifact/plant_helper
	name = "artifact plant_helper"
	associated_datum = /datum/artifact/plant_helper

/datum/artifact/plant_helper
	associated_object = /obj/machinery/artifact/plant_helper
	type_name = "Plant Enhancer"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("martian","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/carbon_touch)
	activated = 0
	activ_text = "begins to radiate a strange energy field!"
	deact_text = "shuts down, causing the energy field to vanish!"
	react_xray = list(9,45,85,11,"ORGANIC")
	combine_flags = ARTIFACT_COMBINES_INTO_ANY | ARTIFACT_ACCEPTS_ANY_COMBINE
	var/field_radius = 7
	var/list/helpers = list("water") // make it a bit more modular

	New()
		..()
		src.react_heat[2] = "SUPERFICIAL DAMAGE DETECTED"
		src.field_radius = rand(4,9) // field radius
		var/did_any = 0
		if (prob(80))
			src.helpers.Add("growth")
			did_any++
		if (prob(60))
			src.helpers.Add("health")
			did_any++
		if (prob(40))
			src.helpers.Add("weedkiller")
			did_any++
		if (prob(20))
			src.helpers.Add("mutation")
			did_any++
		if (did_any == 0)
			// if you rolled a complete dud, instead make it real good
			// i think this works out to about 7% (3.84% x 2 for hitting all OR none)
			src.helpers.Add("growth")
			src.helpers.Add("health")
			src.helpers.Add("weedkiller")
			src.helpers.Add("mutation")

	effect_process(var/obj/O)
		if (..())
			return
		for (var/obj/machinery/plantpot/P in range(O,src.field_radius))
			var/r = 0
			var/g = 0
			var/b = 0
			var/total = 0
			var/datum/plant/growing = P.current
			for (var/X in src.helpers)
				if (X == "water")
					var/wateramt = P.reagents.get_reagent_amount("water")
					if(wateramt > 200)
						P.reagents.remove_reagent("water", 1)
						r += 255
						total++
					if(wateramt < 100)
						P.reagents.add_reagent("water", 1)
						b += 255
						total++
				if (X == "growth" && growing)
					P.growth++
					g += 255
					total++
				if (X == "health" && growing)
					P.health++
					r += 255
					g += 128
					b += 128
					total++
				if (X == "weedkiller" && growing)
					if (growing.growthmode == "weed")
						P.health -= 3
						r += 255
						total++
				if (X == "mutation" && growing)
					if (prob(8))
						P.HYPmutateplant()
						total = INFINITY
				if(total)
					SPAWN(0)
						var/lineColor = rgb(r/total, g/total, b/total)
						var/datum/lineResult/R = drawLineImg(get_turf(O), P, "smooth", "smoothCap", getCrossed = 0)
						var/globalImageKey = "plant_helper_line[TIME]_\ref[R]_[rand(1, 1e9)]"
						R.lineImage.color = lineColor
						R.lineImage.alpha = 0
						R.lineImage.plane = PLANE_SELFILLUM
						R.lineImage.blend_mode = BLEND_ADD
						addGlobalImage(R.lineImage, globalImageKey)
						animate(R.lineImage, alpha = 64, time = 1 SECOND)
						animate(alpha = 0, time = 1 SECOND)
						sleep(2 SECONDS)
						removeGlobalImage(globalImageKey)
						qdel(R.lineImage)
