//stolen from rev, copy paste hell due to ability pathing, should refactor to share code with rev version
/datum/targetable/critter/shockwave
	name = "Shockwave"
	desc = "Emit a shockwave, breaking nearby lights and walls, and stunning nearby humans for a short time."
	icon_state = "template"
	targeted = 0
	cooldown = 8 SECONDS
	var/x_offset = 0
	var/y_offset = 0
	var/propagation_percentage = 100
	var/iteration_depth = 3
	var/static/list/prev = list("1" = NORTHWEST, "5" = NORTH, "4" = NORTHEAST, "6" = EAST,  "2" = SOUTHEAST, "10" = SOUTH, "8" = SOUTHWEST, "9" = WEST)
	var/static/list/next = list("1" = NORTHEAST, "5" = EAST,  "4" = SOUTHEAST, "6" = SOUTH, "2" = SOUTHWEST, "10" = WEST,  "8" = NORTHWEST, "9" = NORTH)

	proc/shock(var/turf/T)
		animate_revenant_shockwave(T, 1, 3)
		SPAWN(0)
			for (var/mob/living/carbon/human/M in T)
				M.changeStatus("knockdown", 2 SECONDS)
				M.force_laydown_standup()
				M.show_message(SPAN_ALERT("A shockwave sweeps you off your feet!"))
			for (var/obj/machinery/light/L in T)
				L.broken()
			for (var/obj/window/W in T)
				W.health = 0
				W.smash()
			if (istype(T, /turf/simulated/wall))
				var/turf/simulated/wall/W = T
				W.dismantle_wall()
			else if (istype(T, /turf/simulated/floor) && prob(75))
				var/turf/simulated/floor/F = T
				if (prob(50))
					F.to_plating()
				else
					F.break_tile()
			sleep(1 SECOND)
			T.pixel_y = 0
			T.transform = null

	cast()
		var/list/next = list()
		var/list/NN = list()
		var/turf/origin = get_turf(holder.owner)
		if (src.x_offset || src.y_offset)
			origin = locate((origin.x + src.x_offset), (origin.y + src.y_offset), origin.z)
		if (!origin)
			return 1
		. = ..()
		shock(origin)
		playsound(origin, 'sound/effects/ExplosionFirey.ogg', 30, 0)
		for (var/turf/T in orange(1, origin))
			next += T
			next[T] = get_dir(origin, T)
		SPAWN(0)
			for (var/i = 1, i <= iteration_depth, i++)
				for (var/turf/T in next)
					shock(T)
					if (!T.density)
						var/base_dir = next[T]
						var/left_dir = src.prev["[base_dir]"]
						var/right_dir = src.next["[base_dir]"] // ugly & fuck you byond for making me do this
						if (prob(propagation_percentage / 2))
							var/turf/A = get_step(T, left_dir)
							if (A && !(A in NN))
								NN += A
								NN[A] = left_dir
						if (prob(propagation_percentage))
							var/turf/B = get_step(T, base_dir)
							if (B && !(B in NN))
								NN += B
								NN[B] = base_dir
						if (prob(propagation_percentage / 2))
							var/turf/C = get_step(T, right_dir)
							if (C && !(C in NN))
								NN += C
								NN[C] = right_dir
				next = NN
				NN = list()
				sleep(0.3 SECONDS)
		return 0
