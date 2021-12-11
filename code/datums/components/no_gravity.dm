/datum/component/holdertargeting/no_gravity
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	keep_while_on_mob = TRUE

/datum/component/holdertargeting/no_gravity/on_pickup(datum/source, mob/user)
	. = ..()
	var/obj/item/I = parent
	if (I.no_gravity)
		user.no_gravity = 1



/datum/component/holdertargeting/no_gravity/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = parent
	if (I.loc != user)
		user.no_gravity = 0
		for (var/atom/movable/A as anything in user)
			if (A.no_gravity)
				user.no_gravity = 1 //keep on if we are still holdin stuff
