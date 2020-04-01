/obj/item/fuel
	name = "Magnetic Storage Ring"
	desc = "A magnetic storage ring."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	var/fuel = 0
	var/s_time = 1.0
	var/content = null

/obj/item/fuel/H
	name = "Hydrogen storage ring"
	content = "Hydrogen"
	fuel = 1e-12		//pico-kilogram

/obj/item/fuel/antiH
	name = "Anti-Hydrogen storage ring"
	content = "Anti-Hydrogen"
	fuel = 1e-12		//pico-kilogram

/obj/item/fuel/attackby(obj/item/fuel/F, mob/user)
	if(istype(src, /obj/item/fuel/antiH))
		if(istype(F, /obj/item/fuel/antiH))
			src.fuel += F.fuel
			F.fuel = 0
			boutput(user, "You have added the anti-Hydorgen to the storage ring, it now contains [src.fuel]kg")
		if(istype(F, /obj/item/fuel/H))
			src.fuel += F.fuel
			qdel(F)
			src:annihilation(src.fuel)
	if(istype(src, /obj/item/fuel/H))
		if(istype(F, /obj/item/fuel/H))
			src.fuel += F.fuel
			F.fuel = 0
			boutput(user, "You have added the Hydorgen to the storage ring, it now contains [src.fuel]kg")
		if(istype(F, /obj/item/fuel/antiH))
			src.fuel += F.fuel
			qdel(src)
			F:annihilation(F.fuel)

/obj/item/fuel/antiH/proc/annihilation(var/mass)

	var/strength = convert2energy(mass)

	if (strength < 773.0)
		var/turf/T = get_turf(src.loc)

		if (strength > (450+T0C))
			explosion(src, T, 0, 1, 2, 4)
		else
			if (strength > (300+T0C))
				explosion(src, T, 0, 0, 2, 3)

		qdel(src)
		return

	var/turf/ground_zero = get_turf(loc)

	var/ground_zero_range = round(strength / 387)
	explosion(src, ground_zero, ground_zero_range, ground_zero_range*2, ground_zero_range*3, ground_zero_range*4)

	//SN src = null
	qdel(src)
	return


/obj/item/fuel/examine()
	set src in view(1)
	if(usr && !usr.stat)
		boutput(usr, "A magnetic storage ring, it contains [fuel]kg of [content ? content : "nothing"].")

/obj/item/fuel/proc/injest(mob/M as mob)
	switch(content)
		if("Anti-Hydrogen")
			M.gib(1)
		if("Hydrogen")
			boutput(M, "<span style=\"color:blue\">You feel very light, as if you might just float away...</span>")
	qdel(src)
	return

/obj/item/fuel/attack(mob/M as mob, mob/user as mob)
	if (user != M)
		user.visible_message("<span style=\"color:red\">[user] is trying to force [M] to eat the [src.content]!</span>")
		if (do_mob(user, M, 40))
			user.visible_message("<span style=\"color:red\">[user] forced [M] to eat the [src.content]!</span>")
			src.injest(M)
	else
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span style=\"color:red\">[M] ate the [content ? content : "empty canister"]!</span>"), 1)
		src.injest(M)
