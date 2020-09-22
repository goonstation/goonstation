/mob/living/carbon/human/normal
	New()
		..()
		SPAWN_DBG(0)
			randomize_look(src, 1, 1, 1, 1, 1, 1)

		SPAWN_DBG(1 SECOND)
			set_clothing_icon_dirty()

/mob/living/carbon/human/normal/assistant
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Staff Assistant")

/mob/living/carbon/human/normal/syndicate
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Syndicate")

/mob/living/carbon/human/normal/captain
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Captain")

/mob/living/carbon/human/normal/headofpersonnel
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Head of Personnel")

/mob/living/carbon/human/normal/chiefengineer
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chief Engineer")

/mob/living/carbon/human/normal/researchdirector
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Research Director")

/mob/living/carbon/human/normal/headofsecurity
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Head of Security")

/mob/living/carbon/human/normal/securityofficer
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Security Officer")

/mob/living/carbon/human/normal/detective
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Detective")

/mob/living/carbon/human/normal/clown
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Clown")

/mob/living/carbon/human/normal/chef
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chef")

/mob/living/carbon/human/normal/chaplain
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chaplain")

/mob/living/carbon/human/normal/barman
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Barman")

/mob/living/carbon/human/normal/botanist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Botanist")

/mob/living/carbon/human/normal/janitor
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Janitor")

/mob/living/carbon/human/normal/mechanic
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Mechanic")

/mob/living/carbon/human/normal/engineer
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Engineer")

/mob/living/carbon/human/normal/miner
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Miner")

/mob/living/carbon/human/normal/quartermaster
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Quartermaster")

/mob/living/carbon/human/normal/medicaldoctor
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Medical Doctor")

/mob/living/carbon/human/normal/geneticist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Geneticist")

/mob/living/carbon/human/normal/roboticist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Roboticist")

/mob/living/carbon/human/normal/chemist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Chemist")

/mob/living/carbon/human/normal/scientist
	New()
		..()
		SPAWN_DBG(0)
			JobEquipSpawned("Scientist")

/mob/living/carbon/human/normal/wizard
	New()
		..()
		SPAWN_DBG(0)
			if (src.gender && src.gender == "female")
				src.real_name = pick_string_autokey("names/wizard_female.txt")
			else
				src.real_name = pick_string_autokey("names/wizard_male.txt")

			equip_wizard(src, 1)
		return

/mob/living/carbon/human/normal/rescue
	New()
		..()
		SPAWN_DBG(0)
			src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/color/red, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/card/id, slot_wear_id)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/belt/utility/prepared, slot_belt)
			src.equip_new_if_possible(/obj/item/storage/backpack/withO2, slot_back)
			src.equip_new_if_possible(/obj/item/device/light/flashlight, slot_l_store)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/vest, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/mask/gas, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/gloves/black, slot_gloves)
			src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, slot_glasses)

			var/obj/item/card/id/C = src.wear_id
			if(C)
				C.registered = src.real_name
				C.assignment = "NT-SO Rescue Worker"
				C.name = "[C.registered]'s ID Card ([C.assignment])"
				C.access = get_all_accesses()

			update_clothing()

/mob/living/carbon/human/normal/ntso
	New()
		..()
		SPAWN_DBG(0)
			src.equip_new_if_possible(/obj/item/clothing/shoes/swat, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/NT, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/card/id, slot_wear_id)
			src.equip_new_if_possible(/obj/item/device/radio/headset/command/captain, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/belt/security, slot_belt)
			src.equip_new_if_possible(/obj/item/storage/backpack/NT, slot_back)
			src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, slot_l_store)
			src.equip_new_if_possible(/obj/item/crowbar, slot_r_store)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/NT_alt, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/mask/gas/swat, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/head/NTberet, slot_head)
			src.equip_new_if_possible(/obj/item/clothing/gloves/black, slot_gloves)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses/sechud, slot_glasses)

			var/obj/item/card/id/C = src.wear_id
			if(C)
				C.registered = src.real_name
				C.assignment = "NT-SO Special Operative"
				C.name = "[C.registered]'s ID Card ([C.assignment])"
				var/list/ntso_access = get_all_accesses()
				ntso_access += access_maxsec // This makes sense, right? They're highly trained and trusted.
				C.access = ntso_access

			update_clothing()
