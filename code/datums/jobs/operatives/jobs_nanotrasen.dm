ABSTRACT_TYPE(/datum/job/special/nt)
/datum/job/special/nt
	ui_colour = TGUI_COLOUR_NAVY
	job_category = JOB_NANOTRASEN
	limit = 0
	wages = PAY_IMPORTANT
	//Emergency responders shouldn't be antags
	can_roll_antag = FALSE
	badge = /obj/item/clothing/suit/security_badge/nanotrasen
	receives_implants = list(/obj/item/implant/health/security/anti_mindhack)
	access_string = "Nanotrasen Responder" // "All Access" + Centcom

	slot_back = list(/obj/item/storage/backpack/NT)
	slot_jump = list(/obj/item/clothing/under/misc/turds)
	slot_foot = list(/obj/item/clothing/shoes/swat)
	slot_glov = list(/obj/item/clothing/gloves/swat/NT)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_card = /obj/item/card/id/nanotrasen
	faction = list(FACTION_NANOTRASEN)

/datum/job/special/nt/special_operative
	name = "Nanotrasen Special Operative"
	trait_list = list("training_security")
	receives_miranda = TRUE
	slot_belt = list(/obj/item/storage/belt/security/ntso)
	slot_suit = list(/obj/item/clothing/suit/space/ntso)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_eyes = list(/obj/item/clothing/glasses/nightvision/sechud/flashblocking)
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_poc1 = list(/obj/item/device/pda2/ntso)
	slot_poc2 = list(/obj/item/storage/ntsc_pouch/ntso)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/clothing/head/NTberet)

/datum/job/special/nt/commander
	name = "Nanotrasen Commander"
	trait_list = list("training_security", "training_medical")
	wages = PAY_EXECUTIVE //The big boss
	receives_miranda = TRUE
	receives_disk = /obj/item/disk/data/floppy/sec_command

	slot_belt = list(/obj/item/swords_sheaths/ntboss)
	slot_jump = list(/obj/item/clothing/under/misc/NT)
	slot_suit = list(/obj/item/clothing/suit/space/nanotrasen/pilot/commander)
	slot_head = list(/obj/item/clothing/head/NTberet/commander)
	slot_foot = list(/obj/item/clothing/shoes/swat/heavy)
	slot_eyes = list(/obj/item/clothing/glasses/nt_operative)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/commander)
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_poc1 = list(/obj/item/device/pda2/ntso)
	slot_poc2 = list(/obj/item/storage/ntsc_pouch/ntso)
	items_in_backpack = list(/obj/item/storage/firstaid/regular)


/datum/job/special/nt/engineer
	name = "Nanotrasen Emergency Repair Technician"
	trait_list = list("training_engineer")

	slot_belt = list(/obj/item/storage/belt/utility/nt_engineer)
	slot_jump = list(/obj/item/clothing/under/rank/engineer)
	slot_suit = list(/obj/item/clothing/suit/space/industrial/nt_specialist)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_foot = list(/obj/item/clothing/shoes/magnetic)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/engineer)
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_poc1 = list(/obj/item/tank/pocket/extended/oxygen)
	slot_poc2 = list(/obj/item/device/pda2/nt_engineer)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/device/flash,
							/obj/item/sheet/steel/fullstack,
							/obj/item/sheet/glass/reinforced/fullstack)

	special_setup(var/mob/living/carbon/human/M)
		..()
		SPAWN(1)
			var/obj/item/rcd/rcd = locate() in M.belt.storage.stored_items
			rcd.matter = 100
			rcd.max_matter = 100
			rcd.tooltip_rebuild = TRUE
			rcd.UpdateIcon()

/datum/job/special/nt/medic
	name = "Nanotrasen Emergency Medic"
	trait_list = list("training_medical")

	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_jump = list(/obj/item/clothing/under/rank/medical)
	slot_suit = list(/obj/item/clothing/suit/hazard/paramedic/armored)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_foot = list(/obj/item/clothing/shoes/brown)
	slot_glov = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/medic)
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_poc1 = list(/obj/item/tank/pocket/extended/oxygen)
	slot_poc2 = list(/obj/item/device/pda2/nt_medical)
	items_in_backpack = list(/obj/item/storage/firstaid/regular,
							/obj/item/device/flash,
							/obj/item/reagent_containers/glass/bottle/omnizine,
							/obj/item/reagent_containers/glass/bottle/ether)

// Use this one for late respawns to deal with existing antags. they are weaker cause they dont get a laser rifle or frags
/datum/job/special/nt/security_consultant
	name = "Nanotrasen Security Consultant"
	limit = 1 // backup during HELL WEEK. players will probably like it
	unique = TRUE
	wages = PAY_TRADESMAN
	trait_list = list("training_security")
	access_string = "Nanotrasen Security Consultant"
	requires_whitelist = TRUE
	requires_supervisor_job = "Head of Security"
	counts_as = "Security Officer"
	receives_miranda = TRUE

	slot_belt = list(/obj/item/storage/belt/security/ntsc)
	slot_suit = list(/obj/item/clothing/suit/space/ntso)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/consultant)
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	slot_poc1 = list(/obj/item/storage/ntsc_pouch)
	slot_poc2 = list(/obj/item/device/pda2/ntso)
	items_in_backpack = list(/obj/item/storage/firstaid/regular)
	wiki_link = "https://wiki.ss13.co/Nanotrasen_Security_Consultant"
