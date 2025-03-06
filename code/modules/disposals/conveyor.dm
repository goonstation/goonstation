// conveyor belt

#define CONVEYOR_SWITCH_COOLDOWN 0.5 SECONDS

// moves items/mobs/movables in set direction every ptick
TYPEINFO(/obj/machinery/conveyor) {
	mats = list("metal" = 1,
				"conductive" = 1,
				"crystal" = 1)
}

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
#ifndef IN_MAP_EDITOR
	icon_state = "conveyor-NS-still"
#else
	icon_state = "conveyor0-map"
#endif
	name = "conveyor belt"
	desc = "A conveyor belt."
	pass_unstable = TRUE
	anchored = ANCHORED
	power_usage = 0
	layer = 2
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	machine_registry_idx = MACHINES_CONVEYORS
	mechanics_type_override = /obj/machinery/conveyor/built
	HELP_MESSAGE_OVERRIDE("")
	/// The direction the conveyor is going to. 1 if running forward, -1 if backwards, 0 if off
	var/operating = CONVEYOR_STOPPED
	/// true if can operate (no broken segments in this belt run)
	var/operable = TRUE
	/// Direction for objects going into the conveyor.
	var/dir_in = null
	/// Direction for objects going out of the conveyor.
	var/dir_out = null
	var/currentdir = SOUTH
	/// Determines whether the conveyor can be modified and deconstructed. (Whether the cover is open.)
	var/deconstructable = FALSE
	/// Determines whether the conveyor can have it's cover open, that is, whether it can be deconstructable at all.
	var/protected = FALSE
	/// the control ID, what the conveyor switch refers to when looking for new conveyors at world init.
	var/id = ""
	// following two only used if a diverter is present
	/// if non-zero, direction to divert items
	var/divert = 0
	/// if diverting, will be conveyer dir needed to divert (otherwise dense)
	var/divdir = 0
	/// The lag at which the movement happens. Lower = faster
	var/move_lag = 4
	var/obj/machinery/conveyor/next_conveyor = null
	event_handler_flags = USE_FLUID_ENTER
	/// list of conveyor_switches that have us in their conveyors list
	var/list/linked_switches
	/// Stored operating direction for conveyors without linked switches
	var/stored_operating

	New()
		. = ..()
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_DO_LIQUID_CLICKS, src)

// for all your mapping needs!
/obj/machinery/conveyor/NE
	dir = NORTH
	dir_in = NORTH
	dir_out = EAST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-NE-map"
#endif
/obj/machinery/conveyor/NS
	dir = NORTH
	dir_in = NORTH
	dir_out = SOUTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-NS-map"
#endif
/obj/machinery/conveyor/NW
	dir = NORTH
	dir_in = NORTH
	dir_out = WEST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-NW-map"
#endif
/obj/machinery/conveyor/ES
	dir = EAST
	dir_in = EAST
	dir_out = SOUTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-ES-map"
#endif
/obj/machinery/conveyor/EW
	dir = EAST
	dir_in = EAST
	dir_out = WEST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-EW-map"
#endif
/obj/machinery/conveyor/EN
	dir = EAST
	dir_in = EAST
	dir_out = NORTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-EN-map"
#endif
/obj/machinery/conveyor/SW
	dir = SOUTH
	dir_in = SOUTH
	dir_out = WEST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-SW-map"
#endif
/obj/machinery/conveyor/SN
	dir = SOUTH
	dir_in = SOUTH
	dir_out = NORTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-SN-map"
#endif
/obj/machinery/conveyor/SE
	dir = SOUTH
	dir_in = SOUTH
	dir_out = EAST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-SE-map"
#endif
/obj/machinery/conveyor/WN
	dir = WEST
	dir_in = WEST
	dir_out = NORTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-WN-map"
#endif
/obj/machinery/conveyor/WE
	dir = WEST
	dir_in = WEST
	dir_out = EAST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-WE-map"
#endif
/obj/machinery/conveyor/WS
	dir = WEST
	dir_in = WEST
	dir_out = SOUTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-WS-map"
#endif

/obj/machinery/conveyor/NE/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/NS/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/NW/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/ES/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/EW/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/EN/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/SW/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/SN/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/SE/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/WN/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/WE/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/WS/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1

