/obj/machinery/computer/security
	name = "Security Cameras"
	icon_state = "security"
	var/obj/machinery/camera/current = null
	var/list/obj/machinery/camera/favorites = list()
	var/const/favorites_Max = 8
	var/network = "SS13"
	var/maplevel = 1
	desc = "A computer that allows one to connect to a security camera network and view camera images."
	deconstruct_flags = DECON_MULTITOOL
	var/chui/window/security_cameras/window
	var/first_click = 1				//for creating the chui on first use
	var/skip_disabled = 1			//If we skip over disabled cameras in AI camera movement mode. Just leaving it in for admins maybe.

	lr = 1
	lg = 0.7
	lb = 0.74

	disposing()
		..()
		window = null

	//This might not be needed. I thought that the proc should be on the computer instead of the mob switching, but maybe not
	proc/switchCamera(var/mob/living/user, var/obj/machinery/camera/C)
		if (!C)
			src.remove_dialog(user)
			user.set_eye(null)
			return 0

		if (user.stat == 2 || C.network != src.network) return 0

		src.current = C
		user.set_eye(C)
		return 1

	//moved out of global to only be used in sec computers
	proc/move_security_camera(/*n,*/direct,var/mob/living/carbon/user)
		if(!user) return

		//pretty sure this should never happen since I'm adding the first camera found to be the current, but just in cases
		if (!src.current)
			boutput(user, "<span class='alert'>No current active camera. Select a camera as an origin point.</span>")
			return


		// if(user.classic_move)
		var/obj/machinery/camera/closest = src.current
		if(istype(closest))
			//do
			if(direct & NORTH)
				closest = closest.c_north
			else if(direct & SOUTH)
				closest = closest.c_south
			if(direct & EAST)
				closest = closest.c_east
			else if(direct & WEST)
				closest = closest.c_west
			// while(closest && !closest.camera_status) //Skip disabled cameras - THIS NEEDS TO BE BETTER (static overlay imo)
		else	//This was for the AI, If there is no current camera, return to the camera nearest the user.
			closest = getCameraMove(user, direct, skip_disabled) //Ok, let's do this then.

		if(!closest)
			return
		else if (!closest.camera_status)
			boutput(user, "<span class='alert'>ERROR. Cannot connect to camera.</span>")
			playsound(src.loc, "sound/machines/buzz-sigh.ogg", 10, 0)
			return
		switchCamera(user, closest)

/obj/machinery/computer/security/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras1"
/obj/machinery/computer/security/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras2"

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	icon_state = "security_det"

	small
		name = "Television"
		desc = "These channels seem to mostly be about robuddies. What is this, some kind of reality show?"
		network = "Zeta"
		icon_state = "security_tv"

		power_change()
			return

// -------------------- VR --------------------
/obj/machinery/computer/security/wooden_tv/small/virtual
	desc = "It's making you feel kinda twitchy for some reason."
	icon = 'icons/effects/VR.dmi'
// --------------------------------------------

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = "thunder"
	density = 0

	power_change()
		return

/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if (status & (NOPOWER|BROKEN) || !user.client)
		return

	if (first_click)
		window = new (src)
		first_click = 0

	//onclose(user, "camera_console", src)
	//winset(user, "camera_console.exitbutton", "command=\".windowclose \ref[src]\"")
	//winshow(user, "camera_console", 1)

	window.Subscribe( user.client )

/obj/machinery/computer/security/Topic(href, href_list)
	if (!usr)
		return
	if (..())
		return
	if (href_list["close"])
		usr.set_eye(null)
		winshow(usr, "camera_console", 0)
		return

	else if (href_list["camera"])
		var/obj/machinery/camera/C = locate(href_list["camera"])
		if (!istype(C, /obj/machinery/camera))
			return

		if ((!isAI(usr)) && (get_dist(usr, src) > 1 || (!usr.using_dialog_of(src)) || !usr.sight_check(1) || !( usr.canmove ) || !( C.camera_status )))
			usr.set_eye(null)
			winshow(usr, "camera_console", 0)
			return

		else
			src.current = C
			usr.set_eye(C)
			use_power(50)

/obj/machinery/computer/security/attackby(obj/item/I as obj, user as mob)
	if (isscrewingtool(I))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 2 SECONDS))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/security/M = new /obj/item/circuitboard/security( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/security/M = new /obj/item/circuitboard/security( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return

proc/getr(col)
	return hex2num( copytext(col, 2,4))

proc/getg(col)
	return hex2num( copytext(col, 4,6))

proc/getb(col)
	return hex2num( copytext(col, 6))
