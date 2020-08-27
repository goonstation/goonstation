/mob/living/carbon/human/var/uses_mobai = 0

/datum/aiHolder/human

/datum/aiTask/timed/targeted/human/get_targets()
	var/list/targets = list()
	if(holder.owner)
		for(var/mob/living/M in view(target_range, holder.owner))
			if(M == holder.owner) continue
			if(isalive(M))
				targets += M
	return targets



/datum/aiTask/timed/targeted/human
	frustration_check()
		.= 0
		if (!IN_RANGE(holder.owner, holder.target, target_range))
			if(frustration >= frustration_threshold) // give up already you goddamn salad.
				holder.target = null
			return 1

		if (ismob(holder.target))
			var/mob/M = holder.target
			. = !(holder.target && isalive(M))
		else
			. = !(holder.target)

/datum/aiTask/timed/targeted/human/get_weapon
	name = "getting strapped"
	minimum_task_ticks = 3
	maximum_task_ticks = 5
	target_range = 5
	frustration_threshold = 2
	var/last_seek = 0

	get_targets()
		var/list/targets = list()
		if(holder.owner)
			for(var/obj/item/gun/G in view(target_range, holder.owner))
				if(G.canshoot())
					targets += G
			if(!targets.len)
				for(var/obj/item/I in view(target_range, holder.owner))
					if(I.force >= 3)
						targets += I
		return targets

	next_task()
		if(holder.ownhuman.equipped())
			return transition_task
		return null

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)

		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()

			if (dist <= 1)
				holder.ownhuman.put_in_hand_or_drop(holder.target)




/datum/aiTask/timed/targeted/human/flee
	name = "running away"
	minimum_task_ticks = 3
	maximum_task_ticks = 10
	target_range = 2
	frustration_threshold = 4
	var/last_seek = 0

	frustration_check()
		.= 0
		if (IN_RANGE(holder.owner, holder.target, target_range))
			return 1

	on_tick()
		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)

		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if(dist <= 1)
				holder.ownhuman.a_intent = INTENT_DISARM
				holder.ownhuman.dir = get_dir(holder.ownhuman, holder.target)
				var/list/params = list()
				params["left"] = 1
				holder.ownhuman.hand_attack(holder.target, params)

			if(dist <= target_range + 3)
				if(prob(25))
					holder.move_circ(holder.target,target_range)
				else
					holder.move_away(holder.target,target_range)
		..()


/datum/aiTask/timed/targeted/human/boxing/
	name = "boxing"
	minimum_task_ticks = 10
	maximum_task_ticks = 26
	target_range = 8
	frustration_threshold = 5
	var/last_seek = 0

	on_tick()

		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)
		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()

			if (ismob(holder.target))
				var/list/params = list()
				params["left"] = 1
				var/mob/living/M = holder.target
				if(!isalive(M))
					holder.target = null
					holder.target = get_best_target(get_targets())
					if(!holder.target)
						return ..() // try again next tick
				if ((dist <= 3) && holder.ownhuman.equipped())
					holder.ownhuman.dir = get_dir(holder.ownhuman, M)
					holder.ownhuman.throw_item(holder.target,params)
				if (dist <= 1)
					holder.ownhuman.a_intent = INTENT_HARM
					holder.ownhuman.dir = get_dir(holder.ownhuman, M)

					holder.ownhuman.hand_attack(M, params)
				if(prob(25))
					holder.move_circ(holder.target,2)

		..()

/datum/aiTask/timed/targeted/human/suplex/
	name = "suplex"
	minimum_task_ticks = 7
	maximum_task_ticks = 16
	//var/weight = 15
	target_range = 8
	frustration_threshold = 5
	var/last_seek = 0

	on_tick()

		if (HAS_MOB_PROPERTY(holder.ownhuman, PROP_CANTMOVE) || !isalive(holder.ownhuman))
			return

		if(!holder.target)
			if (world.time > last_seek + 4 SECONDS)
				last_seek = world.time
				var/list/possible = get_targets()
				if (possible.len)
					holder.target = pick(possible)
		if(holder.target && holder.target.z == holder.ownhuman.z)
			var/dist = get_dist(holder.ownhuman, holder.target)
			if (dist >= 1)
				if (prob(80))
					holder.move_to(holder.target,0)
				else
					holder.move_circ(holder.target)
			else
				holder.stop_move()

			if (ismob(holder.target))
				var/mob/living/M = holder.target
				if(!isalive(M))
					holder.target = null
					holder.target = get_best_target(get_targets())
					if(!holder.target)
						return ..() // try again next tick
				if (dist <= 1)
					holder.ownhuman.a_intent = INTENT_GRAB

					holder.ownhuman.dir = get_dir(holder.ownhuman, M)

					var/list/params = list()
					params["left"] = 1

					if (!holder.ownhuman.equipped())
						holder.ownhuman.hand_attack(M, params)
					else
						var/obj/item/grab/G = holder.ownhuman.equipped()
						if (istype(G))
							if (G.affecting == null || G.assailant == null || G.disposed) //ugly safety
								holder.ownhuman.drop_item()

							if (G.state <= GRAB_PASSIVE)
								G.attack_self(holder.ownhuman)
							else
								holder.ownhuman.emote("flip")
								holder.move_away(holder.target,1)
						else
							holder.ownhuman.drop_item()
			else
				holder.move_circ(holder.target,2)

		..()

