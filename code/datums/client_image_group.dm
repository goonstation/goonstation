var/global/list/datum/client_image_group/client_image_groups

/datum/client_image_group
	var/list/image/images
	var/list/subscribed_mobs

	New()
		. = ..()
		images = list()
		subscribed_mobs = list()

	proc/add_image(image/img) // adds to the list and adds to all mobs clients directly
		src.images.Add(img)
		for(var/mob/iterated_mob as() in subscribed_mobs)
			iterated_mob.client?.images.Add(img)

	proc/remove_image(image/img) // same just reverse
		src.images.Remove(img)
		for(var/mob/iterated_mob as() in subscribed_mobs)
			iterated_mob.client?.images.Remove(img)

	proc/add_mob(mob/added_mob) // adds to the list and adds all images to its client, and registers signals
		subscribed_mobs[added_mob] += 1
		if(subscribed_mobs[added_mob] == 1)
			for (var/image/I in images)
				added_mob.client?.images.Add(I)

			RegisterSignal(added_mob, COMSIG_MOB_LOGIN, .proc/add_images_to_client_of_mob)
			RegisterSignal(added_mob, COMSIG_MOB_LOGOUT, .proc/remove_images_from_client_of_mob)
			RegisterSignal(added_mob, COMSIG_PARENT_PRE_DISPOSING, .proc/remove_mob_forced)

	proc/remove_mob(mob/removed_mob) // same just reverse, and unregisters signals
		subscribed_mobs[removed_mob] -= 1
		if(subscribed_mobs[removed_mob] <= 0)
			subscribed_mobs.Remove(removed_mob)
			removed_mob.client?.images.Remove(images)
			UnregisterSignal(removed_mob, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_PARENT_PRE_DISPOSING))

	// private procs for signal purposes:

	proc/add_images_to_client_of_mob(mob/target_mob) // registered on MOB_LOGIN
		PRIVATE_PROC(TRUE)
		target_mob.client?.images.Add(images)

	proc/remove_images_from_client_of_mob(mob/target_mob) // registered on MOB_LOGOUT
		PRIVATE_PROC(TRUE)
		target_mob.last_client?.images.Remove(images)

	proc/remove_mob_forced(mob/removed_mob) // registered on PARENT_PRE_DISPOSING
		PRIVATE_PROC(TRUE)
		subscribed_mobs.Remove(removed_mob)
		UnregisterSignal(removed_mob, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_PARENT_PRE_DISPOSING))

proc/get_image_group(key)
	RETURN_TYPE(/datum/client_image_group)
	if(isnull(global.client_image_groups))
		global.client_image_groups = list()
	if(!(key in client_image_groups))
		client_image_groups[key] = new /datum/client_image_group()
	return client_image_groups[key]
