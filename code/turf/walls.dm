TYPEINFO(/turf/simulated/wall)
	mat_appearances_to_ignore = list("steel")

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
	flags = FLUID_DENSE
	text = "<font color=#aaa>#"
	HELP_MESSAGE_OVERRIDE("You can use a <b>welding tool</b> to begin to disassemble it.")
	default_material = "steel"

	var/health = 100
	var/list/forensic_impacts = null
	var/last_proj_update_time = null
	var/girdermaterial = null

	New()
		..()
		var/obj/plan_marker/wall/P = locate() in src
		if (P)
			P.check()

		src.AddComponent(/datum/component/bullet_holes, 15, 10)

		for(var/obj/decal/cleanable/clean in src)
			clean.plane = PLANE_FLOOR
		src.selftilenotify() // displace fluid

		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
			xmasify()
		#endif


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
			if(src.material.getMaterialFlags() & MATERIAL_CRYSTAL)
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
				if(!T.density && !(locate(/obj/window) in T) && !(locate(/obj/machinery/door) in T) && !(locate(/obj/mapping_helper/wingrille_spawn) in T))
					var/obj/stocking/stocking = new(T)
					stocking.pixel_y = 26

/turf/simulated/wall/New()
	..()
	if(!ticker && istype(src.loc, /area/station/maintenance) && prob(7))
		make_cleanable(/obj/decal/cleanable/fungus, src)

/turf/simulated/wall/proc/attach_item(var/mob/user, var/obj/item/W) //we don't want code duplication
	//reset object position
	//not doing so breaks it's further position
	W.pixel_y = 0
	W.pixel_x = 0


	//based on light fixture code
	var/turf/target = src
	var/turf/source = get_turf(user)


	var/direction = 0

	for (var/d in cardinal)
		if (get_step(source, d) == target)
			direction = d
			break

	if (!direction)
		boutput(user, SPAN_ALERT(" Attaching \the [W] seems hard in this position..."))
		return FALSE

	user.u_equip(W)
	W.set_loc(get_turf(user))

	if (user.dir == EAST)
		W.pixel_x = 32
		W.pixel_y = 3
	else if (user.dir == WEST)
		W.pixel_x = -32
		W.pixel_y = 3
	else if (user.dir == NORTH)
		W.pixel_y = 35
		W.pixel_x = 0
	else
		W.pixel_y = -21
		W.pixel_x = 0

	src.add_fingerprint(user)
	W.anchored = TRUE
	boutput(user, "You attach \the [W] to [src].")
	return TRUE

/turf/simulated/wall/proc/dismantle_wall(devastated=0, keep_material = 1)
	var/datum/material/defaultMaterial = getMaterial("steel")
	if (istype(src, /turf/simulated/wall/r_wall) || istype(src, /turf/simulated/wall/auto/reinforced))
		if (!devastated)
			var/atom/A = new /obj/structure/girder/reinforced(src)
			var/obj/item/sheet/B = new /obj/item/sheet( src )

			A.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)
			B.setMaterial(src.material ? src.material : defaultMaterial)
			B.set_reinforcement(src.material)
		else
			if (prob(50)) // pardon all these nested probabilities, just trying to vary the damage appearance a bit
				var/atom/A = new /obj/structure/girder/reinforced(src)
				A.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)


				if (prob(50))
					var/atom/movable/B = new /obj/item/raw_material/scrap_metal
					B.set_loc(src)
					B.setMaterial(src.material ? src.material : defaultMaterial)

			else if( prob(50))
				var/atom/A = new /obj/structure/girder(src)
				A.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)

	else
		if (!devastated)
			var/atom/A = new /obj/structure/girder(src)
			var/atom/B = new /obj/item/sheet( src )
			var/atom/C = new /obj/item/sheet( src )

			A.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)
			B.setMaterial(src.material ? src.material : defaultMaterial)
			C.setMaterial(src.material ? src.material : defaultMaterial)

		else
			if (prob(50))
				var/atom/A = new /obj/structure/girder/displaced(src)
				A.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)


			else if (prob(50))
				var/atom/B = new /obj/structure/girder(src)

				B.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)


				if (prob(50))
					var/atom/movable/C = new /obj/item/raw_material/scrap_metal
					C.set_loc(src)
					C.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)


	var/atom/D = ReplaceWithFloor()
	if (src.material && keep_material)
		D.setMaterial(src.material)
	else
		D.setMaterial(getMaterial("steel"))


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

/turf/simulated/wall/blob_act(var/power)
	if(prob(power))
		dismantle_wall(1)

