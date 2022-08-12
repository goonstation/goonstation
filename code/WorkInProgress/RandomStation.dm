#define RANDOM_Z_LEVEL_TARGET 7 //Z level that should recieve randomized station
#define RANDOM_Z_LEVEL_SOURCE 6 //Z level that contains source rooms with room_props objects.
#define RANDOM_Z_LEVEL_MAXROOMS 35 //How many rooms max should we use.

//Make sure that no duplicates can exist in unconnected list.
//Write something that runs at the end and plugs up holes to space. either with walls or airlocks
//Add something to room props that tells us if only one instance of that room is allowed.

/proc/jumptoseed()
	usr.x = 112
	usr.y = 112
	usr.z = 7

/area/random_source //Used to clean up after we're done.
	name = "Random station source tiles"
	icon_state = "yellow"

/area/random_station
	name = "Mysterious Station"
	icon_state = "yellow"
	requires_power = 0
	luminosity = 1
	force_fullbright = 1

var/list/rnd_rooms = new/list()
var/list/rnd_cons = new/list()

/datum/source_room
	var/list/tiles = new/list()
	var/area

/obj/room_monsterspawn //Used to mark spawns for monsters.
	name = "room monster spawn"
	anchored = 1
	invisibility = INVIS_ALWAYS_ISH
	var/probability = 100 //probability that we actually spawn something here.
	icon = 'icons/misc/mark.dmi'
	icon_state = "rdn"

/obj/room_rewardspawn //Used to mark spawns for rewards.
	name = "room reward spawn"
	anchored = 1
	invisibility = INVIS_ALWAYS_ISH
	var/probability = 100 //probability that we actually spawn something here.
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"

/obj/room_props //These need to be placed in the center of the room
	name = "room props"
	anchored = 1
	invisibility = INVIS_ALWAYS_ISH
	var/room_range = 1 //Range of the room (see range proc for how the numbers work)
	var/room_unique = 0 //Is this an unique room that should only be placed once? 0=no, 1=yes
	var/list/connections = new/list()
	icon = 'icons/misc/mark.dmi'
	icon_state = "props"

/obj/room_connection //These are placed north east south and west from the center at the edge of the room if that tile is not solid
	name = "room connection" //Or otherwise blocked. These are used to connect rooms to each other.
	anchored = 1
	invisibility = INVIS_ALWAYS_ISH
	var/open_dir = -1 //These vars are automatically set. Dont need to mess with them.
	var/obj/room_props/room = null

proc/copy_vars(var/atom/from, var/atom/target)
	if (!target || !from) return
	for(var/V in from.vars)
		if (!issaved(from.vars[V]))
			continue

		//The following are commented out because they are already tmp, so issaved() is false for them.
		//if(V == "x") continue
		//if(V == "y") continue
		//if(V == "z") continue
		//if(V == "loc") continue
		if(V == "locs") continue
		if(V == "contents") continue
		//if(V == "type") continue
		//if(V == "parent_type") continue
		//if(V == "vars") continue
		//if(V == "verbs") continue
		target.vars[V] = from.vars[V]

proc/should_copy_room(var/obj/room_props/source, var/turf/target)
	for(var/turf/T in range(source.room_range, target))
		var/diff_x = T.x - target.x
		var/diff_y = T.y - target.y
		var/turf/source_turf = locate(source.loc.x + diff_x, source.loc.y + diff_y, RANDOM_Z_LEVEL_SOURCE)
		if(istype(source_turf, /turf/space) && !length(source_turf.contents)) continue
		if(!istype(T, /turf/space))
			return 0
		if(T.contents.len)
			return 0
	return 1

proc/copy_room_to(var/obj/room_props/source, var/turf/target)
	for(var/turf/T in range(source.room_range, source.loc))
		if(istype(T, /turf/space) && !length(T.contents)) continue //No need to copy this. This is the default state.
		var/diff_x = T.x - source.x
		var/diff_y = T.y - source.y
		var/turf/target_turf = locate(target.x + diff_x, target.y + diff_y, RANDOM_Z_LEVEL_TARGET)
		if(!target_turf) continue //Outside map.
		new T.type(target_turf)
		copy_vars(T, target_turf)
		new/area/random_station(target_turf)
		for(var/atom/A in T)
			var/atom/newAtom = new A.type(target_turf)
			copy_vars(A, newAtom)
	return

