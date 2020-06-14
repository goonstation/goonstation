/datum/targetable/wrestler/throw
	name = "Throw (grab)"
	desc = "Spin a grabbed opponent around and throw them."
	icon_state = "Throw"
	targeted = 0
	target_anything = 0
	target_nodamage_check = 0
	target_selection_check = 0
	max_range = 0
	cooldown = 300
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



		var/mob/living/HH = G.affecting
		if(check_target_immunity( HH ))
			M.visible_message("<span class='alert'>You seem to attack [HH]!</span>")
			return 1
		HH.set_loc(M.loc)
		HH.dir = get_dir(HH, M)

		if (M.invisibility > 0)
			for (var/obj/item/cloaking_device/I in M)
				if (I.active)
					I.deactivate(M)
					M.visible_message("<span class='notice'><b>[M]'s cloak is disrupted!</b></span>")

		HH.changeStatus("stunned", 4 SECONDS)
		M.visible_message("<span class='alert'><B>[M] starts spinning around with [HH]!</B></span>")
		M.emote("scream")

		for (var/i = 0, i < 20, i++)
			var/delay = 5
			switch (i)
				if (17 to INFINITY)
					delay = 0.25
				if (14 to 16)
					delay = 0.5
				if (9 to 13)
					delay = 1
				if (5 to 8)
					delay = 2
				if (0 to 4)
					delay = 3

			if (M && HH)
				// These are necessary because of the sleep call.
				if (!G || !istype(G) || G.state < 1)
					boutput(M, __red("You can't throw the target without a firm grab!"))
					return 0

				if (src.castcheck() != 1)
					qdel(G)
					return 0

				if (get_dist(M, HH) > 1)
					boutput(M, __red("[HH] is too far away!"))
					qdel(G)
					return 0

				if (!isturf(M.loc) || !isturf(HH.loc))
					boutput(M, __red("You can't throw [HH] from here!"))
					qdel(G)
					return 0

				M.dir = turn(M.dir, 90)
				var/turf/T = get_step(M, M.dir)
				var/turf/S = HH.loc
				if ((S && isturf(S) && S.Exit(HH)) && (T && isturf(T) && T.Enter(HH)))
					HH.set_loc(T)
					HH.dir = get_dir(HH, M)
			else
				return 0

			sleep (delay)

		if (M && HH)
			// These are necessary because of the sleep call.
			if (!G || !istype(G) || G.state < 1)
				boutput(M, __red("You can't throw the target without a firm grab!"))
				return 0

			if (src.castcheck() != 1)
				qdel(G)
				return 0

			if (get_dist(M, HH) > 1)
				boutput(M, __red("[HH] is too far away!"))
				qdel(G)
				return 0

			if (!isturf(M.loc) || !isturf(HH.loc))
				boutput(M, __red("You can't throw [HH] from here!"))
				qdel(G)
				return 0

			HH.set_loc(M.loc) // Maybe this will help with the wallthrowing bug.
			qdel(G)

			M.visible_message("<span class='alert'><B>[M] [pick_string("wrestling_belt.txt", "throw")] [HH]!</B></span>")
			playsound(M.loc, "swing_hit", 50, 1)

			var/turf/T = get_edge_target_turf(M, M.dir)
			if (T && isturf(T))
				SPAWN_DBG(0)
					if (!isdead(HH))
						HH.emote("scream")
					if (!fake)
						HH.throw_at(T, 10, 4)
						HH.changeStatus("weakened", 2 SECONDS)
						HH.force_laydown_standup()
						HH.change_misstep_chance(33)
					else
						HH.throw_at(T, 3, 1)


			logTheThing("combat", M, HH, "uses the [fake ? "fake " : ""]throw wrestling move on %target% at [log_loc(M)].")

		if (G && istype(G)) // Target was gibbed before we could throw them, who knows.
			qdel(G)

		return 0

/datum/targetable/wrestler/throw/fake
	fake = 1