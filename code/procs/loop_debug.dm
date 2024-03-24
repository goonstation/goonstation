////////////////////////////////////////////////////////////////////////////////////
// client procs
//
// these verbs allow admins to monitor and adjust the master controller
// and process loops live during the round


/client/proc/main_loop_context()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Main Loop Context"
	set desc = "Displays the current main loop context information (lastproc: lasttask \[world.timeofday\])"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(src.holder)
		if(!src.mob)
			return
		processSchedulerView.getContext()

// this is a godawful hack for now, pending cleanup as part of a better main loop control panel. but hey it works
/client/proc/main_loop_tick_detail()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Main Loop Tick Detail"
	set desc = "Displays detailed tick information for the main loops that support it."
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(src.holder)
		if(!src.mob)
			return
		if(src.holder.rank in list("Coder", "Host"))
			boutput(src, "Dumping detailed tick counters...")
			for (var/datum/controller/process/child in processScheduler.processes)
				child.tickDetail()
		else
			alert("Fuck off, no crashing dis server")
			return
