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

/datum/sun
	var/angle
	var/dx
	var/dy
	var/counter = 20 // to make the vars update during 1st call
	var/rate

	//stuff gets complicated starting from here.
	//jargon i use: global sun means for the whole z level, local sun means it overrides the global in an area.
	/// The datum/area which this star applies to. Generally used for z areas like centcomm. Null indicates global sun.
	var/area/sun_area = null
	/// which z level does this star apply to? mainly for debris and mining fields
	var/zlevel = 1
	/// Is it around Shidd, Fugg, or Typhon? Or the Sun?
	var/name = "unknown"
	/// where does this apply exactly? Where are we?
	var/stationloc = null
	/// flavour text for the tracker
	var/desc
	/// does the sun change position in the sky? does it move?
	var/rotates = TRUE

	// these time vars below theoretically use time units like SECOND and MINUTE, so 1 = 1/10 of a second
	// also, the penumbra and cycle length times don't actually get perma assigned, but it's for reference.
	/// a counter for cycling through the eclipse
	var/eclipse_counter = 1
	/// How long is the peak of the eclipse? 0 is just a default fallback value
	var/eclipse_time = 0
	/// How long does it take to transition from not eclipsing to eclipsing. Generally src.eclipse_time * rand(15,30)
	var/penumbra_time = 0
	/// How much time is spent not in eclipse?
	var/down_time = 0
	/// How often do eclipses happen? It's the length of the whole cycle. Generally down_time + penumbra_time * 2 + eclipse_time
	var/eclipse_cycle_length = 0

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
	/// At 100% visibility, at what efficiency do the solars work? Based on inverse square of distance to star, where 1 is the level at rota fortuna.
	var/photovoltaic_efficiency = 1
	// bonus note, photovoltaic_efficiency on earth is 15.7 since typhon is dimmer than the sun and rota fortuna is further.
	// the spess solars are just mega efficient basically.

/// creates a new star based on (optional) stationloc provided and an assigned area for locals
/datum/sun/New(var/location, var/ztemp, var/area/assigned_area, var/do_we_process)
	. = ..()
	global.starlist += src
	src.rotates = do_we_process
	// this set of if conditions is the bane of my existence
	if (!isnull(assigned_area)) // if it is a local sun, it has an area
		if (isnull(ztemp)) // if local with no z (generally not possible due to how z1 is set up)
			src.zlevel = 1
			CRASH("You have a sun datum localised within [assigned_area] with no given z level!")
		else
			src.zlevel = ztemp
		if (isnull(location)) // if local sun with no location given, assume void
			src.identity_check()
		else // if local sun with location
			src.stationloc = location
			src.identity_check()
		src.sun_area = assigned_area
		global.areas_with_local_suns += assigned_area
	else // global suns
		if (isnull(location)) // if no location
			if (isnull(ztemp) || ztemp == 1) // station sun
				src.check_z1_global_sun()
				src.identity_check()
			else // no location with given zlevel, i.e. a zlevel sun
				src.zlevel = ztemp
				src.identity_check()
				CRASH("You have a sun datum on z level [ztemp] with no given location!")
		else // a global sun with manually assigned location
			if (isnull(ztemp))
				CRASH("You have a sun datum with an assigned location but no z level given!")
			else
				src.zlevel = ztemp
			src.stationloc = location
			src.identity_check()
	SPAWN(10 SECONDS) // guessing that that's long enough for the z levels and areas to load
		src.calc_position()

/// checks where the z level is, for global suns
/datum/sun/proc/check_z1_global_sun()
	src.stationloc = "void"
	#if defined(MAP_OVERRIDE_DESTINY)
	src.stationloc = "travel"
	#elif defined(MAP_OVERRIDE_CLARION)
	src.stationloc = "travel"
	#elif defined(MAP_OVERRIDE_ATLAS)
	src.stationloc = "atlas"
	#elif defined(MAP_OVERRIDE_COGMAP)
	src.stationloc = "NT-13"
	#elif defined(MAP_OVERRIDE_COGMAP2)
	src.stationloc = "NT-13"
	#elif defined(MAP_OVERRIDE_DONUT2)
	src.stationloc = "NT-13"
	#elif defined(MAP_OVERRIDE_DONUT3)
	src.stationloc = "NT-13"
	#elif defined(MAP_OVERRIDE_PAMGOC)
	src.stationloc = "NT-13"
	#elif defined(UNDERWATER_PREFAB_RUNTIME_CHECKING)
	src.stationloc = "abzu"
	#elif defined(MAP_OVERRIDE_MANTA)
	src.stationloc = "abzu"
	#elif defined(MAP_OVERRIDE_OSHAN)
	src.stationloc = "abzu"
	#elif defined(MAP_OVERRIDE_NADIR)
	src.stationloc = "magus"
	#endif
