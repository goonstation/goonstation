/datum/antagonist/zombie
	id = ROLE_ZOMBIE
	display_name = "zombie"
	remove_on_clone = TRUE

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)
