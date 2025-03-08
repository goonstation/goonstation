/// metal beam lattices for connecting station parts.
/obj/lattice
	desc = "Intersecting metal rods, used as a structural skeleton for space stations and to facilitate movement in a vacuum."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "lattice"
	density = 0
	stops_space_move = 1
	anchored = ANCHORED
	layer = LATTICE_LAYER
	plane = PLANE_FLOOR
	event_handler_flags = IMMUNE_TRENCH_WARP
	//	flags = CONDUCT
	text = "<font color=#333>+"
	/// bitmask of directions it connects to.
	var/dirmask = 0

	blob_act(var/power)
		if(prob(75))
			qdel(src)
			return

	ex_act(severity)
		src.material_trigger_on_explosion(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				qdel(src)
				return
			if(3)
				return

	proc/replace_with_catwalk(var/obj/item/rods/rods)
		var/turf/T = get_turf(src.loc)
		if (istype(T, /turf/unsimulated))
			return
		if (istype_exact(T, /turf/space))
			T.ReplaceWith(/turf/simulated/floor/airless/plating/catwalk/auto, FALSE, TRUE, FALSE, FALSE)
		T.MakeCatwalk(rods)
		qdel(src)

	attackby(obj/item/C, mob/user)
		if (istype(C, /obj/item/rods))
			var/actionbar_duration = 2 SECONDS

			if (ishuman(user))
				if (user.traitHolder.hasTrait("training_engineer"))
					src.replace_with_catwalk(C)
					return // Engineers can bypass the actionbar and instantly put down catwalks.

				if (user.traitHolder.hasTrait("carpenter"))
					actionbar_duration /= 2

			user.show_text("You start putting the rods together and making a catwalk...", "blue")
			SETUP_GENERIC_ACTIONBAR(user, src, actionbar_duration, /obj/lattice/proc/replace_with_catwalk, list(C), C.icon, C.icon_state, null, null)

		if (istype(C, /obj/item/tile))
			var/obj/item/tile/T = C
			if (T.amount >= 1)
				T.build(get_turf(src))
				playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
				T.add_fingerprint(user)
				qdel(src)
			return
		if (isweldingtool(C) && C:try_weld(user,0))
			boutput(user, SPAN_NOTICE("Slicing lattice joints ..."))
			new /obj/item/rods/steel(src.loc)
			qdel(src)
		return

/// if icon is manually var edited, set dirmask. Else, input temp_dirmask and select the correct icon.
/obj/lattice/New(turf/newLoc, var/temp_dirmask)
	..()
	if (!isnull(temp_dirmask))
		set_dirmask(temp_dirmask)
	else
		update_dirmask_from_icon_state()

/obj/lattice/proc/set_dirmask(dirmask)
	// this horrendous icon arrangement is pretty much random, so dirmask has to be assigned case by case. Horrible.
	// just look at it. Where's the organisation. Who inflicted upon me the need to write shitcode. I demand answers.
	src.dirmask = dirmask
	switch (src.dirmask)
		if (0)
			src.icon_state = "lattice-single"
		if (NORTH | SOUTH | EAST | WEST)
			src.icon_state = "lattice"
		if (SOUTH | EAST | WEST)
			src.icon_state = "lattice-dir"
			src.dir = WEST
		if (NORTH | EAST | WEST)
			src.icon_state = "lattice-dir"
			src.dir = SOUTHWEST
		if (NORTH | SOUTH | WEST)
			src.icon_state = "lattice-dir"
			src.dir = NORTH
		if (NORTH | SOUTH | EAST)
			src.icon_state = "lattice-dir"
			src.dir = SOUTHEAST
		if (NORTHEAST)
			src.icon_state = "lattice-dir-b"
			src.dir = NORTHWEST
		if (NORTH | SOUTH)
			src.icon_state = "lattice-dir"
			src.dir = SOUTH
		if (NORTHWEST)
			src.icon_state = "lattice-dir-b"
			src.dir = NORTHEAST
		if (SOUTHEAST)
			src.icon_state = "lattice-dir-b"
			src.dir = SOUTHEAST
		if (EAST | WEST)
			src.icon_state = "lattice-dir"
			src.dir = EAST
		if (SOUTHWEST)
			src.icon_state = "lattice-dir-b"
			src.dir = SOUTHWEST
		if (NORTH)
			src.icon_state = "lattice-dir-b"
			src.dir = NORTH
		if (SOUTH)
			src.icon_state = "lattice-dir-b"
			src.dir = SOUTH
		if (EAST)
			src.icon_state = "lattice-dir"
			src.dir = NORTHWEST
		if (WEST)
			src.icon_state = "lattice-dir"
			src.dir = NORTHEAST

/obj/lattice/proc/update_dirmask_from_icon_state()
	switch (src.icon_state)
		if ("lattice")
			src.dirmask = (NORTH | SOUTH | EAST | WEST)
		if ("lattice-dir")
			switch(src.dir)
				if (NORTH)	src.dirmask = (NORTH | SOUTH | WEST)
				if (SOUTH)	src.dirmask = (NORTH | SOUTH)
				if (EAST)	src.dirmask = (EAST | WEST)
				if (WEST)	src.dirmask = (SOUTH | EAST | WEST)
				if (NORTHEAST)	src.dirmask = WEST
				if (SOUTHEAST)	src.dirmask = (NORTH | SOUTH | EAST)
				if (SOUTHWEST)	src.dirmask = (NORTH | EAST | WEST)
				if (NORTHWEST)	src.dirmask = EAST
		if ("lattice-dir-b")
			switch(src.dir)
				if (NORTH)	src.dirmask = NORTH
				if (SOUTH)	src.dirmask = SOUTH
				if (EAST)	src.dirmask = (EAST | WEST)
				if (WEST)	src.dirmask = (NORTH | SOUTH)
				if (NORTHEAST)	src.dirmask = (NORTH | WEST)
				if (SOUTHEAST)	src.dirmask = (SOUTH | EAST)
				if (SOUTHWEST)	src.dirmask = (SOUTH | WEST)
				if (NORTHWEST)	src.dirmask = (NORTH | EAST)

/obj/lattice/proc/auto_connect(to_walls = FALSE, to_all_turfs = FALSE, reset_dirmask = TRUE, force_connect = FALSE)
	if(reset_dirmask)
		src.dirmask = 0
	// check for duplicates
	for (var/obj/lattice/auto/self_lattice in src.loc)
		if (self_lattice != src)
			CRASH("Multiple identical lattice spawners on coordinate [src.x], [src.y], [src.z]!")
	// checks for regular lattices around itself (these always connect by default). Only takes ones which 'point' at them.
	for (var/dir_to_l in cardinal)
		for (var/obj/lattice/neigh_lattice in get_step(src, dir_to_l))
			if (neigh_lattice.dirmask & turn(dir_to_l, 180))
				src.dirmask |= dir_to_l
			else if (force_connect)
				neigh_lattice.set_dirmask(neigh_lattice.dirmask | turn(dir_to_l, 180))
				src.dirmask |= dir_to_l
	// connecting to walls
	if (to_walls)
		for (var/dir_to_w in cardinal)
			var/turf/dummy = get_step(src, dir_to_w)
			if (to_all_turfs) // attach to every side which isn't a space turf
				if (!istype(dummy, /turf/space))
					src.dirmask |= dir_to_w
			else if (istype(dummy, /turf/unsimulated/wall) || istype(dummy, /turf/simulated/wall))
				src.dirmask |= dir_to_w
	// now we spawn the new lattice and delete ourselves
	set_dirmask(src.dirmask)

/obj/lattice/set_icon_state(new_state)
	. = ..()
	update_dirmask_from_icon_state()

/obj/lattice/update_icon(...)
	. = ..()
	update_dirmask_from_icon_state()

/// literally only used in 'assets/maps/prefabs/prefab_water_honk.dmm' Why not just use a girder?
/obj/lattice/barricade
	name = "barricade"
	desc = "A lattice that has been turned into a makeshift barricade."
	icon_state = "girder"
	density = 1
	var/strength = 2

	proc/barricade_damage(var/hitstrength)
		strength -= hitstrength
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if (strength < 1)
			src.visible_message("The barricade breaks!")
			if (prob(50)) new /obj/item/rods/steel(src.loc)
			qdel(src)
			return

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			if(W:try_weld(user,1))
				boutput(user, SPAN_NOTICE("You disassemble the barricade."))
				var/obj/item/rods/R = new /obj/item/rods/steel(src.loc)
				R.amount = src.strength
				qdel(src)
				return
		else if (istype(W,/obj/item/rods))
			var/obj/item/rods/R = W
			var/difference = 5 - src.strength
			if (difference <= 0)
				boutput(user, SPAN_ALERT("This barricade is already fully reinforced."))
				return
			if (R.amount >= difference)
				R.change_stack_amount(-difference)
				src.strength = 5
				boutput(user, SPAN_NOTICE("You reinforce the barricade."))
				boutput(user, SPAN_NOTICE("The barricade is now fully reinforced!")) // seperate line for consistency's sake i guess
				return
			else if (R.amount <= difference)
				src.strength += R.amount
				boutput(user, SPAN_NOTICE("You use up the last of your rods to reinforce the barricade."))
				if (src.strength >= 5) boutput(user, SPAN_NOTICE("The barricade is now fully reinforced!"))
				user.u_equip(W)
				qdel(W)
				return
		else
			if (W.force > 8)
				user.lastattacked = get_weakref(src)
				src.barricade_damage(W.force / 8)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
			..()

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2) src.barricade_damage(3)
			if(3) src.barricade_damage(1)
		return

	blob_act(var/power)
		src.barricade_damage(2 * power / 20)

	meteorhit()
		src.barricade_damage(1)

