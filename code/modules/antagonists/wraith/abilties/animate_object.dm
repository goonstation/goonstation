/datum/targetable/wraithAbility/animateObject
	name = "Animate Object"
	icon_state = "animobject"
	desc = "Animate an inanimate object to attack nearby humans."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 30 SECONDS
	min_req_dist = 10

	cast(atom/T)
		if (..())
			return 1

		var/obj/O = T
		//If you targeted a turf for some reason, find an object on it
		if (istype(T, /turf))
			for (var/obj/target in T.contents)
				if (istype(target, /obj/critter) || istype(target, /obj/machinery/bot) || istype(target, /obj/decal) || target.anchored || target.invisibility)
					continue
				O = target
				break

		if (istype(O))
			if(istype(O, /obj/critter) || istype(O, /obj/machinery/bot) || istype(O, /obj/decal) || O.anchored || O.invisibility)
				boutput(usr, "<span class='alert'>That is not a valid target for animation!</span>")
				return 1
			new/mob/living/object/ai_controlled(O.loc, O)
			usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithlivingobject.ogg', 50, 0)
			return 0
		else
			boutput(usr, "<span class='alert'>There is no object here to animate!</span>")
			return 1
