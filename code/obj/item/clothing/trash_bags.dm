
/obj/item/clothing/under/trash_bag
	name = "trash bag"
	desc = "A flimsy bag for filling with things that are no longer wanted."
	icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	icon_state = "trashbag-f"
	uses_multiple_icon_states = 1
	item_state = ""
	w_class = W_CLASS_TINY
	rand_pos = 1
	flags = FPRINT | TABLEPASS | NOSPLASH
	tooltip_flags = REBUILD_DIST
	body_parts_covered = TORSO
	var/base_state = "trashbag"
	var/max_stuff = 20 // can't hold more than this many stuff
	var/current_stuff = 0 // w_class is added together here, not allowed to add something that would put this > max_stuff

	get_desc(dist)
		..()
		if (dist <= 2)
			if (src.current_stuff > src.max_stuff)
				. += "All the stuff inside is spilling out!"
			else if (src.current_stuff == src.max_stuff)
				. += "It's totally full."
			else
				. += "It's [get_fullness(current_stuff / max_stuff * 100)]."

	equipped(var/mob/user)
		..()
		if (src.contents.len)
			for (var/i=src.contents.len, i>0, i--)
				if (prob(66))
					continue
				else
					src.remove_random_item(user)
			src.calc_w_class(user)
		else
			src.icon_state = src.base_state
			src.item_state = src.base_state

	attackby(obj/item/W, mob/user)
		if(W.w_class > W_CLASS_NORMAL)
			boutput(user, "<span class='alert'>\The [W] is too big to fit inside [src]!</span>")
			return
		if (W.cant_self_remove || W.cant_drop)
			boutput(user, "<span class='alert'>You can't get [W] to come off of you!</span>")
			return
		if (istype(W, /obj/item/clothing/under/trash_bag))
			boutput(user, "<span class='alert'>You can't put a [W] into another trash bag?! Are you crazy?!</span>")
			return
		else if ((src.current_stuff + W.w_class) > src.max_stuff) // we too full
			boutput(user, "<span class='alert'>\The [src] is too full for [W] to fit!</span>")
			return
		else
			if (istype(src.loc, /obj/item/storage))
				var/obj/item/storage/S = src.loc
				if (S.max_wclass < W.w_class) // too big to fit in the thing we're in already!
					boutput(user, "<span class='alert'>You can't fit [W] in [src] while [src] is inside [S]!</span>")
					return
			user.u_equip(W)
			W.set_loc(src)
			playsound(src.loc, "rustle", 50, 1, -5)
			boutput(user, "You stuff [W] into [src].")
			if (ishuman(src.loc)) // person be wearin this
				var/mob/living/carbon/human/H = src.loc
				if (H.w_uniform == src)
					if (prob(66))
						src.remove_random_item(H)
			src.calc_w_class(user)

	attack_hand(mob/user)
		if (!user.find_in_hand(src))
			return ..()
		if (!src.contents.len)
			boutput(user, "<span class='alert'>\The [src] is empty!</span>")
			return
		else
			var/obj/item/I = pick(src.contents)
			playsound(src.loc, "rustle", 50, 1, -5)
			boutput(user, "You rummage around in [src] and pull out [I].")
			user.put_in_hand_or_drop(I)
		if (src.contents.len && ishuman(src.loc)) // person be wearin this
			var/mob/living/carbon/human/H = src.loc
			if (H.w_uniform == src)
				if (prob(66))
					src.remove_random_item(user)
		src.calc_w_class(user)

	proc/calc_w_class(var/mob/user)
		src.current_stuff = 0
		if (!src.contents.len)
			src.w_class = W_CLASS_TINY
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.w_uniform == src)
					return
			src.icon_state = "[src.base_state]-f"
			src.item_state = ""
			if (ismob(user))
				user.update_inhands()
			return
		// can maybe do something more interesting later than just "as big as the biggest thing inside" later but idc right now
		for (var/obj/item/I in src.contents)
			src.w_class = max(I.w_class, src.w_class) // as it turns out there are some w_class things above 5 so fuck it this is just a max() now
			src.current_stuff += I.w_class
			tooltip_rebuild = 1
		if (src.contents.len >= 1)
			src.icon_state = src.base_state
			src.item_state = src.base_state
			if (ismob(user))
				user.update_inhands()

	proc/remove_random_item(var/mob/user)
		if (!src.contents.len)
			return
		var/atom/movable/A = pick(src.contents)
		if (A)
			if (user)
				user.visible_message("\An [A] falls out of [user]'s [src.name]!",\
				"<span class='alert'>\An [A] falls out of your [src.name]!</span>")
			else
				src.loc.visible_message("\An [A] falls out of [src]!")
			A.set_loc(get_turf(src))

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (!usr || usr.stat || usr.restrained() || BOUNDS_DIST(src, usr) > 0 || BOUNDS_DIST(usr, over_object) > 0)
			return
		if (usr.is_in_hands(src))
			var/turf/T = over_object
			if (istype(T, /obj/table))
				T = get_turf(T)
			if (!(usr in range(1, T)))
				return
			if (istype(T))
				for (var/obj/O in T)
					if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
						return
				if (!T.density)
					return//usr.visible_message("<span class='alert'>[usr] dumps the contents of [src] onto [T]!</span>")

/obj/item/clothing/under/trash_bag/biohazard
	name = "hazardous waste bag"
	desc = "A flimsy bag for filling with things that are no longer wanted and are also covered in blood or puke or other gross biohazards. It's not any sturdier than a normal trash bag, though, so be careful with the needles!"
	icon_state = "biobag-f"
	base_state = "biobag"
