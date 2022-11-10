/turf/simulated/wall
	name = "wall"
	desc = "Looks like a regular wall."
	icon = 'icons/turf/walls.dmi'
#ifndef IN_MAP_EDITOR // display disposal pipes etc. above walls in map editors
	plane = PLANE_WALL
#else
	plane = PLANE_FLOOR
#endif
	opacity = 1
	density = 1
	gas_impermeable = 1
	pathable = 1
	flags = ALWAYS_SOLID_FLUID
	text = "<font color=#aaa>#"

	/// The material name (string) that this will default to if a material is not otherwise set
	var/default_material = "steel"
	var/health = 100
	var/list/forensic_impacts = null
	var/last_proj_update_time = null

	New()
		..()
		var/obj/plan_marker/wall/P = locate() in src
		if (P)
			P.check()

		src.AddComponent(/datum/component/bullet_holes, 15, 10)

		src.selftilenotify() // displace fluid

		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
			xmasify()
		#endif

		if(!src.material)
			src.setMaterial(getMaterial(src.default_material), appearance = FALSE, setname = FALSE, copy = FALSE)


	ReplaceWithFloor()
		. = ..()
		if (map_currently_underwater)
			var/turf/space/fluid/n = get_step(src,NORTH)
			var/turf/space/fluid/s = get_step(src,SOUTH)
			var/turf/space/fluid/e = get_step(src,EAST)
			var/turf/space/fluid/w = get_step(src,WEST)
			if(istype(n))
				n.tilenotify(src)
			if(istype(s))
				s.tilenotify(src)
			if(istype(e))
				e.tilenotify(src)
			if(istype(w))
				w.tilenotify(src)

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.getProperty("density") >= 6)
				health *= 1.5
			else if (src.material.getProperty("density") <= 2)
				health *= 0.75
			if(src.material.material_flags & MATERIAL_CRYSTAL)
				health /= 2
		return

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall
	explosion_resistance = 2

	proc/xmasify()
		if(fixed_random(src.x / world.maxx, src.y / world.maxy) <= 0.01)
			new /obj/decal/wreath(src)
		if(istype(get_area(src), /area/station/crew_quarters/cafeteria) && fixed_random(src.x / world.maxx + 0.001, src.y / world.maxy - 0.00001) <= 0.4)
			SPAWN(1 SECOND)
				var/turf/T = get_step(src, SOUTH)
				if(!T.density && !(locate(/obj/window) in T) && !(locate(/obj/machinery/door) in T))
					var/obj/stocking/stocking = new(T)
					stocking.pixel_y = 26

/turf/simulated/wall/New()
	..()
	if(!ticker && istype(src.loc, /area/station/maintenance) && prob(7))
		make_cleanable(/obj/decal/cleanable/fungus, src)

// Made this a proc to avoid duplicate code (Convair880).
/turf/simulated/wall/proc/attach_light_fixture_parts(var/mob/user, var/obj/item/W, var/instantly)
	if (!user || !istype(W, /obj/item/light_parts/) || istype(W, /obj/item/light_parts/floor))	//hack, no floor lights on walls
		return

	// the wall is the target turf, the source is the turf where the user is standing
	var/turf/target = src
	var/turf/source = get_turf(user)

	// need to find the direction to orient the new light
	var/dir = 0

	// find the direction from the mob to the target wall
	for (var/d in cardinal)
		if (get_step(source,d) == target)
			dir = d
			break

	// if no direction was found, fail. need to be standing cardinal to the wall to put the fixture up
	if (!dir)
		return //..(parts, user)

	if(!instantly && W && !W.disposed)
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		boutput(user, "You begin to attach the light fixture to [src]...")
		SETUP_GENERIC_ACTIONBAR(user, src, 4 SECONDS, /turf/simulated/wall/proc/finish_attaching,\
			list(W, user, dir), W.icon, W.icon_state, null, null)
		return

	finish_attaching(W, user, dir)
	return

/turf/simulated/wall/proc/finish_attaching(obj/item/W, mob/user, var/light_dir)
	boutput(user, "You attach the light fixture to [src].")
	var/obj/item/light_parts/parts = W
	var/obj/machinery/light/newlight = new parts.fixture_type(get_turf(user))
	newlight.set_dir(light_dir)
	newlight.icon_state = parts.installed_icon_state
	newlight.base_state = parts.installed_base_state
	newlight.fitting = parts.fitting
	newlight.status = 1 // LIGHT_EMPTY
	if (istype(src,/turf/simulated/wall/auto))
		newlight.nostick = 0
		newlight.autoposition()
	newlight.add_fingerprint(user)
	src.add_fingerprint(user)
	user.u_equip(parts)
	qdel(parts)

