var/global/list/list/procs_by_type = null

proc/generate_procs_by_type()
	if(!isnull(procs_by_type)) // don't want to rebuild twice if someone is really spamming this
		return
	procs_by_type = list()
	var/subaddr = 0
	while(TRUE)
		var/addr = BUILD_ADDR(PROC_TYPEID, subaddr) // 26 is the type id used by procs for ref
		var/pr = locate(addr)
		if(!pr)
			break
		var/pr_path = "[pr]"
		var/last_slash = findlasttext(pr_path, "/")
		var/proc_or_verb = copytext(pr_path, last_slash - 5, last_slash)
		var/owner_type
		if(proc_or_verb == "/proc" || proc_or_verb == "/verb")
			owner_type = text2path(copytext(pr_path, 1, last_slash - 5))
		else
			owner_type = text2path(copytext(pr_path, 1, last_slash))
		var/pr_name = copytext(pr_path, last_slash + 1)
		if(!(owner_type in procs_by_type))
			procs_by_type[owner_type] = list()
		procs_by_type[owner_type][pr_name] = pr
		if(subaddr % 100 == 0)
			LAGCHECK(LAG_MED)
		subaddr++
	for(var/type in procs_by_type)
		procs_by_type[type] = sortList(procs_by_type[type], /proc/cmp_text_asc)
		LAGCHECK(LAG_MED)

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
	if(!istype(procs_by_type))
		generate_procs_by_type()
	if(isnull(target))
		.[null] = procs_by_type[null]
		return
	var/type = target.type
	while(type)
		if(type in procs_by_type)
			.[type] = procs_by_type[type]
		type = type2parent(type) // breaks if you override parent_type, watch out; I'd love to use initial(type.parent_type) but byond dumb

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
