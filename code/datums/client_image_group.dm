var/global/list/datum/client_image_group/client_image_groups

/datum/client_image_group
	var/list/image/images
	/// Associative list containing images for a given mob.
	var/list/mob_to_associated_images_lookup
	/// Associative list containing minds and the images attached to their mobs.
	var/list/minds_with_associated_mob_image
	/// Associative list containing subscribed mobs and the amount of times they subscribed to the image group (to handle multiple sources).
	var/list/subscribed_mobs_with_subcount
	/// Associative list containing subscribed minds with counts.
	var/list/subscribed_minds_with_subcount
	/// Associative list containing subscribed clients with counts.
	var/list/subscribed_clients_with_subcount
	var/key = null
	var/always_visible = FALSE //! If true this image is always visible ignoring loc's invisibiltiy etc

	New(key)
		. = ..()
		src.key = key
		images = list()
		mob_to_associated_images_lookup = list()
		minds_with_associated_mob_image = list()
		subscribed_mobs_with_subcount = list()
		subscribed_minds_with_subcount = list()
		subscribed_clients_with_subcount = list()

	/// Checks whether an image is elligible to be attached to be displayed to a client.
	proc/image_condition(image/image, mob/mob)
		if (image.loc == mob)
			var/datum/mind_mob_overlay/overlay = src.minds_with_associated_mob_image[mob.mind]
			if (overlay && !overlay.see_own_overlay)
				return FALSE
			else
				return TRUE

		return (src.always_visible || !image.loc?.invisibility || istype(mob, /mob/dead/observer))

	/// Adds an image to the image list and adds it to all mobs' clients directly where appropriate. Registers signal to track mob invisibility changes.
	proc/add_image(image/img)
		src.images.Add(img)
		if (mob_to_associated_images_lookup[img.loc]) // mob's images already present in the group, adds the new one to the lookup list for quick access
			mob_to_associated_images_lookup[img.loc] += img
		else // first time a mob's image is added, on top of adding it to the lookup list a signal is registered on the mob to track invisibility changes.
			mob_to_associated_images_lookup[img.loc] = list(img)
			RegisterSignal(img.loc, COMSIG_ATOM_PROP_MOB_INVISIBILITY, PROC_REF(on_mob_invisibility_changed))

		for (var/client/iterated_client as() in subscribed_clients_with_subcount)
			if (image_condition(img, iterated_client.mob))
				iterated_client.images.Add(img)

	/// Removes an image from the image list and from mobs' clients.
	proc/remove_image(image/img)
		src.images.Remove(img)
		mob_to_associated_images_lookup[img.loc] -= img
		if (!length(mob_to_associated_images_lookup[img.loc])) // no images of a mob remain, removing from lookup and unregistering mob's invisibility update signal.
			mob_to_associated_images_lookup.Remove(img.loc)
			UnregisterSignal(img.loc, COMSIG_ATOM_PROP_MOB_INVISIBILITY)
		for (var/client/iterated_client as() in subscribed_clients_with_subcount)
			iterated_client.images.Remove(img)

	/// Add an image that will attempt to attach itself to the mob inhabited by a mind, and update itself should the associated mind move to another mob.
	proc/add_mind_mob_overlay(datum/mind/mind, image/image, see_own_overlay = TRUE)
		var/datum/mind_mob_overlay/mind_mob_overlay = new(src, mind, image, see_own_overlay)
		src.minds_with_associated_mob_image[mind] = mind_mob_overlay

	/// Remove a mind mob image.
	proc/remove_mind_mob_overlay(datum/mind/mind)
		var/datum/mind_mob_overlay/mind_mob_overlay = src.minds_with_associated_mob_image[mind]
		mind_mob_overlay?.remove_self()
		src.minds_with_associated_mob_image.Remove(mind)

	/// Adds a mob to the mob list, adds all images to its client and registers signals on it.
	proc/add_mob(mob/added_mob)
		subscribed_mobs_with_subcount[added_mob] += 1
		if (subscribed_mobs_with_subcount[added_mob] == 1) // mob added for the first time, adding images to client and registering signals
			if(added_mob.client)
				add_client(added_mob.client)

			RegisterSignal(added_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))
			RegisterSignal(added_mob, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
			RegisterSignal(added_mob, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(remove_mob_forced))

	/// Removes a mob from the mob list, removes the images from its client and unregisters signals on it. Force overrides subcount and removes it no matter what.
	proc/remove_mob(mob/removed_mob, force = FALSE) // same just reverse, and unregisters signals
		if (force)
			subscribed_mobs_with_subcount[removed_mob] = 0
		else
			subscribed_mobs_with_subcount[removed_mob] -= 1
		if (subscribed_mobs_with_subcount[removed_mob] <= 0) // mob no longer subscribed, removing images from client and unregistering signals
			subscribed_mobs_with_subcount.Remove(removed_mob)
			if(removed_mob.client)
				remove_client(removed_mob.client)
			UnregisterSignal(removed_mob, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_PARENT_PRE_DISPOSING))

	/// Adds a mind to the mind list, adds all images to its client and registers signals on it.
	proc/add_mind(datum/mind/added_mind)
		subscribed_minds_with_subcount[added_mind] += 1
		if (subscribed_minds_with_subcount[added_mind] == 1)
			if(added_mind.current)
				add_mob(added_mind.current)
				RegisterSignal(added_mind, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(remove_mind))
				RegisterSignal(added_mind, COMSIG_MIND_ATTACH_TO_MOB, PROC_REF(on_mind_attach))
				RegisterSignal(added_mind, COMSIG_MIND_DETACH_FROM_MOB, PROC_REF(on_mind_detach))

	proc/remove_mind(datum/mind/removed_mind)
		subscribed_minds_with_subcount[removed_mind] -= 1
		if (subscribed_minds_with_subcount[removed_mind] <= 0)
			subscribed_minds_with_subcount.Remove(removed_mind)
			if(removed_mind.current)
				remove_mob(removed_mind.current)
				UnregisterSignal(removed_mind, list(COMSIG_PARENT_PRE_DISPOSING, COMSIG_MIND_ATTACH_TO_MOB, COMSIG_MIND_DETACH_FROM_MOB))

	/// Adds a client directly, this should rarely be necessary.
	proc/add_client(client/added_client)
		if(isnull(added_client))
			return
		subscribed_clients_with_subcount[added_client] += 1
		if (subscribed_clients_with_subcount[added_client] == 1)
			for (var/image/img as() in images)
				if (image_condition(img, added_client.mob))
					added_client.images.Add(img)
			RegisterSignal(added_client, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_client_del))

	proc/on_client_del(client/client)
		remove_client(client, force=TRUE)

	proc/on_login(mob/M)
		add_client(M.client)

	/// Removes a client directly, this should rarely be necessary.
	proc/remove_client(client/removed_client, force=FALSE, last_ckey=null)
		if(isnull(removed_client))
			return
		if (force)
			subscribed_clients_with_subcount[removed_client] = 0
		else
			subscribed_clients_with_subcount[removed_client] -= 1
		if (subscribed_clients_with_subcount[removed_client] <= 0)
			subscribed_clients_with_subcount.Remove(removed_client)
			removed_client.images.Remove(images)
			UnregisterSignal(removed_client, COMSIG_PARENT_PRE_DISPOSING)

	proc/on_logout(mob/M)
		remove_client(M.last_client, last_ckey=M.last_ckey)

	disposing()
		if(src.key)
			client_image_groups -= key
		src.key = null
		for(var/datum/mind/iterated_mind as anything in subscribed_minds_with_subcount)
			remove_mind(iterated_mind)
		for(var/mob/iterated_mob as anything in subscribed_mobs_with_subcount)
			remove_mob(iterated_mob, TRUE)
		for(var/image/iterated_image as anything in images)
			remove_image(iterated_image)
		subscribed_minds_with_subcount = null
		subscribed_mobs_with_subcount = null
		mob_to_associated_images_lookup = null
		..()

	// private procs for signal purposes:

	/// when a registered mind attaches to a mob
	proc/on_mind_attach(datum/mind/mind, mob/M)
		PRIVATE_PROC(TRUE)
		add_mob(M)

	/// when a registered mind detaches from a mob
	proc/on_mind_detach(datum/mind/mind, mob/M)
		PRIVATE_PROC(TRUE)
		remove_mob(M)

	/// Registered on PARENT_PRE_DISPOSING, removes the mob from the list and unregisters signals from the mob when it's deleted.
	proc/remove_mob_forced(mob/removed_mob)
		PRIVATE_PROC(TRUE)
		subscribed_mobs_with_subcount.Remove(removed_mob)
		UnregisterSignal(removed_mob, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_PARENT_PRE_DISPOSING))

	/// Removes or adds images to clients depending on the mob who the icons belong to's invisibility.
	proc/on_mob_invisibility_changed(mob/invis_updated_mob)
		PRIVATE_PROC(TRUE)
		for (var/image/I in mob_to_associated_images_lookup[invis_updated_mob])
			if (invis_updated_mob.invisibility) // mob is invisible, remove their icons for other mobs
				for (var/mob/iterated_mob as() in subscribed_mobs_with_subcount)
					if ((iterated_mob != invis_updated_mob) && (invis_updated_mob.invisibility > iterated_mob.see_invisible)) // do nothing for the same person or ghosts
						iterated_mob.client?.images.Remove(I)
			else // mob is visible, add their icons to other mobs
				for (var/mob/iterated_mob as() in subscribed_mobs_with_subcount)
					if ((iterated_mob != invis_updated_mob) && (invis_updated_mob.invisibility <= iterated_mob.see_invisible)) // do nothing for the same person or ghosts
						iterated_mob.client?.images.Add(I)

/// Returns the client image group for a given "key" argument. If one doesn't yet exist, creates it.
proc/get_image_group(key)
	RETURN_TYPE(/datum/client_image_group)
	if (isnull(global.client_image_groups))
		global.client_image_groups = list()
	if (!(key in client_image_groups))
		if(ispath(key))
			client_image_groups[key] = new key(key)
		else
			client_image_groups[key] = new /datum/client_image_group(key)
	return client_image_groups[key]
