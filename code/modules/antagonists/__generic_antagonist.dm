/datum/antagonist/generic

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, id, display_name)
		if (!src.id)
			src.id = id
		if (!src.display_name)
			src.display_name = display_name

		. = ..()

	do_popup(override)
		if (!override)
			override = "traitorgeneric"

		..(override)

/datum/antagonist/generic/antagonist_critter
	id = ROLE_ANTAGONIST_CRITTER
	display_name = "antagonist critter"

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, id, display_name)
		src.display_name = "[initial(src.display_name)] [display_name]"

		. = ..()

