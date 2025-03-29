TYPEINFO(/obj/item/device/transfer_valve)
	mats = 5

/obj/item/device/transfer_valve
	icon = 'icons/obj/items/assemblies.dmi' //TODO: as of 02/02/2020 missing sprite for regular air tank
	name = "tank transfer valve" // because that's what it is exadv1 and don't you dare change it
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks."
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
	///if true, allows adding cable to wear on back. TODO: refactor this out
	var/allow_wearable = TRUE

	w_class = W_CLASS_GIGANTIC /// HEH
	p_class = 3 /// H E H

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_BOMB_SIGNAL_START, PROC_REF(signal_start))
		RegisterSignal(src, COMSIG_ITEM_BOMB_SIGNAL_CANCEL, PROC_REF(signal_cancel))
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
		if (user.get_gang())
			boutput(user, SPAN_ALERT("You think working with explosives would bring a lot of much heat onto your gang to mess with this. But you do it anyway."))
		if(istype(item, /obj/item/tank) || istype(item, /obj/item/clothing/head/butt))
			src.attach_tank(user)
		else if(istype(item, /obj/item/device/radio/signaler) || istype(item, /obj/item/device/timer) || istype(item, /obj/item/device/infra) || istype(item, /obj/item/device/prox_sensor))
			if(attached_device)
				boutput(user, SPAN_ALERT("There is already an device attached to the valve, remove it first!"))
				return

			attached_device = item
			user.drop_item()
			item.set_loc(src)
			boutput(user, SPAN_NOTICE("You attach the [item] to the valve controls!"))
			logTheThing(LOG_BOMBING, user, "attaches the [item] to a TTV tank transfer valve.")
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

		else if(istype(item, /obj/item/cable_coil) && src.allow_wearable) //make loops for shoulder straps
			if(c_flags & ONBACK)
				boutput(user, SPAN_ALERT("The valve already has shoulder straps!"))
				return

			var/obj/item/cable_coil/coil = item
			if (coil.amount < 2)
				boutput(user, SPAN_ALERT("You do not have enough cable to produce two straps! (2 units required)"))
				return
			coil.use(2)

			c_flags |= ONBACK
			boutput(user, SPAN_NOTICE("You attach two loops of [item] to the transfer valve!"))
			UpdateIcon()

		else if ((c_flags & ONBACK) && issnippingtool(item))
			if(usr?.back && usr.back == src)
				boutput(usr, SPAN_ALERT("You can't detach the loops of wire while you're wearing [src]!"))
			else
				c_flags &= ~ONBACK
				var/turf/location = get_turf(src)
				var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(location)
				C.amount = 2
				boutput(usr, SPAN_NOTICE("You detach the loops of wire from [src]!"))
				UpdateIcon()

		return

	/**
	Attach the tank (or butt) the mob is currently holding to the transfer valve.

	* @param `mob/user` The mob holding the tank to attach.

	* @param `tank_preference` The tank slot to attach the tank to. If null, the tank will be attached to the first available slot.
	**/
	proc/attach_tank(mob/user, tank_preference=null)
		if (!user) return
		var/obj/item/I = user.equipped()
		if (istype(I, /obj/item/tank))
			var/obj/item/tank/myTank = I
			if (!myTank.compatible_with_TTV) return
		else if (istype(I, /obj/item/clothing/head/butt))
			; // butts allowed without additional checks
		else
			return
		// Handle UI tank attachment
		if (tank_preference == 1)
			// This check should always pass
			if (!src.tank_one)
				src.tank_one = I
		else if (tank_preference == 2)
			// As should this one
			if (!src.tank_two)
				src.tank_two = I
		// Handle attackby tank attachment (wherever fits)
		else if (!tank_preference && !src.tank_one)
			src.tank_one = I
		else if (!tank_preference && !src.tank_two)
			src.tank_two = I
		else
			// it did not fit, clearly. dummy.
			boutput(user, SPAN_NOTICE("\the [I] cannot fit on the [src]!"))
			return
		user.drop_item()
		I.set_loc(src)
		boutput(user, SPAN_NOTICE("You attach \the [I] to the transfer valve"))
		if(src.tank_one && src.tank_two)
			var/turf/T = get_turf(src)
			var/butt = istype(tank_one, /obj/item/clothing/head/butt) || istype(tank_two, /obj/item/clothing/head/butt)
			logTheThing(LOG_BOMBING, user, "made a TTV tank transfer valve [butt ? "butt" : "bomb"] at [log_loc(T)].")
			message_admins("[key_name(user)] made a TTV tank transfer valve [butt ? "butt" : "bomb"] at [log_loc(T)].")
		UpdateIcon()
		attacher = user
		if(user.back == src)
			user.update_clothing()

	attack_self(mob/user as mob)
		if (isghostdrone(user))
			return
		src.ui_interact(user)

