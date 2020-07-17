//a bit of a word of warning this is janky ass code but aighto!
/datum/flock_tile_group
	var/list/members = list() //what tiles are a part of the group
	var/size = 0 //how many tiles in there
	var/power = 0 //how much power is in the grid
	var/poweruse = 0 //how much is being used
	var/powergen = 0 //how much is being produced
	var/datum/flock/flock = null
	var/id = 0 //debuggin id

/datum/flock_tile_group/New(var/f = null)
	if(f)
		flock = f
//	processing_items |= src
	id = rand(1, 1000)

/datum/flock_tile_group/disposing()
	members.len = 0 //delete the list
	flock = null
//	processing_items -= src



/datum/flock_tile_group/proc/addtile(var/turf/simulated/floor/feather/f)
	members |= f
	size = members.len