/proc/has_dense_objects(var/turf/T)
	for(var/atom/A in T)
		if(A.density) return 1
	return 0

/proc/cleanuprnd()
	for(var/obj/room_props/p in world)
		del(p)
		LAGCHECK(LAG_LOW)
	for(var/obj/room_connection/c in world)
		del(c)
		LAGCHECK(LAG_LOW)
	var/area/A = locate(/area/random_source)
	for(var/obj/toDel in A)
		del(toDel)
		LAGCHECK(LAG_LOW)

proc/spawnmonsters()
	var/theme = pick("undead", "plantsnanimals", "aliens", "demonsnmutants")
	for(var/obj/room_monsterspawn/S in world)
		LAGCHECK(LAG_LOW)
		if(S.z != RANDOM_Z_LEVEL_TARGET)
			continue
		if(prob(S.probability))
			switch(theme)
				if("undead")
					var/selected = pick(/obj/critter/spirit, /obj/critter/zombie, /obj/critter/zombie/scientist, /obj/critter/zombie/security)
					new selected(S.loc)
					del(S)
				if("plantsnanimals")
					var/selected = pick(/obj/critter/bear, /obj/critter/wasp, /obj/critter/lion, /obj/critter/killertomato, /obj/critter/maneater)
					new selected(S.loc)
					del(S)
				if("aliens")
					var/selected = pick(/obj/critter/martian/soldier, /obj/critter/martian/warrior, /obj/critter/martian/psychic)
					new selected(S.loc)
					del(S)
				if("demonsnmutants")
					var/selected = pick(/obj/critter/bloodling, /obj/critter/blobman, /obj/critter/mimic)
					new selected(S.loc)
					del(S)

proc/spawnrewards()
	for(var/obj/room_rewardspawn/S in world)
		LAGCHECK(LAG_LOW)
		if(S.z != RANDOM_Z_LEVEL_TARGET)
			continue
		if(prob(S.probability))
			var/selected = pick(/obj/storage/crate/loot) //No idea what the rewards should be
			new selected(S.loc)
			del(S)

proc/spawndeco()
	var/theme = pick("bloody", "messy", "dirty", "clean")
	for(var/turf/T in locate(/area/random_station))
		if(T.z != RANDOM_Z_LEVEL_TARGET)
			continue
		switch(theme)
			if("bloody")
				if(T.density)
					if(prob(11) && prob(50))
						var/selected = pick(/obj/decal/cleanable/blood, /obj/decal/cleanable/blood/splatter)
						new selected(T)
				else
					if(prob(11) && prob(55))
						var/selected = pick(/obj/decal/cleanable/blood, /obj/decal/cleanable/blood/splatter, /obj/decal/cleanable/blood/gibs, /obj/decal/cleanable/blood/gibs/core, /obj/decal/cleanable/blood/gibs/body)
						new selected(T)
			if("messy")
				if(T.density)
					if(prob(11) && prob(50))
						var/selected = pick(/obj/decal/cleanable/eggsplat, /obj/decal/cleanable/tomatosplat)
						new selected(T)
				else
					if(prob(11) && prob(55))
						var/selected = pick(/obj/decal/cleanable/generic, /obj/deskclutter, /obj/decal/cleanable/robot_debris, /obj/decal/cleanable/robot_debris/limb, /obj/decal/cleanable/robot_debris/gib, /obj/decal/cleanable/molten_item)
						new selected(T)
			if("dirty")
				if(T.density)
					if(prob(11) && prob(50))
						var/selected = pick(/obj/decal/cleanable/eggsplat, /obj/decal/cleanable/tomatosplat, /obj/decal/cleanable/oil, /obj/decal/cleanable/oil/streak, /obj/decal/cleanable/fungus)
						new selected(T)
				else
					if(prob(11) && prob(55))
						var/selected = pick(/obj/decal/cleanable/dirt, /obj/decal/cleanable/oil, /obj/decal/cleanable/oil/streak, /obj/decal/cleanable/vomit, /obj/decal/cleanable/urine)
						new selected(T)
			if("clean")
				continue

