

var/global/datum/apiHandler/apiHandler

/**
 * Handles queries to the Goonhub APIv2
 */
/datum/apiHandler
	/// Is the api handler available for use? only set to false if we try a bunch of times and still fail
	var/enabled = TRUE
	/// Is debug logging on? If true, detailed logs for each API request will be logged to debug
	var/debug = FALSE

	/// how many times should a query attempt to run before giving up
	var/maxApiRetries = 1 //5
	/// base delay between query attempts, gets multiplied by attempt number
	var/apiRetryDelay = 10

	/// how many api errors there have been since a successful one
	var/emergency_shutoff_counter = 0
	/// lazy count of how many are up/down
	var/lazy_concurrent_counter = 0
	/// number of how many are waiting
	var/lazy_waiting_counter = 0

	New()
		..()
		if (!config.goonhub_api_endpoint)
			src.enabled = FALSE
			logTheThing(LOG_DEBUG, null, "<b>API Error</b>: Goonhub endpoint doesn't exist, disabled api handler")
			logTheThing(LOG_DIARY, null, "API Error: Goonhub endpoint doesn't exist, disabled api handler", "debug")


	/// Build and throw an error exception
	proc/apiError(list/data, source)
		var/datum/apiModel/Error/model = new
		model.SetupFromResponse(data)
		throw EXCEPTION(model)


	/**
	 * Retries an API query in the event of failure
	 *
	 * @route (/datum/apiRoute) requested route to call, ex. /datum/apiRoute/players/notes/get
	 * @attempt (int) number of times we've attempted this query
	 * @return (/datum/apiModel) model containing parsed data response from api
	 */
	proc/retryApiQuery(datum/apiRoute/route, attempt)
		//the sleep delay grows as attempts increases
		sleep(src.apiRetryDelay * attempt)
		attempt++
		return src.queryAPI(route, attempt)


	/**
	 * Log an API request
	 *
	 * @method (string) HTTP method of the request
	 * @route (string) URL of the request
	 * @body (string) JSON encoded body of the request if applicable
	 */
	proc/debugLogRequest(method, route, body)
		var/msg = "([method]) [route]<br>[body]"
		logTheThing(LOG_DEBUG, null, "<b>API DEBUG (Request):</b> [msg]")
		logTheThing(LOG_DIARY, null, "API DEBUG (Request): [msg]", "debug")

	/**
	 * Log an API response
	 *
	 * @method (string) HTTP method of the request
	 * @route (string) URL of the request
	 * @body (string) JSON encoded body of the response
	 * @headers (list) Response headers
	 * @status (int) Response status code
	 */
	proc/debugLogResponse(method, route, body, headers, status)
		if (headers && islist(headers)) headers = json_encode(headers)
		var/msg = "([method]) [route]<br><b>Status:</b> [status]<br><b>Headers:</b> [headers]<br><b>Body:</b> [body]"
		logTheThing(LOG_DEBUG, null, "<b>API DEBUG (Response):</b> [msg]")
		logTheThing(LOG_DIARY, null, "API DEBUG (Response): [msg]", "debug")


	/**
	 * Increments or resets the recent error counter
	 *
	 * @reset (bool) reset the counter (eg successful request)
	 */
	proc/trackRecentError(reset = FALSE)
		if (reset)
			src.emergency_shutoff_counter = 0
			return

		src.emergency_shutoff_counter++
		if (src.enabled && src.emergency_shutoff_counter > 50)
			logTheThing(LOG_DEBUG, null, "DISABLING API REQUESTS - Too many errors.")
			logTheThing(LOG_DIARY, null, "DISABLING API REQUESTS - Too many errors.", "debug")
			message_admins("API requests have been disabled due to too many errors (check debug logs).")
			src.enabled = 0
			SPAWN(60 SECONDS)
				src.emergency_shutoff_counter = 0
				logTheThing(LOG_DEBUG, null, "RE-ENABLING API REQUESTS - Cooldown expired.")
				logTheThing(LOG_DIARY, null, "RE-ENABLING API REQUESTS - Cooldown expired.", "debug")
				message_admins("API requests have been re-enabled after waiting.")
				src.enabled = 1

	/**
	 * Constructs a query to send to the goonhub web API
	 *
	 * @route (/datum/apiRoute) requested route to call, ex. /datum/apiRoute/players/notes/get
	 * @attempt (int) number of times we've attempted this query
	 * @return (/datum/apiModel|boolean) model containing parsed data response from api, or boolean indicating success
	 *
	 */
	proc/queryAPI(datum/apiRoute/route = null, attempt = 1)
		if (!enabled)
			src.apiError(list("message" = "API Error: Cancelled query due to disabled apiHandler"))
			return FALSE
		if (!route)
			src.apiError(list("message" = "API Error: Cancelled query due to missing route parameter"))
			return FALSE

		var/req_route = "[config.goonhub_api_endpoint][route.path][route.routeParams ? "/[route.formatRouteParams()]" : ""]/?[route.formatQueryParams()]"
		var/headers = list(
			"Accept" = "application/json",
			"Content-Type" = "application/json",
			"Authorization" = config.goonhub_api_token
		)

		src.lazy_waiting_counter++
		while (src.lazy_concurrent_counter > 50)
			// if we have too many requests out, just wait a little to let some finish
			sleep(rand(1, 5))
		src.lazy_waiting_counter--
		src.lazy_concurrent_counter++

		// Actual request
		var/datum/http_request/request = new()
		var/req_body = route.body ? route.body.toJson() : ""
		request.prepare(route.method, req_route, req_body, headers, "")
		request.begin_async()
		if (src.debug) src.debugLogRequest(route.method, req_route, req_body)
		var/time_started = TIME
		var/time_started_unix = rustg_unix_timestamp()
		UNTIL(request.is_complete() || (TIME - time_started) > 10 SECONDS)
		if (!request.is_complete())
			src.trackRecentError()
			var/msg = "Request timed out during [req_route] (Attempt: [attempt]; recent errors: [src.emergency_shutoff_counter], concurrent: [src.lazy_concurrent_counter])"
			logTheThing(LOG_DEBUG, null, "<b>API Error</b>: [msg]")
			logTheThing(LOG_DIARY, null, "API Error: [msg]", "debug")

			// Temp logging for timeouts
			world.log << "(TEMP) API Error: Request timed out for: [req_route]. Time diff: [TIME - time_started]. Unix start: [time_started_unix]. Unix end: [rustg_unix_timestamp()]"

			// This one is over so we can clear it now
			src.lazy_concurrent_counter--
			if (route.allow_retry && attempt < src.maxApiRetries)
				return src.retryApiQuery(route, attempt)

			src.apiError(list("message" = "API Error: Request timed out during [req_route]"))
			return FALSE

		// Otherwise the request did finish so we can lower this
		src.lazy_concurrent_counter--
		var/datum/http_response/response = request.into_response()
		var/list/data
		if (src.debug) src.debugLogResponse(route.method, req_route, response.body, response.headers, response.status_code)

		if (response.errored && response.status_code)
			data["message"] = "Status [response.status_code]"
		else if (response.errored && !response.body)
			src.trackRecentError()
			var/msg = "No response from server during query [!response.body ? "during" : "to"] [req_route] (Attempt: [attempt]; recent errors: [src.emergency_shutoff_counter], concurrent: [src.lazy_concurrent_counter])"
			logTheThing(LOG_DEBUG, null, "<b>API Error</b>: [msg]")
			logTheThing(LOG_DIARY, null, "API Error: [msg]", "debug")

			if (route.allow_retry && attempt < src.maxApiRetries)
				return src.retryApiQuery(route, attempt)

			src.apiError(list("message" = "API Error: No response from server during query [!response.body ? "during" : "to"] [req_route]"))

		// At this point we assume the request was a success, so reset the error counter
		src.trackRecentError(TRUE)

		if (!data)
			try
				// Parse the response
				data = json_decode(response.body)
			catch
				// Bad data format
				var/msg = "JSON decode error during [req_route] (Attempt: [attempt]; recent errors: [src.emergency_shutoff_counter], concurrent: [src.lazy_concurrent_counter])"
				logTheThing(LOG_DEBUG, null, "<b>API Error</b>: [msg]")
				logTheThing(LOG_DIARY, null, "API Error: [msg]", "debug")

				if (route.allow_retry && attempt < src.maxApiRetries)
					return src.retryApiQuery(route, attempt)

				src.apiError(list("message" = "API Error: JSON decode error during [req_route]", "status_code" = response.status_code))

		// Handle client and server error responses
		if (response.status_code >= 400)
			data["status_code"] = response.status_code
			src.apiError(data)
			return FALSE

		// Validation
		var/datum/apiModel/model = new route.correct_response
		if (istype(model, /datum/apiModel/Paginated) || istype(model, /datum/apiModel/Message))
			model.SetupFromResponse(data, route)
		else
			model.SetupFromResponse(data["data"], route)
		if (!model.VerifyIntegrity())
			var/msg = "Verification error on response during [req_route] (Attempt: [attempt]; recent errors: [src.emergency_shutoff_counter], concurrent: [src.lazy_concurrent_counter])"
			logTheThing(LOG_DEBUG, null, "<b>API Error</b>: [msg]")
			logTheThing(LOG_DIARY, null, "API Error: [msg]", "debug")
			src.apiError(list("message" = "API Error: Verification error on response during [req_route]"))
			return FALSE

		return model

/client/proc/debug_api_handler()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Debug API Handler"
	set desc = "Toggle debug logging of API requests"
	ADMIN_ONLY
	SHOW_VERB_DESC
	apiHandler.debug = !apiHandler.debug
	if (apiHandler.debug)
		boutput(src, "Enabled debug logging of API requests")
	else
		boutput(src, "Disabled debug logging of API requests")
