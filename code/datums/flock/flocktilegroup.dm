//a bit of a word of warning this is janky ass code but aighto!
/datum/flock_tile_group
	var/list/members = list() //what tiles are a part of the group
	var/list/connected = list() //what structures are connected
	var/size = 0 //how many tiles in there
	var/powerbalance = 0 //how much power is in the grid, in the form of a net balance
	var/poweruse = 0 //how much is being used
	var/powergen = 0 //how much is being produced
	var/datum/flock/flock = null
	var/debugid = 0 //debuggin id

/datum/flock_tile_group/New(var/datum/flock/f = null)
	..()
	if(f)
		flock = f
	processing_items |= src
	debugid = rand(1, 1000)

/datum/flock_tile_group/disposing()
	members.len = 0 //delete the list
	connected.len = 0
	flock = null
	processing_items -= src
	..() //linter machine go ANGRY

/datum/flock_tile_group/proc/process()
	calcpower()

/datum/flock_tile_group/proc/addtile(var/turf/simulated/floor/feather/f)
	members |= f
	size = length(members)

/datum/flock_tile_group/proc/removetile(var/turf/simulated/floor/feather/f)
	members -= f
	size = length(members)

/datum/flock_tile_group/proc/addstructure(var/obj/flock_structure/f)
	connected |= f

/datum/flock_tile_group/proc/removestructure(var/obj/flock_structure/f)
	connected -= f

/datum/flock_tile_group/proc/calcpower()
	src.powergen = 0
	src.poweruse = 0
	for(var/obj/flock_structure/f in connected)
		if(f.poweruse < 0)
			src.powergen += abs(f.poweruse)
		else if(f.poweruse > 0)
			src.poweruse += f.poweruse

	src.powerbalance = src.powergen - src.poweruse
