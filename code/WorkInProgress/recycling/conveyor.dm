// conveyor belt

// moves items/mobs/movables in set direction every ptick
TYPEINFO(/obj/machinery/conveyor) {
	mats = list("MET-1" = 1, "CON-1" = 1, "CRY-1" = 1)
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
	var/operating = CONVEYOR_STOPPED	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = TRUE	// true if can operate (no broken segments in this belt run)
	var/dir_in = NORTH
	var/dir_out = SOUTH
	var/currentdir = SOUTH
	var/deconstructable = FALSE
	var/protected = FALSE

	var/id = ""			// the control ID	- must match controller ID
	// following two only used if a diverter is present
	var/divert = 0 		// if non-zero, direction to divert items
	var/divdir = 0		// if diverting, will be conveyer dir needed to divert (otherwise dense)
	var/move_lag = 4	// The lag at which the movement happens. Lower = faster
	var/obj/machinery/conveyor/next_conveyor = null
	event_handler_flags = USE_FLUID_ENTER
	/// list of conveyor_switches that have us in their conveyors list
	var/list/linked_switches = list()

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

/obj/machinery/conveyor/New()
	src.flags |= UNCRUSHABLE
	..()

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
	for(var/obj/machinery/conveyor/C in range(1,src))
		if (C.next_conveyor == src)
			C.next_conveyor = null
	next_conveyor = null

	for (var/obj/machinery/conveyor_switch/S as anything in linked_switches) //conveyor switch could've been exploded
		S.conveyors -= src
	id = null
	..()

/// set the dir and target turf depending on the operating direction
/obj/machinery/conveyor/proc/setdir()
	if (src.deconstructable) return

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
		for(var/atom/movable/A in loc.contents)
			walk(A, 0)
	else
		power_usage = 100
		for(var/atom/movable/A in loc.contents)
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
		walk(M, dir, move_lag, (32 / move_lag) * world.tick_lag)
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
	if (!can_convey(AM))
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
		. += " <span class='notice'>It's cover seems to be open.</span>"


// Sanitize what direction the player wants to set.
#define PLAYER_SET_DIR_IN(dir, conveyor) if (conveyor.dir_out != dir) conveyor.dir_in = dir
#define PLAYER_SET_DIR_OUT(dir, conveyor) if (conveyor.dir_in != dir) conveyor.dir_out = dir

/obj/machinery/conveyor/mouse_drop(over_object, src_location, over_location)
	if (!usr) return
	if (!src.deconstructable)
		usr.show_text("\The [src]'s panel is closed. You have to open it to do any changes to it.", "red")
		return

	if (over_object == src || src_location == over_location) return ..()

	var/obj/item/equipped_object = usr.equipped()
	if (!equipped_object) return ..() // We have nothing to do here if the user has no equipped object.

	if (ispryingtool(equipped_object))
		if (BOUNDS_DIST(src, usr))
			usr.show_text("You are too far away to do that!", "red")
			return

		var/dir_target_atom = get_dir(src_location, over_location)

		if (dir_target_atom in ordinal) // Sanitize the direction we want to pick. We just want to have no diagonals, since it isn't supported by conveyor belts at the time of this commit.
			dir_target_atom &= (WEST | EAST) // Roughly translates to "dir_target_atom is itself but only east or west direction"

		PLAYER_SET_DIR_OUT(dir_target_atom, src)
		src.update()
		return

	if (ispulsingtool(equipped_object))
		if(!istype(over_object, /obj/machinery/conveyor_switch)) return ..()
		var/obj/machinery/conveyor_switch/new_switch = over_object
		src.id = new_switch.id
		src.linked_switches += new_switch
		new_switch.conveyors += src
		usr.show_text("You connect \the [new_switch] to the [src].", "blue")

	return ..()

/obj/machinery/conveyor/MouseDrop_T(dropped, user, src_location, over_location) // Pretty much a copy-paste. Both procs are almost identical.
	if (!user) return
	if (dropped == src || src_location == over_location) return
	if (BOUNDS_DIST(src, user))
		return ..()

	var/obj/item/equipped_object = usr.equipped()
	if (!equipped_object) return ..()

	if (ispryingtool(equipped_object))
		if (!src.deconstructable)
			usr.show_text("\The [src]'s panel is closed. You have to open it to do any changes.", "red")
			return

		var/dir_target_atom = get_dir(over_location, src_location)

		if (dir_target_atom in ordinal)
			dir_target_atom &= (WEST | EAST)

		PLAYER_SET_DIR_IN(dir_target_atom, src)
		src.update()
		return

	if (ispulsingtool(equipped_object))
		if(!istype(dropped, /obj/machinery/conveyor_switch)) return ..()
		var/obj/machinery/conveyor_switch/new_switch = dropped
		src.id = new_switch.id
		src.linked_switches += new_switch
		new_switch.conveyors += src
		usr.show_text("You connect \the [new_switch] to the [src].", "blue")

	return ..()

#undef PLAYER_SET_DIR_IN
#undef PLAYER_SET_DIR_OUT

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
				src.visible_message("<span class='notice'>[M] ties [himself_or_herself(M)] to the conveyor.</span>")
				// note don't check for lying if self-tying
			else
				if(M.lying)
					user.visible_message("<span class='notice'>[M] has been tied to the conveyor by [user].</span>", "<span class='notice'>You tie [M] to the converyor!</span>")
				else
					boutput(user, "<span class='hint'>[M] must be lying down to be tied to the converyor!</span>")
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

		if (ON_COOLDOWN(user, "conveyor_belt_cover", 1 SECOND)) return

		var/actionbar_duration = 5 SECONDS
		if (user.traitHolder.getTrait("training_engineer")) actionbar_duration = 2 SECONDS

		user.show_text("You start [src.deconstructable ? "" : "un-"]screwing \the [src]'s cover.")
		SETUP_GENERIC_ACTIONBAR(user, src, actionbar_duration, PROC_REF(toggle_deconstructability), list(user), src.icon, src.icon_state, null, null)

	else if (issnippingtool(I))
		var/mob/M = locate() in src.loc
		if(M && M.buckled == src)
			M.buckled = null
			src.add_fingerprint(user)
			if (M == user)
				src.visible_message("<span class='notice'>[M] cuts [himself_or_herself(M)] free from the conveyor.</span>")
			else
				src.visible_message("<span class='notice'>[M] had been cut free from the conveyor by [user].</span>")
			return
	else if (ispulsingtool(I))
		var/datum/component/mechanics_connector/connector = I.GetComponent(/datum/component/mechanics_connector)
		if (!connector) return ..()
		if (!istype(connector.connectee, /obj/machinery/conveyor_switch)) return ..()

		var/obj/machinery/conveyor_switch/connected_switch = connector.connectee
		src.id = connected_switch.id
		src.linked_switches += connected_switch
		user.show_text("You connect \the [src] to \the [connector.connectee].", "blue")
// attack with hand, move pulled object onto conveyor

/obj/machinery/conveyor/proc/toggle_deconstructability(var/mob/M)
	if (!M) return

	if (src.deconstructable)
		src.deconstruct_flags = null
		src.deconstructable = FALSE
		M.show_text("You finish closing \the [src]'s panel.", "blue")
		if (length(src.linked_switches) > 0)
			var/obj/machinery/conveyor_switch/connected_switch = src.linked_switches[1]
			src.operating = connected_switch.position
			src.setdir()

		return 1

	else
		src.deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WRENCH | DECON_MULTITOOL
		src.deconstructable = TRUE
		M.show_text("You finish opening \the [src]'s panel.", "blue")
		if (length(src.linked_switches) > 0)
			src.operating = CONVEYOR_STOPPED
			src.setdir()

		return 1

/obj/machinery/conveyor/attack_hand(mob/user)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0))
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

		if (length(favorable_dir_ins) > 0) src.dir_in = favorable_dir_ins[1] // If there are any favorable dir ins, pick the first index.
		if (length(favorable_dir_outs) > 0) src.dir_out = favorable_dir_outs[1]

		if (!src.dir_in) src.dir_in = NORTH // In the case there's no favorable dir_ins, pick north.
		if (!src.dir_out) src.dir_out = turn(src.dir_in, 180) // In the case there's no favorable dir_outs, pick the contrary of dir_in.

		. = ..()

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




