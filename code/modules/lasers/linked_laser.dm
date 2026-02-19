/obj/linked_laser
	icon = 'icons/obj/lasers/ptl_beam.dmi'
	icon_state = "ptl_beam"
	anchored = ANCHORED_ALWAYS
	layer = ABOVE_OBJ_LAYER //layer over mirrors
	density = 0
	luminosity = 1
	mouse_opacity = 0
	///How many laser segments are behind us
	var/length = 0
	///Maximum number of segments in the beam, this exists to prevent nerds from blowing up the server
	var/max_length = 500
	var/obj/linked_laser/next = null
	var/obj/linked_laser/previous = null
	var/turf/current_turf = null
	///Are we at the very end of the beam, and so watching to see if the next turf becomes free
	var/is_endpoint = FALSE
	///A laser sink we're pointing into (null on most beams)
	var/obj/laser_sink/sink = null
	///Relative laser power, modified by splitters etc.
	var/power = 1

/obj/linked_laser/ex_act(severity)
	return

/obj/linked_laser/New(loc, dir)
	..()
	src.length = length
	src.dir = dir
	src.current_turf = get_turf(src)
	RegisterSignal(current_turf, COMSIG_TURF_REPLACED, PROC_REF(current_turf_replaced))
	RegisterSignal(current_turf, COMSIG_TURF_CONTENTS_SET_DENSITY, PROC_REF(current_turf_density_change))

///Attempt to propagate the laser by extending, interacting with sinks etc.
///Separated from New to allow setting up properties on a laser object without passing them as New args
/obj/linked_laser/proc/try_propagate()
	src.icon_state = src.get_icon_state()
	var/turf/next_turf = get_next_turf()
	if (!istype(next_turf) || next_turf == src.current_turf)
		return
	//check the turf for anything that might block us, and notify any laser sinks we find
	var/blocked = FALSE
	if (next_turf.density)
		blocked = TRUE
	else
		for (var/obj/object in next_turf)
			if (istype(object, /obj/laser_sink))
				var/obj/laser_sink/sink = object
				if (sink.incident(src))
					src.sink = sink
			if (src.is_blocking(object))
				blocked = TRUE
				break
	if (src.length >= src.max_length)
		return
	if (!blocked)
		SPAWN(0) //this is here because byond hates recursion depth
			src.extend()
	else
		src.become_endpoint()

/obj/linked_laser/proc/get_next_turf()
	return get_step(src, src.dir)

///Returns a new segment with all its properties copied over (override on child types)
/obj/linked_laser/proc/copy_laser(turf/T, dir)
	var/obj/linked_laser/new_laser = new src.type(T, dir)
	new_laser.length = src.length + 1
	new_laser.power = src.power
	return new_laser

///Set up a new laser on the next turf
/obj/linked_laser/proc/extend()
	src.next = src.copy_laser(src.get_next_turf(), src.dir)
	src.next.previous = src
	src.next.try_propagate()
	src.release_endpoint()

///Called on the last laser in the chain to make it watch for changes to the turf blocking it
/obj/linked_laser/proc/become_endpoint()
	src.is_endpoint = TRUE
	var/turf/next_turf = get_next_turf()
	RegisterSignal(next_turf, COMSIG_TURF_REPLACED, PROC_REF(next_turf_replaced))
	RegisterSignal(next_turf, COMSIG_ATOM_UNCROSSED, PROC_REF(next_turf_updated))
	RegisterSignal(next_turf, COMSIG_TURF_CONTENTS_SET_DENSITY, PROC_REF(next_turf_updated))

///Called when we extend a new laser object and are therefore no longer an endpoint
/obj/linked_laser/proc/release_endpoint()
	src.is_endpoint = FALSE
	var/turf/next_turf = get_next_turf() //this may cause problems when the next turf changes, we'll need to handle re-registering signals waa
	UnregisterSignal(next_turf, COMSIG_TURF_REPLACED)
	UnregisterSignal(next_turf, COMSIG_ATOM_UNCROSSED)
	UnregisterSignal(next_turf, COMSIG_TURF_CONTENTS_SET_DENSITY)

