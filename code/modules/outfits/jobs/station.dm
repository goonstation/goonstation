/* ====== COMMAND OUTFITS ====== */

/datum/outfit/command/captain
	outfit_name = "Captain"

	slot_belt = list(/obj/item/device/pda2/captain)
	slot_back = list(/obj/item/storage/backpack/captain)
	slot_under = list(/obj/item/clothing/under/rank/captain)
	slot_outer = list(/obj/item/clothing/suit/armor/captain)
	slot_shoes = list(/obj/item/clothing/shoes/swat/captain)
	slot_gloves = list(/obj/item/clothing/gloves/swat/captain)
	slot_head = list(/obj/item/clothing/head/caphat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list(/obj/item/device/radio/headset/command/captain)
	left_pocket = list(/obj/item/disk/data/floppy/read_only/authentication)
	backpack_items = list(/obj/item/storage/box/id_kit, /obj/item/device/flash)

/datum/outfit/command/captain/derelict
	outfit_name = null

	slot_outer = list(/obj/item/clothing/suit/armor/captain/centcomm)
	slot_under = list(/obj/item/clothing/under/misc/turds)
	slot_head = list(/obj/item/clothing/head/centhat)
	slot_belt = list(/obj/item/tank/emergency_oxygen/extended)
	slot_gloves = list(/obj/item/clothing/gloves/fingerless)
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_eyes = list(/obj/item/clothing/glasses/thermal)
	backpack_items = list(/obj/item/crowbar, /obj/item/device/light/flashlight, /obj/item/camera, /obj/item/gun/energy/egun)

/datum/outfit/command/head_of_personnel
	outfit_name = "Head of Personnel"

#ifdef SUBMARINE_MAP
	slot_outer = list(/obj/item/clothing/suit/armor/hopcoat)
#endif
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_under = list(/obj/item/clothing/under/suit/hop)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command/hop)
	left_pocket = list(/obj/item/pocketwatch)
	backpack_items = list(/obj/item/storage/box/id_kit, /obj/item/device/flash, /obj/item/storage/box/accessimp_kit)

/datum/outfit/command/head_of_security
	outfit_name = "Head of Security"

#ifdef SUBMARINE_MAP
	slot_under = list(/obj/item/clothing/under/rank/head_of_security/fancy_alt)
#else
	slot_under = list(/obj/item/clothing/under/rank/head_of_security)
#endif
	slot_outer = list(/obj/item/clothing/suit/armor/vest)
	slot_back = list(/obj/item/storage/backpack/security)
	slot_belt = list(/obj/item/device/pda2/hos)
	left_pocket = list(/obj/item/requisition_token/security)
	right_pocket = list(/obj/item/storage/security_pouch) //replaces sec starter kit
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_head = list(/obj/item/clothing/head/hos_hat)
	slot_ears = list(/obj/item/device/radio/headset/command/hos)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	backpack_items = list(/obj/item/device/flash)

/datum/outfit/command/head_of_security/derelict
	outfit_name = null//"NT-SO Special Operative"
	slot_outer = list(/obj/item/clothing/suit/armor/NT)
	slot_under = list(/obj/item/clothing/under/misc/turds)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_belt = list(/obj/item/tank/emergency_oxygen/extended)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_eyes = list(/obj/item/clothing/glasses/thermal)
	backpack_items = list(/obj/item/crowbar, /obj/item/device/light/flashlight, /obj/item/breaching_charge, /obj/item/breaching_charge, /obj/item/gun/energy/plasma_gun)

/datum/outfit/command/chief_engineer
	outfit_name = "Chief Engineer"

	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/device/pda2/chiefengineer)
	slot_gloves = list(/obj/item/clothing/gloves/yellow)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat/chief_engineer)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_under = list(/obj/item/clothing/under/rank/chief_engineer)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	left_pocket = list(/obj/item/paper/book/from_file/pocketguide/engineering)
	backpack_items = list(/obj/item/device/flash, /obj/item/rcd_ammo/medium)

/datum/outfit/command/chief_engineer/derelict
	outfit_name = null//"Salvage Chief"

	slot_outer = list(/obj/item/clothing/suit/space/industrial)
	slot_shoes = list(/obj/item/clothing/shoes/magnetic)
	slot_head = list(/obj/item/clothing/head/helmet/space/industrial)
	slot_belt = list(/obj/item/tank/emergency_oxygen)
	slot_mask = list(/obj/item/clothing/mask/gas)
	slot_eyes = list(/obj/item/clothing/glasses/thermal) // mesons look fuckin weird in the dark
	backpack_items = list(/obj/item/crowbar, /obj/item/rcd,/obj/item/rcd_ammo, /obj/item/rcd_ammo, /obj/item/device/light/flashlight, /obj/item/cell/cerenkite)

