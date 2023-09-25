//this is designed for sounds - but maybe could be adapted for more collision / range checking stuff in the future

/// Get cliented mobs from a given atom within a given range. Careful, because range is actually `max(CELL_SIZE, range)`
#define GET_NEARBY(A,range) ((A.z <= 0 || A.z > length(spatial_z_maps)) ? null : spatial_z_maps[A.z].get_nearby(A,range))

#define CELL_POSITION(X,Y) (clamp(((round(X / cellsize)) + (round(Y / cellsize)) * cellwidth) + 1, 1, length(hashmap)))

#define ADD_BUCKET(X,Y) (. |= CELL_POSITION(X, Y))

/// The global spatial Z map list, used for our spatial hashing
var/global/list/datum/spatial_hashmap/spatial_z_maps = init_spatial_maps()

/proc/init_spatial_maps()
	. = new /list(world.maxz)
	for (var/zlevel in 1 to world.maxz)
		.[zlevel] = new/datum/spatial_hashmap(zlevel)

/proc/init_spatial_map(zlevel)
	if(length(spatial_z_maps) < world.maxz)
		spatial_z_maps.len = world.maxz
	spatial_z_maps[zlevel] = new/datum/spatial_hashmap(zlevel)

/datum/spatial_hashmap
	var/cellsize = 30 // 300x300 -> 10x10
	var/update_cooldown = 5 //! in actual server ticks (not deciseconds)

	var/list/list/hashmap
	var/cols
	var/rows
	var/width
	var/height
	var/cellwidth

	var/last_update = 0

	var/my_z = 0

	var/tmp/list/buckets_holding_atom

	New(z, w = null, h = null, cs = null)
		..()

		if(isnull(w))
			w = world.maxx

		if(isnull(h))
			h = world.maxy

		if(!isnull(cs))
			cellsize = cs

		cols = ceil(w / cellsize) // for very small maps - we want always at least one cell
		rows = ceil(h / cellsize)

		hashmap = new /list(cols * rows)

		for (var/i in 1 to cols * rows)
			hashmap[i] = list()

		width = w
		height = h

		cellwidth = width / cellsize

		my_z = z

	/* unused, could be useful later idk
	proc/clear()
		for (var/i = 1; i <= cols*rows; i++)
			hashmap[i].len = 0

	proc/register(var/atom/A) //see comments re : single cell
		for(var/id in get_atom_id(A))
			hashmap[id] += A;
	*/

	proc/update()
		last_update = world.time
		for (var/i in 1 to cols*rows) //clean
			hashmap[i].len = 0
		for (var/client/C in clients) //register
			var/turf/T = get_turf(C.mob)
			if (T?.z == my_z)
				hashmap[CELL_POSITION(T.x, T.y)] += C
			//a formal spatial map implementation would place an atom into any bucket its bounds occupy (register proc instead of the above line). We don't need that here
			//register(C.mob)

	proc/get_atom_id(atom/A, atomboundsize = 30)
		//usually in this kinda collision detection code you'd want to map the corners of a square....
		//but this is for our sounds system, where the shapes of collision actually resemble a diamond
		//so : sample 8 points around the edges of the diamond shape created by our atom

		. = list()

		ADD_BUCKET(A.x, A.y)

		var/min_x = 0
		var/min_y = 0
		var/max_x = 0
		var/max_y = 0

		//N,W,E,S
		min_x = A.x - atomboundsize
		min_y = A.y - atomboundsize
		max_x = A.x + atomboundsize
		max_y = A.y + atomboundsize
		ADD_BUCKET(min_x,A.y)
		ADD_BUCKET(max_x,A.y)
		ADD_BUCKET(A.x,min_y)
		ADD_BUCKET(A.x,max_y)

		//NW,NE,SW,SE
		min_x = A.x - (atomboundsize * (sqrt(2)/2))
		min_y = A.y - (atomboundsize * (sqrt(2)/2))
		max_x = A.x + (atomboundsize * (sqrt(2)/2))
		max_y = A.y + (atomboundsize * (sqrt(2)/2))
		ADD_BUCKET(min_x,min_y)
		ADD_BUCKET(min_x,max_y)
		ADD_BUCKET(max_x,min_y)
		ADD_BUCKET(max_x,max_y)

	proc/get_nearby(atom/A, range = 30)
		RETURN_TYPE(/list)

		if(A.z != src.my_z)
			CRASH("get_nearby called on a spatial hashmap for a different z level")

		//sneaky... rest period where we lazily refuse to update
		if (world.time > last_update + (world.tick_lag * update_cooldown))
			update()

		// if the range is higher than cell size, we can miss cells!
		range = min(range,cellsize)

		. = list()
		for (var/id in get_atom_id(A, range))
			. += hashmap[id]


#undef CELL_POSITION
#undef ADD_BUCKET
