ABSTRACT_TYPE(/obj/mesh)
TYPEINFO(/obj/mesh)
	///Turfs this mesh will try to automatically connect to
	var/list/connects_to_turf = null
	///Objects this mesh will try to automatically connect to
	var/list/connects_to_obj = null
/obj/mesh
	stops_space_move = TRUE
	anchored = ANCHORED
	flags = CONDUCT | USEDELAY
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = GRILLE_LAYER
	event_handler_flags = USE_FLUID_ENTER
	material_amt = 0.1

	var/health = 30
	var/health_max = 30
	///Has this mesh already been ruined?
	var/ruined = FALSE //Stop, stop, he's already dead!
	var/blunt_resist = 0
	var/cut_resist = 0
	var/corrode_resist = 0
	var/amount_of_rods_when_destroyed = 2
	///Prefix for icon state generation
	var/icon_state_prefix = ""
	///Automatically adjust sprite to connect with `connects_to_*` atoms
	var/auto_connect = TRUE

/obj/mesh/New()
	. = ..()
	START_TRACKING
	if(src.auto_connect)
		SPAWN(0) //fix for sometimes not joining on map load
			if (map_setting && ticker)
				src.update_neighbors()
			src.UpdateIcon()

/obj/mesh/disposing()
	STOP_TRACKING
	var/list/neighbors = null
	if (src.auto_connect && src.anchored && global.map_setting)
		neighbors = list()
		for(var/obj/mesh/neighbor in orange(1, src))
			neighbors += neighbor
	. = ..()
	for (var/obj/mesh/neighbor as anything in neighbors)
		neighbor?.UpdateIcon()

/obj/mesh/onMaterialChanged()
	. = ..()
	if (istype(src.material))
		health_max = material.getProperty("density") * 10
		health = health_max

		cut_resist = material.getProperty("hard") * 10
		blunt_resist = material.getProperty("density") * 5
		corrode_resist = material.getProperty("chemical") * 10

