/datum/mind_mob_overlay
	var/datum/client_image_group/image_group
	var/datum/mind/owner
	var/image/image
	var/see_own_overlay = TRUE

	New(datum/client_image_group/image_group, datum/mind/owner, image/image, see_own_overlay = TRUE)
		. = ..()
		src.image_group = image_group
		src.owner = owner
		src.image = image
		src.see_own_overlay = see_own_overlay

		src.attach_self()

	/// Attempt to attach the image to the owner's mob, and set up signals to track when the owner moves mobs.
	proc/attach_self()
		if (src.owner.current)
			src.image.loc = src.owner.current
			src.image_group.add_image(src.image)

		RegisterSignal(src.owner, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(remove_self))
		RegisterSignal(src.owner, COMSIG_MIND_ATTACH_TO_MOB, PROC_REF(update_loc))

	/// Update the .loc of the image so that it appears attached to the owner's mob.
	proc/update_loc()
		if (src.image.loc)
			src.image_group.remove_image(src.image)

		if (src.owner.current)
			src.image.loc = src.owner.current
			src.image_group.add_image(src.image)

	/// Remove and delete the image, then queue the datum for deletion.
	proc/remove_self()
		src.image_group.remove_image(src.image)
		qdel(src.image)
		qdel(src)