/obj/machinery/conveyor/get_help_message(dist, mob/user)
	if (src.deconstructable)
		return {"To change the conveyor belt directions, you must use a <b>crowbar</b> or any other prying item.
		Click-drag anything into the conveyor belt, and the direction into it will change to that direction.
		Click-drag the conveyor belt to anything, and the direction out of it will change to that direction.
		Click-drag a conveyor belt to another to automatically assign each one's direction.
		To change the conveyor belt's direction, link it to a conveyor belt switch through a <b>mulitool</b> by click-dragging one to another.
		To close the conveyor belt's cover and make it operational again, simply use a <b>screwdriver</b> on it."}
	else
		return "To open the conveyor belt's cover and make any changes to it, use a <b>screwdriver</b> on it."

/obj/machinery/conveyor/New()
	src.flags |= UNCRUSHABLE
	..()
	if (isrestrictedz(src.z))
		src.protected = TRUE

	if(current_state > GAME_STATE_PREGAME)
		SPAWN(0.1 SECONDS)
			src.initialize()

	currentdir = dir_out
	setdir()

/obj/machinery/conveyor/initialize()
	..()
	// if the conveyor belt does not have dir_in or dir_out set they are calculated here according to the following heuristics
	if(isnull(dir_in))
		if(isnull(dir_out))
			dir_out = dir // output dir is set to the direction of the conveyor
		var/backdir = turn(dir_out, 180)
		var/leftdir = turn(dir_out, 90)
		var/rightdir = turn(dir_out, -90)
		// in case we crash or something we set the input dir to the opposite of the target dir as a fallback
		src.dir_in = backdir
		var/candidates = list(backdir, leftdir, rightdir)
		var/scores = list() // we score each candidate by how "good" it is
		for(var/d in candidates)
			var/revd = turn(d, 180)
			var/score = 0
			var/turf/T = get_step(src, d)
			var/obj/machinery/conveyor/C = locate() in T
			if(C)
				if(C.dir_in == revd || C.dir == revd)
					score += 2 // points at us? that's great!
				else
					if(C.id == src.id)
						score += 0.3 // doesn't point at us and is of the same id? that's unlikely to be ever useful but better than nothing
					else
						score += 0.9 // doesn't point at us and has a different id? that might be pretty relevant if one gets reversed
				if(d == backdir)
					score += 1 // backwards is a pretty good default, let's bump it up a bit
			var/obj/machinery/launcher_loader/ll = locate() in T
			if(ll?.dir == revd)
				score += 1.5 // loader pointing at us is good but not as good as a conveyor belt
			var/obj/machinery/cargo_router/router = locate() in T
			if(router)
				// same for routers
				if(router.default_direction == revd)
					score += 1.5
				else
					for(var/dest in router.destinations)
						if(router.destinations[dest] == revd)
							score += 1.5
							break
			scores += score

		// if left and right are tied we take backdir to compromise, we also take backdir if it's the best one
		if(scores[2] == scores[3] || (scores[1] >= scores[2] && scores[1] >= scores[3]))
			src.dir_in = backdir
		else if(scores[2] > scores[3]) // otherwise just pick the best one
			src.dir_in = candidates[2]
		else
			dir_in = candidates[3]

		currentdir = dir_out

	setdir()

/obj/machinery/conveyor/set_dir(new_dir)
	var/old_dir = dir
	. = ..()
	var/turn_angle = turn_needed(old_dir, src.dir)
	src.dir_in = turn(src.dir_in, turn_angle)
	src.dir_out = turn(src.dir_out, turn_angle)
	src.setdir()

/obj/machinery/conveyor/process()
	if(status & NOPOWER || !operating)
		return
	..()

/obj/machinery/conveyor/disposing()
	src.was_deconstructed_to_frame()
	..()

/obj/machinery/conveyor/was_deconstructed_to_frame(mob/user)
	for(var/obj/machinery/conveyor/C in range(1,src))
		if (C.next_conveyor == src)
			C.next_conveyor = null
	next_conveyor = null

	for (var/obj/machinery/conveyor_switch/S as anything in linked_switches) //conveyor switch could've been exploded
		S.conveyors -= src
	id = null
	src.operating = CONVEYOR_STOPPED

/// set the dir and target turf depending on the operating direction
/obj/machinery/conveyor/proc/setdir()
	if (src.deconstructable)
		return

	currentdir = dir_in
	if (operating == CONVEYOR_FORWARD)
		currentdir = dir_out
	else if (operating == CONVEYOR_REVERSE)
		currentdir = dir_in

	next_conveyor = locate(/obj/machinery/conveyor) in get_step(src, currentdir)
	update()


/// update the icon depending on the operating condition
/obj/machinery/conveyor/proc/update()
	if(status & BROKEN)
		icon_state = "conveyor-b"
		operating = CONVEYOR_STOPPED

	if(!operable)
		operating = CONVEYOR_STOPPED
	if(!operating || (status & NOPOWER))
		power_usage = 0
		for(var/atom/movable/A in loc?.contents)
			walk(A, 0)
	else
		power_usage = 100
		for(var/atom/movable/A in loc?.contents)
			move_thing(A)

	var/new_icon = "conveyor-"

	var/dir_in_char = "N"
	switch (dir_in)
		if (NORTH)
			dir_in_char = "N"
		if (EAST)
			dir_in_char = "E"
		if (SOUTH)
			dir_in_char = "S"
		if (WEST)
			dir_in_char = "W"

	var/dir_out_char = "N"
	switch (dir_out)
		if (NORTH)
			dir_out_char = "N"
		if (EAST)
			dir_out_char = "E"
		if (SOUTH)
			dir_out_char = "S"
		if (WEST)
			dir_out_char = "W"


	if (operating == CONVEYOR_STOPPED || operating == CONVEYOR_FORWARD)
		new_icon += dir_in_char + dir_out_char
	else if (operating == CONVEYOR_REVERSE)
		new_icon += dir_out_char + dir_in_char

	if (src.deconstructable)
		src.icon_state = new_icon + "-map"
		return

	if (operating == CONVEYOR_STOPPED || (status & NOPOWER))
		new_icon += "-still"
	else
		new_icon += "-run"

	if (dir_in == dir_out)
		new_icon = "conveyor-fuck"

	icon_state = new_icon

/obj/machinery/conveyor/proc/can_convey(var/atom/movable/A)
	if (A.anchored || A.temp_flags & BEING_CRUSHERED)
		return FALSE
	if(istype(A, /obj/machinery/bot) && A:on)	//They drive against the motion of the conveyor, ok.
		return FALSE
	if(istype(A, /obj/critter) && A:flying)		//They are flying above it, ok.
		return FALSE
	if(HAS_ATOM_PROPERTY(A, PROP_ATOM_FLOATING)) // Don't put new checks here, apply this atom prop instead.
		return FALSE
	return TRUE

/obj/machinery/conveyor/proc/move_thing(var/atom/movable/A)
	if (!can_convey(A))
		return
	var/movedir = currentdir	// base movement dir
	if(divert && currentdir == divdir)	// update if diverter present
		movedir = divert

	var/mob/M = A
	if(istype(M) && M.buckled == src)
		M.glide_size = (32 / move_lag) * world.tick_lag
		walk(M, movedir, move_lag, (32 / move_lag) * world.tick_lag)
		M.glide_size = (32 / move_lag) * world.tick_lag

		if (src.move_lag <= 1)
			if (prob( (1-src.move_lag) * 1.2) )
				var/turf/T = get_edge_target_turf(src, src.dir)
				M.throw_at(T,rand(0,5),rand(1,3))

	else
		A.glide_size = (32 / move_lag) * world.tick_lag
		walk(A, movedir, move_lag, (32 / move_lag) * world.tick_lag)
		A.glide_size = (32 / move_lag) * world.tick_lag

/obj/machinery/conveyor/Crossed(atom/movable/AM)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return
	if(AM.loc != src.loc) //fixes race condition where AM gets yoinked during the turf-to-turf loop that calls Crossed on everything (& ends up with an active walk inside another object)
		return
	move_thing(AM)

/obj/machinery/conveyor/Uncrossed(var/atom/movable/AM)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return
	if(!can_convey(AM))
		walk(AM, 0)
		return

	if(src.next_conveyor && src.next_conveyor.loc == AM.loc)
		//Ok, they will soon walk() according to the new conveyor
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Transfer the buckle
			M.buckled = next_conveyor
		if(!next_conveyor.operating || next_conveyor.status & NOPOWER)
			walk(AM, 0)
			return
	else
		//Stop walking, we left the belt
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Unbuckle
			M.buckled = null
			new /obj/item/cable_coil/cut(M.loc)
		walk(AM, 0)

/obj/machinery/conveyor/get_desc()
	if (src.deconstructable)
		. += " [SPAN_NOTICE("Its cover seems to be open.")]"

/obj/machinery/conveyor/mouse_drop(over_object, src_location, over_location)
	if (!usr)
		return
	if (!src.deconstructable)
		usr.show_text("\The [src]'s panel is closed. You have to open it to do any changes to it.", "red")
		return

	if (over_object == src || src_location == over_location)
		return ..()

	var/obj/item/equipped_object = usr.equipped()
	if (!equipped_object)
		return ..() // We have nothing to do here if the user has no equipped object.

	if (ispryingtool(equipped_object))
		if (BOUNDS_DIST(src, usr))
			usr.show_text("You are too far away to do that!", "red")
			return

		var/dir_target_atom = get_dir(src_location, over_location)

		if (dir_target_atom in ordinal) // Sanitize the direction we want to pick. We just want to have no diagonals, since it isn't supported by conveyor belts at the time of this commit.
			dir_target_atom &= (WEST | EAST) // Roughly translates to "dir_target_atom is itself but only east or west direction"

		if (dir_target_atom == src.dir_in) // Swap directions if the player is trying to set the same direction to both directions.
			src.dir_in = dir_out
		src.dir_out = dir_target_atom
		src.update()
		return

	if (ispulsingtool(equipped_object))
		if(!istype(over_object, /obj/machinery/conveyor_switch))
			return ..()
		var/obj/machinery/conveyor_switch/new_switch = over_object
		src.id = new_switch.id
		src.linked_switches += new_switch
		new_switch.conveyors += src
		usr.show_text("You connect \the [new_switch] to the [src].", "blue")

	return ..()

/obj/machinery/conveyor/MouseDrop_T(dropped, user, src_location, over_location) // Pretty much a copy-paste. Both procs are almost identical.
	if (!user)
		return
	if (dropped == src || src_location == over_location)
		return

	if (!src.deconstructable)
		usr.show_text("\The [src]'s panel is closed. You have to open it to do any changes to it.", "red")
		return

	var/obj/item/equipped_object = usr.equipped()
	if (!equipped_object)
		return ..()

	if (ispryingtool(equipped_object))
		if (BOUNDS_DIST(src, user))
			usr.show_text("You are too far away to do that!", "red")
			return ..()

		var/dir_target_atom = get_dir(over_location, src_location)

		if (dir_target_atom in ordinal)
			dir_target_atom &= (WEST | EAST)

		if (dir_target_atom == src.dir_out)
			src.dir_out = src.dir_in
		src.dir_in = dir_target_atom
		src.update()
		return

	if (ispulsingtool(equipped_object))
		if(!istype(dropped, /obj/machinery/conveyor_switch))
			return ..()
		var/obj/machinery/conveyor_switch/new_switch = dropped
		src.id = new_switch.id
		src.linked_switches += new_switch
		new_switch.conveyors += src
		usr.show_text("You connect \the [new_switch] to the [src].", "blue")

	return ..()

/obj/machinery/conveyor/attackby(var/obj/item/I, mob/user)
	if (istype(I, /obj/item/grab))	// special handling if grabbing a mob
		var/obj/item/grab/G = I
		G.affecting.Move(src.loc)
		qdel(G)
		return
	else if (istype(I, /obj/item/cable_coil))	// if cable, see if a mob is present
		var/mob/M = locate() in src.loc
		if(M)
			if (M == user)
				src.visible_message(SPAN_NOTICE("[M] ties [himself_or_herself(M)] to the conveyor."))
				// note don't check for lying if self-tying
			else
				if(M.lying)
					user.visible_message(SPAN_NOTICE("[M] has been tied to the conveyor by [user]."), SPAN_NOTICE("You tie [M] to the converyor!"))
				else
					boutput(user, SPAN_HINT("[M] must be lying down to be tied to the converyor!"))
					return

			M.buckled = src //behold the most mobile of stools
			src.add_fingerprint(user)
			I:use(1)
			M.lying = 1
			M.set_clothing_icon_dirty()
			return

			// else if no mob in loc, then allow coil to be placed
	else if (isscrewingtool(I))
		if (src.protected)
			user.show_text("\The [src] is too strong to have it's cover un-screwed.", "red")
			return

		if (ON_COOLDOWN(user, "conveyor_belt_cover", 1 SECOND))
			return

		var/actionbar_duration = 2 SECONDS
		if (user.traitHolder.getTrait("training_engineer"))
			actionbar_duration = 0.5 SECONDS

		user.show_text("You start [src.deconstructable ? "" : "un-"]screwing \the [src]'s cover.")
		SETUP_GENERIC_ACTIONBAR(user, src, actionbar_duration, PROC_REF(toggle_deconstructability), list(user), src.icon, src.icon_state, null, null)

	else if (issnippingtool(I))
		var/mob/M = locate() in src.loc
		if(M && M.buckled == src)
			M.buckled = null
			src.add_fingerprint(user)
			if (M == user)
				src.visible_message(SPAN_NOTICE("[M] cuts [himself_or_herself(M)] free from the conveyor."))
			else
				src.visible_message(SPAN_NOTICE("[M] had been cut free from the conveyor by [user]."))
			return
	else if (ispulsingtool(I) && src.deconstructable)
		var/datum/component/mechanics_connector/connector = I.GetComponent(/datum/component/mechanics_connector)
		if (!connector)
			return ..()
		if (!istype(connector.connectee, /obj/machinery/conveyor_switch))
			return ..()

		var/obj/machinery/conveyor_switch/connected_switch = connector.connectee
		src.id = connected_switch.id
		src.linked_switches += connected_switch
		connected_switch.conveyors += src
		user.show_text("You connect \the [src] to \the [connector.connectee].", "blue")
// attack with hand, move pulled object onto conveyor

/obj/machinery/conveyor/proc/toggle_deconstructability(var/mob/M)
	if (!M)
		return

	if (src.deconstructable)
		src.deconstruct_flags = DECON_NONE
		src.deconstructable = FALSE
		M.show_text("You finish closing \the [src]'s panel.", "blue")
		if (length(src.linked_switches))
			var/obj/machinery/conveyor_switch/connected_switch = src.linked_switches[1]
			src.operating = connected_switch.position
			src.setdir()
		else
			src.operating = src.stored_operating
			src.stored_operating = null
			src.set_dir()
		src.update()
		return 1

	else
		src.deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WRENCH | DECON_MULTITOOL
		src.deconstructable = TRUE
		M.show_text("You finish opening \the [src]'s panel.", "blue")
		if (length(src.linked_switches))
			src.operating = CONVEYOR_STOPPED
			src.setdir()
		else
			src.stored_operating = src.operating
			src.operating = CONVEYOR_STOPPED
			src.setdir()
		src.update()
		return 1

/obj/machinery/conveyor/attack_hand(mob/user)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling)))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		M.remove_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.remove_pulling()
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.remove_pulling()
	return

// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	status |= BROKEN
	update()

	var/obj/machinery/conveyor/C
	C = locate() in get_step(src, dir_in)
	C?.set_operable(CONVEYOR_FORWARD, id, 0)

	C = locate() in get_step(src, dir_out)
	C?.set_operable(CONVEYOR_REVERSE, id, 0)


/// set the operable var if ID matches, propagating in the given direction
/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)
	if(id != match_id)
		return
	operable = op

	update()
	var/propdir = dir_in
	if (stepdir == CONVEYOR_FORWARD)
		propdir = dir_in
	else if(stepdir == CONVEYOR_REVERSE)
		propdir = dir_out
	var/obj/machinery/conveyor/C = locate() in get_step(src, propdir)
	C?.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	..()
	if(QDELETED(src))
		return
	update()

/obj/machinery/conveyor/built/
	desc = "A conveyor belt. This one looks like it was built recently."
	deconstructable = TRUE

	initialize() // Look around for other conveyor belts and assume a dir_in and dir_out based on that.
		var/list/favorable_dir_ins = list()
		var/list/favorable_dir_outs = list()
		for (var/direction in cardinal)
			var/turf/T = get_step(src, direction)
			var/obj/machinery/conveyor/neighbor_conveyor = locate() in T

			if (neighbor_conveyor) // If we actually have a conveyor belt in that direction...
				if (direction == turn(neighbor_conveyor.dir_in, 180)) // Is it contrary to a dir_in of another conveyor belt?
					favorable_dir_outs += direction // Great! A favorable dir_out.
				if (direction == turn(neighbor_conveyor.dir_out, 180)) // Is it contrary to the dir_out of another conveyour belt?
					favorable_dir_ins += direction // Great! A favorable dir_in.

		if (length(favorable_dir_ins))
			src.dir_in = favorable_dir_ins[1] // If there are any favorable dir ins, pick the first index.
		if (length(favorable_dir_outs))
			src.dir_out = favorable_dir_outs[1]

		if (!src.dir_in)
			src.dir_in = NORTH // In the case there's no favorable dir_ins, pick north.
		if (!src.dir_out || src.dir_out == src.dir_in)
			src.dir_out = turn(src.dir_in, 180) // In the case there's no favorable dir_outs, pick the contrary of dir_in.

		. = ..()