#define TANK_PRESSURE(item_tank) (hasvar(item_tank, "air_contents")) ? MIXTURE_PRESSURE(item_tank.air_contents) : 0
	ui_data(mob/user)
		var/tank_one_data = (src.tank_one) ? list("name"=src.tank_one.name, "num"=1, "pressure"=TANK_PRESSURE(src.tank_one), \
											      "maxPressure"=TANK_FRAGMENT_PRESSURE) \
										   : list("name"=null, "num"=1, "pressure"=null, "maxPressure"=null)
		var/tank_two_data = (src.tank_two) ? list("name"=src.tank_two.name, "num"=2, "pressure"=TANK_PRESSURE(src.tank_two), \
											      "maxPressure"=TANK_FRAGMENT_PRESSURE) \
										   : list("name"=null, "num"=2, "pressure"=null, "maxPressure"=null)
		return list(
			"tank_one" = tank_one_data,
			"tank_two" = tank_two_data,
			"device" = "[src.attached_device]",
			"opened" = src.valve_open,
		)
#undef TANK_PRESSURE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "TTV", src.name)
			ui.open()

	ui_act(action, params)
		..()
		if (isghostdrone(usr) || usr.stat || usr.restrained())
			return
		switch(action)
			if ("add_item")
				if (params["tank"])
					src.attach_tank(usr, params["tank"])
				else
					src.Attackby(usr.equipped(), usr)
			if ("remove_tank_one")
				src.remove_tank(tank_one)
			if ("remove_tank_two")
				src.remove_tank(tank_two)
			if ("toggle_valve")
				var/openorclose = (src.valve_open) ? "closed" : "opened"
				var/turf/bombturf = get_turf(src)
				logTheThing(LOG_BOMBING, usr, "[openorclose] the valve on a TTV tank transfer valve at [log_loc(bombturf)].")
				if (src.tank_one && src.tank_two)
					message_admins("[key_name(usr)] [openorclose] the valve on a TTV tank transfer valve at [log_loc(bombturf)].")
					message_ghosts("<b>A tank transfer valve</b> has been [openorclose] at [log_loc(bombturf, ghostjump=TRUE)].")
				toggle_valve()
			if ("remove_device")
				src.attached_device.set_loc(get_turf(src))
				src.attached_device.master = null
				src.attached_device = null
				UpdateIcon()
			if ("interact_device")
				attached_device.AttackSelf(usr)
		src.AttackSelf(usr)
		src.add_fingerprint(usr)

	/**
	Remove a tank (or butt) from the transfer valve.

	 * @param `tank_or_butt` The tank or butt to remove.

	**/
	proc/remove_tank(tank_or_butt)
		var/obj/item/removed = tank_or_butt
		if (!istype(removed)) return // huh, must have been the wind
		boutput(usr, SPAN_NOTICE("You remove \the [removed] from [src]."))
		removed.set_loc(get_turf(src))
		removed = null
		UpdateIcon()
		if(src.equipped_in_slot)
			var/mob/wearer = src.loc
			wearer.update_clothing()

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

	update_wear_image(mob/living/carbon/human/H, override) // Doing above but for mutantraces if they have a special variant.
		src.wear_image.overlays = list()
		if(src.tank_one)
			src.wear_image.overlays += image(src.wear_image.icon, "[override ? "back-" : ""][tank_one_icon]1")
			src.wear_image.underlays += image(src.wear_image.icon, "[override ? "back-" : ""][tank_one_icon]_under")
		if(src.tank_two)
			src.wear_image.overlays += image(src.wear_image.icon, "[override ? "back-" : ""][tank_two_icon]2")
			src.wear_image.underlays += image(src.wear_image.icon, "[override ? "back-" : ""][tank_two_icon]_under")

		/*
		Exadv1: I know this isn't how it's going to work, but this was just to check
		it explodes properly when it gets a signal (and it does).
		*/
	proc
		toggle_valve()
			src.valve_open = !valve_open
			SPAWN(1 SECOND)
				signalled = FALSE
			if(valve_open)
				playsound(src, 'sound/effects/valve_creak.ogg', 50, TRUE)
			else
				playsound(src, 'sound/effects/valve_creak.ogg', 50, TRUE, pitch=-1)
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
					visible_message(SPAN_COMBAT("\The [src] farts [pick_string("descriptors.txt", "mopey")]"))
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
					boutput(L, SPAN_ALERT("You are sent flying!"))

					L.changeStatus("knockdown", stun_time SECONDS)
					while (throw_repeat > 0)
						throw_repeat--
						step_away(L,get_turf(src),throw_speed)

				ZERO_GASES(T.air_contents) //I could also make it vent the gas, I guess, but then it'd be off-limits to non-antagonists. Challenge mode: make a safe ttb?
				qdel(B)
				SPAWN(1 SECOND)
					UpdateIcon()
				return

			if(valve_open && (tank_one && tank_two) && tank_one.air_contents && tank_two.air_contents)
				var/turf/bombturf = get_turf(src)
				var/area/A = get_area(bombturf)
				if(!A.dont_log_combat)
					logTheThing(LOG_BOMBING, null, "TTV tank transfer valve bomb opened in [log_loc(bombturf)]. Last touched by [src.fingerprintslast]")
					message_admins("TTV tank transfer valve bomb valve opened in [log_loc(bombturf)]. Last touched by [src.fingerprintslast]")

				var/datum/gas_mixture/temp

				temp = tank_one.air_contents.remove_ratio(1)

				tank_two.air_contents.volume = tank_one.air_contents.volume
				tank_two.air_contents.merge(temp)

				var/transfer_ratio = tank_one.air_contents.volume / (tank_one.air_contents.volume + tank_two.air_contents.volume)
				temp = tank_two.air_contents.remove_ratio(transfer_ratio)
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

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] drops [src], takes a short run up and kicks the valve as hard as [he_or_she(user)] can, knocking it [valve_open ? "closed" : "open"]!</b>"))
		user.u_equip(src)
		src.set_loc(user.loc)
		toggle_valve()
		SPAWN(2 SECONDS)
			if (user)
				user.suiciding = 0
				if(isalive(user) && src && GET_DIST(user,src) <= 7)
					user.visible_message(SPAN_ALERT("[user] stares at the [src.name], a confused expression on [his_or_her(user)] face.")) //It didn't blow up!
		return 1

