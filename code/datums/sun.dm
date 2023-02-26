#define ECLIPSE_FALSE 0 // not eclipsing
#define ECLIPSE_PENUMBRA_WAXING 1 // partial eclipse
#define ECLIPSE_PENUMBRA_WANING 2 // partial eclipse 2
// #define ECLIPSE_ANTUMBRA 3 // annular eclipse
#define ECLIPSE_UMBRA 4 // total eclipse
#define ECLIPSE_PARTIAL 5 // a 0 second long internal counter thing for if the 'peak' of the eclipse isnt total or annular
#define ECLIPSE_TERRESTRIAL 6 // not actually eclipsing truly, but partial blockage by clouds/water. aka daytime
#define ECLIPSE_PLANETARY 7 // night time lol. The planet you're on is eclipsing you.
#define ECLIPSE_ERROR 8 // admin nonsense
/datum/sun
	var/angle
	var/dx
	var/dy
	var/counter = 20 // to make the vars update during 1st call
	var/rate
	/// Is it around Shidd, Fugg, or Typhon? Or the Sun?
	var/star = "unknown"
	/// where is z1 exactly?
	var/stationloc = null
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
	/// If we have an annular eclipse, what's the minimum star visibility? Percentage where 1=100%. This being below 1 makes the peak annular.
	var/max_shadow = 1
	/// which stage of the eclipse are we in?
	var/eclipse_status = ECLIPSE_FALSE
	/// do we calculate the eclipse cycle? False for stuff like earth/abzu's rotation (or just no eclipse), since that's calculated at build
	var/eclipse_cycle_on = FALSE
	/// what kind of eclipses happen in the cycle?
	var/list/eclipse_order = list(ECLIPSE_FALSE)
	/// what percentage of light reaches us? 1 is 100%, 0 is 0%. Changes as the eclipse does. Cloud cover changes this too i guess. Max is 1
	var/visibility = 1
	/// At 100% visibility, at what efficiency do the solars work? Based on inverse square of distance to star. Also a percentage, with 1 = 100%
	var/photovoltaic_efficiency = 1

/// This can be called if the station is teleported, as well as at build, hence it being a separate proc.
/datum/sun/proc/identity_check()
	rate = rand(75,125)/50 // 75% - 125% of 'standard' rotation
	if(prob(50))
		rate = -rate
	switch (stationloc)
		if ("void")
			// for admin nonsense generally, also shuttle transit. Where no stars apply.
			eclipse_status = ECLIPSE_ERROR
			eclipse_order = list(ECLIPSE_ERROR)
			visibility = 0
			photovoltaic_efficiency = 0
			rate = 0
			angle = 0
		if ("13")
			/* Space Station 13, i.e. in L2 lagrange point around Rota Fortuna.
			If the station truly sat at the L2 point, Typhon would be permanently eclipsed, but it's probably in a
			lissajous orbit around the umbra, making the lore reason for the solars turning is that the whole map is spinning.
			*/
			star = "Typhon"
			if (prob(50))
				eclipse_cycle_on = TRUE
				eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_PENUMBRA_WAXING, pick(ECLIPSE_PARTIAL, ECLIPSE_UMBRA, ECLIPSE_ANTUMBRA), ECLIPSE_PENUMBRA_WANING)
				eclipse_cycle_length = rand(100, 300) SECONDS
				eclipse_time = rand(10, 300) SECONDS
			// pretty much the same as regular but with 50% chance of random eclipsing
		if ("solaris")
			star = "Shidd"
			rate = 0
			angle = dir2angle(SOUTH)
			photovoltaic_efficiency = 500 // solars work really well for a bit then explode lol
		if ("travel")
			// for ship maps, deep space. Uses a randomer randomiser
			photovoltaic_efficiency = rand(20,150)/100 // it could be anywhere ooo
			star = pick("Typhon", "Fugg", "Shidd")
			rate = rand(70,160)/50 // more range than the default
			if(prob(50))
				rate = -rate
			if (prob(50)) // 50 50 chance of it going into shadow every so often
				eclipse_cycle_on = TRUE
				eclipse_order = list(ECLIPSE_FALSE, ECLIPSE_PENUMBRA_WAXING, pick(ECLIPSE_PARTIAL, ECLIPSE_UMBRA, ECLIPSE_ANTUMBRA), ECLIPSE_PENUMBRA_WANING)
				eclipse_cycle_length = rand(100, 300) SECONDS
				eclipse_time = rand(10, 300) SECONDS
		if ("magus")
			//nadir. We're going to assume it's tidally locked with typhon seeing as its light level doesn't change. Permanent day.
			star = "Typhon"
			eclipse_status = ECLIPSE_TERRESTRIAL
			eclipse_order = list(ECLIPSE_TERRESTRIAL)
			rate = 0
			angle = rand(0, 360)
			visibility = 0.06 // seeing as the lighting is rgb(0,0,50), it's about 6% surface lighting
			photovoltaic_efficiency = 1.5 // magus is quite close to typhon
			// you get 6% of 150% strength sunlight, is the takeaway
		if ("abzu")
			//oshan and technically also manta
			star = "Fugg"
			visibility = 0.35 // time.dm shows alpha value 65% at noon, so
			eclipse_time = 6 HOURS
			eclipse_cycle_length = 12 HOURS
			eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			// note how the eclipse has details for computers and stuff but won't ever actually happen at runtime.
			if (BUILD_TIME_HOUR < 3 || BUILD_TIME_HOUR > 9 && BUILD_TIME_HOUR < 15 || BUILD_TIME_HOUR > 18)
				// oshan works off a 12 hour cycle, not 24
				eclipse_status = ECLIPSE_PLANETARY
				visibility = 0
			else
				eclipse_status = ECLIPSE_TERRESTRIAL
				visibility = rand(80,100) // assuming cloud covers up to 20% of light
			// oshan is either in day or night. 'eclipses' i.e. sunrises/sunsets don't happen at runtime.
		if ("earth")
			//centcomm mainly. Same as oshan, day/night cycle is determined at build, not runtime.
			star = "\improper Sun"
			eclipse_time = 12 HOURS
			eclipse_cycle_length = 24 HOURS
			eclipse_order = list(ECLIPSE_PLANETARY, ECLIPSE_TERRESTRIAL)
			if (BUILD_TIME_HOUR < 6 || BUILD_TIME_HOUR >= 18)
				eclipse_status = ECLIPSE_PLANETARY
				visibility = 0
			else
				eclipse_status = ECLIPSE_TERRESTRIAL
				visibility = rand(80,100) // assuming cloud covers up to 20% of light


