/datum/disjoint_turf
	var/connections
	var/list/turf/turfs

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
			SPAWN_DBG(5 SECONDS)
				for(var/turf/T in disjoint_turf_connections[id])
					if(T != source)
						connect(source, T)
						break

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

	proc/connect(turf/source, turf/destination, new_name)
		if(!new_name)
			new_name = src.name
		if(source && destination)
			var/datum/disjoint_turf/C = new
			C.connections = DISJOINT_TURF_CONNECTION_DISPOSAL | DISJOINT_TURF_CONNECTION_ATMOS_MACHINERY | DISJOINT_TURF_CONNECTION_POWERNETS
			LAZYLISTINIT(C.turfs)
			C.turfs |= destination
			LAZYLISTINIT(source.connections)
			LAZYLISTINIT(source.connections[name])
			source.connections[name] = C


/turf/proc/get_disjoint_objects_by_type(flag, target_type)
	. = list()
	if(length(connections))
		for(var/key in connections)
			var/datum/disjoint_turf/C = connections[key]
			if(C.connections & flag)
				for(var/turf/T in C.turfs)
					var/atom/A = locate(target_type) in T
					if(A)
						. |= A