proc/create_random_station()
	var/mid_x = round(world.maxx / 2)
	var/mid_y = round(world.maxy / 2)

	var/turf/origin = locate(mid_x, mid_y, RANDOM_Z_LEVEL_TARGET)

	for(var/obj/room_props/p in world)
		LAGCHECK(LAG_LOW)
		if(p.z != RANDOM_Z_LEVEL_SOURCE) continue
		rnd_rooms.Add(p)
		var/turf/north = locate(p.x, p.y + p.room_range, RANDOM_Z_LEVEL_SOURCE)
		var/turf/south = locate(p.x, p.y - p.room_range, RANDOM_Z_LEVEL_SOURCE)
		var/turf/east = locate(p.x + p.room_range, p.y, RANDOM_Z_LEVEL_SOURCE)
		var/turf/west = locate(p.x - p.room_range, p.y, RANDOM_Z_LEVEL_SOURCE)
		if(north)
			if(!north.density && !istype(north, /turf/space) && !has_dense_objects(north))
				var/obj/room_connection/c = new/obj/room_connection(north)
				c.open_dir = NORTH
				c.room = p
				rnd_cons.Add(c)
				p.connections.Add(c)
		if(south)
			if(!south.density && !istype(south, /turf/space) && !has_dense_objects(south))
				var/obj/room_connection/c = new/obj/room_connection(south)
				c.open_dir = SOUTH
				c.room = p
				rnd_cons.Add(c)
				p.connections.Add(c)
		if(east)
			if(!east.density && !istype(east, /turf/space) && !has_dense_objects(east))
				var/obj/room_connection/c = new/obj/room_connection(east)
				c.open_dir = EAST
				c.room = p
				rnd_cons.Add(c)
				p.connections.Add(c)
		if(west)
			if(!west.density && !istype(west, /turf/space) && !has_dense_objects(west))
				var/obj/room_connection/c = new/obj/room_connection(west)
				c.open_dir = WEST
				c.room = p
				rnd_cons.Add(c)
				p.connections.Add(c)

	var/list/multi_rooms = new/list()
	for(var/obj/room_props/p_seed in rnd_rooms)
		if(p_seed.connections.len >= 2) multi_rooms.Add(p_seed)
		LAGCHECK(LAG_LOW)

	var/obj/room_props/selected = pick(multi_rooms)
	copy_room_to(selected, origin)

	var/list/unconnected = new/list()
	for(var/obj/room_connection/R in range(selected.room_range, origin))
		unconnected.Add(R)
		LAGCHECK(LAG_LOW)

	var/rooms_left = RANDOM_Z_LEVEL_MAXROOMS

	while(rooms_left > 0 && unconnected.len && length(multi_rooms))
		LAGCHECK(LAG_LOW)
		var/obj/room_connection/newcon = pick(unconnected)
		unconnected.Remove(newcon)
		var/list/valid_rooms = new/list()
		for(var/obj/room_props/valid in multi_rooms)
			for(var/obj/room_connection/chk_con in valid.connections)
				if(chk_con.open_dir == turn(newcon.open_dir, 180))
					valid_rooms.Add(valid)
					valid_rooms[valid] = chk_con
		var/obj/room_props/selected_new = pick(valid_rooms)
		var/turf/target_origin = newcon.loc
		for(var/i=0, i <= selected_new.room_range, i++)
			target_origin = get_step(target_origin, newcon.open_dir)
		if(target_origin)
			if(should_copy_room(selected_new, target_origin))
				if(selected_new.room_unique)
					multi_rooms.Remove(selected_new)
				copy_room_to(selected_new, target_origin)
				var/turf/conremturf = get_step(newcon.loc, newcon.open_dir)
				var/obj/room_connection/todel = locate(/obj/room_connection) in conremturf
				qdel(todel)
				for(var/obj/room_connection/R1 in range(selected_new.room_range, target_origin))
					if(!unconnected.Find(R1))
						unconnected.Add(R1)
				rooms_left--
				qdel(newcon)
			else
				unconnected.Add(newcon) //Didnt fit, readd to open connections.

	filling_holes:
		for(var/obj/room_connection/C in unconnected)
			LAGCHECK(LAG_LOW)
			var/turf/con_next = get_step(C.loc, C.open_dir)
			if(istype(con_next, /turf/space))
				if(prob(50))
					for(var/turf/T in range(C, 1))
						if(T.density)
							new T.type(C.loc)
							continue filling_holes
					new/turf/simulated/wall(C.loc)
				else
					new/obj/machinery/door/airlock/external(C.loc)
			else
				if(prob(33))
					new/obj/machinery/door/airlock/glass(C.loc)

	cleanuprnd()
	spawnmonsters()
	spawndeco()
	spawnrewards()
	return