/datum/sun/New()
	..()
	identity_check()

/// calculate the sun's position given the time of round, plus other things
/datum/sun/proc/calc_position()
	counter++ // this should be every game tick, 1/10th of a second
	if (counter < 20) // 60 seconds, roughly - about a 5deg change (note, this is now approx 2 seconds instead)
		return
	counter = 0
	angle = ((rate*world.realtime/100)%360 + 360)%360
	/* used to give about a 60 minute rotation time.
	Now around 30 - 40 min, depending on rate. An array on one side would sometimes generate zero or close to zero electricity for up to 30 min
	of a typical round (~60 min), making solars not so useful.*/
	if (ECLIPSE_ERROR)
		eclipse_order = list(ECLIPSE_ERROR)
		eclipse_cycle_on = FALSE
		visibility = 0
		photovoltaic_efficiency = 0
		rate = 0
		angle = 0
	if (eclipse_cycle_on)
		eclipse_counter ++
		switch (eclipse_status)
			if (ECLIPSE_FALSE)
				if (eclipse_counter >= down_time)
					eclipse_status = next_in_list(eclipse_status, eclipse_order)
				else
					visibility = 1
			if (ECLIPSE_PENUMBRA_WAXING)
				if (eclipse_counter >= (down_time + penumbra_time))
					eclipse_status = next_in_list(eclipse_status, eclipse_order)
				else
					visibility -= ((1 - max_shadow) / penumbra_time)
			if (ECLIPSE_PENUMBRA_WANING)
				if (eclipse_counter >= eclipse_cycle_length)
					eclipse_status = next_in_list(eclipse_status, eclipse_order)
					eclipse_counter = 0
				else
					visibility += ((1 - max_shadow) / penumbra_time)
			if (ECLIPSE_UMBRA || ECLIPSE_ANTUMBRA)
				if (eclipse_counter >= (down_time + penumbra_time + eclipse_time))
					eclipse_status = next_in_list(eclipse_status, eclipse_order)
				else
					visibility = 1 - max_shadow
			// if (ECLIPSE_PLANETARY)
			// planetary rotation isnt done at runtime so we dont need this

	// now calculate and cache the (dx,dy) increments for line drawing
	var/s = sin(angle)
	var/c = cos(angle)
	if(c == 0)
		dx = 0
		dy = s
	else if( abs(s) < abs(c))
		dx = s / abs(c)
		dy = c / abs(c)
	else
		dx = s/abs(s)
		dy = c / abs(s)
	for(var/obj/machinery/power/tracker/T in machine_registry[MACHINES_POWER])
		T.set_angle(angle)
	for(var/obj/machinery/power/solar/S in machine_registry[MACHINES_POWER])
		occlusion(S)

// for a solar panel, trace towards sun to see if we're in shadow
/datum/sun/proc/occlusion(var/obj/machinery/power/solar/S)

	var/ax = S.x		// start at the solar panel
	var/ay = S.y

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += dx	// do step
		ay += dy

		var/turf/T = locate( round(ax,0.5),round(ay,0.5),S.z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			S.obscured = 1
			return

	S.obscured = 0		// if hit the edge or stepped 20 times, not obscured
	S.update_solar_exposure()

//returns the north-zero clockwise angle in degrees, given a direction

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

#undef ECLIPSE_FALSE
#undef ECLIPSE_PENUMBRA
#undef ECLIPSE_ANTUMBRA
#undef ECLIPSE_UMBRA
#undef ECLIPSE_TERRESTRIAL
#undef ECLIPSE_PLANETARY
#undef ECLIPSE_ERROR
