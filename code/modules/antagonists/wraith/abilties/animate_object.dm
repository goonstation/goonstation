/datum/targetable/wraithAbility/animateObject
	name = "Animate Object"
	icon_state = "animobject"
	desc = "Animate an inanimate object to attack nearby humans."
	targeted = TRUE
	target_anything = TRUE
	pointCost = 100
	cooldown = 30 SECONDS
	min_req_dist = 10

	cast(atom/target)
		//If you targeted a turf for some reason, find an object on it
		if (isturf(target))
			for (var/obj/O in target.contents)
				if (!is_valid_target(O))
					continue
				target = O
				break

		if(!is_valid_target(target))
			boutput(src.holder.owner, "<span class='alert'>That is not a valid target for animation!</span>")
			return TRUE
		new /mob/living/object/ai_controlled(get_turf(target), target)
		src.holder.owner.playsound_local(src.holder.owner.loc, 'sound/voice/wraith/wraithlivingobject.ogg', 50, 0)
		return FALSE

	proc/is_valid_target(obj/O)
		if(!istype(O) || istype(O, /obj/critter) || istype(O, /obj/machinery/bot) || istype(O, /obj/decal) || O.anchored || O.invisibility)
			return FALSE
		return TRUE