/datum/outfit/command/research_director
	outfit_name = "Research Director"

	slot_back = list(/obj/item/storage/backpack/research)
	slot_belt = list(/obj/item/device/pda2/research_director)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_under = list(/obj/item/clothing/under/rank/research_director)
	slot_outer = list(/obj/item/clothing/suit/labcoat/research_director)
	right_hand = list(/obj/item/clipboard/with_pen)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	slot_ears = list(/obj/item/device/radio/headset/command/rd)
	backpack_items = list(/obj/item/device/flash)

/datum/outfit/command/medical_director
	outfit_name = "Medical Director"

	slot_back = list(/obj/item/storage/backpack/medic)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_under = list(/obj/item/clothing/under/rank/medical_director)
	slot_outer = list(/obj/item/clothing/suit/labcoat/medical_director)
	slot_ears = list(/obj/item/device/radio/headset/command/md)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	left_pocket = list(/obj/item/device/pda2/medical_director)
	backpack_items = list(/obj/item/device/flash)

/datum/outfit/command/comm_officer
	outfit_name = "Communications Officer"

	slot_ears = list(/obj/item/device/radio/headset/command/comm_officer)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_under = list(/obj/item/clothing/under/rank/comm_officer)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/heads)
	left_pocket = list(/obj/item/pen/fancy)
	slot_head = list(/obj/item/clothing/head/sea_captain/comm_officer_hat)
	backpack_items = list(/obj/item/device/camera_viewer, /obj/item/device/audio_log, /obj/item/device/flash)

/* ====== SECURITY OUTFITS ====== */

/datum/outfit/security/security_officer
	outfit_name = "Security Officer"

	slot_back = list(/obj/item/storage/backpack/security)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_under = list(/obj/item/clothing/under/rank/security)
	slot_outer = list(/obj/item/clothing/suit/armor/vest)
	slot_head = list(/obj/item/clothing/head/helmet/hardhat/security)
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	left_pocket = list(/obj/item/storage/security_pouch)
	right_pocket = list(/obj/item/requisition_token/security)

/datum/outfit/security/security_assistant
	outfit_name = "Security Assistant"

	slot_back = list(/obj/item/storage/backpack/security)
	slot_under = list(/obj/item/clothing/under/rank/security/assistant)
	slot_outer = list()
	slot_gloves = list(/obj/item/clothing/gloves/fingerless)
	slot_head = list(/obj/item/clothing/head/red)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	left_pocket = list(/obj/item/storage/security_pouch/assistant)
	right_pocket = list(/obj/item/requisition_token/security/assistant)
	backpack_items = list(/obj/item/paper/book/from_file/space_law)

/datum/outfit/security/security_officer/derelict
	//outfit_name = "NT-SO Officer"
	outfit_name = null

	slot_outer = list(/obj/item/clothing/suit/armor/NT_alt)
	slot_under = list(/obj/item/clothing/under/misc/turds)
	slot_head = list(/obj/item/clothing/head/helmet/swat)
	slot_gloves = list(/obj/item/clothing/gloves/fingerless)
	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/gun/energy/laser_gun)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	backpack_items = list(/obj/item/crowbar, /obj/item/device/light/flashlight, /obj/item/baton, /obj/item/breaching_charge, /obj/item/breaching_charge)

/datum/outfit/security/detective
	outfit_name = "Detective"

	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/storage/belt/security/shoulder_holster)
	left_pocket = list(/obj/item/device/pda2/forensic)
	slot_under = list(/obj/item/clothing/under/rank/det)
	slot_shoes = list(/obj/item/clothing/shoes/detective)
	slot_head = list(/obj/item/clothing/head/det_hat)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_outer = list(/obj/item/clothing/suit/det_suit)
	slot_ears = list(/obj/item/device/radio/headset/detective)
	backpack_items = list(/obj/item/clothing/glasses/vr, /obj/item/storage/box/detectivegun)

/* ====== MED/SCI JOBS ====== */

/datum/outfit/research/geneticist
	outfit_name = "Geneticist"

	slot_back = list(/obj/item/storage/backpack/genetics)
	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_under = list(/obj/item/clothing/under/rank/geneticist)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	slot_outer = list(/obj/item/clothing/suit/labcoat/genetics)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	left_pocket = list(/obj/item/device/analyzer/genetic)

