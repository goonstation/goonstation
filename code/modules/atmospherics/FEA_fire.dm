#define HOTSPOT_MEDIUM_LIGHTS

/// Exposes our reagents and material to some temperature, letting them figure out how to react to it.
/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
	src.reagents?.temperature_reagents(exposed_temperature, exposed_volume, 350, 300, 1, cannot_be_cooled = cannot_be_cooled)
	src.material_trigger_on_temp(exposed_temperature)

/obj/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
	. = ..()
	if (istype(src.artifact,/datum/artifact))
		src.ArtifactStimulus("heat", exposed_temperature)

/// We react to the exposed temperature, call [/atom/proc/temperature_expose] on everything within us, and expose things within fluids to electricity if need be.
/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, source_of_heat, electric = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	src.material_trigger_on_temp(exposed_temperature)
	src.reagents?.temperature_reagents(exposed_temperature, exposed_volume, 350, 300, 1)
	if (electric) //mbc : i'm putting electric zaps on here because eleczaps ALWAYS happen alongside hotspot expose and i dont want to loop all atoms twice
		for (var/atom/movable/item as anything in src)
			item.temperature_expose(null, exposed_temperature, exposed_volume)
			if (item.flags & FLUID_SUBMERGE)
				item.electric_expose(electric)
	else
		for(var/atom/movable/item as anything in src)
			item.temperature_expose(null, exposed_temperature, exposed_volume)

