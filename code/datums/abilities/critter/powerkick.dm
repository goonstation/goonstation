// -----------------
// Throw kick
// -----------------
/datum/targetable/critter/powerkick
	name = "Power Kick"
	desc = "A powerful kick, sends people flying away from you and launches objects. Can force open doors and smash tables."
	cooldown = 150
	targeted = 1
	target_anything = 1
	icon_state = "power_kick"

	cast(atom/target)
		if (..())
			return 1
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to kick there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to kick.</span>")
			return 1

		var/mob/ow = holder.owner

		if (isobj(target))
			var/obj/O = target
			for (var/mob/C in oviewers(ow))
				shake_camera(C, 2, 8)

			var/kickverb = pick("socks", "slams", "kicks", "boots", "throws", "flings", "launches")
			var/kicktype = pick("kick", "roundhouse", "thrust")
			ow.visible_message("<span class='alert'><B>[ow.name] [kickverb] [target] with a powerful [kicktype]!</B></span>")

			playsound(ow.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)

			ow.changeStatus("stunned", 1 SECOND)
			ow.changeStatus("weakened", 1 SECOND)

			switch (ow.smash_through(O, list("window", "grille", "table"), 0))
				if (0)
					if (istype(O, /obj/machinery/door) && O.density)
						var/obj/machinery/door/D = O
						D.try_force_open(src)
						return
					else if (istype(O,/obj/machinery/vending))
						var/obj/machinery/vending/V = O
						V.fall(src)
						return
					else if (istype(O,/obj/machinery/portable_atmospherics/canister))
						var/obj/machinery/portable_atmospherics/canister/C = O
						C.health -= 30
						C.healthcheck()
					else
						var/turf/T = get_edge_target_turf(ow, get_dir(ow, get_step_away(O, ow)))
						if (T && isturf(T) && !O.anchored)
							O.throw_at(T, 5, 2)
				if (1)
					return

			logTheThing(LOG_COMBAT, ow, "uses Power Kick on [constructTarget(target,"combat")] at [log_loc(ow)].")

		else if (ismob(target))
			var/mob/M = target

			M.emote("scream")
			M.emote("flip")
			M.set_dir(turn(M.dir, 90))

			for (var/mob/C in oviewers(M))
				shake_camera(C, 2, 8)

			var/kickverb = pick("socks", "slams", "kicks", "boots", "throws")
			var/kicktype = pick("kick", "roundhouse", "thrust")
			M.visible_message("<span class='alert'><B>[ow.name] [kickverb] [target] with a powerful [kicktype]!</B></span>")

			random_brute_damage(target, 10,1)
			playsound(M.loc, "swing_hit", 60, 1)

			ow.changeStatus("stunned", 1 SECOND)
			ow.changeStatus("weakened", 1 SECOND)

			var/turf/T = get_edge_target_turf(M, get_dir(M, get_step_away(target, M)))
			if (T && isturf(T))
				M.throw_at(T, 5, 2)
				M.changeStatus("stunned", 1 SECOND)

			logTheThing(LOG_COMBAT, M, "uses Power Kick on [constructTarget(target,"combat")] at [log_loc(M)].")
		return 0
