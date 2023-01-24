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

/datum/limiter/proc/canISpawn(var/typePath, limit=null)
	. = TRUE
	if (limits[typePath] > 0 || !isnull(limit)) // null is also not > 0

		if (world.time > currentTick)
			// Limits are per-tick.
			currentTick = world.time
			spawned.Cut()
			spawned[typePath] = 1
			return

		if(isnull(limit))
			limit = limits[typePath]
		// This makes the probability of spawning a new object decrease linearly
		// as the number of spawned objects approaches the limit
		. = !prob( clamp(spawned[typePath] / limit, 0, 1) * 100 )
		if (.)
			spawned[typePath]++