/turf/simulated/wall/attack_hand(mob/user)
	if (user.is_hulk())
		if(isrwall(src))
			boutput(user, SPAN_NOTICE("You punch the [src.name], but can't seem to make a dent!"))
			return
		else
			if (prob(70))
				playsound(user.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				src.material_trigger_when_attacked(user, user, 1)
				for (var/mob/N in AIviewers(user, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
			if (prob(40))
				boutput(user, SPAN_NOTICE("You smash through the [src.name]."))
				logTheThing(LOG_COMBAT, user, "uses hulk to smash a wall at [log_loc(src)].")
				dismantle_wall(1)
				return
			else
				boutput(user, SPAN_NOTICE("You punch the [src.name]."))
				return

	boutput(user, SPAN_NOTICE("You hit the [src.name] but nothing happens!"))
	playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 25, TRUE)
	interact_particle(user,src)
	return

/turf/simulated/wall/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/spray_paint_gang) || istype(W, /obj/item/spray_paint_graffiti)  || istype(W, /obj/item/gang_flyer))
		return

	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return

	else if (isweldingtool(W))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(!W:try_weld(user, 5, burn_eyes = 1))
			return

		boutput(user, SPAN_NOTICE("Now disassembling the outer wall plating."))
		SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, /turf/simulated/wall/proc/weld_action,\
			list(W, user), W.icon, W.icon_state, "[user] finishes disassembling the outer wall plating.", null)

//Spooky halloween key
	else if(istype(W,/obj/item/device/key/haunted))
		//Okay, create a temporary false wall.
		if(W:last_use && ((W:last_use + 300) >= world.time))
			boutput(user, SPAN_ALERT("The key won't fit in all the way!"))
			return
		user.visible_message(SPAN_ALERT("[user] inserts [W] into [src]!"),SPAN_ALERT("The key seems to phase into the wall."))
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
		src.material_trigger_when_attacked(W, user, 1)
		src.visible_message(SPAN_ALERT("[usr ? usr : "Someone"] uselessly hits [src] with [W]."), SPAN_ALERT("You uselessly hit [src] with [W]."))
		//return src.Attackhand(user)

/turf/simulated/wall/proc/weld_action(obj/item/W, mob/user)
	logTheThing(LOG_STATION, user, "deconstructed a wall ([src.name]) using \a [W] at [get_area(user)] ([log_loc(user)])")
	dismantle_wall()

/turf/simulated/wall/bullet_act(obj/projectile/P)
	..()
	if (!istype(P.proj_data, /datum/projectile/bullet))
		return
	var/datum/projectile/bullet/bullet = P.proj_data
	if (!bullet.ricochets)
		return
	if (prob(90))
		return

	var/proj_name = P.name
	var/obj/projectile/p_copy = SEMI_DEEP_COPY(P)
	p_copy.proj_data.shot_sound = "sound/weapons/ricochet/ricochet-[rand(1, 4)].ogg"
	p_copy.proj_data.power = sqrt(p_copy.proj_data.power)
	p_copy.proj_data.dissipation_delay *= 0.5
	p_copy.proj_data.armor_ignored /= 0.25
	var/obj/projectile/p_reflected = shoot_reflected_bounce(p_copy, src, 1)
	P.die()
	p_copy.die()
	if (!p_reflected)
		return

	p_reflected.rotateDirection(rand(-15, 15))

	src.visible_message(SPAN_ALERT("\The [proj_name] richochets off [src]!"))

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
			if(src.material.getMaterialFlags() & MATERIAL_CRYSTAL)
				health /= 2
				desc += " Wait where did the girder go?"
		return

