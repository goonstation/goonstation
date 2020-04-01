// Largely used for handling auto turfs that update their appearance
// to "connect" to nearby walls

// Turfs add themselves to this in their New()
/var/global/list/worldgenCandidates = list()

/proc/initialize_worldgen()
	for(var/turf/U in worldgenCandidates)
		if (U) //may be deleted lol
			U.generate_worldgen()
			LAGCHECK(LAG_REALTIME)
