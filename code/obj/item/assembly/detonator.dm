/obj/item/assembly/detonator
	desc = "A failsafe timer, wired in an incomprehensible way to a detonator assembly"
	name = "Detonator Assembly"
	icon_state = "multitool-igniter"
	var/obj/item/device/multitool/part_mt = null
	var/obj/item/device/igniter/part_ig = null
	var/obj/item/tank/plasma/part_t = null
	var/obj/item/device/timer/part_fs = null
	var/obj/item/device/trigger = null

	var/obj/machinery/portable_atmospherics/canister/attachedTo = null
	var/list/WireColors = list()
	var/list/obj/item/attachments = list()
	var/safety = 1
	var/defused = 0
	var/grant = 1
	var/shocked = 0
	var/leaks = 0
	var/det_state = 0
	var/list/WireNames = list()
	var/list/WireFunctions = list()
	var/list/WireStatus = list()
	var/dfcodeSet
	var/dfcode
	var/dfcodeTries = 3 //How many code attempts before *boom*
	var/mob/builtBy = null

	flags = TABLEPASS | CONDUCT
	force = 1
	throwforce = 2
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL

/obj/item/assembly/detonator/New()
	..()
	var/list/WireFuncs
	WireColors = list("Alabama Crimson", "Antique White", "Burnt Umber", "China Rose", "Dodger Blue", "Field Drab", "Harvest Gold", "Jonquil", "Midori", "Neon Carrot", "Oxford Blue", "Periwinkle", "Purple Pizzazz", "Stil De Grain Yellow", "Toolbox Purple", "Urobilin", "Vivid Tangerine", "Yale Blue")
	WireFuncs = list("detonate", "defuse", "safety", "losetime", "mobility", "leak")
	var/i
	for (i=1, i<=6, i++)
		var/N = pick(WireColors)
		WireColors -= N
		var/F = pick(WireFuncs)
		WireNames += N + " wire"
		WireFunctions += F
		WireFuncs -= F
	for (i=1, i<=9, i++)
		WireStatus += 1

/obj/item/assembly/detonator/proc/setDetState(var/newstate)
	switch (newstate)
		if (0)
			src.desc = "A multitool wired to the activation switch of an igniter, with a slot that seems to be able to hold a rectangular tank in place."
			src.name = "Multitool/Igniter Assembly"
			src.icon_state = "multitool-igniter"
			src.det_state = 0

		if (1)
			src.desc = "An igniter and a multitool, with the plasma tank inserted into a slot. Most of the wiring is missing. <br>The plasma tank is not secured to the assembly."
			src.name = "Multitool/Igniter/Tank Assembly"
			src.icon_state = "m-i-plasma"
			src.det_state = 1

		if (2)
			src.desc = "An igniter and a multitool, with the plasma tank inserted into a slot. Most of the wiring is missing. <br>The plasma tank is firmly secured to the assembly."
			src.name = "Multitool/Igniter/Tank Assembly"
			src.icon_state = "m-i-plasma"
			src.det_state = 2

		if (3)
			src.desc = "An igniter wired to critically weaken a plasma tank when signalled by the multitool. The failsafe wires are unattached."
			src.name = "Unfinished Detonator Assembly"
			src.icon_state = "m-i-p-wire"
			src.det_state = 3

		if (4)
			src.desc = "A failsafe timer, wired in an incomprehensible way to a detonator assembly"
			src.name = "Detonator Assembly"
			src.icon_state = "m-i-p-w-timer"
			src.det_state = 4

