TYPEINFO(/obj/mesh/grille)
TYPEINFO_NEW(/obj/mesh/grille)
	. = ..()
	connects_to_turf = typecacheof(list(/turf/simulated/wall/auto, /turf/simulated/wall/auto/reinforced, /turf/simulated/shuttle/wall, /turf/unsimulated/wall))
	connects_to_obj = typecacheof(list(/obj/indestructible/shuttle_corner, /obj/mesh/grille, /obj/machinery/door, /obj/window))
/obj/mesh/grille
	desc = "A metal mesh often built underneath windows to reinforce them. The holes let fluids and gasses through."
	name = "grille"
	icon = 'icons/obj/SL_windows_grilles.dmi'
	icon_state = "grille0-0"
	density = TRUE
	uses_default_material_appearance = TRUE
	text = "<font color=#aaa>+"

	icon_state_prefix = "grille"

/obj/mesh/grille/steel
	icon_state = "grille1-0"
	default_material = "steel"

/obj/mesh/grille/steel/broken
	desc = "Looks like its been in this sorry state for quite some time."
	icon_state = "grille-cut"
	ruined = TRUE
	density = FALSE
	health = 0

/obj/mesh/grille/steel/broken/corroded
	icon_state = "grille-corroded"

/obj/mesh/grille/steel/broken/melted
	icon_state = "grille-melted"