/datum/outfit/pathologist
	outfit_name = "Pathologist"

	slot_belt = list(/obj/item/device/pda2/genetics)
	slot_under = list(/obj/item/clothing/under/rank/pathologist)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	slot_outer = list(/obj/item/clothing/suit/labcoat/pathology)
#ifdef SCIENCE_PATHO_MAP
	slot_ears = list(/obj/item/device/radio/headset/research)
#else
	slot_ears = list(/obj/item/device/radio/headset/medical)
#endif

/datum/outfit/research/roboticist
	outfit_name = "Roboticist"

	slot_back = list(/obj/item/storage/backpack/robotics)
	slot_belt = list(/obj/item/storage/belt/roboticist/prepared)
	slot_under = list(/obj/item/clothing/under/rank/roboticist)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_outer = list(/obj/item/clothing/suit/labcoat/robotics)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	left_pocket = list(/obj/item/device/pda2/medical/robotics)
	right_pocket = list(/obj/item/reagent_containers/mender/brute)

/datum/outfit/research/scientist
	outfit_name = "Scientist"

	slot_back = list(/obj/item/storage/backpack/research)
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_under = list(/obj/item/clothing/under/rank/scientist)
	slot_outer = list(/obj/item/clothing/suit/labcoat)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	left_hand = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)
	slot_eyes = list(/obj/item/clothing/glasses/spectro)
	left_pocket = list(/obj/item/pen = 50, /obj/item/pen/fancy = 25, /obj/item/pen/red = 5, /obj/item/pen/pencil = 20)

/datum/outfit/research/medical_doctor
	outfit_name = "Medical Doctor"

	slot_back = list(/obj/item/storage/backpack/medic)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_under = list(/obj/item/clothing/under/rank/medical)
	slot_outer = list(/obj/item/clothing/suit/labcoat/medical)
	slot_shoes = list(/obj/item/clothing/shoes/red)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	left_pocket = list(/obj/item/device/pda2/medical)
	right_pocket = list(/obj/item/paper/book/from_file/pocketguide/medical)
	backpack_items = list(/obj/item/crowbar/blue)

/datum/outfit/research/medical_doctor/derelict
	//outfit_name = "Salvage Medic"
	outfit_name = null

	slot_outer = list(/obj/item/clothing/suit/armor/vest)
	slot_head = list(/obj/item/clothing/head/helmet/swat)
	slot_belt = list(/obj/item/tank/emergency_oxygen)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	backpack_items = list(/obj/item/crowbar, /obj/item/device/light/flashlight, /obj/item/storage/firstaid/regular, /obj/item/storage/firstaid/regular)

/* ====== ENGINEERING OUTFITS ====== */

/datum/outfit/engineering/quartermaster
	outfit_name = "Quartermaster"

	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_under = list(/obj/item/clothing/under/rank/cargo)
	slot_belt = list(/obj/item/device/pda2/quartermaster)
	slot_ears = list(/obj/item/device/radio/headset/shipping)
	slot_back = list(/obj/item/storage/backpack)
	left_pocket = list(/obj/item/paper/book/from_file/pocketguide/quartermaster)
	right_pocket = list(/obj/item/device/appraisal)

/datum/outfit/engineering/miner
	outfit_name = "Miner"

	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_belt = list(/obj/item/storage/belt/mining/prepared)
	slot_under = list(/obj/item/clothing/under/rank/overalls)
	slot_shoes = list(/obj/item/clothing/shoes/orange)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/miner)
	left_pocket = list(/obj/item/device/pda2/mining)
#ifdef UNDERWATER_MAP
	slot_outer = list(/obj/item/clothing/suit/space/diving/engineering)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	backpack_items = list(/obj/item/paper/book/from_file/pocketguide/mining,
							/obj/item/clothing/shoes/flippers,
							/obj/item/item_box/glow_sticker)
#else
	slot_outer = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	backpack_items = list(/obj/item/crowbar,
							/obj/item/paper/book/from_file/pocketguide/mining)
#endif

/datum/outfit/engineering/engineer
	outfit_name = "Engineer"

	slot_back = list(/obj/item/storage/backpack/engineering)
	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_under = list(/obj/item/clothing/under/rank/engineer)
	slot_shoes = list(/obj/item/clothing/shoes/orange)
	left_hand = list(/obj/item/storage/toolbox/mechanical/engineer_spawn)
	slot_gloves = list(/obj/item/clothing/gloves/yellow)
	left_pocket = list(/obj/item/device/pda2/engine)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
