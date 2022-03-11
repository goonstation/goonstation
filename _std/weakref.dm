
/datum/var/datum/weakref/weakref = null

/**
 * Gets a weak reference to the given datum.
 * This is a basically a reference that will not prevent garbage collection of the datum. Useful when you don't want to "own" the datum in question.
 * For example a mob holding a reference to its trinket. In that case it doesn't make sense to prevent garbage collection of the trinket. If the
 * trinket gets destroyed in-game we are fine if this weak reference to the trinket turns to null.
 *
 * You need to use [/datum/weakref/proc/deref] to get the datum from the weak reference.
 */
proc/get_weakref(datum/dat)
	RETURN_TYPE(/datum/weakref)
	if(QDELETED(dat))
		return null
	if(isnull(dat.weakref))
		dat.weakref = new(dat)
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
