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

proc/get_all_gangs()
	var/list/datum/gang/gangs = list()

	for (var/datum/antagonist/gang_leader/antag_datum in get_all_antagonists(ROLE_GANG_LEADER))
		gangs += antag_datum.gang

	return gangs

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
