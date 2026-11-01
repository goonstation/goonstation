/datum/antagonist/kudzuperson
	id = ROLE_KUDZUPERSON
	display_name = "Kudzuperson"
	antagonist_icon = "kudzu"
	remove_on_death = TRUE
	remove_on_clone = TRUE
	faction = list(FACTION_BOTANY)
	wiki_link = "https://wiki.ss13.co/Kudzu"

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		H.set_mutantrace(/datum/mutantrace/kudzu)

	remove_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		if(iskudzuman(H) && !isdead(H)) //antag status is removed on death but they should remain a kudzuman so they aren't cloneable
			H.set_mutantrace(H.default_mutantrace)

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_KUDZUPERSON)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_KUDZUPERSON)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	announce_objectives()
		return

	announce()
		boutput(src.owner.current, SPAN_ALERT("<b>You have been taken over by the kudzu hivemind!</b>"))
		..()