/// This can be called to set the sun's data based on its assigned stationloc
/datum/sun/proc/identity_check()
	// the sun datums most places don't have a use at present, since those places don't have solars.
	// but they are supposedly constructible so we need to have that data anyway.
	// for anyone setting up adventure zones with solars in the future, make sure your 'outside' bits have areas,
	// and create then suns for those in code/world.dm and code/global.dm
	var/oldloc
	if (oldloc == src.stationloc)
		return
	oldloc = src.stationloc
	switch (src.stationloc)
		// 'error' suns
		if ("void") // for admin nonsense generally. Where no stars apply.
			src.name = "unknown"
			src.desc = "Error!"
			src.eclipse_cycle_on = FALSE
			src.eclipse_status = ECLIPSE_ERROR
			src.eclipse_order = list(ECLIPSE_ERROR)
			src.visibility = 0
			src.photovoltaic_efficiency = 0
			src.rate = 0
			src.angle = 0
		if ("adventure_void") // z2's global sun. Useful for wormholes n stuff
			src.zlevel = 2
			src.name = "unknown"
			src.desc = "Error!"
			src.eclipse_cycle_on = FALSE
			src.eclipse_status = ECLIPSE_ERROR
			src.eclipse_order = list(ECLIPSE_ERROR)
			src.visibility = 0
			src.photovoltaic_efficiency = 0
			src.rate = 0
			src.angle = 0
		// global suns for various z levels
		if ("trench") // the mining level for nadir and oshan
			src.zlevel = 5
			src.name = "N/A"
			src.desc = "The Trench."
			src.eclipse_cycle_on = FALSE
			src.eclipse_status = ECLIPSE_ERROR
			src.eclipse_order = list(ECLIPSE_ERROR)
			src.visibility = 0
			src.photovoltaic_efficiency = 0
			src.rate = 0
			src.angle = 0
		if ("debris") // the debris field is in the main rings district
			src.zlevel = 3
			src.name = "Typhon"
			src.desc = "The Debris field, in the main rings district."
			src.eclipse_cycle_on = FALSE
			src.eclipse_status = ECLIPSE_FALSE
			src.eclipse_order = list(ECLIPSE_FALSE)
			src.visibility = 1
			src.photovoltaic_efficiency = 2.5
			src.rate = rand(75,125)/50
			if(prob(50)) src.rate = -src.rate
			src.angle = rand(1, 359)
		if ("mining") // the mining level is canonically in the royal rings district, near magus
			src.zlevel = 5
			if (src.name == "unknown")
				src.name = pick("Fugg", "Shidd")
			src.desc = "The mining belt, in the royal rings district."
			src.eclipse_cycle_on = FALSE
			src.eclipse_status = ECLIPSE_FALSE
			src.eclipse_order = list(ECLIPSE_FALSE)
			src.visibility = 1
			if (src.name == "Fugg") src.photovoltaic_efficiency = 0.3
			else src.photovoltaic_efficiency = 0.6
			src.rate = 0
			src.angle = rand(1, 359)
		// global suns for different stations
		if ("NT-13") // for most 'fixed' space stations. Space Station 13 in L2 lagrange point around Rota Fortuna in the mundus gap district.
			/* If the station truly sat at the L2 point, Typhon would be permanently eclipsed, but it's probably in a lissajous orbit around the
			umbra, making the lore reason for the solars turning is that the whole map is spinning.
			A problem arises from the fact that NT-14, typhon, shidd, fugg and all the mundus gap planets and moons are all visible as decals
			on cogmap 1 (and probably other maps too). The solars should therefore theoretically point at the decals, but they don't.
			Scope creep says to ignore that for now. If someone makes parallax and movable background decals a reality, consider it then.*/
			src.name = "Typhon"
			src.desc = "In stable Lissajous orbit around Rota Fortuna's second Langrangian Point."
			if (prob(50)) // this thing gives it a random eclipse
				src.eclipse_cycle_on = TRUE
				src.eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_PENUMBRA_WAXING, pick(ECLIPSE_PARTIAL, ECLIPSE_UMBRA), ECLIPSE_PENUMBRA_WANING)
				src.eclipse_magnitude = pick(1, rand(1,99)/100)
				src.down_time = rand(20 MINUTES, 60 MINUTES)
				src.eclipse_time = rand(10 SECONDS, 5 MINUTES)
				src.penumbra_time = src.eclipse_time * rand(15,30)
				src.eclipse_cycle_length = src.down_time + 2 * src.penumbra_time + src.eclipse_time
				src.eclipse_counter = rand(1, src.eclipse_cycle_length)
			else
				src.eclipse_cycle_on = FALSE
				src.eclipse_status = ECLIPSE_FALSE
				src.eclipse_order = list(ECLIPSE_FALSE)
			src.visibility = 1
			src.photovoltaic_efficiency = 1
			src.rate = rand(75,125)/50 // 75% - 125% of standard rotation
			if(prob(50))
				src.rate = -src.rate
			src.angle = rand(1,359)
			// is the default settings pre #13206, but with 50% chance of random eclipsing
		if ("atlas") // X3 and X5 are visible in the background, meaning it's near quadriga.
			src.zlevel = 1
			src.name = "Typhon"
			src.desc = "Near Quadriga."
			src.eclipse_cycle_on = FALSE
			src.eclipse_status = ECLIPSE_FALSE
			src.eclipse_order = list(ECLIPSE_FALSE)
			src.visibility = 1
			src.photovoltaic_efficiency = 2.5
			src.rate = rand(75,125)/50
			if(prob(50)) src.rate = -src.rate
			src.angle = rand(1, 359)
		if ("travel") // for ship maps (in deep space). Uses a slightly randomer randomiser
			src.name = pick("Typhon", "Fugg", "Shidd")
			src.desc = "Deep space, in transit."
			if (prob(50)) // 50 50 chance of it going into shadow every so often
				src.eclipse_cycle_on = TRUE
				src.eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_PENUMBRA_WAXING, pick(ECLIPSE_PARTIAL, ECLIPSE_UMBRA), ECLIPSE_PENUMBRA_WANING)
				src.eclipse_magnitude = pick(1, rand(10,100)/100)
				src.down_time = rand(25 MINUTES, 120 MINUTES)
				src.eclipse_time = rand(5 SECONDS, 8 MINUTES)
				src.penumbra_time = src.eclipse_time * rand(15,30)
				src.eclipse_cycle_length = src.down_time + 2 * src.penumbra_time + src.eclipse_time
				src.eclipse_counter = rand(1, src.eclipse_cycle_length)
			else
				src.eclipse_cycle_on = FALSE
				src.eclipse_status = ECLIPSE_FALSE
				src.eclipse_order = list(ECLIPSE_FALSE)
			src.visibility = 1
			src.photovoltaic_efficiency = rand(20,150)/100 // it could be anywhere ooo
			src.rate = rand(70,160)/50 // more range than the default
			if(prob(50))
				src.rate = -rate
			src.angle = rand(1,359)
		if ("magus") //nadir. Magus has an 8 hour rotation compared to Typhon. However, it's far enough that its main lighting comes from the binary.
			if ((BUILD_TIME_HOUR % 8) <= 3)
				src.name = "Shidd" // the nadir lighting is bluer
				src.photovoltaic_efficiency = 1
			else
				src.name = "Fugg" // the nadir lighting is redder/darker
				src.photovoltaic_efficiency = 0.6
			src.desc = "Under the acid seas of Magus."
			src.eclipse_cycle_on = FALSE // doesn't proceed at runtime
			src.eclipse_status = ECLIPSE_TERRESTRIAL
			src.eclipse_order = list(ECLIPSE_TERRESTRIAL, ECLIPSE_TERRESTRIAL)
			src.down_time = 8 HOURS
			src.eclipse_counter = (BUILD_TIME_HOUR % 8) HOURS
			src.visibility = 0.166 // the max sunlight is from shidd, the blue one.
			src.rate = 0
			src.angle = pick(90, 270)
			// you get 6% of 60% strength sunlight overall
		if ("abzu") //oshan and technically also manta
			src.name = "Shidd"
			src.desc = "Under the seas of Abzu."
			src.eclipse_time = 6 HOURS
			src.down_time = 6 HOURS
			src.eclipse_cycle_on = FALSE
			src.eclipse_cycle_length = 12 HOURS
			src.eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			src.eclipse_magnitude = 1
			// note how there is data on when Shidd rises/sets, but won't ever actually happen at runtime.
			if (((BUILD_TIME_HOUR + 3) % 12) < 6)
				// oshan works off a 12 hour cycle, not 24
				src.eclipse_status = ECLIPSE_PLANETARY
				src.visibility = 0
			else
				src.eclipse_status = ECLIPSE_TERRESTRIAL
				src.visibility = 0.35 // this is the noon rgb percentage of OCEAN_LIGHT / rgb 255 255 255
			// oshan is either in day or night during a round. 'eclipses' i.e. sunrises/sunsets don't happen at runtime.
			src.eclipse_counter = ((BUILD_TIME_HOUR + 3) % 12) HOURS
			src.photovoltaic_efficiency = 10 //it be pretty close to its star ngl
			src.rate = 0
			src.angle = pick(90, 270)
		// local suns for z2 areas
		if ("earth") //centcomm mainly. Same as oshan, day/night cycle is determined at build, not runtime.
			src.zlevel = 2
			src.name = "\improper Sun"
			src.desc = "Surface of the Earth."
			src.eclipse_cycle_on = FALSE
			src.down_time = 12 HOURS
			src.eclipse_time = 12 HOURS
			src.eclipse_cycle_length = 24 HOURS
			src.eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			if (BUILD_TIME_HOUR < 6 || BUILD_TIME_HOUR >= 18)
				src.eclipse_status = ECLIPSE_PLANETARY
				src.visibility = 0
			else
				src.eclipse_status = ECLIPSE_TERRESTRIAL
				src.visibility = 1
			src.eclipse_counter = BUILD_TIME_HOUR HOURS + BUILD_TIME_MINUTE MINUTES
			src.eclipse_magnitude = 1
			src.photovoltaic_efficiency = 15.7 // the sun is brighter than typhon
			src.rate = 0
			src.angle = pick(90, 270)
		if ("io") // lava moon
			// interesting stuff to consider for lava moon
			// io is pretty much tidally locked with jupiter, so lighting changes are genuine eclipses.
			// its main heat is from geological processes though, not the sun.
			// so it doesn't matter that much
			src.zlevel = 2
			src.name = "\improper Sun"
			src.desc = "Io, the scorched innermost moon of Jupiter."
			src.eclipse_cycle_on = FALSE
			src.eclipse_cycle_length = 1.77 DAYS
			src.eclipse_time = 2.3 HOURS // figures based on irl measurements
			src.down_time = 1.67 DAYS
			src.eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_UMBRA)
			src.eclipse_counter = rand(1, src.eclipse_cycle_length)
			src.eclipse_magnitude = 1
			src.photovoltaic_efficiency = 2.5
			src.rate = 0
			src.angle = pick(90, 270)
		if ("senex") // ice moon, theta outpost
			src.zlevel = 2
			if (src.name == "unknown") src.name = pick("Fugg", "Shidd")
			src.desc = "On Senex, around Flaminica."
			src.eclipse_cycle_on = FALSE
			src.eclipse_counter = 0
			src.eclipse_status = ECLIPSE_FALSE // always start in daytime
			src.visibility = 1
			src.eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_UMBRA)
			src.eclipse_time = 24 WEEKS // making it turn very slowly because otherwise it'd be annoying
			src.down_time = 24 WEEKS
			src.eclipse_counter = rand(1, src.eclipse_cycle_length)
			if (src.name == "Fugg") src.photovoltaic_efficiency = 0.01
			else src.photovoltaic_efficiency = 0.03
			src.rate = 0
			src.angle = pick(90, 270)
		if ("solarium") // solarium
			src.zlevel = 2
			src.name = "\improper sun"
			src.desc = "Near Mercury. Very close to the sun."
			src.eclipse_cycle_on = FALSE
			src.eclipse_order = list(ECLIPSE_FALSE)
			src.visibility = 1
			src.photovoltaic_efficiency = 9000
			src.rate = 0
			src.angle = 90 // we can literally see it on the map
		if ("moon")
			src.zlevel = 2
			src.name = "\improper Sun"
			src.desc = "Surface of the Moon."
			src.eclipse_cycle_on = FALSE
			src.down_time = 14.75 DAYS
			src.eclipse_time = 14.75 DAYS
			src.eclipse_cycle_length = 29.5 DAYS
			src.eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			if (BUILD_TIME_DAY <= 15)
				src.eclipse_status = ECLIPSE_PLANETARY
				src.visibility = 0
			else
				src.eclipse_status = ECLIPSE_TERRESTRIAL
				src.visibility = 1
			src.eclipse_counter = BUILD_TIME_DAY DAYS + BUILD_TIME_HOUR HOURS + BUILD_TIME_MINUTE MINUTES
			src.eclipse_magnitude = 1
			src.photovoltaic_efficiency = 15.7 // the sun is brighter than typhon
			src.rate = 0
			src.angle = pick(90, 270)
		if ("mars")
			src.zlevel = 2
			src.name = "\improper Sun"
			src.desc = "Surface of the Mars."
			src.eclipse_cycle_on = FALSE
			src.down_time = 12 HOURS + 19.75 MINUTES
			src.eclipse_time = 12 HOURS + 19.75 MINUTES
			src.eclipse_cycle_length = 24 HOURS + 39.5 MINUTES
			src.eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			if (pick())
				src.eclipse_status = ECLIPSE_PLANETARY
				src.visibility = 0
			else
				src.eclipse_status = ECLIPSE_TERRESTRIAL
				src.visibility = 1
			src.eclipse_counter = BUILD_TIME_DAY DAYS + BUILD_TIME_HOUR HOURS + BUILD_TIME_MINUTE MINUTES
			src.eclipse_magnitude = 1
			src.photovoltaic_efficiency = 6.7 // mars gets 43% earth's light.
			src.rate = 0
			src.angle = rand(0, 360)
		if ("biodome")
			src.zlevel = 2
			// i don't know where it is.

