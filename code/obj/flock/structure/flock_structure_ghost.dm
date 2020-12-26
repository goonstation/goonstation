//so this is like a fuckinn building ghost, ya know? the ones that like a lot of games have. drones should hopefully waltz over to it and input resources
/obj/flock_structure/ghost
	name = "weird lookin ghost building"
	desc = "It's some weird looking ghost building. Seems like its under construction, You can see faint strands of material floating in it."
// Ma theres a weird fuckin cat outside.
	var/goal = 0 //mats needed to make the thing actually build
	var/building = null //thing thats being built
	var/currentmats = 0 //mats currently in the thing.
	flock_id = "Construction Tealprint"


/obj/flock_structure/ghost/building_specific_info()
	return {"<span class='bold'>Construction Percentage:</span> [!src.goal == 0 ? round((src.currentmats/src.goal)*100) : 0]%
	<br><span class='bold'>Construction Progress:</span> [currentmats] materials added, [goal] needed"}

/obj/flock_structure/ghost/New(var/atom/location, building = null, var/datum/flock/F = null, goal = 0)
	..(location, F)
	if(building)
		var/atom/b = building
		icon = initial(b.icon)
		icon_state = initial(b.icon_state)
		src.color = COLOR_MATRIX_FLOCKMIND
		src.alpha = 104
		src.goal = goal //???? wuh
		src.building = building
	else
		flock_speak(null, "ERROR: No Structure Tealprint Assigned, Deleting", flock)
		qdel(src) //no exist if building null

/obj/flock_structure/ghost/process()
	if(currentmats > goal)
		var/obj/item/flockcache/c = new(get_turf(src))
		flock_speak(null, "ALERT: Material excess detected, ejecting excess", flock)
		c.resources = (currentmats - goal)
		src.completebuild()
	else if(currentmats == goal)
		src.completebuild()
		//not enough resources = do nothin
	updatealpha()

/obj/flock_structure/ghost/proc/updatealpha()
	alpha = lerp(104, 255, currentmats / goal)

/obj/flock_structure/ghost/proc/completebuild()
	if(src.building)
		new building(get_turf(src), src.flock)
	qdel(src)