ADMIN_INTERACT_PROCS(/obj/item/device/transfer_valve, proc/admin_command_vacuum_tanks)
///vacuum out all attached tanks - for admin purposes, to defuse someone's 'self-defense TTV'
/obj/item/device/transfer_valve/proc/admin_command_vacuum_tanks()
	set name = "Vacuum tanks"
	for(var/obj/item/tank/T in src)
		if(T.air_contents)
			ZERO_GASES(T.air_contents)

TYPEINFO(/obj/item/device/transfer_valve/briefcase)
	mats = 8

/obj/item/device/transfer_valve/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	var/obj/item/storage/briefcase/B = null
	allow_wearable = FALSE

	update_icon()

		return

/// How many atmos ticks we are willing to count before giving up
#define UPDATES_BEFORE_TIMEOUT 20
/obj/item/device/transfer_valve/vr
	name = "VR explosive"
	var/obj/machinery/networked/storage/bomb_tester/tester = null
	/// How many atmos ticks we have listened to thus far
	var/update_counter = 0

	attack_hand(mob/user)
		src.ui_interact()

	disposing()
		processing_items.Remove(src)
		if(tester)
			tester.update_bomb_log("VR Bomb deleted.", 1)
			tester.vrbomb = null;
		if(ismob(src.loc))
			boutput(src.loc, SPAN_ALERT("[src] fades away!"))
		else
			src.visible_message(SPAN_ALERT("[src] fades away!"))
		..()

	toggle_valve()
		tester?.update_bomb_log("Valve Opened.")

		processing_items |= src
		..()
		return

	process()
		if(!tester || !tester.vrbomb || !src.valve_open)
			return

		if(update_counter >= UPDATES_BEFORE_TIMEOUT)
			tester.update_bomb_log("VR bomb monitor timeout.", 1)
			processing_items.Remove(src)
			return

		update_counter++

		tester.update_bomb_log("[time2text(world.timeofday, "mm:ss")]:")
		var/tank1_pressure = (hasvar(src.tank_one, "air_contents")) ?  MIXTURE_PRESSURE(src.tank_one.air_contents) : 0
		var/tank2_pressure = (hasvar(src.tank_two, "air_contents")) ?  MIXTURE_PRESSURE(src.tank_two.air_contents) : 0

		tester.update_bomb_log("Tank 1 Pressure:[tank1_pressure] kPa")
		tester.update_bomb_log("Tank 2 Pressure:[tank2_pressure] kPa")

		// This doesn't really happen as both tanks are usually bound to have the same reaction process due to same volume/contents/temp/etc
		// so disposing() gets called first
		if(!tank1_pressure)
			tester.update_bomb_log("Tank one has no pressure or has been destroyed!")
		if (!tank2_pressure)
			tester.update_bomb_log("Tank two has no pressure or has been destroyed!")

		return
