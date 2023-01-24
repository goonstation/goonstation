TYPEINFO(/obj/item/device/shield)
	mats = 10

/obj/item/device/shield
	name = "shield"
	icon_state = "shield0"
	var/active = 0
	flags = FPRINT | TABLEPASS | CONDUCT | NOSHIELD
	item_state = "electronic"
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL

/obj/item/device/shield/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		boutput(user, "<span class='notice'>The shield is now active.</span>")
		src.icon_state = "shield1"
		user.update_inhands()
	else
		boutput(user, "<span class='notice'>The shield is now inactive.</span>")
		src.icon_state = "shield0"
		user.update_inhands()
	src.add_fingerprint(user)
	return
