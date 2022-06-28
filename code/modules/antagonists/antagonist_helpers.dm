/**
 * Gets a list of all antagonists of ID role_id.
 * Returns a list if any datums are present, or null if none are.
 */
/proc/get_all_antagonists(role_id)
	var/list/antags
	for (var/datum/mind/M in ticker.minds)
		for (var/datum/antagonist/A in M.antagonists)
			if (A.id == role_id)
				LAZYLISTADD(antags, A)
				break
	return antags
