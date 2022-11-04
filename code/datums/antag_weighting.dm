/*
* A system for picking players to be antags based on their previous picks
* Designed to give those who never get picked for antag a greater chance
*/

var/global/datum/antagWeighter/antagWeighter

/datum/antagWeighter
	var/debug = 0 //print a shit load of debug messages or not
	var/variance = 100 //percentage probability *per choice* to ignore weighting for a single antag role (instead picking some random dude)
	var/minPlayed = 5 //minimum amount of rounds participated in required for the antag weighter to consider a person a valid choice


	New(debugMode)
		..()
		src.debug = debugMode ? debugMode : 0


	proc/debugLog(msg)
		out(world, msg)
		//logTheThing(LOG_DEBUG, null, "<b>AntagWeighter</b> [msg]")


	/**
	 * Queries the goonhub API for hisorical antag rounds for a single target
	 * NOTE: Currently unused
	 *
	 * @param string role Name of the antag role we're looking up (e.g. traitor, spy_thief)
	 * @param string ckey Ckey of the person we're looking up
	 * @return list List of history details
	 */
	proc/history(role = "", ckey = "")
		if (!role || !ckey)
			throw EXCEPTION("Incorrect parameters given")

		var/list/response = apiHandler.queryAPI("antags/history", list(
			"role" = role,
			"players" = ckey,
			"amount" = 1
		), 1)

		if (response["error"])
			throw EXCEPTION(response["error"])

		return response["history"]

	/**
	* Get the entire antag selection history for a player (all roles, all modes)
	*
	* @param string ckey Ckey of the person we're looking up
	* @return list List of history details
	*/
	proc/completeHistory(ckey = "")
		if (!ckey)
			throw EXCEPTION("No ckey given")
		if (!config.goonhub_api_token)
			throw EXCEPTION("You must have the goonhub API token to use this command!")

		var/list/response
		try
			response = apiHandler.queryAPI("antags/completeHistory", list(
				"player" = ckey,
			), 1)
		catch ()
			throw EXCEPTION("API is currently having issues, try again later")

		if (response["error"])
			throw EXCEPTION(response["error"])

		if (length(response["history"]) < 1)
			throw EXCEPTION("No history for that player")

		return response["history"]

	/**
	 * Simulates a history response from the API, so local development doesn't fuck up
	 *
	 * @param string role Name of the antag role we're looking up (e.g. traitor, spy_thief)
	 * @param list ckeyMinds List of minds keyed by ckeys
	 * @return list Simulated response
	 */
	proc/simulateHistory(role = "", list/ckeyMinds = list())
		var/list/response = list(
			"role" = role,
			"history" = list()
		)

		for (var/ckey in ckeyMinds)
			response["history"][ckey] = list(
				"selected" = 1,
				"seen" = 1
			)

		return response


	/**
	 * Queries the goonhub API for hisorical antag rounds for the pool of minds given
	 *
	 * @param string role Name of the antag role we're picking for (e.g. traitor, spy_thief)
	 * @param list history List of historical antag data returned by the goonhub API
	 * @return list List ckeys sorted by weight (highest weight first)
	 */
	proc/calculateWeightings(role = "", list/history = list())
		if (!role)
			throw EXCEPTION("No role given")

		if (!history.len)
			throw EXCEPTION("Empty history given")

		var/poolSize = length(history)
		var/targetPlayRate = config.play_antag_rates[role]
		var/list/weightings = list()

		//calculate our weightings
		for (var/ckey in history)
			var/list/details = history[ckey]
			var/selected = text2num(details["selected"]) //amount of times selected for antag role in given round type
			var/seen = text2num(details["seen"]) //amount of times seen in given round type
			var/weight

			//players never selected and above min played get highest weightings
			if (!selected && seen >= minPlayed)
				if (src.debug)
					src.debugLog("(Weighting Calc) [ckey] has no selections and [seen] participations. Applying max weight.")

				weight = INFINITY

			//new players below the min played requirement get lowest weightings
			else if (seen < minPlayed)
				if (src.debug)
					src.debugLog("(Weighting Calc) [ckey] has too few participations ([seen]). Applying min weight.")

				weight = 0

			//the lower % of rounds played as antag role in given round type, the higher weighting given
			else
				var/percentSelected = (selected / seen) * 100
				weight = (targetPlayRate * poolSize) / percentSelected

				if (src.debug)
					src.debugLog("(Weighting Calc) [ckey] has [selected] selections and [seen] participations. Calculated weight as [weight] (poolSize: [poolSize]).")

			//insert the weighted entry in the right place
			var/inserted = 0
			for (var/wCkey in weightings)
				if (weight >= weightings[wCkey]["weight"]) //highest weights first
					var/existingIndex = weightings.Find(wCkey)
					weightings.Insert(existingIndex, ckey)
					weightings[ckey] = list("weight" = weight, "seen" = seen)
					inserted = 1
					break

			//couldn't find a place for this entry, shove it on the end
			if (!inserted)
				weightings.Insert(0, ckey)
				weightings[ckey] = list("weight" = weight, "seen" = seen)

		return weightings


	/**
	 * Queries the goonhub API for hisorical antag rounds for the pool of minds given
	 * Returns a list of minds that haevn't played up to the percentage of antag rounds defined in config
	 *
	 * @param list pool List of minds under consideration for antag picking
	 * @param string role Name of the antag role we're picking for (e.g. traitor, spy_thief)
	 * @param int amount Max amount of players to choose for this role
	 * @param boolean recordChosen When true, triggers a src.recordMultiple() for the chosen players
	 * @return list List of minds chosen
	 */
	proc/choose(list/pool = list(), role = "", amount = 0, recordChosen = 0)
		. = list()
		if (!length(pool))
			stack_trace("Incorrect parameters given to antagWeighter.choose(): Pool is empty.")
			return
		if (!role)
			stack_trace("Incorrect parameters given to antagWeighter.choose(): No rank provided.")
			return
		if (!amount)
			stack_trace("Incorrect parameters given to antagWeighter.choose(): Requested antag amount is 0.")
			return

		if (src.debug)
			src.debugLog("---------- Starting antagWeighter.choose with role: [role] and amount: [amount] ----------")

		var/list/apiPayload = list(
			"role" = role,
			"mode" = ticker.mode.name
		)

		//Build a couple lists for sending to the API and for easy lookup after
		var/pCount = 0
		var/list/ckeyMinds = list()
		for (var/datum/mind/M in pool)
			if (M.ckey)
				apiPayload["players\[[pCount]]"] = M.ckey
				ckeyMinds[M.ckey] = M
				pCount++

		if (!ckeyMinds.len)
			throw EXCEPTION("No minds with valid ckeys were given")

		logTheThing(LOG_DEBUG, null, "<b>AntagWeighter</b> Selecting [amount] out of [ckeyMinds.len] candidates for [role].")

		if (src.debug)
			src.debugLog("Sending payload: [json_encode(apiPayload)]")

		var/list/response
		if (config.goonhub_api_token && apiHandler.enabled)
			//YO API WADDUP
			try
				response = apiHandler.queryAPI("antags/history", apiPayload, 1)
			catch ()
				//If the API is in the process of failing, we need to gracefully fail so that SOME antags can be picked
				response = src.simulateHistory(role, ckeyMinds)

		else
			//Fallback for no API set, for local dev (or API is unavailable)
			response = src.simulateHistory(role, ckeyMinds)

		if (response && response["error"])
			throw EXCEPTION(response["error"])

		var/list/history = response["history"]

		if (src.debug)
			src.debugLog("History returned: [json_encode(history)]")

		history = src.calculateWeightings(role, history)

		//Set up segmented list for variance
		var/list/historyLookup = list()
		historyLookup = history.Copy()

		//Build our final list of chosen people, to the max of "amount"
		var/cCount = 0
		var/list/chosen = list()
		for (var/ckey in history)
			cCount++
			var/cckey
			var/weight
			var/seen

			//Variance triggered, go pick a random player
			if (historyLookup.len && prob(src.variance))
				cckey = pick(historyLookup)
				weight = historyLookup[cckey]["weight"]
				seen = historyLookup[cckey]["seen"]
				historyLookup -= cckey

				if (src.debug)
					src.debugLog("Variance triggered, overriding pick with: [cckey]")

			//Normal weighted pick
			else
				cckey = ckey
				weight = history[ckey]["weight"]
				seen = history[ckey]["seen"]

			chosen[ckeyMinds[cckey]] = list("weight" = weight, "seen" = seen)

			if (cCount >= amount)
				break

		if (src.debug)
			src.debugLog("Final chosen list: [json_encode(chosen)]")
			src.debugLog("---------- Ending antagWeighter.choose ----------")

		//Shortcut to record selection for players chosen
		if (recordChosen)
			var/list/record = list()
			for (var/datum/mind/M in chosen)
				record[M.ckey] = role
				logTheThing(LOG_DEBUG, null, "<b>AntagWeighter</b> Selected [M.ckey] for [role]. (Weight: [chosen[M]["weight"]], Seen: [chosen[M]["seen"]])")
			for (var/datum/mind/M in pool)
				if(!M.ckey)
					continue
				if(M in chosen)
					continue
				logTheThing(LOG_DEBUG, null, "<b>AntagWeighter</b> Did <b>not</b> select [M.ckey] for [role]. (Weight: [history[M.ckey]["weight"]], Seen: [history[M.ckey]["seen"]])")


			src.recordMultiple(players = record)

		return chosen


	/**
	 * Records an antag selection for a single player
	 *
	 * @param string role Name of the antag role we're recording a selection for
	 * @param string ckey Ckey of the player
	 * @param boolean latejoin Whether this record is a latejoin antag selection
	 * @return null
	 */
	proc/record(role = "", ckey = "", latejoin = 0)
		if (!role || !ckey)
			throw EXCEPTION("Incorrect parameters given")

		if (src.debug)
			src.debugLog("Recording selection of role: [role] for ckey: [ckey]. latejoin: [latejoin]")

		//Fire and forget
		apiHandler.queryAPI("antags/record", list(
			"role" = role,
			"players" = ckey,
			"latejoin" = latejoin
		))


	/**
	 * Records multiple antag selections at once, reduces API usage
	 *
	 * @param list players Specially formatted list of players to record selection for. e.g.
	 * 		players = list(
	 *			"ckeyforadude1" = "traitor",
	 *			"ckeyforadude2" = "wraith"
	 * 		)
	 * @return null
	 */
	proc/recordMultiple(list/players = list())
		if (!players.len)
			throw EXCEPTION("Incorrect parameters given")

		if (src.debug)
			src.debugLog("Recording multiple selections for: [json_encode(players)]")

		//Build an API-friendly list of players
		var/list/apiPlayers = list()
		var/count = 0
		for (var/ckey in players)
			apiPlayers["players\[[count]]\[role]"] = players[ckey]
			apiPlayers["players\[[count]]\[ckey]"] = ckey
			count++

		if (src.debug)
			src.debugLog("Players list sending to API: [json_encode(apiPlayers)]")

		//Fire and forget
		apiHandler.queryAPI("antags/record", apiPlayers)


world/New()
	. = ..()
	antagWeighter = new()
	//antagWeighter = new(1) //Enables debug mode
