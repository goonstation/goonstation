/datum/spatial_hashmap/listeners
	cell_size = DEFAULT_HEARING_RANGE * 2

/datum/spatial_hashmap/listeners/register_hashmap_entry(datum/listen_module/input/entry, atom/tracked_atom)
	. = ..()
	src.RegisterSignal(entry, COMSIG_LISTENER_ORIGIN_UPDATED, PROC_REF(update_tracked_atom_wrapper))

/datum/spatial_hashmap/listeners/unregister_hashmap_entry(datum/listen_module/input/entry)
	. = ..()
	src.UnregisterSignal(entry, COMSIG_LISTENER_ORIGIN_UPDATED)

/datum/spatial_hashmap/listeners/proc/update_tracked_atom_wrapper(datum/listen_module/input/entry, atom/old_origin, atom/new_origin)
	src.update_tracked_atom(entry, new_origin)





/client/proc/cmd_prune_hashmaps()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Prune Hashmaps"
	set desc = "Prune the hashmaps used by the speech system of qdeleted entries."
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC

	var/output = ""

	for (var/channel_id in global.SpeechManager.say_channel_cache)
		var/datum/say_channel/delimited/local/channel = global.SpeechManager.say_channel_cache[channel_id]
		if (!istype(channel))
			continue

		var/count = channel.hashmap.prune()
		if (count)
			output += "<br>&bull; [channel.hashmap.name]: [count] [count == 1 ? "entry" : "entries"]."

	if (length(output))
		global.message_admins("[key_name(src)] has pruned the following hashmaps of qdeleted entries:[output]")
	else
		boutput(usr, SPAN_ADMIN("No qdeleted entries to prune."))


/datum/spatial_hashmap/proc/prune()
	. = 0

	for (var/z in 1 to src.z_order)
		for (var/y in 1 to src.y_order)
			for (var/x in 1 to src.x_order)
				var/alist/cell = src.hashmap[z][y][x]

				for (var/datum/entry as anything in cell)
					if (!QDELETED(entry))
						continue

					src.unregister_hashmap_entry(entry)
					cell -= entry
					. += 1
