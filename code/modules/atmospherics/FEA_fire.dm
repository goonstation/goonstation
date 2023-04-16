#define HOTSPOT_MEDIUM_LIGHTS

/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if (reagents)
		reagents.temperature_reagents(exposed_temperature, exposed_volume, 350, 300, 1)
	if (src.material)
		src.material.triggerTemp(src, exposed_temperature)
	return null

/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh,electric = 0)
	SHOULD_CALL_PARENT(TRUE)
	if (src.material)
		src.material.triggerTemp(src, exposed_temperature)
	if (reagents)
		reagents.temperature_reagents(exposed_temperature, exposed_volume, 350, 300, 1)
	if(!ON_COOLDOWN(src, "hotspot_expose_to_atoms__1", 1 SECOND) || !ON_COOLDOWN(src, "hotspot_expose_to_atoms__2", 1 SECOND) || !ON_COOLDOWN(src, "hotspot_expose_to_atoms__3", 1 SECOND) || !ON_COOLDOWN(src, "hotspot_expose_to_atoms__4", 1 SECOND) || !ON_COOLDOWN(src, "hotspot_expose_to_atoms__5", 1 SECOND))
		if (electric) //mbc : i'm putting electric zaps on here because eleczaps ALWAYS happen alongside hotspot expose and i dont want to loop all atoms twice
			for (var/atom/item in src) //I hate having to add this here too but too many things use hotspot_expose. This might cause lag on large fires.
				item.temperature_expose(null, exposed_temperature, exposed_volume)
				if (item?.flags & FLUID_SUBMERGE)
					item.electric_expose(electric)
		else
			for(var/atom/item in src) //I hate having to add this here too but too many things use hotspot_expose. This might cause lag on large fires.
				item.temperature_expose(null, exposed_temperature, exposed_volume)



