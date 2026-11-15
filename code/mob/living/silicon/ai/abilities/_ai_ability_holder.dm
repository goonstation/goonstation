/datum/abilityHolder/silicon/ai
	var/datum/targetable/ai/module/camera_gun/active_camera_gun

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

	proc/get_law_module()
		var/mob/living/silicon/ai/AI
		if(istype(holder.owner,/mob/living/silicon/ai))
			AI = holder.owner
		else if(istype(holder.owner, /mob/living/intangible/aieye))
			var/mob/living/intangible/aieye/Aeye = holder.owner
			AI = Aeye.mainframe

		if(istype(AI))
			var/obj/machinery/lawrack/law_rack = AI.law_rack_connection
			for (var/i in 1 to law_rack.MAX_CIRCUITS)
				var/obj/item/aiModule/ability_expansion/expansion = law_rack.law_circuits[i]
				if(istype(expansion))
					if(src.type in expansion.ai_abilities)
						return expansion

/datum/targetable/ai/module
	icon_state = "ai_template"

	castcheck(atom/target)
		. = ..()
		if(.)
			var/obj/item/aiModule/ability_expansion/expansion = get_law_module()
			if(expansion)
				if (expansion.last_use > world.time)
					boutput(holder.owner, SPAN_ALERT("The source module is on cooldown for [round((expansion.last_use - world.time) / 10)] seconds."))
					return FALSE

	doCooldown()
		..()
		var/obj/item/aiModule/ability_expansion/expansion = get_law_module()
		if(expansion)
			expansion.last_use = world.time + expansion.shared_cooldown

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
