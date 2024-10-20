/datum/targetable/wrestler/kick
	name = "Kick"
	desc = "A powerful kick, sends people flying away from you. Also useful for escaping from bad situations."
	icon_state = "Kick"
	targeted = 1
	target_anything = 0
	target_nodamage_check = 1
	target_selection_check = 1
	max_range = 1
	cooldown = 200
	start_on_cooldown = 1
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0

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

		. = ..()
		SEND_SIGNAL(M, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

		M.emote("scream")
		M.emote("flip")
		M.set_dir(turn(M.dir, 90))

		for (var/mob/C in oviewers(M))
			shake_camera(C, 8, 24)

		M.visible_message(SPAN_ALERT("<B>[M.name] [pick_string("wrestling_belt.txt", "kick")]-kicks [target]!</B>"))
		if (!fake)
			random_brute_damage(target, 15, 1)
		playsound(M.loc, "swing_hit", 60, 1)

		var/turf/T = get_edge_target_turf(M, get_dir(M, get_step_away(target, M)))
		if (!fake && T && isturf(T))
			target.throw_at(T, 3, 2, bonus_throwforce = 15)
			target.changeStatus("knockdown", 3 SECONDS)
			target.changeStatus("stunned", 3 SECONDS)
			target.changeStatus("slowed", 8 SECONDS, 2)
			target.force_laydown_standup()

		logTheThing(LOG_COMBAT, M, "uses the [fake ? "fake " : ""][name] wrestling move on [constructTarget(target,"combat")] at [log_loc(M)].")
		return 0

	logCast(atom/target)
		return

/datum/targetable/wrestler/kick/fake
	fake = 1