/turf/simulated/wall/proc/dismantle_wall(devastated=0, keep_material = 1)
	if (istype(src, /turf/simulated/wall/r_wall) || istype(src, /turf/simulated/wall/auto/reinforced))
		if (!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			var/atom/A = new /obj/structure/girder/reinforced(src)
			var/obj/item/sheet/B = new /obj/item/sheet( src )
			if (src.material)
				A.setMaterial(src.material)
				B.setMaterial(src.material)
				B.set_reinforcement(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M, copy = FALSE)
				B.setMaterial(M, copy = FALSE)
				B.set_reinforcement(M)
		else
			if (prob(50)) // pardon all these nested probabilities, just trying to vary the damage appearance a bit
				var/atom/A = new /obj/structure/girder/reinforced(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)

				if (prob(50))
					var/atom/movable/B = new /obj/item/raw_material/scrap_metal
					B.set_loc(src)
					if (src.material)
						B.setMaterial(src.material)
					else
						B.setMaterial(getMaterial("steel"), copy = FALSE)

			else if( prob(50))
				var/atom/A = new /obj/structure/girder(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)

	else
		if (!devastated)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			var/atom/A = new /obj/structure/girder(src)
			var/atom/B = new /obj/item/sheet( src )
			var/atom/C = new /obj/item/sheet( src )
			if (src.material)
				A.setMaterial(src.material)
				B.setMaterial(src.material)
				C.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M, copy = FALSE)
				B.setMaterial(M, copy = FALSE)
				C.setMaterial(M, copy = FALSE)
		else
			if (prob(50))
				var/atom/A = new /obj/structure/girder/displaced(src)
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)

			else if (prob(50))
				var/atom/B = new /obj/structure/girder(src)

				if (src.material)
					B.setMaterial(src.material)
				else
					B.setMaterial(getMaterial("steel"), copy = FALSE)

				if (prob(50))
					var/atom/movable/C = new /obj/item/raw_material/scrap_metal
					C.set_loc(src)
					if (src.material)
						C.setMaterial(src.material)
					else
						C.setMaterial(getMaterial("steel"), copy = FALSE)

	var/atom/D = ReplaceWithFloor()
	if (src.material && keep_material)
		D.setMaterial(src.material)
	else
		D.setMaterial(getMaterial("steel"), copy = FALSE)

/turf/simulated/wall/burn_down()
	src.ReplaceWithFloor()

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1)
			src.ReplaceWithSpace()
			return
		if(2)
			if (prob(66))
				dismantle_wall(1)
		if(3)
			if (prob(40))
				dismantle_wall(1)
		else
	return

/turf/simulated/wall/blob_act(var/power)
	if(prob(power))
		dismantle_wall(1)

/turf/simulated/wall/attack_hand(mob/user)
	if (user.is_hulk())
		if(isrwall(src))
			boutput(user, text("<span class='notice'>You punch the [src.name], but can't seem to make a dent!</span>"))
			return
		else
			if (prob(70))
				playsound(user.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				if (src.material)
					src.material.triggerOnAttacked(src, user, user, src)
				for (var/mob/N in AIviewers(user, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
			if (prob(40))
				boutput(user, text("<span class='notice'>You smash through the [src.name].</span>"))
				logTheThing(LOG_COMBAT, user, "uses hulk to smash a wall at [log_loc(src)].")
				dismantle_wall(1)
				return
			else
				boutput(user, text("<span class='notice'>You punch the [src.name].</span>"))
				return

	boutput(user, "<span class='notice'>You hit the [src.name] but nothing happens!</span>")
	playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 25, 1)
	interact_particle(user,src)
	return

/turf/simulated/wall/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/spray_paint) || istype(W, /obj/item/gang_flyer))
		return

	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return

	else if (istype(W, /obj/item/light_parts))
		src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
		return

	else if (isweldingtool(W))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(!W:try_weld(user, 5, burn_eyes = 1))
			return

		boutput(user, "<span class='notice'>Now disassembling the outer wall plating.</span>")
		SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, /turf/simulated/wall/proc/weld_action,\
			list(W, user), W.icon, W.icon_state, "[user] finishes disassembling the outer wall plating.", null)

//Spooky halloween key
	else if(istype(W,/obj/item/device/key/haunted))
		//Okay, create a temporary false wall.
		if(W:last_use && ((W:last_use + 300) >= world.time))
			boutput(user, "<span class='alert'>The key won't fit in all the way!</span>")
			return
		user.visible_message("<span class='alert'>[user] inserts [W] into [src]!</span>","<span class='alert'>The key seems to phase into the wall.</span>")
		W:last_use = world.time
		blink(src)
		new /turf/simulated/wall/false_wall/temp(src)
		return

//grabsmash
	else if (istype(W, /obj/item/grab/))
		var/obj/item/grab/G = W
		if  (!grab_smash(G, user))
			return ..(W, user)
		else return

	else
		if(src.material)
			src.material.triggerOnHit(src, W, user, 1)
		src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [W].</span>", "<span class='alert'>You uselessly hit [src] with [W].</span>")
		//return attack_hand(user)

/turf/simulated/wall/proc/weld_action(obj/item/W, mob/user)
	logTheThing(LOG_STATION, user, "deconstructed a wall ([src.name]) using \a [W] at [get_area(user)] ([log_loc(user)])")
	dismantle_wall()

