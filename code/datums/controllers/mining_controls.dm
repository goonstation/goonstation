var/datum/mining_controller/mining_controls

var/list/asteroid_blocked_turfs = list()

/datum/mining_controller
	var/mining_z = 4
	var/mining_z_asteroids_max = 0
	var/list/ore_types_all = list()
	var/list/ore_types_common = list()
	var/list/ore_types_uncommon = list()
	var/list/ore_types_rare = list()
	var/list/events = list()
	var/list/weighted_events = list()
	// magnet vars
	var/turf/magnetic_center = null
	var/area/mining/magnet/magnet_area = null
	var/list/magnet_shields = list()
	var/max_magnet_spawn_size = 7
	var/min_magnet_spawn_size = 4
	var/list/mining_encounters_all = list()
	var/list/mining_encounters_common = list()
	var/list/mining_encounters_uncommon = list()
	var/list/mining_encounters_rare = list()
	var/list/small_encounters = list()
	var/list/mining_encounters_selectable = list()

	var/list/magnet_do_not_erase = list(/obj/securearea,/obj/forcefield/mining,/obj/grille/catwalk,/obj/grille/catwalk/cross, /obj/overlay)

	New()
		..()
		for (var/X in childrentypesof(/datum/ore) - /datum/ore/event)
			var/datum/ore/O = new X
			ore_types_common += O
			ore_types_all += O

		for (var/X in childrentypesof(/datum/mining_encounter))
			var/datum/mining_encounter/MC = new X
			mining_encounters_common += MC
			mining_encounters_all += MC

		for (var/datum/ore/O in src.ore_types_common)
			if (O.no_pick)
				ore_types_common -= O
				continue

			if (istype(O, /datum/ore/event/))
				var/datum/ore/event/E = O
				events += E
				weighted_events[E] = initial(E.weight)
				ore_types_common -= O
			if (O.rarity_tier == 2)
				ore_types_uncommon += O
				ore_types_common -= O
			else if (O.rarity_tier == 3)
				ore_types_rare += O
				ore_types_common -= O
			O.set_up()

		for (var/datum/mining_encounter/MC in mining_encounters_common)
			if (MC.no_pick)
				mining_encounters_common -= MC
				continue

			if (MC.rarity_tier == 3)
				mining_encounters_rare += MC
				mining_encounters_common -= MC
			else if (MC.rarity_tier == 2)
				mining_encounters_uncommon += MC
				mining_encounters_common -= MC
			else if (MC.rarity_tier == -1)
				small_encounters += MC
				mining_encounters_common -= MC
			else if (MC.rarity_tier != 1)
				mining_encounters_common -= MC
				qdel(MC)

	proc/setup_mining_landmarks()
		for(var/turf/T in landmarks[LANDMARK_MAGNET_CENTER])
			magnetic_center = T
			magnet_area = get_area(T)
			break

		for(var/turf/T in landmarks[LANDMARK_MAGNET_SHIELD])
			var/obj/forcefield/mining/S = new /obj/forcefield/mining(T)
			magnet_shields += S

	proc/spawn_mining_z_asteroids(var/amt, var/zlev)
		SPAWN(0)
			var/the_mining_z = zlev ? zlev : src.mining_z
			var/turf/T
			var/spawn_amount = amt ? amt : src.mining_z_asteroids_max
			for (var/i=spawn_amount, i>0, i--)
				LAGCHECK(LAG_LOW)
				T = locate(rand(8,(world.maxy - 8)),rand(8,(world.maxy - 8)),the_mining_z)
				if (istype(T))
					T.GenerateAsteroid(rand(4,15))
			message_admins("Asteroid generation on z[the_mining_z] complete: ")

	proc/get_ore_from_string(var/string)
		if (!istext(string))
			return
		for (var/datum/ore/O in ore_types_all)
			if (O.name == string)
				return O
		return null

	proc/get_ore_from_path(var/path)
		if (!ispath(path))
			return
		for (var/datum/ore/O in ore_types_all)
			if (O.type == path)
				return O
		return null

	proc/get_encounter_by_name(var/enc_name = null)
		if(enc_name)
			for(var/datum/mining_encounter/A in mining_encounters_all)
				if(A.name == enc_name)
					return A
		return null

	proc/add_selectable_encounter(var/datum/mining_encounter/A)
		if(A)
			var/number = "[(mining_encounters_selectable.len + 1)]"
			mining_encounters_selectable += number
			mining_encounters_selectable[number] = A
		return

	proc/remove_selectable_encounter(var/number_id)
		if(mining_encounters_selectable.Find(number_id))
			//var/datum/mining_encounter/A = mining_encounters_selectable[number_id]
			mining_encounters_selectable.Remove(number_id)

			var/list/rebuiltList = list()
			var/count = 1

			for(var/X in mining_encounters_selectable)
				rebuiltList.Add("[count]")
				rebuiltList["[count]"] = mining_encounters_selectable[X]
				count++

			mining_encounters_selectable = rebuiltList

		return

	proc/select_encounter(var/rarity_mod)
		if (!isnum(rarity_mod))
			rarity_mod = 0
		var/chosen = RarityClassRoll(100,rarity_mod,list(95,70))

		var/list/category = mining_controls.mining_encounters_common
		switch(chosen)
			if (2)
				category = mining_controls.mining_encounters_uncommon
			if (3)
				category = mining_controls.mining_encounters_rare

		if (category.len < 1)
			category = mining_controls.mining_encounters_common

		return pick(category)

	proc/select_small_encounter(var/rarity_mod)
		return pick(small_encounters)

