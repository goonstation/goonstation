/datum/data
	var/name = "data"
	var/size = 1.0

/datum/data/record
	name = "record"
	size = 5.0
	var/list/fields = list(  )

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0

/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all APCs & sources
	var/list/data_nodes = list()// all networked machinery

	var/newload = 0
	var/load = 0
	var/newavail = 0
	var/avail = 0

	var/viewload = 0

	var/number = 0

	var/perapc = 0			// per-apc avilability

	var/netexcess = 0
