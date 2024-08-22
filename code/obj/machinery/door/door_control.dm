
#define MODE_TOGGLE_OPEN 1 //! Open/close doors on button press
#define MODE_TOGGLE_BOLTS 2 //! Bolt/unbolt doors on button press

var/global/list/reserved_machinery_control_ids = list() //! All the door IDs from concrete types of /obj/machinery/door_control to forbid setting existing ones weirdly

/// Machinery types to check. These are the bits in the list which will have IDs
#define VALID_MACHINERY_TYPES list(/obj/machinery/door/airlock, /obj/machinery/door/poddoor, /obj/machinery/door_control, /obj/machinery/conveyor)

// This list is generated when someone starts trying to name a button ID, as this is predicted to be used so infrequently that it might never be worth loading at all
// If it was to go pre-round it would need to be after everything is setup to for_by_tcl all the buttons
/// Generate all the reserved IDs
proc/generate_reserved_machinery_control_ids()
	// Every ID for a button and every machine that may have an id to recieve
	var/ids_to_blacklist = machine_registry[MACHINES_CONVEYORS] + by_cat[TR_CAT_DOOR_BUTTONS] + by_type[/obj/machinery/door]
	for (var/machinery_object as anything in ids_to_blacklist)
		var/id = null
		if (istypes(machinery_object, VALID_MACHINERY_TYPES))
			// The : syntax would be appropriate here but that's a different kind of code crime(tm)
			// so instead we just use one of the various types which all implement ID differently (WAA)
			// but uhh TODO: reimplement the ID system to make some semblance of sense
			var/obj/machinery/door_control/some_valid_machinery = machinery_object
			id = some_valid_machinery.id
		if (isnull(id))
			continue
		// Kind of expensive but otherwise every directional generates its id again
		var/is_duplicate = FALSE
		for (var/reserved_id in reserved_machinery_control_ids)
			if (reserved_id == id)
				is_duplicate = TRUE
				break
		if (is_duplicate)
			continue
		reserved_machinery_control_ids += id

#undef VALID_MACHINERY_TYPES

/// Check if a given ID is on the door ID blacklist, returns TRUE if it is and FALSE otherwise.
proc/id_on_reserved_list(id)
	for (var/blacklisted_id in reserved_machinery_control_ids)
		if (blacklisted_id == id)
			return TRUE
	return FALSE

TYPEINFO(/obj/machinery/door_control)
	mats = list("metal_dense" = 4,
				"crystal" = 2,
				"conductive" = 6
				)

ADMIN_INTERACT_PROCS(/obj/machinery/door_control, proc/toggle)
/obj/machinery/door_control
	name = "Remote Door Control"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control switch for a door."
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE
	deconstruct_flags = DECON_WIRECUTTERS | DECON_CROWBAR | DECON_MULTITOOL
	object_flags = CAN_REPROGRAM_ACCESS
	req_access = list(access_change_ids) // This in particular is being used to determine if the access pro should be allowed to do stuff
	// Icon state variables
	// following 3 variables should be adjusted in a subtype with different icons
	var/unpressed_icon = "doorctrl0"
	var/pressed_icon = "doorctrl1"
	var/unpowered_icon = "doorctrl-p"

	// Welcome text variables
	var/image/chat_maptext/welcome_text //! for the speak proc, relays the message to speak.
	var/welcome_text_alpha = 140 //! alpha value for speak proc
	var/welcome_text_color = "#FF0100" //! colour value for speak proc

	// Door button specific variables
	var/id = null //! Match to a door to have it be controlled.
	var/original_id = null //! Remembers the ID this was originally assigned, so it can be assigned back if needed.
	var/tamper_lock = TRUE //! Forbids deconstruction/tampering with ID. Removed (set false) with an access-pro or when constructed from frame.
	var/panel_open = FALSE //! Whether or not the panel is open on the button. Allows changing the ID when open
	var/timer = 0 SECONDS //! If this is greater than 0, enforces an artificial delay on toggling machinery
	var/cooldown = 0 SECONDS //! If this is greater than 0, a cooldown is enforced on pressing the button (delays resetting inuse)
	var/inuse = FALSE //! Relays whether the button is currently in use
	var/controlmode = MODE_TOGGLE_OPEN //! Dictates modes for airlock control. Does not change behavior for poddoors or conveyors

	HELP_MESSAGE_OVERRIDE("You can open the panel with a <b>screwdriver</b>. The tamper lock on the button can also be toggled with an <b>Access Pro</b>.")

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
	START_TRACKING_CAT(TR_CAT_DOOR_BUTTONS)
	src.original_id = src.id
	UnsubscribeProcess()