/obj/item/assembly/detonator/attackby(obj/item/W, mob/user)
	switch (src.det_state)
		if (0)
			if (istype(W, /obj/item/tank/plasma))
				src.setDetState(1)
				user.u_equip(W)
				W.set_loc(src)
				W.master = src
				W.layer = initial(src.layer)
				src.part_t = W
				src.add_fingerprint(user)
				user.show_message(SPAN_NOTICE("You insert the [W.name] into the slot."))
			else if (issnippingtool(W))
				src.part_ig.set_loc(user.loc)
				src.part_mt.set_loc(user.loc)
				src.part_ig.master = null
				src.part_mt.master = null
				src.part_ig = null
				src.part_mt = null
				user.u_equip(src)
				qdel(src)
				user.show_message(SPAN_NOTICE("You sever the connection between the multitool and the igniter. The assembly falls apart."))
			else
				user.show_message(SPAN_ALERT("The [W.name] doesn't seem to fit into the slot!"))

		if (1)
			if (istype(W, /obj/item/cable_coil))
				user.show_message(SPAN_ALERT("The plasma tank must be firmly secured to the assembly first."))
			else if (ispryingtool(W))
				src.setDetState(0)
				src.part_t.set_loc(user.loc)
				src.part_t.master = null
				src.part_t = null
				user.show_message(SPAN_NOTICE("You pry the plasma tank out of the assembly."))
			else if (isscrewingtool(W))
				src.setDetState(2)
				user.show_message(SPAN_NOTICE("You secure the plasma tank to the assembly."))

		if (2)
			if (istype(W, /obj/item/cable_coil))
				var/obj/item/cable_coil/C = W
				if (C.amount >= 6)
					C.use(6)
					src.setDetState(3)
					src.add_fingerprint(user)
					user.show_message(SPAN_NOTICE("You add the wiring to the assembly."))
				else
					user.show_message(SPAN_ALERT("This cable coil isn't long enough!"))
			else if (ispryingtool(W))
				user.show_message(SPAN_ALERT("The plasma tank is firmly secured to the assembly and won't budge."))
			else if (isscrewingtool(W))
				src.setDetState(1)
				user.show_message(SPAN_NOTICE("You unsecure the plasma tank from the assembly."))

		if (3)
			if (istype(W, /obj/item/device/timer))
				src.setDetState(4)
				user.u_equip(W)
				W.set_loc(src)
				W.master = src
				W.layer = initial(src.layer)
				src.part_fs = W
				src.part_fs.time = 90 SECONDS //Minimum det time
				src.add_fingerprint(user)
				user.show_message(SPAN_NOTICE("You wire the timer failsafe to the assembly, disabling its external controls."))
			else if (issnippingtool(W))
				src.setDetState(2)
				var/obj/item/cable_coil/C = new /obj/item/cable_coil(user, 6)
				C.set_loc(user.loc)
				user.show_message(SPAN_NOTICE("You cut the wiring on the assembly."))
		if (4)
			if (issnippingtool(W))
				src.setDetState(3)
				src.part_fs.set_loc(user.loc)
				src.part_fs.master = null
				src.part_fs = null
				if (src.trigger)
					src.trigger.set_loc(user.loc)
					src.trigger.master = null
					src.trigger = null
					user.show_message(SPAN_ALERT("The triggering device falls off the assembly."))
				for (var/obj/item/a in src.attachments)
					a.set_loc(user.loc)
					a.master = null
					a.layer = initial(a.layer)
					src.clear_attachment(a)
					user.show_message(SPAN_ALERT("The [a] falls off the assembly."))
				src.attachments.Cut()
				user.show_message(SPAN_NOTICE("You disconnect the timer from the assembly, and reenable its external controls."))
			if (isscrewingtool(W))
				if (!src.trigger && !length(src.attachments))
					user.show_message(SPAN_ALERT("You cannot remove any attachments, as there are none attached."))
					return
				var/list/options = list(src.trigger)
				options += src.attachments
				options += "cancel"
				var/target = input("Which device do you want to remove?", "Device to remove", "cancel") in options
				if (target == src.trigger)
					src.trigger.set_loc(user.loc)
					src.trigger.master = null
					src.trigger = null
					user.show_message(SPAN_NOTICE("You remove the triggering device from the assembly."))
				else if (target == "cancel")
					return
				else
					var/obj/item/T = target
					T.set_loc(user.loc)
					T.master = null
					T.detonator_act("detach", src)
					src.clear_attachment(target)
					src.attachments.Remove(target)
					setDescription()
					user.show_message(SPAN_NOTICE("You remove the [target] from the assembly."))
				setDescription()
			else if (istype(W, /obj/item/device/radio/signaler))
				if (src.trigger)
					user.show_message(SPAN_ALERT("There is a trigger already screwed onto the assembly."))
				else
					W.set_loc(src)
					W.master = src
					user.u_equip(W)
					src.trigger = W
					user.show_message(SPAN_NOTICE("You attach the [W.name] to the trigger slot."))
					setDescription()
			else if (istype(W, /obj/item/paper))
				W.set_loc(src)
				W.master = src
				user.u_equip(W)
				src.attachments += W
				user.show_message(SPAN_NOTICE("You stick the note onto the detonator assembly."))
			else if (W.is_detonator_attachment())
				if (length(src.attachments) < 3)
					W.set_loc(src)
					W.master = src
					user.u_equip(W)
					src.attachments += W
					W.detonator_act("attach", src)

					var/N = pick(src.WireColors)
					src.WireColors -= N
					N += " wire"
					var/pos = rand(0, src.WireNames.len)
					src.WireNames.Insert(pos, N)
					src.WireFunctions.Insert(pos, W)

					user.show_message(SPAN_NOTICE("You attach the [W.name] to an attachment slot."))
					setDescription()
				else
					user.show_message(SPAN_ALERT("There are no more free attachment slots on the device!"))
					setDescription()