/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh, electric = 0)
	. = ..()
	var/datum/gas_mixture/air_contents = return_air()


	if (!air_contents)
		return 0

	if (active_hotspot)
		if (locate(/obj/fire_foam) in src)
			active_hotspot.dispose() // have to call this now to force the lighting cleanup
			qdel(active_hotspot)
			active_hotspot = null

		if (soh)
			if ((air_contents.toxins > 0.5) && (air_contents.oxygen > 0.5))
				if (active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
					active_hotspot.set_real_color()
				if (active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1

	var/igniting = 0

	if ((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && (air_contents.toxins > 0.5))
		igniting = 1

	if (igniting)

		if (locate(/obj/fire_foam) in src) return 0

		if (air_contents.oxygen < 0.5 || air_contents.toxins < 0.5)
			return 0

		if (parent?.group_processing)
			parent.suspend_group_processing()

		active_hotspot = new /obj/hotspot
		active_hotspot.temperature = exposed_temperature
		active_hotspot.volume = exposed_volume
		active_hotspot.set_loc(src)
		active_hotspot.set_real_color()

		active_hotspot.just_spawned = (current_cycle < air_master.current_cycle)
			//remove just_spawned protection if no longer processing this cell

	return igniting

/obj/hotspot
	mouse_opacity = 0
	anchored = ANCHORED_ALWAYS
	flags = UNCRUSHABLE
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	plane = PLANE_ABOVE_LIGHTING

	icon = 'icons/effects/fire.dmi' //Icon for fire on turfs, also helps for nurturing small fires until they are full tile
	icon_state = "1"

	//layer = TURF_LAYER
	alpha = 160
	blend_mode = BLEND_ADD
#ifndef HOTSPOT_MEDIUM_LIGHTS
	var/datum/light/light
#endif

	animate_movement = NO_STEPS // fix for weird unpool sliding

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	var/just_spawned = 1
	var/bypassing = 0
	var/catalyst_active = FALSE

	New()
		..()
		START_TRACKING
		set_dir(pick(cardinal))
#ifndef HOTSPOT_MEDIUM_LIGHTS
		light = new /datum/light/point
		light.set_brightness(0.5,queued_run = 1)
		light.attach(src)
		// note: light is left disabled until the color is set
#endif

	disposing()
		STOP_TRACKING
#ifndef HOTSPOT_MEDIUM_LIGHTS
		light.disable(queued_run = 1)
#endif
		var/turf/simulated/floor/location = loc
		if (istype(location))
			location.active_hotspot = null
		..()

	// now this is ss13 level code
	proc/set_real_color()
		var/input = temperature / 100

		var/red
		if (input <= 66)
			red = 255
		else
			red = input - 60
			red = 329.698727446 * (red ** -0.1332047592)
		red = clamp(red, 0, 255)

		var/green
		if (input <= 66)
			green = max(0.001, input)
			green = 99.4708025861 * log(green) - 161.1195681661
		else
			green = input - 60
			green = 288.1221695283 * (green ** -0.0755148492)
		green = clamp(green, 0, 255)

		var/blue
		if (input >= 66)
			blue = 255
		else
			if (input <= 19)
				blue = 0
			else
				blue = input - 10
				blue = 138.5177312231 * log(blue) - 305.0447927307
		blue = clamp(blue, 0, 255)

		color = rgb(red, green, blue) //changing obj.color is not expensive, and smooths imperfect light transitions

		// dear lord i apologuize for this conditional which i am about to write and commit. please be with the starving pygmies down in new guinea amen

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

	proc/perform_exposure()
		var/turf/simulated/floor/location = loc
		if(!istype(location))
			return 0

		if(src.volume > CELL_VOLUME*0.95)
			bypassing = 1
		else
			bypassing = 0

		if(bypassing)
			if(!just_spawned)
				src.volume = location.air.fuel_burnt*FIRE_GROWTH_RATE
				src.temperature = location.air.temperature
		else
			var/datum/gas_mixture/affected = location.air.remove_ratio(src.volume/max((location.air.volume/5),1))

			affected.temperature = src.temperature
			affected.react()
			src.temperature = affected.temperature

			src.volume = affected.fuel_burnt*FIRE_GROWTH_RATE

			//Inhibit hotspot use as turf heats up to resolve abuse of hotspots unless catalyst is present...
			//Scale volume at 40% of HOTSPOT_MAX_TEMPERATURE to allow for hotspot icon to transition to 2nd state
			if(src.temperature > ( HOTSPOT_MAX_NOCAT_TEMPERATURE * 0.4 ))
				// Force volume as heat increases, scale to cell volume with tempurature to trigger hotspot bypass
				var/max_temp = HOTSPOT_MAX_NOCAT_TEMPERATURE
				if(src.catalyst_active)
					// Limit temperature based scaling to not exceed cell volume so spreading and exposure don't inappropriately scale
					max_temp = HOTSPOT_MAX_CAT_TEMPERATURE
				var/temperature_scaled_volume = clamp((src.temperature * CELL_VOLUME /  max_temp), 1, CELL_VOLUME)
				src.volume = max(src.volume, temperature_scaled_volume)

			location.assume_air(affected)

			for(var/obj/object as anything in location)
				object.temperature_expose(null, temperature, src.volume)

		set_real_color()

	Crossed(var/atom/A)
		..()
		A.temperature_expose(null, temperature, volume)
		if (isliving(A))
			var/mob/living/H = A
			var/B = clamp(temperature - 100 / 550, 0, 55)
			H.update_burning(B)

	proc/process(list/turf/simulated/possible_spread)
		if (just_spawned)
			just_spawned = 0
			return 0

		var/turf/simulated/floor/location = loc
		if (!istype(location) || (locate(/obj/fire_foam) in location))
			qdel(src)
			return 0

		if ((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
			qdel(src)
			return 0

		if (!location.air || location.air.toxins < 0.5 || location.air.oxygen < 0.5)
			qdel(src)
			return 0

		for (var/mob/living/L in loc)
			L.update_burning(clamp(temperature / 60, 5, 33))

		perform_exposure()

		if (catalyst_active) catalyst_active = FALSE
		if (location.wet) location.wet = 0

		if (bypassing)
			icon_state = "3"
			location.burn_tile()

			//Possible spread due to radiated heat
			if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
				var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE

				for(var/turf/simulated/possible_target in possible_spread)
					if(!possible_target.active_hotspot)
						possible_target.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

		else
			if (volume > (CELL_VOLUME * 0.4))
				icon_state = "2"
			else
				icon_state = "1"

		return 1

	ex_act()
		return
