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

	var/list/magnet_do_not_erase = list(/obj/securearea,/obj/forcefield/mining,/obj/mesh/catwalk, /obj/overlay)

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

		if (length(category) < 1)
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
	do_not_irradiate = FALSE

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
	anchored = ANCHORED

	ex_act()
		return

	blob_act()
		return

	meteorhit()
		return
