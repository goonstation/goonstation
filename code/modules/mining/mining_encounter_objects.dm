/obj/flock_encounter_pedestal
	name = "mysterious pedestal"
	desc = "Some sort of pedestal. Maybe it can be interacted with?"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "pedestal-off"
	anchored = ANCHORED_ALWAYS
	density = TRUE
	var/obj/machinery/door/feather/invincible/connected_door
	var/list/adjacent_pedestals
	var/on = FALSE

	attack_hand(mob/user)
		..()
		src.toggle(user)

	proc/toggle(mob/user, recursion_check = FALSE)
		src.on = !src.on
		src.icon_state = src.on ? "pedestal-on" : "pedestal-off"
		src.connected_door.check_puzzle_solved()
		if (recursion_check)
			return
		for (var/obj/flock_encounter_pedestal/pedestal as anything in src.adjacent_pedestals)
			pedestal.toggle(null, TRUE)
		if (src.on)
			boutput(user, SPAN_NOTICE("You activate [src]!"))
		else
			boutput(user, SPAN_NOTICE("You deactivate [src]!"))

	disposing()
		..()
		src.connected_door = null
		src.adjacent_pedestals = null

/obj/machinery/door/feather/invincible
	name = "strong imposing wall"
	health = INFINITY
	health_max = INFINITY
	hardened = TRUE
	autoclose = FALSE
	var/list/pedestals = list()

	New()
		..()
		src.desc += " This looks quite tough, you probably won't be able to break it down!"

		SPAWN(1 SECOND)
			var/turf/pedestal_1_loc = locate(src.x, src.y + 4, src.z)
			var/turf/pedestal_2_loc = locate(src.x + 3, src.y + 1, src.z)
			var/turf/pedestal_3_loc = locate(src.x, src.y - 2, src.z)
			var/turf/pedestal_4_loc = locate(src.x - 3, src.y + 1, src.z)

			var/obj/flock_encounter_pedestal/pedestal_1 = locate(/obj/flock_encounter_pedestal) in pedestal_1_loc
			pedestal_1.connected_door = src
			src.pedestals += pedestal_1
			var/obj/flock_encounter_pedestal/pedestal_2 = locate(/obj/flock_encounter_pedestal) in pedestal_2_loc
			pedestal_2.connected_door = src
			src.pedestals += pedestal_2
			var/obj/flock_encounter_pedestal/pedestal_3 = locate(/obj/flock_encounter_pedestal) in pedestal_3_loc
			pedestal_3.connected_door = src
			src.pedestals += pedestal_3
			var/obj/flock_encounter_pedestal/pedestal_4 = locate(/obj/flock_encounter_pedestal) in pedestal_4_loc
			pedestal_4.connected_door = src
			src.pedestals += pedestal_4

			pedestal_1.adjacent_pedestals = list(pedestal_2, pedestal_4)
			pedestal_2.adjacent_pedestals = list(pedestal_1, pedestal_3)
			pedestal_3.adjacent_pedestals = list(pedestal_3, pedestal_4)
			pedestal_4.adjacent_pedestals = list(pedestal_1, pedestal_3)

			shuffle_list(src.pedestals)
			for (var/i in 2 to rand(2, 3))
				var/obj/flock_encounter_pedestal/pedestal = src.pedestals[i]
				pedestal.toggle(null, TRUE)

	disposing()
		..()
		src.pedestals = null

	proc/check_puzzle_solved()
		var/pedestals_on = 0
		for (var/obj/flock_encounter_pedestal/pedestal as anything in src.pedestals)
			if (pedestal.on)
				pedestals_on++
		if (pedestals_on >= 4 && src.density)
			src.open()
