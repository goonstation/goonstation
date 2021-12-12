var/global/waiting_inits = null
var/global/post_init_procs = null
var/global/init_paused = 0
var/global/init_unpausing = FALSE

// TODO refactor this into a single state var with disposed and qdeled
/datum/var/tmp/init_finished = FALSE

proc/pause_init()
	UNTIL(!init_unpausing) // wait till last unpausing finishes
	global.init_paused++
	if(global.init_paused > 1)
		return
	global.waiting_inits = list()

proc/unpause_init()
	global.init_paused--
	if(global.init_paused > 0)
		return
	global.init_unpausing = TRUE
	var/list/inits_to_process = global.waiting_inits
	global.waiting_inits = null // to make sure things happen correctly if some Init() pauses again but that will still lead to awful things, don't do it
	var/list/post_inits_to_process = global.post_init_procs
	global.post_init_procs = null
	for(var/datum/D as anything in inits_to_process)
		if(!QDELETED(D))
			D.Init(arglist(inits_to_process[D]))
			D.init_finished = TRUE
			LAGCHECK(LAG_HIGH)
	for(var/list/L as anything in post_inits_to_process)
		var/datum/D = L[1]
		if(!QDELETED(D))
			var/proc_path = L[2]
			var/list/proc_args = L[3]
			call(D, proc_path)(arglist(proc_args))
			LAGCHECK(LAG_HIGH)
	global.init_unpausing = FALSE

/datum/New(...)
	SHOULD_CALL_PARENT(TRUE)
	..()
	if(global.init_paused)
		global.waiting_inits[src] = args.Copy()
	else
		Init(arglist(args))
		src.init_finished = TRUE

/datum/proc/Init(...)
	SHOULD_CALL_PARENT(TRUE)
	// SHOULD_NOT_SLEEP(TRUE) // uncomment when the 300+ issues are fixed

#define INIT(ARGS...) New(ARGS) ..(); Init(ARGS)
#define INIT_TYPE(TYPE, ARGS...) TYPE/New(ARGS) ..(); TYPE/Init(ARGS)
#define EXPLICIT_NEW New

#define REGISTER_POST_INIT(PROC, ARGS...) \
	if(global.init_paused) {\
		LAZYLISTADD(global.post_init_procs, list(list(src, .proc/PROC, list(ARGS)))) \
	} else  { \
		src.PROC() \
	}

// not related directly per se but stuff related to large scale map changes follows


/// var that signifies some large-scale map geometry modification is happening, for example prefab loading or explosions, pauses some processes
/// Don't edit manually. Use the procs below.
var/global/big_map_changes_happening = 0

proc/begin_big_map_change()
	big_map_changes_happening++

proc/end_big_map_change()
	big_map_changes_happening--