/// calculate the sun's position given the time of round, plus other things
/datum/sun/proc/calc_position()
	if (!src.rotates)
		return
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
// update every tracker
	for(var/obj/machinery/power/tracker/T in machine_registry[MACHINES_POWER])
		var/turf/dummy = get_turf(T)
		if (dummy.z != src.zlevel) // are we on the right z
			continue
		if (!isnull(src.sun_area)) // local suns
			if (!istype_exact(get_area(dummy), src.sun_area)) // if local, are we in the right spot
				continue
			T.targetstar = src
			T.set_angle(angle)
		else // global sun (applies to whole z level)
			var/ignoreme = FALSE
			for (var/ignorable_area in areas_with_local_suns) // is this an area which should use local star
				if (istype_exact(get_area(dummy), ignorable_area))
					ignoreme = TRUE
					break
			if (ignoreme)
				ignoreme = FALSE
				continue
		T.targetstar = src
		T.set_angle(angle)
// update every solar
	for(var/obj/machinery/power/solar/S in machine_registry[MACHINES_POWER])
		var/turf/dummy = get_turf(S)
		if (dummy.z != src.zlevel)
			continue
		if (!isnull(src.sun_area))
			if (!istype_exact(get_area(dummy), src.sun_area))
				continue
		else
			var/ignoreme = FALSE
			for (var/ignorable_area in areas_with_local_suns)
				if (istype_exact(get_area(dummy), ignorable_area))
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
