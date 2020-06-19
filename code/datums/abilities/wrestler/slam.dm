/datum/targetable/wrestler/slam
	name = "Slam (grab)"
	desc = "Slam a grappled opponent into the floor."
	icon_state = "Slam"
	targeted = 0
	target_anything = 0
	target_nodamage_check = 0
	target_selection_check = 0
	max_range = 0
	cooldown = 350
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
			M.visible_message("<span class='alert'>You seem to attack [M]!</span>")
			return 1
		if (M.invisibility > 0)
			for (var/obj/item/cloaking_device/I in M)
				if (I.active)
					I.deactivate(M)
					M.visible_message("<span class='notice'><b>[M]'s cloak is disrupted!</b></span>")

		HH.set_loc(M.loc)
		M.dir = get_dir(M, HH)
		HH.dir = get_dir(HH, M)

		M.visible_message("<span class='alert'><B>[M] lifts [HH] up!</B></span>")

		SPAWN_DBG (0)
			if (HH)
				animate(HH, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
				sleep (15)
				if (HH)
					animate(HH, transform = null, time = 1, loop = 0)

		var/GT = G.state // Can't include a possibly non-existent item in the loop before we can run the check.
		for (var/i = 0, i < (GT * 3), i++)
			if (M && HH)
				M.pixel_y += 3
				HH.pixel_y += 3
				M.dir = turn(M.dir, 90)
				HH.dir = turn(HH.dir, 90)

				switch (M.dir)
					if (NORTH)
						HH.pixel_x = M.pixel_x
					if (SOUTH)
						HH.pixel_x = M.pixel_x
					if (EAST)
						HH.pixel_x = M.pixel_x - 8
					if (WEST)
						HH.pixel_x = M.pixel_x + 8

				// These are necessary because of the sleep call.
				if (!G || !istype(G) || G.state < 1)
					boutput(M, __red("You can't slam the target without a firm grab!"))
					M.pixel_x = 0
					M.pixel_y = 0
					HH.pixel_x = 0
					HH.pixel_y = 0
					return 0

				if (src.castcheck() != 1)
					qdel(G)
					M.pixel_x = 0
					M.pixel_y = 0
					HH.pixel_x = 0
					HH.pixel_y = 0
					return 0

				if (get_dist(M, HH) > 1)
					boutput(M, __red("[target] is too far away!"))
					qdel(G)
					M.pixel_x = 0
					M.pixel_y = 0
					HH.pixel_x = 0
					HH.pixel_y = 0
					return 0

				if (!isturf(M.loc) || !isturf(HH.loc))
					boutput(M, __red("You can't slam [target] here!"))
					qdel(G)
					M.pixel_x = 0
					M.pixel_y = 0
					HH.pixel_x = 0
					HH.pixel_y = 0
					return 0
			else
				if (M)
					M.pixel_x = 0
					M.pixel_y = 0
				if (HH)
					HH.pixel_x = 0
					HH.pixel_y = 0
				return 0

			sleep (1)

		if (M && HH)
			M.pixel_x = 0
			M.pixel_y = 0
			HH.pixel_x = 0
			HH.pixel_y = 0

			// These are necessary because of the sleep call.
			if (!G || !istype(G) || G.state < 1)
				boutput(M, __red("You can't slam the target without a firm grab!"))
				return 0

			if (src.castcheck() != 1)
				qdel(G)
				return 0

			if (get_dist(M, HH) > 1)
				boutput(M, __red("[HH] is too far away!"))
				qdel(G)
				return 0

			if (!isturf(M.loc) || !isturf(HH.loc))
				boutput(M, __red("You can't slam [HH] here!"))
				qdel(G)
				return 0

			HH.set_loc(M.loc)

			var/fluff = pick_string("wrestling_belt.txt", "slam")
			switch (G.state)
				if (2)
					fluff = "turbo [fluff]"
				if (3)
					fluff = "atomic [fluff]"
					playsound(M.loc, "sound/effects/explosionfar.ogg", 60, 1)

			playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
			M.visible_message("<span class='alert'><B>[M] [fluff] [HH]!</B></span>")

			if (!fake)
				if (!isdead(HH))
					HH.emote("scream")
					HH.changeStatus("weakened", 2 SECONDS)
					HH.changeStatus("stunned", 2 SECONDS)
					HH.force_laydown_standup()

					switch (G.state)
						if (2)
							random_brute_damage(HH, 25, 1)
						if (3)
							HH.ex_act(3)
						else
							random_brute_damage(HH, 15, 1)
				else
					HH.ex_act(3)

			qdel(G)
			logTheThing("combat", M, HH, "uses the [fake ? "fake " : ""]slam wrestling move on %target% at [log_loc(M)].")

		else
			if (M)
				M.pixel_x = 0
				M.pixel_y = 0
			if (HH)
				HH.pixel_x = 0
				HH.pixel_y = 0

		if (G && istype(G)) // Target was gibbed before we could slam them, who knows.
			qdel(G)

		return 0

/datum/targetable/wrestler/slam/fake
	fake = 1