var/global/list/datum/daynight_controller/daynight_controllers = list(AMBIENT_LIGHT_SRC_EARTH=new /datum/daynight_controller/earth,
																	  AMBIENT_LIGHT_SRC_OCEAN=new /datum/daynight_controller/ocean,
																	  AMBIENT_LIGHT_SRC_TERRAINIFY=new /datum/daynight_controller/terrainify
																	 )

/datum/daynight_controller
	// The daynight controller is responsible for managing the in-game time and triggering day/night cycles.
	var/active = TRUE	// Whether the controller is active or not
	var/initial_time = 0	// The time (in ticks) that the controller was set to when placed. Used for resetting.
	var/speed = 1	// The speed multiplier for time progression. 1 is normal speed, 2 is double speed, etc.
	var/cycle = 24 HOURS	// The length of a full day/night cycle in minutes. Default is 1440 (24 hours).
	var/time = 0	// The current time in ticks.
	var/last_update = 0	// The last time (in ticks) the time was updated
	var/ambient_light_source = AMBIENT_LIGHT_SRC_INVLD
	var/current_color
	var/obj/ambient/light
	var/atom/movable/screen/ambient_lighting/ambient_screen

	New()
		. = ..()
		src.initial_time =   BUILD_TIME_HOUR HOURS + BUILD_TIME_MINUTE MINUTES + BUILD_TIME_SECOND SECONDS
		src.time = initial_time
		light = new
		ambient_screen = new

		process()

		update_color( calculate_color(src.time) )

	proc/initialize()
		return

	proc/process()
		if (!active)
			return

		var/current_tick = world.timeofday
		var/delta_ticks = current_tick - src.last_update
		if (delta_ticks <= 0)
			return

		src.time = (src.time + ( delta_ticks * src.speed)) % src.cycle

		update_color( calculate_color(src.time) )

		src.last_update = current_tick

	proc/calculate_color(tick)
		return "#888"

	proc/update_color(new_color)
		if(current_color != new_color)
			current_color = new_color
			if(istype(light))
				animate(light, color=new_color, time=10 SECONDS)
			if(istype(ambient_screen))
				animate(ambient_screen, color=new_color, time=10 SECONDS)

	proc/generate_color_samples()
		var/list/colors = list()
		var/samples = 24
		if(cycle)
			for(var/i = 0; i < samples; i++)
				colors += calculate_color(i * (src.cycle / samples))
		else
			colors += current_color
		return colors


/datum/daynight_controller/earth
	ambient_light_source = AMBIENT_LIGHT_SRC_EARTH

	calculate_color(tick)
		// Update lighting based on sun position
		var/sun_color

		var/hours = floor(tick/(1 HOUR))
		switch(hours)
			if(7)
				sun_color =  rgb(255 * 0.01, 255 * 0.01, 255 * 0.01)	// night time
			if(8)
				sun_color =  rgb(255 * 0.005, 255 * 0.005, 255 * 0.01)	// night time
			if(9)
				sun_color =  rgb(255 * 0.00, 255 * 0.00, 255 * 0.005)	// night time
			if(10)
				sun_color =  rgb(255 * 0.00, 255 * 0.00, 255 * 0.00)	// night time
			if(11)
				sun_color =  rgb(255 * 0.02, 255 * 0.02, 255 * 0.02)	// night time
			if(12)
				sun_color =  rgb(255 * 0.05, 255 * 0.05, 255 * 0.05)	// night time
			if(13)
				sun_color =  rgb(181 * 0.25, 205 * 0.25, 255 * 0.25)	// 17000
			if(14)
				sun_color =  rgb(202 * 0.60, 218 * 0.60, 255 * 0.60)	// 10000
			if(15)
				sun_color =  rgb(221 * 0.95, 230 * 0.95, 255 * 0.95)	// 8000 (sunrise)
			if(16)
				sun_color =  rgb(210 * 1.00, 223 * 1.00, 255 * 1.00)	// 11000
			if(17)
				sun_color =  rgb(196 * 1.00, 214 * 1.00, 255 * 1.00)	// 10000
			if(18)
				sun_color =  rgb(221 * 1.00, 230 * 1.00, 255 * 1.00)	// 8000
			if(19)
				sun_color =  rgb(230 * 1.00, 235 * 1.00, 255 * 1.00)	// 7500-ish
			if(20)
				sun_color =  rgb(243 * 1.00, 242 * 1.00, 255 * 1.00)	// 7000
			if(21)
				sun_color =  rgb(255 * 1.00, 250 * 1.00, 244 * 1.00)	// 6250-ish
			if(22)
				sun_color =  rgb(255 * 1.00, 243 * 1.00, 231 * 1.00)	// 5800-ish
			if(23)
				sun_color =  rgb(255 * 1.00, 232 * 1.00, 213 * 1.00)	// 5200-ish
			if(0)
				sun_color =  rgb(255 * 0.95, 206 * 0.95, 166 * 0.95)	// 4000
			if(1)
				sun_color =  rgb(255 * 0.90, 146 * 0.90,  39 * 0.90)	// 2200 (sunset), "golden hour"
			if(2)
				sun_color =  rgb(196 * 0.50, 214 * 0.50, 255 * 0.50)	// 10000
			if(3)
				sun_color =  rgb(191 * 0.21, 211 * 0.20, 255 * 0.30)	// 12000 (moon / stars), "blue hour"
			if(4)
				sun_color =  rgb(218 * 0.10, 228 * 0.10, 255 * 0.13)	// 8250
			if(5)
				sun_color =  rgb(221 * 0.04, 230 * 0.04, 255 * 0.05)	// 8000
			if(6)
				sun_color =  rgb(243 * 0.01, 242 * 0.01, 255 * 0.02)	// 7000
			else
				sun_color =  rgb(255 * 1.00, 255 * 1.00, 255 * 1.00)	// uhhhhhh

		. = sun_color