#undef UPDATES_BEFORE_TIMEOUT

/obj/item/pressure_crystal
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "pressure_none"
	w_class = W_CLASS_SMALL
	var/pressure = 0 // used to calculate credit value, in shippingmarket.dm proc/appraise_value
	var/last_explode_time = 0
	var/static/explosion_id = 0
	var/broken = FALSE
	name = "pressure crystal"
	desc = "A mysterious gadget that measures the power of bombs detonated over it. \
		Certain measurements within the crystal can be very valuable on the shipping market."
	HELP_MESSAGE_OVERRIDE("Place this where the epicenter of a bomb would be, then detonate the bomb. \
		Afterwards, place the crystal in a pressure sensor to determine the explosion power.<br>\
		Spent pressure crystals can be sold to researchers on the shipping market, for a credit sum depending on the measured power.")

	attackby(obj/item/thing, mob/user)
		if (istype(thing, /obj/item/device/pressure_sensor))
			thing.Attackby(src, user)
		else ..()

	get_desc()
		. = ..()
		if (src.broken)
			. += "<br>[SPAN_ALERT("This crystal has been broken by an explosion too powerful for it to handle, it is worthless.")]"
		else if (src.pressure)
			. += "<br>[SPAN_NOTICE("This crystal has already measured something. Another explosion will overwrite the previous results.")]"

	ex_act(severity, fingerprints, power, datum/explosion/explosion)
		if(src.broken)
			return

		var/exp_power = (power / 2) ** 2 || (4-clamp(severity, 1, 3))*2

		logTheThing(LOG_BOMBING, src, "is hit by an explosion of power [exp_power] calculated from [power ? "power [power]" : "severity [severity]"]")

		if (src.last_explode_time < world.time)
			src.pressure = exp_power
		else // sum the power of multiple explosions at roughly the same instant, but diminishingly
			// preferring stronger explosions, too
			src.pressure = max(src.pressure, exp_power) + sqrt(min(src.pressure, exp_power))
		var/icon_num
		if (exp_power < 10)
			icon_num = 3
		else if (exp_power < 50)
			icon_num = 2
		else
			icon_num = 1
		src.icon_state = "pressure_[icon_num]"
		src.last_explode_time = world.time
		src.explosion_id = exp_power * world.time

		if (explosion.power >= 10000 || exp_power >= 10000) //sadly, the hemera nuke exists and so we must put a limit here
			src.broken = TRUE
			src.icon_state = "pressure_broken"

