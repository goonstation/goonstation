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
	attack(mob/M, mob/user, def_zone)
		if(empty)
			boutput(user, "<span class='alert'>This stimpack is empty!</span>")
			return
		if(user != M)
			boutput(user, "<span class='alert'>You can only use this item on yourself.</span>")
			return
		src.empty = 1
		src.icon_state = "stims0"
		boutput(user, "<span class='notice'>Ah! That's the stuff!</span>")
		user.changeStatus("stimulants", 3 MINUTES)
		return

/obj/item/stimpack/large_dose
	attack(mob/M, mob/user, def_zone)
		if(user != M)
			boutput(user, "<span class='alert'>You can only use this item on yourself.</span>")
			return
		boutput(user, "<span class='notice'>Ah! That's the stuff!</span>")
		user.changeStatus("stimulants", 15 MINUTES)
		qdel(src)
		return