/obj/item/assembly/detonator/proc/clear_attachment(var/obj/item/T)
	var/pos = src.WireFunctions.Find(T)
	var/N = copytext(src.WireNames[pos], 1, -5)
	src.WireColors += N
	src.WireNames.Cut(pos, pos+1)
	src.WireFunctions.Cut(pos, pos+1)

/obj/item/assembly/detonator/proc/detonate()
	if (!src.attachedTo)
		return

	if(ON_COOLDOWN(attachedTo, "canbomb sanity check", 10 SECONDS))
		return

	if(force_dud)
		var/turf/T = get_turf(src)
		message_admins("A canister bomb would have detonated at at [T.loc.name] ([log_loc(T)]) but was forced to dud!")
		return

	src.attachedTo.anchored = UNANCHORED
	src.attachedTo.remove_simple_light("canister")

	if (src.defused)
		src.attachedTo.visible_message(SPAN_ALERT("<b>The cut detonation wire emits a spark. The detonator signal never reached the detonator unit.</b>"))
		return
	if (MIXTURE_PRESSURE(src.part_t.air_contents) < 400 || src.part_t.air_contents.toxins < (4*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C))
		src.attachedTo.visible_message(SPAN_ALERT("<b>A sparking noise is heard as the igniter goes off. The plasma tank fails to explode, merely burning the circuits of the detonator.</b>"))
		src.attachedTo.det = null
		src.attachedTo.overlay_state = null
		qdel(src)
		return
	src.attachedTo.visible_message(SPAN_ALERT("<b>A sparking noise is heard as the igniter goes off. The plasma tank blows, creating a microexplosion and rupturing the canister.</b>"))
	if (MIXTURE_PRESSURE(attachedTo.air_contents) < 7000)
		src.attachedTo.visible_message(SPAN_ALERT("<b>The ruptured canister, due to a serious lack of pressure, fails to explode into shreds and leaks its contents into the air.</b>"))
		src.attachedTo.health = 0
		src.attachedTo.healthcheck()
		src.attachedTo.det = null
		src.attachedTo.overlay_state = null
		qdel(src)
		return
	if (attachedTo.air_contents.temperature < 100000)
		src.attachedTo.visible_message(SPAN_ALERT("<b>The ruptured canister shatters from the pressure, but its temperature isn't high enough to create an explosion. Its contents leak into the air.</b>"))
		src.attachedTo.health = 0
		src.attachedTo.healthcheck()
		src.attachedTo.det = null
		src.attachedTo.overlay_state = null
		qdel(src)
		return

	var/turf/epicenter = get_turf(loc)
	logTheThing(LOG_BOMBING, null, "A canister bomb detonates at [epicenter.loc.name] ([log_loc(epicenter)])")
	message_admins("A canister bomb detonates at [epicenter.loc.name] ([log_loc(epicenter)])")
	src.attachedTo.visible_message(SPAN_ALERT("<b>The ruptured canister shatters from the pressure, and the hot gas ignites.</b>"))

	var/power = min(850 * (MIXTURE_PRESSURE(attachedTo.air_contents) + attachedTo.air_contents.temperature - 107000) / 233196469.0 + 200, 7000) //the second arg is the max explosion power
	//if (power == 150000) //they reached the cap SOMEHOW? well dang they deserve a medal
		//src.builtBy.unlock_medal("", 1) //WIRE TODO: make new medal for this
	explosion_new(attachedTo, epicenter, power)

