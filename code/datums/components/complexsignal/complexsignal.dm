/datum/component/complexsignal
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/registered_count = 0
	var/qdel_when_unneeded = TRUE

/datum/component/complexsignal/proc/register(datum/listener, sig_type, proctype, override = FALSE, ...)
	SHOULD_NOT_OVERRIDE(TRUE)
	registered_count++
	. = src._register(arglist(args))

/datum/component/complexsignal/proc/_register(datum/listener, sig_type, proctype, override = FALSE, ...)
	listener.RegisterSignal(src, sig_type, proctype, override)

/datum/component/complexsignal/proc/unregister(datum/listener, sig_type)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = src._unregister(listener, sig_type)
	registered_count--
	if(registered_count <= 0 && qdel_when_unneeded)
		qdel(src)

/datum/component/complexsignal/proc/_unregister(datum/listener, sig_type)
	listener.UnregisterSignal(src, sig_type)
