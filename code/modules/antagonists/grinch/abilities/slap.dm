/datum/targetable/grinch/slap
	name = "Slap"
	desc = "Slap a creature away with your mighty grinch hand."
	icon_state = "grinchcloak"
	targeted = 1
	target_anything = 0
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
			M.visible_message(SPAN_ALERT("The Grinch slaps themself..?"))

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1
		if(check_target_immunity( target ))
			M.visible_message(SPAN_ALERT("You seem to attack [target]!"))
			return 1

		. = ..()
		SEND_SIGNAL(M, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)

		var/turf/T = get_turf(M)
		if (T && isturf(T) && target && isturf(target.loc))
			playsound(M.loc, "swing_hit", 50, 1)
			M.set_dir(get_dir(M, target))
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "stall")
			APPLY_ATOM_PROPERTY(target, PROP_MOB_CANTMOVE, "stall")
			var/obj/effects/grinch_hand/hand = new /obj/effects/grinch_hand (get_turf(M))
			hand.dir = M.dir

			SPAWN(1.3 SECONDS)
				REMOVE_ATOM_PROPERTY(target, PROP_MOB_CANTMOVE, "stall")
				playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
				random_brute_damage(target, 15, 1)
				var/atom/targetTurf = get_edge_target_turf(target, M.dir)
				var/mob/living/carbon/human/target_human = target
				target_human.throw_at(targetTurf, 30, 4)
				target.changeStatus("unconscious", 2 SECONDS)
				target.changeStatus("knockdown", 3 SECONDS)
				target.force_laydown_standup()
				target.change_misstep_chance(25)
				REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "stall")
			SPAWN(2.1 SECONDS)
				qdel(hand)
				M.anchored = 0

		else
			boutput(M, SPAN_ALERT("You can't slap the target here!"))

		return 0

	logCast(atom/target)
		return