/obj/item/assembly/detonator/proc/setDescription()
	src.desc = "A failsafe timer, wired in an incomprehensible way to a detonator assembly"

	if (src.trigger)
		src.desc += "<br>[SPAN_NOTICE("There is \an [src.trigger.name] as a detonation trigger.")]"
	for (var/obj/item/a in src.attachments)
		src.desc += "<br>[SPAN_NOTICE("There is \an [a] wired onto the assembly as an attachment.")]"

/obj/item/assembly/detonator/proc/failsafe_engage()
	if (src.part_fs.timing)
		return
	if (!src.attachedTo || !src.master) // if the detonator assembly isn't wired to anything, then no need to prime it
		return
	if (src.attachedTo.destroyed)
		return
	src.safety = 0
	src.part_fs.timing = 1
	src.part_fs.c_state(1)
	processing_items |= src
	processing_items |= src.part_fs
	src.dispatch_event("prime")

	command_alert("A canister bomb is primed in [get_area(src)] at coordinates (<b>X</b>: [src.master.x], <b>Y</b>: [src.master.y], <b>Z</b>: [src.master.z])! It is set to go off in [src.part_fs.time / 10] seconds.")
	playsound_global(world, 'sound/machines/siren_generalquarters_quiet.ogg', 100)
	logTheThing(LOG_BOMBING, usr, "primes a canister bomb at [get_area(src.master)] ([log_loc(src.master)])")
	message_admins("[key_name(usr)] primes a canister bomb at [get_area(src.master)] ([log_loc(src.master)])")
	src.attachedTo.visible_message("<B><font color=#FF0000>The detonator's priming process initiates. Its timer shows [src.part_fs.time / 10] seconds.</font></B>")

// Legacy.
/obj/item/assembly/detonator/proc/leaking()
	src.dispatch_event("leak")

/obj/item/assembly/detonator/process()
	src.dispatch_event("process")

/obj/item/assembly/detonator/proc/dispatch_event(event)
	for (var/obj/item/a in src.attachments)
		a.detonator_act(event, src)

/obj/item/assembly/detonator/receive_signal(datum/signal/signal)
	if (signal)
		if (signal.source == src.part_fs)
			src.attachedTo.visible_message("<B><font color=#FF0000>The failsafe timer's ticks more rapidly with every passing moment, then suddenly goes quiet.</font></B>")
			src.detonate()
		else
			failsafe_engage()

/obj/item/proc/is_detonator_attachment()
	return 0

// Possible events: attach, detach, leak, process, prime, detonate, cut, pulse
/obj/item/proc/detonator_act(event, var/obj/item/assembly/detonator/det)
	return


//For testing and I'm too lazy to hand-assemble these whenever I need one =I
/obj/item/assembly/detonator/finished

	New()
		..()
		var/obj/item/tank/plasma/ptank = new /obj/item/tank/plasma(src)
		ptank.air_contents.toxins = 30
		ptank.master = src
		src.part_t = ptank

		var/obj/item/device/timer/timer = new /obj/item/device/timer(src)
		timer.master = src
		src.part_fs = timer
		src.part_fs.time = 90 SECONDS //Minimum det time

		setDetState(4)
