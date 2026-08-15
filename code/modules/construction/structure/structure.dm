/obj/structure
	icon = 'icons/obj/structures.dmi'
	var/projectile_passthrough_chance = 0

/obj/structure/blob_act(power)
	if (prob(power))
		qdel(src)

/obj/structure/meteorhit(obj/O)
	qdel(src)

/obj/structure/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(50))
				qdel(src)
				return
		if(3)
			return
	return
