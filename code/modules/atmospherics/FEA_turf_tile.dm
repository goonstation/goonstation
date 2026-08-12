/atom/movable/tile_gas_effect
	name = ""
	density = FALSE
	mouse_opacity = 0
	anchored = ANCHORED_ALWAYS
	pass_unstable = FALSE
	mat_changename = FALSE
	mat_changedesc = FALSE
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_TRENCH_WARP

	meteorhit()
		return

	ex_act()
		return

	track_blood()
		src.tracked_blood = null
		return

/turf
	/// Pressure delta between us and some turf.
	var/tmp/pressure_difference = 0
	/// The direction of the pressure delta.
	var/tmp/pressure_direction = 0
	/// Current fire object on us.
	var/tmp/list/atom/movable/hotspot/active_hotspots
	/// Our gas mixture
	VAR_PRIVATE/tmp/datum/gas_mixture/turf_tied/air

/turf/New()
	. = ..()
	src.active_hotspots = list()

/// Assumes air into the turf. Use this instead of directly adding to air.
/turf/assume_air(datum/gas_mixture/giver)
	return FALSE

/// Return new gas mixture with the gas variables we start with.
/turf/return_air(direct = FALSE)
	RETURN_TYPE(/datum/gas_mixture/turf_tied)
	src.air ||= new /datum/gas_mixture/turf_tied(src.x, src.y, src.z)
	return src.air

/// Return a new gas mixture with a specified amount of moles with the composition of our gas vars.
/turf/remove_air(amount)
	var/datum/gas_mixture/normal/GM = new /datum/gas_mixture/normal

	GM.copy_from_goonmos(goonmos_get_tile_info(src))

	return GM

/// Checks if gas can pass between two turfs. If anything within the turf does not allow passage, the check fails.
/// Returns: TRUE if gas can pass, FALSE if not.
/turf/gas_cross(atom/target)
	if(isnull(target) || target.gas_impermeable || src.gas_impermeable)
		return FALSE
	for(var/atom/movable/AM as anything in src)
		if(AM.gas_impermeable())
			return FALSE
	for(var/atom/movable/AM as anything in target)
		if(AM.gas_impermeable())
			return FALSE
	return TRUE

/// Tile that processes things such as air, explosions, and fluids.
/turf/simulated
	pass_unstable = FALSE
	var/static/list/mutable_appearance/gas_overlays = list(
			#ifdef ALPHA_GAS_OVERLAYS
			mutable_appearance('icons/effects/tile_effects.dmi', "plasma-alpha", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "sleeping_agent-alpha", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "rad_particles-alpha", FLY_LAYER, PLANE_NOSHADOW_ABOVE)
			#else
			mutable_appearance('icons/effects/tile_effects.dmi', "plasma", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "sleeping_agent", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "rad_particles", FLY_LAYER, PLANE_NOSHADOW_ABOVE)
			#endif
		)
	/// The overlay used to show gases on us such as plasma.
	var/tmp/atom/movable/tile_gas_effect/gas_icon_overlay
	/// Bitfield representing gas graphics on us.
	var/tmp/visuals_state

/// Process moving movable atoms within us based on the pressure differential.
/turf/simulated/proc/high_pressure_movements()
	for(var/atom/movable/in_tile as anything in src)
		in_tile.experience_pressure_difference(pressure_difference, pressure_direction)

	pressure_difference = 0

/** Sets [/turf/simulated/pressure_difference] and [/turf/simulated/pressure_direction] to connection_difference and connection_direction if
	connection_difference is higher than the value of [/turf/simulated/pressure_difference].
 * 	Flips connection_difference and connection_direction if connection_difference was lower than 0.
 * 	Queues us for pressure delta processing if we previously did not have a pressure difference. */
/turf/simulated/proc/consider_pressure_difference(connection_difference, connection_direction)
	if(loc:sanctuary)
		return //no atmos updates in sanctuaries

	if(connection_difference < 0)
		connection_difference = -connection_difference
		connection_direction = turn(connection_direction, 180)

	if(connection_difference > pressure_difference)
		if(!pressure_difference)
			air_master.high_pressure_delta[src] = null
		pressure_difference = connection_difference
		pressure_direction = connection_direction

