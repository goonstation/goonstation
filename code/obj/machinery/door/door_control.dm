/obj/machinery/door_control
	name = "Remote Door Control"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for a door."
	var/id = null
	var/timer = 0
	anchored = 1.0
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/r_door_control (door_control.dm)
	// /obj/machinery/door/poddoor/pyro (poddoor.dm)
	// /obj/machinery/door/poddoor/blast/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay
		name = "pod bay door control"

		New()
			..()
			if (!isnull(src.id))
				src.name = "[src.name] ([src.id])"
			return

		wizard
			id = "hangar_wizard"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		syndicate
			id = "hangar_syndicate"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		catering
			id = "hangar_catering"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		arrivals
			id = "hangar_arrivals"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		escape
			id = "hangar_escape"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		mainpod1
			id = "hangar_podbay1"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		mainpod2
			id = "hangar_podbay2"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		engineering
			id = "hangar_engineering"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		security
			id = "hangar_security"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		medsci
			id = "hangar_medsci"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		research
			id = "hangar_research"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		medbay
			id = "hangar_medbay"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		qm
			id = "hangar_qm"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		mining
			id = "hangar_mining"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		miningoutpost
			id = "hangar_miningoutpost"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		diner1
			id = "hangar_spacediner1"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		diner2
			id = "hangar_spacediner2"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		soviet
			id = "hangar_soviet"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

/obj/machinery/door_control/New()
	..()
	UnsubscribeProcess()

