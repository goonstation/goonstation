// Special Cases
ABSTRACT_TYPE(/datum/job/special)
/datum/job/special
	name = "Special Job"
	limit = 0
	wages = PAY_UNTRAINED
	wiki_link = "https://wiki.ss13.co/Jobs#Gimmick_Jobs" // fallback for those without their own page

#ifdef I_WANNA_BE_THE_JOB
/datum/job/special/imcoder
	name = "IMCODER"
	// Used for debug testing. No need to define special landmark, this overrides job picks
	access_string = "Captain"
	limit = -1
	slot_belt = list(/obj/item/storage/belt/utility/prepared/ceshielded)
	slot_jump = list(/obj/item/clothing/under/rank/assistant)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_glov = list(/obj/item/clothing/gloves/yellow)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_head = list(/obj/item/clothing/head/helmet/space/light/engineer)
	slot_suit = list(/obj/item/clothing/suit/space/light/engineer)
	slot_back = list(/obj/item/storage/backpack)
	// slot_mask = list(/obj/item/clothing/mask/gas)
	items_in_backpack = list(
		/obj/item/rcd/construction/safe/admin_crimes,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/sheet/steel/fullstack,
		/obj/item/storage/box/cablesbox,
		/obj/item/tank/oxygen,
	)
#endif

/datum/job/special/station_builder
	// Used for Construction game mode, where you build the station
	name = "Station Builder"
	can_roll_antag = FALSE
	limit = 0
	wages = PAY_TRADESMAN
	trait_list = list("training_engineer")
	access_string = "Construction Worker"
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	slot_rhan = list(/obj/item/tank/jetpack)
	slot_eyes = list(/obj/item/clothing/glasses/construction)
	slot_poc1 = list(/obj/item/currency/spacecash/fivehundred)
	slot_poc2 = list(/obj/item/room_planner)
	slot_suit = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	slot_mask = list(/obj/item/clothing/mask/breath)
	wiki_link = "https://wiki.ss13.co/Construction_Game_Mode" // ?

	items_in_backpack = list(/obj/item/rcd/construction, /obj/item/rcd_ammo/big, /obj/item/rcd_ammo/big, /obj/item/material_shaper,/obj/item/room_marker)

/datum/job/special/mime
	name = "Mime"
	limit = 1
	request_limit = 2
	ui_colour = TGUI_COLOUR_GREY
	wages = PAY_DUMBCLOWN*2 // lol okay whatever
	request_cost = PAY_DOCTORATE * 4
	trait_list = list("training_mime")
	access_string = "Mime"
	slot_belt = list(/obj/item/device/pda2)
	slot_head = list(/obj/item/clothing/head/mime_bowler)
	slot_mask = list(/obj/item/clothing/mask/mime)
	slot_jump = list(/obj/item/clothing/under/misc/mime/alt)
	slot_suit = list(/obj/item/clothing/suit/scarf)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/pen/crayon/white)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/baguette, /obj/item/instrument/whistle/janitor)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Mime"

/datum/job/special/vice_officer
	name = "Vice Officer"
	ui_colour = TGUI_COLOUR_RED
	limit = 0
	wages = PAY_TRADESMAN
	access_string = "Vice Officer"
	can_roll_antag = FALSE
	badge = /obj/item/clothing/suit/security_badge
	receives_miranda = TRUE
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/misc/vice)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list( /obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_poc2 = list(/obj/item/requisition_token/security)
	wiki_link = "https://wiki.ss13.co/Part-Time_Vice_Officer"

/datum/job/special/forensic_technician
	name = "Forensic Technician"
	ui_colour = TGUI_COLOUR_RED
	limit = 0
	wages = PAY_TRADESMAN
	access_string = "Forensic Technician"
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/color/darkred)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/device/detective_scanner)
	items_in_backpack = list(/obj/item/tank/pocket/oxygen)

/datum/job/special/toxins_researcher
	name = "Toxins Researcher"
	ui_colour = TGUI_COLOUR_PURPLE
	limit = 0
	wages = PAY_DOCTORATE
	trait_list = list("training_scientist")
	access_string = "Toxins Researcher"
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)

/datum/job/special/chemist
	name = "Chemist"
	ui_colour = TGUI_COLOUR_PURPLE
	limit = 0
	wages = PAY_DOCTORATE
	trait_list = "training_scientist"
	access_string = "Chemist"
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_ears = list(/obj/item/device/radio/headset/research)
	wiki_link = "https://wiki.ss13.co/Chemist"

