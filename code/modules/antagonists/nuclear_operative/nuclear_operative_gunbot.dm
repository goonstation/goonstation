/datum/antagonist/nuclear_operative_gunbot
	id = ROLE_NUKEOP_GUNBOT
	display_name = "\improper Syndicate gunbot"
	antagonist_icon = "syndicate"
	faction = FACTION_SYNDICATE

	New(datum/mind/new_owner)
		src.owner = new_owner
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			src.owner.store_memory("The bomb must be armed in <B>[gamemode.concatenated_location_names]</B>.")
			if (!(src.owner in gamemode.syndicates))
				gamemode.syndicates += src.owner

		. = ..()

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/critter/robotic/gunbot/syndicate/gunbot = new/mob/living/critter/robotic/gunbot/syndicate(get_turf(current_mob))
		src.owner.transfer_to(gunbot)
		qdel(current_mob)

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)

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

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/nuclear, src)