/obj/machinery/conveyor/was_built_from_frame(mob/user, newly_built)
	. = ..()
	src.id = null
	src.next_conveyor = null
	src.linked_switches = list()
/obj/item/debug_conveyor_layer
	name = "conveyor layer"
	icon = 'icons/obj/recycling.dmi'
	icon_state = "debug"
	var/on = FALSE
	var/list/obj/machinery/conveyor/conveyors
	var/list/obj/machinery/conveyor_switch/switches
	var/conv_id

	attack_self(mob/user)
		if (!on)
			switch_on(user)
		else
			switch_off(user)

	proc/switch_on(var/mob/user, var/use_id = null)
		on = TRUE
		icon_state = "debug-on"
		conveyors = list()
		switches = list()
		conv_id = "[world.time]"
		user.AddComponent(/datum/component/conveyorplacer, conveyors, conv_id)

	proc/switch_off(var/mob/user)
		on = FALSE
		icon_state = "debug"
		var/datum/component/conveyorplacer/CP = user.GetComponent(/datum/component/conveyorplacer)
		CP.RemoveComponent()
		for (var/obj/machinery/conveyor/C in src.conveyors)
			C.linked_switches = src.switches
		for (var/obj/machinery/conveyor_switch/S in src.switches)
			S.conveyors = src.conveyors

	afterattack(atom/target, mob/user, reach, params)
		if (on && isturf(target))
			var/obj/machinery/conveyor_switch/sw = new /obj/machinery/conveyor_switch(target)
			sw.id = conv_id
			src.switches |= sw

	dropped(mob/user)
		. = ..()
		switch_off(user)

	disposing()
		. = ..()
		if (on && ismob(src.loc))
			switch_off(src.loc)

