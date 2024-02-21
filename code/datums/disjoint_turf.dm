/** Disjoint Turf Connections
	This allows for a way of treating non-contigious turfs as if they were adjacent.  This provides for interoperability between
	z-levels or different sections of the map without having to connect everything physically.

	Turfs have an associative list of [/datum/disjoint_turf].  The keys are intended to be conceptual connections between the turfs such as
	"up", "down", "underfloor", that way they could be isolated or referred to later.atom

	Each [/datum/disjoint_turf] then has a number of connections types, which define the types of connections allowed, and a number of turfs
	they are connected to.
  */
/datum/disjoint_turf
	/// Valid connection types
	var/connection_types
	/// Turfs of this connection type
	var/list/turf/turfs

/**
 * Helper object to define how disjoint connections are formed.
 *
 * Use [/obj/disjoint_connector/id] to connect thing by name.  All turfs sharing the same name will be linked according to that id
 * Use [/obj/disjoint_connector/location] to connect to a x,y,z.  This allows can be used for a one way connection.
 */
/obj/disjoint_connector/
	icon = 'icons/mob/screen1.dmi'
	icon_state = "connection"
	name = "Disjoint Connector"
	invisibility = 101
	var/reciprocal_name

	var/static/list/list/turf/disjoint_turf_connections = list()

	id
		var/id

		up
			icon_state = "up"
			reciprocal_name = "down"

		down
			icon_state = "down"
			reciprocal_name = "up"

		New()
			..()
			if(!id)
				CRASH("Disjoint Connector missing ID [log_loc(src)]")
			var/turf/source = get_turf(src)
			LAZYLISTADD(disjoint_turf_connections[id], source)
			SPAWN(0)
				for(var/turf/T in disjoint_turf_connections[id])
					if(T != source)
						connect(source, T)

	location
		var/conn_x
		var/conn_y
		var/conn_z
		var/generate_reciprocal = FALSE

		up
			name = "up"
			reciprocal_name = "down"
			icon_state = "up"

		down
			name = "down"
			reciprocal_name = "up"
			icon_state = "down"

		New()
			..()
			var/turf/source = get_turf(src)
			var/turf/destination = locate(conn_x, conn_y, conn_z)
			connect(source, destination)
			if(generate_reciprocal && reciprocal_name)
				connect(destination, source, reciprocal_name)

	proc/connect(turf/source, turf/destination, new_name, flags=DISJOINT_TURF_ALL)
		if(!new_name)
			new_name = src.name
		if(source && destination)
			var/datum/disjoint_turf/C
			LAZYLISTINIT(source.connections)
			LAZYLISTINIT(source.connections[name])
			for(var/datum/disjoint_turf/existing_connection in source.connections[name])
				if(existing_connection.connection_types == flags)
					C = existing_connection
					break

			// Create new connection since none were found
			if(!C)
				C = new
				C.connection_types = flags
				source.connections[name] += C

			LAZYLISTINIT(C.turfs)
			C.turfs |= destination

/**
 * Retrieve a list of objects matching the provided type on connection with the given flag.
 *
 * NOTE: Only one object per turf will be provided.
 *
 * Arguments:
 * * flag - Flag to test for on disjoint connections.
 * * target_type - Target type to test for.
 * * limit_key - (Optional) Specific conceptual link to limit search to ("up", "down", etc)
 */
/turf/proc/get_disjoint_objects_by_type(flag, target_type, limit_key=null)
	. = list()
	if(length(connections))
		for(var/key in connections)
			if(limit_key)
				key = limit_key

			for(var/datum/disjoint_turf/C in connections[key] )
				if((C.connection_types & flag) == flag)
					for(var/turf/T in C.turfs)
						var/atom/A = locate(target_type) in T
						if(A)
							. |= A

			if(limit_key)
				break

/**
 * Retrieve a list of turfs connected by given flag(s).
 *
 * NOTE: Only one object per turf will be provided.
 *
 * Arguments:
 * * flag - Flag to test for on disjoint connections.
 * * limit_key - (Optional) Specific conceptual link to limit search to ("up", "down", etc)
 */
/turf/proc/get_disjoint_turfs(flag, limit_key=null)
	. = list()
	if(length(connections))
		for(var/key in connections)
			if(limit_key)
				key = limit_key

			for(var/datum/disjoint_turf/C in connections[key] )
				if((C.connection_types & flag) == flag)
					. |= C.turfs

			if(limit_key)
				break