/obj/machinery/door_control/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	if(status & (NOPOWER|BROKEN))
		return

	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
		return

	use_power(5)
	icon_state = "doorctrl1"

	if (!src.id)
		return

	logTheThing("station", user, null, "toggled the [src.name] at [log_loc(src)].")

	for (var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			if (M.density)
				M.open()
				if (src.timer)
					SPAWN_DBG(src.timer)
						M.close()
			else
				M.close()
				if (src.timer)
					SPAWN_DBG(src.timer)
						M.open()

	for (var/obj/machinery/door/airlock/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			if (M.density)
				M.open()
			else
				M.close()

	for (var/obj/machinery/conveyor/M in machine_registry[MACHINES_CONVEYORS]) // Workaround for the stacked conveyor belt issue (Convair880).
		if (M.id == src.id)
			if (M.operating)
				M.operating = 0
				if (src.timer)
					SPAWN_DBG(src.timer)
						M.operating = 1
			else
				M.operating = 1
				if (src.timer)
					SPAWN_DBG(src.timer)
						M.operating = 0
			M.setdir()

	SPAWN_DBG(1.5 SECONDS)
		if(!(status & NOPOWER))
			icon_state = "doorctrl0"
	src.add_fingerprint(usr)

/obj/machinery/door_control/power_change()
	..()
	if(status & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/door_control/oneshot/attack_hand(mob/user as mob)
	..()
	if (!(status & BROKEN))
		src.status |= BROKEN
		src.visible_message("<span class='alert'>[src] emits a sad thunk.  That can't be good.</span>")
		playsound(src.loc, "sound/impact_sounds/Generic_Click_1.ogg", 50, 1)
	else
		boutput(user, "<span class='alert'>It's broken.</span>")

////////////////////////////////////////////////////////
//////////////Mass Driver Button	///////////////////
///////////////////////////////////////////////////////
/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/W, mob/user as mob)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	if(status & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			M.open()

	sleep(2 SECONDS)

	for(var/obj/machinery/mass_driver/M in machine_registry[MACHINES_MASSDRIVERS])
		if(M.id == src.id)
			M.drive()

	sleep(5 SECONDS)

	for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			M.close()

	icon_state = "launcherbtt"
	active = 0

	return


///////////Uses a radio signal to control the door
//////////////////////////////////////////////////////////////////////////
///////Remote Door Control //////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

/obj/machinery/r_door_control
	name = "Remote Door Control"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "sec_lock"
	desc = "A remote recieving device for a door."
	var/id = null
	var/pass = null
	var/frequency = 1142
	var/open = 0 //open or not?
	var/access_type = 1
	var/access_type_secondary = null
	anchored = 1.0
	var/datum/light/light

	syndicate
		access_type = -1

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/door/poddoor/pyro (poddoor.dm)
	// /obj/machinery/door/poddoor/blast/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay
		name = "pod bay door control"

		wizard
			id = "hangar_wizard"
			access_type = -2

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		syndicate
			id = "hangar_syndicate"
			access_type = -1

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		catering
			id = "hangar_catering"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		arrivals
			id = "hangar_arrivals"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		escape
			id = "hangar_escape"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		mainpod1
			id = "hangar_podbay1"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		mainpod2
			id = "hangar_podbay2"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		engineering
			id = "hangar_engineering"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		security
			id = "hangar_security"
			access_type = 2
			#ifdef MAP_OVERRIDE_MANTA
			access_type_secondary = 2
			#else
			access_type_secondary = null
			#endif


			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		medsci
			id = "hangar_medsci"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		research
			id = "hangar_research"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		medbay
			id = "hangar_medbay"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		qm
			id = "hangar_qm"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		mining
			id = "hangar_mining"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		miningoutpost
			id = "hangar_miningoutpost"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		diner1
			id = "hangar_spacediner1"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		diner2
			id = "hangar_spacediner2"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		soviet
			id = "hangar_soviet"
			access_type = -1

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

	New()
		..()
		UnsubscribeProcess()
		SPAWN_DBG(0.5 SECONDS)	// must wait for map loading to finish
			if(radio_controller)
				radio_controller.add_object(src, "[frequency]")

		if(id)
			pass = "[id]-[rand(1,50)]"
			name = "Access Code: [pass]"
		light = new /datum/light/point //They were kinda dark okay
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.25)
		light.set_color(0.9, 0.5, 0.5)
		light.enable()
		return

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

	Click(var/location,var/control,var/params)
		if(get_dist(usr, src) < 16)
			if(istype(usr.loc, /obj/machinery/vehicle))
				var/obj/machinery/vehicle/V = usr.loc
				if (!V.com_system)
					boutput(usr, "<span class='alert'>Your pod has no comms system installed!</span>")
					return ..()
				if (!V.com_system.active)
					boutput(usr, "<span class='alert'>Your communications array isn't on!</span>")
					return ..()
				if (!access_type)
					open_door()
				else if (!access_type_secondary)
					open_door()
				else if (!access_type_secondary)
					open_door()
				else
					if(V.com_system.access_type == src.access_type)
						open_door()

					else if(V.com_system.access_type_secondary == src.access_type_secondary)
						open_door()
					else
						boutput(usr, "<span class='alert'>Access denied. Comms system not recognized.</span>")
						return ..()
			return ..()

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/device/detective_scanner))
			return
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		boutput(user, "<span class='notice'>The password is \[[src.pass]\]</span>")
		return

	proc/open_door()
		if(status & (NOPOWER|BROKEN))
			return
		use_power(5)

		for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
			if (M.id == src.id)
				if (M.density)
					M.open()
					src.open = 1
				else
					M.close()
					src.open = 0

	receive_signal(datum/signal/signal)
		if(..())
			return
		//////Open Door
		if(signal.data["command"] =="open door")
			if(!signal.data["doorpass"])
				return
			if(!signal.data["access_type"] || signal.data["access_type"] != src.access_type)
				return

			if(signal.data["doorpass"] == src.pass)
				if(status & (NOPOWER|BROKEN))
					return
				use_power(5)

				for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
					if (M.id == src.id)
						if (M.density)
							M.open()
						else
							M.close()
			return
		////////reset pass
		if(signal.data["command"] =="reset door pass")
			if(!signal.data["doorpass"])
				pass = "[id]-[rand(100,999)]"
				return
			if(signal.data["doorpass"] == src.pass)
				if(signal.data["newpass"])
					pass = signal.data["newpass"]
					return
				else
					pass = "[id]-[rand(100,999)]"
				return
			return
		return

	proc/post_signal(datum/signal/signal,var/newfreq)
		if(!signal)
			return
		var/freq = newfreq
		if(!freq)
			freq = src.frequency

		signal.source = src

		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

		signal.transmission_method = TRANSMISSION_RADIO
		if(frequency)
			return frequency.post_signal(src, signal)
		//else
			//qdel(signal)