// conveyor diverter
// extendable arm that can be switched so items on the conveyer are diverted sideways
// situate in same turf as conveyor
// only works if belts is running proper direction
/obj/machinery/diverter
	icon = 'icons/obj/recycling.dmi'
	icon_state = "diverter0"
	name = "diverter"
	desc = "A diverter arm for a conveyor belt."
	pass_unstable = TRUE
	anchored = ANCHORED
	layer = FLY_LAYER
	event_handler_flags = USE_FLUID_ENTER
	var/obj/machinery/conveyor/conv // the conveyor this diverter works on
	var/deployed = 0	// true if diverter arm is extended
	var/operating = 0	// true if arm is extending/contracting
	var/divert_to	// the dir that diverted items will be moved
	var/divert_from // the dir items must be moving to divert


// create a diverter
// set up divert_to and divert_from directions depending on dir state
/obj/machinery/diverter/New()
	..()
	switch(dir)
		if(NORTH)
			divert_to = WEST			// stuff will be moved to the west
			divert_from = NORTH			// if entering from the north
		if(SOUTH)
			divert_to = EAST
			divert_from = NORTH
		if(EAST)
			divert_to = EAST
			divert_from = SOUTH
		if(WEST)
			divert_to = WEST
			divert_from = SOUTH
		if(NORTHEAST)
			divert_to = NORTH
			divert_from = EAST
		if(NORTHWEST)
			divert_to = NORTH
			divert_from = WEST
		if(SOUTHEAST)
			divert_to = SOUTH
			divert_from = EAST
		if(SOUTHWEST)
			divert_to = SOUTH
			divert_from = WEST
	SPAWN(0.2 SECONDS)
		// wait for map load then find the conveyor in this turf
		conv = locate() in src.loc
		if(conv)	// divert_from dir must match possible conveyor movement
			if(conv.dir_in != divert_from && conv.dir_out != turn(divert_from,180) )
				qdel(src)	// if no dir match, then delete self
		set_divert()
		update()

