/datum/random_event/start/weeds
	name = "Weed Growth"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()
		for_by_tcl(P, /obj/machinery/plantpot)
			var/area/A = get_area(P)
			if (!istype(A, /area/station))
				return
			var/weed_chance = rand(1,8)
			if(weed_chance == 8)
				var/datum/plant/current_planttype = null
				var/datum/plantgenes/current_plantgenes = new /datum/plantgenes(P)
				var/weed_type = rand(0,9)
				if(weed_type == 0)
					current_planttype = /datum/plant/weed/fungus
				else if (weed_type == 1)
					current_planttype = /datum/plant/weed/radweed
				else if (weed_type == 2)
					current_planttype = /datum/plant/weed/lasher
				else if (weed_type == 3)
					current_planttype = /datum/plant/weed/slurrypod
				else if (weed_type == 4)
					current_planttype = /datum/plant/seed_spitter
				else if (weed_type == 5)
					current_planttype = /datum/plant/spore_poof
				else if (weed_type == 6)
					current_planttype = /datum/plant/flower/rafflesia
				else if (weed_type == 7)
					current_planttype = /datum/plant/artifact/pukeplant
				else if (weed_type == 8)
					current_planttype = /datum/plant/artifact/creeper
				else
					current_planttype = /datum/plant/artifact/peeker
				//we create a new seed now
				var/obj/item/seed/temporary_seed = HYPgenerateseedcopy(current_plantgenes, current_planttype, 1)
				if(!P.current) // This is roundstart, but shenenigans will happen
					P.HYPnewplant(temporary_seed)
					spawn(0.5 SECONDS)
						qdel(temporary_seed)
					break
