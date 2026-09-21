ABSTRACT_TYPE(/datum/job/special/pod_wars)
/datum/job/special/pod_wars
	name = "Pod_Wars"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = -1
	wages = 0 //Who needs cash when theres a battle to win
#else
	limit = 0
	wages = PAY::IMPORTANT
#endif
	can_roll_antag = FALSE
	var/team = 0 //1 = NT, 2 = SY
	var/overlay_icon
	wiki_link = "https://wiki.ss13.co/Game_Modes#Pod_Wars"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if (!M.abilityHolder)
			M.abilityHolder = new /datum/abilityHolder/pod_pilot(src)
			M.abilityHolder.owner = src
		else if (istype(M.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/AH = M.abilityHolder
			AH.addHolder(/datum/abilityHolder/pod_pilot)

		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			mode.setup_team_overlay(M.mind, overlay_icon)
			if (team == 1)
				M.mind.special_role = mode.team_NT?.name
			else if (team == 2)
				M.mind.special_role = mode.team_SY?.name

	nanotrasen
		name = "NanoTrasen Pod Pilot"
		ui_colour = /datum/job/special/nt::ui_colour
		no_jobban_from_this_job = TRUE
		low_priority_job = TRUE
		cant_allocate_unwanted = TRUE
		access = list(access_heads, access_medical, access_medical_lockers, access_mining)
		team = 1
		overlay_icon = "nanotrasen"

		faction = list(FACTION_NANOTRASEN)

		receives_implants = list(/obj/item/implant/pod_wars/nanotrasen)
		slot_back = list(/obj/item/storage/backpack/NT)
		slot_jump = list(/obj/item/clothing/under/misc/turds)
		slot_head = list(/obj/item/clothing/head/helmet/space/pod_wars/NT)
		slot_suit = list(/obj/item/clothing/suit/space/pod_wars/NT)
		slot_foot = list(/obj/item/clothing/shoes/swat)
		slot_card = /obj/item/card/id/pod_wars/nanotrasen
		slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen)
		slot_mask = list(/obj/item/clothing/mask/gas/swat/NT)
		slot_glov = list(/obj/item/clothing/gloves/swat/NT)
		slot_poc1 = list(/obj/item/tank/pocket/extended/oxygen)
		slot_poc2 = list(/obj/item/requisition_token/podwars/NT)

		commander
			name = "NanoTrasen Pod Commander"
#ifdef MAP_OVERRIDE_POD_WARS
			limit = 1
#else
			limit = 0
#endif
			no_jobban_from_this_job = FALSE
			high_priority_job = TRUE
			cant_allocate_unwanted = TRUE
			overlay_icon = "nanocomm"
			access = list(access_heads, access_captain, access_medical, access_medical_lockers, access_engineering_power, access_mining)

			slot_head = list(/obj/item/clothing/head/helmet/space/pod_wars/NT/commander)
			slot_suit = list(/obj/item/clothing/suit/space/pod_wars/NT/commander)
			slot_card = /obj/item/card/id/pod_wars/nanotrasen/commander
			slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen/commander)

	syndicate
		name = "Syndicate Pod Pilot"
		ui_colour = /datum/job/special/syndicate::ui_colour
		no_jobban_from_this_job = TRUE
		low_priority_job = TRUE
		cant_allocate_unwanted = TRUE
		access = list(access_syndicate_shuttle, access_medical, access_medical_lockers, access_mining)
		team = 2
		overlay_icon = "syndicate"
		add_to_manifest = FALSE

		faction = list(FACTION_SYNDICATE)

		receives_implants = list(/obj/item/implant/pod_wars/syndicate)
		slot_back = list(/obj/item/storage/backpack/syndie)
		slot_jump = list(/obj/item/clothing/under/misc/syndicate)
		slot_head = list(/obj/item/clothing/head/helmet/space/pod_wars/SY)
		slot_suit = list(/obj/item/clothing/suit/space/pod_wars/SY)
		slot_foot = list(/obj/item/clothing/shoes/swat)
		slot_card = /obj/item/card/id/pod_wars/syndicate
		slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate)
		slot_mask = list(/obj/item/clothing/mask/gas/swat)
		slot_glov = list(/obj/item/clothing/gloves/swat/syndicate)
		slot_poc1 = list(/obj/item/tank/pocket/extended/oxygen)
		slot_poc2 = list(/obj/item/requisition_token/podwars/SY)

		commander
			name = "Syndicate Pod Commander"
#ifdef MAP_OVERRIDE_POD_WARS
			limit = 1
#else
			limit = 0
#endif
			no_jobban_from_this_job = FALSE
			high_priority_job = TRUE
			cant_allocate_unwanted = TRUE
			overlay_icon = "syndcomm"
			access = list(access_syndicate_shuttle, access_syndicate_commander, access_medical, access_medical_lockers, access_engineering_power, access_mining)

			slot_head = list(/obj/item/clothing/head/helmet/space/pod_wars/SY/commander)
			slot_suit = list(/obj/item/clothing/suit/space/pod_wars/SY/commander)
			slot_card = /obj/item/card/id/pod_wars/syndicate/commander
			slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate/commander)
