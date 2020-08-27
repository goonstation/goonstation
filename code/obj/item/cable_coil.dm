// the cable coil object, used for laying cable

obj/item/cable_coil/abilities = list(/obj/ability_button/cable_toggle)

#define MAXCOIL 120
#define STARTCOIL 30 //base type starting coil amt
/obj/item/cable_coil
	name = "cable coil"
	var/base_name = "cable coil"
	desc = "A coil of power cable."
	amount = STARTCOIL
	max_stack = MAXCOIL
	stack_type = /obj/item/cable_coil // so cut cables can stack with partially depleted full coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	var/iconmod = null
	var/namemod = null
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "coil"
	throwforce = 2
	w_class = 1.0
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

	// will use getMaterial() to apply these at spawn
	var/spawn_insulator_name = "synthrubber"
	var/spawn_conductor_name = "copper"

	New(loc, length = STARTCOIL)
		src.amount = length
		pixel_x = rand(-2,2)
		pixel_y = rand(-2,2)
		updateicon()
		..(loc)
		if (spawn_conductor_name)
			applyCableMaterials(src, getMaterial(spawn_insulator_name), getMaterial(spawn_conductor_name))
		BLOCK_ROPE

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
		SPAWN_DBG(50 SECONDS)
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
		else if (src.amount == used)
			qdel(src)
			return 1
		else
			amount -= used
			updateicon()
			return 1

	proc/take(var/amt, var/newloc)
		if (amt > amount)
			amt = amount
		if (amt == amount)
			if (ismob(loc))
				var/mob/owner = loc
				owner.u_equip(src)
			set_loc(newloc)
			return src
		src.use(amt)
		var/obj/item/cable_coil/C = new /obj/item/cable_coil(newloc)
		C.amount = amt
		C.updateicon()
		C.setInsulator(insulator)
		C.setConductor(conductor)

	proc/updateicon()
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

	New(loc, length = MAXCOIL)
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
	if (istype(M))
		if (M.move_laying)
			M.move_laying = null
			boutput(M, "<span class='notice'>No longer laying the cable while moving.</span>")
		else
			M.move_laying = src
			boutput(M, "<span class='notice'>Now laying cable while moving.</span>")

/obj/proc/move_callback(var/mob/M, var/turf/source, var/turf/target)
	return

/proc/find_half_cable(var/turf/T, var/ignore_dir)
	for (var/obj/cable/C in T)
		if (!C.d1 && C.d2 != ignore_dir)
			return C

/obj/item/cable_coil/move_callback(var/mob/living/M, var/turf/source, var/turf/target)
	if (!istype(M))
		return
	if (!src.amount)
		M.move_laying = null
		boutput(M, "<span class='alert'>Your cable coil runs out!</span>")
		return
	var/obj/cable/C

	C = find_half_cable(source, get_dir(source, target))
	if (C)
		cable_join_between(C, target)
	else
		turf_place_between(source, target)

	if (!src.amount)
		M.move_laying = null
		boutput(M, "<span class='alert'>Your cable coil runs out!</span>")
		return

	C = find_half_cable(target, get_dir(target, source))

	if (C)
		cable_join_between(C, source)
	else
		turf_place_between(target, source)

	if (!src.amount)
		M.move_laying = null
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
		src.amount--
		take(1, usr.loc)
		boutput(user, "You cut a piece off the [base_name].")
		src.updateicon()
		return

	else if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/C = W
		if (C.conductor.mat_id != src.conductor.mat_id || C.insulator.mat_id != src.insulator.mat_id)
			boutput(user, "You cannot link together cables made from different materials. That would be silly.")
			return

		if (C.amount == MAXCOIL)
			boutput(user, "The coil is too long, you cannot add any more cable to it.")
			return

		if ((C.amount + src.amount <= MAXCOIL))
			C.amount += src.amount
			boutput(user, "You join the cable coils together.")
			C.updateicon()
			if(istype(src.loc, /obj/item/storage))
				var/obj/item/storage/storage = src.loc
				storage.hud.remove_object(src)
			else if(istype(src.loc, /mob))
				var/mob/M = src.loc
				M.u_equip(src)
				M.drop_item(src)
			qdel(src)
			return

		else
			boutput(user, "You transfer [MAXCOIL - src.amount ] length\s of cable from one coil to the other.")
			src.amount -= (MAXCOIL-C.amount)
			src.updateicon()
			C.amount = MAXCOIL
			C.updateicon()
			return

