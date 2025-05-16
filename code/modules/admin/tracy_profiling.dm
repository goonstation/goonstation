var/global/tracy_log = null
var/global/tracy_initialized = FALSE
var/global/tracy_init_error = null
var/global/tracy_init_reason = null

/proc/prof_init()
	if(!fexists(TRACY_DLL_PATH))
		world.log << "Error initializing byond-tracy: [TRACY_DLL_PATH] not found!"
		CRASH("Error initializing byond-tracy: [TRACY_DLL_PATH] not found!")

	world.log << "Enabling the Tracy Profiler Hook."

	var/init_result = call_ext(TRACY_DLL_PATH , "init")("block")
	if (length(init_result) != 0 && init_result[1] == ".") // if first character is ., then it returned the output filename
		world.log << "byond-tracy initialized (logfile: [init_result])"
		global.tracy_initialized = TRUE
		return tracy_log = init_result
	else if (init_result != "0")
		global.tracy_init_error = init_result
		world.log <<  "Error initializing byond-tracy: [init_result]"
		CRASH("Error initializing byond-tracy: [init_result]")
	else
		global.tracy_initialized = TRUE
		world.log << "byond-tracy initialized (no logfile)"

/world/proc/shutdown_byond_tracy()
	if (tracy_initialized)
		world.log << "Shutting down byond-tracy"
		message_admins("Shutting down byond-tracy")
		global.tracy_initialized = FALSE
		call_ext(TRACY_DLL_PATH, "destroy")()

/proc/toggle_tracy_profiling_file()
	var/enabled = FALSE
	if (fexists(TRACY_ENABLE_PATH))
		fdel(TRACY_ENABLE_PATH)
	else
		var/file = file(TRACY_ENABLE_PATH)
		file << ""
		enabled = TRUE
	return enabled

#undef TRACY_DLL_PATH
