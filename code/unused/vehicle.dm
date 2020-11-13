/obj/machinery/vehicle/process()
	if (src.speed)
		if (src.speed <= 10)
			var/t1 = 10 - src.speed
			while(t1 > 0)
				step(src, src.dir)
				sleep(0.1 SECONDS)
				t1--
		else
			var/t1 = round(src.speed / 5)
			while(t1 > 0)
				step(src, src.dir)
				t1--
	return

/obj/machinery/vehicle/meteorhit(var/obj/O as obj)
	for (var/obj/item/I in src)
		I.set_loc(src.loc)

	for (var/mob/M in src)
		M.set_loc(src.loc)
	qdel(src)

/obj/machinery/vehicle/ex_act(severity)
	switch (severity)
		if (1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				ex_act(severity)
			//SN src = null
			qdel(src)
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					ex_act(severity)
				//SN src = null
				qdel(src)

/obj/machinery/vehicle/blob_act(var/power)
	for(var/atom/movable/A as mob|obj in src)
		A.set_loc(src.loc)
	qdel(src)

/obj/machinery/vehicle/Bump(var/atom/A)
	//boutput(world, "[src] bumped into [A]")
	SPAWN_DBG (0)
		..()
		src.speed = 0
		return
	return

/obj/machinery/vehicle/relaymove(mob/user as mob, direction)
	if (user.stat)
		return

	if ((user in src))
		if (direction & 1)
			src.speed = max(src.speed - 1, 1)
		else if (direction & 2)
			src.speed = min(src.maximum_speed, src.speed + 1)
		else if (src.can_rotate && direction & 4)
			src.set_dir(turn(src.dir, -90.0))
		else if (src.can_rotate && direction & 8)
			src.set_dir(turn(src.dir, 90))
		else if (direction & 16 && src.can_maximize_speed)
			src.speed = src.maximum_speed

/obj/machinery/vehicle/verb/eject()
	set src = usr.loc

	if (usr.stat)
		return

	var/mob/M = usr
	M.set_loc(src.loc)
	step(M, turn(src.dir, 180))
	return

/obj/machinery/vehicle/verb/board()
	set src in oview(1)

	if (usr.stat || isintangible(usr))
		return

	if (src.one_person_only && locate(/mob, src))
		boutput(usr, "There is no room! You can only fit one person.")
		return

	var/mob/M = usr
	M.set_loc(src)

/obj/machinery/vehicle/verb/unload(var/atom/movable/A in src)
	set src in oview(1)

	if (usr.stat)
		return

	if (istype(A, /atom/movable))
		A.set_loc(src.loc)
		for(var/mob/O in view(src, null))
			if ((O.client && !(O.blinded)))
				boutput(O, text("<span class='notice'><B> [] unloads [] from []!</B></span>", usr, A, src))

		if (ismob(A))
			var/mob/M = A

/obj/machinery/vehicle/verb/load()
	set src in oview(1)

	if (usr.stat)
		return

	if (ishuman(usr))
		var/mob/living/carbon/human/H = usr

		if ((H.pulling && !(H.pulling.anchored)))
			if (src.one_person_only && !(istype(H.pulling, /obj/item/weapon)))
				boutput(usr, "You may only place items in.")
			else
				H.pulling.set_loc(src)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						boutput(O, text("<span class='notice'><B> [] loads [] into []!</B></span>", H, H.pulling, src))

				H.pulling = null
