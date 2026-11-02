/datum/targetable/ai/module/teleport
	targeted = TRUE
	target_anything = 1

	castcheck(atom/target)
		. = ..()
		if(.)
			if(!get_first_teleporter())
				boutput(holder.owner, SPAN_ALERT("No valid telepad found on data network."))
				return FALSE
			else  if(target.z != Z_LEVEL_STATION)
				boutput(holder.owner, SPAN_ALERT("Module only calibrated for nearby station travel."))
				return FALSE

	doCooldown()
		var/since_last_cast = world.time - src.last_cast
		var/cd_penalty_chance = clamp(src.cooldown * 2 - (since_last_cast), 0, 10)
		..()
		if(prob(cd_penalty_chance))
			boutput(holder.owner, SPAN_ALERT("Expansion module registers an error that must be adjusted for."))
			src.last_cast += src.cooldown

	proc/get_first_teleporter()
		var/mob/living/silicon/ai/AI
		if(istype(holder.owner,/mob/living/silicon/ai))
			AI = holder.owner
		else if(istype(holder.owner, /mob/living/intangible/aieye))
			var/mob/living/intangible/aieye/Aeye = holder.owner
			AI = Aeye.mainframe

		if(istype(AI))
			var/datum/powernet/PN = AI.link?.get_direct_powernet()
			if (!PN)
				return FALSE
			for(var/obj/machinery/power/data_terminal/DT in PN.data_nodes)
				var/obj/machinery/networked/telepad/telepad = DT.master
				if(!istype(telepad) || telepad.status & (NOPOWER|BROKEN) || !telepad.link)
					continue
				else
					return telepad

	send
		name = "Telepad: Send"
		desc = "Send current telepad contents to the destination."
		icon_state = "tele_tx"

		cast(atom/target)
			if (..())
				return 1

			var/turf/T = get_turf(target)

			if (istype(T, /turf/space) )
				boutput(holder.owner, SPAN_ALERT("Module inhibits teleportation into space."))
				return 1
			else if (!checkTurfPassable(T))
				boutput(holder.owner, SPAN_ALERT("Module inhibits teleportation solid or poorly accessable areas."))
				return 1

			var/datum/gas_mixture/environment = T.return_air()
			var/env_pressure = MIXTURE_PRESSURE(environment)
			if(env_pressure <= 0.15*ONE_ATMOSPHERE)
				boutput(holder.owner, SPAN_ALERT("Module inhibits teleportation areas with insufficient atmosphere."))
				return

			var/obj/machinery/networked/telepad/telepad = get_first_teleporter()
			if(is_teleportation_allowed(T))
				if(prob(15))
					if(prob(10))
						boutput(holder.owner, SPAN_ALERT("Recalculating..."))
					sleep(randfloat(0.5 SECONDS, 2.5 SECONDS))
				telepad.send(T)
			else
				boutput(holder.owner, SPAN_ALERT("Interference inhibits teleportation."))

	receive
		name = "Telepad: Receive"
		desc = "Send the contents of the target to the current telepad."
		icon_state = "tele_rx"
		cast(atom/target)
			if (..())
				return 1

			var/turf/T = get_turf(target)
			var/obj/machinery/networked/telepad/telepad = get_first_teleporter()
			if(is_teleportation_allowed(T))
				if(prob(85))
					if(prob(10))
						boutput(holder.owner, SPAN_ALERT("Recalculating..."))
					sleep(randfloat(0.5 SECONDS, 2.5 SECONDS))
				telepad.receive(T)
			else
				boutput(holder.owner, SPAN_ALERT("Interference inhibits teleportation."))