#ifdef MAP_OVERRIDE_OSHAN
	backpack_items = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/clothing/shoes/stomp_boots)
#else
	backpack_items = list(/obj/item/paper/book/from_file/pocketguide/engineering, /obj/item/old_grenade/oxygen)
#endif

/datum/outfit/engineering/engineer/derelict
	outfit_name = null//"Salvage Engineer"

	slot_outer = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/welding)
	slot_belt = list(/obj/item/tank/emergency_oxygen)
	slot_mask = list(/obj/item/clothing/mask/breath)
	backpack_items = list(/obj/item/crowbar, /obj/item/device/light/flashlight, /obj/item/device/light/glowstick,
			/obj/item/gun/kinetic/flaregun, /obj/item/ammo/bullets/flare, /obj/item/cell/cerenkite)

/* ====== CIVILLIAN OUTFITS ====== */

/datum/outfit/civilian/chef
	outfit_name = "Chef"

	slot_belt = list(/obj/item/device/pda2/chef)
	slot_under = list(/obj/item/clothing/under/rank/chef)
	slot_shoes = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/chefhat)
	slot_outer = list(/obj/item/clothing/suit/chef)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	backpack_items = list(/obj/item/kitchen/rollingpin, /obj/item/kitchen/utensil/knife/cleaver, /obj/item/bell/kitchen)

/datum/outfit/civilian/bartender
	outfit_name = "Bartender"

	slot_belt = list(/obj/item/device/pda2/bartender)
	slot_under = list(/obj/item/clothing/under/rank/bartender)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_outer = list(/obj/item/clothing/suit/armor/vest)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	left_pocket = list(/obj/item/cloth/towel/bar)
	right_pocket = list(/obj/item/reagent_containers/food/drinks/cocktailshaker)
	backpack_items = list(/obj/item/gun/kinetic/sawnoff, /obj/item/ammo/bullets/abg, /obj/item/paper/book/from_file/pocketguide/bartending)

/datum/outfit/civilian/botanist
	outfit_name = "Botanist"

	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_under = list(/obj/item/clothing/under/rank/hydroponics)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	left_pocket = list(/obj/item/paper/botany_guide)

/datum/outfit/civilian/rancher
	outfit_name = "Rancher"

	slot_belt = list(/obj/item/storage/belt/rancher/prepared)
	slot_under = list(/obj/item/clothing/under/rank/rancher)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_shoes = list(/obj/item/clothing/shoes/westboot/brown/rancher)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	left_pocket = list(/obj/item/paper/ranch_guide)
	right_pocket = list(/obj/item/device/pda2/botanist)
	backpack_items = list(/obj/item/device/camera_viewer/ranch, /obj/item/storage/box/knitting)

/datum/outfit/civilian/janitor
	outfit_name = "Janitor"

	slot_belt = list(/obj/item/storage/fanny/janny)
	slot_under = list(/obj/item/clothing/under/rank/janitor)
	slot_shoes = list(/obj/item/clothing/shoes/galoshes)
	slot_gloves = list(/obj/item/clothing/gloves/long)
	right_hand = list(/obj/item/mop)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	left_pocket = list(/obj/item/device/pda2/janitor)
	backpack_items = list(/obj/item/reagent_containers/glass/bucket)

/datum/outfit/civilian/chaplain
	outfit_name = "Chaplain"

	slot_under = list(/obj/item/clothing/under/rank/chaplain)
	slot_belt = list(/obj/item/device/pda2/chaplain)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	left_hand = list(/obj/item/bible/loaded)

/datum/outfit/civilian/staff_assistant
	outfit_name = "Staff Assistant"

	slot_under = list(/obj/item/clothing/under/rank/assistant)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2)

/datum/outfit/civilian/clown
	outfit_name = "Clown"

	slot_belt = list(/obj/item/storage/fanny/funny)
	slot_mask = list(/obj/item/clothing/mask/clown_hat)
	slot_under = list(/obj/item/clothing/under/misc/clown)
	slot_shoes = list(/obj/item/clothing/shoes/clown_shoes)
	slot_ears = list(/obj/item/device/radio/headset/clown)
	left_hand = list(/obj/item/instrument/bikehorn)
	left_pocket = list(/obj/item/device/pda2/clown)
	right_pocket = list(/obj/item/reagent_containers/food/snacks/plant/banana)
	belt_items = list(/obj/item/cloth/towel/clown)
