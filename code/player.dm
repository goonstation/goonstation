/// for client variables and stuff that has to persist between connections
/datum/player
	/// the key of the client object that this datum is attached to
	var/key
	/// the ckey of the client object that this datum is attached to
	var/ckey
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
	/// position of client in in global.clients
	var/clients_pos = null
	/// the server time that this player joined the game, in 1/10ths of a second
	var/round_join_time = null
	/// the server time that this player left the game, in 1/10ths of a second
	var/round_leave_time = null
	/// the total time that this player has been playing the game this round, in 1/10ths of a second
	var/current_playtime = null
	/// Cache jobbans here to speed things up massively
	var/list/cached_jobbans = null
	/// saved profiles from the cloud
	var/list/cloudsaves = null
	/// saved data from the cloud (spacebux, volume settings, ...)
	var/list/clouddata = null

	/// sets up vars, caches player stats, adds by_type list entry for this datum
	New(key)
		..()
		START_TRACKING
		src.key = key
		src.ckey = ckey(key)
		src.tag = "player-[src.ckey]"

		if (mentors.Find(ckey(src.key)))
			src.mentor = 1

		if (src.key) //just a safety check!
			src.cache_round_stats()

	/// removes by_type list entry for this datum, clears dangling references
	disposing()
		STOP_TRACKING
		if (src.client)
			src.client.player = null
			src.client = null
		..()

	/// queries api to cache stats so its only done once per player per round (please update this proc when adding more player stat vars)
	proc/cache_round_stats()
		var/list/response = null
		try
			response = apiHandler.queryAPI("playerInfo/get", list("ckey" = src.ckey), forceResponse = 1)
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

	/// sets the join time to the current server time, in 1/10ths of a second
	proc/log_join_time()
		src.round_join_time = TIME

	/// sets the leave time to the current server time, in 1/10ths of a second
	proc/log_leave_time()
		src.round_leave_time = TIME
		src.calculate_played_time()

	/// adds the calculated playtime (in 1/10ths of a second) to the playtime variable
	proc/calculate_played_time()
		if (isnull(src.round_join_time) || isnull(src.round_leave_time)) //acts as a safety, in case we call log_leave_time without setting a join time (end of round usually)
			return
		src.current_playtime += (src.round_leave_time - round_join_time)
		src.round_leave_time = null //reset this - null value is important
		src.round_join_time = null //reset this - null value is important

	/// Sets a cloud key value pair and sends it to goonhub
	proc/cloud_put(key, value)
		if(!clouddata)
			return FALSE
		clouddata[key] = "[value]"

		// Via rust-g HTTP
		var/datum/http_request/request = new() //If it fails, oh well...
		request.prepare(RUSTG_HTTP_METHOD_GET, "http://spacebee.goonhub.com/api/cloudsave?dataput&api_key=[config.ircbot_api]&ckey=[ckey]&key=[url_encode(key)]&value=[url_encode(clouddata[key])]", "", "")
		request.begin_async()
		return TRUE // I guess

	/// Returns some cloud data on the client
	proc/cloud_get( var/key )
		return clouddata ? clouddata[key] : null

	/// Returns 1 if you can set or retrieve cloud data on the client
	proc/cloud_available()
		return !!clouddata

	/// Downloads cloud data from goonhub
	proc/cloud_fetch()
		if(!cdn)
			return
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "http://spacebee.goonhub.com/api/cloudsave?list&ckey=[ckey]&api_key=[config.ircbot_api]", "", "")
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			logTheThing("debug", src.key, null, "failed to have their cloud data loaded: Couldn't reach Goonhub")
			return FALSE

		var/list/ret = json_decode(response.body)
		if(ret["status"] == "error")
			logTheThing( "debug", src.key, null, "failed to have their cloud data loaded: [ret["error"]["error"]]" )
			return FALSE
		else
			cloudsaves = ret["saves"]
			clouddata = ret["cdata"]
			return TRUE

/// returns a reference to a player datum based on the ckey you put into it
/proc/find_player(key)
	RETURN_TYPE(/datum/player)
	var/datum/player/player = locate("player-[ckey(key)]")
	return player

/// returns a reference to a player datum, but it tries to make a new one if it cant an already existing one (this is how it persists between connections)
/proc/make_player(key)
	var/datum/player/player = find_player(key) // just double check so that we don't get any dupes
	if (!player)
		player = new(key)
	return player
