/**
 * Gets a list of all antagonists of ID role_id.
 * Returns a list if any datums are present, or null if none are.
 */
/proc/get_all_antagonists(role_id)
	. = list()
	for (var/datum/mind/M in ticker.minds)
		for (var/datum/antagonist/antag in M.antagonists)
			if (antag.id == role_id)
				. += antag
				break