/obj/machinery/door_control/disposing()
	STOP_TRACKING_CAT(TR_CAT_DOOR_BUTTONS)
	..()

/obj/machinery/door_control/get_desc()
	. += "The panel is [src.panel_open ? "open" : "closed"]. "
	if (src.panel_open)
		if (src.tamper_lock)
			. += "The tamper lock is currently [src.tamper_lock ? "enabled" : "disabled"]. "
		. += "The display inside currently shows \the [src]'s ID as '[src.id]'. "

/obj/machinery/door_control/was_built_from_frame(mob/user, newly_built)
	. = ..()
	if (newly_built)
		src.tamper_lock = FALSE

/obj/machinery/door_control/attack_ai(mob/user as mob)
	return src.Attackhand(user)

#define CHANGE_ID "Change ID"
#define MODE_BOLTS "Change control mode to bolting"
#define MODE_OPENCLOSE "Change control mode to open/close"

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if(isscrewingtool(W))
		src.panel_open = !src.panel_open
		boutput(user, SPAN_NOTICE("You [src.panel_open ? "open" : "close"] the panel on \the [src]."))
		return
	if (ispulsingtool(W))
		var/options = list(CHANGE_ID, MODE_BOLTS, MODE_OPENCLOSE)
		var/choice = tgui_input_list(user, "What would you like to do?", "Editing [src]", options)
		switch(choice)
			if (CHANGE_ID)
				src.change_id(user)
			if (MODE_BOLTS)
				if (src.tamper_lock)
					boutput(user, SPAN_ALERT("You can't do that with the tamper lock on!"))
					return
				src.controlmode = MODE_TOGGLE_BOLTS
			if (MODE_OPENCLOSE)
				if (src.tamper_lock)
					boutput(user, SPAN_ALERT("You can't do that with the tamper lock on!"))
					return
				src.controlmode = MODE_TOGGLE_OPEN
		return
	if (istype(W, /obj/item/device/accessgun))
		return
	if (istype(W, /obj/item/deconstructor))
		return // it does its thing, just shouldnt be toggling it while doing aforementioned thing
	return src.Attackhand(user)

/obj/machinery/door_control/proc/change_id(mob/user as mob)
	if (!src.panel_open)
		return
	// Forbid changing IDs of existing buttons (so easily, at least)
	if (src.tamper_lock)
		boutput(user, SPAN_ALERT("You can't do that with the tamper lock on!"))
		return
	// Generate blacklist if it doesnt exist yet
	if (!length(reserved_machinery_control_ids))
		generate_reserved_machinery_control_ids()
	// Allow user to set a new ID, but check against blacklist first
	var/new_id = tgui_input_text(user, "What would you like the new ID to be?", "Change target ID", src.original_id, 50)
	if ((new_id != src.original_id) && (!new_id || id_on_reserved_list(new_id)))
		boutput(user, SPAN_ALERT("You can't set the ID to '[new_id]'!"))
		return
	boutput(user, SPAN_NOTICE("You set the ID to '[new_id]'."))
	src.id = new_id

/obj/machinery/door_control/proc/toggle_tamper_lock()
	src.tamper_lock = !src.tamper_lock

/obj/machinery/door_control/can_deconstruct()
	// Forbid deconstructing 'special' pre-existing buttons
	if (src.tamper_lock)
		return FALSE
	if (!src.panel_open)
		return FALSE
	. = ..()

/obj/machinery/door_control/attack_hand(mob/user)
	if (user.getStatusDuration("stunned") || user.getStatusDuration("knockdown") || user.stat)
		return
	src.toggle(user)
	src.add_fingerprint(user)

