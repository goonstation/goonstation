var/global/datum/limiter/limiter

/proc/initLimiter()
	limiter = new
	limiter.addLimit(/obj/effects/sparks, 500)
	limiter.addLimit(/obj/item/rods, 300)
	limiter.addLimit(/obj/item/raw_material/shard, 300)
	limiter.addLimit(/sound, 300)

/datum/limiter
	var/currentTick
	var/list/limits
	var/list/spawned

/datum/limiter/New()
	..()
	limits = list()
	spawned = list()
	currentTick = world.time

/datum/limiter/proc/addLimit(var/typePath, var/limit)
	limits[typePath] = limit

/datum/limiter/proc/canISpawn(var/typePath)
	if (!(typePath in limits))
		return 1

	checkTick()

	if (limits[typePath] > 0)
		if (!(typePath in spawned))
			spawned[typePath] = 1
			return 1

		// This makes the probability of spawning a new object decrease linearly
		// as the number of spawned objects approaches the limit
		var/probability = max(0, min(1, spawned[typePath] / limits[typePath]))
		. = 1 - prob(probability * 100)
		if (.)
			spawned[typePath]++
		return

	return 0

/datum/limiter/proc/checkTick()
	if (world.time > currentTick)
		// Limits are per-tick.
		currentTick = world.time
		spawned.len = 0