ADMIN_INTERACT_PROCS(/obj/machinery/conveyor_switch, proc/trigger)

TYPEINFO(/obj/machinery/conveyor_switch) {
	mats = list("MET-1" = 10, "CON-1" = 10, "CRY-1" = 10)
}

/// the conveyor control switch
/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	/// current direction setting
	var/position = CONVEYOR_STOPPED
	/// last direction setting
	var/last_pos = CONVEYOR_REVERSE
	// Checked against conveyor ID on link attempt
	var/id = ""
	/// the list of converyors that are controlled by this switch
	var/list/conveyors = list()
	anchored = ANCHORED
	/// time last used
	var/last_used = 0

	New()
		. = ..()
		UnsubscribeProcess()
		START_TRACKING
		UpdateIcon()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", PROC_REF(trigger))
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
		attack_hand(usr) //bit of a hack but hey.
		return

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
		if (TIME < (last_used + 0.5 SECONDS))
			return
		last_used = TIME
		if(position == CONVEYOR_STOPPED)
			if (last_pos == CONVEYOR_REVERSE)
				position = CONVEYOR_FORWARD
				last_pos = CONVEYOR_STOPPED
			else
				position = CONVEYOR_REVERSE
				last_pos = CONVEYOR_STOPPED
			logTheThing(LOG_STATION, user, "turns the conveyor switch on in [last_pos == CONVEYOR_REVERSE ? "forward" : "reverse"] mode at [log_loc(src)].")
		else
			last_pos = position
			position = CONVEYOR_STOPPED
			logTheThing(LOG_STATION, user, "turns the conveyor switch off at [log_loc(src)].")
		UpdateIcon()

		// find any switches with same id as this one, and set their positions to match us
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if (S == src) continue
			if(S.id == src.id)
				S.position = position
				S.UpdateIcon()
			LAGCHECK(LAG_MED)

		for (var/obj/machinery/conveyor/C as anything in conveyors)
			if (C.id == src.id)
				C.operating = position
				C.setdir()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"switchTriggered")

