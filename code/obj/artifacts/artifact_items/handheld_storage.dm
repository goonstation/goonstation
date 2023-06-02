/obj/item/artifact/bag_of_holding
	name = "artifact bag of holding"
	associated_datum = /datum/artifact/bag_of_holding
	w_class = W_CLASS_NORMAL
	var/base_icon_state
	var/belt_icon_states = list("eldritch" = "martian-belt",
								"martian" = "martian-belt",
								"precursor" = "martian-belt",
								"wizard" = "martian-belt")
	var/back_icon_states = list("eldritch" = "martian-backpack",
								"martian" = "martian-backpack",
								"precursor" = "martian-backpack",
								"wizard" = "martian-backpack")
	var/image/wizard_gem_image

	equipped(mob/user, slot)
		if (slot != SLOT_BELT && slot != SLOT_BACK)
			return ..()
		var/datum/artifact/artifact = src.artifact
		if (!artifact.activated)
			return ..()
		artifact.hide_fx(src)
		if (artifact.artitype.name == "wizard")
			src.wizard_gem_image = src.GetOverlayImage("gem")
			src.UpdateOverlays(null, "gem")
		src.base_icon_state = src.icon_state
		src.icon = 'icons/obj/artifacts/artifactStorages.dmi'
		if (slot == SLOT_BELT)
			src.wear_image_icon = 'icons/mob/clothing/belt.dmi'
			src.icon_state = src.belt_icon_states[artifact.artitype.name]
			src.item_state = src.belt_icon_states[artifact.artitype.name]
			src.wear_layer = MOB_BELT_LAYER
		else
			src.wear_image_icon = 'icons/mob/clothing/back.dmi'
			src.icon_state = src.back_icon_states[artifact.artitype.name]
			src.wear_layer = MOB_BACK_LAYER
		..()

	unequipped(mob/user)
		var/datum/artifact/artifact = src.artifact
		if (!artifact.activated)
			return ..()
		artifact.show_fx(src)
		src.UpdateOverlays(src.wizard_gem_image, "gem")
		src.wizard_gem_image = null
		src.reset_visible_state()
		..()

	proc/reset_visible_state()
		if (src.icon == initial(src.icon))
			return
		src.icon = initial(src.icon)
		src.wear_image_icon = initial(src.wear_image_icon)
		src.icon_state = src.base_icon_state
		src.item_state = initial(src.item_state)
		src.wear_layer = initial(src.wear_layer)

		var/datum/artifact/artifact = src.artifact
		if (artifact.artitype.name == "wizard")
			src.UpdateOverlays(src.wizard_gem_image, "gem")
			src.wizard_gem_image = null

/datum/artifact/bag_of_holding
	associated_object = /obj/item/artifact/bag_of_holding
	type_name = "Bag of Holding"
	rarity_weight = 200
	validtypes = list("eldritch", "martian", "precursor", "wizard")
	validtriggers = list(/datum/artifact_trigger/force, /datum/artifact_trigger/electric, /datum/artifact_trigger/heat,
		/datum/artifact_trigger/radiation, /datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch,
		/datum/artifact_trigger/cold)
	type_size = ARTIFACT_SIZE_MEDIUM
	react_xray = list(5, 91, 97, 11, "HOLLOW")

	effect_activate(obj/O)
		if (..())
			return TRUE

		var/obj/item/artifact/bag_of_holding/boh = O

		switch(src.artitype.name)
			// large variety of storage, though there's no HUD and items are stored in LIFO, FIFO, or random order
			if ("eldritch")
				var/slots = rand(3, 13)
				var/wclass

				if (slots >= 3 && slots <= 5)
					wclass = pick(prob(10); W_CLASS_TINY, prob(50); W_CLASS_SMALL, prob(100); W_CLASS_NORMAL, prob(40); W_CLASS_BULKY)
				else if (slots > 5 && slots <= 9)
					wclass = pick(prob(20); W_CLASS_TINY, prob(100); W_CLASS_SMALL, prob(50); W_CLASS_NORMAL)
				else if (slots >= 9)
					wclass = pick(prob(30); W_CLASS_TINY, prob(100); W_CLASS_SMALL, prob(10); W_CLASS_NORMAL)

				if (slots > 4)
					boh.c_flags |= ONBELT
				if (slots > 6)
					boh.c_flags |= ONBACK
				if ((slots > 8 || wclass == W_CLASS_BULKY) && prob(90))
					boh.w_class = W_CLASS_BULKY

				boh.create_storage(/datum/storage/no_hud/eldritch_bag_of_holding, max_wclass = wclass, slots = slots, opens_if_worn = boh.c_flags & ONBELT,
					params = list("use_inventory_counter" = TRUE, "item_pick_type" = pick(STORAGE_NO_HUD_QUEUE, STORAGE_NO_HUD_STACK, STORAGE_NO_HUD_RANDOM)))

			// storage that starts off small, but it can be upgraded by "feeding" it ores
			if ("martian")
				return

			// large storage, but you can only see a random selection of items in it at a time
			if ("wizard")
				boh.w_class = W_CLASS_BULKY
				boh.c_flags |= (ONBELT | ONBACK)
				boh.create_storage(/datum/storage/artifact_bag_of_holding/wizard, max_wclass = pick(prob(75); W_CLASS_TINY, prob(100); W_CLASS_SMALL),
					slots = rand(20, 40), opens_if_worn = TRUE, params = list("visible_slots" = rand(2, 5)))

			// small storage, but it fits in pockets, extinguishes items, repairs item health, and has some neutral effects on items stored
			if ("precursor")
				boh.w_class = W_CLASS_SMALL
				boh.create_storage(/datum/storage/artifact_bag_of_holding/precursor, max_wclass = pick(prob(40); W_CLASS_TINY, prob(100); W_CLASS_SMALL),
					slots = rand(2, 4), opens_if_worn = TRUE)

		if (boh.c_flags & ONBELT || boh.c_flags & ONBACK)
			boh.uses_multiple_icon_states = TRUE

	effect_deactivate(obj/O)
		if (..())
			return TRUE
		var/obj/item/artifact/bag_of_holding/boh = O
		boh.reset_visible_state()
		boh.w_class = initial(boh.w_class)
		boh.c_flags = initial(boh.c_flags)
		boh.uses_multiple_icon_states = initial(boh.uses_multiple_icon_states)
		boh.remove_storage()
		if (istype(boh.loc, /mob))
			var/mob/M = boh.loc
			M.put_in_hand_or_drop(boh)
