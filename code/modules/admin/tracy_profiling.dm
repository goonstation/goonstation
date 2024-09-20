var/tracy_toggle_path = "data/tracy_profiling_enabled"

/proc/prof_init()
	world.log << "Enabling the Tracy Profiler Hook."
	var/lib
	switch(world.system_type)
		if(MS_WINDOWS) lib = "prof.dll"
		if(UNIX) lib = "./libprof.so"
		else CRASH("unsupported platform")

	var/init = LIBCALL(lib, "init")("block")
	if("0" != init) CRASH("[lib] init error: [init]")

/proc/check_tracy_toggle()
	if (fexists(tracy_toggle_path))
		fdel(tracy_toggle_path)
		prof_init()

/proc/toggle_tracy_profiling_file()
	var/enabled = FALSE
	if (fexists(tracy_toggle_path))
		fdel(tracy_toggle_path)
	else
		var/file = file(tracy_toggle_path)
		file << ""
		enabled = TRUE
	return enabled