/datum/job/special/atmospheric_technician
	name = "Atmospherish Technician"
	ui_colour = TGUI_COLOUR_ORANGE
	limit = 0
	wages = PAY_TRADESMAN
	access_string = "Atmospheric Technician"
	slot_belt = list(/obj/item/device/pda2/atmos)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/atmos)
	slot_jump = list(/obj/item/clothing/under/misc/atmospheric_technician)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/toolbox/mechanical)
	slot_poc1 = list(/obj/item/device/analyzer/atmospheric)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	items_in_backpack = list(/obj/item/tank/mini/oxygen,/obj/item/crowbar)
	wiki_link = "https://wiki.ss13.co/Atmospheric_Technician"

/datum/job/special/comm_officer
	name = "Communications Officer"
	limit = 0
	wages = PAY_IMPORTANT
	access_string = "Communications Officer"
	world_announce_priority = ANNOUNCE_ORDER_LAST
	wiki_link = "https://wiki.ss13.co/Communications_Officer"

	slot_ears = list(/obj/item/device/radio/headset/command/comm_officer)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_jump = list(/obj/item/clothing/under/rank/comm_officer)
	slot_card = /obj/item/card/id/command
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_poc1 = list(/obj/item/pen/fancy)
	slot_head = list(/obj/item/clothing/head/sea_captain/comm_officer_hat)
	items_in_backpack = list(/obj/item/device/camera_viewer/security, /obj/item/device/audio_log, /obj/item/device/flash)

/datum/job/special/stowaway
	name = "Stowaway"
	limit = 0 // set in New()
	wages = 0
	trait_list = list("stowaway")
	add_to_manifest = FALSE
	low_priority_job = TRUE
	slot_card = null
	slot_head = list(\
	/obj/item/clothing/head/green = 1,
	/obj/item/clothing/head/red = 1,
	/obj/item/clothing/head/constructioncone = 1,
	/obj/item/clothing/head/helmet/welding = 1,
	/obj/item/clothing/head/helmet/hardhat = 1,
	/obj/item/clothing/head/serpico = 1,
	/obj/item/clothing/head/souschefhat = 1,
	/obj/item/clothing/head/maid = 1,
	/obj/item/clothing/head/cowboy = 1)

	slot_mask = list(\
	/obj/item/clothing/mask/gas = 1,
	/obj/item/clothing/mask/surgical = 1,
	/obj/item/clothing/mask/skull = 1,
	/obj/item/clothing/mask/bandana/white = 1)

	slot_ears = list(\
	/obj/item/device/radio/headset/civilian = 8,
	/obj/item/device/radio/headset/engineer = 1,
	/obj/item/device/radio/headset/research = 1,
	/obj/item/device/radio/headset/shipping = 1,
	/obj/item/device/radio/headset/medical = 1,
	/obj/item/device/radio/headset/miner = 1)

	slot_suit = list(\
	/obj/item/clothing/suit/wintercoat/engineering = 1,
	/obj/item/clothing/suit/wintercoat/robotics = 1,
	/obj/item/clothing/suit/labcoat = 1,
	/obj/item/clothing/suit/labcoat/robotics = 1,
	/obj/item/clothing/suit/wintercoat/research = 1)

	slot_jump = list(\
	/obj/item/clothing/under/color/grey = 1,
	/obj/item/clothing/under/rank/security/assistant = 1,
	/obj/item/clothing/under/rank/roboticist = 1,
	/obj/item/clothing/under/rank/engineer = 1,
	/obj/item/clothing/under/rank/orangeoveralls = 1,
	/obj/item/clothing/under/rank/orangeoveralls/yellow = 1,
	/obj/item/clothing/under/gimmick/maid = 1,
	/obj/item/clothing/under/rank/bartender = 1,
	/obj/item/clothing/under/misc/souschef = 1,
	/obj/item/clothing/under/rank/hydroponics = 1,
	/obj/item/clothing/under/rank/rancher = 1,
	/obj/item/clothing/under/rank/overalls = 1,
	/obj/item/clothing/under/rank/cargo = 1,
	/obj/item/clothing/under/rank/assistant = 10,
	/obj/item/clothing/under/rank/janitor = 1)

	slot_glov = list(\
	/obj/item/clothing/gloves/yellow/unsulated = 1,
	/obj/item/clothing/gloves/black = 1,
	/obj/item/clothing/gloves/fingerless = 1,
	/obj/item/clothing/gloves/long = 1)

	slot_foot = list(\
	/obj/item/clothing/shoes/brown = 6,
	/obj/item/clothing/shoes/red = 1,
	/obj/item/clothing/shoes/white = 1,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/shoes/swat = 1,
	/obj/item/clothing/shoes/orange = 1,
	/obj/item/clothing/shoes/westboot/brown/rancher = 1,
	/obj/item/clothing/shoes/galoshes = 1)

	slot_back = list(\
	/obj/item/storage/backpack = 3,
	/obj/item/storage/backpack/anello = 1,
	/obj/item/storage/backpack/security = 1,
	/obj/item/storage/backpack/engineering = 1,
	/obj/item/storage/backpack/research = 1,
	/obj/item/storage/backpack/salvager = 1,
	/obj/item/storage/backpack/syndie/tactical = 0.2) //hehe

	slot_belt = list(\
	/obj/item/crowbar = 6,
	/obj/item/crowbar/red = 1,
	/obj/item/crowbar/yellow = 1,
	/obj/item/crowbar/blue = 1,
	/obj/item/crowbar/grey = 1,
	/obj/item/crowbar/orange = 1)

	slot_poc1 = list(\
	/obj/item/screwdriver = 1,
	/obj/item/screwdriver/yellow = 1,
	/obj/item/screwdriver/grey = 1,
	/obj/item/screwdriver/orange = 1)

	slot_poc2 = list(\
	/obj/item/scissors = 1,
	/obj/item/wirecutters = 1,
	/obj/item/wirecutters/yellow = 1,
	/obj/item/wirecutters/grey = 1,
	/obj/item/wirecutters/orange = 1,
	/obj/item/scissors/surgical_scissors = 1)

	items_in_backpack = list(\
	/obj/item/currency/buttcoin,
	/obj/item/currency/spacecash/fivehundred)

	New()
		. = ..()
		src.limit = rand(0,3)

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

