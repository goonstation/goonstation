/obj/machinery/sec_lock/attack_ai(user as mob)
	return //src.Attackhand(user)

/obj/machinery/sec_lock/attack_hand(var/mob/user)
	if(..())
		return
	use_power(10)

	if (src.loc == user.loc)
		var/dat = text("<B>Security Pad:</B><BR><br>Keycard: []<BR><br><A href='?src=\ref[];door1=1'>Toggle Outer Door</A><BR><br><A href='?src=\ref[];door2=1'>Toggle Inner Door</A><BR><br><BR><br><A href='?src=\ref[];em_cl=1'>Emergency Close</A><BR><br><A href='?src=\ref[];em_op=1'>Emergency Open</A><BR>", (src.scan ? text("<A href='?src=\ref[];card=1'>[]</A>", src, src.scan.name) : text("<A href='?src=\ref[];card=1'>-----</A>", src)), src, src, src, src)
		user.Browse(dat, "window=sec_lock")
		onclose(user, "sec_lock")
	return

/obj/machinery/sec_lock/attackby(nothing, user as mob)
	return src.Attackhand(user)

/obj/machinery/sec_lock/New()
	..()
	SPAWN( 2 )
		if (src.a_type == 1)
			src.d2 = locate(/obj/machinery/door, locate(src.x - 2, src.y - 1, src.z))
			src.d1 = locate(/obj/machinery/door, get_step(src, SOUTHWEST))
		else
			if (src.a_type == 2)
				src.d2 = locate(/obj/machinery/door, locate(src.x - 2, src.y + 1, src.z))
				src.d1 = locate(/obj/machinery/door, get_step(src, NORTHWEST))
			else
				src.d1 = locate(/obj/machinery/door, get_step(src, SOUTH))
				src.d2 = locate(/obj/machinery/door, get_step(src, SOUTHEAST))
		return
	return

/obj/machinery/sec_lock/Topic(href, href_list)
	if(..())
		return
	if ((!( src.d1 ) || !( src.d2 )))
		boutput(usr, "<span class='alert'>Error: Cannot interface with door security!</span>")
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr))))
		src.add_dialog(usr)
		if (href_list["card"])
			if (src.scan)
				src.scan.set_loc(src.loc)
				src.scan = null
			else
				var/obj/item/card/id/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)
					src.scan = I
		if (href_list["door1"])
			if (src.scan)
				if (src.check_access(src.scan))
					if (src.d1.density)
						SPAWN( 0 )
							src.d1.open()
							return
					else
						SPAWN( 0 )
							src.d1.close()
							return
		if (href_list["door2"])
			if (src.scan)
				if (src.check_access(src.scan))
					if (src.d2.density)
						SPAWN( 0 )
							src.d2.open()
							return
					else
						SPAWN( 0 )
							src.d2.close()
							return
		if (href_list["em_cl"])
			if (src.scan)
				if (src.check_access(src.scan))
					if (!( src.d1.density ))
						src.d1.close()
						return
					sleep(0.1 SECONDS)
					SPAWN( 0 )
						if (!( src.d2.density ))
							src.d2.close()
						return
		if (href_list["em_op"])
			if (src.scan)
				if (src.check_access(src.scan))
					SPAWN( 0 )
						if (src.d1.density)
							src.d1.open()
						return
					sleep(0.1 SECONDS)
					SPAWN( 0 )
						if (src.d2.density)
							src.d2.open()
						return
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return
