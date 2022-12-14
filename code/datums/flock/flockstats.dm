/// Datum for storing and processing stats from flock rounds.
/// Each flock spawned will grab an instance of this
/// At round end, the stats will be collated and stored

/// Global list to handle multiple flocks existing
var/global/list/datum/flockstats/flockstats_global = list()

/datum/flockstats
	var/drones_made = 0
	var/bits_made = 0
	var/deaths = 0
	var/resources_gained = 0
	var/partitions_made = 0
	var/tiles_converted = 0
	var/structures_made = 0
	var/peak_compute = 0
	var/datum/flock/my_flock

	New(datum/flock/owner)
		..()
		flockstats_global += src
		src.my_flock = owner

	proc/reset_stats()
		src.drones_made = 0
		src.bits_made = 0
		src.deaths = 0
		src.resources_gained = 0
		src.partitions_made = 0
		src.tiles_converted = 0
		src.structures_made = 0
		src.peak_compute = 0
