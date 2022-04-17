// the cable coil object, used for laying cable

// Contains reinforced and red (default) cables, the other colours of cable are generated through weird-but-cool #define bullshit in cablecolors.dm

obj/item/cable_coil/abilities = list(/obj/ability_button/cable_toggle)

#define STARTCOIL 30 //base type starting coil amt
/obj/item/cable_coil
	name = "cable coil"
	var/base_name = "cable coil"
	desc = "A coil of power cable."
	amount = STARTCOIL
	max_stack = 120
	stack_type = /obj/item/cable_coil // so cut cables can stack with partially depleted full coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	var/iconmod = null
	var/namemod = null
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "coil"
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 2
	throw_range = 5
	flags = TABLEPASS|EXTRADELAY|FPRINT|CONDUCT|ONBELT
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 10
	rand_pos = 1
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab
	inventory_counter_enabled = 1

	var/datum/material/insulator = null
	var/datum/material/conductor = null

	var/cable_obj_type = /obj/cable
	var/currently_laying = FALSE

	// will use getMaterial() to apply these at spawn
	var/spawn_insulator_name = "synthrubber"
	var/spawn_conductor_name = "copper"

	New(loc, length = STARTCOIL)
		src.amount = length
		pixel_x = rand(-2,2)
		pixel_y = rand(-2,2)
		UpdateIcon()
		..(loc)
		if (spawn_conductor_name)
			applyCableMaterials(src, getMaterial(spawn_insulator_name), getMaterial(spawn_conductor_name))
		BLOCK_SETUP(BLOCK_ROPE)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins coiling cable!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish coiling cable.</span>")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] wraps the cable around \his neck and tightens it.</b></span>")
		user.take_oxygen_deprivation(160)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/setInsulator(var/datum/material/M)
		if (!M)
			return
		insulator = M
		applyCableMaterials(src, M, conductor)

	proc/setConductor(var/datum/material/M)
		if (!M)
			return
		conductor = M
		applyCableMaterials(src, insulator, M)

	proc/updateName()
		if (!conductor)
			return
		if (insulator)
			name = "[insulator.name]-insulated [conductor.name]-[base_name]"
		else
			name = "uninsulated [conductor.name]-[base_name]"

	proc/use(var/used)
		if (src.amount < used)
			return 0
		amount -= used
		if (src.amount <= 0)
			qdel(src)
			return 1
		else
			UpdateIcon()
			return 1

	update_stack_appearance()
		update_icon()

	update_icon()
		if (amount <= 0)
			qdel(src)
		else if (amount >= 1 && amount <= 4)
			set_icon_state("coil[amount][iconmod]")
			base_name = "[namemod]cable piece"
		else if (amount > STARTCOIL * 1.5)
			set_icon_state("coilbig[iconmod]")
			base_name = "[namemod]cable coil"
		else
			set_icon_state("coil[iconmod]")
			base_name = "[namemod]cable coil"
		updateName()
		inventory_counter?.update_number(amount)


/obj/item/cable_coil/cut
	icon_state = "coil2"
	New(loc, length)
		if (length)
			..(loc, length)
		else
			..(loc, rand(1,2))

/obj/item/cable_coil/cut/small
	New(loc, length)
		..(loc, rand(1,5))

/////////////////////////////////////////////////REINFORCED CABLE


/obj/item/cable_coil/reinforced
	name = "reinforced cable coil"
	base_name = "reinforced cable coil"
	desc = "A coil of reinforced power cable."
	icon_state = "coil-thick"
	stack_type = /obj/item/cable_coil/reinforced
	namemod = "reinforced "
	iconmod = "-thick"

	spawn_insulator_name = "synthblubber"
	spawn_conductor_name = "pharosium"

	cable_obj_type = /obj/cable/reinforced

	New(loc, length = max_stack)
		..(loc, length)

/obj/item/cable_coil/reinforced/cut
	icon_state = "coil2-thick"
	New(loc, length)
		if (length)
			..(loc, length)
		else
			..(loc, rand(1,2))

/obj/item/cable_coil/reinforced/cut/small
	New(loc, length)
		..(loc, rand(1,5))


/////////////////////////////////////////////////REINFORCED CABLE

/obj/item/cable_coil/attack_self(var/mob/living/M)
	if (currently_laying)
		UnregisterSignal(M, COMSIG_MOVABLE_MOVED)
		boutput(M, "<span class='notice'>No longer laying the cable while moving.</span>")
	else
		RegisterSignal(M, COMSIG_MOVABLE_MOVED, .proc/move_callback)
		boutput(M, "<span class='notice'>Now laying cable while moving.</span>")
	currently_laying = !currently_laying