/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "Looks a lot tougher than a regular wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	pathable = 0
	var/d_state = 0
	explosion_resistance = 7
	health = 300

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.getProperty("density") >= 6)
				health *= 1.5
			else if (src.material.getProperty("density") <= 2)
				health *= 0.75
			if(src.material.material_flags & MATERIAL_CRYSTAL)
				health /= 2
		return

/turf/simulated/wall/r_wall/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/spray_paint) || istype(W, /obj/item/gang_flyer))
		return

	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return

	else if (istype(W, /obj/item/light_parts))
		src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
		return

	else if (isweldingtool(W))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (src.d_state == 2)
			if(!W:try_weld(user,1,-1,1,1))
				return
			boutput(user, "<span class='notice'>Slicing metal cover.</span>")
			sleep(6 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 3
				boutput(user, "<span class='notice'>You removed the metal cover.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 3
				boutput(user, "<span class='notice'>You removed the metal cover.</span>")

		else if (src.d_state == 5)
			if(!W:try_weld(user,1,-1,1,1))
				return
			boutput(user, "<span class='notice'>Removing support rods.</span>")
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 6
				var/atom/A = new /obj/item/rods( src )
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)
				boutput(user, "<span class='notice'>You removed the support rods.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 6
				var/atom/A = new /obj/item/rods( src )
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"), copy = FALSE)
				boutput(user, "<span class='notice'>You removed the support rods.</span>")

	else if (iswrenchingtool(W))
		if (src.d_state == 4)
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Detaching support rods.</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
			sleep(4 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 5
				boutput(user, "<span class='notice'>You detach the support rods.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 5
				boutput(user, "<span class='notice'>You detach the support rods.</span>")

	else if (issnippingtool(W))
		if (src.d_state == 0)
			playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
			src.d_state = 1
			var/atom/A = new /obj/item/rods( src )
			if (src.material)
				A.setMaterial(src.material)
			else
				A.setMaterial(getMaterial("steel"), copy = FALSE)

	else if (isscrewingtool(W))
		if (src.d_state == 1)
			var/turf/T = user.loc
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			boutput(user, "<span class='notice'>Removing support lines.</span>")
			sleep(4 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 2
				boutput(user, "<span class='notice'>You removed the support lines.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 2
				boutput(user, "<span class='notice'>You removed the support lines.</span>")

	else if (ispryingtool(W))
		if (src.d_state == 3)
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Prying cover off.</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 4
				boutput(user, "<span class='notice'>You removed the cover.</span>")
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 4
				boutput(user, "<span class='notice'>You removed the cover.</span>")
		else if (src.d_state == 6)
			var/turf/T = user.loc
			boutput(user, "<span class='notice'>Prying outer sheath off.</span>")
			playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				boutput(user, "<span class='notice'>You removed the outer sheath.</span>")
				dismantle_wall()
				logTheThing(LOG_STATION, user, "dismantles a reinforced wall at [log_loc(user)].")
				return
			else if((isrobot(user) && (user.loc == T)))
				boutput(user, "<span class='notice'>You removed the outer sheath.</span>")
				dismantle_wall()
				logTheThing(LOG_STATION, user, "dismantles a reinforced wall at [log_loc(user)].")
				return

	//More spooky halloween key
	else if(istype(W,/obj/item/device/key/haunted))
		//Okay, create a temporary false wall.
		if(W:last_use && ((W:last_use + 300) >= world.time))
			boutput(user, "<span class='alert'>The key won't fit in all the way!</span>")
			return
		user.visible_message("<span class='alert'>[user] inserts [W] into [src]!</span>","<span class='alert'>The key seems to phase into the wall.</span>")
		W:last_use = world.time
		blink(src)
		var/turf/simulated/wall/false_wall/temp/fakewall = new /turf/simulated/wall/false_wall/temp(src)
		fakewall.was_rwall = 1
		return

	else if ((istype(W, /obj/item/sheet)) && (src.d_state))
		var/obj/item/sheet/S = W
		boutput(user, "<span class='notice'>Repairing wall.</span>")
		if (do_after(user, 10 SECONDS) && S.change_stack_amount(-1))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			if(S.material)
				src.setMaterial(S.material)
			else
				src.setMaterial(getMaterial("steel"), copy = FALSE)
			boutput(user, "<span class='notice'>You repaired the wall.</span>")

//grabsmash
	else if (istype(W, /obj/item/grab/))
		var/obj/item/grab/G = W
		if  (!grab_smash(G, user))
			return ..(W, user)
		else return

	if(istype(src, /turf/simulated/wall/r_wall) && src.d_state > 0)
		src.icon_state = "r_wall-[d_state]"

	if(src.material)
		src.material.triggerOnHit(src, W, user, 1)

	src.visible_message("<span class='alert'>[usr ? usr : "Someone"] uselessly hits [src] with [W].</span>", "<span class='alert'>You uselessly hit [src] with [W].</span>")
	//return attack_hand(user)


/turf/simulated/wall/meteorhit(obj/M as obj)
	dismantle_wall()
	return 0
