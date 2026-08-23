/datum/antagonist/zombie
	id = ROLE_ZOMBIE
	display_name = "zombie"
	remove_on_clone = TRUE
	antagonist_icon = "zombie"

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		if(!iszombie(H)) //Mutantrace adds antag role, antag role adds mutantrace, avoid cyclical application from both.
			H.set_mutantrace(/datum/mutantrace/zombie/can_infect)

	remove_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		if(iszombie(H)) //antag status is not removed on death unlike kudzu so we don't need to check (they'll be revived shortly as a zombie again)
			H.set_mutantrace(H.default_mutantrace)

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_ZOMBIE)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_ZOMBIE)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)
