/// for client variables and stuff that has to persist between connections
/datum/player
	/// the ckey of the client object that this datum is attached to
	var/key
	/// the client object that this datum is attached to
	var/client/client
	/// are they a mentor?
	var/mentor = 0
	/// do we want to see mentor pms?
	var/see_mentor_pms = 1
	/// to make sure that they cant escape being shamecubed by just reconnecting
	var/shamecubed = 0
	/// how many rounds theyve declared ready and joined, null with to differentiate between not set and no participation
	var/rounds_participated = null
	/// how many rounds theyve joined to at least the lobby in, null to differentiate between not set and not seen
	var/rounds_seen = null
	/// a list of cooldowns that has to persist between connections
	var/list/cooldowns = null

	/// sets up vars and caches player stats
	New(key)
		src.key = key
		src.tag = "player-[ckey(key)]"
		src.cooldowns = list()

		if (mentors.Find(ckey(src.key)))
			src.mentor = 1

		if (src.key) //just a safety check!
			src.cache_round_stats()

	/// queries api to cache stats so its only done once per player per round (please update this proc when adding more player stat vars)
	proc/cache_round_stats()
		var/list/response = null
		try
			response = apiHandler.queryAPI("playerInfo/get", list("ckey" = ckey(src.key)), forceResponse = 1)
		catch
			return 0
		if (!response)
			return 0
		src.rounds_participated = text2num(response["participated"])
		src.rounds_seen = text2num(response["seen"])
		return 1

	/// returns an assoc list of cached player stats (please update this proc when adding more player stat vars)
	proc/get_round_stats()
		if ((isnull(src.rounds_participated) || isnull(src.rounds_seen))) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
		else
			return list("participated" = src.rounds_participated, "seen" = src.rounds_seen)

	/// returns the number of rounds that the player has played by joining in at roundstart
	proc/get_rounds_participated()
		if (isnull(src.rounds_participated)) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
		else
			return src.rounds_participated

	/// returns the number of rounds that the player has at least joined the lobby in
	proc/get_rounds_seen()
		if (isnull(src.rounds_seen)) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
		else
			return src.rounds_seen

/// returns a reference to a player datum based on the ckey you put into it
/proc/find_player(key)
	var/datum/player/player = locate("player-[ckey(key)]")
	return player

/// returns a reference to a player datum, but it tries to make a new one if it cant an already existing one (this is how it persists between connections)
/proc/make_player(key)
	var/datum/player/player = find_player(key) // just double check so that we don't get any dupes
	if (!player)
		player = new(key)
	return player
