///
/datum/component/storage_viscontents
	var/datum/vis_storage_controller/controller

/datum/component/storage_viscontents/Initialize(container)
	controller = container
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(remove_self))
	..()

/datum/component/storage_viscontents/proc/remove_self(source)
	controller.vis_items -= parent
	qdel(src)
