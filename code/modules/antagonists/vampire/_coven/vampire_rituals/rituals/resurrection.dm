/datum/vampire_ritual/resurrection
	name = "ritual of resurrection"
	incantation_lines = list(
		"insula mortuorum",
		"domus resurrectorum",
		"reddite nobis amicum nostrum",
	)
	blood_cost = 100

/datum/vampire_ritual/resurrection/can_invoke_ritual()
	var/dead_member = FALSE
	var/datum/vampire_coven/coven = global.get_singleton(/datum/vampire_coven)
	for (var/datum/mind/member as anything in coven.members)
		if (!isdead(member.current))
			continue

		if (!ishuman(member.current) && !ishuman(astype(member.current, /mob/dead)?.corpse))
			continue

		dead_member = TRUE
		break

	if (!dead_member)
		return FALSE

	. = ..()

/datum/vampire_ritual/resurrection/sacrifice_conditions_met()
	var/turf/T = get_turf(src.parent)
	for (var/atom/movable/AM as anything in T.contents)
		var/mob/living/carbon/human/H = AM
		if (!istype(H) || !isdead(H) || isnpcmonkey(H) || isnpc(H))
			continue

		src.set_major_sacrifice(H)
		break

	if (!src.major_sacrifice)
		return FALSE

	return TRUE

/datum/vampire_ritual/resurrection/invoke(mob/caster)
	var/list/mob/living/carbon/human/dead_members = list()
	var/datum/vampire_coven/coven = global.get_singleton(/datum/vampire_coven)
	for (var/datum/mind/member as anything in coven.members)
		if (!isdead(member.current))
			continue

		var/mob/living/carbon/human/body = null
		if (istype(member.current, /mob/living/carbon/human))
			body = member.current
		else
			body = astype(member.current, /mob/dead).corpse

		if (!istype(body))
			continue

		dead_members[body.real_name] = body

	if (!length(dead_members))
		return FALSE

	var/member_to_revive = global.tgui_input_list(caster, "Chose a coven member to revive", "Revive Coven Vampire", dead_members)
	if (isnull(member_to_revive))
		return FALSE

	var/mob/living/carbon/human/H = dead_members[member_to_revive]
	if (!istype(H))
		return FALSE

	src.additional_completion_text = ", bringing <b>[H.real_name]</b> back from beyond the grave"

	global.animate_shrinking_outline(H)
	SPAWN(2 SECONDS)
		H.set_loc(get_turf(src.parent))
		H.full_heal()
		global.animate_expanding_outline(H)

	return TRUE
