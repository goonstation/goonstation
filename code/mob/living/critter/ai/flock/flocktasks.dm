// base shared flock AI stuff
// main default "what do we do next" task, run for one tick and then switches to a new task
/datum/aiHolder/flock


/datum/aiTask/prioritizer/flock
	name = "base thinking (should never see this)"

/datum/aiTask/prioritizer/flock/New()
	..()

/datum/aiTask/prioritizer/flock/on_tick()
	if(isdead(holder.owner))
		holder.enabled = 0
		walk(holder.owner, 0) // STOP RUNNING AROUND YOU'RE SUPPOSED TO BE DEAD

/datum/aiTask/prioritizer/flock/on_reset()
	..()
	walk(holder.owner, 0)

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// RALLY TO GOAL
// target: the rally target given when this is invoked
// precondition: none, this is an override
/datum/aiTask/sequence/goalbased/rally
	name = "rallying"
	weight = 0
	can_be_adjacent_to_target = 0
	max_dist = 0
// most of the functionality here is already in the base goalbased task, we only want movement


///////////////////////////////////////////////////////////////////////////////////////////////////////////
// REPLICATION GOAL
// targets: valid nesting sites
// precondition: 100 resources
/datum/aiTask/sequence/goalbased/replicate
	name = "replicating"
	weight = 6
	can_be_adjacent_to_target = 0

/datum/aiTask/sequence/goalbased/replicate/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/replicate, list(holder)))

/datum/aiTask/sequence/goalbased/replicate/precondition()
	. = 0
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.can_afford(100))
		. = 1

/datum/aiTask/sequence/goalbased/replicate/get_targets()
	var/list/targets = list()
	for(var/turf/simulated/floor/feather/F in view(max_dist, holder.owner))
		// let's not spam eggs all the time
		if(isnull(locate(/obj/flock_structure/egg) in F))
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), F, 0, null, /proc/heuristic, 40))
				targets += F
	return targets

////////

/datum/aiTask/succeedable/replicate
	name = "replicate subtask"
	var/has_started = 0

/datum/aiTask/succeedable/replicate/failed()
	var/mob/living/critter/flock/drone/F = holder.owner
	if(!F)
		return 1
	if(F && !F.can_afford(100))
		return 1
	var/turf/simulated/floor/feather/N = get_turf(holder.owner)
	if(!N)
		return 1

/datum/aiTask/succeedable/replicate/succeeded()
	return (!actions.hasAction(holder.owner, "flock_egg")) // for whatever reason, the required action has stopped

/datum/aiTask/succeedable/replicate/on_tick()
	if(!has_started)
		var/mob/living/critter/flock/drone/F = holder.owner
		if(F)
			F.create_egg()
			has_started = 1

/datum/aiTask/succeedable/replicate/on_reset()
	has_started = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// BUILDING GOAL
// targets: priority tiles, fetched from holder.owner.flock (with casting)
//			or, if they're not available, whatever's available nearby
// precondition: 20 resources
/datum/aiTask/sequence/goalbased/build
	name = "building"
	weight = 5
	max_dist = 2

/datum/aiTask/sequence/goalbased/build/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/build, list(holder)))

/datum/aiTask/sequence/goalbased/build/precondition()
	. = 0
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.can_afford(20))
		. = 1