/area/mining/magnet
	name = "Magnet Area"
	icon_state = "purple"
	force_fullbright = 1
	requires_power = 0
	luminosity = 1
	expandable = 0

/obj/forcefield/mining
	name = "magnetic forcefield"
	desc = "A powerful field used by the mining magnet to attract minerals."
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "noise6"
	color = "#BF12DE"
	alpha = 175
	opacity = 0
	density = 0
	invisibility = INVIS_ALWAYS
	anchored = 1

/// *** MISC *** ///

/proc/getOreQualityName(var/quality)
	switch(quality)
		if(-INFINITY to -101)
			return "worthless"
		if(-100 to -51)
			return "terrible"
		if(-50 to -41)
			return "awful"
		if(-40 to -31)
			return "bad"
		if(-30 to -21)
			return "low-grade"
		if(-20 to -11)
			return "poor"
		if(-10 to -1)
			return "impure"
		if(0)
			return ""
		if(1 to 10)
			return "decent"
		if(11 to 20)
			return "fine"
		if(21 to 30)
			return "good"
		if(31 to 40)
			return "high-quality"
		if(41 to 50)
			return "excellent"
		if(51 to 60)
			return "fantastic"
		if(61 to 70)
			return "amazing"
		if(71 to 80)
			return "incredible"
		if(81 to 90)
			return "supreme"
		if(91 to 100)
			return "pure"
		if(101 to INFINITY)
			return "perfect"
		else
			return "strange"

/proc/getGemQualityName(var/quality)
	switch(quality)
		if(-INFINITY to -101)
			return "worthless"
		if(-100 to -51)
			return "awful"
		if(-50 to -41)
			return "shattered"
		if(-40 to -31)
			return "broken"
		if(-30 to -21)
			return "cracked"
		if(-20 to -11)
			return "flawed"
		if(-10 to -1)
			return "dull"
		if(0)
			return ""
		if(1 to 10)
			return "pretty"
		if(11 to 20)
			return "shiny"
		if(21 to 30)
			return "gleaming"
		if(31 to 40)
			return "sparkling"
		if(41 to 50)
			return "glittering"
		if(51 to 60)
			return "beautiful"
		if(61 to 70)
			return "lustrous"
		if(71 to 80)
			return "iridescent"
		if(81 to 90)
			return "radiant"
		if(91 to 100)
			return "pristine"
		if(101 to INFINITY)
			return "perfect"
		else
			return "strange"
