/datum/antagonist/nuclear_operative_gunbot
	id = ROLE_NUKEOP_GUNBOT
	display_name = "\improper Syndicate gunbot"

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

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/nuclear, src)


