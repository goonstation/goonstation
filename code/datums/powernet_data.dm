/datum/data
	var/name = "data"
	var/size = 1

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
	/// Estimate of per-APC proportion of output
	var/perapc = 0

	var/netexcess = 0
	/// Each APC's share of excess power, offered for recharge
	var/apc_charge_share = 0
