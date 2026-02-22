/datum/targetable/wrestler/throw
	name = "Throw (grab)"
	desc = "Spin a grabbed opponent around and throw them."
	icon_state = "Throw"
	targeted = 0
	target_anything = 0
	target_nodamage_check = 0
	target_selection_check = 0
	max_range = 0
	cooldown = 200
	start_on_cooldown = 1
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		var/obj/item/grab/G = src.grab_check(null, 1, 1)
		if (!G || !istype(G))
			return 1



		. = ..()
		var/mob/living/HH = G.affecting
		if(check_target_immunity( HH ))
			M.visible_message(SPAN_ALERT("You seem to attack [HH]!"))
			return 1
		HH.set_loc(M.loc)
		HH.set_dir(get_dir(HH, M))

		SEND_SIGNAL(M, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

		HH.changeStatus("stunned", 4 SECONDS)
		M.visible_message(SPAN_ALERT("<B>[M] starts spinning around with [HH]!</B>"))
		M.emote("scream")
		var/i = 0
		var/spin_start = TIME
		while (TIME < spin_start + 2.5 SECONDS)
			var/delay = 5
			switch (i)
				if (17 to INFINITY)
					delay = 0.1
				if (14 to 16)
					delay = 0.25
				if (9 to 13)
					delay = 0.5
				if (5 to 8)
					delay = 1
				if (0 to 4)
					delay = 2

			if (M && HH)
				// These are necessary because of the sleep call.
				if (!G || !istype(G) || G.state == GRAB_PASSIVE)
					boutput(M, SPAN_ALERT("You can't throw the target without a firm grab!"))
					return 0

				if (src.castcheck() != 1)
					qdel(G)
					return 0

				if (!isturf(M.loc) || !isturf(HH.loc))
					boutput(M, SPAN_ALERT("You can't throw [HH] from here!"))
					qdel(G)
					return 0

				M.set_dir(turn(M.dir, 90))
				var/turf/T = get_step(M, cardinal[(i % 4) + 1])
				var/turf/S = HH.loc
				if ((S && isturf(S) && S.Exit(HH)) && (T && isturf(T) && T.Enter(HH)))
					HH.set_loc(T)
					HH.set_dir(get_dir(HH, M))
					if(TIME > spin_start + 1 SECOND)
						for(var/mob/living/L in T)
							if (L == HH || isintangible(L))
								continue
							L.throw_at(get_edge_target_turf(L, turn(get_dir(M, T), 90)), 5, 2)
							random_brute_damage(L, 10, 1)
							random_brute_damage(HH, 5, 1)
			else
				return 0

			sleep (delay)
			i++

		sleep(0.1 SECONDS) //let the thrower set their dir maybe
		if (M && HH)
			// These are necessary because of the sleep call.
			if (!G || !istype(G) || G.state == GRAB_PASSIVE)
				boutput(M, SPAN_ALERT("You can't throw the target without a firm grab!"))
				return 0

			if (src.castcheck() != 1)
				qdel(G)
				return 0

			if (!isturf(M.loc) || !isturf(HH.loc))
				boutput(M, SPAN_ALERT("You can't throw [HH] from here!"))
				qdel(G)
				return 0

			HH.set_loc(M.loc) // Maybe this will help with the wallthrowing bug.
			qdel(G)

			M.visible_message(SPAN_ALERT("<B>[M] [pick_string("wrestling_belt.txt", "throw")] [HH]!</B>"))
			playsound(M.loc, "swing_hit", 50, 1)

			var/turf/T = get_edge_target_turf(M, M.dir)
			if (T && isturf(T))
				if (!fake)
					HH.set_loc(get_turf(M))
					HH.throw_at(T, 10, 4, bonus_throwforce = 33) // y e e t
					HH.changeStatus("knockdown", 3 SECONDS)
					HH.force_laydown_standup()
					HH.change_misstep_chance(50)
					HH.changeStatus("slowed", 8 SECONDS, 2)
				else
					HH.throw_at(T, 3, 1)


			logTheThing(LOG_COMBAT, M, "uses the [fake ? "fake " : ""][name] wrestling move on [constructTarget(target,"combat")] at [log_loc(M)].")
		if (G && istype(G)) // Target was gibbed before we could throw them, who knows.
			qdel(G)

		return 0

	logCast(atom/target)
		return

/datum/targetable/wrestler/throw/fake
	fake = 1