/obj/mesh/grille/Cross(atom/movable/mover)
	if (istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if (src.density)
			if(P.proj_data.damage_type & D_RADIOACTIVE) // this shit isn't lead-lined
				return TRUE
			return prob(max(25, 1 - P.power))//big bullet = more chance to hit grille. 25% minimum
		return TRUE

	if (src.density && istype(mover, /obj/window))
		return TRUE

	return ..()

/obj/mesh/grille/Crossed(atom/movable/AM)
	. = ..()
	if (ismob(AM))
		if (!isliving(AM) || isintangible(AM)) // I assume this was left out by accident (Convair880).
			return
		var/mob/M = AM
		if (M.client && M.client.flying || (ismob(M) && HAS_ATOM_PROPERTY(M, PROP_MOB_NOCLIP))) // noclip
			return
		var/shock_chance = 10
		if (M.m_intent != "walk") // move carefully
			shock_chance += 50
		if (src.shock(M, shock_chance, rand(0,1))) // you get a 50/50 shot to accidentally touch the grille with something other than your hands
			M.show_text("<b>You brush against [src] while moving past it and it shocks you!</b>", "red")

/obj/mesh/grille/attack_hand(mob/user)
	if(!src.shock(user, 70))
		user.lastattacked = get_weakref(src)
		var/damage = 1
		var/message = "[user.kickMessage] [src]"

		if (user.is_hulk())
			damage = 10
			message = "smashes [src] with incredible strength"

		src.visible_message(SPAN_ALERT("<b>[user]</b> [message]"))
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

		src.damage_blunt(damage)

/obj/mesh/grille/attackby(obj/item/I, mob/user)
	//check pnet
	if (ispulsingtool(I) || istype(I, /obj/item/device/t_scanner))
		var/net = src.get_connection()
		if(!net)
			boutput(user, SPAN_NOTICE("No electrical current detected."))
		else
			boutput(user, SPAN_ALERT("CAUTION: Dangerous electrical current detected."))
		return

	//make window
	if (istype(I, /obj/item/sheet))
		var/obj/item/sheet/sheet = I
		if (sheet.material && (sheet.material.getMaterialFlags() & MATERIAL_CRYSTAL) && sheet.amount_check(2))
			var/obj/window/new_window
			var/turf/starting_turf = get_turf(src)

			if(starting_turf && isturf(starting_turf))
				if(sheet.reinforcement)
					if(global.map_settings)
						new_window = new global.map_settings.rwindows(starting_turf)
					else
						new_window = new /obj/window/reinforced(starting_turf)
				else
					if(global.map_settings)
						new_window = new global.map_settings.windows(starting_turf)
					else
						new_window = new /obj/window(starting_turf)

			if(new_window && istype(new_window))
				if(sheet.material)
					new_window.setMaterial(sheet.material)
				logTheThing(LOG_STATION, user, "builds a [new_window.name] (<b>Material:</b> [new_window.material && new_window.material.getID() ? "[new_window.material.getID()]" : "*UNKNOWN*"]) at ([log_loc(user)] in [user.loc.loc])")
			else
				user.show_text("<b>Error:</b> Couldn't spawn window. Try again and please inform a coder if the problem persists.", "red")
				return

			sheet.change_stack_amount(-2)
			return
		else
			..()
			return

	//gun
	if (istype(I, /obj/item/gun))
		var/obj/item/gun/gun = I
		gun.ShootPointBlank(src, user)
		return

	// electrocution check
	var/is_conductive = TRUE
	if (src.material && src.material.getProperty("electrical") < 4)
		is_conductive = FALSE
	if (is_conductive && src.material && (BOUNDS_DIST(src, user) == 0) && src.shock(user, 60 + (5 * (src?.material.getProperty("electrical") - 5))))
		return

	// tools
	if (issnippingtool(I))
		src.damage_slashing(src.health_max)
		src.visible_message(SPAN_ALERT("<b>[user]</b> cuts apart the [src] with [I]."))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return

	if (isscrewingtool(I) && (istype(src.loc, /turf/simulated) || src.anchored))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		src.anchored = !( src.anchored )
		src.provides_grip = !(src.provides_grip)
		var/turf/T = get_turf(src)
		T?.grip_atom_count += src.provides_grip ? 1 : -1
		src.visible_message(SPAN_ALERT("<b>[user]</b> [src.anchored ? "fastens" : "unfastens"] [src]."))
		return

	..()

/obj/mesh/grille/hitby(atom/movable/AM, datum/thrown_thing/thr)
	..()
	src.visible_message(SPAN_ALERT("<B>[src] was hit by [AM].</B>"))
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
	if (ismob(AM))
		if(src?.material.hasProperty("electrical"))
			src.shock(AM, 60 + (5 * (src.material.getProperty("electrical") - 5)))  // sure loved people being able to throw corpses into these without any consequences.
		src.damage_blunt(5)
	else if (isobj(AM))
		var/obj/O = AM
		if (O.throwforce)
			src.damage_blunt((max(1, O.throwforce * (1 - (src.blunt_resist / 100)))) / 2) // we don't want people screaming right through these and you can still get through them by kicking/cutting/etc

/obj/mesh/grille/get_icon_direction()
	var/connectdir = src.get_icon_connectdir()
	switch(connectdir) //many states share icons
		if (0) //stand alone
			connectdir = (NORTH) //1
		if (SOUTH) //2
			connectdir = (NORTH + SOUTH) //3
		if (NORTH + EAST)//5
			connectdir = EAST //4
		if (SOUTH + EAST + NORTH) //7
			connectdir = (SOUTH + EAST) //6
		if (NORTH + WEST) //9
			connectdir = WEST //8
		if (NORTH + SOUTH + WEST) //11
			connectdir = (SOUTH + WEST) //10
		if (NORTH + EAST + WEST) //13
			connectdir = (EAST + WEST) //12
		if (NORTH + SOUTH + EAST + WEST) //15
			connectdir = (SOUTH + EAST + WEST) //14
	return connectdir

/// Shock user with given probability (if all connections & power are working).
/// Returns TRUE if shocked, FALSE otherwise.
/obj/mesh/grille/proc/shock(mob/user, probability, ignore_gloves = FALSE)
	if (!src.anchored)
		return FALSE

	if (!prob(probability))
		return FALSE

	var/net = src.get_connection()

	if (!net) // cable is unpowered
		return FALSE

	return src.electrocute(user, probability, net, ignore_gloves)

///When hit by an arcflash, transfer some wattage to a connected pnet
/obj/mesh/grille/proc/on_arcflash(wattage)
	if (!src.anchored)
		return FALSE
	var/net = src.get_connection()
	if (!powernets[net])
		return FALSE
	if(src.material)
		powernets[net].newavail += wattage / 100 * (100 - src.material.getProperty("electrical") * 5)
		return TRUE

	powernets[net].newavail += wattage / 7500
	return TRUE

///Get the netnum of a stub cable at this grille loc, or 0 if none.
/obj/mesh/grille/proc/get_connection()
	var/turf/T = src.loc
	if(!istype(T, /turf/simulated/floor))
		return

	for(var/obj/cable/C in T)
		if(C.d1 == 0)
			return C.netnum

	return 0
