TYPEINFO(/obj/item/device/transfer_valve)
	mats = 5

/obj/item/device/transfer_valve
	icon = 'icons/obj/items/assemblies.dmi' //TODO: as of 02/02/2020 missing sprite for regular air tank
	name = "tank transfer valve" // because that's what it is exadv1 and don't you dare change it
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks."
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi' //TODO: as of 02/02/2020 only single general plasma+oxygen ttv sprites, no functionality or sprites to change the icon depending on tanks used
	item_state = "newbomb"
	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/device/attached_device
	var/mob/attacher = "Unknown"
	var/valve_open = FALSE
	var/toggle = TRUE
	var/force_dud = FALSE
	var/signalled = FALSE
	var/tank_one_icon = null
	var/tank_two_icon = null
	var/image/tank_one_image = null
	var/image/tank_two_image = null
	var/image/tank_one_image_under = null
	var/image/tank_two_image_under = null

	w_class = W_CLASS_GIGANTIC /// HEH
	p_class = 3 /// H E H

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_BOMB_SIGNAL_START, .proc/signal_start)
		RegisterSignal(src, COMSIG_ITEM_BOMB_SIGNAL_CANCEL, .proc/signal_cancel)
		processing_items |= src

	disposing()
		processing_items -= src
		qdel(src.tank_one)
		src.tank_one = null
		qdel(src.tank_two)
		src.tank_two = null
		qdel(src.attached_device)
		src.attached_device = null
		..()

	Exited(thing, newloc)
		. = ..()
		if (thing == src.tank_one)
			src.tank_one = null
			src.UpdateIcon()
		else if (thing == src.tank_two)
			src.tank_two = null
			src.UpdateIcon()
		else if (thing == src.attached_device)
			src.attached_device = null
			src.UpdateIcon()


	attackby(obj/item/item, mob/user)
		if (isghostdrone(user))
			return ..()
		if (user.mind && user.mind.gang)
			boutput(user, "<span class='alert'>You think working with explosives would bring a lot of much heat onto your gang to mess with this. But you do it anyway.</span>")
		if(istype(item, /obj/item/tank) || istype(item, /obj/item/clothing/head/butt))
			if(istype(item, /obj/item/tank))
				var/obj/item/tank/myTank = item
				if(!myTank.compatible_with_TTV)
					boutput(user, "<span class='alert'>There's no way that will fit!</span>")
					return

			if(tank_one && tank_two)
				boutput(user, "<span class='alert'>There are already two tanks attached, remove one first!</span>")
				return

			if(!tank_one)
				tank_one = item
				user.drop_item()
				item.set_loc(src)
				boutput(user, "<span class='notice'>You attach \the [item] to the transfer valve</span>")
			else if(!tank_two)
				tank_two = item
				user.drop_item()
				item.set_loc(src)
				boutput(user, "<span class='notice'>You attach the \the [item] to the transfer valve!</span>")

			if(tank_one && tank_two)
				var/turf/T = get_turf(src)
				var/butt = istype(tank_one, /obj/item/clothing/head/butt) || istype(tank_two, /obj/item/clothing/head/butt)
				logTheThing(LOG_BOMBING, user, "made a transfer valve [butt ? "butt" : "bomb"] at [log_loc(T)].")
				message_admins("[key_name(user)] made a transfer valve [butt ? "butt" : "bomb"] at [log_loc(T)].")

			UpdateIcon()
			attacher = user

			if(user.back == src)
				user.update_clothing()

		else if(istype(item, /obj/item/device/radio/signaler) || istype(item, /obj/item/device/timer) || istype(item, /obj/item/device/infra) || istype(item, /obj/item/device/prox_sensor))
			if(attached_device)
				boutput(user, "<span class='alert'>There is already an device attached to the valve, remove it first!</span>")
				return

			attached_device = item
			user.drop_item()
			item.set_loc(src)
			boutput(user, "<span class='notice'>You attach the [item] to the valve controls!</span>")
			item.master = src

			/*
			var/extra = ""
			if (istype(item, /obj/item/device/timer))
				if (item:timing)
					extra = "n <font color='red'>active</font>"


			logTheThing(LOG_BOMBING, user, "made a bomb using a[extra] [item.name] and a transfer valve.")
			message_admins("[key_name(user)] made a bomb using a[extra] [item.name] and a transfer valve.")
			*/
			attacher = user
			UpdateIcon()

		else if(istype(item, /obj/item/cable_coil)) //make loops for shoulder straps
			if(c_flags & ONBACK)
				boutput(user, "<span class='alert'>The valve already has shoulder straps!</span>")
				return

			var/obj/item/cable_coil/coil = item
			if (coil.amount < 2)
				boutput(user, "<span class='alert'>You do not have enough cable to produce two straps! (2 units required)</span>")
				return
			coil.use(2)

			c_flags |= ONBACK
			boutput(user, "<span class='notice'>You attach two loops of [item] to the transfer valve!</span>")
			UpdateIcon()

		return

	attack_self(mob/user as mob)
		if (isghostdrone(user))
			return
		if (user.mind && user.mind.gang)
			boutput(user, "<span class='alert'>You think working with explosives would bring a lot of much heat onto your gang to mess with this. But you do it anyway.</span>")
		src.add_dialog(user)
		var/dat = {"<B> Valve properties: </B>
		<BR> <B> Attachment one:</B> [tank_one] [tank_one ? "<A href='?src=\ref[src];tankone=1'>Remove</A>" : ""]
		<BR> <B> Attachment two:</B> [tank_two] [tank_two ? "<A href='?src=\ref[src];tanktwo=1'>Remove</A>" : ""]
		<BR> <B> Valve attachment:</B> [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]
		<BR> <B> Valve status: </B> [ valve_open ? "<A href='?src=\ref[src];open=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];open=1'>Open</A>"]
		<BR> [c_flags & ONBACK ? "<B> Straps: </B> <A href='?src=\ref[src];straps=1'>Remove</A>" : ""]"}

		user.Browse(dat, "window=trans_valve;size=600x300")
		onclose(user, "trans_valve")
		return

	Topic(href, href_list)
		..()
		if (isghostdrone(usr))
			return
		if (usr.mind && usr.mind.gang)
			boutput(usr, "<span class='alert'>You think working with explosives would bring a lot of much heat onto your gang to mess with this. But you do it anyway.</span>")
		if (usr.stat|| usr.restrained())
			return
		if (src.loc == usr)
			if(href_list["tankone"])
				tank_one.set_loc(get_turf(src))
				tank_one = null
				UpdateIcon()
			if(href_list["tanktwo"])
				tank_two.set_loc(get_turf(src))
				tank_two = null
				UpdateIcon()
			if(href_list["open"])
				if (valve_open)
					var/turf/bombturf = get_turf(src)
					logTheThing(LOG_BOMBING, usr, "closed the valve on a tank transfer valve at [log_loc(bombturf)].")
					message_admins("[key_name(usr)] closed the valve on a tank transfer valve at [log_loc(bombturf)].")
				else
					var/turf/bombturf = get_turf(src)
					logTheThing(LOG_BOMBING, usr, "opened the valve on a tank transfer valve at [log_loc(bombturf)].")
					message_admins("[key_name(usr)] opened the valve on a tank transfer valve at [log_loc(bombturf)].")
				toggle_valve()
			if(href_list["rem_device"])
				attached_device.set_loc(get_turf(src))
				attached_device.master = null
				attached_device = null
				UpdateIcon()
			if(href_list["device"])
				attached_device.attack_self(usr)
			if(href_list["straps"])
				if(usr?.back && usr.back == src)
					boutput(usr, "<span class='alert'>You can't detach the loops of wire while you're wearing [src]!</span>")
				else
					c_flags &= ~ONBACK
					var/turf/location = get_turf(src)
					var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(location)
					C.amount = 2
					boutput(usr, "<span class='notice'>You detach the loops of wire from [src]!</span>")
					UpdateIcon()

			src.attack_self(usr)

			src.add_fingerprint(usr)
			return

	receive_signal(signal)
		if(toggle)
			toggle = 0
			toggle_valve()
			SPAWN(5 SECONDS) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
				toggle = 1

	process()
		if(signalled)
			UpdateIcon()

	proc/signal_start()
		signalled = TRUE

	proc/signal_cancel()
		signalled = FALSE

	update_icon()
		//blank slate
		src.overlays = new/list()
		src.underlays = new/list()
		src.wear_image = image(wear_image_icon, "valve")

		if(!tank_one && !tank_two && !attached_device && !(c_flags & ONBACK))
			icon_state = "valve_1"
			return

		icon_state = "valve"
		var/device_icon = ""

		if(tank_one)
			tank_one_icon = tank_one.icon_state

			var/image/I = new(src.icon, icon_state = "[tank_one_icon]")
			//var/obj/overlay/tank_one_overlay = new
			//tank_one_overlay.icon = src.icon
			//tank_one_overlay.icon_state = tank_one_icon
			src.overlays += I

			src.tank_one_image = new(src.wear_image_icon, icon_state = "[tank_one_icon]1")
			src.tank_one_image_under = new(src.wear_image_icon, icon_state = "[tank_one_icon]_under")
			src.wear_image.overlays += tank_one_image
			src.wear_image.underlays += tank_one_image_under

		if(tank_two)
			tank_two_icon = tank_two.icon_state

			var/image/J = new(src.icon, icon_state = "[tank_two_icon]")
			if(istype(tank_two, /obj/item/clothing/head/butt))
				J.transform = matrix(J.transform, -180, MATRIX_ROTATE | MATRIX_MODIFY)
				J.pixel_y = -1
				J.pixel_x = -1
			else
				J.pixel_x = -20
			//var/obj/underlay/tank_two_overlay = new
			//tank_two_overlay.icon = I
			src.overlays += J

			src.tank_two_image = new(src.wear_image_icon, icon_state = "[tank_two_icon]2")
			src.tank_two_image_under = new(src.wear_image_icon, icon_state = "[tank_two_icon]_under")
			src.wear_image.overlays += tank_two_image
			src.wear_image.underlays += tank_two_image_under

		if(attached_device)
			device_icon = attached_device.icon_state
			var/image/K
			if(istype(attached_device, /obj/item/device/prox_sensor))
				var/obj/item/device/prox_sensor/prox = attached_device
				var/state = 0
				if(prox.armed)
					state = 1
				else if(prox.timing)
					state = 2
				K = new(src.icon, icon_state = "motion[state]")
			else if(istype(attached_device, /obj/item/device/timer))
				var/obj/item/device/timer/time = attached_device
				var/state = 0
				if(time.timing && time.time)
					if(time.time < 5)
						state = 2
					else
						state = 1
				K = new(src.icon, icon_state = "timer[state]")
			else
				K = new(src.icon, icon_state = "[device_icon]")
			src.overlays += K

		if(c_flags & ONBACK)
			var/image/straps = new(src.icon, icon_state = "wire_straps")
			src.underlays += straps

	update_wear_image(mob/living/carbon/human/H, override) // Doing above but for mutantraces if they have a special varient.
		src.tank_one_image = image(src.wear_image.icon,"[override ? "back-" : ""][tank_one_icon]1")
		src.tank_one_image_under = image(src.wear_image.icon,"[override ? "back-" : ""][tank_one_icon]_under",)
		src.tank_two_image = image(src.wear_image.icon,"[override ? "back-" : ""][tank_two_icon]2")
		src.tank_two_image_under = image(src.wear_image.icon,"[override ? "back-" : ""][tank_two_icon]_under")
		src.wear_image.overlays = list(tank_one_image, tank_two_image)
		src.wear_image.underlays = list(tank_one_image_under, tank_two_image_under)

		/*
		Exadv1: I know this isn't how it's going to work, but this was just to check
		it explodes properly when it gets a signal (and it does).
		*/
	proc
		toggle_valve()
			src.valve_open = !valve_open
			SPAWN(1 SECOND)
				signalled = FALSE
			if(valve_open && force_dud)
				message_admins("A bomb valve would have opened at [log_loc(src)] but was forced to dud! Last touched by: [key_name(src.fingerprintslast)]")
				logTheThing(LOG_BOMBING, null, "A bomb valve would have opened at [log_loc(src)] but was forced to dud! Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")
				return

			if(valve_open && (istype(tank_one, /obj/item/clothing/head/butt) || istype(tank_two, /obj/item/clothing/head/butt))) //lol
				var/obj/item/tank/T
				var/obj/item/clothing/head/butt/B
				if(istype(tank_one, /obj/item/tank))
					T = tank_one
				else if(istype(tank_one, /obj/item/clothing/head/butt))
					B = tank_one
				if(istype(tank_two, /obj/item/tank))
					T = tank_two
				else if(istype(tank_two, /obj/item/clothing/head/butt))
					B = tank_two

				if(!B || !T) return

				var/power = min(MIXTURE_PRESSURE(T.air_contents) / TANK_RUPTURE_PRESSURE, 2)
				DEBUG_MESSAGE("Power: [power]")

				if(power < 0.3) //Really weak
					return
				else if (power < 0.5)
					visible_message("<span class='combat'>\The [src] farts [pick_string("descriptors.txt", "mopey")]</span>")
					playsound(src, 'sound/voice/farts/poo2.ogg', 30, 2, channel=VOLUME_CHANNEL_EMOTE)
					return

				var/stun_time = 6 * power
				var/fart_range = 12 * power
				var/throw_speed = 30 * power
				var/throw_repeat = 6 * power
				var/sound_volume = 100 * power

				playsound(src, 'sound/voice/farts/superfart.ogg', sound_volume, 2, channel=VOLUME_CHANNEL_EMOTE)
				visible_message("<span class='combat bold' style='font-size:[100 + (100*(power-0.5))]%;'>\The [src] farts loudly!</span>")

				for(var/mob/living/L in hearers(get_turf(src), fart_range))
					shake_camera(L,10,32)
					boutput(L, "<span class='alert'>You are sent flying!</span>")

					L.changeStatus("weakened", stun_time SECONDS)
					while (throw_repeat > 0)
						throw_repeat--
						step_away(L,get_turf(src),throw_speed)

				T.air_contents.zero() //I could also make it vent the gas, I guess, but then it'd be off-limits to non-antagonists. Challenge mode: make a safe ttb?
				qdel(B)
				SPAWN(1 SECOND)
					UpdateIcon()
				return

			if(valve_open && (tank_one && tank_two) && tank_one.air_contents && tank_two.air_contents)
				var/turf/bombturf = get_turf(src)
				var/area/A = get_area(bombturf)
				if(!A.dont_log_combat)
					logTheThing(LOG_BOMBING, null, "Bomb valve opened in [log_loc(bombturf)]. Last touched by [src.fingerprintslast]")
					message_admins("Bomb valve opened in [log_loc(bombturf)]. Last touched by [src.fingerprintslast]")

				var/datum/gas_mixture/temp

				temp = tank_one.air_contents.remove_ratio(1)

				tank_two.air_contents.volume = tank_one.air_contents.volume
				tank_two.air_contents.merge(temp)

				temp = tank_two.air_contents.remove_ratio(0.5)
				tank_one.air_contents.merge(temp)

				SPAWN(2 SECONDS) // In case one tank bursts
					src.UpdateIcon()

		// this doesn't do anything but the timer etc. expects it to be here
		// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
		c_state()
			return

//Prox sensor handling.

	Move()
		. = ..()
		if(istype(attached_device,/obj/item/device/prox_sensor))
			var/obj/item/device/prox_sensor/A = attached_device
			A.sense()

	dropped()
		..()
		if(istype(attached_device,/obj/item/device/prox_sensor))
			var/obj/item/device/prox_sensor/A = attached_device
			A.sense()

	HasProximity(atom/movable/AM as mob|obj)
		if(istype(attached_device,/obj/item/device/prox_sensor))
			if (istype(AM, /obj/projectile))
				return
			if (AM.move_speed < 12)
				var/obj/item/device/prox_sensor/A = attached_device
				A.sense()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] drops [src], takes a short run up and kicks the valve as hard as [he_or_she(user)] can, knocking it [valve_open ? "closed" : "open"]!</b></span>")
		user.u_equip(src)
		src.set_loc(user.loc)
		toggle_valve()
		SPAWN(2 SECONDS)
			if (user)
				user.suiciding = 0
				if(isalive(user) && src && GET_DIST(user,src) <= 7)
					user.visible_message("<span class='alert'>[user] stares at the [src.name], a confused expression on [his_or_her(user)] face.</span>") //It didn't blow up!
		return 1

