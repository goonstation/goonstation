/datum/component/death_gang_respawn
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/death_gang_respawn/Initialize()
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/queue_respawn)

/datum/component/death_gang_respawn/proc/queue_respawn()
	var/mob/M = parent
	SPAWN(2 SECONDS)
		var/obj/ganglocker/locker = M.mind.gang.locker
		var/mob/new_mob = locker.respawn_member(M)
		src.parent = new_mob

/datum/component/death_gang_respawn/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	. = ..()
