/obj/item/bell
	name = "service bell"
	icon = 'icons/obj/items/bell.dmi'
	icon_state = "bell"
	desc = "Ding ding ding!"
	flags = FPRINT | TABLEPASS
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 15
	w_class = W_CLASS_SMALL

/obj/item/bell/attack_hand(mob/user)
	if ((!isturf(src.loc) && !user.is_in_hands(src)))
		return ..()
	if (ON_COOLDOWN(src, "service_bell", 1.5 SECONDS))
		return
	src.visible_message("<span class='notice'><b>[user]</b> rings \the [src]!</span>")
	playsound(src, 'sound/effects/bell_ring.ogg', 30, 0)

/obj/item/bell/attack_self(mob/user as mob)
	src.attack_hand(user)

/obj/item/bell/mouse_drop(mob/user as mob) // copy paste
	if (user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
		if (!user.put_in_hand(src))
			return ..()

/obj/item/bell/hop
	icon_state = "bell_hop" // get it?

/obj/item/bell/kitchen
	name = "dinner bell"
	icon_state = "bell_kitchen"
