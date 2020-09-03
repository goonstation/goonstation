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
	if (I.loc != curent_user)
		curent_user.no_gravity = 0
		for (var/thing in curent_user)
			var/atom/movable/A = thing
			if (A.no_gravity)
				curent_user.no_gravity = 1 //keep on if we are still holdin stuff
