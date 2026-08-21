/datum/spatial_hashmap/clients
	cell_size = 30

/datum/spatial_hashmap/clients/register_hashmap_entry(datum/entry, atom/tracked_atom)
	. = ..()
	src.RegisterSignal(entry, COMSIG_CLIENT_LOGIN, PROC_REF(update_tracked_atom))

/datum/spatial_hashmap/clients/unregister_hashmap_entry(datum/entry)
	. = ..()
	src.UnregisterSignal(entry, COMSIG_CLIENT_LOGIN)





/client/New()
	. = ..()
	global.client_hashmap.register_hashmap_entry(src, src.mob)
	// gross hack for audio routing
	if (isskeleton(src.mob))
		var/obj/item/organ/head/head = IS_HEADLESS_SKELETON(src.mob)
		if (head)
			global.sound_hashmap.register_hashmap_entry(src, head)
		else
			global.sound_hashmap.register_hashmap_entry(src, src.mob)
	else
		global.sound_hashmap.register_hashmap_entry(src, src.mob)

/client/Del()
	global.client_hashmap.unregister_hashmap_entry(src)
	. = ..()
