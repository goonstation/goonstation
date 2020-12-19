// flockdrone stuff

// -----
// FLOOR
// -----
/turf/simulated/floor/feather
	name = "weird floor"
	desc = "I don't like the looks of that whatever-it-is."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "floor"
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = 0
	mat_changedesc = 0
	broken = 0
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	var/health = 50
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/datum/light/light
	var/brightness = 0.5
	var/on = 0
	var/connected = 0 //used for collector
	var/datum/flock_tile_group/group = null //the group its connected to


/turf/simulated/floor/feather/New()
	..()
	setMaterial(getMaterial("gnesis"))
	light = new /datum/light/point
	light.set_brightness(src.brightness)
	light.set_color(col_r, col_g, col_b)
	light.attach(src)
	src.checknearby() //check for nearby groups
	if(!group)//if no group found
		initializegroup() //make a new one

/turf/simulated/floor/feather/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Conduit
    <br><span class='bold'>System Integrity:</span> [round((src.health/50)*100)]%
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description

/turf/simulated/floor/feather/attackby(obj/item/C as obj, mob/user as mob, params)
	// do not call parent, this is not an ordinary floor
	if(!C || !user)
		return
	if(ispryingtool(C) && src.broken)
		playsound(src, "sound/items/Crowbar.ogg", 80, 1)
		src.break_tile_to_plating()
		return
	if(src.broken)
		boutput(user, "<span class='hint'>It's already broken, you need to pry it out with a crowbar.</span>")
		return
	src.health -= C.force
	if(src.health <= 0)
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks [src] with [C], shattering it!</span>")
		src.name = "weird broken floor"
		src.desc = "It's broken. You could probably use a crowbar to pull the remnants out."
		playsound(src.loc, "sound/impact_sounds/Crystal_Shatter_1.ogg", 25, 1)
		break_tile()
	else
		src.visible_message("<span class='alert'><span class='bold'>[user]</span> smacks [src] with [C]!</span>")
		playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 25, 1)

/turf/simulated/floor/feather/break_tile_to_plating()
	// if the turf's on, turn it off
	off()
	var/turf/simulated/floor/F = src.ReplaceWithFloor()
	F.to_plating()

/turf/simulated/floor/feather/break_tile()
	off()
	icon_state = "floor-broken"
	broken = 1
	splitgroup()
	for(var/obj/flock_structure/f in src)
		if(f.usesgroups)
			f.group.removestructure(f)
			f.group = null


//////////////////////////////////////////////////////////////////////////////////////////////////////
// stuff to make floorrunning possible (god i wish i could think of a better verb than "floorrunning")
/turf/simulated/floor/feather/Entered(var/mob/living/critter/flock/drone/F, atom/oldloc)
	..()
	if(!istype(F) || !oldloc)
		return
	if(F.client && F.client.check_key(KEY_RUN) && !broken && !F.floorrunning)
		F.start_floorrunning()
	if(F.floorrunning && !broken)
		if(!on)
			on()

