/* ================================================================== */
/* -----------STORAGE DATUM FOR ITEMS WITH NO STORAGE HUD------------ */
/* ================================================================== */

// For any items that you don't want a storage HUD shown. This allows for
// storages of any size

/datum/storage/no_hud
	/// whether an inventory counter should be used or not
	var/use_inventory_counter = FALSE
	/// if inventory_counter is used, if false this will show percentage, if true this will show count
	var/show_count = TRUE
	/// if the weight of the storage item is equal to the highest weight its holding
	var/variable_weight = FALSE
	/// the max weight that this storage can hold. keep null if this isn't checked
	var/max_weight = null
	/// how items are picked out of this storage
	var/item_pick_type = STORAGE_NO_HUD_STACK

	/// current weight held in the storage
	var/cur_weight = 0

/datum/storage/no_hud/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding, check_wclass, max_wclass,
		slots, sneaky, stealthy_storage, opens_if_worn, list/params)
	..()
	src.use_inventory_counter = params["use_inventory_counter"] || initial(src.use_inventory_counter)
	src.show_count = params["show_count"] || initial(src.show_count)
	src.variable_weight = params["variable_weight"] || initial(src.variable_weight)
	src.max_weight = !isnull(params["max_weight"]) ? params["max_weight"] : initial(src.max_weight)
	src.item_pick_type = params["item_pick_type"] || initial(src.item_pick_type)

	if (src.use_inventory_counter && istype(src.linked_item, /obj/item))
		var/obj/item/I = src.linked_item
		I.inventory_counter_enabled = TRUE
		I.create_inventory_counter()
		if (!src.show_count)
			I.inventory_counter.update_percent(0, 100)
		else
			I.inventory_counter.update_number(0)

/datum/storage/no_hud/disposing()
	if (src.use_inventory_counter && istype(src.linked_item, /obj/item))
		var/obj/item/I = src.linked_item
		I.remove_inventory_counter()
	..()

/datum/storage/no_hud/storage_item_attack_hand(mob/user)
	if (!..())
		return
	if (!length(src.get_contents()))
		return

	if (isnull(user.equipped()))
		var/obj/item/I
		switch(src.item_pick_type)
			if (STORAGE_NO_HUD_QUEUE)
				I = src.get_contents()[1]
			if (STORAGE_NO_HUD_STACK)
				I = src.get_contents()[length(src.get_contents())]
			if (STORAGE_NO_HUD_RANDOM)
				I = pick(src.get_contents())
		I.Attackhand(user)

/datum/storage/no_hud/storage_item_attack_self(mob/user)
	return

/datum/storage/no_hud/check_can_hold(obj/item/W)
	. = ..()
	if (. != STORAGE_CAN_HOLD)
		return

	if (!isnull(src.max_weight))
		if (src.cur_weight + W.w_class > src.max_weight)
			return STORAGE_WONT_FIT

	if (src.variable_weight && istype(src.linked_item, /obj/item))
		var/obj/item/I = src.linked_item
		if (I.stored && I.stored.max_wclass < W.w_class)
			return STORAGE_WONT_FIT

/datum/storage/no_hud/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (src.variable_weight && istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		W.w_class = max(W.w_class, I.w_class)
	if (!isnull(src.max_weight))
		src.cur_weight += I.w_class
	if (src.use_inventory_counter && istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		if (!src.show_count)
			if (length(src.get_contents()) / src.slots > src.cur_weight / src.max_weight)
				W.inventory_counter.update_percent(length(src.get_contents()), src.slots)
			else
				W.inventory_counter.update_percent(src.cur_weight, src.max_weight)
		else
			W.inventory_counter.update_number(length(src.get_contents()))

/datum/storage/no_hud/transfer_stored_item_extra(obj/item/I, atom/location, add_to_storage, mob/user)
	..()
	if (src.variable_weight && istype(src.linked_item, /obj/item))
		var/obj/item/storage_item = src.linked_item
		if (length(src.get_contents()))
			for (var/obj/item/W as anything in src.get_contents())
				storage_item.w_class = max(initial(storage_item.w_class), W.w_class)
		else
			storage_item.w_class = initial(storage_item.w_class)
	if (!isnull(src.max_weight))
		src.cur_weight -= I.w_class
	if (src.use_inventory_counter && istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		if (!src.show_count)
			if (length(src.get_contents()) / src.slots > src.cur_weight / src.max_weight)
				W.inventory_counter.update_percent(length(src.get_contents()), src.slots)
			else
				W.inventory_counter.update_percent(src.cur_weight, src.max_weight)
		else
			W.inventory_counter.update_number(length(src.get_contents()))

/datum/storage/no_hud/is_full()
	return isnull(src.max_weight) ? ..() : ..() || (src.cur_weight >= src.max_weight)

/datum/storage/no_hud/show_hud(mob/user)
	return

/datum/storage/no_hud/hide_hud(mob/user)
	return

/datum/storage/no_hud/get_capacity_string()
	. = ..()
	if (isnull(src.max_weight))
		return

	var/capacity = null

	switch(round(src.cur_weight / src.max_weight * 100))
		if (0)
			capacity = ""
		if (1 to 24)
			capacity = "It's at less than a quarter of its weight limit."
		if (25 to 49)
			capacity = "It's holding between a quarter and a half of its weight limit."
		if (50 to 74)
			capacity = "It's holding between a half and three quarters of its weight limit."
		if (75 to 99)
			capacity = "It's at more than three quarters of its weight limit."
		if (100)
			capacity = "It's at its weight limit."

	return . + ". [capacity]"
