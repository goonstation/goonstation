// Special Cases
ABSTRACT_TYPE(/datum/job/special)
/datum/job/special
	name = "Special Job"
	limit = 0
	wages = PAY::UNTRAINED
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
	wages = PAY::TRADESMAN
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
	wages = PAY::DUMBCLOWN*2 // lol okay whatever
	request_cost = PAY::DOCTORATE * 4
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
	items_in_backpack = list(/obj/item/baguette, /obj/item/instrument/whistle/janitor, /obj/item/stamp/mime)
	change_name_on_spawn = TRUE
	wiki_link = "https://wiki.ss13.co/Mime"
	email_group = MGD_CIVILIAN
	rounds_needed_to_play = ROUNDS_MIN_SECASS

/datum/job/special/vice_officer
	name = "Vice Officer"
	ui_colour = /datum/job/security::ui_colour
	limit = 0
	wages = PAY::TRADESMAN
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
	email_group = MGD_SECURITY

/datum/job/special/forensic_technician
	name = "Forensic Technician"
	ui_colour = /datum/job/security::ui_colour
	limit = 0
	wages = PAY::TRADESMAN
	trait_list = list("training_forensic")
	access_string = "Forensic Technician"
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_jump = list(/obj/item/clothing/under/color/darkred)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_poc1 = list(/obj/item/device/detective_scanner)
	items_in_backpack = list(/obj/item/tank/pocket/oxygen, /obj/item/reagent_containers/applicator/brush/silver_nitrate)
	email_group = MGD_SECURITY

/datum/job/special/toxins_researcher
	name = "Toxins Researcher"
	ui_colour = /datum/job/research::ui_colour
	limit = 0
	wages = PAY::DOCTORATE
	trait_list = list("training_scientist")
	access_string = "Toxins Researcher"
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_lhan = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)
	email_group = MGD_RESEARCH

/datum/job/special/chemist
	name = "Chemist"
	ui_colour = /datum/job/research::ui_colour
	limit = 0
	wages = PAY::DOCTORATE
	trait_list = "training_scientist"
	access_string = "Chemist"
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_jump = list(/obj/item/clothing/under/rank/scientist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_ears = list(/obj/item/device/radio/headset/research)
	wiki_link = "https://wiki.ss13.co/Chemist"
	email_group = MGD_RESEARCH

/datum/job/special/atmospheric_technician
	name = "Atmospherish Technician"
	ui_colour = /datum/job/engineering::ui_colour
	slot_card = /datum/job/engineering::slot_card
	limit = 0
	wages = PAY::TRADESMAN
	access_string = "Atmospheric Technician"
	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/storage/belt/utility/atmos)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/atmos)
	slot_jump = list(/obj/item/clothing/under/misc/atmospheric_technician)
	slot_foot = list(/obj/item/clothing/shoes/black)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_poc1 = list(/obj/item/device/pda2/atmos)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	items_in_backpack = list(/obj/item/clothing/mask/gas/emergency, /obj/item/rcd_ammo/big)
	wiki_link = "https://wiki.ss13.co/Atmospheric_Technician"
	email_group = MGD_ENGINEER

/datum/job/special/comm_officer
	name = "Communications Officer"
	limit = 0
	wages = PAY::IMPORTANT
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
	email_group = MGD_COMMAND

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
	wages = PAY::IMPORTANT
	trait_list = list("training_miner")
	access_string = "Head of Mining"
	ui_colour = /datum/job/command::ui_colour
	invalid_antagonist_roles = list(ROLE_HEAD_REVOLUTIONARY, ROLE_GANG_MEMBER, ROLE_GANG_LEADER, ROLE_SPY_THIEF, ROLE_CONSPIRATOR)
	slot_card = /obj/item/card/id/command
	slot_belt = list(/obj/item/device/pda2/mining)
	slot_jump = list(/obj/item/clothing/under/rank/overalls)
	slot_foot = list(/obj/item/clothing/shoes/orange)
	slot_glov = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	items_in_backpack = list(/obj/item/tank/pocket/oxygen,/obj/item/crowbar)
	email_group = MGD_SUPPLY

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
	wages = PAY::DOCTORATE
	access_string = "Medical Doctor"
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_jump = list(/obj/item/clothing/under/rank/pathologist)
	slot_foot = list(/obj/item/clothing/shoes/white)
	slot_suit = list(/obj/item/clothing/suit/labcoat/pathology)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	email_group = MGD_MEDICAL

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
	email_group = MGD_CIVILIAN

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
	email_group = MGD_CIVILIAN

	items_in_belt = list(
		/obj/item/dagger/silver,
		/obj/item/gun/bow/crossbow/wooden,
		/obj/item/gun/bow/crossbow/wooden,
		/obj/item/handcuffs/silver,
		/obj/item/handcuffs/silver,
	)

/datum/job/special/goon
	name = "Goon"
	access_string = "Staff Assistant"
	limit = 0
	slot_head = list(/obj/item/clothing/head/flatcap/razor)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_jump = list(/obj/item/clothing/under/suit/pinstripe)
	slot_back = list(/obj/item/storage/backpack = 1, /obj/item/storage/backpack/studdedblack = 2)
	slot_foot = list(/obj/item/clothing/shoes/black = 1, /obj/item/clothing/shoes/brown = 1, /obj/item/clothing/shoes/cowboy = 1, /obj/item/clothing/shoes/detective = 1)
	items_in_backpack = list(/obj/item/handcuffs/tape_roll, /obj/item/bat)

