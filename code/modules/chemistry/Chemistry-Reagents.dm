//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.

//important MBC reagent note : implement mult for on_mob_life(). needed for proper realtime processing. lookk for examples, there are plenty
//dont put them on byond-time effects like drowsy. just use them for damage, counters, statuseffects(realtime) etc.

datum
	reagent
		var/name = "Reagent"
		var/id = "reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/list/pathogen_nutrition = null
		var/reagent_state = SOLID
		var/data = null
		var/volume = 0
		///Fluids now have colors
		var/transparency = 150
		var/fluid_r = 0
		var/fluid_b = 0
		var/fluid_g = 255
		var/addiction_prob = 0
		var/addiction_prob2 = 100 // when addiction is being rolled, it's rolled as prob(addiction_prob) && prob(addiction_prob2), it won't roll at all if addiction_prob is 0 though
		var/addiction_min = 0 // how high the tally for this addiction needs to be before addiction_prob starts rolling
		var/max_addiction_severity = "HIGH" // HIGH = barfing, stuns, etc, LOW = twitching, getting tired
		var/dispersal = 4 // The range at which this disperses from a grenade. Should be lower for heavier particles (and powerful stuff).
		var/volatility = 0 // Volatility determines effectiveness in pipebomb. This is 0 for a bad additive, otherwise a positive number which linerally affects explosive power.
		var/reacting = 0 // fuck off chemist spam
		var/overdose = 0 // if reagents are at or above this in a mob, it's an overdose - if double this, it's a major overdose
		var/depletion_rate = 0.4 // this much goes away per tick
		var/penetrates_skin = 0 //if this reagent can enter the bloodstream through simple touch.
		var/touch_modifier = 1 //If this does penetrate skin, how much should be transferred by default (assuming naked dude)? 1 = transfer full amount, 0.5 = transfer half, etc.
		var/taste = "uninteresting"
		var/value = 1 // how many credits this is worth per unit
		var/thirst_value = 0
		var/hunger_value = 0
		var/hygiene_value = 0
		var/bladder_value = 0
		var/energy_value = 0
		var/blob_damage = 0 // If this is a poison, it may be useful for poisoning the blob.
		var/viscosity = 0 // determines interactions in fluids. 0 for least viscous, 1 for most viscous. use decimals!
		var/block_slippy = 0 //fluid flag for slippage control
		var/list/target_organs
		var/heat_capacity = 100 /* how much heat a reagent can hold */
		var/blocks_sight_gas = 0 //opacity
		var/pierces_outerwear = 0//whether or not this penetrates outerwear that may protect the victim(e.g. biosuit)
		var/stun_resist = 0
		var/smoke_spread_mod = 0 //base minimum-required-to-spread on a smoke this chem is in. Highest value in the smoke is used
		var/minimum_reaction_temperature = INFINITY // Minimum temperature for reaction_temperature() to occur, use -INFINITY to bypass this check

		New()
			..()
			if (src.viscosity == 0 && src.reagent_state == SOLID)
				src.viscosity = 0.7

		disposing()
			holder = null
			..()

		pooled()
			..()
			transparency = initial(transparency)
			fluid_r = initial(fluid_r)
			fluid_b = initial(fluid_b)
			fluid_g = initial(fluid_g)
			holder = null
			data = null
			volume = 0
			reacting = 0


		proc/on_add()
			if (stun_resist > 0)
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					M.add_stun_resist_mod("reagent_[src.id]", stun_resist)
			return

		proc/on_remove()
			if (stun_resist > 0)
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stun_resist_mod("reagent_[src.id]")
			return

		proc/on_copy(var/datum/reagent/new_reagent)
			//To support deep copying of a reagent holder
			return

		proc/on_transfer(var/datum/reagents/source, var/datum/reagents/target, var/trans_amt)
			// NOTE: When this proc is invoked, the volume of the reagent will equal the total volume of this reagent.
			// Thus:
			// - the amount of this reagent in source before transfer = src.volume
			// - the amount of this reagent in target after transfer = trans_amt
			// - the amount of this reagent in source after transfer = src.volume - trans_amt
			return

		proc/grenade_effects(var/obj/grenade, var/atom/A)
			return

		proc/reaction_temperature(exposed_temperature, exposed_volume) //By default we do nothing.
			return

		//reaction_mob, reaction_obj reaction_turf and reaction_blob all return 1 by default. Children procs should override return value with 0.
		// This is for fluid interactions : returning 0 means 'this reaction consumed fluid'
		// YES i know this is kind of backwards - however it's much easier to change these return values to 1 than to change every single reagent

		proc/reaction_blob(var/obj/blob/B, var/volume)
			if (!blob_damage)
				return 1
			B.take_damage(blob_damage, volume, "poison")
			return 1

		proc/reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0) //By default we have a chance to transfer some
			var/datum/reagent/self = src					  //of the reagent to the mob on TOUCHING it.
			var/did_not_react = 1
			switch(method)
				if(TOUCH)
					if (penetrates_skin && !("nopenetrate" in paramslist))
						var/modifier = touch_modifier
						if(!src.pierces_outerwear)
							for(var/atom in M.get_equipped_items())
								if (istype(atom, /obj/item/clothing))
									var/obj/item/clothing/C = atom
									modifier -= (1 - C.permeability_coefficient)/3

						if(M.reagents)
							M.reagents.add_reagent(self.id,volume*modifier,self.data)
							did_not_react = 0
					if (ishuman(M) && hygiene_value && method == TOUCH)
						var/mob/living/carbon/human/H = M
						if (H.sims)
							if ((hygiene_value > 0 && !(H.wear_suit || H.w_uniform)) || hygiene_value < 0)
								H.sims.affectMotive("Hygiene", volume * hygiene_value)

				if(INGEST)
					var/datum/ailment_data/addiction/AD = M.addicted_to_reagent(src)
					/*var/addProb = addiction_prob
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.traitHolder.hasTrait("strongwilled"))
							addProb = round(addProb / 2)
					if(prob(addProb) && ishuman(M) && !AD)
						// i would set up a proc for this but this is the only place that adds addictions
						boutput(M, "<span class='alert'><B>You suddenly feel invigorated and guilty...</B></span>")
						AD = new
						AD.associated_reagent = src.name
						AD.last_reagent_dose = world.timeofday
						AD.name = "[src.name] addiction"
						AD.affected_mob = M
						AD.max_severity = src.max_addiction_severity
						M.ailments += AD
					else */if (AD)
						boutput(M, "<span class='notice'><b>You feel slightly better, but for how long?</b></span>")
						M.make_jittery(-5)
						AD.last_reagent_dose = world.timeofday
						AD.stage = 1
