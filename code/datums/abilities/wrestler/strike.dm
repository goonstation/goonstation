/datum/targetable/wrestler/strike
	name = "Strike"
	desc = "Hit a neaby opponent with a quick attack."
	icon_state = "Strike"
	targeted = 1
	target_anything = 0
	target_nodamage_check = 1
	target_selection_check = 1
	max_range = 1
	cooldown = 150
	start_on_cooldown = 1
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target)
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to wrestle yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1
		if(check_target_immunity( target ))
			M.visible_message("<span class='alert'>You seem to attack [target]!</span>")
			return 1

		SEND_SIGNAL(M, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

		var/turf/T = get_turf(M)
		if (T && isturf(T) && target && isturf(target.loc))
			playsound(M.loc, "swing_hit", 50, 1)

			SPAWN(0)
				for (var/i = 0, i < 4, i++)
					M.set_dir(turn(M.dir, 90))

				M.set_loc(target.loc)
				sleep(4)
				if (M && (T && isturf(T) && BOUNDS_DIST(M, T) == 0))
					M.set_loc(T)

			M.visible_message("<span class='alert'><b>[M] [pick_string("wrestling_belt.txt", "strike")] [target]!</b></span>")
			playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)

			if (!fake)
				random_brute_damage(target, 15, 1)
				target.changeStatus("paralysis", 2 SECONDS)
				target.changeStatus("weakened", 3 SECONDS)
				target.force_laydown_standup()
				target.change_misstep_chance(25)

			logTheThing(LOG_COMBAT, M, "uses the [fake ? "fake " : ""]strike wrestling move on [constructTarget(target,"combat")] at [log_loc(M)].")

		else
			boutput(M, "<span class='alert'>You can't wrestle the target here!</span>")

		return 0

/datum/targetable/wrestler/strike/fake
	fake = 1
