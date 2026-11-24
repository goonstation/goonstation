/proc/bust_lights()
	for(var/i in 1 to PROCESSING_MAX_IN_USE) // oh boy
		for(var/list/machines_list in processing_machines[i])
			for(var/obj/machinery/light_area_manager/LAM in machines_list)
				for(var/obj/machinery/light/lights in LAM.lights)
					if(prob(70))
						lights.on = 0
						lights.status = LIGHT_BROKEN
						lights.update()
	for(var/obj/machinery/power/apc/apcs in machine_registry[MACHINES_POWER])
		if(prob(65))
			apcs.cell.charge-=20
	return

/proc/creepify_station()
	var/counter = 0
	for(var/turf/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if(istype(T, /turf/simulated/floor))
			var/turf/simulated/floor/F = T
			if (was_eaten)
				F.icon = 'icons/turf/floors.dmi'
				F.icon_state = "bloodfloor_2"
				F.name = "fleshy floor"
			else
				if(prob(75))
					F.to_plating()
				if(prob(75))
					F.break_tile()
				else if(prob(90))
					F.burn_tile()
		else if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			if (was_eaten)
				W.icon = 'icons/misc/meatland.dmi'
				W.icon_state = "bloodwall_2"
				W.name = "meaty wall"
				if(istype(W, /turf/simulated/wall/auto))
					var/turf/simulated/wall/auto/WA = W
					WA.mod = "meatier-"
			else
				var/overlay
				if(istype(W,/turf/simulated/wall/auto/supernorn) || istype(W,/turf/simulated/wall/auto/reinforced/supernorn))
					overlay = image('icons/turf/walls/damage.dmi',"burn-[W.icon_state]")
				W.UpdateOverlays(overlay,"burn")
		if(counter++ % 300 == 0)
			LAGCHECK(LAG_MED)
