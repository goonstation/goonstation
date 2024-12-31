/datum/targetable/wrestler/drop
	name = "Drop (prone)"
	desc = "Smash down onto on an opponent."
	icon_state = "Drop"
	targeted = 1
	target_anything = 0
	target_nodamage_check = 1
	target_selection_check = 1
	max_range = 1
	cooldown = 250
	start_on_cooldown = 1
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target)
			return 1

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to wrestle yourself?"))
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1

		if(check_target_immunity( target ))
			M.visible_message(SPAN_ALERT("You seem to attack [target]!"))
			return 1

		if (!target.lying)
			boutput(M, SPAN_ALERT("You can use this move on prone opponents only!"))
			return 1

		. = ..()
		SEND_SIGNAL(M, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

		var/obj/surface = null
		var/turf/ST = null
		var/falling = 0

		for (var/obj/O in oview(1, M))
			if (O.density == 1 || istype(O, /obj/stool))
				if (O == M) continue
				if (O == target) continue
				if (O.opacity) continue
				if (istype(O, /obj/window) || istype(O, /obj/mesh/grille))
					continue
				else
					surface = O
					ST = get_turf(O)
					break

		if (surface && (ST && isturf(ST)))
			M.set_loc(ST)
			M.visible_message(SPAN_ALERT("<B>[M] climbs onto [surface]!</b>"))
			M.pixel_y = 10
			falling = 1
			sleep (10)

		if (M && target)
			// These are necessary because of the sleep call.
			if (src.castcheck() != 1)
				M.pixel_y = 0
				return 0

			if ((falling == 0 && GET_DIST(M, target) > src.max_range) || (falling == 1 && GET_DIST(M, target) > (src.max_range + 1))) // We climbed onto stuff.
				M.pixel_y = 0
				if (falling == 1 && !fake)
					M.visible_message(SPAN_ALERT("<B>...and dives head-first into the ground, ouch!</b>"))
					M.TakeDamageAccountArmor("head", 15, 0, 0, DAMAGE_BLUNT)
					M.changeStatus("knockdown", 3 SECONDS)
					M.force_laydown_standup()
				boutput(M, SPAN_ALERT("[target] is too far away!"))
				return 0

			if (!isturf(M.loc) || !isturf(target.loc))
				M.pixel_y = 0
				boutput(M, SPAN_ALERT("You can't drop onto [target] from here!"))
				return 0

			SPAWN(0)
				if (M)
					animate(M, transform = matrix(M.transform, 90, MATRIX_ROTATE | MATRIX_MODIFY), time = 1, loop = 0, flags = ANIMATION_PARALLEL)
				sleep (10)
				if (M)
					animate(M, transform = matrix(M.transform, -90, MATRIX_ROTATE | MATRIX_MODIFY), time = 1, loop = 0, flags = ANIMATION_PARALLEL)

			M.set_loc(target.loc)

			M.visible_message(SPAN_ALERT("<B>[M] [pick_string("wrestling_belt.txt", "drop")] [target]!</B>"))
			playsound(M.loc, "swing_hit", 50, 1)

			if (!fake)
				if (falling == 1)
					if (prob(33) || isdead(target))
						target.ex_act(3)
					else
						random_brute_damage(target, 25, 1)
				else
					random_brute_damage(target, 15, 1)

			target.changeStatus("knockdown", 3 SECOND)
			target.changeStatus("stunned", 3 SECONDS)
			target.force_laydown_standup()

			M.pixel_y = 0
			logTheThing(LOG_COMBAT, M, "uses the [fake ? "fake " : ""][name] wrestling move on [constructTarget(target,"combat")] at [log_loc(M)].")
		else
			if (M)
				M.pixel_y = 0

		return 0

	logCast(atom/target)
		return

/datum/targetable/wrestler/drop/fake
	fake = 1