obj/item/cable_coil/dropped(mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	currently_laying = FALSE
	..()

/proc/find_half_cable(var/turf/T, var/ignore_dir)
	for (var/obj/cable/C in T)
		if (!C.d1 && C.d2 != ignore_dir)
			return C

/obj/item/cable_coil/move_callback(var/mob/living/M, var/turf/target)
	if (!istype(M))
		return
	if (!isturf(M.loc))
		return
	var/turf/source = M.loc //the signal doesn't give the source location but it gets sent before the mob actually transfers turfs so this works fine

	var/obj/cable/C = find_half_cable(source, get_dir(source, target))
	if (C)
		cable_join(C, target, M, FALSE)
	else
		turf_place(source, target, M)

	if (src.disposed) //AKA 0 coil left
		boutput(M, "<span class='alert'>Your cable coil runs out!</span>")
		return

	C = find_half_cable(target, get_dir(target, source))

	if (C)
		cable_join(C, source, M, FALSE)
	else
		turf_place(target, source, M)

	if (src.disposed)
		boutput(M, "<span class='alert'>Your cable coil runs out!</span>")
		return

/obj/item/cable_coil/examine()
	if (amount == 1)
		. = list("A short piece of [base_name].")
	else
		. = list("A coil of [base_name]. There's [amount] length[s_es(amount)] of cable in the coil.")

	if (insulator)
		. += "It is insulated with [insulator]."
	if (conductor)
		. += "Its conductive layer is made out of [conductor]."

/obj/item/cable_coil/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && src.amount > 1)
		var/obj/item/cable_coil/A = split_stack(round(input("How long of a wire do you wish to cut?","Length of [src.amount]",1) as num))
		if (istype(A))
			A.set_loc(user.loc) //Hey, split_stack, Why is the default location for the new item src.loc which is *very likely* to be a damn mob?
			boutput(user, "You cut a piece off the [base_name].")
		return

	if (check_valid_stack(W))
		stack_item(W)
		if(!user.is_in_hands(src))
			user.put_in_hand(src)
		boutput(user, "You join the cable coils together.")

/obj/item/cable_coil/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..(O, user)
	for (var/obj/item/cable_coil/C in view(1, user))
		C.UpdateIcon()

// Placing a cable on a turf
/obj/item/cable_coil/proc/turf_place(turf/target, turf/source, mob/user)
	if (target.intact)		// if floor is intact, complain
		return
	if (!(istype(target,/turf/simulated/floor) || istype(target,/turf/space/fluid)))
		return
	if (!(istype(source,/turf/simulated/floor) || istype(source,/turf/space/fluid)))
		return
	if (get_dist(target, source) > 1)
		boutput(user, "You can't lay cable at a place that far away.")
		return

	var/dirn
	if (target == source)
		dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
	else
		dirn = get_dir(target, source)

	for (var/obj/cable/LC in target)
		if (LC.d1 == dirn || LC.d2 == dirn)
			return

	plop_a_cable(target, user, 0, dirn)
	return

// called when cable_coil is clicked on an installed obj/cable or auto-laying found a stub to connect to
/obj/item/cable_coil/proc/cable_join(obj/cable/C, turf/source, mob/user, attempt_at_source)
	var/turf/target = C.loc
	if (!isturf(target) || target.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return
	if (get_dist(C, user) > 1)		// make sure it's close enough
		boutput(user, "You can't lay cable at a place that far away.")
		return
	if (source == target)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, source)

	//Okay so this code branch tries to connect C on the turf you're standing on, for when you slap an obj/cable by hand
	//Auto-laying cable doesn't need it because that attempts to put a cable on both turfs anyway
	if (attempt_at_source && (C.d1 == dirn || C.d2 == dirn))		// one end of the clicked cable is pointing towards us
		if (source.intact)						// can't place a cable if the floor is complete
			boutput(user, "You can't lay cable there unless the floor tiles are removed.")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for (var/obj/cable/LC in source)		// check to make sure there's not a cable there already
				if (LC.d1 == fdirn && LC.d2 == fdirn)
					boutput(user, "There's already a cable at that position.")
					return

			plop_a_cable(source, user, 0, fdirn)
			C.shock(user, 25)
			return

	else if (C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = min(C.d2, dirn)	// these will be the new directions
		var/nd2 = max(C.d2, dirn)

		for (var/obj/cable/LC in target)		// check to make sure there's no matching cable
			if (LC == C)			// skip the cable we're interacting with
				continue
			if ((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				boutput(user, "There's already a cable at that position.")
				return
		C.shock(user, 25)
		qdel(C)
		plop_a_cable(target, user, nd1, nd2)
		return

///This was copy-pasted some 5 times across the 4 cable laying procs that existed) FSR?
obj/item/cable_coil/proc/plop_a_cable(turf/overthere, mob/user, dir1, dir2)
	var/obj/cable/NC = new cable_obj_type(overthere, src)
	applyCableMaterials(NC, src.insulator, src.conductor)
	NC.d1 = dir1
	NC.d2 = dir2
	NC.add_fingerprint()
	NC.update_icon()
	NC.update_network()
	NC.log_wirelaying(user)
	src.use(1)