/turf/simulated/floor/feather/Exited(var/mob/living/critter/flock/drone/F, atom/newloc)
	..()
	if(!istype(F) || !newloc)
		return
	if(on && !connected)
		off()
	if(F.floorrunning)
		if(istype(newloc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/T = newloc
			if(T.broken)
				F.end_floorrunning() // broken tiles won't let you continue floorrunning
		else if(!isfeathertile(newloc))
			F.end_floorrunning() // you left flocktile territory, boyo

/turf/simulated/floor/feather/proc/on()
	if(src.broken)
		return 1
	src.icon_state = "floor-on"
	src.name = "weird glowing floor"
	src.desc = "Looks like disco's not dead after all."
	on = 1
	playsound(src.loc, "sound/machines/ArtifactFea3.ogg", 25, 1)
	src.light.enable()

/turf/simulated/floor/feather/proc/off()
	if(src.broken) // i guess this could potentially happen
		src.icon_state = "floor-broken"
	else
		src.icon_state = "floor"
		src.name = initial(name)
		src.desc = initial(desc)
	src.light.disable()
	on = 0

/turf/simulated/floor/feather/proc/repair()
	src.icon_state = "floor"
	src.broken = 0
	src.health = initial(health)
	src.name = initial(name)
	src.desc = initial(desc)
	if(isnull(src.group))
		checknearby() //check for groups to join
	for(var/obj/flock_structure/f in get_turf(src))
		if(f.usesgroups)
			f.group = src.group
			f.group.addstructure(f)

/turf/simulated/floor/feather/broken
	name = "weird broken floor"
	desc = "Disco's dead, baby."
	icon_state = "floor-broken"
	broken = 1

////////////////////////////////////////////////////////////////////////////////////////
//start of flocktilegroup stuff

/turf/simulated/floor/feather/proc/initializegroup() //make a new group
	group = new/datum/flock_tile_group
	group.addtile(src)

/turf/simulated/floor/feather/proc/checknearby()//handles merging groups
	var/list/groups_found = list() //list of tile groups found
	var/datum/flock_tile_group/largestgroup = null //largest group
	var/max_group_size = 0
	for(var/turf/simulated/floor/feather/F in getneighbours(src))//check for nearby flocktiles
		if(F.group)
			if(F.group.size > max_group_size)
				max_group_size = F.group.size
				largestgroup = F.group
			groups_found |= F.group
	if(length(groups_found) == 1)
		src.group = groups_found[1] //set it to the group found.
		src.group.addtile(src)
	else if(length(groups_found) > 1) //if there is more then one, then join the largest (add merging functionality here later)
		for(var/datum/flock_tile_group/oldgroup in groups_found)
			if(oldgroup == largestgroup) continue
			largestgroup.powergen += oldgroup.powergen
			largestgroup.poweruse += oldgroup.poweruse
			for(var/turf/simulated/floor/feather/F in oldgroup.members)
				F.group = largestgroup
				largestgroup.addtile(F)
			for(var/obj/flock_structure/f in oldgroup.connected)
				f.group = largestgroup
				largestgroup.addstructure(f)
			qdel(oldgroup)
		src.group = largestgroup
		largestgroup.addtile(src)

	else
		return null

/turf/simulated/floor/feather/proc/splitgroup()
	var/count = 0 //count of nearby tiles
	var/datum/flock_tile_group/oldgroup = src.group
	for(var/turf/simulated/floor/feather/F in getneighbours(get_turf(src)))
		count++ //enumerate nearby tiles
//TODO: fail safe for if there are more then 1 group.
	src.group.removetile(src)
	src.group = null

	if(count <= 1) //if theres only one tile nearby or it by itself dont bother splitting
		if(count <=0) qdel(oldgroup)
		return

	for(var/turf/simulated/floor/feather/tile in getneighbours(get_turf(src)))
		if(tile.group == oldgroup)//check if the tile is the same as the old group
			var/list/listotiles = bfs(tile)//compile a list of connected tiles
			var/datum/flock_tile_group/newgroup = new
			for(tile in listotiles)
				tile.group.removetile(tile)//reassign tiles in the list to new group
				tile.group = newgroup
				tile.group.addtile(tile)
				for(var/obj/flock_structure/s in tile)
					s.groupcheck()//reassign any structures aswell
	qdel(oldgroup)

// TODO: make this use typecheckless lists

turf/simulated/floor/feather/proc/bfs(turf/start)//breadth first search, made by richardgere(god bless)
	var/list/queue = list()
	var/list/visited = list()
	var/turf/current = null

	if(!istype(start, /turf/simulated/floor/feather))
		return //dont bother if it SOMEHOW gets called on a non flock turf
	// start node
	queue += start
	visited[start] = TRUE

	while(length(queue))
		// dequeue
		current = queue[1]
		queue -= current

		// enqueue
		for(var/dir in cardinal)
			var/next_turf = get_step(current, dir)
			if(!visited[next_turf] && istype(next_turf, /turf/simulated/floor/feather))
				var/turf/simulated/floor/feather/f = next_turf
				if(f.broken)
					continue //skip broken tiles
				queue += f
				visited[next_turf] = TRUE
	return visited

//end of flocktilegroup stuff
////////////////////////////////////////////////////////////////////////////////////////

/turf/simulated/wall/auto/feather
	name = "weird glowing wall"
	desc = "You can feel it thrumming and pulsing."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "0"
	mat_appearances_to_ignore = list("steel","gnesis")
	connects_to = list(/turf/simulated/wall/auto/feather, /obj/machinery/door/feather)

/turf/simulated/wall/auto/feather/New()
	..()
	setMaterial(getMaterial("gnesis"))

/turf/simulated/wall/auto/feather/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Nanite Block
    <br><span class='bold'>System Integrity:</span> 100%
    <br><span class='bold'>###=-</span></span>"}
    // todo: damageable walls
  else
    return null // give the standard description

/turf/simulated/wall/auto/feather/Entered(var/mob/living/critter/flock/drone/F, atom/oldloc)
	..()
	if(!istype(F) || !oldloc)
		return
	if(F.client && F.client.check_key(KEY_RUN) && !F.floorrunning)
		F.start_floorrunning()

/turf/simulated/wall/auto/feather/Exited(var/mob/living/critter/flock/drone/F, atom/newloc)
	..()
	if(!istype(F) || !newloc)
		return
	if(F.floorrunning)
		if(istype(newloc, /turf/simulated/floor/feather))
			var/turf/simulated/floor/feather/T = newloc
			if(T.broken)
				F.end_floorrunning() // broken tiles won't let you continue floorrunning
		else if(!isfeathertile(newloc))
			F.end_floorrunning() // you left flocktile territory, boyo
