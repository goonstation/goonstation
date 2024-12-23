//this is designed for sounds - but maybe could be adapted for more collision / range checking stuff in the future

/// Get cliented mobs from a given atom within a given range. Careful, because range is actually `max(CELL_SIZE, range)`
#define GET_NEARBY(maptype, A, range) (get_singleton(maptype).get_nearby(A, range))

#define CELL_POSITION(X, Y, Z) (clamp(round((X - 1) / cellsize), 0, cols - 1) + clamp(round((Y - 1) / cellsize), 0, rows - 1) * cols + (Z - 1) * rows * cols + 1)

#define ADD_BUCKET(X, Y, Z) (. |= CELL_POSITION(X, Y, Z))

#define ADD_TO_MAP(TARGET, TARGET_POS) \
	if (TARGET_POS?.z) { \
	LAZYLISTADD(hashmap[CELL_POSITION(TARGET_POS.x, TARGET_POS.y, TARGET_POS.z)], TARGET); \
	buckets_holding_atom |= CELL_POSITION(TARGET_POS.x, TARGET_POS.y, TARGET_POS.z); \
	}

ABSTRACT_TYPE(/datum/spatial_hashmap)
/datum/spatial_hashmap
	var/cellsize = 30 // 300x300 -> 10x10
	var/update_cooldown = 5 //! in actual server ticks (not deciseconds)

	var/list/list/hashmap
	var/cols
	var/rows
	var/zlevels
	var/width
	var/height

	var/last_update = 0

	var/tmp/list/buckets_holding_atom

	New(w = null, h = null, zlevels = null, cs = null)
		..()

		if(isnull(w))
			w = world.maxx

		if(isnull(h))
			h = world.maxy

		if(!isnull(cs))
			cellsize = cs

		cols = ceil(w / cellsize) // for very small maps - we want always at least one cell
		rows = ceil(h / cellsize)

		hashmap = list()
		hashmap.len = cols * rows * world.maxz

		width = w
		height = h

		if(isnull(zlevels))
			src.zlevels = world.maxz
		else
			src.zlevels = zlevels

		buckets_holding_atom = list()

	/* unused, could be useful later idk
	proc/clear()
		for (var/i = 1; i <= cols*rows; i++)
			hashmap[i].len = 0

	proc/register(var/atom/A) //see comments re : single cell
		for(var/id in get_ids(A))
			hashmap[id] += A;
	*/

	proc/update()
		if (world.maxz > src.zlevels)
			src.zlevels = world.maxz
			src.hashmap.len = src.cols * src.rows * src.zlevels
		last_update = world.time
		for (var/i in buckets_holding_atom)
			hashmap[i].len = 0
		buckets_holding_atom.len = 0
		add_targets()

	/**
	 * Implement in children.
	 * Example:
	 * ```
	 * for (var/atom/A in some_list_of_atoms_you_care_about)
	 *	var/turf/T = get_turf(A)
	 *	ADD_TO_MAP(A, T)
	 * ```
	 */
	proc/add_targets()

	proc/get_ids(atom/A, atomboundsize = 30)
		. = get_ids_by_coords(A.x, A.y, A.z, atomboundsize)

	proc/get_nearby_atoms_exact(atom/A, range = 30)
		RETURN_TYPE(/list)
		. = get_nearby_atoms_exact_by_coords(A.x, A.y, A.z, range)

	/// Gets is of atoms that are truly within the given range as long as the range is at most cell size
	/// This will only work if we are actually tracking atoms and not something else!!
	proc/get_nearby_atoms_exact_by_coords(x, y, z, range=30)
		RETURN_TYPE(/list)
		if(!z || z > src.zlevels)
			return list()

		//sneaky... rest period where we lazily refuse to update
		if (world.time > last_update + (world.tick_lag * update_cooldown))
			update()

		// if the range is higher than cell size, we can miss cells!
		var/mod_range = min(range, src.cellsize)

		. = list()
		for (var/id in get_ids_by_coords(x, y, z, mod_range))
			if(length(hashmap[id]))
				for(var/atom/A as anything in hashmap[id])
					if(max(abs(get_step(A, 0)?.x - x), abs(get_step(A, 0)?.y - y)) <= range)
						. += A

	proc/get_nearby(atom/A, range = 30)
		RETURN_TYPE(/list)
		. = get_nearby_by_coords(A.x, A.y, A.z, range)

	/// get_nearby() but for arbitrary x,y positions
	proc/get_nearby_by_coords(x, y, z, range=30)
		RETURN_TYPE(/list)

		if(!z || z > src.zlevels)
			return list()

		//sneaky... rest period where we lazily refuse to update
		if (world.time > last_update + (world.tick_lag * update_cooldown))
			update()

		// if the range is higher than cell size, we can miss cells!
		range = min(range, src.cellsize)

		. = list()
		for (var/id in get_ids_by_coords(x, y, z, range))
			if(length(hashmap[id]))
				. += src.hashmap[id]

	/// gets ids of buckets to check for atoms around a given x,y,z position
	proc/get_ids_by_coords(x, y, z, atomboundsize = 30)
		if(!z)
			return null

		. = list()

		//usually in this kinda collision detection code you'd want to map the corners of a square....
		//but this is for our sounds system, where the shapes of collision actually resemble a diamond
		//so : sample 8 points around the edges of the diamond shape created by our atom

		ADD_BUCKET(x, y, z)

		var/min_x = 0
		var/min_y = 0
		var/max_x = 0
		var/max_y = 0

		//N,W,E,S
		min_x = x - atomboundsize
		min_y = y - atomboundsize
		max_x = x + atomboundsize
		max_y = y + atomboundsize
		ADD_BUCKET(min_x, y, z)
		ADD_BUCKET(max_x, y, z)
		ADD_BUCKET(x, min_y, z)
		ADD_BUCKET(x, max_y, z)

		//NW,NE,SW,SE
		min_x = x - (atomboundsize * (sqrt(2)/2))
		min_y = y - (atomboundsize * (sqrt(2)/2))
		max_x = x + (atomboundsize * (sqrt(2)/2))
		max_y = y + (atomboundsize * (sqrt(2)/2))
		ADD_BUCKET(min_x, min_y, z)
		ADD_BUCKET(min_x, max_y, z)
		ADD_BUCKET(max_x, min_y, z)
		ADD_BUCKET(max_x, max_y, z)

