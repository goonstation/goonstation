/datum/component/death_confetti
	dupe_mode = COMPONENT_DUPE_UNIQUE

TYPEINFO(/datum/component/death_confetti)
	initialization_args = list()

/datum/component/death_confetti/Initialize()
	. = ..()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH, .proc/the_confetti)
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/the_confetti)
	RegisterSignal(parent, COMSIG_MOB_FAKE_DEATH, .proc/the_confetti)

/datum/component/death_confetti/proc/the_confetti()
	var/atom/movable/AM = parent
	var/turf/T = get_turf(AM)
	particleMaster.SpawnSystem(new /datum/particleSystem/confetti(T))
	SPAWN(1 SECOND)
		playsound(T, 'sound/voice/yayyy.ogg', 50, 1)

/datum/component/death_confetti/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH)
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	UnregisterSignal(parent, COMSIG_MOB_FAKE_DEATH)
	. = ..()