/datum/job/special/juicer_specialist
	ui_colour = TGUI_COLOUR_PINK
	name = "Juicer Security"
	limit = 0
	wages = 0
	can_roll_antag = FALSE
	add_to_manifest = FALSE

	slot_back = list(/obj/item/gun/energy/blaster_cannon)
	slot_belt = list(/obj/item/storage/fanny)
	//more

/datum/job/special/headminer
	name = "Head of Mining"
	limit = 0
	wages = PAY_IMPORTANT
	trait_list = list("training_miner")
	access_string = "Head of Mining"
	ui_colour = TGUI_COLOUR_GREEN
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY, ROLE_GANG_MEMBER, ROLE_GANG_LEADER, ROLE_SPY_THIEF, ROLE_CONSPIRATOR)
	slot_card = /obj/item/card/id/command
	slot_belt = list(/obj/item/device/pda2/mining)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	items_in_backpack = list(/obj/item/tank/pocket/oxygen,/obj/item/crowbar)

/datum/job/special/machoman
	name = "Macho Man"
	ui_colour = TGUI_COLOUR_VIOLET
	limit = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	wiki_link = "https://wiki.ss13.co/Admin#Special_antagonists"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_MACHO_MAN, source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/meatcube
	name = "Meatcube"
	ui_colour = TGUI_COLOUR_RED
	limit = 0
	can_roll_antag = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	add_to_manifest = FALSE
	wiki_link = "https://wiki.ss13.co/Critter#Other"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.cubeize(INFINITY)

/datum/job/special/ghostdrone
	name = "Drone"
	ui_colour = TGUI_COLOUR_GREY
	limit = 0
	wages = 0
	can_roll_antag = FALSE
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	wiki_link = "https://wiki.ss13.co/Ghostdrone"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		droneize(M, 0)

ABSTRACT_TYPE(/datum/job/daily)
/datum/job/daily //Special daily jobs
	request_limit = 2
	request_cost = PAY_DOCTORATE*4
	var/day = ""
/datum/job/daily/boxer
	day = "Sunday"
	name = "Boxer"
	wages = PAY_UNTRAINED
	access_string = "Boxer"
	limit = 4
	slot_jump = list(/obj/item/clothing/under/shorts)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/boxing)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Boxer"

/datum/job/daily/dungeoneer
	day = "Monday"
	name = "Dungeoneer"
	limit = 1
	wages = PAY_UNTRAINED
	access_string = "Dungeoneer"
	slot_belt = list(/obj/item/device/pda2)
	slot_mask = list(/obj/item/clothing/mask/skull)
	slot_jump = list(/obj/item/clothing/under/color/brown)
	slot_suit = list(/obj/item/clothing/suit/cultist/nerd)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_poc1 = list(/obj/item/pen/omni)
	slot_poc2 = list(/obj/item/paper)
	items_in_backpack = list(/obj/item/storage/box/nerd_kit)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Jobs#Job_of_the_Day" // no wiki page yet

