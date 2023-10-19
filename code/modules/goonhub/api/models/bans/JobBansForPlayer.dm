
/// JobBansForPlayer
/datum/apiModel/JobBansForPlayer
	var/list/jobs = null

/datum/apiModel/JobBansForPlayer/SetupFromResponse(response)
	. = ..()
	src.jobs = response

/datum/apiModel/JobBansForPlayer/ToString()
	. = list()
	.["jobs"] = src.jobs
	return json_encode(.)