/turf/simulated/wall/r_wall/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/spray_paint_gang) || istype(W, /obj/item/spray_paint_graffiti) || istype(W, /obj/item/gang_flyer))
		return

	if (istype(W, /obj/item/pen))
		var/obj/item/pen/P = W
		P.write_on_turf(src, user, params)
		return

	else if (isweldingtool(W))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (src.d_state == 2)
			if(!W:try_weld(user,1,-1,1,1))
				return
			boutput(user, SPAN_NOTICE("Slicing metal cover."))
			sleep(6 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 3
				boutput(user, SPAN_NOTICE("You removed the metal cover."))
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 3
				boutput(user, SPAN_NOTICE("You removed the metal cover."))

		else if (src.d_state == 5)
			if(!W:try_weld(user,1,-1,1,1))
				return
			boutput(user, SPAN_NOTICE("Removing support rods."))
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 6
				var/atom/A = new /obj/item/rods( src )
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"))
				boutput(user, SPAN_NOTICE("You removed the support rods."))
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 6
				var/atom/A = new /obj/item/rods( src )
				if (src.material)
					A.setMaterial(src.material)
				else
					A.setMaterial(getMaterial("steel"))
				boutput(user, SPAN_NOTICE("You removed the support rods."))

	else if (iswrenchingtool(W))
		if (src.d_state == 4)
			var/turf/T = user.loc
			boutput(user, SPAN_NOTICE("Detaching support rods."))
			playsound(src, 'sound/items/Ratchet.ogg', 100, TRUE)
			sleep(4 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 5
				boutput(user, SPAN_NOTICE("You detach the support rods."))
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 5
				boutput(user, SPAN_NOTICE("You detach the support rods."))

	else if (issnippingtool(W))
		if (src.d_state == 0)
			playsound(src, 'sound/items/Wirecutter.ogg', 100, TRUE)
			src.d_state = 1
			var/atom/A = new /obj/item/rods( src )
			if (src.material)
				A.setMaterial(src.material)
			else
				A.setMaterial(getMaterial("steel"))

	else if (isscrewingtool(W))
		if (src.d_state == 1)
			var/turf/T = user.loc
			playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
			boutput(user, SPAN_NOTICE("Removing support lines."))
			sleep(4 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 2
				boutput(user, SPAN_NOTICE("You removed the support lines."))
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 2
				boutput(user, SPAN_NOTICE("You removed the support lines."))

	else if (ispryingtool(W))
		if (src.d_state == 3)
			var/turf/T = user.loc
			boutput(user, SPAN_NOTICE("Prying cover off."))
			playsound(src, 'sound/items/Crowbar.ogg', 100, TRUE)
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 4
				boutput(user, SPAN_NOTICE("You removed the cover."))
			else if((isrobot(user) && (user.loc == T)))
				src.d_state = 4
				boutput(user, SPAN_NOTICE("You removed the cover."))
		else if (src.d_state == 6)
			var/turf/T = user.loc
			boutput(user, SPAN_NOTICE("Prying outer sheath off."))
			playsound(src, 'sound/items/Crowbar.ogg', 100, TRUE)
			sleep(10 SECONDS)
			if ((user.loc == T && user.equipped() == W))
				boutput(user, SPAN_NOTICE("You removed the outer sheath."))
				dismantle_wall()
				logTheThing(LOG_STATION, user, "dismantles a reinforced wall at [log_loc(user)].")
				return
			else if((isrobot(user) && (user.loc == T)))
				boutput(user, SPAN_NOTICE("You removed the outer sheath."))
				dismantle_wall()
				logTheThing(LOG_STATION, user, "dismantles a reinforced wall at [log_loc(user)].")
				return

	//More spooky halloween key
	else if(istype(W,/obj/item/device/key/haunted))
		//Okay, create a temporary false wall.
		if(W:last_use && ((W:last_use + 300) >= world.time))
			boutput(user, SPAN_ALERT("The key won't fit in all the way!"))
			return
		user.visible_message(SPAN_ALERT("[user] inserts [W] into [src]!"),SPAN_ALERT("The key seems to phase into the wall."))
		W:last_use = world.time
		blink(src)
		var/turf/simulated/wall/false_wall/temp/fakewall = new /turf/simulated/wall/false_wall/temp(src)
		fakewall.was_rwall = 1
		return

	else if ((istype(W, /obj/item/sheet)) && (src.d_state))
		var/obj/item/sheet/S = W
		boutput(user, SPAN_NOTICE("Repairing wall."))
		if (do_after(user, 10 SECONDS) && S.change_stack_amount(-1))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			if(S.material)
				src.setMaterial(S.material)
			else
				src.setMaterial(getMaterial("steel"))
			boutput(user, SPAN_NOTICE("You repaired the wall."))

//grabsmash
	else if (istype(W, /obj/item/grab/))
		var/obj/item/grab/G = W
		if  (!grab_smash(G, user))
			return ..(W, user)
		else return

	if(istype(src, /turf/simulated/wall/r_wall) && src.d_state > 0)
		src.icon_state = "r_wall-[d_state]"

	src.material_trigger_when_attacked(W, user, 1)

	src.visible_message(SPAN_ALERT("[usr ? usr : "Someone"] uselessly hits [src] with [W]."), SPAN_ALERT("You uselessly hit [src] with [W]."))
	//return src.Attackhand(user)


/turf/simulated/wall/meteorhit(obj/M as obj)
	dismantle_wall()
	return 0

/turf/simulated/wall/grass
	name = "tall grass"
	desc = "Looks like a... regular wall that's been painted in a grassy pattern. Clever!"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "grass_0"

#ifdef SEASON_AUTUMN
	New()
		..()
		try_set_icon_state(src.icon_state + "_autumn", src.icon)
#endif

/turf/simulated/wall/grass/leafy
	icon_state = "grass_leafy"

/turf/simulated/wall/auto/asteroid
	HELP_MESSAGE_OVERRIDE("")
