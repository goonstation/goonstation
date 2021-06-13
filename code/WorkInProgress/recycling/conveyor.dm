// converyor belt

// moves items/mobs/movables in set direction every ptick


/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
#ifndef IN_MAP_EDITOR
	icon_state = "conveyor0"
#else
	icon_state = "conveyor0-map"
#endif
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1
	power_usage = 100
	layer = 2
	machine_registry_idx = MACHINES_CONVEYORS
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/welded = TRUE 	// newly constructed conveyors need welding before being operational
	var/startdir = null // the default direction
	var/altdir = null	 // the reverse direction

	var/id = ""			// the control ID	- must match controller ID
	// following two only used if a diverter is present
	var/divert = 0 		// if non-zero, direction to divert items
	var/divdir = 0		// if diverting, will be conveyer dir needed to divert (otherwise dense)
	var/move_lag = 4	// The lag at which the movement happens. Lower = faster
	var/obj/machinery/conveyor/next_conveyor = null
	var/obj/machinery/conveyor_switch/owner = null
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH


/obj/machinery/conveyor/north
	startdir = NORTH
	altdir = SOUTH
/obj/machinery/conveyor/south
	startdir = SOUTH
	altdir = NORTH
/obj/machinery/conveyor/east
	startdir = EAST
	altdir = WEST
/obj/machinery/conveyor/west
	startdir = WEST
	altdir = EAST
/*
/obj/machinery/conveyor/constructed
	New()
		. = ..()
		SPAWN_DBG(0.5 SECONDS) // construction takes a bit to set the dir right >.>
			src.connect_to_nearby()
*/

/obj/machinery/conveyor/New()
	..()
	if(!src.startdir)
		src.startdir = src.dir
	if(!src.altdir)
		src.altdir = turn(src.dir, 180)
	setdir()
	UnsubscribeProcess()

/obj/machinery/conveyor/initialize()
	..()
	setdir()

/obj/machinery/conveyor/disposing()
	for(var/obj/machinery/conveyor/C in range(1,src))
		if (C.next_conveyor == src)
			C.next_conveyor = null
	next_conveyor = null

	if (owner) //conveyor switch could've been exploded
		owner.conveyors -= src
	..()

// called when constructed via mechanics or via conveyor parts
/obj/machinery/conveyor/proc/connect_to_nearby()
	// needs to be done again since new() is run before the frame deployment sets the direction
	src.startdir = dir
	src.altdir = turn(dir, 180)
	// get adjacent conveyors, try to find one that leads into us, one that leads away from us
	// then make us point in those directions, to make things easier
	// also copy switch settings if we find at least one!
	var/list/obj/machinery/conveyor/near_conveyors = list(locate(/obj/machinery/conveyor) in get_step(src,turn(startdir, 180)),
	locate(/obj/machinery/conveyor) in get_step(src,startdir),
	locate(/obj/machinery/conveyor) in get_step(src,turn(startdir, -90)),
	locate(/obj/machinery/conveyor) in get_step(src,turn(startdir, 90)))
	var/obj/machinery/conveyor/prev_conveyor
	var/obj/machinery/conveyor/next_conveyor
	for(var/obj/machinery/conveyor/cur_conveyor as() in near_conveyors)
		if(!cur_conveyor)
			continue
		if(get_step(cur_conveyor.loc, cur_conveyor.startdir) == src.loc)
			prev_conveyor = cur_conveyor
			break
	for(var/obj/machinery/conveyor/cur_conveyor as() in near_conveyors)
		if(!cur_conveyor)
			continue
		if(get_step(cur_conveyor.loc, cur_conveyor.altdir) == src.loc)
			next_conveyor = cur_conveyor
			break

	if(prev_conveyor)
		src.altdir = get_dir(src, prev_conveyor)
	if(next_conveyor)
		src.startdir = get_dir(src, next_conveyor)
	setdir()

	var/obj/machinery/conveyor/settings_conveyor = prev_conveyor ? prev_conveyor : next_conveyor ? next_conveyor : null
	if(settings_conveyor)
		src.operating = settings_conveyor.operating
		src.update()
		if(settings_conveyor.owner)
			src.owner = settings_conveyor.owner
			src.owner.conveyors += src


/obj/machinery/conveyor/was_built_from_frame(mob/user, newly_built)
	src.connect_to_nearby()

/obj/machinery/conveyor/was_deconstructed_to_frame(mob/user)
	src.owner.conveyors -= src
	src.owner = null
	src.operating = 0

