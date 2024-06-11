/// For things which are meant to be a part of a machine. No rustling, no interacting with by hand, etc. DONT!!!
/datum/storage/machine
	sneaky = TRUE
	move_triggered = FALSE
	/// How many items in a stack we transfer to others
	var/max_amount_to_others = 1
	/// How many items in a stack we transfer to ourselves
	var/max_amount_to_self = 1
	/// Maximum amount of items this can hold at once
	var/max_amount = 100

	storage_item_attack_by()
		return FALSE // bad

	storage_item_mouse_drop()
		return FALSE // no

	storage_item_attack_hand()
		return FALSE // i said no

	storage_item_after_attack()
		return FALSE // please no

	is_full()
		var/total_amount = 0
		for(var/obj/item/I in src.stored_items)
			total_amount += I.amount
			if (total_amount > src.max_amount)
				return TRUE
		return FALSE

	/// Goes through items in our storage, stacks it with something if possible, otherwise tries to add it to an empty slot.
	/// Fails that if we are at the slot limit. Returns the item  (or what it was stacked into) if added to storage, otherwise returns null.
	add_contents(obj/item/I, mob/user = null, visible = TRUE)
		var/amt_stacked = 0
		var/target_item_amount = I.amount

		if (I in user?.equipped_list())
			user.u_equip(I)

		// Try stacking it with everything. Afterward, we move on to trying to add to an empty slot, remembering how much we stacked already.
		// We return early if we stacked everything already or hit our limit.
		for (var/obj/item/stored_item in src.stored_items)
			if (I.check_valid_stack(stored_item))
				var/amt_add = min(I.amount, (stored_item.max_stack - stored_item.amount), src.max_amount_to_self)
				if (amt_add == I.amount)
					amt_stacked += stored_item.stack_item(I)
				else
					var/obj/item/I_to_stack = I.split_stack(amt_add, src.linked_item)
					amt_stacked += stored_item.stack_item(I_to_stack)

				if (amt_stacked == target_item_amount)
					return stored_item

				if (amt_stacked >= src.max_amount_to_self)
					return I

		// We couldn't stack everything or at all, try to insert into an available slot
		if (amt_stacked < I.amount)
			if (src.slots > length(src.stored_items))
				var/amt_add = min(I.amount, src.max_amount_to_self)
				var/obj/item/I_to_add = I
				if (amt_add < I.amount)
					I_to_add = I.split_stack(amt_add, src.linked_item)
				src.stored_items += I_to_add
				I_to_add.set_loc(src.linked_item, FALSE)
				I_to_add.stored = src
				return I

		return null

	/// Try transferring the specific item in our storage to the target. Returns whether it was transferred successfully.
	/// Mimics player action of trying to split off the highest transferrable amount, inserting that where possible into target, and restacking if failed.
	transfer_stored_item(obj/item/I, atom/location, add_to_storage, mob/user)
		if (location?.storage != null && !location.storage.check_can_hold(I))
			return

		if (I.amount > src.max_amount_to_others)
			var/obj/item/new_I = I.split_stack(src.max_amount_to_others)
			if (location?.storage != null && !location.storage.check_can_hold(new_I))
				I.stack_item(new_I)
				return FALSE
			else
				// We handle it here because new_I is technically not in storage and will fail ..() immediately
				if (location?.storage && add_to_storage)
					location.storage.add_contents(I, user)

				else
					I.set_loc(location, FALSE)
					if (isturf(location))
						I.dropped(user)
				src.stored_items -= I
				I.stored = null
		else
			. = ..()

