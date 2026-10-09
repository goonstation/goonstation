/datum/element/death_confetti/Attach(atom/movable/target)
	if (!istype(target))
		return DCS::ERR::ELEMENT_INCOMPATIBLE

	src.RegisterSignal(target, COMSIG_OBJ_CRITTER_DEATH, PROC_REF(confetti))
	src.RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(confetti))
	src.RegisterSignal(target, COMSIG_MOB_FAKE_DEATH, PROC_REF(confetti))
	. = ..()

/datum/element/death_confetti/Detach(atom/movable/target)
	src.UnregisterSignal(target, COMSIG_OBJ_CRITTER_DEATH)
	src.UnregisterSignal(target, COMSIG_MOB_DEATH)
	src.UnregisterSignal(target, COMSIG_MOB_FAKE_DEATH)
	. = ..()

/datum/element/death_confetti/proc/confetti(atom/movable/target)
	if (HAS_ATOM_PROPERTY(target, PROP_MOB_SUPPRESS_DEATH_SOUND))
		return

	var/turf/T = get_turf(target)
	global.particleMaster.SpawnSystem(new /datum/particleSystem/confetti(T))
	SPAWN(1 SECOND)
		playsound(T, 'sound/voice/yayyy.ogg', 50, TRUE)
