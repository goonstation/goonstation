
/datum/apiBody/jobbans/update
	var/server_id	= "string"
	var/job			= "string"
	var/reason		= "string"
	var/duration	= 0

/datum/apiBody/jobbans/update/New(
	server_id,
	job,
	reason,
	duration
)
	. = ..()
	src.server_id = server_id
	src.job = job
	src.reason = reason
	src.duration = duration

/datum/apiBody/jobbans/update/VerifyIntegrity()
	if (
		isnull(src.server_id) \
		|| isnull(src.job) \
		|| isnull(src.reason) \
		|| isnull(src.duration) \
	)
		return FALSE

/datum/apiBody/jobbans/update/toJson()
	return json_encode(list(
		"server_id"			= src.server_id,
		"job"				= src.job,
		"reason"			= src.reason,
		"duration"			= src.duration
	))
