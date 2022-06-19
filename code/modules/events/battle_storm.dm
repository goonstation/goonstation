// Basically a weaker radioactive blowout
/datum/random_event/special/battlestorm
	name = "Battle Storm"
	required_elapsed_round_time = 0 MINUTES
	var/space_color = "#ff4646"
	var/list/area/safe_areas = list()
	var/list/safe_area_names = list()
	var/list/area/safe_locations = list()
	var/list/area/excluded_areas = list(/area/shuttle/battle, /area/shuttle/escape/transit, /area/shuttle_transit_space)
	var/activations = 0

	New()
		..()
		safe_locations = get_accessible_station_areas()

	event_effect(var/final = FALSE)
		// Pick a safe area(s)
		activations++
		safe_area_names = list()
		safe_areas = list()
		if (!final)
			var/num_safe_areas = clamp(6 - activations, 1, 5)
			var/area/temp = null
			var/list/locations_copy = list()
			for(var/A in safe_locations)
				locations_copy.Add(A)
			for(var/i = 0, i < num_safe_areas, i++)
				temp = pick(locations_copy)
				locations_copy.Remove(temp)
				safe_area_names.Add(temp)
				safe_areas.Add(safe_locations[temp])
				safe_locations[temp].icon_state = "blue"

		for (var/mob/M in mobs)
			if (M.z == Z_LEVEL_STATION)
				M.flash(3 SECONDS)
		var/sound/siren = sound('sound/misc/airraid_loop_short.ogg')
		siren.repeat = TRUE
		siren.channel = 5
		siren.volume = 50 // wire note: lets not deafen players with an air raid siren
		world << siren
		command_alert("[final ? "The FINAL STORM" : "A BATTLE STORM"] is approaching the [station_or_ship()]! Impact in 60 seconds. [final ? "You must make it to the escape shuttle or die" : "You will take large amounts of damage unless you are standing in [get_battle_area_names(safe_area_names)]"]!", "[final ? "FINAL" : "BATTLE"] STORM INCOMING")

		SPAWN(60 SECONDS)

			siren.repeat = FALSE
			siren.channel = 5
			siren.volume = 50

			for (var/mob/M in mobs)
				if (M.z == Z_LEVEL_STATION)
					M.flash(3 SECONDS)

	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				if (S.z == Z_LEVEL_STATION)
					S.color = src.space_color
				else
					break
	#endif
			for(var/area/A in world)
				if (A.z != Z_LEVEL_STATION)
					continue
				var/B = 1
				for(var/area/S in safe_areas)
					if(istype(A,S))
						B = 0
				for(var/E in excluded_areas)
					if(istype(A,E))
						B = 0
				if(B)
					A.icon_state = "red"
					A.storming = 1

			world << siren

			sleep(0.4 SECONDS)


			var/sound/blowoutsound = sound('sound/misc/blowout_short.ogg')
			blowoutsound.repeat = 0
			blowoutsound.channel = 5
			blowoutsound.volume = 50
			world << blowoutsound
			boutput(world, "<span class='alert'>[final ? "The FINAL STORM has reached the [station_or_ship()]. You must make it to the escape shuttle or die" : "<B>WARNING</B>: A BATTLE STORM has struck [station_name(1)]. You will take damage unless you are in [get_battle_area_names(safe_area_names)]"]!</span>")

			for (var/mob/M in mobs)
				SPAWN(0)
					if (!inafterlife(M) && !isVRghost(M))
						shake_camera(M, 100, 16) // wire note: lowered strength from 840 to 400, by popular request

			if (final)
				// Yes we are going forever
				for(var/i = 0, i < INFINITY, i++)
					sleep(2 SECONDS)
					for(var/mob/living/M in mobs)
						if(M.z == Z_LEVEL_STATION)
							M.changeStatus("burning", 10 SECONDS)
							M.changeStatus("radiation", 10 SECONDS)
							random_brute_damage(M, 14)
							random_burn_damage(M, 14)
			else
				// Hit everyone every 2 seconds when they are not in the safe zone
				// Everyone gets set more and more on fire the longer they arent in the safe area
				for(var/i = 0, i < 10, i++)
					sleep(2 SECONDS)
					for(var/mob/living/M in mobs)
						var/area/mob_area = get_area(M)
						if(mob_area?.storming)
							M.changeStatus("burning", clamp(2 * activations, 2, 8) SECONDS)
							if  (activations > 1)
								M.changeStatus("radiation", clamp(1 * activations, 2, 6) SECONDS)
							random_brute_damage(M, clamp(2 * activations, 2, 10))

			command_alert("The storm has almost passed. ETA 5 seconds until all areas are safe.", "BATTLE STORM ABOUT TO END")

			sleep(5 SECONDS)

			blowout = 0
	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				if (S.z == 1)
					S.color = null
				else
					break
	#endif

			for(var/area/A in world)
				A.icon_state = ""
				A.storming = 0
			for (var/mob/M in mobs)
				if (!inafterlife(M) && !isVRghost(M))
					M.flash(3 SECONDS)

proc/get_battle_area_names(var/list/strings)
	. = ""
	if(strings.len == 1)
		return "[strings[1]]"
	for(var/i = 1, i < strings.len; i++)
		. += strings[i] + ", "
	. += "or [strings[strings.len]]"
