/mob/living/carbon/human/normal
	initializeBioholder()
		. = ..()
		randomize_look(src, 1, 1, 1, 1, 1, 1, src)
		src.gender = src.bioHolder?.mobAppearance?.gender
		src.update_colorful_parts()
		set_clothing_icon_dirty()

/mob/living/carbon/human/normal/assistant
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Staff Assistant")

/mob/living/carbon/human/normal/syndicate
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Syndicate")

/mob/living/carbon/human/normal/captain
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Captain")

/mob/living/carbon/human/normal/headofpersonnel
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Head of Personnel")

/mob/living/carbon/human/normal/chiefengineer
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Chief Engineer")

/mob/living/carbon/human/normal/researchdirector
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Research Director")

/mob/living/carbon/human/normal/headofsecurity
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Head of Security")

/mob/living/carbon/human/normal/securityofficer
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Security Officer")

/mob/living/carbon/human/normal/securityassistant
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Security Assistant")

/mob/living/carbon/human/normal/detective
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Detective")

/mob/living/carbon/human/normal/clown
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Clown")

/mob/living/carbon/human/normal/chef
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Chef")

/mob/living/carbon/human/normal/chaplain
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Chaplain")

/mob/living/carbon/human/normal/bartender
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Bartender")

/mob/living/carbon/human/normal/botanist
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Botanist")

/mob/living/carbon/human/normal/rancher
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Rancher")

/mob/living/carbon/human/normal/janitor
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Janitor")

/mob/living/carbon/human/normal/mechanic
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Mechanic")

/mob/living/carbon/human/normal/engineer
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Engineer")

/mob/living/carbon/human/normal/miner
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Miner")

/mob/living/carbon/human/normal/quartermaster
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Quartermaster")

/mob/living/carbon/human/normal/medicaldoctor
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Medical Doctor")

/mob/living/carbon/human/normal/geneticist
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Geneticist")

/mob/living/carbon/human/normal/pathologist
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Pathologist")

/mob/living/carbon/human/normal/roboticist
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Roboticist")

/mob/living/carbon/human/normal/chemist
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Chemist")

/mob/living/carbon/human/normal/scientist
	initializeBioholder()
		. = ..()
		JobEquipSpawned("Scientist")

/mob/living/carbon/human/normal/wizard
	initializeBioholder()
		. = ..()
		if (src.gender && src.gender == "female")
			src.real_name = pick_string_autokey("names/wizard_female.txt")
		else
			src.real_name = pick_string_autokey("names/wizard_male.txt")

		equip_wizard(src, 1)

/mob/living/carbon/human/normal/rescue
	initializeBioholder()
		. = ..()
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
	initializeBioholder()
		. = ..()
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
