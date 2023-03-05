/// not eclipsing
#define ECLIPSE_FALSE 0
/// partial eclipse, leading into the peak
#define ECLIPSE_PENUMBRA_WAXING 1
// partial eclipse, leading out of the peak
#define ECLIPSE_PENUMBRA_WANING 2
/// total eclipse or annular. Which one it is is determined by eclipse_magnitude. Not the same as ECLIPSE_PARTIAL
#define ECLIPSE_UMBRA 4
/// a partial eclipse, with no peak. In code this means a peak of 0 seconds.
#define ECLIPSE_PARTIAL 5
/// daytime: like ECLIPSE_FALSE but on the ground.
#define ECLIPSE_TERRESTRIAL 6
/// night time lol. The planet you're on is eclipsing your view of the sun.
#define ECLIPSE_PLANETARY 7
/// for when the game doesn't know what's happening (e.g. admin nonsense)
#define ECLIPSE_ERROR 8

/// which areas should the 'global' sun ignore
var/global/list/areas_with_local_suns = new
/datum/sun
	var/angle
	var/dx
	var/dy
	var/counter = 20 // to make the vars update during 1st call
	var/rate

	//stuff gets complicated starting from here.
	//jargon i use: global sun means for the whole z level, local sun means it overrides the global in an area.
	/// The datum/area which this star applies to. Generally used for z areas like centcomm. Null means all of z1.
	var/area/sun_area = null
	/// which z level does this star apply to? mainly for debris and mining fields
	var/zlevel = 1
	/// Is it around Shidd, Fugg, or Typhon? Or the Sun?
	var/name = "unknown"
	/// where does this apply exactly? Where are we?
	var/stationloc = null
	/// flavour text for the tracker
	var/desc

	// these time vars below theoretically use time units like SECOND and MINUTE, so 1 = 1/10 of a second
	/// How often do eclipses happen? It's the length of the whole cycle, so it needs to be = to eclipse_time + penumbra_time + downtime
	var/eclipse_cycle_length = 0
	/// a counter for cycling through the eclipse
	var/eclipse_counter = 20
	/// How long does it take to transition from not eclipsing to eclipsing.
	var/penumbra_time = 0
	/// How long is the peak of the eclipse? 0 is just a default fallback value
	var/eclipse_time = 0
	/// How much time is spent not in eclipse?
	var/down_time = 0

	/// At the peak, what's the minimum star visibility? Percentage where 1=100% (total eclipse). This being below 1 makes the peak annular.
	var/eclipse_magnitude = 1
	/// which stage of the eclipse are we in?
	var/eclipse_status = ECLIPSE_FALSE
	/// do we calculate the eclipse cycle? False for stuff like earth/abzu's rotation (or just no eclipse), since that's calculated at build
	var/eclipse_cycle_on = FALSE
	/// what kind of eclipses happen in the cycle? Saves the order of eclipse events so we can go to the next easily
	var/list/eclipse_order = list(ECLIPSE_FALSE)
	/// what percentage of light reaches us? 1 is 100%, 0 is 0%. Changes as the eclipse does. Cloud cover changes this too i guess. Max is 1
	var/visibility = 1
	/// At 100% visibility, at what efficiency do the solars work? Based on inverse square of distance to star. Also a percentage, with 1 = 100%
	var/photovoltaic_efficiency = 1

