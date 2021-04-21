/datum/data
	var/name = "data"
	var/size = 1.0

/datum/data/record
	name = "record"
	size = 5.0
	/// associated list of various data fields
	var/list/fields = list(  )

proc/FindRecordByFieldValue(var/list/datum/data/record/L, var/field, var/value)
	if (!value) return
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R
	return

/datum/powernet
	/// all cables & junctions
	var/list/obj/cable/cables = list()
	/// all APCs & sources
	var/list/obj/machinery/power/nodes = list()
	/// all networked machinery
	var/list/obj/machinery/power/data_nodes = list()

	var/newload = 0
	var/load = 0
	var/newavail = 0
	var/avail = 0

	var/viewload = 0

	var/number = 0
	/// per-apc avilability
	var/perapc = 0

	var/netexcess = 0
