/proc/prof_init()
	world.log << "Enabling the Tracy Profiler Hook."
	var/lib
	switch(world.system_type)
		if(MS_WINDOWS) lib = "prof.dll"
		if(UNIX) lib = "./libprof.so"
		else CRASH("unsupported platform")

	var/init = LIBCALL(lib, "init")("block")
	if("0" != init) CRASH("[lib] init error: [init]")

/proc/toggle_tracy_profiling()
	var/path = "data/tracy_profiling_enabled"
	var/enabled = FALSE
	if (fexists(path))
		fdel(path)
	else
		var/file = file(path)
		file << ""
		enabled = TRUE
	return enabled