/datum/aiTask/sequence/goalbased/build/get_targets()
	var/list/targets = list()
	var/mob/living/critter/flock/drone/F = holder.owner

	if(F && F.flock)
		// if we can go for a tile we already have reserved, go for it
		var/turf/simulated/reserved = F.flock.busy_tiles[F.real_name]
		if(istype(reserved) && !isfeathertile(reserved) && cirrAstar(get_turf(holder.owner), reserved, 1, null, /proc/heuristic, 20))
			targets += reserved
			return targets
		// if there's a priority tile we can go for, do it
		var/list/priority_turfs = F.flock.getPriorityTurfs(F)
		if(priority_turfs && priority_turfs.len)
			for(var/turf/simulated/PT in priority_turfs)
				// if we can get a valid path to the target, include it for consideration
				if(cirrAstar(get_turf(holder.owner), PT, 1, null, /proc/heuristic, 80))
					targets += PT
			return targets

	// else just go for one nearby
	for(var/turf/simulated/T in view(max_dist, holder.owner))
		if(istype(T, /turf/simulated/floor) && !istype(T, /turf/simulated/floor/feather) || \
			istype(T, /turf/simulated/wall) && !istype(T, /turf/simulated/wall/auto/feather))
			if(F && F.flock && !F.flock.isTurfFree(T, F.real_name))
				continue // this tile's been claimed by someone else
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), T, 1, null, /proc/heuristic, 40))
				targets += T
	return targets

////////

/datum/aiTask/succeedable/build
	name = "build subtask"
	var/has_started = 0

/datum/aiTask/succeedable/build/failed()
	var/turf/simulated/floor/build_target = holder.target
	if(!build_target || get_dist(holder.owner, build_target) > 1)
		return 1
	var/mob/living/critter/flock/drone/F = holder.owner
	if(!F)
		return 1
	if(F && !F.can_afford(20))
		return 1
	if(F && F.flock && !F.flock.isTurfFree(build_target, F.real_name)) // oh no, someone else claimed this tile before we got to it
		return 1

/datum/aiTask/succeedable/build/succeeded()
	return isfeathertile(holder.target)

/datum/aiTask/succeedable/build/on_tick()
	if(!has_started)
		var/turf/simulated/floor/build_target = holder.target
		if(build_target && get_dist(holder.owner, build_target) <= 1)
			var/mob/living/critter/flock/drone/F = holder.owner
			if(F && F.set_hand(2)) // nanite spray
				sleep(0.2 SECONDS)
				holder.owner.dir = get_dir(holder.owner, holder.target)
				F.hand_attack(build_target)
				has_started = 1

/datum/aiTask/succeedable/build/on_reset()
	has_started = 0
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.flock)
		F.flock.reserveTurf(holder.target, F.real_name)

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// REPAIR GOAL
// targets: other flockdrones in the same flock
// precondition: 10 resources
/datum/aiTask/sequence/goalbased/repair
	name = "repairing"
	weight = 4

/datum/aiTask/sequence/goalbased/repair/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/repair, list(holder)))

/datum/aiTask/sequence/goalbased/repair/precondition()
	. = 0
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.can_afford(10))
		. = 1

/datum/aiTask/sequence/goalbased/repair/on_reset()
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F)
		F.active_hand = 2 // nanite spray
		sleep(0.1 SECONDS)
		F.a_intent = INTENT_HELP
		F.hud?.update_intent()
		sleep(0.1 SECONDS)
		F.hud?.update_hands() // for observers

/datum/aiTask/sequence/goalbased/repair/get_targets()
	var/list/targets = list()
	for(var/mob/living/critter/flock/drone/F in view(max_dist, holder.owner))
		if(F == holder.owner)
			continue
		if(F.get_health_percentage() < 0.66 && !isdead(F))//yeesh dont try to repair something which is dead
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), get_turf(F), 1, null, /proc/heuristic, 40))
				targets += F
	return targets

////////

/datum/aiTask/succeedable/repair
	name = "repair subtask"
	var/has_started = 0

/datum/aiTask/succeedable/repair/failed()
	var/mob/living/critter/flock/drone/F = holder.owner
	var/mob/living/critter/flock/drone/T = holder.target
	if(!F || !T || get_dist(T, F) > 1)
		return 1
	if(F && (!F.can_afford() || !F.abilityHolder))
		return 1

/datum/aiTask/succeedable/repair/succeeded()
	return (!actions.hasAction(holder.owner, "flock_repair")) // for whatever reason, the required action has stopped

