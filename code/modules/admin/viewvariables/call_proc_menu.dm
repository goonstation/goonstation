/*
Returns procs of a datum categorized by parent type on which they are defined.
e.g. list_procs(new /obj/item/gnome) returns
list(
	/obj/item/gnome = list("hohoho" = /obj/item/gnome/proc/hohoho),
	/obj/item = list(...),
	/obj = list(...),
	...
)
*/
proc/list_procs(datum/target) // null for global
	. = list()

	var/datum/proc_ownership_cache/proc_ownership_cache = global.get_singleton(/datum/proc_ownership_cache)

	if (isnull(target))
		.[null] = proc_ownership_cache.procs_by_type[null]
		return

	var/type = target.type
	while (type)
		if (proc_ownership_cache.procs_by_type[type])
			.[type] = proc_ownership_cache.procs_by_type[type]

		type = type2parent(type)

/client/proc/show_proc_list(datum/target) // null for global
	var/list/procs = list_procs(target)
	var/link_target = isnull(target) ? "global" : "\ref[target]"
	var/list/lines = list()
	if(isnull(target))
		lines += "<title>Global procs</title>"
	else
		lines += "<title>Procs of [target] - \ref[target] - [target.type]</title>"
	for(var/type in procs)
		if(type)
			lines += "<b syle='padding-left:20px;'>[type]</b><br>"
		for(var/proc_name in procs[type])
			var/pr = procs[type][proc_name]
			lines += "<a href='byond://?src=\ref[src];CallProc=[link_target];proc_ref=\ref[pr]'>[proc_name]</a><br>"
	src.Browse(lines.Join(), "window=proc_list;size=300x800")
