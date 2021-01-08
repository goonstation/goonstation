/obj/item/stimpack
	name = "Stimpack"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "stims"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/empty = 0
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(empty)
			boutput(user, "<span class='alert'>This stimpack is empty!</span>")
			return
		if(user != M)
			boutput(user, "<span class='alert'>You can only use this item on yourself.</span>")
			return
		src.empty = 1
		src.icon_state = "stims0"
		boutput(user, "<span class='notice'>Ah! That's the stuff!</span>")
		user.reagents?.add_reagent("stimulants", 50)
		return

/obj/item/stimpack/large_dose
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(user != M)
			boutput(user, "<span class='alert'>You can only use this item on yourself.</span>")
			return
		boutput(user, "<span class='notice'>Ah! That's the stuff!</span>")
		user.reagents?.add_reagent("stimulants", 200)
		qdel(src)
		return
