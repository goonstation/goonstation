/datum/abilityHolder/silicon/ai
	var/datum/targetable/ai/program/camera_gun/active_camera_gun

/datum/abilityHolder/silicon/ai/updateButtons(called_by_owner = 0, start_x = 2, start_y = 0)
	. = ..()

/datum/targetable/ai
	preferred_holder_type = /datum/abilityHolder/silicon/ai
	icon = 'icons/mob/hud_ai.dmi'

	castcheck(atom/target)
		. = TRUE
		var/mob/living/silicon/ai/AI = holder.owner
		if(istype(AI))
			if (!AI.deployed_to_eyecam)
				boutput(holder.owner, "Deploy to an AI Eye first to do that.")
				. = FALSE
				return

	cast(atom/target)
		. = ..()
		if(.)
			return

		var/turf/T = get_turf(target)
		if(src.targeted)
			if (!istype(T) || !istype(T.cameras) || !length(T.cameras))
				boutput(holder.owner, "No camera available to target that location.")
				. = FALSE
				return 1

/datum/targetable/ai/program
	icon_state = "ai_template"

	proc/can_shoot_to(obj/machinery/camera/C, turf/target, atom/A, max_length=10)
		if(isnull(A))
			A = new /obj/projectile
		var/turf/current = get_turf(C)
		var/turf/target_turf = get_turf(target)
		var/turf/next = get_step_towards(current, target_turf)
		var/steps = 0

		while(next != target_turf)
			if (steps > max_length) return 0
			if (!next) return 0
			if(!jpsTurfPassable(next, source=current, passer=A))
				return 0

			current = next
			next = get_step_towards(next, target_turf)
			steps++

		return 1
