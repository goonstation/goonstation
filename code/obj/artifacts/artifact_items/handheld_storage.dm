// bag of holding artifact
// handheld storage with various types. some can be held on back or belt, in which case they "transform" to fit there, with an icon change
// putting a bags of holding into another is bad

/obj/item/artifact/bag_of_holding
	name = "artifact bag of holding"
	associated_datum = /datum/artifact/bag_of_holding
	w_class = W_CLASS_NORMAL
	/// original icon state, without artifact activation fx
	var/base_icon_state
	/// original item_state
	var/base_item_state
	/// worn belt icon states
	var/static/belt_icons = list("eldritch" = "martian-belt",
								"precursor" = "martian-belt",
								"wizard" = "martian-belt")
	/// worn back icon states
	var/back_icons = list("eldritch" = "martian-backpack",
						  "precursor" = "martian-backpack",
						  "wizard" = "martian-backpack")

	/// wizard arts have an overlay applied, this is used to store it, otherwise it appears in the transformed icon when worn
	var/image/wizard_gem_image

	// when worn, transform icon state into worn version
	equipped(mob/user, slot)
		if (slot != SLOT_BELT && slot != SLOT_BACK)
			return ..()
		var/datum/artifact/artifact = src.artifact
		if (!artifact.activated)
			return ..()

		// hide activation fx
		artifact.hide_fx(src)

		// store wizard overlay
		if (artifact.artitype.name == "wizard")
			src.wizard_gem_image = src.GetOverlayImage("gem")
			src.UpdateOverlays(null, "gem")

		// transform icon state
		src.base_icon_state = src.icon_state
		src.icon = 'icons/obj/artifacts/artifactStorages.dmi'
		if (slot == SLOT_BELT)
			src.wear_image_icon = 'icons/mob/clothing/belt.dmi'
			src.icon_state = src.belt_icons[artifact.artitype.name]
			src.item_state = src.belt_icons[artifact.artitype.name]
			src.wear_layer = MOB_BELT_LAYER
		else
			src.wear_image_icon = 'icons/mob/clothing/back.dmi'
			src.icon_state = src.back_icons[artifact.artitype.name]
			src.wear_layer = MOB_BACK_LAYER
		..()

	unequipped(mob/user)
		var/datum/artifact/artifact = src.artifact
		if (!artifact.activated)
			return ..()

		// reset worn effects
		artifact.show_fx(src)
		src.UpdateOverlays(src.wizard_gem_image, "gem")
		src.wizard_gem_image = null
		src.reset_visible_state()
		..()

	// reset state to pre-worn state
	proc/reset_visible_state()
		if (src.icon == initial(src.icon))
			return

		// reset icons and wear layer
		src.icon = initial(src.icon)
		src.icon_state = src.base_icon_state
		src.item_state = src.base_item_state
		src.wear_image_icon = initial(src.wear_image_icon)
		src.wear_layer = initial(src.wear_layer)

		// reapply overlay if needed
		src.UpdateOverlays(src.wizard_gem_image, "gem")
		src.wizard_gem_image = null

/datum/artifact/bag_of_holding
	associated_object = /obj/item/artifact/bag_of_holding
	type_name = "Bag of Holding"
	rarity_weight = 200
	validtypes = list("eldritch", "precursor", "wizard")
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
			// large variety of storage, items are stored in LIFO, FIFO, or random order
			if ("eldritch")
				var/slots = rand(3, 13)
				var/wclass

				// pick max w class that can be held
				if (slots >= 3 && slots <= 5)
					wclass = pick(prob(10); W_CLASS_TINY, prob(50); W_CLASS_SMALL, prob(100); W_CLASS_NORMAL, prob(40); W_CLASS_BULKY)
				else if (slots > 5 && slots <= 9)
					wclass = pick(prob(20); W_CLASS_TINY, prob(100); W_CLASS_SMALL, prob(50); W_CLASS_NORMAL)
				else if (slots >= 9)
					wclass = pick(prob(30); W_CLASS_TINY, prob(100); W_CLASS_SMALL, prob(10); W_CLASS_NORMAL)

				// allow it to be worn if it can hold a lot of items
				if (slots > 4)
					boh.c_flags |= ONBELT
				if (slots > 6)
					boh.c_flags |= ONBACK

				// set weight size if its a large storage
				if ((slots > 8 || wclass == W_CLASS_BULKY) && prob(90))
					boh.w_class = W_CLASS_BULKY

				boh.create_storage(/datum/storage/no_hud/eldritch_bag_of_holding, max_wclass = wclass, slots = slots, opens_if_worn = \
					boh.c_flags & ONBELT || boh.c_flags & ONBACK, params = list("use_inventory_counter" = TRUE, "item_pick_type" = \
					pick(STORAGE_NO_HUD_QUEUE, STORAGE_NO_HUD_STACK, STORAGE_NO_HUD_RANDOM)))

			// "large sized" storage that can hold small items
			if ("wizard")
				boh.w_class = W_CLASS_BULKY
				boh.c_flags |= (ONBELT | ONBACK)
				boh.create_storage(/datum/storage/artifact_bag_of_holding/wizard, max_wclass = pick(prob(75); W_CLASS_TINY, prob(100); W_CLASS_SMALL),
					slots = rand(20, 40), opens_if_worn = TRUE, params = list("visible_slots" = rand(2, 5)))

			// small storage, but it fits in pockets
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

		// reset to pre-storage changes
		boh.reset_visible_state()
		boh.w_class = initial(boh.w_class)
		boh.c_flags = initial(boh.c_flags)
		boh.uses_multiple_icon_states = initial(boh.uses_multiple_icon_states)

		for (var/atom/A as anything in boh.storage.get_contents())
			boh.storage.transfer_stored_item(A, get_turf(boh))
		boh.remove_storage()

		// in case it's worn on belt or back
		if (istype(boh.loc, /mob))
			var/mob/M = boh.loc
			if (!(boh in M.equipped_list()))
				M.put_in_hand_or_drop(boh)
