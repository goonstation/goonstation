var/global/datum/poll_manager/poll_manager = new
/// master poll controller for the server. Caches the results, syncs with api
/datum/poll_manager
	var/list/poll_data

	/// fetch and cache the latest poll data from the API
	proc/sync_polldata()
		var/datum/http_request/request = new
		var/list/headers = list(
			"Accept" = "application/json",
			"Authorization" = config.goonhub_api_token
		)
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.goonhub_api_endpoint]/api/polls", null, headers)
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()
		if (rustg_json_is_valid(response.body))
			poll_data = json_decode(response.body)


