/datum/component/death_confetti
	dupe_mode = COMPONENT_DUPE_UNIQUE

TYPEINFO(/datum/component/death_confetti)
	initialization_args = list()

/datum/component/death_confetti/Initialize()
	. = ..()
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH, PROC_REF(the_confetti))
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(the_confetti))
	RegisterSignal(parent, COMSIG_MOB_FAKE_DEATH, PROC_REF(the_confetti))

/datum/component/death_confetti/proc/the_confetti()
	var/atom/movable/AM = parent
	var/turf/T = get_turf(AM)
	if (HAS_ATOM_PROPERTY(AM, PROP_MOB_SUPPRESS_DEATH_SOUND))
		return
	particleMaster.SpawnSystem(new /datum/particleSystem/confetti(T))
	SPAWN(1 SECOND)
		playsound(T, 'sound/voice/yayyy.ogg', 50, TRUE)

/datum/component/death_confetti/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_CRITTER_DEATH)
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	UnregisterSignal(parent, COMSIG_MOB_FAKE_DEATH)
	. = ..()
