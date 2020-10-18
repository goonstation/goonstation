/datum/component/holdertargeting/no_gravity
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/holdertargeting/no_gravity/on_pickup(datum/source, mob/user)
	. = ..()
	var/obj/item/I = parent
	if (I.no_gravity)
		user.no_gravity = 1



/datum/component/holdertargeting/no_gravity/on_dropped(datum/source, mob/user)
	. = ..()
	var/obj/item/I = parent
	if (I.loc != current_user)
		current_user.no_gravity = 0
		for (var/atom/movable/A as() in current_user)
			if (A.no_gravity)
				current_user.no_gravity = 1 //keep on if we are still holdin stuff
