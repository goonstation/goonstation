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
	/// how many rounds (total) theyve declared ready and joined, null with to differentiate between not set and no participation
	var/rounds_participated = null
	/// how many rounds (rp only) theyve declared ready and joined, null with to differentiate between not set and no participation
	var/rounds_participated_rp = null
	/// how many rounds (total) theyve joined to at least the lobby in, null to differentiate between not set and not seen
	var/rounds_seen = null
	/// how many rounds (rp only) theyve joined to at least the lobby in, null to differentiate between not set and not seen
	var/rounds_seen_rp = null
	/// timestamp of when they were last seen
	var/last_seen = null
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
	/// buildmode holder of our client so it doesn't need to get rebuilt every time we reconnect
	var/datum/buildmode_holder/buildmode = null

	/// sets up vars, caches player stats, adds by_type list entry for this datum
	New(key)
		..()
		START_TRACKING
		src.key = key
		src.ckey = ckey(key)
		src.tag = "player-[src.ckey]"

		if (ckey(src.key) in mentors)
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
		src.rounds_participated_rp= text2num(response["participated_rp"])
		src.rounds_seen = text2num(response["seen"])
		src.rounds_seen_rp = text2num(response["seen_rp"])
		src.last_seen = response["last_seen"]
		return 1

	/// returns an assoc list of cached player stats (please update this proc when adding more player stat vars)
	proc/get_round_stats()
		if ((isnull(src.rounds_participated) || isnull(src.rounds_seen) || isnull(src.rounds_participated_rp) || isnull(src.rounds_seen_rp) || isnull(src.last_seen))) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
		return list("participated" = src.rounds_participated, "seen" = src.rounds_seen, "participated_rp" = src.rounds_participated_rp, "seen_rp" = src.rounds_seen_rp, "last_seen" = src.last_seen)

	/// returns the number of rounds that the player has played by joining in at roundstart
	proc/get_rounds_participated()
		if (isnull(src.rounds_participated)) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
		return src.rounds_participated

	proc/get_rounds_participated_rp()
		if (isnull(src.rounds_participated_rp)) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
		return src.rounds_participated_rp

	/// returns the number of rounds that the player has at least joined the lobby in
	proc/get_rounds_seen()
		if (isnull(src.rounds_seen)) //if the stats havent been cached yet
			if (!src.cache_round_stats()) //if trying to set them fails
				return null
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

#ifdef LIVE_SERVER
		// Via rust-g HTTP
		var/datum/http_request/request = new() //If it fails, oh well...
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/cloudsave?dataput&api_key=[config.spacebee_api_key]&ckey=[ckey]&key=[url_encode(key)]&value=[url_encode(clouddata[key])]", "", "")
		request.begin_async()
#else
		var/json = null
		var/list/decoded_json
		if (fexists("data/simulated_cloud.json"))
			json = file2text("data/simulated_cloud.json")
			decoded_json = json_decode(json)
		else
			decoded_json = list()

		decoded_json["[ckey(ckey)]"] = clouddata
		//t2f appends, but need to to replace
		fdel("data/simulated_cloud.json")
		text2file(json_encode(decoded_json),"data/simulated_cloud.json")
#endif
		return TRUE // I guess

	/// Sets a cloud key value pair and sends it to goonhub for a target ckey
	proc/cloud_put_target(target, key, value)
		var/list/data = cloud_fetch_target_ckey(target)
		if(!data)
			return FALSE
		data[key] = "[json_encode(value)]"

#ifdef LIVE_SERVER
		// Via rust-g HTTP
		var/datum/http_request/request = new() //If it fails, oh well...
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/cloudsave?dataput&api_key=[config.spacebee_api_key]&ckey=[ckey(target)]&key=[url_encode(key)]&value=[url_encode(data[key])]", "", "")
		request.begin_async()
#else
		var/json = null
		var/list/decoded_json
		if (fexists("data/simulated_cloud.json"))
			json = file2text("data/simulated_cloud.json")
			decoded_json = json_decode(json)
		else
			decoded_json = list()
		decoded_json["[ckey(target)]"] = data
		//t2f appends, but need to to replace
		fdel("data/simulated_cloud.json")
		text2file(json_encode(decoded_json),"data/simulated_cloud.json")
#endif
		return TRUE // I guess

	/// Returns some cloud data on the client
	proc/cloud_get( var/key )
		return clouddata ? clouddata[key] : null

	/// Returns some cloud data on the provided target ckey
	proc/cloud_get_target(target, key)
		var/list/data = cloud_fetch_target_data_only(target)
		return data ? data[key] : null

	/// Returns 1 if you can set or retrieve cloud data on the client
	proc/cloud_available()
		return !!clouddata

	/// Downloads cloud data from goonhub
	proc/cloud_fetch()
		var/list/data = cloud_fetch_target_ckey(src.ckey)
		if (data)
#ifdef LIVE_SERVER
			cloudsaves = data["saves"]
			clouddata = data["cdata"]
#else
			clouddata = data
#endif
			return TRUE

	/// Refreshes clouddata
	proc/cloud_fetch_data_only()
		var/list/data = cloud_fetch_target_data_only(src.ckey)
		if (data)
			clouddata = data
			return TRUE

	/// returns the clouddata of a target ckey in list form
	proc/cloud_fetch_target_data_only(target)
		var/list/data = cloud_fetch_target_ckey(target)
		if (data)
			return data["cdata"]

	/// returns the cloudsaves of a target ckey in list form
	proc/cloud_fetch_target_saves_only(target)
		var/list/data = cloud_fetch_target_ckey(target)
		if (data)
			return data["saves"]

	/// Returns cloud data and saves from goonhub for the target ckey in list form
	proc/cloud_fetch_target_ckey(target)
