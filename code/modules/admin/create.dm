/datum/admins/proc/create_object(mob/user)
	if(user)
		var/datum/object_creator/object_creator = new(src, /obj)
		object_creator.ui_interact(user)

/datum/admins/proc/create_mob(mob/user)
	if(user)
		var/datum/object_creator/object_creator = new(src, /mob)
		object_creator.ui_interact(user)

/datum/admins/proc/create_turf(mob/user)
	if(user)
		var/datum/object_creator/object_creator = new(src, /turf)
		object_creator.ui_interact(user)
