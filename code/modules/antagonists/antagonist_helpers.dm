/// An associative list of all antagonist IDs, associated with a list of all antagonist datums of that ID.
var/list/list/antagonists = list()

/**
 * Gets a list of all antagonist datums of ID role_id, or of all IDs if no ID is specified.
 * Returns a list of all antagonist datums. If no antagonist datums could be found, returns an empty list.
 */
/proc/get_all_antagonists(antagonist_role_id)
	. = list()

	if (antagonist_role_id)
		return antagonists["[antagonist_role_id]"]

	for (var/antagonist_type in antagonists)
		. += antagonists[antagonist_type]

/// Returns a list of all gang datums.
proc/get_all_gangs()
	. = list()

	for (var/datum/antagonist/gang_leader/antagonist_role as anything in get_all_antagonists(ROLE_GANG_LEADER))
		if (antagonist_role?.gang)
			. += antagonist_role.gang

/** Returns the mind of this mind's master.
 * If a specific antagonist role ID is provided, then the master of the antagonist datum of that ID belonging to this mind will be returned.
 * If no antagonist role ID is provided, then the master of the newest antagonist datum will be returned.
 */
/datum/mind/proc/get_master(antagonist_role_id)
	if (antagonist_role_id)
		var/datum/antagonist/subordinate/antagonist_role = src.get_antagonist(antagonist_role_id)
		if (antagonist_role?.master)
			. = antagonist_role.master
		return

	for (var/datum/antagonist/subordinate/antagonist_role in src.antagonists)
		. = antagonist_role.master // Return the master of the newest antagonist datum in `antagonists`.

/// Returns the gang datum of this mob, provided they have one. Otherwise returns false.
/mob/proc/get_gang()
	var/datum/gang/gang
	var/datum/antagonist/gang_leader/gang_leader_antagonist_role = src.mind?.get_antagonist(ROLE_GANG_LEADER)
	if (gang_leader_antagonist_role)
		gang = gang_leader_antagonist_role.gang

	else
		var/datum/antagonist/subordinate/gang_member/gang_member_antagonist_role = src.mind?.get_antagonist(ROLE_GANG_MEMBER)
		if (gang_member_antagonist_role)
			gang = gang_member_antagonist_role.gang

		else
			return null

	return gang

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
		"Detective",
		"AI",
		"Cyborg")

	if (src.mind.assigned_role in unconvertable_roles)
		return FALSE

	return TRUE

/datum/mind/proc/is_head_of_staff()
	return src.assigned_role in list(
			"Captain",
			"Head of Security",
			"Head of Personnel",
			"Chief Engineer",
			"Research Director",
			"Medical Director",
			"Communications Officer",
			)