/obj/machinery/conveyor/MouseDrop(obj/copyobj, null)
	var/mob/living/user = usr
	if (!istype(user))
		return
	if (user.stat)
		return
	if (!user.find_tool_in_hand(TOOL_PULSING))
		boutput(usr, "<span class='alert'>You need a multitool to link conveyor belts to levers!</span>")
		return
	var/obj/machinery/conveyor_switch/newswitch
	if (istype(copyobj, /obj/machinery/conveyor_switch))
		newswitch = copyobj
	else if(istype(copyobj, /obj/machinery/conveyor))
		var/obj/machinery/conveyor/conv = copyobj
		newswitch = conv.owner
	if(newswitch)
		src.connect_to_switch(newswitch)
		boutput(usr, "<span class='notice'>You connect the [src] to the [newswitch].</spawn>")

// set the dir and target turf depending on the operating direction
/obj/machinery/conveyor/proc/setdir()
	if(operating == -1)
		set_dir(altdir)
	else
		set_dir(startdir)
	next_conveyor = locate(/obj/machinery/conveyor) in get_step(src,dir)
	update()


	// update the icon depending on the operating condition

/obj/machinery/conveyor/proc/update()
	if(status & BROKEN)
		icon_state = "conveyor-b"
		operating = 0

	if(!operable || !welded)
		operating = 0
	if(!operating || (status & NOPOWER))
		for(var/atom/movable/A in loc.contents)
			walk(A, 0)
	else
		for(var/atom/movable/A in loc.contents)
			move_thing(A)

	// find bendy direction
	var/angle_dir = dir2angle(src.altdir) - dir2angle(src.startdir)
	if(angle_dir < 0)
		angle_dir += 360
	// reverse in case of reverse
	if(operating == -1)
		angle_dir = 360 - angle_dir
	// 270 means left, 90 means right, 180 means straight, 0 means hypothetical stupid conveyor that goes back to where it comes from
	var/bendy_dir = ""
	if(angle_dir == 270)
		bendy_dir = "left"
	else if(angle_dir == 90)
		bendy_dir = "right"


	icon_state = "conveyor[bendy_dir][(operating != 0) && !(status & NOPOWER)]"


/obj/machinery/conveyor/proc/move_thing(var/atom/movable/A)
	if (A.anchored)
		return
	if(isobserver(A))
		return
	if(istype(A, /obj/machinery/bot) && A:on)	//They drive against the motion of the conveyor, ok.
		return
	if(istype(A, /obj/critter) && A:flying)		//They are flying above it, ok.
		return
	var/movedir = dir	// base movement dir
	if(divert && dir == divdir)	// update if diverter present
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

/obj/machinery/conveyor/HasEntered(var/atom/movable/AM, atom/oldloc)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating || !welded)
		return
	if(!loc)
		return
	move_thing(AM)

/obj/machinery/conveyor/HasExited(var/atom/movable/AM, var/atom/newloc)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating || !welded)
		return
	if(!loc)
		return

	if(src.next_conveyor && src.next_conveyor.loc == newloc)
		//Ok, they will soon walk() according to the new conveyor
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Transfer the buckle
			M.buckled = next_conveyor
		if(!next_conveyor.operating)
			walk(AM, 0)
			return

	else
		//Stop walking, we left the belt
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Unbuckle
			M.buckled = null
			new /obj/item/cable_coil/cut(M.loc)
		walk(AM, 0)


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
	else if (iswrenchingtool(I))
		if(src.welded)
			boutput(user, "<span class='alert'>You can't modify the conveyor belt while it is welded to the floor!</span>")
		else
			src.startdir = turn(src.startdir, -90)
			src.setdir()
	else if (isscrewingtool(I))
		if(src.welded)
			boutput(user, "<span class='alert'>You can't modify the conveyor belt while it is welded to the floor!</span>")
		else
			src.altdir = turn(src.altdir, -90)
			src.setdir()
	else if (isweldingtool(I))
		if(I:try_weld(user, 1))
			src.welded = !src.welded
			if(src.welded)
				boutput(user, "<span class='notice'>You weld the conveyor belt to the floor. It is now operable.</span>")
			else
				boutput(user, "<span class='notice'>You unweld the conveyor belt from the floor. It can now be modified.</span>")

// attack with hand, move pulled object onto conveyor

