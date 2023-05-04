/datum/storage/artifact_bag_of_holding
	/// chance this has of performing a bad effect on adding something to the storage
	var/fault_chance = 0

/datum/storage/artifact_bag_of_holding/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding, check_wclass, max_wclass, \
	slots, sneaky, opens_if_worn, list/params)
	..()
	src.fault_chance = !isnull(params["fault_chance"]) ? params["fault_chance"] : initial(src.fault_chance)

/datum/storage/artifact_bag_of_holding/disposing()
	src.fault_chance = 0
	..()

/datum/storage/artifact_bag_of_holding/add_contents(obj/item/I, mob/user = null, visible = TRUE)
	if (istype(I.storage, /datum/storage/artifact_bag_of_holding))
		src.combine_bags_of_holding(I)
		return
	if (!prob(src.fault_chance))
		return ..()
	switch(pick(1, 2))
		if (1)
			I.combust()
		if (2)
			var/list/mobs_in_game = mobs.Copy()
			var/mob/living/carbon/human/H
			if (!mobs_in_game)
				return
			for (var/i = 1 to 10)
				H = pick(mobs_in_game)
				if (!istype(H))
					continue
				mobs_in_game -= H
				if (H.back.storage?.check_can_hold(I))
					H.back.storage.add_contents(I, null, FALSE)
					playsound(I.loc, "warp", 50, 1, 0.1, 0.7)
					return
				else if (H.belt.storage?.check_can_hold(I))
					H.belt.storage.add_contents(I, null, FALSE)
					playsound(I.loc, "warp", 50, 1, 0.1, 0.7)
					return

/datum/storage/artifact_bag_of_holding/proc/combine_bags_of_holding(obj/item/other_bag)
	switch(pick(1, 2, 3))
		if (1, 2, 3)
			explosion_new(src.linked_item, get_turf(src.linked_item), 10)
		//if (2)
		//	sorium_reaction(src.linked_item.reagent, 50)
		//if (3)
		//	ldmatter_reaction(src.linked_item.reagent, 50)

	qdel(other_bag)
	qdel(src.linked_item)
