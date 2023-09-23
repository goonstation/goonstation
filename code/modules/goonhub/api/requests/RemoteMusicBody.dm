
/datum/apiBody/remoteMusic
	var/video				= "string"
	var/round_id			= 0

/datum/apiBody/remoteMusic/New(
	video,
	round_id
)
	. = ..()
	src.video = video
	src.round_id = round_id

/datum/apiBody/remoteMusic/VerifyIntegrity()
	if (
		isnull(src.video) \
		|| isnull(src.round_id) \
	)
		return FALSE

/datum/apiBody/remoteMusic/toJson()
	return json_encode(list(
		"video"				= src.video,
		"round_id"			= src.round_id
	))
