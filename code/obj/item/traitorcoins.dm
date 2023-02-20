/obj/item/uplink_telecrystal
	name = "pure telecrystal"
	desc = "A pure Telecrystal, useful for creating small, precise warps in space."
	icon = 'icons/obj/materials.dmi'
	icon_state = "telecrystal_pure"
	max_stack = INFINITY

	attackby(obj/item/W, mob/user)
		if(W.type == src.type)
			stack_item(W)
			if(!user.is_in_hands(src))
				user.put_in_hand(src)
			boutput(user, "<span class='notice'>You add the [src] to the stack. It now has [src.amount] [src].</span>")
			return
		else ..()

	attack_hand(mob/user)
		if(user.is_in_hands(src) && src.amount > 1)
			var/splitnum = round(input("How many [src] do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if (splitnum >= amount || splitnum < 1 || !isnum_safe(splitnum))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			if (!src.loc || BOUNDS_DIST(src, user) > 0)
				return
			var/obj/item/raw_material/new_stack = split_stack(splitnum)
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
		else
			..(user)

	_update_stack_appearance()
		if(material)
			name = "[amount] [initial(src.name)][amount > 1 ? "s":""]"
		return

/obj/item/explosive_uplink_telecrystal
	name = "pure telecrystal"
	desc = "A pure Telecrystal, useful for creating small, precise warps in space."
	icon = 'icons/obj/materials.dmi'
	icon_state = "telecrystal_pure"

	New()
		..()
		name = "[syndicate_currency]"

/obj/decal/cleanable/shattered_traitorcoin
	name = "shattered crystal"
	desc = "The remains of some kind of red-pink crystal."
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "shattered_traitorcoin"
