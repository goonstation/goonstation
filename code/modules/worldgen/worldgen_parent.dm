/// Largely used for handling auto turfs that update their appearance
/// to "connect" to nearby walls
/// Turfs add themselves to this in their New()
/var/global/list/turf/worldgenCandidates = list()

/proc/initialize_worldgen()
	for(var/turf/U as anything in worldgenCandidates)
		U.generate_worldgen()
		LAGCHECK(LAG_REALTIME)