/datum/aiTask/succeedable/repair/on_tick()
	if(!has_started)
		var/mob/living/critter/flock/drone/F = holder.owner
		var/mob/living/critter/flock/drone/T = holder.target
		if(F && T && get_dist(holder.owner, holder.target) <= 1)
			if(F.set_hand(2)) // nanite spray
				sleep(0.2 SECONDS)
				holder.owner.dir = get_dir(holder.owner, holder.target)
				F.hand_attack(T)
				has_started = 1

/datum/aiTask/succeedable/repair/on_reset()
	has_started = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// OPEN CONTAINER GOAL
// targets: any large storage object
// precondition: none
// the idea is the drones will open unlocked, unwelded crates and lockers to reveal the delicious things inside
// the way this shakes out, drones will prioritise making more things available if there's targets in range than taking things
/datum/aiTask/sequence/goalbased/open_container
	name = "opening container"
	weight = 3
	max_dist = 4

/datum/aiTask/sequence/goalbased/open_container/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/open_container, list(holder)))

/datum/aiTask/sequence/goalbased/open_container/precondition()
	return 1 // no precondition required that isn't already checked for targets

/datum/aiTask/sequence/goalbased/open_container/get_targets()
	var/list/targets = list()
	for(var/obj/storage/S in view(max_dist, holder.owner))
		if(!S.open && !S.welded && !S.locked)
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), get_turf(S), 1, null, /proc/heuristic, 10))
				targets += S
	return targets

////////

/datum/aiTask/succeedable/open_container
	name = "open container subtask"
	max_fails = 5

/datum/aiTask/succeedable/open_container/failed()
	var/obj/storage/container_target = holder.target
	if(!container_target || get_dist(holder.owner, container_target) > 1 || fails >= max_fails)
		return 1

/datum/aiTask/succeedable/open_container/succeeded()
	var/obj/storage/container_target = holder.target
	if(container_target) // fix runtime Cannot read null.open
		return container_target.open
	else
		return 0

/datum/aiTask/succeedable/open_container/on_tick()
	var/obj/storage/container_target = holder.target
	if(container_target && get_dist(holder.owner, container_target) <= 1 && !succeeded())
		var/mob/living/critter/flock/drone/F = holder.owner
		if(F && F.set_hand(1)) // grip tool
			sleep(0.2 SECONDS)
			F.dir = get_dir(F, container_target)
			F.hand_attack(container_target) // wooo
	// tick up a fail counter so we don't try to open something we can't forever
	fails++

/datum/aiTask/succeedable/open_container/on_reset()
	fails = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// RUMMAGE GOAL
// targets: any small storage object
// precondition: none
// rummage through the storage object and throw every item in it we can get all over the place
/datum/aiTask/sequence/goalbased/rummage
	name = "rummaging"
	weight = 3
	max_dist = 4

/datum/aiTask/sequence/goalbased/rummage/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/rummage, list(holder)))

/datum/aiTask/sequence/goalbased/rummage/precondition()
	return 1 // no precondition required that isn't already checked for targets

/datum/aiTask/sequence/goalbased/rummage/get_targets()
	var/list/targets = list()
	for(var/obj/item/storage/I in view(max_dist, holder.owner))
		if(I.contents.len > 0 && I.loc != holder.owner && I.does_not_open_in_pocket)
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), get_turf(I), 1, null, /proc/heuristic, 10))
				targets += I
	return targets

////////

/datum/aiTask/succeedable/rummage
	name = "rummage subtask"
	max_fails = 5
	var/list/dummy_params = list("screen-loc" = "7:16,8:16") // click on the first item in storage menu on turf

/datum/aiTask/succeedable/rummage/failed()
	var/obj/item/storage/container_target = holder.target
	if(!container_target || get_dist(holder.owner, container_target) > 1 || fails >= max_fails)
		return 1

/datum/aiTask/succeedable/rummage/succeeded()
	var/obj/item/storage/container_target = holder.target
	if(container_target) // fix runtime Cannot read null.contents
		return container_target.contents.len <= 0
	else
		return 0

