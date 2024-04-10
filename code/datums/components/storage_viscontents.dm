///
/datum/component/storage_viscontents
	var/obj/storage/crate/parent_container

/datum/component/storage_viscontents/Initialize(container)
	parent_container = container
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(remove_self))
	..()

/datum/component/storage_viscontents/proc/remove_self(source)
	var/obj/O = parent
	O.transform = matrix()
	parent_container.vis_items -= parent
	qdel(src)