/// a lattice that starts off with icon_state "lattice-dir"
/obj/lattice/directional_icons
	icon_state = "lattice-dir"
/// a lattice that starts off with icon_state "lattice-dir-b"
/obj/lattice/directional_icons_alt
	icon_state = "lattice-dir-b"

/// lattice spawners, for mapping large quantities of lattice at once.
/// They auto connect in four directions depending on the lattices around them, plus you can set them to connect to certain turfs.
/obj/lattice/auto
	dirmask = NORTH | SOUTH | EAST | WEST // so others will connect to us during init
	/// makes the lattices connect to walls too
	var/attach_to_wall = FALSE
	/// makes it attach to all non space turfs
	var/attach_to_all_turfs = FALSE

/// connect to all simulated and unsimulated walls
/obj/lattice/auto/wall_attaching
	attach_to_wall = TRUE

/// connect to all non turf/space turfs
/obj/lattice/auto/turf_attaching
	attach_to_wall = TRUE	// saves us iterating twice over the same thing, neater code further down
	attach_to_all_turfs = TRUE

/obj/lattice/auto/New()
	if(current_state >= GAME_STATE_WORLD_INIT && !src.disposed)
		// this delay in theory lets regular lattices get placed in world first.
		SPAWN(0.1 SECONDS)
			if(!src.disposed)
				initialize()
	..()

/// checks around itself for spots to connect to, creates a new lattice, then qdels itself.
/obj/lattice/auto/initialize()
	. = ..()
	auto_connect(attach_to_wall, attach_to_all_turfs)
