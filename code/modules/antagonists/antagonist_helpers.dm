/**
 * Gets a list of all minds with an antagonist datum of ID role_id.
 * Returns a list if any minds are present, or null if none are.
 */
/proc/get_all_antagonists(role_id)
	var/list/datum/mind/minds
	for (var/datum/mind/M in ticker.minds)
		for (var/datum/antagonist/A in M.antagonists)
			if (A.id == role_id)
				LAZYLISTADD(minds, A)
				break
	return minds
