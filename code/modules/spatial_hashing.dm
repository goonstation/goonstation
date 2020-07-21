

#define GET_NEARBY(A,range) spatial_z_maps[A.z].get_nearby(A,range)

#define CELL_POSITION(X,Y) ((round(X / cellsize)) + (round(Y / cellsize)) * cellwidth)

#define ADD_BUCKET(X,Y) do{\
var/cellposition = CELL_POSITION(X,Y);\
if (!(cellposition in buckets_holding_atom)){\
	buckets_holding_atom += cellposition;\
}\
} while (false)




var/global/list/datum/spatial_hashmap/spatial_z_maps

/proc/init_spatial_map()
	spatial_z_maps = list(world.maxz)
	for (var/zlevel = 1; zlevel <= world.maxz; zlevel++)
		spatial_z_maps[zlevel] = new/datum/spatial_hashmap(world.maxx,world.maxy,100)

//so this is designed for sounds - but maybe could be adapted for more collision / range checking stuff in the future

/datum/spatial_hashmap
	var/list/hashmap
	var/cols
	var/rows
	var/width
	var/height
	var/cellsize
	var/cellwidth

	var/last_update = 0

	New(w,h,cs)
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
	/*
	proc/clear()
		for (var/i = 1; i < cols*rows; i++)
			hashmap[i].len = 0

	proc/register(var/atom/A) //see comments re : single cell
		for(var/id in get_atom_id(A))
			hashmap[id] += A;
	*/

	proc/update()
		last_update = world.time
		for (var/i = 1; i < cols*rows; i++) //clean
			hashmap[i].len = 0
		for (var/client/C) //register
			if (C.mob)
				hashmap[CELL_POSITION(C.mob.x,C.mob.y)] += C.mob //register(C.mob) //to optimize update we are gonna only pop a mob in a single cell instead of 4 cells. dangerous?? idk try it
				C.mob.maptext = "[CELL_POSITION(C.mob.x,C.mob.y)]" //lazy debug to see what cell we are being placed in

	var/tmp/min_x = 0
	var/tmp/min_y = 0
	var/tmp/max_x = 0
	var/tmp/max_y = 0
	proc/get_atom_id(var/atom/A,var/atomboundsize = 33)
		var/list/buckets_holding_atom = list()

		min_x = A.x - atomboundsize
		min_y = A.y - atomboundsize
		max_x = A.x + atomboundsize
		max_y = A.y + atomboundsize

		ADD_BUCKET(min_x,min_y)
		ADD_BUCKET(max_x,min_y)
		ADD_BUCKET(min_x,max_y)
		ADD_BUCKET(max_x,max_y)


		//lazy debug to see what cells we are searching in
		var/s = "U : "
		for (var/i in buckets_holding_atom)
			s += "[i] "
		boutput(world,s)


		return buckets_holding_atom

	proc/get_nearby(var/atom/A, var/range = 33)
		if (world.time > last_update + (world.tick_lag*5)) //sneaky... rest period where we lazily refuse to update
			update()

		range = min(range,cellsize/2)

		.= list()
		for (var/id in get_atom_id(A,range))
			.+= hashmap[id];
