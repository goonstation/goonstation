/obj/item/stimpack
	name = "Stimpack"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "dnainjector"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(user != M)
			boutput(user, "<span style=\"color:red\">You can only use this item on yourself.</span>")
			return
		boutput(user, "<span style=\"color:blue\">Ah! That's the stuff!</span>")
		if(user.reagents)
			user.reagents.add_reagent("stimulants", 50)
		qdel(src)
		return

/obj/item/stimpack/large_dose
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(user != M)
			boutput(user, "<span style=\"color:red\">You can only use this item on yourself.</span>")
			return
		boutput(user, "<span style=\"color:blue\">Ah! That's the stuff!</span>")
		if(user.reagents)
			user.reagents.add_reagent("stimulants", 200)
		qdel(src)
		return
