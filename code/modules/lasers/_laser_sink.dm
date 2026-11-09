ABSTRACT_TYPE(/obj/laser_sink)
///The abstract concept of a thing that does stuff when hit by a laser.
///Subtypes should register handlers for COMSIG_LASER_CONNECTED, COMSIG_LASER_DISCONNECTED, and COMSIG_LASER_TRAVERSE
///in their New() to implement type-specific behavior.
///
/// You don't HAVE to use this subtype, but it's a common one from the original implementation and changing it makes no sense.
/obj/laser_sink
	///Convenient reference to the laser_sink component added in New()
	var/datum/component/laser_sink/laser_sink_comp = null

/obj/laser_sink/New()
	..()
	laser_sink_comp = AddComponent(/datum/component/laser_sink)