// update the icon state depending on whether the diverter is extended
/obj/machinery/diverter/proc/update()
	icon_state = "diverter[deployed]"

// call to set the diversion vars of underlying conveyor
/obj/machinery/diverter/proc/set_divert()
	if(conv)
		if(deployed)
			conv.divert = divert_to
			conv.divdir = divert_from
		else
			conv.divert= 0


// *** TESTING click to toggle
/obj/machinery/diverter/Click()
	toggle()


// toggle between arm deployed and not deployed, showing animation
//
/obj/machinery/diverter/proc/toggle()
	if( status & (NOPOWER|BROKEN))
		return

	if(operating)
		return

	use_power(50)
	operating = 1
	if(deployed)
		flick("diverter10",src)
		icon_state = "diverter0"
		sleep(1 SECOND)
		deployed = 0
	else
		flick("diverter01",src)
		icon_state = "diverter1"
		sleep(1 SECOND)
		deployed = 1
	operating = 0
	update()
	set_divert()

// don't allow movement into the 'backwards' direction if deployed
/obj/machinery/diverter/Cross(atom/movable/O)
	var/direct = get_dir(O, src)
	if(direct == divert_to)	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != turn(divert_from,180))

// don't allow movement through the arm if deployed
/obj/machinery/diverter/Uncross(atom/movable/O, do_bump=TRUE)
	var/direct = get_dir(O, O.movement_newloc)
	if(direct == turn(divert_to,180))	// prevent movement through body of diverter
		. = 0
	else if(!deployed)
		. = 1
	else
		. = direct != divert_from
	UNCROSS_BUMP_CHECK(O)






#define CALC_DELAY(C) max(initial(C.move_lag) - src.speedup + src.slowdown, 0.1)

ADMIN_INTERACT_PROCS(/obj/machinery/conveyor_switch, proc/trigger)
TYPEINFO(/obj/machinery/conveyor_switch) {
	mats = list("metal" = 10,
				"conductive" = 10,
				"crystal" = 10)
}