/obj/machinery/conveyor/attack_hand(mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.pulling = null
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.pulling = null
	return


// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	status |= BROKEN
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, startdir)
	C?.set_operable(startdir, id, 0)

	C = locate() in get_step(src, altdir)
	if(C)
		C.set_operable(altdir, id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	..()
	update()

/obj/machinery/conveyor/proc/connect_to_switch(var/obj/machinery/conveyor_switch/newswitch)
	if(!newswitch)
		return
	if(src.owner) // remove from old switch and add to new one
		src.owner.conveyors -= src
	src.owner = newswitch
	newswitch.conveyors |= src

/obj/item/conveyor_parts
	name = "conveyor parts"
	desc = "A collection of parts that can be used to construct a conveyor belt. They will need to be welded before being operational."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_parts"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT
	stamina_damage = 35
	stamina_cost = 22
	stamina_crit_chance = 10

	amount = 10
	max_stack = 50
	inventory_counter_enabled = 1
	stack_type = /obj/item/conveyor_parts
	var/move_laying = FALSE									// do we lay conveyors when moving?
	var/obj/machinery/conveyor_switch/connect_switch = null // switch to automatically connect new belts to

/obj/item/conveyor_parts/proc/consumeConveyors(var/amount, var/mob/M)
	src.change_stack_amount(-amount)
	if (src.amount <= 0)
		UnregisterSignal(M, COMSIG_MOVABLE_MOVED)
		src.move_laying = FALSE
		if (M)
			boutput(M, "<span class='alert'>Your conveyor parts run out!</span>")


/obj/item/conveyor_parts/proc/placeConveyor(mob/M, newLoc)
	var/obj/machinery/conveyor/C = new /obj/machinery/conveyor(newLoc)
	C.set_dir(M.dir)
	C.connect_to_nearby()
	if(connect_switch)
		C.connect_to_switch(connect_switch)
	C.welded = FALSE
	C.deconstruct_flags = DECON_NONE
	src.consumeConveyors(1, M)

/obj/item/conveyor_parts/proc/walkConveyors(mob/M, newLoc, direct)
	var/obj/machinery/conveyor/C = locate() in newLoc
	if(!C) // no conveyor where we are moving, so we can place one!
		src.placeConveyor(M, newLoc)

/obj/item/conveyor_parts/attack_self(mob/M)
	if (istype(M))
		if (src.move_laying)
			src.move_laying = FALSE
			UnregisterSignal(M, COMSIG_MOVABLE_MOVED)
			boutput(M, "<span class='notice'>No longer laying the cable while moving.</span>")
		else
			src.move_laying = TRUE
			RegisterSignal(M, COMSIG_MOVABLE_MOVED, .proc/walkConveyors)
			boutput(M, "<span class='notice'>Now laying cable while moving.</span>")

/obj/item/conveyor_parts/afterattack(atom/target, mob/M, reach, params)
	if(istype(target, /obj/machinery/conveyor_switch))
		src.connect_switch = target
	else if(istype(target, /turf/))
		src.placeConveyor(M, target)

/obj/item/conveyor_parts/before_stack(atom/movable/O as obj, mob/user as mob)
	user.visible_message("<span class='notice'>[user] begins collecting conveyor parts!</span>")

/obj/item/conveyor_parts/after_stack(atom/movable/O as obj, mob/user as mob, var/added)
	boutput(user, "<span class='notice'>You finish stacking the conveyor parts.</span>")

// converyor diverter
// extendable arm that can be switched so items on the conveyer are diverted sideways
// situate in same turf as conveyor
// only works if belts is running proper direction
//
//
/obj/machinery/diverter
	icon = 'icons/obj/recycling.dmi'
	icon_state = "diverter0"
	name = "diverter"
	desc = "A diverter arm for a conveyor belt."
	anchored = 1
	layer = FLY_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT
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
	SPAWN_DBG(0.2 SECONDS)
		// wait for map load then find the conveyor in this turf
		conv = locate() in src.loc
		if(conv)	// divert_from dir must match possible conveyor movement
			if(conv.startdir != divert_from && conv.startdir != turn(divert_from,180) )
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
/obj/machinery/diverter/CanPass(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == divert_to)	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != turn(divert_from,180))

// don't allow movement through the arm if deployed
/obj/machinery/diverter/CheckExit(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == turn(divert_to,180))	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != divert_from)

// running counter for new conveyor switch network ids
var/static/conv_network_id = 10000

// the conveyor control switch
//
//
/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated

	var/id = "" 				// must match conveyor IDs to control them

	var/list/conveyors		// the list of converyors that are controlled by this switch
	anchored = 1
	mats = 8
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL


/obj/machinery/conveyor_switch/New()
	..()
	START_TRACKING
	update()

	SPAWN_DBG(0.5 SECONDS)		// allow map load
		conveyors = list()
		if(id != "")
			for(var/obj/machinery/conveyor/C as anything in machine_registry[MACHINES_CONVEYORS])
				if(C.id == id)
					conveyors += C
					C.owner = src

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", "trigger")

/obj/machinery/conveyor_switch/disposing()
	STOP_TRACKING
	for(var/obj/machinery/conveyor/C in conveyors)
		C.owner = null
	conveyors = null
	..()