/obj/item/device/pressure_sensor
	name = "pressure sensor"
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "pressure_tester"
	desc = "Put in a pressure crystal to determine the strength of the explosion."
	w_class = W_CLASS_SMALL
	c_flags = ONBELT

	var/obj/item/pressure_crystal/crystal

	examine()
		. = ..()
		if (src.crystal?.pressure)
			. += "<br>[SPAN_NOTICE("The display reads: <b>[src.crystal.pressure] kiloblast.</b>")]"

	attack_self(mob/user as mob)
		if(!src.crystal)
			boutput( user, SPAN_ALERT("There's no crystal in this here device!"))
			return
		if(src.crystal.pressure)
			boutput( user, SPAN_NOTICE("The display reads: <b>[src.crystal.pressure] kiloblast.</b>") )
		else
			boutput( user, "<span class='notice'>The display reads a firm 0. It guilts you into trying to read an unexploded pressure crystal, \
							and seems to have succeeded. You feel ashamed for being so compelled by a device that \
							has nothing more than a slot and a number display.</span>")

	ex_act(var/ex, var/inf, var/factor, var/datum/explosion/explosion)
		if (src.crystal)
			src.crystal.ex_act(ex, inf, factor, explosion)
			src.crystal.set_loc(src.loc)
		qdel(src)

	attackby(obj/item/thing, mob/user)
		if (!istype(thing, /obj/item/pressure_crystal))
			return ..()
		if (src.insert_crystal(user, thing))
			user.visible_message("[user] inserts [thing] into [src].",
								SPAN_NOTICE("You insert the crystal into [src]."))

	mouse_drop(atom/over_object, src_location, over_location)
		if (!src.crystal)
			. = ..()
			return

		if(BOUNDS_DIST(src_location, usr) > 0 || BOUNDS_DIST(src_location, over_location) > 0)
			return
		if (src.remove_crystal(usr, over_location))
			usr.visible_message("[usr] removes the crystal from [src].",
								SPAN_NOTICE("You pull the crystal out of [src]."))

	MouseDrop_T(atom/movable/thing, mob/user)
		. = ..()
		if (!istype(thing, /obj/item/pressure_crystal))
			return
		if (src.insert_crystal(user, thing))
			user.visible_message("[user] drops [thing] into [src].",
								SPAN_NOTICE("You drop the crystal into [src]."))

	attack_hand(mob/user)
		if (src.loc != user || !user.find_in_hand(src))
			..()
		else if (src.crystal && src.remove_crystal(user))
			boutput(user, SPAN_NOTICE("You extract the crystal from [src].") )
		else ..() // something about having two of these feels wrong

	update_icon()
		if (src.crystal)
			var/image/pc = image(src.crystal.icon, src.crystal.icon_state)
			src.UpdateOverlays(pc, "sensor")
		else
			src.UpdateOverlays(null, "sensor")

	proc/insert_crystal(mob/user, obj/item/pressure_crystal/pc)
		if (!istype(pc, /obj/item/pressure_crystal))
			return FALSE
		if (src.crystal)
			boutput(user, "<span class='alert'>You contemplate how to place the crystal in an occupied sensor, \
							but can't manage to figure out how.</span>" )
			return FALSE
		user.drop_item(pc)
		pc.set_loc(src)
		src.crystal = pc
		src.UpdateIcon()
		return TRUE

	proc/remove_crystal(mob/user, turf/spot)
		if (!src.crystal)
			boutput(user, SPAN_ALERT("There's no crystal in this here device!"))
			return FALSE
		if (spot)
			src.crystal.set_loc(spot)
		else
			user.put_in_hand_or_drop(src.crystal)
		src.crystal = null
		src.UpdateIcon()
		return TRUE
