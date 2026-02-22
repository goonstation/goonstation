/datum/antagonist/mob/nuclear_operative_gunbot
	id = ROLE_NUKEOP_GUNBOT
	display_name = "\improper Syndicate gunbot"
	antagonist_icon = "syndicate"
	remove_on_clone = TRUE
	antagonist_panel_tab_type = /datum/antagonist_panel_tab/bundled/nuclear_operative
	faction = list(FACTION_SYNDICATE)
	mob_path = /mob/living/critter/robotic/gunbot/syndicate
	wiki_link = "https://wiki.ss13.co/Nuclear_Operative"

	New(datum/mind/new_owner)
		src.owner = new_owner
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			src.owner.store_memory("The bomb must be armed in <B>[gamemode.concatenated_location_names]</B>.")
			if (!(src.owner in gamemode.syndicates))
				gamemode.syndicates += src.owner

		. = ..()

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/nuclear, src)


