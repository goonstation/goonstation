ABSTRACT_TYPE(/obj/laser_sink)
///The abstract concept of a thing that does stuff when hit by a laser
/obj/laser_sink //might end up being a component or something
	var/obj/linked_laser/in_laser = null
///When a laser hits this sink, return TRUE on successful connection
/obj/laser_sink/proc/incident(obj/linked_laser/laser)
	return TRUE

///"that's not a word" - 🤓
///When a laser stops hitting this sink
/obj/laser_sink/proc/exident(obj/linked_laser/laser)
	src.in_laser = null

///Another stub, should call traverse on all emitted laser segments with the proc passed through
/obj/laser_sink/proc/traverse(datum/callback/callback)
	return

/obj/laser_sink/Move()
	src.exident(src.in_laser)
	..()

/obj/laser_sink/set_loc(loc)
	if (loc != src.loc)
		src.exident(src.in_laser)
	..()

/obj/laser_sink/disposing()
	src.exident(src.in_laser)
	..()