/// the conveyor control switch
/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	mechanics_type_override = /obj/machinery/conveyor_switch/built
	icon_state = "switch-off"
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	/// current direction setting
	var/position = CONVEYOR_STOPPED
	/// last direction setting
	var/last_pos = CONVEYOR_REVERSE
	// Checked against conveyor ID on link attempt
	var/id = ""
	/// the list of converyors that are controlled by this switch
	var/list/conveyors
	anchored = ANCHORED
	///How much this switch is configured to manually slow down by
	VAR_PROTECTED/slowdown = 0
	///How much speed boost this switch is getting
	VAR_PROTECTED/speedup = 0

	HELP_MESSAGE_OVERRIDE("Click to cycle between forward, stop, and reverse.<br>Click-drag right or left to set the direction forward or reverse.")

	New()
		. = ..()
		UnsubscribeProcess()
		START_TRACKING
		UpdateIcon()
		if (!isrestrictedz(src.z))
			AddComponent(/datum/component/mechanics_holder)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Flip", PROC_REF(trigger))
			SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Speed", PROC_REF(set_speed))
		conveyors = list()
		SPAWN(0.5 SECONDS)
			link_conveyors()
			for (var/obj/machinery/conveyor/C as anything in conveyors)
				if (C.id == src.id)
					C.operating = position
					C.setdir()

	disposing()
		STOP_TRACKING
		for (var/obj/machinery/conveyor/C as anything in conveyors)
			C.linked_switches -= src
		conveyors = null
		. = ..()

	proc/link_conveyors()
		for (var/obj/machinery/conveyor/C as anything in machine_registry[MACHINES_CONVEYORS])
			if (C.id == src.id)
				conveyors |= C
				if (!C.linked_switches)
					C.linked_switches = list()
				C.linked_switches |= src

	proc/trigger(var/inp)
		src.Attackhand(usr) //bit of a hack but hey.
		return

	proc/set_speed(datum/mechanicsMessage/msg)
		var/speed = text2num_safe(msg.signal)
		if (!speed)
			return
		speed = clamp(speed, 1, 10)
		src.update_speed(slowdown = (1 - speed/10) * 5)

	proc/update_speed(speedup = null, slowdown = null)
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if(S.id != src.id)
				continue
			if (!isnull(speedup))
				S.speedup = speedup
			if (!isnull(slowdown))
				S.slowdown = slowdown

		for (var/obj/machinery/conveyor/C as anything in conveyors)
			if (C.id == src.id)
				C.move_lag = CALC_DELAY(C)

	/// update the icon depending on the position
	update_icon()
		if(position == CONVEYOR_REVERSE)
			icon_state = "switch-rev"
		else if(position == CONVEYOR_FORWARD)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-off"

	// attack with hand, switch position
	attack_hand(mob/user)
		if(ON_COOLDOWN(src, "switch", CONVEYOR_SWITCH_COOLDOWN))
			return
		src.add_fingerprint(user)
		if(position == CONVEYOR_STOPPED)
			if (last_pos == CONVEYOR_REVERSE)
				src.go_forward()
			else
				src.go_reverse()
			logTheThing(LOG_STATION, user, "turns the conveyor switch on in [last_pos == CONVEYOR_REVERSE ? "forward" : "reverse"] mode at [log_loc(src)].")
		else
			src.stop()
			logTheThing(LOG_STATION, user, "turns the conveyor switch off at [log_loc(src)].")
		src.UpdateIcon()
		src.update_others()

	// click-drag to set direction left/right
	mouse_drop(atom/over_object, src_location, over_location, src_control, over_control, params)
		if (!isliving(usr)) return
		if (!can_act(usr) || !can_reach(usr, src)) return
		var/mob/M = usr
		if (ispulsingtool(M.equipped()) && istype(over_object, /obj/machinery/conveyor)) return // linking handled in conveyor MouseDrop_T
		if (ON_COOLDOWN(src, "switch", CONVEYOR_SWITCH_COOLDOWN)) return
		src.add_fingerprint(usr)
		switch (over_location:x - src_location:x)
			if (0)
				return
			if (1 to INFINITY)
				src.go_forward()
			if (-INFINITY to -1)
				src.go_reverse()
		logTheThing(LOG_STATION, usr, "turns the conveyor switch to [src.position == CONVEYOR_REVERSE ? "forward" : "reverse"] mode at [log_loc(src)].")
		src.UpdateIcon()
		src.update_others()

	proc/go_forward()
		src.last_pos = src.position
		src.position = CONVEYOR_FORWARD

	proc/go_reverse()
		src.last_pos = src.position
		src.position = CONVEYOR_REVERSE

	proc/stop()
		src.last_pos = src.position
		src.position = CONVEYOR_STOPPED

	/// Update matching switches and conveyors to our position
	proc/update_others()
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if (S == src) continue
			if (S.id == src.id)
				S.position = src.position
				S.UpdateIcon()
			LAGCHECK(LAG_MED)

		for (var/obj/machinery/conveyor/C as anything in conveyors)
			if (C.id == src.id)
				C.operating = src.position
				C.setdir()
				C.move_lag = CALC_DELAY(C)

		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"switchTriggered")

