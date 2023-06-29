ADMIN_INTERACT_PROCS(/obj/machinery/door_control, proc/toggle)
/obj/machinery/door_control
	name = "Remote Door Control"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for a door."
	var/id = null
	var/timer = 0
	var/cooldown = 0 SECONDS
	var/inuse = FALSE
	anchored = ANCHORED
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
		t1d1
			id = "hangar_t1d1"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t1d2
			id = "hangar_t1d2"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t1d3
			id = "hangar_t1d3"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t1d4
			id = "hangar_t1d4"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t1condoor
			id = "hangar_t1condoor"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t2d1
			id = "hangar_t2d1"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t2d2
			id = "hangar_t2d2"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t2d3
			id = "hangar_t2d3"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t2d4
			id = "hangar_t2d4"

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 24
				south
					pixel_y = -19
				west
					pixel_x = -24

		t2condoor
			id = "hangar_t2condoor"

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
	return src.Attackhand(user)

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.Attackhand(user)

/obj/machinery/door_control/attack_hand(mob/user)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat)
		return
	src.toggle(user)
	src.add_fingerprint(user)

/obj/machinery/door_control/proc/toggle(mob/user)
	if((src.status & (NOPOWER|BROKEN)) || inuse)
		return

	src.use_power(5)
	icon_state = "doorctrl1"
	playsound(src.loc, 'sound/machines/button.ogg', 40, 0.5)

	if (!src.id)
		return

	logTheThing(LOG_STATION, user || usr, "toggled the [src.name] at [log_loc(src)].")

	for (var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			if (M.density)
				M.open()
				if (src.timer)
					SPAWN(src.timer)
						M.close()
			else
				M.close()
				if (src.timer)
					SPAWN(src.timer)
						M.open()

	for (var/obj/machinery/door/airlock/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			if (M.density)
				M.open()
			else
				M.close()

	for (var/obj/machinery/conveyor/M as anything in machine_registry[MACHINES_CONVEYORS]) // Workaround for the stacked conveyor belt issue (Convair880).
		if (M.id == src.id)
			if (M.operating)
				M.operating = 0
				if (src.timer)
					SPAWN(src.timer)
						M.operating = 1
			else
				M.operating = 1
				if (src.timer)
					SPAWN(src.timer)
						M.operating = 0
			M.setdir()

	if(src.cooldown)
		inuse = TRUE
		sleep(src.cooldown)
		inuse = FALSE

	SPAWN(1.5 SECONDS)
		if(!(src.status & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	..()
	if(src.status & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/door_control/oneshot/attack_hand(mob/user)
	..()
	if (!(src.status & BROKEN))
		src.status |= BROKEN
		src.visible_message("<span class='alert'>[src] emits a sad thunk.  That can't be good.</span>")
		playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 50, 1)
	else
		boutput(user, "<span class='alert'>It's broken.</span>")

////////////////////////////////////////////////////////
//////////// Machine activation buttons	///////////////
///////////////////////////////////////////////////////
ABSTRACT_TYPE(/obj/machinery/activation_button)
/obj/machinery/activation_button
	name = "Activation Button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for ... something."
	/// compatible machines with a matching id will be activated
	var/id = null
	var/active = FALSE
	anchored = ANCHORED

	proc/activate()
		return

/obj/machinery/activation_button/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/activation_button/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.Attackhand(user)

/obj/machinery/activation_button/attack_hand(mob/user)
	if(src.status & (NOPOWER|BROKEN))
		return
	if(active)
		return

	src.use_power(5)
	playsound(src.loc, 'sound/machines/button.ogg', 40, 0.5)
	src.active = TRUE
	icon_state = "launcheract"

	// the activate procs usually do some spooky sleep() calls here to delay this
	src.activate()

	icon_state = "launcherbtt"
	active = 0
	return

/obj/machinery/activation_button/driver_button
	name = "Mass Driver Button"
	desc = "A remote control switch for a Mass Driver."

	activate()
		for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
			if (M.id == src.id)
				M.open()

		sleep(2 SECONDS)

		for(var/obj/machinery/mass_driver/M as anything in machine_registry[MACHINES_MASSDRIVERS])
			if(M.id == src.id)
				M.drive()

		#ifdef UPSCALED_MAP
		sleep(8 SECONDS)
		#else
		sleep(5 SECONDS)
		#endif

		for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
			if (M.id == src.id)
				M.close()

/obj/machinery/activation_button/flusher_button
	name = "Flusher Button"
	desc = "A remote control switch for a Floor Flusher."

	activate()
		for(var/obj/machinery/floorflusher/M in by_type[/obj/machinery/floorflusher])
			if(M.id == src.id)
				if(M.open)
					M.closeup()
				else
					M.openup()

		sleep(2 SECONDS)


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
	var/frequency = FREQ_DOOR_CONTROL
	var/open = 0 //open or not?
	var/access_type = POD_ACCESS_STANDARD
	anchored = ANCHORED
	var/datum/light/light

	syndicate
		access_type = POD_ACCESS_SYNDICATE

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/door/poddoor/pyro (poddoor.dm)
	// /obj/machinery/door/poddoor/blast/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay
		name = "pod bay door control"

		wizard
			id = "hangar_wizard"
			access_type = POD_ACCESS_WIZARDS

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
			access_type = POD_ACCESS_SYNDICATE

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
			access_type = POD_ACCESS_SECURITY


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
			access_type = POD_ACCESS_SYNDICATE

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22
		t1d1
			id = "hangar_t1d1"
			access_type = POD_ACCESS_SECURITY

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t1d2
			id = "hangar_t1d2"
			access_type = POD_ACCESS_SECURITY

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t1d3
			id = "hangar_t1d3"
			access_type = POD_ACCESS_SECURITY

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t1d4
			id = "hangar_t1d4"
			access_type = POD_ACCESS_SECURITY

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t1condoor
			id = "hangar_t1condoor"
			access_type = POD_ACCESS_SECURITY

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t2d1
			id = "hangar_t2d1"
			access_type = POD_ACCESS_SYNDICATE

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t2d2
			id = "hangar_t2d2"
			access_type = POD_ACCESS_SYNDICATE

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t2d3
			id = "hangar_t2d3"
			access_type = POD_ACCESS_SYNDICATE

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t2d4
			id = "hangar_t2d4"
			access_type = POD_ACCESS_SYNDICATE

			new_walls
				north
					pixel_y = 24
				east
					pixel_x = 22
				south
					pixel_y = -19
				west
					pixel_x = -22

		t2condoor
			id = "hangar_t2condoor"
			access_type = POD_ACCESS_SYNDICATE

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
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

		if(id)
			pass = "[id]-[rand(1,50)]"
			name = "Access Code: [pass]"
		light = new /datum/light/point //They were kinda dark okay
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.25)
		light.set_color(0.9, 0.5, 0.5)
		light.enable()

	Click(var/location,var/control,var/params)
		if(GET_DIST(usr, src) < 16)
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
				else
					if(V.com_system.access_type.Find(src.access_type))
						open_door()
					else
						boutput(usr, "<span class='alert'>Access denied. Comms system not recognized.</span>")
						return ..()
			return ..()

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/device/detective_scanner))
			return
		return src.Attackhand(user)

	attack_hand(mob/user)
		boutput(user, "<span class='notice'>The password is \[[src.pass]\]</span>")
		return

	proc/open_door()
		if(src.status & (NOPOWER|BROKEN))
			return
		src.use_power(5)

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
			if(!signal.data["access_type"])
				return
			var/list/signal_access_types = splittext(signal.data["access_type"],";")
			// the signal process makes the list of numbers into a list of strings
			// this is easier than making all the signal_access_types elements back into numbers
			if(!(signal_access_types.Find("[src.access_type]")))
				return

			if(signal.data["doorpass"] == src.pass)
				if(src.status & (NOPOWER|BROKEN))
					return
				src.use_power(5)

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

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)
