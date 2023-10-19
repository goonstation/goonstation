
/datum/apiBody/remoteMusic
	fields = list(
		"video", // string
		"round_id", // integer
		"game_admin_ckey" // string
	)

/datum/apiBody/remoteMusic/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["video"]) \
		|| isnull(src.values["round_id"]) \
	)
		return FALSE