/// * Checks if we should light on fire if we do not have a hotspot already. If we should and don't have one, spawns one.
/// * Returns: TRUE if we ignited or already have a hotspot, FALSE if we didn't make one or have one.
/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, source_of_heat, electric = FALSE)
	..()
	var/datum/gas_mixture/air_contents = src.return_air()

	if (!air_contents)
		return FALSE

	if (length(src.active_hotspots))
		if (locate(/obj/fire_foam) in src)
			for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
				qdel(hotspot)
			src.active_hotspots.len = 0
			return FALSE

		if (source_of_heat)
			/*  If we have a hotspot with sufficient gas, we set to the exposed_ args if the hotspot is lower and change our colour if needed.
				My best guess on why we need this is so mounted igniters and such don't cool down hotspots when used, only heating them up.
				I don't like how much effort was needed in renaming this var from "soh" and figuring out what it does - cringe */
			if ((air_contents.toxins > 0.5 MOLES) && (air_contents.oxygen > 0.5 MOLES))
				for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
					if (hotspot.temperature < exposed_temperature)
						hotspot.temperature = exposed_temperature
						hotspot.set_real_color()
					if (hotspot.volume < exposed_volume)
						hotspot.volume = exposed_volume
		return TRUE

	var/igniting = FALSE

	if ((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && (air_contents.toxins > 0.5))
		igniting = TRUE

	if (igniting)
		if (locate(/obj/fire_foam) in src)
			return FALSE

		if (air_contents.oxygen < 0.5 || air_contents.toxins < 0.5)
			return FALSE

		if (parent?.group_processing)
			parent.suspend_group_processing()

		src.add_hotspot(exposed_temperature, exposed_volume)

		for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
			hotspot.just_spawned = (current_cycle < air_master.current_cycle)
		//remove just_spawned protection if no longer processing this cell

	return igniting

/// Adds a hotspot to self if a previous one of the same type can not be found. Sets processing to true also, since a fire kinda should be processed.
/turf/proc/add_hotspot(temperature, volume, chemfire = null)
	var/atom/movable/hotspot/hotspot
	for (var/atom/movable/hotspot/selected as anything in src.active_hotspots)
		if ((istype(selected, /atom/movable/hotspot/chemfire) && chemfire) || (istype(selected, /atom/movable/hotspot/gasfire) && !chemfire))
			hotspot = selected
	if(isnull(hotspot))
		hotspot = !chemfire ? (new /atom/movable/hotspot/gasfire(src)) : (new /atom/movable/hotspot/chemfire(src, chemfire))
		src.active_hotspots += hotspot
	hotspot.temperature = temperature
	hotspot.volume = volume
	hotspot.set_real_color()
	if (issimulatedturf(src))
		var/turf/simulated/self = src
		self.processing = TRUE
		if(!self.parent)
			air_master.active_singletons[src] = null
	return hotspot

// ABSTRACT_TYPE(/atom/movable/hotspot) // i dont feel like touching code outside of atmos oh well
/// The object that represents fire ingame. Very nice and warm.
/atom/movable/hotspot
	mouse_opacity = 0
	anchored = ANCHORED_ALWAYS
	pass_unstable = FALSE
	flags = UNCRUSHABLE
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	plane = PLANE_ABOVE_LIGHTING

	icon = 'icons/effects/fire.dmi' //Icon for fire on turfs, also helps for nurturing small fires until they are full tile

	blend_mode = BLEND_ADD
#ifndef HOTSPOT_MEDIUM_LIGHTS
	var/datum/light/light
#endif
	/// Volume to expose to other atoms. Also used while [/atom/movable/hotspot/var/bypassing] is FALSE to act on a volume of gas on our turf.
	var/volume = 125
	/// Our temperature.
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	/// If we've just spawned then don't process yet, wait a cycle.
	var/just_spawned = TRUE
	/// If true, we've reached our last stage and should bypass processing reactions within ourselves.
	/// We may then start spreading heat and call [/turf/simulated/hotspot_expose] on other tiles.
	var/bypassing = FALSE
	/// Are we allowed to pass the temperature limit for non-catalysed fires?
	var/catalyst_active = FALSE

/atom/movable/hotspot/New(turf/newLoc, chemfire = null)
	..()
	START_TRACKING

#ifndef HOTSPOT_MEDIUM_LIGHTS
	light = new /datum/light/point
	light.set_brightness(0.5,queued_run = TRUE)
	light.attach(src)
	// note: light is left disabled until the color is set
#endif

/atom/movable/hotspot/disposing()
	STOP_TRACKING
#ifndef HOTSPOT_MEDIUM_LIGHTS
	light.disable(queued_run = TRUE)
#endif
	var/turf/simulated/floor/location = loc
	if (issimulatedturf(location))
		location.active_hotspots -= src
	..()

/// override. used to modify fire color and ambient light at any point of its lifetime
/atom/movable/hotspot/proc/set_real_color()
	return

/// Interact with our turf, performing reactions, scaling volume up, and exposing things on our turf while [/atom/movable/hotspot/var/bypassing] is FALSE,
/// and simply scaling up while it is set to TRUE.
/atom/movable/hotspot/proc/perform_exposure()
	var/turf/simulated/floor/location = loc
	if(!issimulatedturf(location))
		return FALSE

	if(src.volume > CELL_VOLUME*0.95)
		bypassing = TRUE
		if(!just_spawned)
			src.volume = location.air.fuel_burnt*FIRE_GROWTH_RATE
			src.temperature = location.air.temperature
	else
		bypassing = FALSE
		var/datum/gas_mixture/affected = location.air.remove_ratio(src.volume/max((location.air.volume/5),1))

		affected.temperature = src.temperature
		if( affected.react() & CATALYST_ACTIVE)
			src.catalyst_active = TRUE
		src.temperature = affected.temperature

		src.volume = affected.fuel_burnt*FIRE_GROWTH_RATE

		//Inhibit hotspot use as turf heats up to resolve abuse of hotspots unless catalyst is present...
		//Scale volume at 40% of HOTSPOT_MAX_TEMPERATURE to allow for hotspot icon to transition to 2nd state
		if(src.temperature > ( HOTSPOT_MAX_NOCAT_TEMPERATURE * 0.4 ))
			// Force volume as heat increases, scale to cell volume with tempurature to trigger hotspot bypass
			// Limit temperature based scaling to not exceed cell volume so spreading and exposure don't inappropriately scale
			var/max_temp = src.catalyst_active ? HOTSPOT_MAX_CAT_TEMPERATURE : HOTSPOT_MAX_NOCAT_TEMPERATURE
			var/temperature_scaled_volume = clamp((src.temperature * CELL_VOLUME / max_temp), 1, CELL_VOLUME)
			src.volume = max(src.volume, temperature_scaled_volume)

		location.assume_air(affected)

		for(var/atom/movable/AM as anything in location)
			AM.temperature_expose(null, temperature, src.volume)

	src.set_real_color()

///Temperature expose every atom that crosses us, burning living mobs that cross us.
/atom/movable/hotspot/Crossed(var/atom/A)
	..()
	A.temperature_expose(null, temperature, volume)
	if (isliving(A))
		var/mob/living/H = A
		var/B = clamp(temperature - 100 / 550, 0, 55)
		H.update_burning(B)

/// Process fire survival, mob burning, hotspot exposure, and heat radiation.
/atom/movable/hotspot/proc/process(list/turf/simulated/possible_spread)
	if (src.just_spawned)
		src.just_spawned = FALSE
		return FALSE

	var/turf/simulated/floor/location = src.loc
	if (!issimulatedturf(location) || (locate(/obj/fire_foam) in location))
		qdel(src)
		return FALSE

	if ((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (src.volume <= 1))
		qdel(src)
		return FALSE

	if (!location.air || location.air.toxins < 0.5 MOLES || location.air.oxygen < 0.5 MOLES)
		qdel(src)
		return FALSE

	for (var/mob/living/L in src.loc)
		L.update_burning(clamp(temperature / 60, 5, 33))

	src.perform_exposure()
	if(src.catalyst_active)
		var/image/catalyst_overlay = SafeGetOverlayImage("catalyst", src.icon, src.icon_state)
		var/list/rgb =  rgb2num(src.color)
		var/list/hsl = rgb2hsl(rgb[1],rgb[2],rgb[3])
		var/new_color = hsl2rgb(hsl[1]+60%255, clamp(hsl[2],50,180), hsl[3]*0.8)
		var/hue_shift = normalize_color_to_matrix(new_color)

		catalyst_overlay.appearance_flags = RESET_COLOR
		if(length(hue_shift))
			var/base_alpha = 0.3
			var/add_alpha = 0.2
			hue_shift[4] = add_alpha
			hue_shift[8] = add_alpha
			hue_shift[12] = add_alpha
			hue_shift[16] = -1
			hue_shift[20] = base_alpha
			catalyst_overlay.color = hue_shift
			AddOverlays(catalyst_overlay,"catalyst")
	else
		ClearSpecificOverlays("catalyst")


	src.catalyst_active = FALSE
	location.wet = 0

	if (bypassing)
		if (istype(src, /atom/movable/hotspot/gasfire))
			src.UpdateIcon("3")
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE

			for(var/turf/simulated/possible_target as anything in possible_spread)
				if(!length(possible_target.active_hotspots))
					possible_target.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else if (istype(src, /atom/movable/hotspot/gasfire))
		if (volume > (CELL_VOLUME * 0.4))
			src.UpdateIcon("2")
		else
			src.UpdateIcon("1")

	return TRUE


/atom/movable/hotspot/ex_act()
	return

/// fire created by a gaseous source. or atmos fire.
/atom/movable/hotspot/gasfire
	icon = 'icons/effects/fire_atmospheric.dmi'
	icon_state = "1"
	appearance_flags = TILE_BOUND // prevents fires laying against walls from showing over the wall
	alpha = 160
	pixel_x = -16

/atom/movable/hotspot/gasfire/New(turf/newLoc)
	..()
	src.set_dir(pick(cardinal))

/atom/movable/hotspot/gasfire/update_icon(base_icon)
	..()
	if (QDELETED(src)) // covers cases like building a wall over a fire
		src.icon_state = null
		src.remove_filter("fire-NW-alphamask")
		src.remove_filter("fire-NE-alphamask")
		return
	var/turf/north_turf = get_step(src, NORTH)
	var/turf/east_turf = get_step(src, EAST)
	var/turf/west_turf = get_step(src, WEST)

	var/north_valid = !IS_VALID_FLUID_TURF(north_turf) && IS_PERSPECTIVE_WALL(north_turf)
	if (!north_valid)
		for (var/obj/O in north_turf)
			if (IS_PERSPECTIVE_BLOCK(O))
				if (locate(/obj/hotspot/gasfire) in north_turf)
					break
				north_valid = TRUE
				break
	var/east_valid = !IS_VALID_FLUID_TURF(east_turf) && IS_PERSPECTIVE_WALL(east_turf)
	if (!east_valid)
		for (var/obj/O in east_turf)
			if (IS_PERSPECTIVE_BLOCK(O))
				if (locate(/obj/hotspot/gasfire) in east_turf)
					break
				east_valid = TRUE
				break
	var/west_valid = !IS_VALID_FLUID_TURF(west_turf) && IS_PERSPECTIVE_WALL(west_turf)
	if (!west_valid)
		for (var/obj/O in west_turf)
			if (IS_PERSPECTIVE_BLOCK(O))
				if (locate(/obj/hotspot/gasfire) in west_turf)
					break
				west_valid = TRUE
				break

	if (north_valid)
		if (east_valid && west_valid)
			src.icon_state = "[base_icon]-NEW"
		else if (east_valid && !west_valid)
			src.icon_state = "[base_icon]-NE"
		else if (!east_valid && west_valid)
			src.icon_state = "[base_icon]-NW"
		else
			src.icon_state = "[base_icon]-N"
	else if (east_valid)
		if (west_valid)
			src.icon_state = "[base_icon]-EW"
		else
			src.icon_state = "[base_icon]-E"
	else if (west_valid)
		src.icon_state = "[base_icon]-W"
	else
		src.icon_state = "[base_icon]"

	src.remove_filter("fire-NW-alphamask")
	src.remove_filter("fire-NE-alphamask")
	if (!north_valid)
		return
	var/atom/movable/hotspot/gasfire = locate(/atom/movable/hotspot/gasfire) in get_step(src, NORTHWEST)
	if (gasfire)
		src.add_filter("fire-NW-alphamask", 0, alpha_mask_filter(icon = icon(src.icon, "NW-alpha"), flags = MASK_INVERSE))
	gasfire = locate(/atom/movable/hotspot/gasfire) in get_step(src, NORTHEAST)
	if (gasfire)
		src.add_filter("fire-NE-alphamask", 0, alpha_mask_filter(icon = icon(src.icon, "NE-alpha"), flags = MASK_INVERSE))

// now this is ss13 level code
/// Converts our temperature into an approximate color based on blackbody radiation.
/atom/movable/hotspot/gasfire/set_real_color()
	var/input = temperature / 100
	var/red
	var/green
	var/blue
	if (input <= 66)
		red = 255
		green = 99.4708025861 * log(max(0.001, input)) - 161.1195681661
		if (input <= 19)
			blue = 0
		else
			blue = 138.5177312231 * log(input - 10) - 305.0447927307
	else
		red = 329.698727446 * ((input - 60) ** -0.1332047592)
		green = 288.1221695283 * ((input - 60) ** -0.0755148492)
		blue = 255
	red = clamp(red, 0, 255)
	green = clamp(green, 0, 255)
	blue = clamp(blue, 0, 255)

	color = rgb(red, green, blue) //changing obj.color is not expensive, and smooths imperfect light transitions

	// dear lord i apologise for this conditional which i am about to write and commit. please be with the starving pygmies down in new guinea amen //zewaka is no longer apologuizing

	//hello yes now it's ZeWaka with an even more hellcode implementation that makes no sense
	//scientific reasoning provided by Mokrzycki, Wojciech & Tatol, Maciej. (2011).

#ifndef HOTSPOT_MEDIUM_LIGHTS
	var/red_mean = ((red + light.r*255) /2) // mean of R components in the two compared colors

	var/deltaR2 = (red   - (light.r*255))**2
	var/deltaG2 = (blue  - (light.b*255))**2
	var/deltaB2 = (green - (light.g*255))**2
#else
	var/list/curc = medium_light_rgbas?["hotspot"] || list(0, 0, 0, 100)
	var/red_mean = ((red + curc[1]) /2) // mean of R components in the two compared colors
	var/deltaR2 = (red   - (curc[1]))**2
	var/deltaG2 = (blue  - (curc[2]))**2
	var/deltaB2 = (green - (curc[3]))**2
#endif

	//this is our weighted euclidean distance function, weights based on red component
	var/color_delta = ( (((512+red_mean)*(deltaR2**2))>>8) + (4*(deltaG2**2)) + (((767-red_mean)*(deltaB2**2))>>8) )

	//DEBUG_MESSAGE("[x],[y]:[temperature], d:[color_delta], [red]|[green]|[blue] vs [light.r*255]|[light.g*255]|[light.b*255]")

	if (color_delta > 144) //determined via E'' sampling in science paper above, 144=12^2

#ifndef HOTSPOT_MEDIUM_LIGHTS
		light.set_color(red, green, blue, queued_run = 1)
		light.enable(queued_run = 1)
#else
		add_medium_light("hotspot", list(red, green, blue, 100))
#endif

/// chemical/magical fire. represents a fire coming from a chemical or magical source
/atom/movable/hotspot/chemfire
	icon = 'icons/effects/fire_chemical.dmi'
	icon_state = "red_full-1"
	plane = PLANE_NOSHADOW_BELOW
	layer = OBJ_LAYER - 0.2 // so that part of the fire appears behind objects. 0.2 to account for vending machine, etc layering
	blend_mode = BLEND_DEFAULT

	var/fire_color = CHEM_FIRE_RED

	var/color_set = FALSE
	var/over_state
	var/under_state

// chemfire - use a chem_fire define
/atom/movable/hotspot/chemfire/New(turf/newLoc, chemfire)
	..()
	src.fire_color = chemfire

	src.over_state = pick(1, 2)
	src.under_state = pick(1, 2)
	// base fire that appears behind turf contents
	src.icon_state = chemfire + "_under-[under_state]"

	// fire puff effects that will rise over vertically adjacent fires, for a nicer appearance
	var/image/im1 = image(src.icon, src, chemfire + "_fx-[under_state]", NOLIGHT_EFFECTS_LAYER_BASE - 0.01)
	src.AddOverlays(im1, "fire-fx")

	UpdateIcon()
	src.update_neighbors()

/atom/movable/hotspot/chemfire/disposing()
	var/turf/T = get_turf(src)
	. = ..()
	src.update_neighbors(T)

/atom/movable/hotspot/chemfire/proc/update_neighbors(turf/T)
	if(!T)
		T = get_turf(src)
	for (var/atom/movable/hotspot/chemfire/C in orange(1,T))
		C.UpdateIcon()

/atom/movable/hotspot/chemfire/update_icon()
	var/connectdir = get_connected_directions_bitflag(list(src.type=TRUE), null, TRUE, FALSE)
	var/side_connect = connectdir & (EAST | WEST)
	var/third_row = connectdir & (SOUTH)

	var/image/im2
	if(side_connect)
		src.icon_state = src.fire_color + "_under-[under_state]-[side_connect]"
		im2 = image(src.icon, src, src.fire_color + "_over-[over_state]-[side_connect]", NOLIGHT_EFFECTS_LAYER_BASE - 0.02)
	else
		src.icon_state = src.fire_color + "_under-[under_state]"
		im2 = image(src.icon, src, src.fire_color + "_over-[over_state]", NOLIGHT_EFFECTS_LAYER_BASE - 0.02)

	im2.plane = PLANE_NOSHADOW_ABOVE
	im2.filters += filter(type="alpha", icon=icon('icons/effects/fire_chemical.dmi', "alpha"), y=-10)
	src.AddOverlays(im2, "fire-over")

	if(third_row)
		var/image/im3
		var/image/im4
		if(side_connect)
			im3 = image(src.icon, src, src.fire_color + "_under-[over_state]-[side_connect]", OBJ_LAYER - 0.2, pixel_y=-20)
			im4 = image(src.icon, src, src.fire_color + "_under-[over_state]-[side_connect]", NOLIGHT_EFFECTS_LAYER_BASE - 0.02, pixel_y=-20)
		else
			im3 = image(src.icon, src, src.fire_color + "_under-[over_state]", OBJ_LAYER - 0.2, pixel_y=-20)
			im4 = image(src.icon, src, src.fire_color + "_under-[over_state]", NOLIGHT_EFFECTS_LAYER_BASE - 0.02, pixel_y=-20)


		//Seperate overlay into two parts, one that overlays this one and one that is below
		src.AddOverlays(im3, "fire-under2")
		im4.plane = PLANE_NOSHADOW_ABOVE
		im4.filters += filter(type="alpha", icon=icon('icons/effects/fire_chemical.dmi', "alpha"), y=20)
		src.AddOverlays(im4, "fire-over2")
	else
		src.ClearSpecificOverlays("fire-under2")

/atom/movable/hotspot/chemfire/set_real_color()
	if (src.color_set)
		return

	src.color_set = TRUE

	// no particular reason for color values chosen in this proc, just based off what worked
	var/list/rgb
	switch (src.fire_color)
		if (CHEM_FIRE_RED)
			rgb = list(50, 0, 0)
		if (CHEM_FIRE_DARKRED)
			rgb = list(10, 0, 0)
		if (CHEM_FIRE_BLUE)
			rgb = list(0, 0, 50)
		if (CHEM_FIRE_GREEN)
			rgb = list(0, 50, 0)
		if (CHEM_FIRE_YELLOW)
			rgb = list(50, 50, 0)
		if (CHEM_FIRE_PURPLE)
			rgb = list(50, 0, 50)
		if (CHEM_FIRE_BLACK)
			rgb = list(0, 0, 0)
		if (CHEM_FIRE_WHITE)
			rgb = list(50, 50, 50)
	src.add_medium_light("fire_lightup", list(65, 65, 65, 100))
	src.add_medium_light("fire_color_highlight", list(rgb[1], rgb[2], rgb[3], 100))
