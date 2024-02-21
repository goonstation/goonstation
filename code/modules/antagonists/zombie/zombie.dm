/datum/antagonist/zombie
	id = ROLE_ZOMBIE
	display_name = "zombie"
	remove_on_clone = TRUE

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

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