/datum/job/daily/barber
	day = "Tuesday"
	name = "Barber"
	wages = PAY_UNTRAINED
	access_string = "Barber"
	limit = 1
	slot_jump = list(/obj/item/clothing/under/misc/barber)
	slot_head = list(/obj/item/clothing/head/boater_hat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_poc1 = list(/obj/item/scissors)
	slot_poc2 = list(/obj/item/razor_blade)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	alt_names = list("Barber", "Hairdresser")
	wiki_link = "https://wiki.ss13.co/Barber"

/datum/job/daily/waiter
	day = "Wednesday"
	name = "Waiter"
	wages = PAY_UNTRAINED
	access_string = "Waiter"
	slot_jump = list(/obj/item/clothing/under/rank/bartender)
	slot_suit = list(/obj/item/clothing/suit/wcoat)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/plate/tray)
	slot_poc1 = list(/obj/item/cloth/towel/white)
	items_in_backpack = list(/obj/item/storage/box/glassbox,/obj/item/storage/box/cutlery)
	wiki_link = "https://wiki.ss13.co/Jobs#Job_of_the_Day" // no wiki page yet

/datum/job/daily/lawyer
	day = "Thursday"
	name = "Lawyer"
	ui_colour = TGUI_COLOUR_RED
	wages = PAY_DOCTORATE
	access_string = "Lawyer"
	limit = 4
	badge = /obj/item/clothing/suit/security_badge/attorney
	slot_jump = list(/obj/item/clothing/under/misc/lawyer)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_lhan = list(/obj/item/storage/briefcase)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	alt_names = list("Lawyer", "Attorney")
	wiki_link = "https://wiki.ss13.co/Lawyer"


/datum/job/daily/tourist
	day = "Friday"
	name = "Tourist"
	limit = 100
	request_limit = 0
	wages = 0
	slot_back = null
	slot_belt = list(/obj/item/storage/fanny)
	slot_jump = list(/obj/item/clothing/under/misc/tourist)
	slot_poc1 = list(/obj/item/camera_film)
	slot_poc2 = list(/obj/item/currency/spacecash/tourist) // Exact amount is randomized.
	slot_foot = list(/obj/item/clothing/shoes/tourist)
	slot_lhan = list(/obj/item/camera)
	slot_rhan = list(/obj/item/storage/photo_album)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Tourist"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/morph = null
		if(prob(33))
			morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)

		if (morph && (morph == /datum/mutantrace/martian || morph == /datum/mutantrace/blob)) // doesn't wear human clothes
			M.equip_if_possible(new /obj/item/storage/backpack/empty(src), SLOT_BACK)
			var/obj/item/backpack = M.back

			var/obj/item/storage/fanny/belt_storage = M.belt
			if(istype(belt_storage))
				for(var/obj/item/I in belt_storage.storage.get_contents())
					belt_storage.storage.transfer_stored_item(I, backpack, TRUE, M)
			qdel(belt_storage)

			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_IN_BACKPACK)

			M.stow_in_available(M.l_store, FALSE)
			M.stow_in_available(M.r_store, FALSE)

			var/obj/item/shirt = M.get_slot(SLOT_W_UNIFORM)
			M.drop_from_slot(shirt)
			qdel(shirt)

			var/obj/item/shoes = M.get_slot(SLOT_SHOES)
			M.drop_from_slot(shoes)
			qdel(shoes)

		else
			var/obj/item/clothing/lanyard/L = new /obj/item/clothing/lanyard(M.loc)
			var/obj/item/card/id = locate() in M
			if (id)
				L.storage.add_contents(id, M, FALSE)
			if (M.l_store)
				M.stow_in_available(M.l_store)
			M.equip_if_possible(new /obj/item/device/speech_pro(src), SLOT_L_STORE)
			M.equip_if_possible(L, SLOT_WEAR_ID, TRUE)

		if(morph) // now that we've handled weird mutantrace cases, morph them
			M.set_mutantrace(morph)

/datum/job/daily/musician
	day = "Saturday"
	name = "Musician"
	limit = 3
	wages = PAY_UNTRAINED
	slot_jump = list(/obj/item/clothing/under/suit/pinstripe)
	slot_head = list(/obj/item/clothing/head/flatcap)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_lhan = list(/obj/item/storage/briefcase/instruments)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Musician"

/datum/job/battler
	name = "Battler"
	limit = -1
	wiki_link = "https://wiki.ss13.co/Battler"