/obj/mesh/damage_blunt(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		if (amount >= health_max / 2)
			qdel(src)
		return

	amount = get_damage_after_percentage_based_armor_reduction(src.blunt_resist, amount)

	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("cut")
		src.set_density(FALSE)
		src.ruined = TRUE
	else
		src.UpdateIcon()

/obj/mesh/damage_slashing(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		src.drop_rods()
		qdel(src)
		return

	amount = get_damage_after_percentage_based_armor_reduction(src.cut_resist, amount)

	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("cut")
		src.set_density(0)
		src.ruined = 1
	else
		UpdateIcon()

/obj/mesh/damage_corrosive(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		qdel(src)
		return

	amount = get_damage_after_percentage_based_armor_reduction(src.corrode_resist, amount)
	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("corroded")
		src.set_density(FALSE)
		src.ruined = TRUE
	else
		UpdateIcon()

/obj/mesh/damage_heat(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		qdel(src)
		return

	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("melted")
		src.set_density(FALSE)
		src.ruined = TRUE
	else
		UpdateIcon()

/obj/mesh/meteorhit(var/obj/M)
	if (istype(M, /obj/newmeteor/massive))
		qdel(src)
		return

	src.damage_blunt(5)

/obj/mesh/blob_act(var/power)
	src.damage_blunt(3 * power / 20)

/obj/mesh/ex_act(severity)
	switch(severity)
		if(1)
			src.damage_blunt(40)
			src.damage_heat(40)

		if(2)
			src.damage_blunt(15)
			src.damage_heat(15)

		if(3)
			src.damage_blunt(7)
			src.damage_heat(7)

/obj/mesh/bullet_act(obj/projectile/P)
	..()
	var/damage_unscaled = P.power * P.proj_data.ks_ratio //stam component does nothing- can't tase a grille
	switch(P.proj_data.damage_type)
		if (D_PIERCING)
			src.damage_blunt(damage_unscaled)
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if (D_BURNING)
			src.damage_heat(damage_unscaled / 2)
		if (D_KINETIC)
			src.damage_blunt(damage_unscaled / 2)
			if (damage_unscaled > 10)
				var/datum/effects/system/spark_spread/sparks = new /datum/effects/system/spark_spread
				sparks.set_up(2, null, src) //sparks fly!
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 40, 1)
		if (D_ENERGY)
			src.damage_heat(damage_unscaled / 4)
		if (D_SPECIAL) //random guessing
			src.damage_blunt(damage_unscaled / 4)
			src.damage_heat(damage_unscaled / 8)
		//nothing for radioactive (useless) or slashing (unimplemented)

/obj/mesh/reagent_act(reagent_id, volume, datum/reagentsholder_reagents)
	if(..())
		return
	switch(reagent_id)
		//todo: other acids?
		if("acid")
			src.damage_corrosive(volume / 2)
		if("pacid")
			src.damage_corrosive(volume)
		//todo: thermite, kerosene?
		if("phlogiston")
			src.damage_heat(volume)
		if("infernite")
			src.damage_heat(volume * 2)
		if("foof")
			src.damage_heat(volume * 3)

/obj/mesh/update_icon()
	if (src.ruined)
		return
	src.icon_state = "[src.icon_state_prefix][src.get_icon_direction()][src.get_damage_icon_suffix()]"

/obj/mesh/attackby(obj/item/I, mob/user)
	user.lastattacked = get_weakref(src)
	attack_particle(user, src)
	src.visible_message(SPAN_ALERT("<b>[user]</b> attacks [src] with [I]."))
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

	switch(I.hit_type)
		if(DAMAGE_BURN)
			damage_heat(I.force)
		else
			damage_blunt(I.force * 0.5)

///Get the directional icon state piece.
/obj/mesh/proc/get_icon_direction()
	return ""

/// Get the direct turf connection directions from neighbors. Uses typeinfo connects_to lists.
/obj/mesh/proc/get_icon_connectdir()
	var/connectdir = 0
	if (src.auto_connect)
		var/typeinfo/obj/mesh/typinfo = get_typeinfo()
		var/connects_to_turf = typinfo.connects_to_turf
		var/connects_to_obj = typinfo.connects_to_obj
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			var/connectable_turf = FALSE
			if(connects_to_turf?[T.type])
				connectdir |= dir
				connectable_turf = TRUE
			if (!connectable_turf) //no turfs to connect to, check for obj's
				for (var/atom/movable/AM as anything in T)
					if (!AM.anchored)
						continue
					if (connects_to_obj?[AM.type])
						connectdir |= dir
						break
	return connectdir

///Check our damage percentage and return the appropriate suffix
/obj/mesh/proc/get_damage_icon_suffix()
	var/diff = get_fraction_of_percentage_and_whole(health,health_max)
	switch(diff)
		if(-INFINITY to 25)
			return "-3"
		if(25 to 50)
			return "-2"
		if(50 to 75)
			return "-1"
		if(75 to INFINITY)
			return "-0"

///Handle special icon states for cut/corroded/melted meshes
/obj/mesh/proc/special_update_icon(special_icon_state)
	if (istext(special_icon_state))
		src.icon_state = "[src.icon_state_prefix]-[special_icon_state]"

///Trigger updates in the icons of our neighbors
/obj/mesh/proc/update_neighbors()
	for(var/obj/mesh/neighbor in orange(1, src))
		neighbor.UpdateIcon()

///Drop rods of our material when deconstructing
/obj/mesh/proc/drop_rods()
	var/obj/item/rods/R = new /obj/item/rods(get_turf(src))
	R.amount = src.amount_of_rods_when_destroyed
	if(src.material)
		R.setMaterial(src.material)
	else
		var/datum/material/M = getMaterial("steel")
		R.setMaterial(M)

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
		src.stops_space_move = !(src.stops_space_move)
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

TYPEINFO(/obj/mesh/catwalk)
TYPEINFO_NEW(/obj/mesh/catwalk)
	. = ..()
	connects_to_obj = typecacheof(list(/obj/mesh/catwalk, /obj/machinery/door))
/obj/mesh/catwalk
	name = "catwalk surface"
	icon = 'icons/obj/catwalk.dmi'
	icon_state = "C15-0"
	layer = CATWALK_LAYER
	plane = PLANE_FLOOR
	event_handler_flags = IMMUNE_MINERAL_MAGNET
	default_material = "steel"
	uses_default_material_appearance = FALSE
	mat_changename = FALSE

	amount_of_rods_when_destroyed = 1
	icon_state_prefix = "C"// Short for "Catwalk"

/obj/mesh/catwalk/New()
	. = ..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_DO_LIQUID_CLICKS, src) // fuck this object

/obj/mesh/catwalk/attackby(obj/item/I, mob/user)
	if (issnippingtool(I))
		src.damage_slashing(src.health_max)
		src.visible_message(SPAN_ALERT("<b>[user]</b> cuts apart the [src] with [I]."))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return
	if (istype(I, /obj/item/cable_coil))
		src.loc.Attackby(user.equipped(), user)
		return
	..()


/obj/mesh/catwalk/special_update_icon(special_icon_state)
	if(special_icon_state == "cut")
		src.UpdateIcon()
		return // no special sprites for cut catwalks
	src.icon_state = "[src.icon_state_prefix][src.get_icon_direction()]-[special_icon_state]"

/obj/mesh/catwalk/get_icon_direction()
	return src.get_icon_connectdir()

/obj/mesh/catwalk/jen // ^^ no i made my own because i am epic
	name = "maintenance catwalk"
	icon_state = "M0-0"
	desc = "This looks marginally more safe than the ones outside, at least..."
	icon_state_prefix = "M" // Short for "Maintenance"

/obj/mesh/catwalk/jen/attackby(obj/item/I, mob/user)
	if(issnippingtool(I))
		..()
		return
	if(isturf(src.loc))
		src.loc.Attackby(user.equipped(), user)

/obj/mesh/catwalk/dubious
	name = "rusty catwalk"
	desc = "This one looks even less safe than usual."
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_MINERAL_MAGNET
	///How far are we along to collapsing
	var/collapse_counter = 0

/obj/mesh/catwalk/dubious/New()
	src.health = rand(5, 10)
	..()
	src.UpdateIcon()

/obj/mesh/catwalk/dubious/Crossed(atom/movable/AM)
	..()
	if (isliving(AM) && !isintangible(AM))
		src.collapse_counter++
		SPAWN (1 SECOND)
			src.collapse_timer()
			if(src.collapse_counter)
				playsound(src.loc, 'sound/effects/creaking_metal1.ogg', 25, 1)

/obj/mesh/catwalk/dubious/proc/collapse_timer()
	var/still_collapsing = FALSE
	for (var/mob/M in src.loc)
		src.collapse_counter++
		still_collapsing = TRUE

	if (!still_collapsing)
		src.collapse_counter--

	if (src.collapse_counter >= 5)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		src.visible_message("[src] collapses!", "[src] thuds loudly!")
		qdel(src)

	if(src.collapse_counter)
		SPAWN(1 SECOND)
			src.collapse_timer()

ABSTRACT_TYPE(/obj/mesh/flock)
/obj/mesh/flock
	icon = 'icons/misc/featherzone.dmi'
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

	auto_connect = FALSE

// Flock-converted grilles
TYPEINFO(/obj/mesh/flock/barricade)
	mat_appearances_to_ignore = list("steel", "gnesis")
/obj/mesh/flock/barricade
	icon_state = "barricade-0"
	text = "<font color=#4d736d>+"
	density = TRUE
	uses_default_material_appearance = TRUE

	icon_state_prefix = "barricade"

	var/flock_id = "Reinforced barricade"
	var/repair_per_resource = 1

/obj/mesh/flock/barricade/New()
	. = ..()
	src.UpdateIcon()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

// flockdrones can always move through
/obj/mesh/flock/barricade/Crossed(atom/movable/AM)
	. = ..()
	var/mob/living/critter/flock/drone/drone = AM
	if(istype(drone) && !drone.floorrunning)
		animate_flock_passthrough(AM)
		. = TRUE
	else if(istype(AM,/mob/living/critter/flock))
		. = TRUE

/obj/mesh/flock/barricade/Cross(atom/movable/mover)
	return !src.density || istype(mover,/mob/living/critter/flock)

/obj/mesh/flock/barricade/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] [src.flock_id]<br>\
			[SPAN_BOLD("System Integrity:")] [round((src.health/src.health_max)*100)]%<br>\
			[SPAN_BOLD("###=-")]")]"}

