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
				boutput(usr, "<span class='alert'>Some mysterious force protects [T] from your influence.</span>")
				return TRUE
			else
				boutput(usr, "<span class='notice'>[pick("You sap [T]'s energy.", "You suck the breath out of [T].")]</span>")
				boutput(T, "<span class='alert'>You feel really tired all of a sudden!</span>")
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithstaminadrain.ogg', 75, 0)
				H.emote("pale")
				H.remove_stamina( rand(100, 120) )//might be nice if decay was useful.
				H.changeStatus("stunned", 4 SECONDS)
				return FALSE
		else if (isobj(T))
			var/obj/O = T
			if(istype(O, /obj/machinery/computer/shuttle))
				boutput(usr, "<span class='alert'>You cannot seem to alter the energy of [O].</span>" )
				return TRUE
			// go to jail, do not pass src, do not collect pushed messages
			if (O.emag_act(null, null))
				boutput(usr, "<span class='notice'>You alter the energy of [O].</span>")
				return FALSE
			else
				boutput(usr, "<span class='alert'>You fail to alter the energy of the [O].</span>")
				return TRUE
		else
			boutput(usr, "<span class='alert'>There is nothing to decay here!</span>")
			return TRUE
