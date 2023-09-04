/datum/component/death_gang_respawn
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/count = GANG_LEADER_REVIVES

/datum/component/death_gang_respawn/Initialize()
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/queue_respawn)

/datum/component/death_gang_respawn/proc/queue_respawn()
	var/mob/M = parent
	if (count > 0)
		M.show_antag_popup("ganglead_death")
		boutput(M, "<h2><span class='alert'>You've died as a gang leader! Either wait to be resurrected by your gang, or use your locker to come back.</span></h2>")
		SPAWN(15 SECONDS)
			M.setStatus("gang_revivify")
			M.ghost.setStatus("gang_revivify")

/datum/component/death_gang_respawn/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	. = ..()
