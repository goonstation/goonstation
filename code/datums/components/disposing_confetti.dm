

/datum/component/disposing_confetti
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/disposing_confetti/Initialize()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_PARENT_PRE_DISPOSING), .proc/the_confetti)

/datum/component/disposing_confetti/proc/the_confetti()
	var/atom/movable/AM = parent
	var/turf/T = get_turf(AM)
	particleMaster.SpawnSystem(new /datum/particleSystem/confetti(T))
	SPAWN_DBG(1 SECOND)
		playsound(T, "sound/voice/yayyy.ogg", 50, 1)
