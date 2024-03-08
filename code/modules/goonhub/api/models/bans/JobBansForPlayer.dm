
/// JobBansForPlayer
/datum/apiModel/JobBansForPlayer
	var/list/jobs = null

/datum/apiModel/JobBansForPlayer/SetupFromResponse(response)
	. = ..()
	src.jobs = response

/datum/apiModel/JobBansForPlayer/ToList()
	. = ..()
	.["jobs"] = src.jobs
