/obj/item/artifact/bag_of_holding
	name = "artifact bag of holding"
	associated_datum = /datum/artifact/bag_of_holding
	w_class = W_CLASS_NORMAL

/datum/artifact/bag_of_holding
	associated_object = /obj/item/artifact/bag_of_holding
	type_name = "Bag of Holding"
	rarity_weight = 200
	validtypes = list("eldritch", "martian", "precursor", "wizard")
	validtriggers = list(/datum/artifact_trigger/force, /datum/artifact_trigger/electric, /datum/artifact_trigger/heat,
		/datum/artifact_trigger/radiation, /datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch,
		/datum/artifact_trigger/cold)
	type_size = ARTIFACT_SIZE_MEDIUM
	react_xray = list(9, 70, 75, 11, "HOLLOW")

	effect_activate(obj/O)
		if (..())
			return TRUE

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

				O.create_storage(/datum/storage/no_hud, max_wclass = wclass, slots = slots,
					params = list("use_inventory_counter" = TRUE, "item_pick_type" = pick(STORAGE_NO_HUD_QUEUE, STORAGE_NO_HUD_STACK, STORAGE_NO_HUD_RANDOM)))

			// storage that starts off small, but it can be upgraded by "feeding" it ores
			if ("martian")
				return

			// infinite storage, but you can only see a random selection of items in it at a time
			if ("wizard")
				O.create_storage(/datum/storage/artifact_bag_of_holding/wizard, max_wclass = pick(prob(75); W_CLASS_TINY, prob(100); W_CLASS_SMALL), slots = 999)
				return

			// small storage that can fit in pockets, has random, neutral effects and some benefits
			if ("precursor")
				O.create_storage(/datum/storage/artifact_bag_of_holding/precursor, max_wclass = pick(prob(40); W_CLASS_TINY, prob(100); W_CLASS_SMALL), slots = rand(2, 4),
					opens_if_worn = TRUE)
				var/obj/item/artifact/bag_of_holding/boh = O
				boh.w_class = W_CLASS_SMALL

	effect_deactivate(obj/O)
		if (..())
			return TRUE
		O.remove_storage()
