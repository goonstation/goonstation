// Disposal pipe construction

/obj/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/disposal.dmi'
	icon_state = "conpipe-s"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	m_amt = 1850
	level = 2
	help_message = {"You can use a <b>wrench</b> to (un)anchor the pipe segment, a <b>crowbar</b> to rotate it, a <b>screwdriver</b> to disassemble it, and a <b>welding tool</b> to turn it into a functional immovable pipe."}

	var/ptype = 0
	// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk, 6 & 7=switching junction, 8 & 9=mob filter junction, 10 = loafer, 11 = mechanics controlled junction

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"
	var/mail_tag = null //For pipes that use mail filtering
	var/filter_type = null //For pipes that filter objects passing through.

	// update iconstate and dpdir due to dir and type
	proc/update()
		var/flip = turn(dir, 180)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)

		switch(ptype)
			if(0)
				base_state = "pipe-s"
				dpdir = dir | flip
			if(1)
				base_state = "pipe-c"
				dpdir = dir | right
			if(2)
				base_state = "pipe-j1"
				dpdir = dir | right | flip
			if(3)
				base_state = "pipe-j2"
				dpdir = dir | left | flip
			if(4)
				base_state = "pipe-y"
				dpdir = dir | left | right
			if(5)
				base_state = "pipe-t"
				dpdir = dir
			if(6,8)
				base_state = "pipe-sj1"
				dpdir = dir
			if(7,9)
				base_state = "pipe-sj2"
				dpdir = dir
			if(10)
				base_state = "pipe-loaf0"
				dpdir = dir
			if(11)
				base_state = "pipe-mech"
				dpdir = dir | left | flip
			if(12)
				base_state = "pipe-mechsense"
				dpdir = dir | flip


		icon_state = "con[base_state]"

		if(invisibility)				// if invisible, fade icon
			icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = (intact && level==1) ? INVIS_ALWAYS : INVIS_NONE	// hide if floor is intact
		update()

	// returns the type path of disposalpipe corresponding to this item dtype
	proc/dpipetype()
		switch(ptype)
			if(0,1)
				return /obj/disposalpipe/segment
			if(2,3,4)
				return /obj/disposalpipe/junction
			if(5)
				return /obj/disposalpipe/trunk
			if(6,7)
				return /obj/disposalpipe/switch_junction
			if(8,9)
				return /obj/disposalpipe/switch_junction/biofilter
			if(10)
				return /obj/disposalpipe/loafer
			if(11)
				return /obj/disposalpipe/mechanics_switch
			if(12)
				return /obj/disposalpipe/mechanics_sensor
		return

	// click the junction with empty hand to change direction
	attack_hand(mob/user)
		if(!anchored)
			if(ptype == 2)
				ptype = 3
				set_dir(turn(dir, 180))
				boutput(user, "You change the pipe junction's direction.")
			else if (ptype == 3)
				ptype = 2
				set_dir(turn(dir, 180))
				boutput(user, "You change the pipe junction's direction.")
			update()

	// attackby item
	// crowbar: rotate
	// screwdriver: disassemble
	// wrench: (un)anchor
	// weldingtool: convert to real pipe

	attackby(var/obj/item/I, var/mob/user)
		if(ispryingtool(I) && !anchored)
			set_dir(turn(dir, -90))
			update()
			return

		if(isscrewingtool(I))
			boutput(user, "You take the pipe segment apart.")
			// var/obj/item/sheet/A = new /obj/item/sheet(get_turf(src))
			// if(src.material)
			// 	A.setMaterial(src.material)
			// else
			// 	var/datum/material/M = getMaterial("steel")
			// 	A.setMaterial(M)
			qdel(src)
			return

		var/turf/T = src.loc
		if(T.intact && (iswrenchingtool(I) || isweldingtool(I))) //to stop it from screaming about it when rotating the pipe with crowbar
			boutput(user, "You can only attach the pipe if the floor plating is removed.")
			return

		var/obj/disposalpipe/CP = locate() in T
		if(CP)
			update()
			var/pdir = CP.dpdir
			if(istype(CP, /obj/disposalpipe/broken))
				pdir = CP.dir
			if((pdir & dpdir) && (iswrenchingtool(I) || isweldingtool(I))) //see the comment above
				boutput(user, "There is already a pipe at that location.")
				return

		if (iswrenchingtool(I))
			if(anchored)
				anchored = 0
				level = 2
				set_density(1)
				boutput(user, "You detach the pipe from the underfloor.")
			else
				anchored = 1
				level = 1
				set_density(0)
				boutput(user, "You attach the pipe to the underfloor.")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)

		else if(isweldingtool(I))
			if(I:try_weld(user, 2, noisy = 2))
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = I.loc
				var/turf/ploc = loc
				boutput(user, "You begin welding [src] in place.")
				sleep(0.1 SECONDS)
				if(user.loc == uloc && wloc == I.loc)
					// REALLY? YOU DON'T FUCKING CARE ABOUT THE LOCATION OF THE PIPE? GET FUCKED <CODER>
					if (ploc != loc)
						boutput(user, "<span class='alert'>As you try to weld the pipe to a completely different floor than it was originally placed on it breaks!</span>")
						ploc = loc
						SPAWN(0)
							robogibs(ploc)
							//if (isrestrictedz(ploc.z))
								//explosion_new(src, ploc, 3) // okay yes we don't need to explode people for this
						qdel(src)
						return
					update()
					var/pipetype = dpipetype()
					var/obj/disposalpipe/P = new pipetype(src.loc)
					P.base_icon_state = base_state
					P.set_dir(dir)
					P.dpdir = dpdir
					P.mail_tag = mail_tag
					P.UpdateIcon()
					boutput(user, "You weld [P] in place.")
					logTheThing(LOG_STATION, user, "welded the disposal pipe in place at [log_loc(P)]")

					qdel(src)
				else
					boutput(user, "You must stay still while welding.")
					return

/obj/disposalconstruct/mechanics
	name = "controlled pipe junction"
	ptype = 11
	base_state = "pipe-mech"
	icon_state = "conpipe-mech"

/obj/disposalconstruct/mechanics_sensor
	name = "sensor pipe"
	ptype = 12
	base_state = "pipe-mechsense"
	icon_state = "pipe-mechsense"