/datum/aiTask/succeedable/rummage/on_tick()
	var/obj/item/storage/container_target = holder.target
	if(container_target && get_dist(holder.owner, container_target) <= 1 && !succeeded())
		var/mob/living/critter/flock/drone/F = holder.owner
		usr = F // don't ask, please, don't
		if(F && F.set_hand(1)) // grip tool
			sleep(0.2 SECONDS)
			// drop whatever we're holding
			F.drop_item()
			sleep(0.1 SECONDS)
			F.dir = get_dir(F, container_target)
			F.hand_attack(container_target)
			sleep(0.2 SECONDS)
			if(F.equipped() == container_target)
				// we've picked up a container
				// just eat it
				// dump it onto the floor
				container_target.MouseDrop(get_turf(F))
				sleep(1.5 SECONDS)
				// might as well eat the container now
				F.absorber.equip(container_target)
				return
			else
				// we've opened a HUD
				// do a fake HUD click, because i am dedicated to this whole puppetry schtick
				container_target.hud.clicked("boxes", F, dummy_params)
				sleep(0.3 SECONDS)
				if(isitem(F.equipped()))
					// we got an item from the thing, THROW IT
					// we can't actually fake a throw command because we don't have a client (no, so do a bit more trickery to simulate it
					F.throw_mode_on()
					sleep(0.4 SECONDS)
					var/list/random_pixel_offsets = list("icon-x" = rand(1, 32), "icon-y" = rand(1, 32))
					// pick a random turf in sight to throw this at
					var/list/throw_targets = list()
					for(var/turf/T in oview(3, F))
						throw_targets += T
					if(throw_targets.len <= 0)
						fails++
						return
					var/turf/throw_target = pick(throw_targets)
					F.throw_item(throw_target, random_pixel_offsets)
					sleep(0.1 SECONDS)
					F.throw_mode_off()
					return
				else
					// either the container is empty and we're fruitlessly trying to get something, or we can't work the HUD for some reason
					// (maybe the format got changed?)
					fails++
					return
	// tick up a fail counter so we don't try to open something we can't forever
	fails++

/datum/aiTask/succeedable/rummage/on_reset()
	fails = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// HARVEST GOAL
// targets: any item
// precondition: empty absorber slot
/datum/aiTask/sequence/goalbased/harvest
	name = "harvesting"
	weight = 2
	max_dist = 4

/datum/aiTask/sequence/goalbased/harvest/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/harvest, list(holder)))

/datum/aiTask/sequence/goalbased/harvest/precondition()
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F)
		return !(F.absorber.item)
	else
		return 0 // can't harvest anyway, if not a flockdrone

/datum/aiTask/sequence/goalbased/harvest/get_targets()
	var/list/targets = list()
	for(var/obj/item/I in view(max_dist, holder.owner))
		if(!I.anchored && I.loc != holder.owner)
			if(istype(I, /obj/item/game_kit))
				continue // fuck the game kit
			if(istype(I, /obj/item/paper_bin))
				// special consideration because these things can empty out
				var/obj/item/paper_bin/P = I
				if(P.amount <= 0)
					continue // do not try to fetch paper out of an empty paper bin forever
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), get_turf(I), 1, null, /proc/heuristic, 40))
				targets += I
	return targets

////////

/datum/aiTask/succeedable/harvest
	name = "harvest subtask"
	max_fails = 5

/datum/aiTask/succeedable/harvest/failed()
	var/obj/item/harvest_target = holder.target
	if(!harvest_target || get_dist(holder.owner, harvest_target) > 1 || fails >= max_fails)
		return 1

/datum/aiTask/succeedable/harvest/succeeded()
	return holder.owner.find_in_equipment(holder.target)

