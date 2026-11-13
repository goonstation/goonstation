CREATE_NAMESPACE(EVENT)

CREATE_NAMESPACE(EVENT, TYPE)
ADD_TO_NAMESPACE(EVENT, TYPE)(var/const/MAJOR = "major")
ADD_TO_NAMESPACE(EVENT, TYPE)(var/const/MINOR = "minor")
ADD_TO_NAMESPACE(EVENT, TYPE)(var/const/RESPAWN = "respawn")
ADD_TO_NAMESPACE(EVENT, TYPE)(var/const/START = "start")
ADD_TO_NAMESPACE(EVENT, TYPE)(var/const/SPECIAL = "special")

CREATE_NAMESPACE(EVENT, MENHIR)
ADD_TO_NAMESPACE(EVENT, MENHIR)(var/const/ALERT_VOLUME = 40)
ADD_TO_NAMESPACE(EVENT, MENHIR)(var/const/CORE_X = 158)
ADD_TO_NAMESPACE(EVENT, MENHIR)(var/const/CORE_Y = 169)

// Bitflags for filtering Menhir events
CREATE_NAMESPACE(EVENT, MENHIR, FILTER)
///Does our candidate need to be human?
ADD_TO_NAMESPACE(EVENT, MENHIR, FILTER)(var/const/HUMAN = (1 << 0))
///Does our candidate need to be directly on a turf, and not inside anything else?
ADD_TO_NAMESPACE(EVENT, MENHIR, FILTER)(var/const/ON_TURF = (1 << 1))
///By default, anyone in Precursor areas counts as "present" as well. This filter prevents that.
ADD_TO_NAMESPACE(EVENT, MENHIR, FILTER)(var/const/NO_MOON = (1 << 2))
///Does our candidate suffer no direct ill effects from abrupt relocation? (currently excludes vamp/thralls due to proximity demand)
ADD_TO_NAMESPACE(EVENT, MENHIR, FILTER)(var/const/YOINK_SAFE = (1 << 3))

///Grabs (and updates, if necessary) the list of people who are present for on-station events. Provide a filter to narrow the returned pool further.
ADD_TO_NAMESPACE(EVENT, MENHIR, FILTER)(proc/get_event_candidates(filter = 0))
	RETURN_TYPE(/list)
	//Build stage
	if(menhir_candidates_last_built < (world.time - 20 SECONDS) && !length(menhir_local_event_candidates))
		menhir_candidates_last_built = world.time
		menhir_local_event_candidates = list()

		for (var/mob/living/L in mobs)
			if(!isalive(L) || !L.client || ismobcritter(L) || isintangible(L))
				continue
			var/area/mobarea = get_area(L)
			if(istype(mobarea,/area/station) || istype(mobarea,/area/unspace) || istype(mobarea, /area/research_outpost) || istype(mobarea, /area/precursor))
				menhir_local_event_candidates += L
	. = menhir_local_event_candidates

	//Filter stage
	if(filter)
		for(var/mob/M in .)
			if(filter & EVENT::MENHIR::FILTER::HUMAN && !istype(M,/mob/living/carbon/human))
				. -= M
				continue
			if(filter & EVENT::MENHIR::FILTER::ON_TURF && !isturf(M.loc))
				. -= M
				continue
			if(filter & EVENT::MENHIR::FILTER::NO_MOON)
				var/area/mobarea = get_area(M)
				if(istype(mobarea,/area/precursor))
					. -= M
					continue
			if(filter & EVENT::MENHIR::FILTER::YOINK_SAFE)
				if(isvampiricthrall(M) || isvampire(M))
					. -= M
					continue
	return


CREATE_NAMESPACE(EVENT, MENHIR, NOTIFY)
ADD_TO_NAMESPACE(EVENT, MENHIR, NOTIFY)(var/const/NONE = 0)
ADD_TO_NAMESPACE(EVENT, MENHIR, NOTIFY)(var/const/PDA = 1)
ADD_TO_NAMESPACE(EVENT, MENHIR, NOTIFY)(var/const/GLOBAL = 2)

