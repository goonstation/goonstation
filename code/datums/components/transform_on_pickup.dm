/datum/component/transform_on_pickup
/datum/component/transform_on_pickup/Initialize()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/fix_transform)

/datum/component/transform_on_pickup/proc/fix_transform(source)
	var/obj/O = parent
	O.transform = matrix()
	qdel(src)