TYPEINFO(/obj/item/device/transfer_valve/briefcase)
	mats = 8

/obj/item/device/transfer_valve/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	var/obj/item/storage/briefcase/B = null

	update_icon()

		return

/obj/item/device/transfer_valve/vr
	name = "VR explosive"
	var/obj/machinery/networked/storage/bomb_tester/tester = null
	var/updates_before_halt = 10 //So we don't keep updating on a dud bomb forever.
	var/update_counter = 0

	attack_hand(mob/user)
		return

	disposing()
		processing_items.Remove(src)
		if(tester)
			tester.update_bomb_log("VR Bomb deleted.", 1)
			tester.vrbomb = null;
		if(ismob(src.loc))
			boutput(src.loc, "<span class='alert'>[src] fades away!</span>")
		else
			src.visible_message("<span class='alert'>[src] fades away!</span>")
		..()

	toggle_valve()
		tester?.update_bomb_log("Valve Opened.")

		processing_items |= src
		..()
		return

	process()
		if(!tester || !src.valve_open)
			return

		if(update_counter >= updates_before_halt)
			tester.update_bomb_log("VR bomb monitor timeout.", 1)
			processing_items.Remove(src)
			return

		update_counter++

		var/tankslost = 2
		var/log_message = "[time2text(world.timeofday, "mm:ss")]:"
		var/tpressure = 0
		if(tank_one?.air_contents)
			tankslost--
			var/t1pressure = MIXTURE_PRESSURE(tank_one.air_contents)
			tpressure += round(t1pressure,0.1)

		if(tank_two?.air_contents)
			tankslost--
			var/t2pressure = MIXTURE_PRESSURE(tank_two.air_contents)
			tpressure += round(t2pressure,0.1)

		log_message += " Pressure:[tpressure] kPa"
		if(tankslost)
			log_message += " [tankslost == 2 ? "Both" : "One"] Tank(s) Lost!"

		tester.update_bomb_log(log_message)
		return


