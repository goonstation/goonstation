/obj/item/uplink_telecrystal
	name = "pure telecrystal"
	desc = "A pure Telecrystal, useful for creating small, precise warps in space."
	icon = 'icons/obj/items/materials/telecrystal.dmi'
	icon_state = "telecrystal_pure"
	max_stack = INFINITY
	var/icon_stack_value = 0 //! Used for updating the icon_state as stack amount changes

	New()
		..()
		_update_stack_appearance()

	attackby(obj/item/W, mob/user)
		if(W.type == src.type)
			stack_item(W)
			if(!user.is_in_hands(src))
				user.put_in_hand(src)
			boutput(user, SPAN_NOTICE("You add the [src] to the stack. It now has [src.amount] [src]."))
			return
		else ..()

	attack_hand(mob/user)
		if(user.is_in_hands(src) && src.amount > 1)
			var/splitnum = round(input("How many [src] do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum))
				boutput(user, SPAN_ALERT("Invalid entry, try again."))
				return
			if (!src.loc || BOUNDS_DIST(src, user) > 0)
				return
			var/obj/item/raw_material/new_stack = split_stack(splitnum)
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
		else
			..(user)

	_update_stack_appearance()
		if(src.amount == 1)
			name = "[syndicate_currency]"
		else
			name = "[amount] [syndicate_currency]"
		name = "[amount] [syndicate_currency][amount > 1 ? "s":""]"
		var/icon_stack_new = get_stack_value()
		if(icon_stack_new && icon_stack_new != src.icon_stack_value)
			src.icon_stack_value = icon_stack_new
			src.icon_state = "telecrystal_pure_[icon_stack_value]"
		return

	proc/get_stack_value() // Determines at what stack sizes the icon_state changes
		// Stack icons chosen to be the same as telecrystals.
		switch(src.amount)
			if(1)
				return 1
			if(2 to 4)
				return 2
			if(5 to 9)
				return 3
			if(10 to 24)
				return 4
			if(25 to 49)
				return 5
			else
				return 6

/obj/item/uplink_telecrystal/trick
	name = "pure telecrystal"

/obj/decal/cleanable/shattered_traitorcoin
	name = "shattered crystal"
	desc = "The remains of some kind of red-pink crystal."
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "shattered_traitorcoin"