/datum/aiTask/succeedable/harvest/on_tick()
	var/obj/item/harvest_target = holder.target
	if(harvest_target && get_dist(holder.owner, harvest_target) <= 1 && !succeeded())
		var/mob/living/critter/flock/drone/F = holder.owner
		if(F && F.set_hand(1)) // grip tool
			sleep(0.2 SECONDS)
			var/obj/item/already_held = F.get_active_hand().item
			if(already_held)
				// we're already holding a thing to eat
				harvest_target = already_held
			else
				F.empty_hand(1) // drop whatever we might be holding just in case
				sleep(0.1 SECONDS)
				// grab the item
				F.dir = get_dir(F, harvest_target)
				F.hand_attack(harvest_target)
			// if we have the item, equip it into our horrifying death chamber
			if(F.is_in_hands(harvest_target))
				sleep(0.2 SECONDS)
				F.absorber.equip(harvest_target) // hooray!
	// tick up a fail counter so we don't try to get something we can't forever
	fails++

/datum/aiTask/succeedable/harvest/on_reset()
	fails = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// FLOCKDRONE-SPECIFIC SHOOT TASK
// ho boy
// so within this timed task, look through valid targets in holder.owner.flock
// pick a target within range and shoot at them if they're not already stunned
/datum/aiTask/timed/targeted/flockdrone_shoot
	name = "shooting"
	minimum_task_ticks = 10
	maximum_task_ticks = 25
	var/weight = 10
	target_range = 12
	var/shoot_range = 6
	var/run_range = 3
	var/list/dummy_params = list("icon-x" = 16, "icon-y" = 16)


/datum/aiTask/timed/targeted/flockdrone_shoot/evaluate()
	return weight * score_target(get_best_target(get_targets()))