/datum/job/slasher
	name = "The Slasher"
	ui_colour = TGUI_COLOUR_BLACK
	limit = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()
	items_in_backpack = list()
	wiki_link = "https://wiki.ss13.co/The_Slasher"

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_SLASHER, source = ANTAGONIST_SOURCE_ADMIN)

ABSTRACT_TYPE(/datum/job/special/pod_wars)
/datum/job/special/pod_wars
	name = "Pod_Wars"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = -1
	wages = 0 //Who needs cash when theres a battle to win
#else
	limit = 0
	wages = PAY_IMPORTANT
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
		ui_colour = TGUI_COLOUR_NAVY
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
		ui_colour = TGUI_COLOUR_CRIMSON
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

/datum/job/football
	name = "Football Player"
	limit = -1
	wiki_link = "https://wiki.ss13.co/Game_Modes#Football"


/datum/job/special/gang_respawn
	name = "Gang Respawn"
	limit = 0
	wages = 0
	access_string = "Staff Assistant"
	slot_card = /obj/item/card/id/civilian
	slot_jump = list(/obj/item/clothing/under/rank/assistant)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	add_to_manifest = FALSE

	special_setup(var/mob/living/carbon/human/M)
		..()
		SPAWN(0)
			var/obj/item/card/id/C = M.get_slot(SLOT_WEAR_ID)
			C.assignment = "Staff Assistant"
			C.name = "[C.registered]’s ID Card ([C.assignment])"

			M.job = "Staff Assistant" // for observers

			var/obj/item/device/pda2/pda = locate() in M
			pda.assignment = "Staff Assistant"
			pda.ownerAssignment = "Staff Assistant"

/datum/job/special/pathologist
	name = "Pathologist"
	limit = 0
	wages = PAY_DOCTORATE
	access_string = "Pathologist"
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/pathologist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/pathology)
	slot_ears = list(/obj/item/device/radio/headset/medical)

/datum/job/special/performer
	name = "Performer"
	access_string = "Staff Assistant"
	limit = 0
	change_name_on_spawn = TRUE
	slot_ears = list(/obj/item/device/radio/headset)
	slot_jump = list(/obj/item/clothing/under/gimmick/black_wcoat)
	slot_foot = list(/obj/item/clothing/shoes/dress_shoes)
	slot_belt = list(/obj/item/device/pda2)
	items_in_backpack = list(/obj/item/storage/box/box_o_laughs, /obj/item/item_box/assorted/stickers/stickers_limited, /obj/item/currency/spacecash/twothousandfivehundred)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("accent_goodmin", magical=1)

/datum/job/special/werewolf_hunter
	name = "Werewolf Hunter"
	access_string = "Staff Assistant"
	limit = 0
	change_name_on_spawn = TRUE
	slot_head = list(/obj/item/clothing/head/witchfinder)
	slot_ears = list(/obj/item/device/radio/headset/werewolf_hunter)
	slot_suit = list(/obj/item/clothing/suit/witchfinder)
	slot_jump = list(/obj/item/clothing/under/gimmick/witchfinder)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_foot = list(/obj/item/clothing/shoes/witchfinder)
	slot_back = list(/obj/item/quiver/leather/stocked)
	slot_belt = list(/obj/item/storage/belt/crossbow)
	slot_poc1 = list(/obj/item/storage/werewolf_hunter_pouch)

	items_in_belt = list(
		/obj/item/dagger/silver,
		/obj/item/gun/bow/crossbow/wooden,
		/obj/item/gun/bow/crossbow/wooden,
		/obj/item/handcuffs/silver,
		/obj/item/handcuffs/silver,
	)

/*---------------------------------------------------------------*/

/datum/job/created
	name = "Special Job"
	job_category = JOB_CREATED

	//handle special spawn location
	Write(F)
		. = ..()
		if(istext(src.special_spawn_location))
			F["special_spawn_location"] << src.special_spawn_location
		else if(ismovable(src.special_spawn_location) || isturf(src.special_spawn_location))
			var/atom/A = src.special_spawn_location
			var/turf/T = get_turf(A)
			F["special_spawn_location_coords"] << list(T.x, T.y, T.z)

	Read(F)
		. = ..()
		src.special_spawn_location = null
		var/maybe_spawn_loc = null
		F["special_spawn_location"] >> maybe_spawn_loc
		if(istext(maybe_spawn_loc))
			src.special_spawn_location = maybe_spawn_loc
		else
			var/list/maybe_coords = null
			F["special_spawn_location_coords"] >> maybe_coords
			if(islist(maybe_coords))
				src.special_spawn_location = locate(maybe_coords[1], maybe_coords[2], maybe_coords[3])