#ifdef LIVE_SERVER
		if(!cdn) return
		target = ckey(target)
		if (!target) return

		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/cloudsave?list&ckey=[target]&api_key=[config.spacebee_api_key]", "", "")
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			logTheThing(LOG_DEBUG, target, "failed to have their cloud data loaded: Couldn't reach Goonhub")
			return

		var/list/ret = json_decode(response.body)
		if(ret["status"] == "error")
			logTheThing(LOG_DEBUG, target, "failed to have their cloud data loaded: [ret["error"]["error"]]")
			return
		else
			return ret
#else
		if (!target) return
		/// holds our json string
		var/json
		/// holds our list made from decoding json
		var/list/decoded_json
		// make sure the files actually exists before we try to read it, if it doesn't then just return a blank list to work with
		if (fexists("data/simulated_cloud.json"))
			// file was found, lets decode it
			json = file2text("data/simulated_cloud.json")
			decoded_json = json_decode(json)
		else
			decoded_json = list()

		// do we have an entry for the target ckey?
		if (decoded_json[target])
			return decoded_json[target]
		else
			// we need to return a list with a list in the cdata index or it causes a deadlock where we can't save
			return list(cdata = list())
#endif

	proc/get_buildmode()
		RETURN_TYPE(/datum/buildmode_holder)
		if(src.buildmode)
			return src.buildmode
		var/saved_buildmode = src.cloud_get("buildmode")
		if(!saved_buildmode)
			src.buildmode = new /datum/buildmode_holder(src.client)
		else
			var/savefile/save = new
			save.ImportText("/", saved_buildmode)
			save.eof = 0
			try
				save["buildmode"] >> src.buildmode
			catch(var/exception/e)
				stack_trace("loading buildmode error\n[e.name]\n[e.desc]")
				boutput(src.client, "<span class='internal'>Loading your buildmode failed. Check runtime log for details.</span>")
				qdel(src.buildmode)
				src.buildmode = new /datum/buildmode_holder(src.client)
			if(isnull(src.buildmode))
				boutput(src.client, "<span class='internal'>Loading your buildmode failed. No clue why.</span>")
				src.buildmode = new /datum/buildmode_holder(src.client)
			if(isnull(src.buildmode.owner))
				src.buildmode.set_client(src.client)
		return src.buildmode

	proc/on_round_end()
		if(src.buildmode)
			var/savefile/S = new
			S["buildmode"] << buildmode
			src.cloud_put("buildmode", S.ExportText())

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

/** Bulk cloud save for saving many key value pairs and/or many ckeys in a single api call
 * example input (formatted for readability)
 *  command add adds a number onto the current value (record must exist in the cloud to update or it won't do anything)
 *  command replace overwrites the existing record
 * 	{
 * 		"some_ckey":{
 * 			"persistent_bank":{
 * 				"command":"add",
 * 				"value":42069
 * 			},
 * 			"persistent_bank_item":{
 * 				"command":"replace",
 * 				"value":"none"
 * 			}
 * 		},
 * 		"some_other_ckey":{
 * 			"persistent_bank":{
 * 				"command":"add",
 * 				"value":1337
 * 			},
 * 			"persistent_bank_item":{
 * 				"command":"replace",
 * 				"value":"rubber_ducky"
 * 			}
 * 		}
 * 	}
**/
proc/cloud_put_bulk(json)
	if (!rustg_json_is_valid(json))
		stack_trace("cloud_put_bulk received an invalid json object.")
		return FALSE
	var/list/decoded_json = json_decode(json)
	var/list/sanitized = list()
	for (var/json_ckey in decoded_json)
		var/clean_ckey = ckey(json_ckey)
		if (!length(decoded_json[json_ckey]))
			stack_trace("cloud_put_bulk received ckey \"[clean_ckey]\" without any key pairs to save.")
			continue
		sanitized[clean_ckey] = list()
		for (var/json_key in decoded_json[json_ckey])
			var/value = decoded_json[json_ckey][json_key]["value"]
			if (isnull(value))
				value = "" //api wants empty strings, not nulls
			sanitized[clean_ckey][json_key] = list ("command" = decoded_json[json_ckey][json_key]["command"], "value" = value)
#ifdef LIVE_SERVER
	var/sanitized_json = json_encode(sanitized)
	// Via rust-g HTTP
	var/datum/http_request/request = new()
	var/list/headers = list(
		"Authorization" = "[config.spacebee_api_key]",
		"Content-Type" = "application/json",
		"Command" = "dataput_bulk"
	)
	request.prepare(RUSTG_HTTP_METHOD_POST, "[config.spacebee_api_url]/api/cloudsave", sanitized_json, headers)
	request.begin_async()
#else
// temp disabled
/* 		var/save_json
	var/list/decoded_save
	if (fexists("data/simulated_cloud.json"))
		save_json = file2text("data/simulated_cloud.json")
		decoded_save = json_decode(save_json)
	else
		decoded_save = list()

	for (var/sani_ckey in sanitized)
		if (!decoded_save[sani_ckey])
			decoded_save[sani_ckey] = list(cdata = list())
		for (var/data_key in sanitized[sani_ckey])
			decoded_save[sani_ckey]["cdata"][data_key] = sanitized[sani_ckey][data_key]

	//t2f appends, but need to to replace
	fdel("data/simulated_cloud.json")
	text2file(json_encode(decoded_save),"data/simulated_cloud.json") */
#endif
	return TRUE
