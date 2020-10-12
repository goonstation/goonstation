/datum/component/holdertargeting/mat_triggersonlife
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/holdertargeting/mat_triggersonlife/RegisterWithParent()
	..()
	var/obj/item/I = parent
	if (ismob(I.loc))
		var/mob/user = I.loc
		user.mob_flags |= MAT_TRIGGER_LIFE

/datum/component/holdertargeting/mat_triggersonlife/UnregisterFromParent()
	var/obj/item/I = parent

	if (ismob(I.loc))
		var/mob/user = I.loc
		user.mob_flags &= ~MAT_TRIGGER_LIFE
		for (var/atom/movable/A as() in user)

			if (A != src && A.GetComponent(/datum/component/holdertargeting/mat_triggersonlife))
				user.mob_flags |= MAT_TRIGGER_LIFE
	..()

/datum/component/holdertargeting/mat_triggersonlife/on_pickup(datum/source, mob/user)
	. = ..()
	//var/obj/item/I = parent
	if (user)
		user.mob_flags |= MAT_TRIGGER_LIFE

/datum/component/holdertargeting/mat_triggersonlife/on_dropped(datum/source, mob/user)
	var/obj/item/I = parent
	if (user && I.loc != user)
		user.mob_flags &= ~MAT_TRIGGER_LIFE
		for (var/atom/movable/A as() in user)
			if (A != src && A.GetComponent(/datum/component/holdertargeting/mat_triggersonlife))
				user.mob_flags |= MAT_TRIGGER_LIFE
	. = ..()
