/// Resets the transformation on an item when it's picked up. Used for resizing things coming out of gang crates.
/datum/component/reset_transform_on_pickup
/datum/component/reset_transform_on_pickup/Initialize()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(fix_transform))
	..()

/datum/component/reset_transform_on_pickup/proc/fix_transform(source)
	var/obj/O = parent
	O.transform = matrix()
	O.pixel_x = 0
	O.pixel_y = 0
	qdel(src)
