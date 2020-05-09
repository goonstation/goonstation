/obj/machinery/computer/genetics/portable
	name = "Port-A-Gene"
	desc = "A mobile scanner and computer in one unit for genetics work."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "PAG_0"
	anchored = 0
	var/mob/occupant = null
	var/locked = 0

	New()
		..()
		genetics_computers += src
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (isscrewingtool(W) && (src.status & BROKEN))
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
			if(do_after(user, 20))
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/genetics/M = new /obj/item/circuitboard/genetics( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W

			if (src.occupant)
				boutput(user, "<span class='alert'><B>The scanner is already occupied!</B></span>")
				return

			if (src.locked)
				boutput(usr, "<span class='alert'><B>You need to unlock the scanner first.</B></span>")
				return

			if(!iscarbon(G.affecting))
				boutput(user, "<span class='hint'><B>The scanner supports only carbon based lifeforms.</B></span>")
				return

			var/mob/M = G.affecting
			if (user.pulling == M)
				user.pulling = null
			src.go_in(M)

			for(var/obj/O in src)
				O.set_loc(src.loc)

			src.add_fingerprint(user)
			qdel(G)
			return
		else
			src.attack_hand(user)
		return

	power_change()
		return

	verb/eject()
		set name = "Eject Occupant"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return
		if (src.locked)
			boutput(usr, "<span class='alert'><b>The scanner door is locked!</b></span>")
			return

		src.go_out()
		add_fingerprint(usr)
		return

	verb/enter()
		set name = "Enter"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return
		if (src.locked)
			boutput(usr, "<span class='alert'><b>The scanner door is locked!</b></span>")
			return
		if (src.occupant)
			boutput(usr, "<span class='alert'>It's already occupied.</span>")
			return

		src.go_in(usr)
		add_fingerprint(usr)
		return

	verb/lock()
		set name = "Scanner Lock"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return
		if (usr == src.occupant)
			boutput(usr, "<span class='alert'><b>You can't reach the scanner lock from the inside.</b></span>")
			return

		playsound(src.loc, "sound/machines/click.ogg", 50, 1)
		if (src.locked)
			src.locked = 0
			usr.visible_message("<b>[usr]</b> unlocks the scanner.")
			if (src.occupant)
				boutput(src.occupant, "<span class='alert'>You hear the scanner's lock slide out of place.</span>")
		else
			src.locked = 1
			usr.visible_message("<b>[usr]</b> locks the scanner.")
			if (src.occupant)
				boutput(src.occupant, "<span class='alert'>You hear the scanner's lock click into place.</span>")

	proc/go_out()
		if (!src.occupant)
			return

		if (src.locked)
			return

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.occupant.set_loc(src.loc)
		src.occupant = null
		src.icon_state = "PAG_0"
		return

	proc/go_in(var/mob/M)
		if (src.occupant || !M)
			return

		if (src.locked)
			return

		M.set_loc(src)
		src.occupant = M
		src.icon_state = "PAG_1"
		return

	get_scan_subject()
		if (!src)
			return null
		if (occupant)
			return occupant
		else
			return null

	get_scanner()
		if (!src)
			return null
		return src
