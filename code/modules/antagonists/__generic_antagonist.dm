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

/datum/antagonist/generic/syndicate_agent
	id = ROLE_SYNDICATE_AGENT
	antagonist_icon = "syndicate"
	faction = FACTION_SYNDICATE

	New(datum/mind/new_owner)
		src.owner = new_owner
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if (!(src.owner in gamemode.syndicates))
				gamemode.syndicates += src.owner

		. = ..()

	add_to_image_groups()
		. = ..()
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = src.antagonist_icon)
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.add_mind_mob_overlay(src.owner, image)
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	remove_self()
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			if (src.owner in gamemode.syndicates)
				gamemode.syndicates -= src.owner

		. = ..()

