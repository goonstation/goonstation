/client/proc/admin_minimap()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "View Admin Minimap"
	set desc = "An admin view of the station map with player locations"
	ADMIN_ONLY
	SHOW_VERB_DESC

	observer_minimap_ui.ui_interact(src.mob)

/mob/dead/observer/verb/observer_minimap()
	set name = "View Minimap"
	set category = "Ghost"

	observer_minimap_ui.ui_interact(src)

/datum/targetable/ghost_observer/view_minimap
	name = "View Minimap"
	desc = "View the station minimap and crew locations"
	icon_state = "minimap"
	targeted = 0
	cooldown = 0

	cast(atom/target)
		. = ..()
		if (holder && istype(holder.owner, /mob/dead/observer))
			var/mob/dead/observer/ghost = holder.owner
			ghost.observer_minimap()

/mob/living/Login()
	. = ..()
	SPAWN(5 SECONDS) // race condition with job assignment at round start
		var/datum/job/J = find_job_in_controller_by_string(src.job)
		var/job_dot

		if (istype(J, /datum/job/civilian))
			job_dot = "civilian_dot"
		else if (istype(J, /datum/job/research))
			job_dot = "research_dot"
		else if (istype(J, /datum/job/engineering))
			job_dot = "engineering_dot"
		else if (istype(J, /datum/job/security))
			job_dot = "security_dot"
		else if (istype(J, /datum/job/command))
			job_dot = "command_dot"
		else if (istype(J, /datum/job/special))
			job_dot = "special_dot"
		else
			job_dot = "civilian_dot"
		AddComponent(/datum/component/minimap_marker/minimap, MAP_OBSERVER, job_dot, 'icons/obj/minimap/minimap_markers.dmi', null, FALSE)