/// Updates, or creates, our overlay if [/datum/gas_mixture/var/graphic] on model is different from [/turf/simulated/var/tmp/visuals_state].
/// If model doesn't have a graphic, delete our overlay.
/turf/simulated/proc/update_visuals(datum/gas_mixture/model)

	if (model.graphic)
		if (model.graphic != visuals_state)
			if(!src.gas_icon_overlay)
				src.gas_icon_overlay = new /atom/movable/tile_gas_effect(src)
			else
				src.gas_icon_overlay.overlays.len = 0

			src.visuals_state = model.graphic
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_PLASMA)
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_N2O)
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_RAD)
			src.gas_icon_overlay.dir = pick(cardinal)
	else
		if (src.gas_icon_overlay)
			qdel(gas_icon_overlay)
			src.gas_icon_overlay = null

/turf/simulated/New()
	. = ..()

	if(!src.gas_impermeable)


	else
		if(!air_master)
			return
		for(var/direction in cardinal)
			var/turf/simulated/floor/target = get_step(src,direction)
			if(issimulatedturf(target))
				air_master.tiles_to_update[target] = null

/turf/simulated/Del()
	for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
		qdel(hotspot)
	src.active_hotspots.len = 0

	qdel(air)
	src.air = null

	if (src.gas_icon_overlay)
		qdel(gas_icon_overlay)
		src.gas_icon_overlay = null

	src.air = null
	..()

/// Removes some moles from turf or air group.
/turf/simulated/remove_air(amount)
	var/datum/gas_mixture/normal/removed = null

	if(!src.processing)
		if(src.air.check_tile_graphic())
			src.update_visuals(air)

	return removed

/// Does a fair amount. Shares with neighbors, updates hotspots, update graphics, checks superconductivity, the whole nine yards.
/turf/simulated/proc/process_cell()
	if(src.air.react() & CATALYST_ACTIVE)
		for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
			hotspot.catalyst_active = TRUE
	else
		for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
			hotspot.catalyst_active = FALSE

	if(src.air.check_tile_graphic())
		src.update_visuals(air)

	if(src.air.temperature() > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		src.hotspot_expose(air.temperature(), CELL_VOLUME)
		for(var/atom/movable/AM as anything in src)
			AM.temperature_expose(src.air, src.air.temperature(), CELL_VOLUME)
		src.temperature_expose(src.air, src.air.temperature(), CELL_VOLUME)

	if(src.air.radgas() >= RADGAS_MINIMUM_CONTAMINATION_MOLES && !ON_COOLDOWN(src, "radgas_contaminate", RADGAS_CONTAMINATION_COOLDOWN)) //if fallout is in the air, contaminate objects on this tile and consume radgas
		for(var/atom/movable/AM as anything in src)
			if(isintangible(AM) || isobserver(AM) || IS_OVERLAY_OR_EFFECT(AM) || istype(AM, /atom/movable/hotspot) || istype(AM, /obj/particle))
				continue
			if(AM.invisibility > INVIS_CLOAK) //invisible things don't get to be radioactive. Because space science reasons.
				continue
			var/list/rad_level = list()
			SEND_SIGNAL(AM, COMSIG_ATOM_RADIOACTIVITY, rad_level)
			if(max(rad_level) > RADGAS_MAXIMUM_CONTAMINATION)
				continue
			AM.AddComponent(/datum/component/radioactive,min(src.air.radgas() + max(rad_level), max(rad_level) + RADGAS_MAXIMUM_CONTAMINATION_TICK),TRUE,FALSE)
			src.air.adjust_radgas(-min(src.air.radgas(), RADGAS_MAXIMUM_CONTAMINATION_TICK)/RADGAS_CONTAMINATION_PER_MOLE)
			if(src.air.radgas() < RADGAS_MINIMUM_CONTAMINATION_MOLES)
				break //no point continuing if we've dropped below threshold

	return TRUE


/// Tells our neighbors it's time to update.
/turf/proc/update_nearby_tiles(need_rebuild)
	src.selftilenotify() //used in fluids.dm for displaced fluid

	if (map_currently_underwater)
		for(var/direction in cardinal)
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T))
				T.tilenotify(src)

	return TRUE
