ABSTRACT_TYPE(/datum/unlockable_flock_structure)
/**
 * Subclass this for every new building type you add
 * Override the check_unlocked() function to do whatever unlock logic you have
 * If you're looking for a specific event, I recommend /datum/flock.achievements
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
		var/obj/flock_structure/sT = src.structType //this is a gross hack, but needed for resolving flock_id
		friendly_name = initial(sT.flock_id)

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
		return FALSE

/datum/unlockable_flock_structure/relay
	structType = /obj/flock_structure/relay

	check_unlocked()
		return src.my_flock.total_compute() > 1000

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

	check_unlocked()
		return src.my_flock.hasAchieved("all_structures")
