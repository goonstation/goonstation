/datum/antagonist/pirate
	id = ROLE_PIRATE
	display_name = "Pirate"

	var/pirate_captain = FALSE
	var/pirate_first_mate = FALSE

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, "<span class='alert'>Due to your lack of opposable thumbs, the pirates were unable to provide you with your equipment. That's biology for you.</span>")
			return FALSE
		var/mob/living/carbon/human/H = src.owner.current

		if (id == ROLE_PIRATE_CAPTAIN)
			H.force_equip(new /obj/item/clothing/under/shirt_pants_b(H), H.slot_w_uniform)
			H.force_equip(new /obj/item/clothing/suit/armor/pirate_captain_coat(H), H.slot_wear_suit)
			H.force_equip(new /obj/item/clothing/head/pirate_captain(H), H.slot_head)
			H.force_equip(new /obj/item/clothing/shoes/swat/heavy(H), H.slot_shoes)
			H.force_equip(new /obj/item/device/radio/headset/pirate/captain(H), H.slot_ears)
			H.force_equip(new /obj/item/pinpointer/gold_bee(H), H.slot_l_store)

		else if (id == ROLE_PIRATE_FIRST_MATE)
			H.force_equip(new /obj/item/clothing/under/gimmick/guybrush(H), H.slot_w_uniform)
			H.force_equip(new /obj/item/clothing/suit/gimmick/guncoat/tan(H), H.slot_wear_suit)
			H.force_equip(new /obj/item/clothing/head/pirate_brn(H), H.slot_head)
			H.force_equip(new /obj/item/device/radio/headset/pirate/first_mate(H), H.slot_ears)

		else if (id == ROLE_PIRATE)
			// Random clothing:
			var/obj/item/clothing/jumpsuit = pick(/obj/item/clothing/under/gimmick/waldo,
							/obj/item/clothing/under/misc/serpico,
							/obj/item/clothing/under/gimmick/guybrush,
							/obj/item/clothing/under/misc/dirty_vest)
			var/obj/item/clothing/hat = pick(/obj/item/clothing/head/red,
							/obj/item/clothing/head/bandana/red,
							/obj/item/clothing/head/pirate_brn)

			H.force_equip(new jumpsuit, H.slot_w_uniform)
			H.force_equip(new hat, H.slot_head)
			H.force_equip(new /obj/item/device/radio/headset/pirate(H), H.slot_ears)

		H.force_equip(new /obj/item/clothing/shoes/swat(H), H.slot_shoes)
		H.force_equip(new /obj/item/storage/backpack(H), H.slot_back)
		H.force_equip(new /obj/item/clothing/glasses/eyepatch/pirate(H), H.slot_glasses)
		H.force_equip(new /obj/item/tank/emergency_oxygen/extended(H), H.slot_r_store)
		H.force_equip(new /obj/item/swords_sheaths/pirate(H), H.slot_belt)

		H.equip_sensory_items()

		H.traitHolder.addTrait("training_drinker")

	// assign_objectives()

	// do_popup(override)
	// 	if (pirate_captain)
	// 		override = "pirate_captain"
	// 	else if (pirate_first_mate)
	// 		override = "pirate_first_mate"
	// 	..(override)

	// handle_round_end(log_data)


	first_mate
		id = ROLE_PIRATE_FIRST_MATE
		display_name = "Pirate First Mate"
		pirate_first_mate = TRUE

	captain
		id = ROLE_PIRATE_CAPTAIN
		display_name = "Pirate Captain"
		pirate_captain = TRUE
