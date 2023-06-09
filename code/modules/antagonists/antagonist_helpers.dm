var/list/antagonists = list()
/**
 * Gets a list of all antagonists of ID role_id, or of all IDs if no ID is specified.
 * Returns a list of minds if any datums are present, or null if none are.
 */
/proc/get_all_antagonists(antagonist_role_id)
	. = list()

	if (antagonist_role_id)
		return antagonists["[antagonist_role_id]"]

	for (var/antagonist_type in concrete_typesof(/datum/antagonist))
		var/datum/antagonist/A = antagonist_type
		var/list/datum/mind/antagonist_minds = antagonists["[initial(A.id)]"]
		if (length(antagonist_minds))
			. += antagonist_minds

/// Returns a list of all gang datums.
proc/get_all_gangs()
	. = list()

	for (var/datum/mind/gang_leader as anything in get_all_antagonists(ROLE_GANG_LEADER))
		var/datum/antagonist/gang_leader/antagonist_role = gang_leader.get_antagonist(ROLE_GANG_LEADER)
		if (antagonist_role?.gang)
			. += antagonist_role.gang

	return .

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
			return FALSE

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
		"Part-time Vice Officer",
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
