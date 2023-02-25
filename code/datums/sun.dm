#define ECLIPSE_FALSE 0 // not eclipsing
#define ECLIPSE_PENUMBRA 1 // partial eclipse
#define ECLIPSE_ANTUMBRA 2 // annular eclipse
#define ECLIPSE_UMBRA 3 // total eclipse
#define ECLIPSE_TERRESTRIAL 4 // not actually eclipsing truly, but partial blockage by clouds/water
#define ECLIPSE_PLANETRAY 5 // night time lol. The planet you're on is eclipsing you.
/datum/sun
	var/angle
	var/dx
	var/dy
	var/counter = 20 // to make the vars update during 1st call
	var/rate
	// advanced mechanics here
	var/star = "Typhon" // Is it around Shidd, Fugg, or Typhon?
	var/stationloc = null // where is it exactly?
	var/eclipse_rate = null // does a planet or moon eclipse it? if no, null. If it does, how often?
	var/eclipse_time = 20 // How long, in seconds, is the eclipse? 20 is just a default fallback value
	var/eclipse_status = ECLIPSE_FALSE
	var/visiblity = 1 //if 0, no light gets through, if 1, all light.
	// ECLIPSE_UMBRA sets this to 0, ECLIPSE_FALSE sets this to 1, the others use scales.

/datum/sun/identity_check()
	// this isn't just New(), so that if admin nonsense teleports the whole station, this can be called
	// here're the default settings that can get overridden
	rate = rand(75,125)/50 // 75% - 125% of 'standard' rotation
	if(prob(50))
		rate = -rate
	switch (stationloc)
		if ("void")
			// for admin nonsense generally
			star = "unknown"
			visiblity = 0
			rate = 0
			angle = 0
		if ("13")
			/* Space Station 13, i.e. in L2 lagrange point around Rota Fortuna.
			If the station truly sat at the L2 point, Typhon would be permanently eclipsed.
			Most irl Lagrange placed satellites however take a lissajous orbit around the penumbra,
			putting them in permanent sunlight with no eclipsing. If canonically there are multiple NT-13
			stations sitting around Rota Fortuna, they'd have to do this in a sort of coordinated set of orbits.
			The movement of the sun would also be based on, uh, the year length.
			So the lore reason for the solars turning is that the whole map is, and that NT failed to calibrate it proper.
			*/
			if (prob(50))
				rate = -rate
			// same as the default preexisting for now, no changes so far
		if ("travel")
			// for ship maps, deep space. Uses a randomer randomiser
			star = pick("Typhon", "Fugg", "Shidd")
			rate = rand(70,160)/50 // more range than the default
			if(prob(50))
				rate = -rate
			if (prob(50)) // 50 50 chance of it going into umbra every so often
				eclipse_rate = rand(100, 300)
				eclipse_time = rand(10, 300)
			return
		if ("abzu")
			//oshan and technically also manta
			star = "Fugg"
			eclipse_status = ECLIPSE_TERRESTRIAL
		if ("magus")
			//nadir
			eclipse_status = ECLIPSE_TERRESTRIAL

/datum/sun/New()
	..()
	identity_check()

// calculate the sun's position given the time of day
//
/datum/sun/proc/calc_position()
	counter++
	if (counter < 20) // 60 seconds, roughly - about a 5deg change
		return
	counter = 0

	angle = ((rate*world.realtime/100)%360 + 360)%360
	// gives about a 60 minute rotation time
	// now 45 - 75 minutes, depending on rate

	// Now around 30 - 40 min. An array would sometimes generate zero or close to zero electricity for up to 30 min
	// of a typical round (~60 min), making solars not so useful.

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
#undef ECLIPSE_PLANETRAY
