/// For things which are meant to be a part of a machine. No rustling, no interacting with by hand, etc. DONT!!!
/datum/storage/no_hud/machine
	sneaky = TRUE
	move_triggered = FALSE

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
				var/amt_add = min(I.amount, (stored_item.max_stack - stored_item.amount))
				if (amt_add == I.amount)
					amt_stacked += stored_item.stack_item(I)
				else
					var/obj/item/I_to_stack = I.split_stack(amt_add, src.linked_item)
					amt_stacked += stored_item.stack_item(I_to_stack)

				if (amt_stacked == target_item_amount)
					return stored_item

		// We couldn't stack everything or at all, try to insert into an available slot
		if (amt_stacked < I.amount)
			if (src.slots > length(src.stored_items))
				src.stored_items += I
				I.set_loc(src.linked_item, FALSE)
				I.stored = src
				return I

		return null

