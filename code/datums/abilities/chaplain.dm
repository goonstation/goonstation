/datum/targetable/faith_based
	//var/faith_cost = 0

	tryCast(atom/target, params)
		var/area/station/chapel/area = get_area(holder.owner)
		if (!istype(area))
			boutput(holder.owner, SPAN_ALERT("You can only cast that spell while on holy ground."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (src.targeted)
			area = get_area(target)
			if (!istype(area))
				boutput(holder.owner, SPAN_ALERT("You can only target holy ground with that ability."))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		/* var/datum/trait/job/chaplain/faithtrait = holder.owner.traitHolder.getTrait("training_chaplain")
		if (!faithtrait || faithtrait.faith < src.faith_cost)
			boutput(holder.owner, SPAN_ALERT("Your flock lacks the faith for you to use this ability."))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN */
		. = ..()
		/* if (. == CAST_ATTEMPT_SUCCESS)
			faithtrait.faith -= src.faith_cost */




ABSTRACT_TYPE(/datum/targetable/faith_based/spawn_decoration)
/datum/targetable/faith_based/spawn_decoration
	name = "Spawn Decoration"
	desc = "spawns a decoration."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "toxmob"
	cooldown = 5
	targeted = TRUE
	target_anything = TRUE
	var/spawnable_type

	castcheck(atom/target)
		. = ..()
		if (!.)
			return
		if (disabled)
			boutput(holder.owner, SPAN_ALERT("You cannot use that ability at this time."))
			return FALSE



	cast(atom/target)
		var/turf/turf = get_turf(target)
		boutput(holder.owner, SPAN_ALERT("target: [target], x: [turf.x]; y: [turf.y]"))
		if (!isfloor(turf))
			boutput(holder.owner, SPAN_ALERT("You can only spawn decorations on floors."))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		for (var/obj/O in turf)
			if (O.density || isitem(O))
				boutput(holder.owner, SPAN_ALERT("You cannot spawn a decoration here, because of [O]."))
				return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/list/check_turfs = get_all_neighbours(turf)
		for (var/turf/check_turf in check_turfs)
			for (var/obj/O in check_turf)// needs to have a lot of space around it, to prevent it from being used as an impromptu barricade
				if (O.density || istype(O, /obj/machinery/door))
					boutput(holder.owner, SPAN_ALERT("You cannot spawn a decoration here; [O] is in the way."))
					return CAST_ATTEMPT_FAIL_CAST_FAILURE
		..()
		if (!spawnable_type)
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/decoration = new spawnable_type(turf)
		animate_supernatural_spawn(decoration)
		holder.owner.abilityHolder.removeAbility(src.type)


