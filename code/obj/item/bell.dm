/obj/item/bell
	name = "service bell"
	icon = 'icons/obj/items/bell.dmi'
	icon_state = "bell"
	desc = "Ding ding ding!"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 15
	w_class = W_CLASS_SMALL
	var/sends_signal_to_hop_watch = FALSE

/obj/item/bell/attack_hand(mob/user)
	if ((!isturf(src.loc) && !user.is_in_hands(src)))
		return ..()
	if (ON_COOLDOWN(src, "service_bell", 1.5 SECONDS))
		return
	src.visible_message(SPAN_NOTICE("<b>[user]</b> rings \the [src]!"))
	playsound(src, 'sound/effects/bell_ring.ogg', 30, FALSE)
	if(sends_signal_to_hop_watch)
		for_by_tcl(watch, /obj/item/pocketwatch)
			watch.the_bell_has_been_rung()

/obj/item/bell/attack_self(mob/user as mob)
	src.Attackhand(user)

/obj/item/bell/mouse_drop(mob/user as mob) // copy paste
	if (user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
		if (!user.put_in_hand(src))
			return ..()

/obj/item/bell/hop
	icon_state = "bell_hop" // get it?
	sends_signal_to_hop_watch = TRUE

/obj/item/bell/kitchen
	name = "dinner bell"
	icon_state = "bell_kitchen"