/// This can be called if the station is teleported, as well as at build, hence it being a separate proc.
/datum/sun/proc/identity_check()
	if (src.stationloc == "mining" || src.stationloc == "debris")
	else if (isnull(src.sun_area)) // global sun only
		src.stationloc = "void"
		#if defined(MAP_OVERRIDE_DESTINY)
		src.stationloc = "travel"
		#elif defined(MAP_OVERRIDE_CLARION)
		src.stationloc = "travel"
		#elif defined(MAP_OVERRIDE_ATLAS)
		src.stationloc = "travel"
		#elif defined(MAP_OVERRIDE_COGMAP)
		src.stationloc = "13"
		#elif defined(MAP_OVERRIDE_COGMAP2)
		src.stationloc = "13"
		#elif defined(MAP_OVERRIDE_DONUT2)
		src.stationloc = "13"
		#elif defined(MAP_OVERRIDE_DONUT3)
		src.stationloc = "13"
		#elif defined(MAP_OVERRIDE_PAMGOC)
		src.stationloc = "13"
		#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
		src.stationloc = "abzu"
		#elif defined(MAP_OVERRIDE_MANTA)
		src.stationloc = "abzu"
		#elif defined(MAP_OVERRIDE_OSHAN)
		src.stationloc = "abzu"
		#elif defined(MAP_OVERRIDE_NADIR)
		src.stationloc = "magus"
		#endif
	switch (src.stationloc)
		if ("void")
			// for admin nonsense generally, also shuttle transit. Where no stars apply.
			src.desc = "The stars have abandoned you."
			src.eclipse_status = ECLIPSE_ERROR
			src.eclipse_order = list(ECLIPSE_ERROR)
			src.visibility = 0
			src.photovoltaic_efficiency = 0
			src.rate = 0
			src.angle = 0
		if ("trench")
			src.name = "N/A"
			src.desc = "Something appears to be obstructing the sun."
			src.eclipse_status = ECLIPSE_ERROR
			src.eclipse_order = list(ECLIPSE_ERROR)
			src.visibility = 0
			src.rate = 0
			src.angle = 0
		if ("13")
			/* Space Station 13, i.e. NT-13 in L2 lagrange point around Rota Fortuna.
			If the station truly sat at the L2 point, Typhon would be permanently eclipsed, but it's probably in a
			lissajous orbit around the umbra, making the lore reason for the solars turning is that the whole map is spinning.
			*/
			src.name = "Typhon"
			src.desc = "Station is currently in a stable Lissajous orbit around Rota Fortuna's second Langrangian Point."
			src.rate = rand(75,125)/50 // 75% - 125% of standard rotation
			if(prob(50))
				src.rate = -src.rate
			if (prob(50)) // this thing gives it a random eclipse
				src.eclipse_cycle_on = TRUE
				src.eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_PENUMBRA_WAXING, pick(ECLIPSE_PARTIAL, ECLIPSE_UMBRA), ECLIPSE_PENUMBRA_WANING)
				src.eclipse_magnitude = pick(1, rand(10,100)/100)
				src.eclipse_cycle_length = rand(20, 80) MINUTES
				src.eclipse_time = rand(10 SECONDS, 5 MINUTES)
			// is the default settings pre #13206, but with 50% chance of random eclipsing
		if ("travel")
			// for ship maps (in deep space). Uses a randomer randomiser
			src.photovoltaic_efficiency = rand(20,150)/100 // it could be anywhere ooo
			if (src.name == "unknown")
				src.name = pick("Typhon", "Fugg", "Shidd")
			src.desc = "Ship is currently in deep space, with its main lighting coming from [src.name]."
			src.rate = rand(70,160)/50 // more range than the default
			if(prob(50))
				src.rate = -rate
			if (prob(50)) // 50 50 chance of it going into shadow every so often
				src.eclipse_cycle_on = TRUE
				src.eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_PENUMBRA_WAXING, pick(ECLIPSE_PARTIAL, ECLIPSE_UMBRA), ECLIPSE_PENUMBRA_WANING)
				src.eclipse_magnitude = pick(1, rand(10,100)/100)
				src.eclipse_cycle_length = rand(100, 300) SECONDS
				src.eclipse_time = rand(10, 300) SECONDS
		if ("magus")
			//nadir. Magus has an 8 hour rotation compared to Typhon. However, it's far enough that its main lighting comes from Shidd or Fugg.
			#if (BUILD_TIME_HOUR <=3 || (BUILD_TIME_HOUR <= 11 && BUILD_TIME_HOUR >=8) || (BUILD_TIME_HOUR <= 19 && BUILD_TIME_HOUR >= 16))
			src.name = "Shidd" // the nadir lighting is bluer
			#else
			src.name = "Fugg" // the nadir lighting is redder/darker
			#endif
			src.desc = "The Nadir Extraction Site is located under miles of acid sea on Magus. The site is currently being lit by [src.name]."
			src.eclipse_status = ECLIPSE_TERRESTRIAL
			src.eclipse_order = list(ECLIPSE_TERRESTRIAL, ECLIPSE_TERRESTRIAL)
			src.rate = 0
			src.angle = 180 + (rand(90, 180) * pick(1, -1))
			src.visibility = 0.166 // the max sunlight is from shidd, the blue one.
			if (src.name == "Fugg") // the stars have different strengths, see. Based on the noon RGB values.
				src.photovoltaic_efficiency = 0.6
			else
				src.photovoltaic_efficiency = 1
			// you get 6% of 60% strength sunlight overall
		if ("abzu")
			//oshan and technically also manta
			src.name = "Shidd"
			src.desc = "The Oshan Laboratory is located under the seas of Abzu, and is lit by the blue-white light of its star, Shidd."
			src.visibility = 0.35 // time.dm shows alpha value 65% at noon, so
			src.eclipse_time = 6 HOURS
			src.eclipse_cycle_length = 12 HOURS
			src.eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			// note how the eclipse has details for computers and stuff but won't ever actually happen at runtime.
			if (BUILD_TIME_HOUR < 3 || BUILD_TIME_HOUR > 9 && BUILD_TIME_HOUR < 15 || BUILD_TIME_HOUR > 18)
				// oshan works off a 12 hour cycle, not 24
				src.eclipse_status = ECLIPSE_PLANETARY
				src.visibility = 0
			else
				src.eclipse_status = ECLIPSE_TERRESTRIAL
				src.visibility = rand(80,100)/100 // assuming cloud covers up to 20% of light
			// oshan is either in day or night. 'eclipses' i.e. sunrises/sunsets don't happen at runtime.
		if ("earth")
			//centcomm mainly. Same as oshan, day/night cycle is determined at build, not runtime.
			src.zlevel = 2
			src.name = "\improper Sun"
			src.desc = "The sun illuminates the surface of the Earth, as it has done for millions of years."
			src.eclipse_time = 12 HOURS
			src.eclipse_cycle_length = 24 HOURS
			src.eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			if (BUILD_TIME_HOUR < 6 || BUILD_TIME_HOUR >= 18)
				src.eclipse_status = ECLIPSE_PLANETARY
				src.visibility = 0
			else
				src.eclipse_status = ECLIPSE_TERRESTRIAL
				src.visibility = rand(80,100) // assuming cloud covers up to 20% of light
		if ("debris") // the debris field is in the main rings district
			src.name = "Typhon"
			src.desc = "Floating in the debris field, this area is illuminated far more strongly than the Mundus gap."
			src.zlevel = 3
			src.photovoltaic_efficiency = 2.5
			src.rate = rand(75,125)/50
			if(prob(50))
				src.rate = -src.rate
		if ("mining") // the mining level is canonically in the royal rings district, near magus
			src.zlevel = 5
			src.rate = 0
			src.angle = 180 + (rand(90, 180) * pick(1, -1))
			if (src.name == "unknown")
				src.name = pick("Fugg", "Shidd")
			src.desc = "The mining belt lies in the royal rings district, illuminated mostly by the binary stars and not Typhon."
			if (src.name == "Fugg")
				src.photovoltaic_efficiency = 0.3
			else
				src.photovoltaic_efficiency = 0.6