/datum/spatial_hashmap/clients
	cellsize = 30 // 300x300 -> 10x10
	update_cooldown = 5

	add_targets()
		for (var/client/C in clients)
			var/turf/T = get_turf(C.mob)
			ADD_TO_MAP(C, T)
			// a formal spatial map implementation would place an atom into any bucket its bounds occupy (register proc instead of the above line). We don't need that here
			// register(C.mob))

ABSTRACT_TYPE(/datum/spatial_hashmap/by_type)
/datum/spatial_hashmap/by_type
	var/type_to_track

	add_targets()
		for(var/atom/A as anything in by_type[type_to_track])
			var/turf/T = get_turf(A)
			ADD_TO_MAP(A, T)

ABSTRACT_TYPE(/datum/spatial_hashmap/by_type/alive_mob)
/datum/spatial_hashmap/by_type/alive_mob
	add_targets()
		for(var/mob/M as anything in by_type[type_to_track])
			if(!isdead(M))
				var/turf/T = get_turf(M)
				ADD_TO_MAP(M, T)

/datum/spatial_hashmap/by_type/alive_mob/ranch_animals
	cellsize = 10
	update_cooldown = 50
	type_to_track = /mob/living/critter/small_animal/ranch_base

/datum/spatial_hashmap/by_type/shrub // for testing, ok??
	cellsize = 10
	update_cooldown = 5
	type_to_track = /obj/shrub

/datum/spatial_hashmap/manual/near_station

/datum/spatial_hashmap/manual/proc/add_target(atom/A)
	var/turf/T = get_turf(A)
	if (world.maxz > src.zlevels)
		src.zlevels = world.maxz
		src.hashmap.len = src.cols * src.rows * src.zlevels
	if(T && !QDELETED(A))
		ADD_TO_MAP(A, T)

/datum/spatial_hashmap/manual/proc/add_weakref(atom/A)
	var/turf/T = get_turf(A)
	if (world.maxz > src.zlevels)
		src.zlevels = world.maxz
		src.hashmap.len = src.cols * src.rows * src.zlevels
	if(T && !QDELETED(A))
		ADD_TO_MAP(get_weakref(A), T)

/datum/spatial_hashmap/datums/proc/add_target(x, y, z, datum/target)
	LAZYLISTADD(hashmap[CELL_POSITION(x, y, z)], target)
	buckets_holding_atom |= CELL_POSITION(x, y, z)

#undef CELL_POSITION
#undef ADD_BUCKET
#undef ADD_TO_MAP