#undef CALC_DELAY
/obj/machinery/conveyor_switch/built/
	desc = "A conveyor control switch. This one looks like it was built recently."


	New()
		. = ..()
		UnsubscribeProcess()
		START_TRACKING
		UpdateIcon()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", PROC_REF(trigger))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Refresh ID", PROC_REF(get_new_id))
		src.get_new_id()

	proc/get_new_id()
		src.id = ckey("\ref[src]") // Create a new ID on the fly. It doesn't need to be readable, it just needs to be unique.
		src.conveyors = list()

	MouseDrop_T(dropped, mob/user)
		if (user.find_tool_in_hand(TOOL_PULSING))
			if (!istype(dropped, /obj/machinery/conveyor_switch))
				return ..()
			var/obj/machinery/conveyor_switch/connected_switch = dropped
			for (var/obj/machinery/conveyor/conveyor in src.conveyors)
				conveyor.id = connected_switch.id
				conveyor.linked_switches += connected_switch

			src.id = connected_switch.id
			connected_switch.conveyors = src.conveyors
			user.show_text("You connect \the [src] to \the [dropped]. Both share the same ID now.", "blue")

		return ..()
//silly proc for corners that can be flippies
/obj/machinery/conveyor/proc/rotateme()
	.= 0

/obj/machinery/carouselpower
	var/maxdrain = 23 MEGA WATTS
	var/bonusdrain = 100 MEGA WATTS

	var/speedup = 0
	var/speedup_max = 3.5
	var/speedup_bonus = 1
	icon = 'icons/obj/fluid.dmi'
	icon_state = "battery-0"
	name = "carousel power unit"
	desc = "All power dumped into this power unit will boost the speed of the station's cargo carousel."
	density = 1
	anchored = ANCHORED
	event_handler_flags =  USE_FLUID_ENTER

	var/icon_base = "battery-"
	var/icon_levels = 6 //there are 7 icons of power levels (6 + 1 for unpowered)
	var/obj/cable/attached

	var/search_interval = 1 MINUTES
	var/last_search = 0

	New()
		..()
		attached = locate() in get_turf(src)

	set_loc()
		..()
		attached = locate() in get_turf(src)

	process()
		..()
		var/last_speedup = speedup
		speedup = 0

		if( attached && !(status & (BROKEN | NOPOWER)) )
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				var/power_to_use = 0

				var/free_power = PN.avail - PN.newload
				power_to_use = min ( maxdrain, free_power )
				speedup = (power_to_use/maxdrain) * speedup_max

				if (free_power > maxdrain)
					power_to_use = min ( maxdrain+bonusdrain, free_power )
					speedup += (power_to_use / bonusdrain ) * speedup_bonus

				PN.newload += power_to_use
				//use_power(power_to_use)

		if (!attached)
			if (world.time + search_interval > last_search)
				last_search = world.time
				attached = locate() in get_turf(src)

		if (speedup != last_speedup)
			update_belts()
			UpdateIcon()

	proc/update_belts()
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if(S.id == "carousel")
				S.update_speed(speedup = speedup)
				break

	update_icon()
		var/ico = clamp(((speedup / speedup_max) * icon_levels), 0, 6)
		icon_state = "[icon_base][round(ico)]"

//turns on when area is active
/obj/machinery/conveyor/area_activated
	var/area/activation_area = null

	New()
		. = ..()
		activation_area = get_area(src)
		// this assumes that the conveyor's area never changes
		// if we expect the area of the conveyor to change (because the conveyor got deconstructed / moved or the turf beneat it got replaced with space etc.)
		// we should have signals for area changes in the future
		// however, currently these are only used in an adventure zone where such changes are unlikely
		RegisterSignal(activation_area, COMSIG_AREA_ACTIVATED, PROC_REF(turn_on))
		RegisterSignal(activation_area, COMSIG_AREA_DEACTIVATED, PROC_REF(turn_off))

	set_loc(atom/target)
		. = ..()
		var/area/A = get_area(target)
		if (activation_area == A || isnull(A)) return
		UnregisterSignal(activation_area, list(COMSIG_AREA_ACTIVATED, COMSIG_AREA_DEACTIVATED))
		if(QDELETED(src))
			return
		activation_area = A
		RegisterSignal(activation_area, COMSIG_AREA_ACTIVATED, PROC_REF(turn_on))
		RegisterSignal(activation_area, COMSIG_AREA_DEACTIVATED, PROC_REF(turn_off))
		if (activation_area.active)
			turn_on()

	proc/turn_on()
		// (status & (BROKEN | NOPOWER)) checks might be needed here in the future who knows
		src.operating = TRUE
		src.setdir()
		src.update()

	proc/turn_off()
		src.operating = FALSE
		src.setdir()
		src.update()

	disposing()
		UnregisterSignal(activation_area, list(COMSIG_AREA_ACTIVATED, COMSIG_AREA_ACTIVATED))
		..()

//only runs when area is active and operating
/obj/machinery/conveyor/area_activity_dependant
	var/area/activation_area = null

	New()
		. = ..()
		activation_area = get_area(src)

	process()
		if (!src.activation_area.active)
			return
		. = ..()

	move_thing()
		if (!src.activation_area.active)
			return
		. = ..()

#undef CONVEYOR_SWITCH_COOLDOWN
