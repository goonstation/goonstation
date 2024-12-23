/datum/targetable/wraithAbility/decay
	name = "Decay"
	icon_state = "decay"
	desc = "Cause a human to lose stamina, or an object to malfunction."
	targeted = 1
	target_anything = 1
	pointCost = 30
	cooldown = 1 MINUTE //1 minute
	min_req_dist = 15

	cast(atom/T)
		if (..())
			return TRUE

		//If you targeted a turf for some reason, find a valid target on it
		var/atom/target = null
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/M in T.contents)
				if (!isdead(M))
					target = M
					break
			if (!target)
				for (var/obj/O in T.contents)
					target = O //todo: emaggable check
					break
		else
			target = T

		if (ishuman(T))
			var/mob/living/carbon/H = T
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, SPAN_ALERT("Some mysterious force protects [T] from your influence."))
				return TRUE
			else
				boutput(usr, SPAN_NOTICE("[pick("You sap [T]'s energy.", "You suck the breath out of [T].")]"))
				boutput(T, SPAN_ALERT("You feel really tired all of a sudden!"))
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithstaminadrain.ogg', 75, 0)
				H.emote("pale")
				H.remove_stamina( rand(100, 120) )//might be nice if decay was useful.
				H.changeStatus("stunned", 4 SECONDS)
				return FALSE
		else if (isobj(T))
			var/obj/O = T
			if(istype(O, /obj/machinery/computer/shuttle) || istype(O, /obj/item/parts/robot_parts/robot_frame))
				boutput(usr, SPAN_ALERT("You cannot seem to alter the energy of [O].") )
				return TRUE
			// go to jail, do not pass src, do not collect pushed messages
			if (O.emag_act(null, null))
				boutput(usr, SPAN_NOTICE("You alter the energy of [O]."))
				return FALSE
			else
				boutput(usr, SPAN_ALERT("You fail to alter the energy of the [O]."))
				return TRUE
		else
			boutput(usr, SPAN_ALERT("There is nothing to decay here!"))
			return TRUE
