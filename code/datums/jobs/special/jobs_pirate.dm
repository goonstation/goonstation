/datum/job/special/pirate
	ui_colour = TGUI_COLOUR_CRIMSON
	name = "Space Pirate"
	limit = 0
	wages = 0
	add_to_manifest = FALSE
	radio_announcement = FALSE
	can_roll_antag = FALSE
	slot_card = /obj/item/card/id
	slot_belt = list()
	slot_back = list()
	slot_jump = list()
	slot_foot = list()
	slot_head = list()
	slot_eyes = list()
	slot_ears = list()
	slot_poc1 = list()
	slot_poc2 = list()
	var/rank = ROLE_PIRATE

	New()
		..()
		src.access = list(access_maint_tunnels, access_pirate )
		return

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		for (var/datum/antagonist/antag in M.mind.antagonists)
			if (antag.id == ROLE_PIRATE || antag.id == ROLE_PIRATE_FIRST_MATE || antag.id == ROLE_PIRATE_CAPTAIN)
				antag.give_equipment()
				return
		M.mind.add_antagonist(rank, source = ANTAGONIST_SOURCE_ADMIN)


	first_mate
		name = "Space Pirate First Mate"
		rank = ROLE_PIRATE_FIRST_MATE

	captain
		name = "Space Pirate Captain"
		rank = ROLE_PIRATE_CAPTAIN
