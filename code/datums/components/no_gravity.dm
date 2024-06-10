/datum/component/loctargeting/no_gravity
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	loctype = /mob/living

/datum/component/loctargeting/no_gravity/on_added(atom/movable/source, atom/old_loc)
	. = ..()
	var/obj/item/I = parent
	var/mob/living/user = source.loc
	if (istype(user) && I.no_gravity)
		user.no_gravity = 1

/datum/component/loctargeting/no_gravity/on_removed(atom/movable/source, atom/old_loc)
	. = ..()
	var/mob/living/user = old_loc
	if(istype(user))
		user.no_gravity = 0
		for (var/atom/movable/A as anything in user)
			if (A.no_gravity)
				user.no_gravity = 1 //keep on if we are still holdin stuff