/obj/machinery/door_control/proc/toggle(mob/user)
	if((src.status & (NOPOWER|BROKEN)) || inuse)
		return

	src.use_power(5)
	icon_state = pressed_icon
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

	if(src.controlmode == MODE_TOGGLE_OPEN)
		for (var/obj/machinery/door/airlock/M in by_type[/obj/machinery/door])
			if (M.id == src.id)
				if (M.density)
					M.open()
				else
					M.close()

	if(src.controlmode == MODE_TOGGLE_BOLTS)
		for (var/obj/machinery/door/airlock/M in by_type[/obj/machinery/door])
			if (M.id == src.id)
				if (M.locked)
					M.set_unlocked()
				else
					if (M.density)
						M.set_locked()
					else
						M.close()
						SPAWN(5 DECI SECONDS)
							M.set_locked()

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
			icon_state = unpressed_icon

/obj/machinery/door_control/power_change()
	..()
	if(src.status & NOPOWER)
		icon_state = unpowered_icon
	else
		icon_state = unpressed_icon

/obj/machinery/door_control/oneshot/attack_hand(mob/user)
	..()
	if (!(src.status & BROKEN))
		src.status |= BROKEN
		src.visible_message(SPAN_ALERT("[src] emits a sad thunk.  That can't be good."))
		playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 50, 1)
	else
		boutput(user, SPAN_ALERT("It's broken."))
// Stolen from the vending module
/// For a flying chat and message addition upon controller activation, not called outside of a child as things stand
/obj/machinery/door_control/proc/speak(var/message)
	var/image/chat_maptext/speak_text = welcome_text
	if ((src.status & NOPOWER) || !message)
		return
	else
		speak_text = make_chat_maptext(src, message, "color: [src.welcome_text_color];", alpha = src.welcome_text_alpha)
		src.audible_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"[message]\"")), assoc_maptext = speak_text)
		if (speak_text && src.chat_text && length(src.chat_text.lines))
			speak_text.measure(src)
			for (var/image/chat_maptext/I in src.chat_text.lines)
				if (I != speak_text)
					I.bump_up(speak_text.measured_height)

/// for sleepers entering listening post
/obj/machinery/door_control/antagscanner
	/// For the front door having a flying chat message or not.
	var/entrance_scanner = 0
	name = "Dubious Hand Scanner"
	id = "Sleeper_Access"
	flags = FLUID_SUBMERGE | NOFPRINT
	icon = 'icons/obj/decoration.dmi'
	icon_state = "antagscanner"
	unpressed_icon = "antagscanner"
	pressed_icon = "antagscanner-u"
	unpowered_icon = "antagscanner" // should never happen, this is a failsafe if anything.
	requires_power = 0
	welcome_text = "Welcome, Agent."

/obj/machinery/door_control/ex_act(severity)
	return

/obj/machinery/door_control/antagscanner/attack_hand(mob/user)
	if (ON_COOLDOWN(src, "scan", 2 SECONDS))
		return
	playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
	if (user.mind?.get_antagonist(ROLE_SLEEPER_AGENT))
		user.visible_message(SPAN_NOTICE("The [src] accepts the biometrics of the user and beeps, granting you access."))
		src.toggle()
		if (src.entrance_scanner)
			src.speak(src.welcome_text)
	else
		boutput(user, SPAN_ALERT("Invalid biometric profile. Access denied."))

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
	var/emagged = FALSE

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		if (user && !emagged)
			boutput(user, SPAN_NOTICE("You fry the control circuits beyond repair!"))
		emagged = TRUE


	activate()
		if(emagged)
			return

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
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, null, frequency)

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
					boutput(usr, SPAN_ALERT("Your pod has no comms system installed!"))
					return ..()
				if (!V.com_system.active)
					boutput(usr, SPAN_ALERT("Your communications array isn't on!"))
					return ..()
				if (!access_type)
					open_door()
				else
					if(V.com_system.access_type.Find(src.access_type))
						open_door()
					else
						boutput(usr, SPAN_ALERT("Access denied. Comms system not recognized."))
						return ..()
			return ..()

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/device/detective_scanner))
			return
		return src.Attackhand(user)

	attack_hand(mob/user)
		boutput(user, SPAN_NOTICE("The password is \[[src.pass]\]"))
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

/obj/machinery/door_control/bolter
	name = "Remote Door Bolt Control"
	desc = "A remote control switch for a door's locking bolts."
	controlmode = MODE_TOGGLE_BOLTS

	new_walls
		north
			pixel_y = 24
		east
			pixel_x = 22
		south
			pixel_y = -19
		west
			pixel_x = -22

#undef MODE_TOGGLE_OPEN
#undef MODE_TOGGLE_BOLTS
