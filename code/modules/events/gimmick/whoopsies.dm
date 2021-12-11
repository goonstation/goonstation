/datum/random_event/special/whoopsies
	name = "Whoops, someone put detergent in the air system again!"
	customization_available = 1

	admin_call(var/source)
		if (..())
			return

		if (usr.client.holder.level < LEVEL_CODER)
			alert("You must be at least a Coder to mess with this.")
			return
		var/total = 0
		var/foamsize = input(usr, "How much foam?", "Foam Amount") as null|num
		if(isnull(foamsize))
			foamsize = 2
		if(foamsize == 0)
			return
		var/list/picklist = new
		var/pick = input(usr, "Which reagent(s)?","Add Reagents") as null|text
		if (pick)
			picklist = params2list(pick)
			if (length(picklist))
				for(pick in picklist)
					var/amt = input(usr, "How much of [pick]?","Add Reagent") as null|num
					if(!amt || amt < 0)
						picklist[pick] = null
					else
						total += amt
						picklist[pick] = amt

		src.event_effect(picklist, total, foamsize)
		return

	event_effect(var/list/regs = new, var/totalReagents = 0, var/foamsize = 2)
		..()
		if (random_events.announce_events)
			command_alert("Our [pick("sensors","scientists","monitors","fluidity regulators","janitor consultants")] have [pick("detected","found","discovered","noted","warned us that")] \a [pick("strange gathering of fluid","overabundance of moisture","large amount of moist material","spillage of janitorial supplies")] [pick("has built up in","has inundated","has been introduced into","has flooded")] the air distribution network.", "Anomaly Alert")

		for (var/obj/machinery/atmospherics/unary/outlet_injector/I in world)
			LAGCHECK(LAG_LOW)
			if(!I.reagents)
				I.reagents = new(totalReagents)
				I.reagents.my_atom = I
			//var/datum/reagents/reagents = I.reagents
			I.reagents.maximum_volume = totalReagents
			for(var/reagent in regs)
				if(regs[reagent])
					I.reagents.add_reagent(reagent, regs[reagent])
			var/datum/effects/system/foam_spread/s = new()
			s.set_up(foamsize, get_turf(I), I.reagents, 0)
			s.start()
			I.reagents.clear_reagents()