/obj/item/cable_coil/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..(O, user)
	for (var/obj/item/cable_coil/C in view(1, user))
		C.updateicon()

// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/cable_coil/proc/turf_place_between(turf/A, turf/B)
	if (!(istype(A,/turf/simulated/floor) || istype(A,/turf/space/fluid)))
		return
	if (!isturf(B) || !(istype(B,/turf/simulated/floor) || istype(B,/turf/space/fluid)))
		return
	if (get_dist(A, B) > 1)
		return
	if (A.intact)
		return

	var/dirn = get_dir(A, B)
	for (var/obj/cable/C in A)
		if (C.d1 == dirn || C.d2 == dirn)
			return
	var/obj/cable/NC = new cable_obj_type(A, src)

	applyCableMaterials(NC, src.insulator, src.conductor)
	NC.d1 = 0
	NC.d2 = dirn
	NC.updateicon()
	NC.update_network()
	NC.log_wirelaying(usr)
	src.use(1)
	return

/obj/item/cable_coil/proc/cable_join_between(var/obj/cable/C, var/turf/B)
	if (!isturf(B) || !(istype(B,/turf/simulated/floor) || istype(B,/turf/space/fluid)))
		return

	var/turf/T = C.loc

	if (!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if (get_dist(C, B) > 1)		// make sure it's close enough
		return

	if (B == T)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, B)

	if (C.d1 == 0)			// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn

		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if (nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for (var/obj/cable/LC in T)		// check to make sure there's no matching cable
			if (LC == C)			// skip the cable we're interacting with
				continue
			if ((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				return
		qdel(C)
		var/obj/cable/NC = new cable_obj_type(T, src)
		applyCableMaterials(NC, src.insulator, src.conductor)
		NC.d1 = nd1
		NC.d2 = nd2
		NC.updateicon()
		NC.update_network()
		NC.log_wirelaying(usr)
		src.use(1)
	return

/obj/item/cable_coil/proc/turf_place(turf/F, mob/user)
	if (!isturf(user.loc))
		return

	if (!(istype(F,/turf/simulated/floor) || istype(F,/turf/space/fluid)))
		return

	if (get_dist(F,user) > 1)
		boutput(user, "You can't lay cable at a place that far away.")
		return

	if (F.intact)		// if floor is intact, complain
		boutput(user, "You can't lay cable there unless the floor tiles are removed.")
		return

	else
		var/dirn

		if (user.loc == F)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)

		for (var/obj/cable/LC in F)
			if (LC.d1 == dirn || LC.d2 == dirn)
				boutput(user, "There's already a cable at that position.")
				return

		var/obj/cable/C = new cable_obj_type(F, src)
		C.d1 = 0
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()
		C.update_network()
		applyCableMaterials(C, src.insulator, src.conductor)
		C.log_wirelaying(user)
		src.use(1)
	return

// called when cable_coil is click on an installed obj/cable
/obj/item/cable_coil/proc/cable_join(obj/cable/C, mob/user)
	var/turf/U = user.loc
	if (!isturf(U))
		return

	var/turf/T = C.loc

	if (!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if (get_dist(C, user) > 1)		// make sure it's close enough
		boutput(user, "You can't lay cable at a place that far away.")
		return

	if (U == T)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, user)

	if (C.d1 == dirn || C.d2 == dirn)		// one end of the clicked cable is pointing towards us
		if (U.intact)						// can't place a cable if the floor is complete
			boutput(user, "You can't lay cable there unless the floor tiles are removed.")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for (var/obj/cable/LC in U)		// check to make sure there's not a cable there already
				if (LC.d1 == fdirn && LC.d2 == fdirn)
					boutput(user, "There's already a cable at that position.")
					return

			var/obj/cable/NC = new cable_obj_type(U, src)
			applyCableMaterials(NC, src.insulator, src.conductor)
			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()
			NC.update_network()
			NC.log_wirelaying(user)
			src.use(1)
			C.shock(user, 25)
			return

	else if (C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn

		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if (nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for (var/obj/cable/LC in T)		// check to make sure there's no matching cable
			if (LC == C)			// skip the cable we're interacting with
				continue
			if ((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				boutput(user, "There's already a cable at that position.")
				return
		C.shock(user, 25)
		qdel(C)
		var/obj/cable/NC = new cable_obj_type(T, src)
		applyCableMaterials(NC, src.insulator, src.conductor)
		NC.d1 = nd1
		NC.d2 = nd2
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()
		NC.log_wirelaying(user)
		src.use(1)
		return