///Kill any upstream laser objects
/obj/linked_laser/disposing()
	UnregisterSignal(src.current_turf, COMSIG_TURF_REPLACED)
	UnregisterSignal(src.current_turf, COMSIG_TURF_CONTENTS_SET_DENSITY)
	SPAWN(0)
		qdel(src.next)
		src.next = null
	src.sink?.exident(src)
	src.sink = null
	if (!QDELETED(src.previous))
		src.previous.become_endpoint()
	if (src.is_endpoint)
		src.release_endpoint()
	..()

///Does something block the laser?
/obj/linked_laser/proc/is_blocking(atom/movable/A)
	if(!istypes(A, list(/obj/window, /obj/mesh/grille, /obj/machinery/containment_field)) && !ismob(A) && A.density)
		return TRUE

///Does anything on a turf block the laser?
/obj/linked_laser/proc/turf_check(turf/T)
	. = TRUE
	if (!istype(T) || T.density)
		return FALSE
	for (var/obj/object in T)
		if (src.is_blocking(object))
			return FALSE

///NB: the parent is allowed to qdel src here, so child types should handle being qdeled in Crossed
/obj/linked_laser/Crossed(atom/movable/A)
	..()
	if (istype(A, /obj/laser_sink) && src.previous)
		var/turf/T = get_turf(src)
		//we need this to happen after the crossing atom has finished moving otherwise mirrors will delete their own laser obj
		SPAWN(0)
			if (!QDELETED(src.previous) && get_turf(A) == T) //check that the sink hasn't moved during our SPAWN
				src.previous.sink = A
				src.previous.sink.incident(src.previous)
	if (src.is_blocking(A))
		qdel(src)

///Traverses all upstream laser segments and calls proc_to_call on each of them
/obj/linked_laser/proc/traverse(proc_to_call)
	var/obj/linked_laser/ptl/current_laser = src
	do
		call(current_laser, proc_to_call)()
		if (!current_laser.next)
			current_laser.sink?.traverse(proc_to_call)
		current_laser = current_laser.next
	while (current_laser)

/obj/linked_laser/proc/get_icon_state()
	return src.icon_state

/obj/linked_laser/proc/get_corner_icon_state(facing)
	return "[src.get_icon_state()]_corner[facing]"

//////////////clusterfuck signal registered procs///////////////

///Our turf is being replaced with another
/obj/linked_laser/proc/current_turf_replaced()
	SPAWN(1) //wait for the turf to actually be replaced
		var/turf/T = get_turf(src)
		if (!istype(T) || T.density)
			qdel(src)

///Something is changing density in our current turf
/obj/linked_laser/proc/current_turf_density_change(turf/T, old_density, atom/thing)
	if (src.is_blocking(thing))
		qdel(src)

///The next turf in line is being replaced with another, so check if it's now suitable to put another laser on
/obj/linked_laser/proc/next_turf_replaced()
	src.release_endpoint()
	SPAWN(1) //wait for the turf to actually be replaced
		var/turf/next_turf = get_next_turf()
		if (src.turf_check(next_turf))
			src.extend()
		else
			//if we can't put a new laser there, then register to watch the new turf
			src.become_endpoint()

///Something is crossing into or changing density in the next turf in line
/obj/linked_laser/proc/next_turf_updated(loc, mover)
	if (istype(mover, /obj/linked_laser)) //no, dont car
		return
	var/turf/next_turf = get_next_turf()
	if (turf_check(next_turf))
		src.sink?.exident(src)
		//in case this is a sink, we need to wait for it to have finished moving before trying to incident on it again
		//I know SPAWN(0) is cringe but do you really want to see the control logic I'd have to rig up to do this properly?
		SPAWN(0)
			src.extend()
