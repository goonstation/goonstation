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

/// Checks whether a mob can be converted to the revolution by use of a flash, revolutionary flash, revolutionary flashbang, or violence.
/mob/living/proc/can_be_converted_to_the_revolution()
	if (!src.mind || isghostcritter(src) || locate(/obj/item/implant/counterrev) in src.implant)
		return FALSE

	var/list/unconvertable_roles = list(
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Research Director",
		"Medical Director",
		"Chief Engineer",
		"Communications Officer",
		"Head of Mining",
		"Nanotrasen Special Operative",
		"Nanotrasen Security Consultant",
		"Security Officer",
		"Security Assistant",
		"Vice Officer",
		"Part-time Vice Officer",
		"Detective",
		"AI",
		"Cyborg")

	if (src.mind.assigned_role in unconvertable_roles)
		return FALSE

	return TRUE
