/mob/living/carbon/human/normal
	initializeBioholder(gender)
		if (gender)
			src.gender = gender
		. = ..()
		randomize_look(src, !gender, 1, 1, 1, 1, 1, src)
		src.gender = src.bioHolder?.mobAppearance?.gender
		src.update_colorful_parts()
		set_clothing_icon_dirty()

/mob/living/carbon/human/normal/assistant
	New()
		..()
		JobEquipSpawned("Staff Assistant")

/mob/living/carbon/human/normal/syndicate
	New()
		..()
		JobEquipSpawned("Syndicate Operative")

/mob/living/carbon/human/normal/captain
	New()
		..()
		JobEquipSpawned("Captain")

/mob/living/carbon/human/normal/headofpersonnel
	New()
		..()
		JobEquipSpawned("Head of Personnel")

/mob/living/carbon/human/normal/chiefengineer
	New()
		..()
		JobEquipSpawned("Chief Engineer")

/mob/living/carbon/human/normal/researchdirector
	New()
		..()
		JobEquipSpawned("Research Director")

/mob/living/carbon/human/normal/medicaldirector
	New()
		..()
		JobEquipSpawned("Medical Director")

/mob/living/carbon/human/normal/headofsecurity
	New()
		..()
		JobEquipSpawned("Head of Security")

/mob/living/carbon/human/normal/securityofficer
	New()
		..()
		JobEquipSpawned("Security Officer")

/mob/living/carbon/human/normal/securityassistant
	New()
		..()
		JobEquipSpawned("Security Assistant")

/mob/living/carbon/human/normal/detective
	New()
		..()
		JobEquipSpawned("Detective")

/mob/living/carbon/human/normal/clown
	New()
		..()
		JobEquipSpawned("Clown")

/mob/living/carbon/human/normal/chef
	New()
		..()
		JobEquipSpawned("Chef")

/mob/living/carbon/human/normal/chaplain
	New()
		..()
		JobEquipSpawned("Chaplain")

/mob/living/carbon/human/normal/bartender
	New()
		..()
		JobEquipSpawned("Bartender")

/mob/living/carbon/human/normal/botanist
	New()
		..()
		JobEquipSpawned("Botanist")

/mob/living/carbon/human/normal/rancher
	New()
		..()
		JobEquipSpawned("Rancher")

/mob/living/carbon/human/normal/janitor
	New()
		..()
		JobEquipSpawned("Janitor")

/mob/living/carbon/human/normal/engineer
	New()
		..()
		JobEquipSpawned("Engineer")

/mob/living/carbon/human/normal/miner
	New()
		..()
		JobEquipSpawned("Miner")

/mob/living/carbon/human/normal/quartermaster
	New()
		..()
		JobEquipSpawned("Quartermaster")

/mob/living/carbon/human/normal/medicaldoctor
	New()
		..()
		JobEquipSpawned("Medical Doctor")

/mob/living/carbon/human/normal/geneticist
	New()
		..()
		JobEquipSpawned("Geneticist")

/mob/living/carbon/human/normal/pathologist
	New()
		..()
		JobEquipSpawned("Pathologist")

/mob/living/carbon/human/normal/roboticist
	New()
		..()
		JobEquipSpawned("Roboticist")

/mob/living/carbon/human/normal/chemist
	New()
		..()
		JobEquipSpawned("Chemist")

/mob/living/carbon/human/normal/scientist
	New()
		..()
		JobEquipSpawned("Scientist")

/mob/living/carbon/human/normal/ntsc
	New()
		..()
		JobEquipSpawned("Nanotrasen Security Consultant")

/mob/living/carbon/human/normal/inspector
	New()
		..()
		JobEquipSpawned("Inspector")

/mob/living/carbon/human/normal/rescue
	New()
		..()
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

/mob/living/carbon/human/normal/ntso_old
	New()
		..()
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
