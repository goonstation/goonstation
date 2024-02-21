

/// DectalkPlayResource
/datum/apiModel/DectalkPlayResource
	var/audio = null // string, url pointing to the recorded audio file

/datum/apiModel/DectalkPlayResource/SetupFromResponse(response)
	. = ..()
	src.audio = response["audio"]

/datum/apiModel/DectalkPlayResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.audio) \
	)
		return FALSE

/datum/apiModel/DectalkPlayResource/ToList()
	. = ..()
	.["audio"] = src.audio
