/datum/effects/system/foam_spread
	var/amount = 5				// the size of the foam spread.
	var/turf/location
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/metal = 0				// 0=foam, 1=metalfoam, 2=ironfoam,
	var/temperature = T0C
	var/list/banned_reagents = list("smokepowder", "propellant", "pyrosium", "fluorosurfactant", "salt", "poor_concrete", "okay_concrete", "good_concrete", "perfect_concrete")

/datum/effects/system/foam_spread/proc/set_up(amt=5, loca, var/datum/reagents/carry = null, var/metalfoam = 0, var/carry_volume = 0)
	if (!carry)
		return
	amount = round(amt/5, 1)
	amount = min(amount, 7) // FUCK infinifoam holy shit
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

	carried_reagents = list()
	metal = metalfoam
	temperature = carry.total_temperature

	// bit of a hack here. Foam carries along any reagent also present in the glass it is mixed
	// with (defaults to water if none is present). Rather than actually transfer the reagents,
	// this makes a list of the reagent ids and spawns 1 unit of that reagent when the foam disolves.

	if(carry && !metal)
		var/carrymult = 1
		if (carry_volume > 0)
			carrymult = min(carry_volume / carry.total_volume,1)

		for(var/reagent_id in carry.reagent_list)
			var/datum/reagent/current_reagent = carry.reagent_list[reagent_id]
			carried_reagents[reagent_id] = current_reagent.volume * carrymult

/datum/effects/system/foam_spread/proc/start()
	SPAWN(0)
		var/obj/effects/foam/F = locate() in location
		if(F)
			DEBUG_MESSAGE("Located [F] in [location]")
			F.repeated_applications += 1
			//var/min = max(27 - (F.repeated_applications * 3),0)
			var/amt_change = min((amount - (F.repeated_applications*3) ),amount)
			amt_change = max(amt_change,0)
			F.amount += amt_change

			F.amount = min(F.amount, 27)
			return

		F = new /obj/effects/foam
		F.foam_id = "\ref[src][world.time]"
		F.set_up(src.location, metal)
		F.amount = amount

		playsound(F.loc, 'sound/effects/bubbles2.ogg', 80, 1, -3) //let's not play this from every single foam obj

		if(!metal)			// don't carry other chemicals if a metal foam
			F.create_reagents(15)

			if(carried_reagents)
				for(var/id in carried_reagents)
					//Limit reagents in foam to 3 so the nerds can't bomb eveyrthing all day
					if (banned_reagents.Find("[id]"))
						continue
					var/datum/reagent/reagent_volume = carried_reagents[id]
					F.reagents.add_reagent(id,min(reagent_volume,3), null, temperature)
				F.overlays.len = 0
				F.icon_state = "foam"
				F.foamcolor = F.reagents.get_master_color()
				var/icon/I = new /icon('icons/effects/effects.dmi',"foam_overlay")
				I.Blend(F.foamcolor, ICON_ADD)
				F.overlays += I
			else
				F.reagents.add_reagent("cleaner", 1)
				F.overlays.len = 0
				F.icon_state = "foam"
				F.foamcolor = F.reagents.get_master_color()
				var/icon/I = new /icon('icons/effects/effects.dmi',"foam_overlay")
				I.Blend(F.foamcolor, ICON_ADD)
				F.overlays += I
