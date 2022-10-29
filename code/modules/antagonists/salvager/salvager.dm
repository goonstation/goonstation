/datum/antagonist/salvager
	id = ROLE_SALVAGER
	display_name = ROLE_SALVAGER

	var/static/datum/allocated_region/home_base
	var/static/building_base = FALSE
	var/static/starting_freq = null

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current

		// You are... no one...
		randomize_look(H, change_gender=FALSE)
		H.bioHolder.mobAppearance.flavor_text = null
		H.unequip_all(TRUE)
		H.equip_sensory_items()

		H.equip_if_possible(new /obj/item/clothing/head/helmet/space/engineer/salvager(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/suit/space/salvager(H), H.slot_wear_suit)

		var/obj/item/device/radio/headset/headset = H.ears
		if(!headset)
			headset = new /obj/item/device/radio/headset/salvager
			H.equip_if_possible(headset, H.slot_ears)
		else
			headset.protected_radio = TRUE
		headset.frequency = src.pick_radio_freq()

		H.equip_if_possible(new /obj/item/salvager(H), H.slot_l_hand)
		H.equip_if_possible(new /obj/item/clothing/under/color/grey(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/storage/backpack/salvager(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/mask/breath(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), H.slot_l_store)
		H.equip_if_possible(new /obj/item/ore_scoop/prepared(H), H.slot_r_store)
		H.equip_if_possible(new /obj/item/clothing/shoes/magnetic(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/gloves/long(H), H.slot_gloves)
		H.traitHolder.addTrait("training_engineer")

	assign_objectives()
		new /datum/objective_set/salvager(src.owner)

	relocate()
#ifdef SECRETS_ENABLED
		var/time = TIME
		while(building_base) // yield to builder for a bit
			sleep(0.5 SECONDS)
			if( (TIME - time ) > 20 SECONDS)
				break
		if(!src.home_base)
			building_base = TRUE
			src.home_base = get_singleton(/datum/mapPrefab/allocated/salvager).load()
			sleep(0.5 SECONDS)
			building_base = FALSE
#endif

		if (!landmarks[LANDMARK_SALVAGER])
			message_admins("<span class='alert'><b>ERROR: couldn't find Salvager spawn landmark, aborting relocation.</b></span>")
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
		while (. in blacklisted)

		. = sanitize_frequency(.)
		starting_freq = .

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
	spawn_id = 0
	radio_announcement = FALSE
	add_to_manifest = FALSE

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_SALVAGER)
		return

// Stubs for the public
/datum/objective_set/salvager
