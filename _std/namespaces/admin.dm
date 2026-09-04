CREATE_NAMESPACE(ADMIN)

ADD_TO_NAMESPACE(ADMIN)(proc/lights_out(duration = 120 SECONDS))
	set waitfor = FALSE
	var i = 0
	for_by_tcl(apc, /obj/machinery/power/apc)
		if(apc.z == 1)
			if((i++ % 5) == 0)
				sleep(1 SECOND)
			apc.setStatus("lightsout", duration)
