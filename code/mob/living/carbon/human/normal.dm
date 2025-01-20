/mob/living/carbon/human/normal
	name = "Random Human"
	initializeBioholder(gender)
		if (gender)
			src.gender = gender
		. = ..()
		randomize_look(src, !gender, 1, 1, 1, 1, 1, src)
		src.gender = src.bioHolder?.mobAppearance?.gender

/mob/living/carbon/human/normal/assistant
	New()
		..()
		JobEquipSpawned("Staff Assistant")

/mob/living/carbon/human/normal/syndicate
	New()
		..()
		JobEquipSpawned("Junior Syndicate Operative")

/mob/living/carbon/human/normal/syndicate_old
	New()
		..()
		src.equip_if_possible(new /obj/item/storage/backpack/syndie, SLOT_BACK)
		src.equip_if_possible(new /obj/item/clothing/under/misc/syndicate, SLOT_W_UNIFORM)
		src.equip_if_possible(new /obj/item/clothing/shoes/swat, SLOT_SHOES)
		src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/tanning, SLOT_GLASSES)
		src.equip_if_possible(new /obj/item/clothing/mask/gas/swat, SLOT_WEAR_MASK)
		src.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended, SLOT_L_STORE)
		src.equip_if_possible(new /obj/item/device/radio/headset/syndicate, SLOT_EARS)
		var/obj/item/card/id/ID = new/obj/item/card/id(src)
		ID.name = "Syndicate Identification Card"
		ID.assignment = "Syndicate Agent"
		ID.registered = "[src.real_name]"
		ID.icon = 'icons/obj/items/card.dmi'
		ID.icon_state = "id_syndie"
		ID.desc = "A Syndicate Agent Identification card."
		src.equip_if_possible(ID, SLOT_WEAR_ID)

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

/mob/living/carbon/human/normal/gang_respawn
	New(var/gender) //force IDs and stuff to spawn for the correct gender
		src.gender = gender
		..()
		JobEquipSpawned("Gang Respawn")


/mob/living/carbon/human/normal/rescue
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/shoes/red, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/color/red, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/card/id, SLOT_WEAR_ID)
		src.equip_new_if_possible(/obj/item/device/radio/headset, SLOT_EARS)
		src.equip_new_if_possible(/obj/item/storage/belt/utility/prepared, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/storage/backpack/withO2, SLOT_BACK)
		src.equip_new_if_possible(/obj/item/device/light/flashlight, SLOT_L_STORE)
		src.equip_new_if_possible(/obj/item/clothing/suit/armor/vest, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/mask/gas, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/gloves/black, SLOT_GLOVES)
		src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, SLOT_GLASSES)

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
		src.equip_new_if_possible(/obj/item/clothing/shoes/swat, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/NT, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/card/id, SLOT_WEAR_ID)
		src.equip_new_if_possible(/obj/item/device/radio/headset/command/captain, SLOT_EARS)
		src.equip_new_if_possible(/obj/item/storage/belt/security, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/storage/backpack/NT, SLOT_BACK)
		src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, SLOT_L_STORE)
		src.equip_new_if_possible(/obj/item/crowbar, SLOT_R_STORE)
		src.equip_new_if_possible(/obj/item/clothing/suit/armor/NT_alt, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/mask/gas/swat, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/head/NTberet, SLOT_HEAD)
		src.equip_new_if_possible(/obj/item/clothing/gloves/black, SLOT_GLOVES)
		src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses/sechud, SLOT_GLASSES)

		var/obj/item/card/id/C = src.wear_id
		if(C)
			C.registered = src.real_name
			C.assignment = "NT-SO Special Operative"
			C.name = "[C.registered]'s ID Card ([C.assignment])"
			var/list/ntso_access = get_all_accesses()
			ntso_access += access_armory // This makes sense, right? They're highly trained and trusted.
			C.access = ntso_access

		update_clothing()

/mob/living/carbon/human/normal/random_clothes
	var/static/valid_back_item_types
	New()
		. = ..()
		if (!valid_back_item_types)
			valid_back_item_types = list()
			for (var/type in concrete_typesof(/obj/item/clothing/suit))
				if (initial(type:c_flags) & ONBACK)
					valid_back_item_types += type
		var/newback = pick(valid_back_item_types)
		var/newhat = pick(concrete_typesof(/obj/item/clothing/head))
		var/newsuit = pick(concrete_typesof(/obj/item/clothing/suit))
		var/newgloves = pick(concrete_typesof(/obj/item/clothing/gloves))
		var/newunder = pick(concrete_typesof(/obj/item/clothing/under))
		var/newbelt = pick(concrete_typesof(/obj/item/storage/belt) + concrete_typesof(/obj/item/storage/fanny))
		var/newshoes = pick(concrete_typesof(/obj/item/clothing/shoes))

		src.equip_new_if_possible(newback, SLOT_BACK)
		src.equip_new_if_possible(newhat, SLOT_HEAD)
		src.equip_new_if_possible(newsuit, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(newgloves, SLOT_GLOVES)
		src.equip_new_if_possible(newunder, SLOT_W_UNIFORM)
		src.equip_new_if_possible(newbelt, SLOT_BELT)
		src.equip_new_if_possible(newshoes, SLOT_SHOES)

/mob/living/carbon/human/normal/baller
	New()
		. = ..()
		src.equip_new_if_possible(pick(concrete_typesof(/obj/item/clothing/under/jersey)), SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/white, SLOT_SHOES) //sneakers or something
		src.throw_mode_on()

	hitby(obj/item/item, datum/thrown_thing/thr)
		. = ..()
		if (!(item in src))
			return
		SPAWN(0)
			src.drop_item(item)
			item.throw_at(thr.thrown_by, 10, 1, thrown_by = src, thrown_from = get_turf(src))
			src.throw_mode_on()
