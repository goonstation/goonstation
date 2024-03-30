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
	var/tealprint_purchase_name

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
		tealprint_purchase_name = "[initial(sT.flock_id)] ([initial(sT.online_compute_cost)])"

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
		return TRUE

/datum/unlockable_flock_structure/relay
	structType = /obj/flock_structure/relay

	check_unlocked()
		var/relay_built = src.my_flock.relay_in_progress || src.my_flock.relay_finished
		return src.my_flock.hasAchieved(FLOCK_ACHIEVEMENT_CHEAT_STRUCTURES) || \
			(src.my_flock.total_compute() >= FLOCK_RELAY_COMPUTE_COST && !relay_built && !src.my_flock.flockmind?.tutorial)

/datum/unlockable_flock_structure/collector
	structType = /obj/flock_structure/collector

/datum/unlockable_flock_structure/sentinel
	structType = /obj/flock_structure/sentinel

/datum/unlockable_flock_structure/compute
	structType = /obj/flock_structure/compute

	check_unlocked()
		return src.my_flock.hasAchieved(FLOCK_ACHIEVEMENT_CHEAT_STRUCTURES)

/datum/unlockable_flock_structure/gnesisturret
	structType = /obj/flock_structure/gnesisturret

/datum/unlockable_flock_structure/sapper
	structType = /obj/flock_structure/sapper

/datum/unlockable_flock_structure/interceptor
	structType = /obj/flock_structure/interceptor
