//this is designed for sounds - but maybe could be adapted for more collision / range checking stuff in the future


#define GET_NEARBY(A,range) spatial_z_maps[A.z].get_nearby(A,range)

#define CELL_POSITION(X,Y) clamp(((round(X / cellsize)) + (round(Y / cellsize)) * cellwidth) + 1,1,hashmap.len)

#define ADD_BUCKET(X,Y) do{\
var/cellposition = CELL_POSITION(X,Y);\
buckets_holding_atom[cellposition] = 1;\
} while (false)

var/global/list/datum/spatial_hashmap/spatial_z_maps = init_spatial_maps()

/proc/init_spatial_maps()
	. = new /list(world.maxz)
	for (var/zlevel = 1; zlevel <= world.maxz; zlevel++)
		.[zlevel] = new/datum/spatial_hashmap(world.maxx,world.maxy,60,zlevel)

/proc/init_spatial_map(zlevel)
	spatial_z_maps[zlevel] = new/datum/spatial_hashmap(world.maxx,world.maxy,60,zlevel)

/datum/spatial_hashmap
	var/list/list/hashmap
	var/cols
	var/rows
	var/width
	var/height
	var/cellsize
	var/cellwidth

	var/last_update = 0

	var/my_z = 0

	var/tmp/list/buckets_holding_atom
	var/tmp/min_x = 0
	var/tmp/min_y = 0
	var/tmp/max_x = 0
	var/tmp/max_y = 0

	var/tmp/turf/T = null



	New(w,h,cs,z)
		..()
		cols = w / cs
		rows = h / cs

		hashmap = list()
		hashmap.len = cols * rows

		for (var/i = 1; i <= cols*rows; i++)
			hashmap[i] = list()

		width = w
		height = h
		cellsize = cs

		cellwidth = width/cellsize

		buckets_holding_atom = list()
		buckets_holding_atom.len = hashmap.len

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
		for (var/i = 1; i <= cols*rows; i++) //clean
			hashmap[i].len = 0
		for (var/client/C) //register
			if (C.mob)
				T = get_turf(C.mob)
				if (T && T.z == my_z)
					hashmap[CELL_POSITION(T.x,T.y)] += C.mob
				//a formal spatial map implementation would place an atom into any bucket its bounds occupy (register proc instead of the above line). We don't need that here
				//register(C.mob)
				//C.mob.maptext = "[CELL_POSITION(C.mob.x,C.mob.y)]" //lazy debug to see what cell we are being placed in



	proc/get_atom_id(var/atom/A,var/atomboundsize = 33)
		//usually in this kinda collision detection code you'd want to map the corners of a square....
		//but this is for our sounds system, where the shapes of collision actually resemble a diamond
		//so : sample 8 points around the edges of the diamond shape created by our atom

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

		//why do the list stuff this way? i dont want to do `find element` checks on the buckets list, but it must not hold duplicate values.
		//track collided cell IDs by flipping an index of the list from 0 to 1 in ADD_BUCKET.
		.= list()
		for (var/i in 1 to buckets_holding_atom.len)
			if (buckets_holding_atom[i])
				.+= i
			buckets_holding_atom[i] = null


		//lazy debug to see what cells we are searching in
		/*
		var/s = "U : "
		for (var/i in .)
			s += "[i] "
		boutput(world,s)
		*/

	proc/get_nearby(var/atom/A, var/range = 33)
		//sneaky... rest period where we lazily refuse to update
		if (world.time > last_update + (world.tick_lag*5))
			update()

		// if the range is higher than cell size, we can miss cells!
		range = min(range,cellsize)

		.= list()
		for (var/id in get_atom_id(A,range))
			.+= hashmap[id];


#undef CELL_POSITION
#undef ADD_BUCKET
