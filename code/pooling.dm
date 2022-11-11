#define POOL_HIT_COUNT 1
#define POOL_MISS_COUNT 2
#define POOLINGS 3
#define UNPOOLINGS 4
#define EVICTIONS 5

var
	list/object_pools = list()
	list/pool_limit_overrides = list(/sound = 300, \
									/obj/effects/sparks = 1000, \
									/obj/hotspot = 1000, \
									/datum/effects/system/spark_spread = 200,
									/obj/effects/harmless_smoke = 500,
									/obj/effects/foam = 500,
									/obj/effects/steam = 500,
									/obj/effects/bad_smoke = 500,
									/obj/fluid = 10000, // f u c k (mbc note : drsingh says this is fine.)
									/obj/fluid/airborne = 10000,
									/obj/particle = 300,// FUCKING SPARKLES
									/obj/item/spacecash = 300,
									/obj/item/paper = 300,
									/obj/decal/cleanable = 800,
									/obj/overlay/tile_effect/lighting = 1000) //fine ok its smaller now! //edit : ok actually maybe this matters lets make it biger
/datum/proc/pooled_deprecated(var/pooltype)
	SHOULD_CALL_PARENT(TRUE)
	dispose()
	if(istype(src, /atom/movable))
		var/atom/movable/AM = src
		AM.set_loc(null)
		AM.transform = null
		animate(AM)
	// If this thing went through the delete queue and was rescued by the pool mechanism, we should reset the qdeled flag.
	qdeled = 0
	// pooled = 1

/datum/proc/unpooled_deprecated(var/pooltype)
	SHOULD_CALL_PARENT(TRUE)
	disposed = 0
	// pooled = 0

#ifdef DETAILED_POOL_STATS
var/global/list/pool_stats = list()

proc/increment_pool_stats(var/type, var/index)
	if(!type || index < 1 || index > 5)
		return
	var/list/L = pool_stats[type]
	if(!L)
		L = list(0,0,0,0,0)

		pool_stats[type] = L

	L[index]++


#endif

proc/get_pool_size_limit(var/type)
	return pool_limit_overrides[type] || DEFAULT_POOL_SIZE

proc/unpool_deprecated(var/type=null)
	if(!type)
		return null //Uh, here's your unpooled null. You weirdo.

	#ifdef DETAILED_POOL_STATS
	increment_pool_stats(type, UNPOOLINGS)
	#endif

	var/list/l = object_pools[type]
	if(!l) //Didn't have a pool
		l = createPool(type)

	if(!l.len) //Didn't have anything in the pool
		#ifdef DETAILED_POOL_STATS
		increment_pool_stats(type, POOL_MISS_COUNT)
		#endif
		return new type

	var/datum/thing = l[l.len]
	if (!thing)// || !thing.pooled) //This should not happen, but I guess it did.
		l.len-- // = 0
		#ifdef DETAILED_POOL_STATS
		increment_pool_stats(type, POOL_MISS_COUNT)
		#endif
		return new type

	else //Take the thing out of the pool and return it
		l.len-- //Remove(thing)
		#ifdef DETAILED_POOL_STATS
		increment_pool_stats(type, POOL_HIT_COUNT)
		#endif
		thing.unpooled_deprecated(type)
	return thing

proc/createPool(var/type)
	if(!object_pools[type])
		object_pools[type] = list()
	return object_pools[type]

proc/pool_deprecated(var/datum/to_pool)
	if (to_pool)

		var/list/type_pool = object_pools[to_pool.type]
		if(!type_pool)
			type_pool = createPool(to_pool.type)


		if(type_pool.len < get_pool_size_limit(to_pool.type))
			#ifdef DETAILED_POOL_STATS
			increment_pool_stats(to_pool.type, POOLINGS)
			#endif
			type_pool += to_pool
			to_pool.pooled_deprecated(to_pool.type)
		else
			#ifdef DETAILED_POOL_STATS
			increment_pool_stats(to_pool.type, EVICTIONS)
			#endif
			qdel(to_pool)


#ifdef DETAILED_POOL_STATS

proc/getPoolingJson()
	var/json = "\[{path:null,count:0,hits:0,misses:0,poolings:0,unpoolings:0,evictions:0}"
	for(var/type in pool_stats)
		var/count = 0
		var/list/L = object_pools[type]
		if(L) count = length(L)
		L = pool_stats[type]

		json += ",{path:'[type]',count:[count],hits:[L[POOL_HIT_COUNT]],misses:[L[POOL_MISS_COUNT]],poolings:[L[POOLINGS]],unpoolings:[L[UNPOOLINGS]],evictions:[L[EVICTIONS]]}"
	json += "]"

	//usr.Browse(json, "window=teststuff")
	return json

#endif

#undef POOL_HIT_COUNT
#undef POOL_MISS_COUNT
#undef POOLINGS
#undef UNPOOLINGS
#undef EVICTIONS
