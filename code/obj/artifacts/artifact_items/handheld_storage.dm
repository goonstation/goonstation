/obj/item/bag_of_holding
	name = "artifact bag of holding"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	desc = "You have no idea what this thing is!"
	artifact = TRUE
	mat_changename = FALSE
	mat_changedesc = FALSE

	w_class = W_CLASS_NORMAL

	New(loc, forceartiorigin)
		..()
		var/datum/artifact/bag_of_holding/artifact_holder = new /datum/artifact/bag_of_holding(src)
		if (forceartiorigin)
			artifact_holder.validtypes = list("[forceartiorigin]")
		src.artifact = artifact_holder
		src.ArtifactSetup()

		var/datum/artifact/linked_artifact = src.artifact
		var/fault_chance = 0

		switch(linked_artifact.artitype.name)
			// large variety of storage
			if ("eldritch")
				var/slots = rand(3, 13)
				var/wclass

				if (slots >= 3 && slots <= 5)
					wclass = pick(prob(10); W_CLASS_TINY, prob(50); W_CLASS_SMALL, prob(100); W_CLASS_NORMAL, prob(40); W_CLASS_BULKY)
					if (wclass == W_CLASS_NORMAL)
						fault_chance = 1
					else if (wclass == W_CLASS_BULKY)
						fault_chance = 2
				else if (slots > 5 && slots <= 9)
					wclass = pick(prob(20); W_CLASS_TINY, prob(100); W_CLASS_SMALL, prob(50); W_CLASS_NORMAL)
					if (wclass == W_CLASS_NORMAL)
						fault_chance = 2
				else if (slots >= 9)
					fault_chance = 1
					wclass = pick(prob(30); W_CLASS_TINY, prob(100); W_CLASS_SMALL, prob(10); W_CLASS_NORMAL)
					if (wclass == W_CLASS_NORMAL)
						fault_chance = 3

				src.create_storage(/datum/storage/artifact_bag_of_holding, max_wclass = wclass, slots = slots, params = list("fault_chance" = fault_chance))

			// auto "replenishes" items
			if ("precursor")

			// fancy storing, like on belt and giving no messages when storing items
			if ("wizard")
				fault_chance = 0.05
				var/can_be_worn = TRUE
				var/is_sneaky = FALSE

				switch(pick(1, 2, 3))
					// fits in pocket
					if (1)
						src.w_class = W_CLASS_SMALL
					// fits on belt
					if (2)
						src.c_flags &= ONBELT
						// TODO: if anyone wants to sprite worn states, this could be worn on your back too!
					// gives no message when adding items
					if (3)
						is_sneaky = TRUE
						can_be_worn = FALSE

				src.create_storage(/datum/storage/artifact_bag_of_holding, max_wclass = pick(W_CLASS_SMALL, prob(40); W_CLASS_NORMAL), slots = rand(5, 9),
					sneaky = is_sneaky, opens_if_worn = can_be_worn, params = list("fault_chance" = fault_chance))

	attackby(obj/item/W, mob/user)
		if (src.storage.check_can_hold(W) != STORAGE_CAN_HOLD)
			src.Artifact_attackby(W, user)
		else
			..()

	examine()
		return list(src.desc)

	UpdateName()
		src.name = "[src.name_prefix(null, 1)][src.real_name][src.name_suffix(null, 1)]"

	update_icon()
		return

/datum/artifact/bag_of_holding
	associated_object = /obj/item/bag_of_holding
	type_name = "Bag of Holding"
	rarity_weight = 200
	validtypes = list("eldritch", "precursor", "wizard")
	type_size = ARTIFACT_SIZE_MEDIUM
	no_activation = TRUE
	min_triggers = 0
	max_triggers = 0
	react_xray = list(9, 70, 75, 11, "HOLLOW")