/datum/daynight_controller/ocean
	ambient_light_source = AMBIENT_LIGHT_SRC_OCEAN

	calculate_color(tick)
		var/sky_color

		var/hours = floor(tick/(1 HOUR))
		switch(hours)
#ifdef MAP_OVERRIDE_NADIR
	// nadir has an 8 hour rotation, but is somewhat evenly lit by both shidd and fugg, as it's quite far from typhone (royal rings district)
	// the redness increases as fugg (Fugere) rises, and the blueness (and greenness) increases as Shidd (Šid) rises. Still pretty dark most of the time though.
	// shidd and fugg are on opposite sides of the sky, so as one sets, the other rises.
			if(0, 8, 16)
				sky_color = rgb(0.10 * 128, 0.10 * 128, 1.00 *  75, 0.65 * 255)
			if(1, 9, 17)
				sky_color = rgb(0.10 *  64, 0.10 * 191, 1.00 *  88, 0.65 * 255)
			if(2, 10, 18)
				sky_color = rgb(0.10 *   0, 0.10 * 255, 1.00 * 100, 0.65 * 255) // noon (shidd) rgb(0,26,100), quite bluey
			if(3, 11, 19)
				sky_color = rgb(0.10 *  64, 0.10 * 191, 1.00 *  88, 0.65 * 255)
			if(4, 12, 20)
				sky_color = rgb(0.10 * 128, 0.10 * 128, 1.00 *  75, 0.65 * 255)
			if(5, 13, 21)
				sky_color = rgb(0.10 * 191, 0.10 *  64, 1.00 *  62, 0.65 * 255)
			if(6, 14, 22)
				sky_color = rgb(0.10 * 255, 0.10 *   0, 1.00 *  50, 0.65 * 255) // noon (fugg) rgb(26,0,50), some red tones, more purple
			if(7, 15, 23)
				sky_color = rgb(0.10 * 191, 0.10 *  64, 1.00 *  62, 0.65 * 255)
#else // Abzu - oshan (and manta too technically), we're just going to say that fugg has noon exactly at shidd's midnight because we want a nice reddish glow during the night
			if(0, 12) // shidd noon, fugg midnight
				sky_color = rgb(0.160 *   0, 0.60 * 255, 1.00 * 255, 0.65 * 255)
			if(1, 13)
				sky_color = rgb(0.160 *  18, 0.60 * 236, 1.00 * 255, 0.65 * 255)
			if(2, 14)
				sky_color = rgb(0.160 *  63, 0.60 * 187, 1.00 * 236, 0.65 * 255)
			if(3, 15)
				sky_color = rgb(0.160 * 125, 0.60 * 125, 1.00 * 125, 0.65 * 255)
			if(4, 16)
				sky_color = rgb(0.160 * 187, 0.60 *  63, 1.00 *  63, 0.65 * 255)
			if(5, 17)
				sky_color = rgb(0.2   * 236, 0.60 *  18, 1.00 *  18, 0.65 * 255)
			if(6, 18) // shidd mignight, fugg noon
				sky_color = rgb(0.25   * 255, 0.60 * 23, 1.00 *   0, 0.65 * 255)
			if(7, 19)
				sky_color = rgb(0.2   * 236, 0.60 *  18, 1.00 *  18, 0.65 * 255)
			if(8, 20)
				sky_color = rgb(0.160 * 187, 0.60 *  63, 1.00 *  63, 0.65 * 255)
			if(9, 21)
				sky_color = rgb(0.160 * 125, 0.60 * 125, 1.00 * 125, 0.65 * 255)
			if(10, 22)
				sky_color = rgb(0.160 *  63, 0.60 * 187, 1.00 * 236, 0.65 * 255)
			if(11, 23)
				sky_color = rgb(0.160 *  18, 0.60 * 236, 1.00 * 255, 0.65 * 255)
#endif
		. = sky_color


/datum/daynight_controller/terrainify
	ambient_light_source = AMBIENT_LIGHT_SRC_TERRAINIFY
	var/color1 = "#cfcfcf"
	var/color2 = "#000"
	cycle = 40 MINUTES

	initialize(color1, color2, cycle)
		src.color1 = color1
		src.color2 = color2
		src.cycle = cycle

		if(cycle)
			process()
		else
			src.light.color	= color1

	calculate_color(tick)

		var/color1_cycle = (-cos(360*(tick / src.cycle)+30)+1) / 2 // 0 to 1 over the course of the cycle
		var/color2_cycle = (-cos(360*(tick / src.cycle)-30)+1) / 2

		var/list/color1_rgb = rgb2num(color1)
		var/list/color2_rgb = rgb2num(color2)

		var/new_color = rgb( color1_rgb[1]*color1_cycle+color2_rgb[1]*color2_cycle, \
					color1_rgb[2]*color1_cycle+color2_rgb[2]*color2_cycle, \
					color1_rgb[3]*color1_cycle+color2_rgb[3]*color2_cycle)

		// Update ambient light color if it has changed
		. = new_color
