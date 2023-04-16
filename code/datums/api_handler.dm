/*
* Handles queries to the goonhub universal API
*/

var/global/datum/apiHandler/apiHandler

/datum/apiHandler
	var/enabled = 1 //is the api handler available for use? only set to false if we try a bunch of times and still fail
	//retry handling
	var/maxApiRetries = 5 //how many times should a query attempt to run before giving up
	var/apiRetryDelay = 10 //base delay between query attempts, gets multiplied by attempt number

	var/emergency_shutoff_counter = 0 // how many api errors there have been since a successful one
	var/lazy_concurrent_counter = 0 // lazy count of how many are up/down
	var/lazy_waiting_counter = 0 // number of how many are waiting

	New()
		..()
		if (!config.goonhub_api_endpoint)
			src.enabled = 0
			logTheThing(LOG_DEBUG, null, "Goonhub endpoint doesn't exist, disabled api handler")
			logTheThing(LOG_DIARY, null, "Goonhub endpoint doesn't exist, disabled api handler", "debug")


	// Suppress errors on local environments, as it's spammy and local devs probably won't have the config for API connectivity to work
	proc/apiError(message = "", forceErrorException = 0)
		if (config.server_id != "local" || forceErrorException)
			throw EXCEPTION(message)


	/**
	 * Retries an API query in the event of failure
	 *
	 * @givenArgs (list) arglist of the failed query attempt
	 * @attempt (int) number of times we've attempted this query
	 * @return (*) the result of another query attempt
	 */
	proc/retryApiQuery(list/givenArgs, attempt = 1)
		//the sleep delay grows as attempts increases
		sleep(apiRetryDelay * attempt)
		//arglist() doesnt recognise named params lol
		givenArgs[4] = attempt + 1
		return src.queryAPI(arglist(givenArgs))


	/**
	 * Increments or resets the recent error counter
	 *
	 * @reset (bool) reset the counter (eg successful request)
	 */
	proc/trackRecentError(reset = 0)
		if (reset)
			emergency_shutoff_counter = 0
			return

		emergency_shutoff_counter++
		if (enabled && emergency_shutoff_counter > 50)
			logTheThing(LOG_DEBUG, null, "DISABLING API REQUESTS - Too many errors.")
			logTheThing(LOG_DIARY, null, "DISABLING API REQUESTS - Too many errors.", "debug")
			message_admins("API requests have been disabled due to too many errors (check logs).")
			enabled = 0
			SPAWN(60 SECONDS)
				emergency_shutoff_counter = 0
				logTheThing(LOG_DEBUG, null, "RE-ENABLING API REQUESTS - Cooldown expired.")
				logTheThing(LOG_DIARY, null, "RE-ENABLING API REQUESTS - Cooldown expired.", "debug")
				message_admins("API requests have been re-enabled after waiting.")
				enabled = 1
		return


	/**
	 * Constructs a query to send to the goonhub web API
	 *
	 * @route (string) requested route e.g. bans/check
	 * @query (list) query arguments to be passed along to route
	 * @forceResponse (boolean) will force the API server to return the requested data from the route rather than hitting hubCallback later on
	 * @attempt (int) number of times we've attempted this query
	 * @return (list|boolean) list containing parsed data response from api, 1 if forceResponse is false
	 *
	 */
	proc/queryAPI(route = "", query = list(), forceResponse = 0, attempt = 1, forceErrorException = 0)
		if (!enabled || !route)
			src.apiError("API Error: Cancelled query due to [!enabled ? "disabled apiHandler" : "missing route parameter"]", forceErrorException)
			return

		var/req = "[config.goonhub_api_endpoint]/[route]/?[query ? "[list2params(query)]&" : ""]" //Necessary
		req += "[forceResponse ? "bypass=1&" : ""]" //Force a response RIGHT NOW y/n
		req += "data_server=[serverKey]&data_id=[config.server_id]&" //Append server number and ID
		req += "data_version=[config.goonhub_api_version]&" //Append API version
		var/safeReq = req //for outputting errors without the auth code
		req += "auth=[md5(config.goonhub_api_token)]" //Append auth code

		lazy_waiting_counter++
		while (lazy_concurrent_counter > 50)
			// if we have too many requests out, just wait a little to let some finish
			sleep(rand(1, 5))
		lazy_waiting_counter--


		// Fetch via HTTP from goonhub
		lazy_concurrent_counter++
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, req, "", "")
		request.begin_async()
		var/time_started = TIME
		UNTIL(request.is_complete() || (TIME - time_started) > 10 SECONDS)
		if(!request.is_complete())
			// to whoever looks at this next: uhh, do we have to do any cleanup of
			// these requests or will it just solve itself?
			trackRecentError()
			logTheThing(LOG_DEBUG, null, "<b>API Error</b>: Request timed out during <b>[safeReq]</b> (Attempt: [attempt]; recent errors: [emergency_shutoff_counter], concurrent: [lazy_concurrent_counter])")
			logTheThing(LOG_DIARY, null, "API Error: Request timed out during [safeReq] (Attempt: [attempt]; recent errors: [emergency_shutoff_counter], concurrent: [lazy_concurrent_counter])", "debug")

			// This one is over so we can clear it now
			lazy_concurrent_counter--
			if (attempt < maxApiRetries)
				return retryApiQuery(args, attempt = attempt)

			src.apiError("API Error: Request timed out during [safeReq]")
			return 1

		// Otherwise the request did finish so we can lower this
		lazy_concurrent_counter--
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			trackRecentError()
			logTheThing(LOG_DEBUG, null, "<b>API Error</b>: No response from server during query [!response.body ? "during" : "to"] <b>[safeReq]</b> (Attempt: [attempt]; recent errors: [emergency_shutoff_counter], concurrent: [lazy_concurrent_counter])")
			logTheThing(LOG_DIARY, null, "API Error: No response from server during query [!response.body ? "during" : "to"] [safeReq] (Attempt: [attempt]; recent errors: [emergency_shutoff_counter], concurrent: [lazy_concurrent_counter])", "debug")

			if (attempt < maxApiRetries)
				return retryApiQuery(args, attempt = attempt)

			src.apiError("API Error: No response from server during query [!response.body ? "during" : "to"] [safeReq]")

		// At this point we assume the request was a success, so reset the error counter
		trackRecentError(TRUE)

		if (forceResponse)
			// Parse the response
			var/list/data = json_decode(response.body)

			if (!data)
				logTheThing(LOG_DEBUG, null, "<b>API Error</b>: JSON decode error during <b>[safeReq]</b> (Attempt: [attempt]; recent errors: [emergency_shutoff_counter], concurrent: [lazy_concurrent_counter])")
				logTheThing(LOG_DIARY, null, "API Error: JSON decode error during [safeReq] (Attempt: [attempt]; recent errors: [emergency_shutoff_counter], concurrent: [lazy_concurrent_counter])", "debug")

				if (attempt < maxApiRetries)
					return retryApiQuery(args, attempt = attempt)

				src.apiError("API Error: JSON decode error during [safeReq]")

			return data
		return 1