/obj/machinery/conveyor_switch/built/
	desc = "A conveyor control switch. This one looks like it was built recently."
	var/static/list/switch_ids

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
		if (src.id) // If we already have an ID, remove it from the switch ID pool.
			src.switch_ids -= src.id

		var/new_id = TIME // Create a new ID on the fly. It doesn't need to be readable, it just needs to be unique.
		var/id_disambiguation_number = 0
		while (new_id in switch_ids) // If we somehow reach a state where there's already a conveyor switch with the same ID, we loop through 0 to BYOND's max integer value and check if it is unique.
			src.id = new_id + "[id_disambiguation_number]"
			id_disambiguation_number++

		src.switch_ids += src.id

	MouseDrop_T(dropped, mob/user)
		if (ispulsingtool(dropped))
			if (!istype(dropped, /obj/machinery/conveyor_switch)) return ..()
			var/obj/machinery/conveyor_switch/connected_switch = dropped
			for (var/obj/machinery/conveyor/conveyor in src.conveyors)
				conveyor.id = connected_switch.id
				conveyor.linked_switches += connected_switch

			src.id = connected_switch.id
			connected_switch.conveyors = src.conveyors
			user.show_text("You connect \the [src] to \the [dropped]. Both share the same ID now.", "blue")

		return ..()

	attackby(var/obj/item/I, mob/user)
		if (ispulsingtool(I))
			var/datum/component/mechanics_connector/connector = I.GetComponent(/datum/component/mechanics_connector)
			if (!connector) return ..()
			if (!istype(connector.connectee, /obj/machinery/conveyor_switch)) return ..()

			var/obj/machinery/conveyor_switch/connected_switch = connector.connectee
			src.id = connected_switch.id
			connected_switch.conveyors = src.conveyors
			for (var/obj/machinery/conveyor/conveyor in src.conveyors)
				conveyor.id = connected_switch.id
				conveyor.linked_switches += connected_switch
			user.show_text("You connect \the [src] to \the [connector.connectee]. Both share the same ID now.", "blue")

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

				power_to_use = min ( maxdrain, PN.avail )
				speedup = (power_to_use/maxdrain) * speedup_max

				if (PN.avail > maxdrain)
					power_to_use = min ( maxdrain+bonusdrain, PN.avail )
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
				for(var/obj/machinery/conveyor/C in S.conveyors)
					C.move_lag = max(initial(C.move_lag) - speedup, 0.1)
				break

	update_icon()
		var/ico = clamp(((speedup / speedup_max) * icon_levels), 0, 6)
		icon_state = "[icon_base][round(ico)]"
