/// The holder of the canbomb assembly which we use to handle the wires and functions of the canbomb.
/// Maybe once we have some kind of wire hacking component we could do away with this and merge that whole shitshow into obj/item/assembly

/obj/item/canbomb_detonator
	desc = "A failsafe timer, wired in an incomprehensible way to a detonator assembly"
	name = "Detonator Assembly"
	icon_state = "multitool-igniter"
	var/obj/item/assembly/complete/part_assembly = null
	var/list/initial_wire_functions = null //! a list with the in New() addec wires of the canbomb
	var/obj/machinery/portable_atmospherics/canister/attachedTo = null
	var/list/obj/item/attachments = null
	var/safety = 1
	var/defused = 0
	var/grant = 1
	var/shocked = 0
	var/leaks = 0
	var/det_state = 0
	var/force_dud = 0
	var/list/WireNames = null
	var/list/WireFunctions = null
	var/list/WireStatus = null
	var/mob/builtBy = null

	flags = TABLEPASS | CONDUCT
	force = 1
	throwforce = 2
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL

/obj/item/canbomb_detonator/New(var/new_location, var/obj/item/assembly/complete/new_assembly)
	..()
	src.initial_wire_functions = list("detonate", "defuse", "safety", "losetime", "mobility", "leak")
	src.attachments = list()
	src.WireNames = list()
	src.WireFunctions = list()
	src.WireStatus = list()
	var/potential_wire_colors = list("Alabama Crimson", "Antique White", "Burnt Umber", "China Rose", "Dodger Blue", "Field Drab", "Harvest Gold", "Jonquil", "Midori", "Neon Carrot", "Oxford Blue", "Periwinkle", "Purple Pizzazz", "Stil De Grain Yellow", "Toolbox Purple", "Urobilin", "Vivid Tangerine", "Yale Blue")
	new_assembly.override_upstream = TRUE //the timer sends the signal to the assembly, the assembly sends the signal to the detonator
	new_assembly.set_trigger_time(90 SECONDS)
	new_assembly.master = src
	new_assembly.set_loc(src)
	for(var/obj/item/checked_item in new_assembly.additional_components)
		src.attachments += checked_item
		checked_item.detonator_act("attach", src)
	// now, for each wire, we shuffle them around and set a colour
	while(length(src.initial_wire_functions) > 0)
		var/wire_picked_colour = pick(potential_wire_colors)
		potential_wire_colors -= wire_picked_colour
		var/wire_picked_function = pick(initial_wire_functions)
		src.WireNames += wire_picked_colour + " wire"
		src.WireFunctions += wire_picked_function
		src.initial_wire_functions -= wire_picked_function
		WireStatus += TRUE

/obj/item/canbomb_detonator/disposing()
	qdel(src.part_assembly)
	src.part_assembly = null
	src.builtBy = null
	src.attachedTo = null
	src.master = null
	. = ..()

/obj/item/canbomb_detonator/proc/disassemble()
	src.part_assembly.set_loc(get_turf(src))
	src.part_assembly.override_upstream = FALSE
	src.part_assembly.master = null
	src.part_assembly = null
	qdel(src)


/obj/item/canbomb_detonator/proc/detonate()
	if (!src.attachedTo)
		return

	if(ON_COOLDOWN(attachedTo, "canbomb sanity check", 10 SECONDS))
		return

	if(src.force_dud)
		var/turf/T = get_turf(src)
		message_admins("A canister bomb would have detonated at at [T.loc.name] ([log_loc(T)]) but was forced to dud!")
		return

	src.attachedTo.anchored = UNANCHORED
	src.attachedTo.remove_simple_light("canister")

	if (src.defused)
		src.attachedTo.visible_message(SPAN_ALERT("<b>The cut detonation wire emits a spark. The detonator signal never reached the detonator unit.</b>"))
		return
	var/obj/item/tank/plasma_tank = src.part_assembly.target
	if (MIXTURE_PRESSURE(plasma_tank.air_contents) < 400 || plasma_tank.air_contents.toxins < (4*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C))
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

/obj/item/canbomb_detonator/proc/get_timing()
	if(SEND_SIGNAL(src.part_assembly, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE) == ASSEMBLY_TRIGGER_ARMED)
		return TRUE
	else
		return FALSE

/obj/item/canbomb_detonator/proc/get_signaler()
	for(var/obj/item/device/radio/signaler/found_trigger in src.part_assembly.additional_components)
		return found_trigger

/obj/item/canbomb_detonator/proc/get_time_left()
	return SEND_SIGNAL(src.part_assembly, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_TIME_LEFT)

/obj/item/canbomb_detonator/proc/failsafe_engage()
	if (!src.attachedTo || !src.master) // if the detonator assembly isn't wired to anything, then no need to prime it
		return
	if (src.attachedTo.destroyed)
		return
	src.safety = 0
	if (SEND_SIGNAL(src.part_assembly.trigger, COMSIG_ITEM_ASSEMBLY_ACTIVATION, part_assembly))
		processing_items |= src
		src.dispatch_event("prime")
		command_alert("A canister bomb is primed in [get_area(src)] at coordinates (<b>X</b>: [src.master.x], <b>Y</b>: [src.master.y], <b>Z</b>: [src.master.z])! It is set to go off in [src.get_time_left() / 10] seconds.")
		playsound_global(world, 'sound/machines/siren_generalquarters_quiet.ogg', 100)
		logTheThing(LOG_BOMBING, usr, "primes a canister bomb at [get_area(src.master)] ([log_loc(src.master)])")
		message_admins("[key_name(usr)] primes a canister bomb at [get_area(src.master)] ([log_loc(src.master)])")
		src.attachedTo.visible_message("<B><font color=#FF0000>The detonator's priming process initiates. Its timer shows [src.get_time_left() / 10] seconds.</font></B>")

// Legacy.
/obj/item/canbomb_detonator/proc/leaking()
	src.dispatch_event("leak")

/obj/item/canbomb_detonator/process()
	src.dispatch_event("process")

/obj/item/canbomb_detonator/proc/dispatch_event(event)
	for (var/obj/item/a in src.attachments)
		a.detonator_act(event, src)

/obj/item/canbomb_detonator/receive_signal(datum/signal/signal)
	if (signal)
		if (signal.source == src.part_assembly.trigger)
			src.attachedTo.visible_message("<B><font color=#FF0000>The failsafe timer's ticks more rapidly with every passing moment, then suddenly goes quiet.</font></B>")
			src.detonate()
		else
			failsafe_engage()

/obj/item/proc/is_detonator_attachment()
	return 0

// Possible events: attach, detach, leak, process, prime, detonate, cut, pulse
/obj/item/proc/detonator_act(event, var/obj/item/canbomb_detonator/det)
	return


//For testing and I'm too lazy to hand-assemble these whenever I need one =I
///obj/item/canbomb_detonator/finished

//	New()
//		..()
//		var/obj/item/tank/plasma/ptank = new /obj/item/tank/plasma(src)
//		ptank.air_contents.toxins = 30
//		ptank.master = src
//		src.part_t = ptank

//		var/obj/item/device/timer/timer = new /obj/item/device/timer(src)
//		timer.master = src
//		src.part_fs = timer
//		src.part_fs.time = 90 SECONDS //Minimum det time

//		setDetState(4)
