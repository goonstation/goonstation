/obj/item/storage/box/stimulants
	name = "stimulants box"
	desc = "A box containing 3 stimpacks. Use responsibly."
	spawn_contents = list(/obj/item/stimpack = 3)

/obj/item/stimpack
	name = "Stimpack"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "stims"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	var/empty = 0
	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(empty)
			boutput(user, SPAN_ALERT("This stimpack is empty!"))
			return
		if(user != target)
			boutput(user, SPAN_ALERT("You can only use this item on yourself."))
			return
		src.empty = 1
		src.icon_state = "stims0"
		boutput(user, SPAN_NOTICE("Ah! That's the stuff!"))
		user.changeStatus("stimulants", 3 MINUTES)
		return

/obj/item/stimpack/large_dose
	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(user != target)
			boutput(user, SPAN_ALERT("You can only use this item on yourself."))
			return
		boutput(user, SPAN_NOTICE("Ah! That's the stuff!"))
		user.changeStatus("stimulants", 15 MINUTES)
		qdel(src)
		return
