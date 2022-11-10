ABSTRACT_TYPE(/datum/unlockable_flock_structure)
/**
 * Subclass this for every new building type you add
 * Override the check_unlocked() function to do whatever unlock logic you have
 * If you're looking for a specific event, I recommend /datum/flock.hasAchieved()
 */

/datum/unlockable_flock_structure
	var/structType = null
	var/datum/flock/my_flock = null
	var/unlocked = FALSE
	var/friendly_name

	New(var/datum/flock/F)
		..()
		if(F)
			src.my_flock = F
		if(!src.structType)
			stack_trace("[src.type] must specify structType")
			return
		var/obj/flock_structure/sT = src.structType //this is a gross hack, but needed for resolving flock_id
		friendly_name = initial(sT.flock_id)
		if(!friendly_name)
			stack_trace("[src.type] has invalid structType [sT]")
			return

	proc/process()
		if(src.check_unlocked())
			if(!src.unlocked)
				src.my_flock.notifyUnlockStructure(src)
				src.unlocked = TRUE
		else if(src.unlocked)
			src.my_flock.notifyRelockStructure(src)
			src.unlocked = FALSE

	///Returns true when unlock condition is met, false when it isn't.
	proc/check_unlocked()
		return src.my_flock.hasAchieved(FLOCK_ACHIEVEMENT_CHEAT_STRUCTURES)

/datum/unlockable_flock_structure/relay
	structType = /obj/flock_structure/relay

	check_unlocked()
		return ..() || (src.my_flock.total_compute() >= FLOCK_RELAY_COMPUTE_COST && !src.my_flock.relay_in_progress && !src.my_flock.relay_finished)

/datum/unlockable_flock_structure/collector
	structType = /obj/flock_structure/collector

	check_unlocked()
		return TRUE

/datum/unlockable_flock_structure/sentinel
	structType = /obj/flock_structure/sentinel

	check_unlocked()
		return TRUE

/datum/unlockable_flock_structure/compute
	structType = /obj/flock_structure/compute

/datum/unlockable_flock_structure/gnesisturret
	structType = /obj/flock_structure/gnesisturret

	check_unlocked()
		return ..() || src.my_flock.hasAchieved(FLOCK_ACHIEVEMENT_CAGE_HUMAN)

/datum/unlockable_flock_structure/sapper
	structType = /obj/flock_structure/sapper

	check_unlocked()
		return ..() || src.my_flock.total_compute() >= 150

/datum/unlockable_flock_structure/interceptor
	structType = /obj/flock_structure/interceptor

	check_unlocked()
		return ..() || src.my_flock.hasAchieved(FLOCK_ACHIEVEMENT_BULLETS_HIT)