// click drag to connect conveyors or link with other switches using multitool
/obj/machinery/conveyor_switch/MouseDrop(obj/copyobj, null)
	var/mob/living/user = usr
	if (!istype(user))
		return
	if (user.stat)
		return
	if (!user.find_tool_in_hand(TOOL_PULSING))
		boutput(usr, "<span class='alert'>You need a multitool to link conveyor belts to levers!</span>")
		return
	var/obj/machinery/conveyor/conveyor
	if(istype(copyobj, /obj/machinery/conveyor)) // connect conveyor to this switch
		var/obj/machinery/conveyor/conv = copyobj
		conv.connect_to_switch(src)
		boutput(usr, "<span class='notice'>You connect the [conv] to the [src].</spawn>")
	else if(istype(copyobj, /obj/machinery/conveyor_switch) && copyobj != src) // form or join network with other switch
		var/obj/machinery/conveyor_switch/otherswitch = copyobj
		var/network = src.id
		if (otherswitch.id != "")
			network = otherswitch.id
		if (network) // at least one of the switches has a network, the one you drag from is dominant if both have one, I guess
			src.id = network
			otherswitch.id = network
		else // make new network
			src.id = "conveyornet [conv_network_id]"
			otherswitch.id = "conveyornet [conv_network_id]"
			conv_network_id++

// reset network using multitool
/obj/machinery/conveyor_switch/attackby(obj/item/I, mob/user)
	if(istool(I, TOOL_PULSING))
		var/confirm = alert("Reset the [src]'s network settings?", "Reset Switch", "Yes", "No")
		if(confirm == "Yes")
			src.id = ""
			boutput(user, "<span class='notice'>You reset the [src]'s network settings using the [I].")

/obj/machinery/conveyor_switch/was_deconstructed_to_frame(mob/user)
	for(var/obj/machinery/conveyor/C as() in conveyors)
		C.owner = null
	src.conveyors = list()
	src.id = ""

/obj/machinery/conveyor_switch/proc/trigger(var/inp)
	attack_hand(usr) //bit of a hack but hey.
	return

// update the icon depending on the position

/obj/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

/obj/machinery/conveyor_switch/proc/update_conveyors()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in conveyors)
		C.operating = position
		C.setdir()

// timed process
// if the switch changed, update the linked conveyors
/obj/machinery/conveyor_switch/process()
	src.update_conveyors()


// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	if(position == 0)
		if(last_pos < 0)
			position = 1
			last_pos = 0
		else
			position = -1
			last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update()

	// find any switches with same id as this one, and set their positions to match us
	if(id != "")
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if(S.id == src.id)
				S.position = position
				S.update()
			LAGCHECK(LAG_MED)

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"switchTriggered")

	if(!ON_COOLDOWN(src, "INSTANT_SWITCH_1", 1 SECOND) || !ON_COOLDOWN(src, "INSTANT_SWITCH_2", 1 SECOND))
		src.update_conveyors()

//silly proc for corners that can be flippies
/obj/machinery/conveyor/proc/rotateme()
	.= 0


//for ease of mapping
/obj/machinery/conveyor/oshan_carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1

/obj/machinery/conveyor/oshan_carousel/northeast
	startdir = NORTH
	altdir = EAST

/obj/machinery/conveyor/oshan_carousel/northwest
	startdir = NORTH
	altdir = WEST

/obj/machinery/conveyor/oshan_carousel/southeast
	startdir = SOUTH
	altdir = EAST

/obj/machinery/conveyor/oshan_carousel/southwest
	startdir = SOUTH
	altdir = WEST

/obj/machinery/conveyor/oshan_carousel/westsouth
	startdir = WEST
	altdir = SOUTH

/obj/machinery/conveyor/oshan_carousel/westnorth
	startdir = WEST
	altdir = NORTH

/obj/machinery/conveyor/oshan_carousel/eastsouth
	startdir = EAST
	altdir = SOUTH

/obj/machinery/conveyor/oshan_carousel/eastnorth
	startdir = EAST
	altdir = NORTH




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
	anchored = 1
	event_handler_flags = USE_CANPASS | USE_FLUID_ENTER

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
			update_icon()

	proc/update_belts()
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if(S.id == "carousel")
				for(var/obj/machinery/conveyor/C in S.conveyors)
					C.move_lag = max(initial(C.move_lag) - speedup, 0.1)
				break

	proc/update_icon()
		var/ratio = speedup / speedup_max
		var/ico = min(ratio, speedup_max) * icon_levels
		icon_state = "[icon_base][ratio > 1 ? "bonus" : round(ico)]"
