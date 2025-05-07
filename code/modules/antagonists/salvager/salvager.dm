/datum/antagonist/salvager
	id = ROLE_SALVAGER
	display_name = ROLE_SALVAGER
	antagonist_icon = "salvager"
	uses_pref_name = FALSE
	wiki_link = "https://wiki.ss13.co/Salvager"

	var/static/starting_freq = null
	var/salvager_points

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		H.traitHolder.removeAll()
		// You are... no one...
		randomize_look(H, change_gender=FALSE)
		H.bioHolder.mobAppearance.flavor_text = null
		H.unequip_all(TRUE)

		H.equip_if_possible(new /obj/item/clothing/head/helmet/space/engineer/salvager(H), SLOT_HEAD)
		H.equip_if_possible(new /obj/item/clothing/suit/space/salvager(H), SLOT_WEAR_SUIT)
		H.equip_if_possible(new /obj/item/clothing/glasses/salvager(H), SLOT_GLASSES)

		var/obj/item/device/radio/headset/headset = H.ears
		if(!headset)
			headset = new /obj/item/device/radio/headset/salvager
			H.equip_if_possible(headset, SLOT_EARS)
		else
			headset.protected_radio = TRUE

		// Allow for Salvagers to have a secure channel
		headset.secure_frequencies = list("z" = src.pick_radio_freq())
		headset.secure_classes = list(RADIOCL_OTHER)
		headset.secure_colors = list("#a18146")
		headset.set_secure_frequency("z", src.pick_radio_freq())
		headset.desc += " The headset is covered in scratch marks and the screws look nearly stripped."

		H.equip_if_possible(new /obj/item/clothing/under/color/grey(H), SLOT_W_UNIFORM)
		H.equip_if_possible(new /obj/item/storage/backpack/salvager(H), SLOT_BACK)
		H.equip_if_possible(new /obj/item/clothing/mask/breath(H), SLOT_WEAR_MASK)
		H.equip_if_possible(new /obj/item/tank/pocket/extended/oxygen(H), SLOT_L_STORE)
		H.equip_if_possible(new /obj/item/ore_scoop/prepared(H), SLOT_R_STORE)
		H.equip_if_possible(new /obj/item/clothing/shoes/magnetic(H), SLOT_SHOES)
		H.equip_if_possible(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
		H.equip_if_possible(new /obj/item/salvager(H), SLOT_BELT)
		H.equip_if_possible(new /obj/item/device/pda2/salvager(H), SLOT_WEAR_ID)
		var/obj/item/device/pda2/salvager_pda = locate() in H
		salvager_pda.insert_id_card(new /obj/item/card/id/salvager(H), H)

		H.equip_new_if_possible(/obj/item/storage/box/salvager_frame_compartment, SLOT_IN_BACKPACK)
		H.equip_new_if_possible(/obj/item/salvager_hand_tele, SLOT_IN_BACKPACK)
		H.equip_new_if_possible(/obj/item/deconstructor, SLOT_IN_BACKPACK)
		H.equip_new_if_possible(/obj/item/tool/omnitool, SLOT_IN_BACKPACK)
		H.equip_new_if_possible(/obj/item/weldingtool, SLOT_IN_BACKPACK)

		// we don't need to add body or sensory trait items as we have removed all traits above
		H.traitHolder.addTrait("training_engineer")

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_SALVAGER)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_SALVAGER)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		new /datum/objective_set/salvager(src.owner, src)

	relocate()
		if (!landmarks[LANDMARK_SALVAGER])
			message_admins(SPAN_ALERT("<b>ERROR: couldn't find Salvager spawn landmark, aborting relocation.</b>"))
			return 0

		if(length(by_type[/obj/salvager_cryotron]))
			src.owner.current.set_loc(pick(by_type[/obj/salvager_cryotron]))
		else
			src.owner.current.set_loc(pick(landmarks[LANDMARK_SALVAGER]))

	proc/pick_radio_freq()
		if(starting_freq)
			return starting_freq

		var/list/blacklisted = list(0, 1451, 1457)
		blacklisted.Add(R_FREQ_BLACKLIST)

		do
			. = rand(R_FREQ_MINIMUM, R_FREQ_MAXIMUM)
			. = sanitize_frequency(.)
		while (. in blacklisted)

		starting_freq = .

	handle_round_end()
		. = ..()

		logTheThing(LOG_DIARY, src.owner, "collected [src.salvager_points || 0] points worth of material.")

	get_statistics()
		return list(
			list(
				"name" = "Collected Material Points",
				"value" = "[src.salvager_points]",
			)
		)

/datum/job/special/salvager
	name = "Salvager"
	wages = 0
	limit = 0
	linkcolor = "#acbb27"
	slot_ears = list() // So they don't get a default headset and stuff first.
	slot_card = null
	slot_glov = list()
	slot_foot = list()
	slot_back = list()
	slot_belt = list()
	spawn_id = FALSE
	radio_announcement = FALSE
	add_to_manifest = FALSE

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_SALVAGER, source = ANTAGONIST_SOURCE_ADMIN)
		return

// Stubs for the public
/datum/objective_set/salvager
