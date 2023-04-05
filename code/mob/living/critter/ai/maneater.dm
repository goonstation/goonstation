
/datum/aiHolder/maneater
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/maneater, list(src))


/datum/aiTask/prioritizer/critter/maneater
	name = "Maneater priorisation"

	New()
		..()
		transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/maneater_hunting, list(holder, src))
		transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))

	on_reset()
		..()
		holder.stop_move()

/datum/aiTask/timed/targeted/maneater_hunting
	name = "hunt for devouring"
	minimum_task_ticks = 20
	maximum_task_ticks = 30
	weight = 25
	target_range = 6
	frustration_threshold = 5
	var/last_seek = 0
	var/time_until_new_seek = 2 SECONDS

	proc/precondition()
		. = 1

	frustration_check()
		.= 0
		if (!IN_RANGE(src.holder.owner, src.holder.target, src.target_range))
			return 1
		. = !(src.holder.target)

	evaluate()
		return src.precondition() * src.weight * src.score_target(src.get_best_target(src.get_targets()))

	get_targets()
		. = list()
		if(src.holder.owner)
			for(var/mob/living/potential_target in view(src.target_range, src.holder.owner))
				if (istype(src.holder.owner, /mob/living/critter/plant))
					var/mob/living/critter/plant/plantowner = src.holder.owner
					if (potential_target in plantowner.growers) //ignore growers of the maneater at all cost
						continue
				if (potential_target.job == "Botanist")
					continue
				if (iskudzuman(potential_target))
					continue
				if(!ismobcritter(potential_target)) //Maneaters don't care too much if alive or dead
					. += potential_target

	score_target(atom/target)
		. = 0
		if(target)
			if (istype(target, /mob/living))
				var/mob/living/evaluate_target = target
				var/dead_weighting = 100
				if (!isalive(evaluate_target))
					dead_weighting = 25 //We still want to eat dead people, just less likely
				return dead_weighting*(src.target_range - GET_MANHATTAN_DIST(get_turf(src.holder.owner), get_turf(target)))/src.target_range

	on_tick()
		var/mob/living/critter/owncritter = src.holder.owner
		if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE) || !isalive(owncritter))
			return

		if(!src.holder.target)
			if (world.time > src.last_seek + src.time_until_new_seek)
				src.last_seek = world.time
				var/list/possible = src.get_targets()
				if (possible.len)
					src.holder.target = pick(possible)
		if(src.holder.target && src.holder.target.z == owncritter.z)
			var/dist = GET_DIST(owncritter, src.holder.target)
			if (dist >= 1)
				src.holder.move_to(src.holder.target,0)
			else
				src.holder.stop_move()

			if (ismob(src.holder.target)) //should be always the case, but eh, you never know
				var/mob/living/M = holder.target
				if (dist <= 1)
					//let's grab out target :)
					owncritter.set_a_intent(INTENT_GRAB)
					owncritter.set_dir(get_dir(owncritter, M))

					var/list/params = list()
					params["left"] = 1

					if (!owncritter.equipped())
						owncritter.hand_attack(M, params)
					else
						var/obj/item/grab/G = owncritter.equipped()
						if (istype(G))
							if (G.affecting == null || G.assailant == null || G.disposed) //ugly safety
								owncritter.drop_item()

							else if (G.state <= GRAB_PASSIVE)
								G.AttackSelf(owncritter)
							//From here on, the maneater should use its munching capabilities
						else
							owncritter.drop_item()
			else
				//dunno how we got an invalid target, but let's handle this case regardless
				holder.target = null
				holder.target = get_best_target(get_targets())
				if(!holder.target)
					return ..() // try again next tick

		..()


