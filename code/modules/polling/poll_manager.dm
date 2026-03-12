var/global/datum/poll_manager/poll_manager = new
/// master poll controller for the server. Caches the results, syncs with api
/datum/poll_manager
	var/list/poll_data = list()
	/// server id for global polls
	var/const/global_server_id = "global"
	/// server id for rp only polls
	var/const/rp_only_server_id = "rp_only"

	/// fetch and cache the latest poll data from the API
	proc/sync_polldata()
		set waitfor = FALSE
		var/datum/apiModel/Paginated/PollResourceList/polls
		try
			var/datum/apiRoute/polls/get/getPolls = new
			getPolls.queryParams = list(
				"filters" = list(
#ifdef RP_MODE
					"servers" = list(config.server_id, global_server_id, rp_only_server_id)
#else
					"servers" = list(config.server_id, global_server_id)
#endif
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

	proc/get_active_poll_names()
		. = list()
		var/current_time = subtractTime(world.realtime, hours = world.timezone)
		for (var/poll in src.poll_data)
			if (fromIso8601(poll["expires_at"]) > current_time) //time is hard, hopefully this is sane
				. += poll["question"]

