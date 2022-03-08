
/datum/var/datum/weakref/weakref = null

proc/get_weakref(datum/dat)
	if(QDELETED(dat))
		return null
	if(isnull(dat.weakref))
		dat.weakref = new weakref(dat)
	. = dat.weakref

/datum/weakref
	var/addr = null

	New(datum/dat)
		. = ..()
		addr = ref(dat)

	proc/deref()
		RETURN_TYPE(/datum)
		var/datum/dat = locate(addr)
		if(!QDELETED(dat) && dat?.weakref == src)
			return dat

	disposing()
		deref()?.weakref = null
		..()