/datum/aiTask/timed/targeted/flockdrone_shoot/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	walk_to(owncritter, 0)
	if(!holder.target)
		holder.target = get_best_target(get_targets())
	if(holder.target)
		var/mob/living/M = holder.target
		if(M && !istype(M.loc.type, /obj/icecube/flockdrone) && (M.getStatusDuration("stunned") || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") || M.stat))
			// target is down or in a cage, we don't care about this target now
			// fetch a new one if we can
			holder.target = get_best_target(get_targets())
			if(!holder.target)
				return // try again next tick
		var/dist = get_dist(owncritter, holder.target)
		if(dist > target_range)
			holder.target = get_best_target(get_targets())
		else if(dist > shoot_range)
			walk_to(owncritter, holder.target, 1, 4)
		else
			if(owncritter.active_hand != 3) // stunner
				owncritter.set_hand(3)
				sleep(0.2 SECONDS)
			owncritter.dir = get_dir(owncritter, holder.target)
			owncritter.hand_attack(holder.target, dummy_params)
			if(dist < run_range)
				// RUN
				walk_away(owncritter, holder.target, 1, 4)
			else if(prob(30))
				// ROBUST DODGE
				walk(owncritter, 0)
				sleep(0.2 SECONDS)
				walk_rand(owncritter, 1, 4)


/datum/aiTask/timed/targeted/flockdrone_shoot/get_targets()
	var/list/targets = list()
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.flock)
		for(var/mob/living/M in view(target_range, holder.owner))
			if(!istype(M.loc.type, /obj/icecube/flockdrone) && !(M.getStatusDuration("stunned") || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") || M.stat))
				// mob isn't already stunned, check if they're in our target list
				if(F.flock.isEnemy(M))
					targets += M
					// also, while we're here, update the last time this mob was seen
					F.flock.updateEnemy(M)
	return targets

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// FLOCKDRONE-SPECIFIC CAPTURE TASK
// look through valid targets that are in the flock targets AND are stunned
/datum/aiTask/timed/targeted/flockdrone_capture
	name = "capturing"
	minimum_task_ticks = 10
	maximum_task_ticks = 25
	var/weight = 15
	target_range = 12

/datum/aiTask/timed/targeted/flockdrone_capture/proc/precondition()
	. = 0
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.can_afford(15))
		. = 1

/datum/aiTask/timed/targeted/flockdrone_capture/evaluate()
	return precondition() * weight * score_target(get_best_target(get_targets()))

/datum/aiTask/timed/targeted/flockdrone_capture/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	walk_to(owncritter, 0)
	if(!holder.target)
		holder.target = get_best_target(get_targets())
	if(holder.target)
		var/mob/living/M = holder.target
		if(!(M.getStatusDuration("stunned") || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") || M.stat))
			// target is up, abort
			// fetch a new one if we can
			holder.target = get_best_target(get_targets())
			if(!holder.target)
				return // try again next tick
		var/dist = get_dist(owncritter, holder.target)
		if(dist > target_range)
			holder.target = get_best_target(get_targets())
		else if(dist > 1)
			walk_to(owncritter, holder.target, 1, 4)
		else if(!actions.hasAction(owncritter, "flock_entomb")) // let's not keep interrupting our own action
			if(owncritter.active_hand != 2) // nanite spray
				owncritter.set_hand(2)
				sleep(0.2 SECONDS)
				owncritter.a_intent = INTENT_DISARM
				owncritter.hud.update_intent()
				sleep(0.1 SECONDS)
			owncritter.dir = get_dir(owncritter, holder.target)
			owncritter.hand_attack(holder.target)

/datum/aiTask/timed/targeted/flockdrone_capture/get_targets()
	var/list/targets = list()
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F && F.flock)
		for(var/mob/living/M in view(target_range, holder.owner))
			if(F.flock.isEnemy(M) && (M.getStatusDuration("stunned") || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") || M.stat))
				// mob is a valid target, check if they're not already in a cage
				if(!istype(M.loc.type, /obj/icecube/flockdrone))
					// if we can get a valid path to the target, include it for consideration
					if(cirrAstar(get_turf(holder.owner), get_turf(M), 1, null, /proc/heuristic, 40))
						// GO AND IMPRISON THEM
						targets += M
	return targets


////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// BUTCHER GOAL
// targets: other dead flockdrones in the same flock
/datum/aiTask/sequence/goalbased/butcher
	name = "butchering"
	weight = 3

/datum/aiTask/sequence/goalbased/butcher/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/butcher, list(holder)))


/datum/aiTask/sequence/goalbased/butcher/on_reset()
	var/mob/living/critter/flock/drone/F = holder.owner
	if(F)
		F.active_hand = 2 // nanite spray
		sleep(0.1 SECONDS)
		F.a_intent = INTENT_HARM
		F.hud?.update_intent()
		sleep(0.1 SECONDS)
		F.hud?.update_hands() // for observers

/datum/aiTask/sequence/goalbased/butcher/get_targets()
	var/list/targets = list()
	for(var/mob/living/critter/flock/drone/F in view(max_dist, holder.owner))
		if(F == holder.owner)
			continue
		if(isdead(F))
			// if we can get a valid path to the target, include it for consideration
			if(cirrAstar(get_turf(holder.owner), get_turf(F), 1, null, /proc/heuristic, 40))
				targets += F
	return targets

////////

/datum/aiTask/succeedable/butcher
	name = "butcher subtask"
	var/has_started = 0

/datum/aiTask/succeedable/butcher/failed()
	var/mob/living/critter/flock/drone/F = holder.owner
	var/mob/living/critter/flock/drone/T = holder.target
	if(!F || !T || get_dist(T, F) > 1)
		return 1
	if(F && !F.abilityHolder)
		return 1

/datum/aiTask/succeedable/butcher/succeeded()
	return (!actions.hasAction(holder.owner, "butcherlivingcritter")) // for whatever reason, the required action has stopped

/datum/aiTask/succeedable/butcher/on_tick()
	if(!has_started)
		var/mob/living/critter/flock/drone/F = holder.owner
		var/mob/living/critter/flock/drone/T = holder.target
		if(F && T && get_dist(holder.owner, holder.target) <= 1)
			if(F.set_hand(2)) // nanite spray
				sleep(0.2 SECONDS)
				holder.owner.dir = get_dir(holder.owner, holder.target)
				F.hand_attack(T)
				has_started = 1

/datum/aiTask/succeedable/butcher/on_reset()
	has_started = 0
