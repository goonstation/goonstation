/// POST /job-bans
/// Add a new job ban
/datum/apiRoute/jobbans/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/job-bans"
	body = /datum/apiBody/jobbans/add
	correct_response = /datum/apiModel/Tracked/JobBanResource

	buildBody(
		game_admin_ckey,
		round_id,
		server_id,
		ckey,
		job,
		reason,
		duration
	)
		. = ..(args)
