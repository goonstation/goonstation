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
	var/custominfo = "<span class='bold'>Construction Percentage:</span> [!src.goal == 0 ? round((src.currentmats/src.goal)*100) : 0]%"
	custominfo += "<br><span class='bold'>Construction Progress:</span> [currentmats] materials added, [goal] needed"
	return custominfo

/obj/flock_structure/ghost/New(var/atom/location, building = null, var/datum/flock/F = null, goal = null)
	..(location, F)
	if(building)
		var/atom/b = building
		icon = initial(b.icon)
		icon_state = initial(b.icon_state)
		src.goal = goal //???? wuh
		src.building = building
	else
		boutput(src, "ERROR: No Structure Tealprint Assigned, Deleting")
		qdel(src) //no existo if building null

/obj/flock_structure/ghost/process()
	if(currentmats > goal) //incase some fucko like somehow adds more then needed???
		var/obj/item/flockcache/c = new(src)
		boutput(src, "ALERT: Material excess detected, ejecting excess")
		c.resources = (currentmats - goal)
		src.completebuild()
	else if(currentmats == goal)
		src.completebuild()

		//not enough resources = do nothin

/obj/flock_structure/ghost/proc/completebuild()
	if(src.building)
//		building = text2path(building)
		new building(get_turf(src), src.flock)
		qdel(src)
	else
		return

