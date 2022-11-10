/**
 * Gets a list of all antagonists of ID role_id.
 * Returns a list if any datums are present, or null if none are.
 */
/proc/get_all_antagonists(role_id, include_pseudo = FALSE)
	. = list()
	for (var/datum/mind/mind in ticker.minds)
		for (var/datum/antagonist/antag in mind.antagonists)
			if (antag.id == role_id && (!antag.pseudo || include_pseudo))
				. += antag
				break
