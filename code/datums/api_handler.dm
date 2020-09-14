/*
* Handles queries to the goonhub universal API
*/

var/global/datum/apiHandler/apiHandler

/datum/apiHandler
	var/enabled = 1 //is the api handler available for use? only set to false if we try a bunch of times and still fail
	//retry handling
	var/maxApiRetries = 5 //how many times should a query attempt to run before giving up
	var/apiRetryDelay = 10 //base delay between query attempts, gets multiplied by attempt number

	New()
		..()
		if (!config.goonhub_api_endpoint)
			src.enabled = 0
			logTheThing("debug", null, null, "Goonhub endpoint doesn't exist, disabled api handler")
			logTheThing("diary", null, null, "Goonhub endpoint doesn't exist, disabled api handler", "debug")


	// Suppress errors on local environments, as it's spammy and local devs probably won't have the config for API connectivity to work
	proc/apiError(message = "")
		if (config.server_id != "local")
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
		givenArgs[givenArgs.len] = attempt + 1
		return src.queryAPI(arglist(givenArgs))


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
	proc/queryAPI(route = "", query = list(), forceResponse = 0, attempt = 1)
		set background = 1
		if (!enabled || !route)
			src.apiError("API Error: Cancelled query due to [!enabled ? "disabled apiHandler" : "missing route parameter"]")
			return

		var/req = "[config.goonhub_api_endpoint]/[route]/?[query ? "[list2params(query)]&" : ""]" //Necessary
		req += "[forceResponse ? "bypass=1&" : ""]" //Force a response RIGHT NOW y/n
		req += "data_server=[serverKey]&data_id=[config.server_id]&" //Append server number and ID
		req += "data_version=[config.goonhub_api_version]&" //Append API version
		var/safeReq = req //for outputting errors without the auth code
		req += "auth=[md5(config.goonhub_api_token)]" //Append auth code

		var/response[] = world.Export(req)
		if(!response)
			logTheThing("debug", null, null, "<b>API Error</b>: No response from server during query to <b>[safeReq]</b> (Attempt: [attempt])")
			logTheThing("diary", null, null, "API Error: No response from server during query to [safeReq] (Attempt: [attempt])", "debug")

			if (attempt < maxApiRetries)
				return retryApiQuery(args, attempt = attempt)

			src.apiError("API Error: No response from server during query to [safeReq]")

		if (forceResponse)
			var/key
			var/contentExists = 0
			for (key in response)
				if (key == "CONTENT")
					contentExists = 1

			if (!contentExists)
				logTheThing("debug", null, null, "<b>API Error</b>: Malformed response from server during <b>[safeReq]</b> (Attempt: [attempt])")
				logTheThing("diary", null, null, "API Error: Malformed response from server during [safeReq] (Attempt: [attempt])", "debug")

				if (attempt < maxApiRetries)
					return retryApiQuery(args, attempt = attempt)

				src.apiError("API Error: Malformed response from server during [safeReq]")

			//Parse the response
			var/list/data = json_decode(file2text(response["CONTENT"]))

			if (!data)
				logTheThing("debug", null, null, "<b>API Error</b>: JSON decode error during <b>[safeReq]</b> (Attempt: [attempt])")
				logTheThing("diary", null, null, "API Error: JSON decode error during [safeReq] (Attempt: [attempt])", "debug")

				if (attempt < maxApiRetries)
					return retryApiQuery(args, attempt = attempt)

				src.apiError("API Error: JSON decode error during [safeReq]")

			return data

		return 1
