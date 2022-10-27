/datum/antagonist/zombie
	id = ROLE_ZOMBIE
	display_name = "zombie"

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)
