/proc/enable_reference_tracking()
	var/extools = world.GetConfig("env", "EXTOOLS_DLL") || (world.system_type == MS_WINDOWS ? "./byond-extools.dll" : "./libbyond-extools.so")
	if (fexists(extools))
		call(extools, "ref_tracking_initialize")()

/proc/get_back_references(datum/D)
	CRASH("/proc/get_back_references not hooked by extools, reference tracking will not function!")

/proc/get_forward_references(datum/D)
	CRASH("/proc/get_forward_references not hooked by extools, reference tracking will not function!")

/proc/clear_references(datum/D)
	return

#ifdef REFERENCE_TRACKING
/datum/Del()
	clear_references(src)
	..()
#endif

/client/proc/view_references(atom/D, window_name=null) //it actually supports datums as well but byond no likey
	var/list/backrefs = get_back_references(D)
	if(isnull(window_name))
		window_name = "ref_view_\ref[D]"
	if(isnull(backrefs))
		src.Browse("Reference tracking not enabled", "window=[window_name]")
		return
	if(isnull(D))
		src.Browse("Datum does not exist.", "window=[window_name]")
		return
	var/list/frontrefs = get_forward_references(D)
	var/list/dat = list()
	var/maybe_type = ""
	if(istype(D, /datum))
		maybe_type = "- [D.type]"
	dat += "<h2>References of \ref[D] - [D] [maybe_type]</h2><br><a href='?src=\ref[src];ViewReferences=\ref[D];window_name=[window_name]'>\[Refresh\]</a> &middot; <a href='?src=\ref[src];Refresh=\ref[D];window_name=[window_name]'>\[View Variables\]</a><hr>"
	dat += "<h3>Back references - these things hold references to this object.</h3>"
	dat += "<table>"
	dat += "<tr><th>Ref</th><th>Name</th><th>Type</th><th>Variable Name</th><th>Follow</th>"
	for (var/datum/R as anything in backrefs)
		dat += "<tr><td><a href='?src=\ref[src];Refresh=\ref[R]'>[ref(R)]</td><td>[R]</td><td>[R.type]</td><td>[backrefs[R]]</td><td><a href='?src=\ref[src];ViewReferences=\ref[R];window_name=[window_name]'>\[Follow\]</a></td></tr>"
	dat += "</table><hr>"
	dat += "<h3>Forward references - this object is referencing those things.</h3>"
	dat += "<table>"
	dat += "<tr><th>Variable name</th><th>Ref</th><th>Name</th><th>Type</th><th>Follow</th>"
	for(var/ref in frontrefs)
		var/datum/R = frontrefs[ref]
		dat += "<tr><td>[ref]</td><td><a href='?src=\ref[src];Refresh=\ref[R]'>[ref(R)]</a></td><td>[R]</td><td>[R.type]</td><td><a href='?src=\ref[src];ViewReferences=\ref[R];window_name=[window_name]'>\[Follow\]</a></td></tr>"
	dat += "</table><hr>"
	dat = dat.Join()

	src.Browse(dat, "window=[window_name]")