/datum/sun/New()
	..()

/// calculate the sun's position given the time of round, plus other things
/datum/sun/proc/calc_position()
	src.counter++ // this 'should' be every game tick, 1/10th of a second
	if (src.counter < 2 SECONDS)
		return
	src.counter = 0
	src.angle = ((src.rate * world.realtime/100)%360 + 360)%360
	/* used to give about a 60 minute rotation time.
	Now around 30 - 40 min, depending on rate. An array on one side would sometimes generate zero or close to zero electricity for up to 30 min
	of a typical round (~60 min), making solars not so useful.*/
#ifdef ECLIPSE_ERROR
	src.eclipse_order = list(ECLIPSE_ERROR)
	src.eclipse_cycle_on = FALSE
	src.visibility = 0
	src.photovoltaic_efficiency = 0
	src.rate = 0
	src.angle = 0
#endif
	if (src.eclipse_cycle_on)
		src.eclipse_counter ++ // this too should be every game tick
		switch (src.eclipse_status)
			if (ECLIPSE_FALSE)
				if (src.eclipse_counter >= src.down_time)
					src.eclipse_status = next_in_list(src.eclipse_status, src.eclipse_order)
					if (src.zlevel == 1 && isnull(src.sun_area))
						command_alert("An eclipse is occurring to the [station_or_ship()]. The eclipse is predicted to last for [time_to_text(src.eclipse_cycle_length-src.down_time)], and the output of solar panels will gradually reduce to a minimum of [(1 - src.eclipse_magnitude)*100]% output." , "Solar Eclipse", alert_origin = ALERT_WEATHER)
				else
					src.visibility = 1
			if (ECLIPSE_PENUMBRA_WAXING)
				if (src.eclipse_counter >= (src.down_time + src.penumbra_time))
					src.eclipse_status = next_in_list(src.eclipse_status, src.eclipse_order)
				else
					src.visibility -= ((1 - src.eclipse_magnitude) / src.penumbra_time)
			if (ECLIPSE_PENUMBRA_WANING)
				if (src.eclipse_counter >= src.eclipse_cycle_length)
					src.eclipse_status = next_in_list(src.eclipse_status, src.eclipse_order)
					src.eclipse_counter = 0
				else
					src.visibility += ((1 - src.eclipse_magnitude) / src.penumbra_time)
			if (ECLIPSE_PARTIAL)
				// not the same as annular eclipses. Think of light curves. This one has no flat peak.
				src.eclipse_status = next_in_list(src.eclipse_status, src.eclipse_order)
			if (ECLIPSE_UMBRA)
				if (src.eclipse_counter >= (src.down_time + src.penumbra_time + src.eclipse_time))
					src.eclipse_status = next_in_list(src.eclipse_status, src.eclipse_order)
					if (src.zlevel == 1 && isnull(src.sun_area))
						command_alert("The Solar Eclipse is now ending. The next one is predicted to be in [time_to_text(src.down_time)].", "Eclipse Ended", alert_origin = ALERT_WEATHER)
				else
					src.visibility = 1 - src.eclipse_magnitude
			// if (ECLIPSE_PLANETARY) planetary rotation isnt done at runtime so we dont need this

	// now calculate and cache the (dx,dy) increments for line drawing
	var/s = sin(angle)
	var/c = cos(angle)
	if(c == 0)
		src.dx = 0
		src.dy = s
	else if( abs(s) < abs(c))
		src.dx = s / abs(c)
		src.dy = c / abs(c)
	else
		src.dx = s / abs(s)
		src.dy = c / abs(s)

	for(var/obj/machinery/power/tracker/T in machine_registry[MACHINES_POWER])
		var/turf/dummy = get_turf(T)
		if (dummy.z != src.zlevel) // are we on the right z
			continue
		if (!isnull(src.sun_area)) // local suns
			if (get_area(dummy) != src.sun_area) // if local, are we in the right spot
				continue
		else // global sun (applies to whole z level)
			var/ignoreme = FALSE
			for (var/ignorable_area in areas_with_local_suns) // is this an area which should use local star
				if (get_area(dummy) == ignorable_area)
					ignoreme = TRUE
					break
			if (ignoreme)
				ignoreme = FALSE
				continue
		if (!T.lockedon) // is targetstar set
			T.lockedon = TRUE
			T.targetstar = src
		T.set_angle(angle)

	for(var/obj/machinery/power/solar/S in machine_registry[MACHINES_POWER])
		var/turf/dummy = get_turf(S)
		if (dummy.z != src.zlevel)
			continue
		if (!isnull(src.sun_area))
			if (get_area(dummy) != src.sun_area)
				continue
		else
			var/ignoreme = FALSE
			for (var/ignorable_area in areas_with_local_suns)
				if (get_area(dummy) == ignorable_area)
					ignoreme = TRUE
					break
			if (ignoreme)
				ignoreme = FALSE
				continue
		occlusion(S,src.visibility)


/// for a solar panel, trace towards sun to see if we're in shadow
/datum/sun/proc/occlusion(var/obj/machinery/power/solar/S, var/eclipse_blockage)

	var/ax = S.x		// start at the solar panel
	var/ay = S.y

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += src.dx	// do step
		ay += src.dy

		var/turf/T = locate(round(ax,0.5),round(ay,0.5),S.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			S.obscured = 1
			return

	S.obscured = 0		// if hit the edge or stepped 20 times, not obscured
	S.update_solar_exposure()

//returns the north-zero clockwise angle in degrees, given a direction

///turns a direction into an angle in degrees, with NORTH being 0 degrees, and EAST 90
/proc/dir2angle(var/D)
	switch(D)
		if(NORTH)
			return 0
		if(SOUTH)
			return 180
		if(EAST)
			return 90
		if(WEST)
			return 270
		if(NORTHEAST)
			return 45
		if(SOUTHEAST)
			return 135
		if(NORTHWEST)
			return 315
		if(SOUTHWEST)
			return 225
		else
			return null
