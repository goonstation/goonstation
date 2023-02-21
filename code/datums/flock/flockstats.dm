/// Datum for storing and processing stats from flock rounds.
/// Each flock spawned will grab an instance of this
/// At round end, the stats will be collated and stored

///Config for the last X rounds we save the stats for.
#define FLOCK_ROUNDS_SAVED 25


/// Global list to handle multiple flocks existing
var/global/list/datum/flockstats/flockstats_global = list()

///In a sensible language, this would be a static class proc. Alas this is DM.
///This proc saves all the stats for all flocks in this round, and rotates the log so only the last FLOCK_ROUNDS_SAVED flock rounds are stored
proc/save_flock_stats()
	if(length(flockstats_global) == 0)
		return
	var/players = world.load_intra_round_value("flock_plays_total") || 0
	var/builders = world.load_intra_round_value("flock_relays_total") || 0
	var/winners = world.load_intra_round_value("flock_wins_total") || 0
	var/list/encoded_stats_stored = list()
	for(var/i = 1 to FLOCK_ROUNDS_SAVED)
		var/stat_string = world.load_intra_round_value("flock_stats[i]")
		if(isnull(stat_string))
			break
		encoded_stats_stored += stat_string

	//rotate, discarding the last
	for(var/datum/flockstats/stat as anything in flockstats_global)
		if (stat.drones_made <= 0) //ignore flocks that never deployed a rift
			continue
		players++
		if(stat.built_relay)
			builders++
		if(stat.won)
			winners++
		encoded_stats_stored.Insert(1, stat.encode_for_saving())

	for(var/i = 1 to min(length(encoded_stats_stored), FLOCK_ROUNDS_SAVED))
		if(world.save_intra_round_value("flock_stats[i]", encoded_stats_stored[i]) != 0)
			CRASH("Failed to save flockstats!")

	world.save_intra_round_value("flock_plays_total", players)
	world.save_intra_round_value("flock_relays_total", builders)
	world.save_intra_round_value("flock_wins_total", winners)


/datum/flockstats
	var/drones_made = 0
	var/bits_made = 0
	var/deaths = 0
	var/resources_gained = 0
	var/partitions_made = 0
	var/tiles_converted = 0
	var/structures_made = 0
	var/peak_compute = 0
	var/respawns = 0
	var/built_relay = FALSE
	var/won = FALSE
	var/flockname = ""

	var/datum/flock/my_flock

	New(owner)
		..()
		if(istext(owner))
			src.decode_and_load(owner)
		else if(istype(owner, /datum/flock))
			flockstats_global += src
			src.my_flock = owner
			src.flockname = src.my_flock.name
		else
			CRASH("Tried to instantiate flockstats with invalid owner: [owner]")

	proc/reset_stats()
		src.drones_made = 0
		src.bits_made = 0
		src.deaths = 0
		src.resources_gained = 0
		src.partitions_made = 0
		src.tiles_converted = 0
		src.structures_made = 0
		src.peak_compute = 0
		src.respawns = 0

	proc/encode_for_saving()
		var/list/save = list()
		save["flockname"] = src.flockname
		save["drones_made"] = src.drones_made
		save["bits_made"] = src.bits_made
		save["deaths"] = src.deaths
		save["resources_gained"] = src.resources_gained
		save["partitions_made"] = src.partitions_made
		save["tiles_converted"] = src.tiles_converted
		save["structures_made"] = src.structures_made
		save["peak_compute"] = src.peak_compute
		save["respawns"] = src.respawns
		save["won"] = src.won
		save["built_relay"] = src.built_relay
		return json_encode(save)

	proc/decode_and_load(var/json_encoded_string="")
		var/list/load = json_decode(json_encoded_string)
		src.flockname = load["flockname"]
		src.drones_made = load["drones_made"]
		src.bits_made = load["bits_made"]
		src.deaths = load["deaths"]
		src.resources_gained = load["resources_gained"]
		src.partitions_made = load["partitions_made"]
		src.tiles_converted = load["tiles_converted"]
		src.structures_made = load["structures_made"]
		src.peak_compute = load["peak_compute"]
		src.respawns = load["respawns"]
		src.won = load["won"]
		src.built_relay = load["built_relay"]
		return src


/obj/item/paper/flockstatsnote
	name = "teal stained note"
	desc = "A piece of paper stained teal, with crystalised edges. It seems to contain some record of Flock infestations."
	var/list/datum/flockstats/stat_store

	New()
		..()
		src.setMaterialAppearance(getMaterial("gnesis")) //we just want the appearance, not actually the material
		src.stat_store = list()
		var/players = world.load_intra_round_value("flock_plays_total") || 0
		var/builders = world.load_intra_round_value("flock_relays_total") || 0
		var/winners = world.load_intra_round_value("flock_wins_total") || 0
		for(var/i = 1 to FLOCK_ROUNDS_SAVED)
			var/stat_string = world.load_intra_round_value("flock_stats[i]")
			if(isnull(stat_string))
				break
			src.stat_store += new /datum/flockstats(stat_string)
		src.info = {"<center><b>Flock Stats<b></center><br>
					The Flock has been sighted [players] times, with [builders] building the Relay, and [winners] transmitting the Signal!<br>
					Statistics for the last [length(stat_store)] Flocks:<br>
					<ol>\n"}
		for(var/datum/flockstats/stat in src.stat_store)
			src.info += {"<li><b>[stat.flockname][stat.won ? " - RETRANSMITTED" :""]<b>
							<ul>
								<li>Built the Relay: [stat.built_relay ? "Yes": "No"]</li>
								<li>Drones made: [stat.drones_made]</li>
								<li>Bits made:[stat.bits_made]</li>
								<li>Drones destroyed: [stat.deaths]</li>
								<li>Resources gathered: [stat.resources_gained]</li>
								<li>Partitions made: [stat.partitions_made]</li>
								<li>Tiles converted:[stat.tiles_converted]</li>
								<li>Structures built: [stat.structures_made]</li>
								<li>Peak compute: [stat.peak_compute]</li>
								<li>Respawns: [stat.respawns]</li>
							</ul>
						</li>"}



#undef FLOCK_ROUNDS_SAVED