/obj/item/pressure_crystal
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "pressure_3"
	var/pressure = 0
	var/total_pressure = 0
	desc = "A pressure crystal. We're not really sure how it works, but it does. Place this near where the epicenter of a bomb would be, then detonate the bomb. Afterwards, place the crystal in a tester to determine the strength."
	name = "Pressure Crystal"
	ex_act(var/ex, var/inf, var/factor)
		pressure = factor || (4-clamp(ex, 1, 3))*2
		total_pressure += pressure
		pressure += (rand()-0.5) * (pressure/1000)//its not extremely accurate.
		icon_state = "pressure_[clamp(ex, 1, 3)]"
/obj/item/device/pressure_sensor
	name = "Pressure Sensor"
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "pressure_tester"
	desc = "Put in a pressure crystal to determine the strength of the explosion."
	var/obj/item/pressure_crystal/crystal
	attack_self(mob/user as mob)
		if(!crystal)
			boutput( user, "<b>There's no crystal in this here device!</b>")
		else
			if(crystal.pressure)
				boutput( user, "The reader reads <b>[crystal.pressure/25]</b> kilojoules." )
			else
				boutput( user, "The reader reads a firm 0. It guilts you into trying to read an unexploded pressure crystal, and seems to have succeeded. You feel ashamed for being so compelled by a device that has nothing more than a slot and a number display.")
	ex_act()
		qdel(src)
	attackby(obj/item/thing, mob/user)
		if(istype(thing, /obj/item/pressure_crystal))
			if(src.crystal)
				boutput( user, "You contemplate how to place the crystal in an occupied sensor, but can't manage to figure out how." )
			else
				src.crystal = thing
				thing.pixel_x = 0
				thing.pixel_y = 0
				boutput( user, "You insert the crystal." )
				overlays += thing
				user.drop_item()
				crystal.set_loc(src)
				wear_image.overlays += src.crystal
			return
		else if(thing.tool_flags & TOOL_PRYING && src.crystal)
			overlays = list()
			wear_image.overlays = list()
			boutput( user, "You pry out the crystal." )
			if(prob(src.crystal.total_pressure / 45))
				boutput( user, "<b class='alert'>It shatters!</b>" )
				qdel(src.crystal)
				return
			src.crystal.set_loc(user.loc)
			src.crystal = null
			return
		else return ..()