/obj/mesh/flock/barricade/hitby(atom/movable/AM, datum/thrown_thing/thr)
	..()
	src.visible_message(SPAN_ALERT("<B>[src] was hit by [AM].</B>"))
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
	if (ismob(AM))
		src.damage_blunt(5)
	else if (isobj(AM))
		var/obj/O = AM
		if (O.throwforce)
			src.damage_blunt((max(1, O.throwforce * (1 - (src.blunt_resist / 100)))) / 2) // we don't want people screaming right through these and you can still get through them by kicking/cutting/etc

/obj/mesh/flock/barricade/attack_hand(mob/user)
	if (user.a_intent != INTENT_HARM)
		return
	. = ..()

/obj/mesh/flock/barricade/bullet_act(obj/projectile/P)
	if (istype(P.proj_data, /datum/projectile/energy_bolt/flockdrone))
		return
	. = ..()

/obj/mesh/flock/barricade/special_update_icon(special_icon_state)
	if(special_icon_state != "cut")
		src.UpdateIcon()
		return // flock barriades only have "cut" special icons
	. = ..()

/obj/mesh/flock/barricade/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health)
	src.health += health_given
	if (src.ruined)
		src.set_density(TRUE)
		src.ruined = FALSE
	src.UpdateIcon()
	return ceil(health_given / src.repair_per_resource)