/*					if (ishuman(M) && thirst_value)
						var/mob/living/carbon/human/H = M
						if (H.sims)
							H.sims.affectMotive("Thirst", volume * thirst_value)
*/
			if(M.material)
				M.material.triggerChem(M, src, volume)
			for(var/atom/A in M)
				if(A.material) A.material.triggerChem(A, src, volume)
			src = null
			return did_not_react

		proc/reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
			src = null						//if it can hold reagents. nope!
			if(O.material)
				O.material.triggerChem(O, src, volume)
			//if(O.reagents)
			//	O.reagents.add_reagent(id,volume/3)
			return 1

		proc/reaction_turf(var/turf/T, var/volume)
			src = null
			if(T.material)
				T.material.triggerChem(T, src, volume)
			return 1 // returns 1 to spawn fluid. Checked in 'reaction()' proc of Chemistry-Holder.dm


		proc/how_many_depletions(var/mob/M)
			var/deplRate = depletion_rate
			if(!deplRate)
				return
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.traitHolder.hasTrait("slowmetabolism")) //fuck
					deplRate /= 2
				if (H.organHolder)
					if (!H.organHolder.liver || H.organHolder.liver.broken)	//if no liver or liver is dead, deplete slower
						deplRate /= 2
					if (H.organHolder.get_working_kidney_amt() == 0)	//same with kidneys
						deplRate /= 2

			.= src.volume / deplRate

			if (abs(volume - deplRate) < 0.001) //magic number oooo (prevent bug where floating point values linger in body)
				. += 0.001

		//mult is used to handle realtime metabolizations over byond time
		proc/on_mob_life(var/mob/M, var/mult = 1)
			if (!M || !M.reagents)
				return
			if (!holder)
				holder = M.reagents
			var/deplRate = depletion_rate
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.traitHolder.hasTrait("slowmetabolism"))
					deplRate /= 2
				if (H.organHolder)
					if (!H.organHolder.liver || H.organHolder.liver.broken)	//if no liver or liver is dead, deplete slower
						deplRate /= 2
					if (H.organHolder.get_working_kidney_amt() == 0)	//same with kidneys
						deplRate /= 2

				if (H.sims)
					if (src.thirst_value)
						H.sims.affectMotive("Thirst", thirst_value)
					if (src.hunger_value)
						H.sims.affectMotive("Hunger", hunger_value)
					if (src.bladder_value)
						H.sims.affectMotive("Bladder", bladder_value)
					if (src.energy_value)
						H.sims.affectMotive("Energy", energy_value)
			deplRate = deplRate * mult
			if (addiction_prob)
				src.handle_addiction(M, deplRate)

			if (src.volume - deplRate <= 0)
				src.on_mob_life_complete(M)

			holder.remove_reagent(src.id, deplRate) //By default it slowly disappears.

			if(M && overdose > 0) check_overdose(M, mult)
			//if(M && isdead(M) && src.id != "montaguone" && src.id != "montaguone_extra") M.reagents.del_reagent(src.id) // no more puking corpses and such
			return

		//when we entirely drained from sstem, do this
		proc/on_mob_life_complete(var/mob/M)
			.=0

		proc/on_plant_life(var/obj/machinery/plantpot/P)
			if (!P) return

		proc/check_overdose(var/mob/M, var/mult = 1)
			if (!M || !M.reagents)
				return
			if (!holder)
				holder = M.reagents
			var/amount = holder.get_reagent_amount(src.id)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.traitHolder.hasTrait("chemresist"))
					amount *= (0.65 ** mult)
			if (amount >= src.overdose * 2)
				return do_overdose(2, M, mult)
			else if (amount >= src.overdose)
				return do_overdose(1, M, mult)

		proc/do_overdose(var/severity, var/mob/M, var/mult = 1)
			// if there's ever stuff that all drug overdoses should do, put it here
			// for now all this is used for is to determine which overdose effect will happen
			// and allow the individual effects' scale to be adjusted by severity in one spot
			if (ismob(severity)) return //Wire: Fix for shitty fucking byond mixing up vars
			var/effect = rand(1, 100) - severity
			if (effect <= 8)
				M.take_toxin_damage(severity * mult)
			return effect



		proc/handle_addiction(var/mob/M, var/rate)
			//DEBUG_MESSAGE("[src.id].handle_addiction([M],[rate])")
			var/datum/ailment_data/addiction/AD = M.addicted_to_reagent(src)
			if (AD)
				//DEBUG_MESSAGE("already have [AD.name]")
				return AD
			var/addProb = addiction_prob
			//DEBUG_MESSAGE("addProb [addProb]")
			if (isliving(M))
				var/mob/living/H = M
				if (H.traitHolder.hasTrait("strongwilled"))
					addProb = round(addProb / 2)
					rate /= 2
					//DEBUG_MESSAGE("strongwilled: addProb [addProb], rate [rate]")
				if (H.traitHolder.hasTrait("addictive_personality"))
					addProb = round(addProb * 2)
					rate *= 2
					//DEBUG_MESSAGE("addictive_personality: addProb [addProb], rate [rate]")
			if (!holder.addiction_tally)
				holder.addiction_tally = list()
			//DEBUG_MESSAGE("holder.addiction_tally\[src.id\] = [holder.addiction_tally[src.id]]")
			holder.addiction_tally[src.id] += rate
			var/current_tally = holder.addiction_tally[src.id]
			//DEBUG_MESSAGE("current_tally [current_tally], min [addiction_min]")
			if (addiction_min < current_tally && isliving(M) && prob(addProb) && prob(addiction_prob2))
				boutput(M, "<span class='alert'><b>You suddenly feel invigorated and guilty...</b></span>")
				AD = new
				AD.associated_reagent = src.name
				AD.last_reagent_dose = world.timeofday
				AD.name = "[src.name] addiction"
				AD.affected_mob = M
				AD.max_severity = src.max_addiction_severity
				M.ailments += AD
				//DEBUG_MESSAGE("became addicted: [AD.name]")
				return AD
			return

		// reagent state helper procs

		proc/is_solid()
			return reagent_state == SOLID

		proc/is_liquid()
			return reagent_state == LIQUID

		proc/is_gas()
			return reagent_state == GAS

		proc/physical_shock(var/force)
			return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////



		/*helldrug
			name = "cthonium"
			id = "chtonium"
			description = "***CLASSIFIED. ULTRAVIOLET-CLASS ANOMALOUS MATERIAL. INFORMATION REGARDING THIS REAGENT IS ABOVE YOUR PAY GRADE. QUARANTINE THE SAMPLE IMMEDIATELY AND REPORT THIS INCIDENT TO YOUR HEAD OF SECURITY***"
			reagent_state = LIQUID
			fluid_r = 250
			fluid_b = 250
			fluid_g = 0
			transparency = 40

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5)
					if(!locate(/turf/unsimulated/floor/void) in T)
						playsound(T, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
						new /turf/unsimulated/floor/void(T)

		//	When finished, exposure to or consumption of this drug should basically duplicate the
		//	player. send their active body to a horrible hellvoid. back on the station,
		//	replace them with a crunch-critter transposed mob? or just a Transposed Particle Field,
		//	that might be easier
		*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
