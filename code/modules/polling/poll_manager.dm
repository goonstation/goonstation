var/global/datum/poll_manager/poll_manager = new
/// master poll controller for the server. Caches the results, syncs with api
/datum/poll_manager
	var/list/poll_data = list()

	/// fetch and cache the latest poll data from the API
	proc/sync_polldata()
		set waitfor = FALSE
		var/datum/apiModel/Paginated/PollResourceList/polls
		try
			var/datum/apiRoute/polls/get/getPolls = new
			getPolls.queryParams = list(
				"filters" = list(
					//"active" = "true",
					"servers" = list(config.server_id)
				)
			)
			polls = apiHandler.queryAPI(getPolls)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			logTheThing(LOG_DEBUG, null, "Failed to fetch poll data: [error.message]")
			return

		poll_data = polls.ToList()["data"]


	proc/sync_single_poll(pollId)
		var/list/poll
		var/datum/apiModel/Tracked/PollResource/pollResource
		try
			var/datum/apiRoute/polls/show/getPoll = new
			getPoll.routeParams = list("[pollId]")
			pollResource = apiHandler.queryAPI(getPoll)
		catch (var/exception/e)
			var/datum/apiModel/Error/error = e.name
			logTheThing(LOG_DEBUG, null, "Failed to fetch data for poll #[pollId]: [error.message]")
			return

		poll = pollResource.ToList()

		for (var/i in 1 to length(poll_data))
			if (poll_data[i]["id"] != pollId)
				continue
			if (!poll)
				poll_data.Remove(list(poll_data[i]))
				return
			poll_data[i] = poll
			break
