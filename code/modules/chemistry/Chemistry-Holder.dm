//defines moved to _setup.dm

///////////////////////////////////////////////////////////////////////////////////


//If i somehow could add something that sets the temp of all reagents to the average and calls their temp reactions
//in the update_total_temp , without causing an endless loop - i could have the reagents cool each other down etc.
//Right now only cryostylane does that kinda stuff because its coded that way. So yup. Right now you have to code it.

// Exadv1: reagent_list is now an ASSOCIATIVE LIST for performance reasons

//SpyGuy: Testing out a possibility-based reaction list

var/list/datum/reagents/active_reagent_holders = list()

proc/chem_helmet_check(mob/living/carbon/human/H, var/what_liquid="hot")
	if(H.wear_mask)
		boutput(H, SPAN_ALERT("Your mask protects you from the [what_liquid] liquid!"))
		return 0
	else if(H.head)
		boutput(H, SPAN_ALERT("Your helmet protects you from the [what_liquid] liquid!"))
		return 0
	return 1

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/last_basic_explosion = 0

	var/last_temp = T20C
	var/total_temperature = T20C
	var/total_volume = 0
	var/composite_heat_capacity = 0

	///Set internally to prevent reactions inside reactions.
	var/defer_reactions = 0
	var/deferred_reaction_checks = 0
	var/processing_reactions = 0
	///Do not react. At all. Do not pass go, do not collect $200. Halt. Stop right there, son.
	var/inert = 0

	var/list/addiction_tally = null

	var/tmp/list/datum/chemical_reaction/possible_reactions = list()
	var/tmp/list/datum/chemical_reaction/active_reactions = list()

	var/tmp/list/covered_cache = 0
	var/covered_cache_volume = 0

	var/temperature_cap = 10000
	var/temperature_min = 0

	///attempt at killing infinite foam
	var/postfoam = 0
	///can be heated by external sources
	var/can_be_heated = TRUE

	New(maximum=100)
		..()
		maximum_volume = maximum

	disposing()
		if (reagent_list)
			for(var/reagent_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if(current_reagent)
					qdel(current_reagent)
			reagent_list.len = 0
			reagent_list = null
		my_atom = null
		total_volume = 0
		addiction_tally = null
		..()

	proc/covered_turf()
		.= list()
		if (my_atom)
			.+= get_turf(my_atom)

	proc/cache_covered_turf()
		covered_cache = covered_turf() //heh
		covered_cache_volume = total_volume

	proc/play_mix_sound(var/mix_sound)
		playsound(my_atom, mix_sound, 80, TRUE, 3)

	proc/copy_to(var/datum/reagents/target, var/multiplier = 1, var/do_not_react = 0, var/copy_temperature = 0, var/exception = null)
		if(!target || target == src) return
		var/newtemp = copy_temperature ? src.total_temperature : T20C
		for(var/reagent_id in reagent_list)
			if (reagent_id == exception)
				continue
			var/datum/reagent/current_reagent = reagent_list[reagent_id]
			if(current_reagent)
				target.add_reagent(reagent=reagent_id, amount=max(current_reagent.volume * multiplier, 0.001),donotreact=do_not_react, temp_new = newtemp, sdata=current_reagent.data) //mbc : fixed reagent duplication bug by changing max(x,1) to max(x,0.001). Still technically possible to dupe, but not realistically doable.
				current_reagent.on_copy(target.reagent_list[reagent_id])
			if(!target) return

		return target

	proc/set_reagent_temp(var/new_temp = T0C, var/react = 0)
		src.last_temp = total_temperature
		src.total_temperature = max(new_temp, 0)
		if (react)
			temperature_react()
			handle_reactions()

	///Calls the temperature reaction procs without changing the temp.
	proc/temperature_react()
		for(var/reagent_id in reagent_list)
			var/datum/reagent/current_reagent = reagent_list[reagent_id]
			if(current_reagent && src.total_temperature >= current_reagent.minimum_reaction_temperature)
				current_reagent.reaction_temperature(src.total_temperature, 100)

	///This is what you use to change the temp of a reagent holder.
	///Do not manually change the reagent unless you know what youre doing.
	proc/temperature_reagents(exposed_temperature, exposed_volume = 100, exposed_heat_capacity = 100, change_cap = 15, change_min = 0.0000001,loud = 0, cannot_be_cooled = FALSE)
		if (!src.can_be_heated)
			return
		last_temp = total_temperature
		var/exposed_temp = max(exposed_temperature,0)
		if(loud)
			boutput(world,"exposed_temp: [exposed_temp]")
		exposed_volume = exposed_volume/100 //abitrary but w/e, it makes the new values similar to old ones
		if(loud)
			boutput(world,"exposed_volume: [exposed_volume]")

		if(loud)
			boutput(world,"total_volume: [total_volume]")
		if(loud)
			boutput(world,"composite_heat_capacity: [composite_heat_capacity]")

		var/new_temperature = (total_temperature*total_volume*composite_heat_capacity + exposed_temp*exposed_volume*exposed_heat_capacity)/max(total_volume*composite_heat_capacity + exposed_volume*exposed_heat_capacity, 1)

		if(loud)
			boutput(world,"new_temperature = ([total_temperature]*[total_volume]*[composite_heat_capacity] + [exposed_temp]*[exposed_volume]*[exposed_heat_capacity])/([total_volume]*[composite_heat_capacity] + [exposed_volume]*[exposed_heat_capacity])")

		if(loud)
			boutput(world,"new_temperature: [new_temperature]")

		var/change = new_temperature - total_temperature

		if(change < 0)
			if(cannot_be_cooled)
				return
			change = -clamp(abs(change),change_min,change_cap)
		else
			change = clamp(abs(change),change_min,change_cap)

		if(loud)
			boutput(world,"change: [change]")

		total_temperature += change

		total_temperature = clamp(total_temperature, temperature_min, temperature_cap) //Cap for the moment.

		reagents_changed()

		update_total()

		temperature_react()

		handle_reactions()

	proc/remove_any(var/amount=1)
		if(amount > total_volume) amount = total_volume
		if(amount <= 0) return

		var/remove_ratio = amount/total_volume

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current_reagent = reagent_list[reagent_id]
			if(current_reagent)
				var/transfer_amt = current_reagent.volume*remove_ratio
				src.remove_reagent(reagent_id, transfer_amt)

		src.update_total()

		return amount

	proc/remove_any_to(var/amount=1)
		if(amount > total_volume) amount = total_volume
		if(amount <= 0) return

		var/datum/reagents/R = new()

		var/remove_ratio = amount/total_volume

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current_reagent = reagent_list[reagent_id]
			if(current_reagent)
				var/transfer_amt = current_reagent.volume*remove_ratio
				R.add_reagent(reagent_id, transfer_amt, current_reagent.data)
				src.remove_reagent(reagent_id, transfer_amt)

		src.update_total()

		return R

	proc/remove_any_except(var/amount=1, var/exception)
		if(amount > total_volume) amount = total_volume
		if(amount <= 0) return

		var/remove_ratio = amount/total_volume

		for(var/reagent_id in reagent_list)
			if (reagent_id == exception)
				continue

			var/datum/reagent/current_reagent = reagent_list[reagent_id]
			if(current_reagent)
				var/transfer_amt = current_reagent.volume*remove_ratio
				src.remove_reagent(reagent_id, transfer_amt)

		src.update_total()

		return amount

	proc/get_master_reagent_name()
		var/largest_name = null
		var/largest_volume = 0

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current = reagent_list[reagent_id]
			if(current.volume > largest_volume)
				largest_name = current.name
				largest_volume = current.volume
		if (largest_name == "mirabilis")
			largest_name = " "
		return largest_name


	proc/get_master_reagent_id()
		var/largest_id = null
		var/largest_volume = 0

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current = reagent_list[reagent_id]
			if(current.volume > largest_volume)
				largest_id = current.id
				largest_volume = current.volume

		return largest_id

	proc/get_master_color()
		var/largest_volume = 0
		var/the_color = rgb(255,255,255,255)

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current = reagent_list[reagent_id]
			if(current.volume > largest_volume)
				largest_volume = current.volume
				the_color = rgb(current.fluid_r, current.fluid_g, current.fluid_b, max(current.transparency,255))

		return the_color

	proc/get_master_reagent()
		var/largest_id = ""
		var/largest_volume = 0

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current = reagent_list[reagent_id]
			if(current.volume > largest_volume)
				largest_volume = current.volume
				largest_id = reagent_id

		return largest_id

	proc/get_master_reagent_slippy()
		var/largest_block_slippy = null
		var/largest_volume = 0

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current = reagent_list[reagent_id]
			if(current.volume > largest_volume)
				largest_block_slippy = current.block_slippy
				largest_volume = current.volume

		return largest_block_slippy

	proc/get_master_reagent_gas_opaque()
		var/opacity_to_return = null
		var/largest_volume = 0

		for(var/reagent_id in reagent_list)
			var/datum/reagent/current = reagent_list[reagent_id]
			if(current.volume > largest_volume)
				opacity_to_return = current.blocks_sight_gas
				largest_volume = current.volume

		return opacity_to_return

	/// index = which reagent to transfer (0 = all)
	proc/trans_to(var/obj/target, var/amount=1, var/multiplier=1, var/do_fluid_react=1, var/index=0, var/exception=0)
		if(amount > total_volume) amount = total_volume
		if(amount <= 0) return
		if(!target) return

		if (isnull(target.reagents))
			target.create_reagents()

		var/datum/reagents/target_reagents = target.reagents
		amount = min(amount, target_reagents.maximum_volume - target_reagents.total_volume)
		if(amount <= 0) return

		if (do_fluid_react && issimulatedturf(target))
			var/turf/simulated/T = target
			return T.fluid_react(src, amount, index = index)

		return trans_to_direct(target_reagents, amount, multiplier, index = index, exception = exception)

	// MBC note : I added update_target_reagents and update_self_reagents vars for fluid handling. y'see, there are a ton of transfer operations involving fluids that don't need to update reagents immediately as they happen.
	// we would rather perform all the transfers, and then batch update the reagents when necessary. Saves us from some lag, and avoids some *buggy shit*!
	proc/trans_to_direct(var/datum/reagents/target_reagents, var/amount=1, var/multiplier=1, var/update_target_reagents = 1, var/update_self_reagents = 1, var/index = 0, var/exception = null)
		if (!target_reagents || !total_volume) //Wire & ZeWaka: Fix for Division by zero
			return
		var/transfer_ratio = amount/total_volume

		if(!index)
			for(var/reagent_id in reagent_list)
				if (reagent_id == exception)
					continue

				var/datum/reagent/current_reagent = reagent_list[reagent_id]
				if (isnull(current_reagent) || current_reagent.volume == 0)
					continue

				var/transfer_amt = current_reagent.volume*transfer_ratio
				var/receive_amt = transfer_amt * multiplier

				/*if(istype(current_reagent, /datum/reagent/disease))
					target_reagents.add_reagent_disease(current_reagent, (transfer_amt * multiplier), current_reagent.data, current_reagent.temperature)
				else*/
				target_reagents.add_reagent(reagent_id, receive_amt, current_reagent.data, src.total_temperature, TRUE, TRUE)

				current_reagent.on_transfer(src, target_reagents, receive_amt)

				src.remove_reagent(reagent_id, transfer_amt, FALSE, FALSE)
		else //Only transfer one reagent
			var/CI = 1
			for(var/reagent_id in reagent_list)
				if (reagent_id == exception)
					continue
				if ( CI++ == index )
					var/datum/reagent/current_reagent = reagent_list[reagent_id]
					if (isnull(current_reagent) || current_reagent.volume == 0)
						break
					var/transfer_amt = min(current_reagent.volume,amount)
					var/receive_amt = transfer_amt * multiplier
					target_reagents.add_reagent(reagent_id, receive_amt, current_reagent.data, src.total_temperature, TRUE, TRUE)
					current_reagent.on_transfer(src, target_reagents, receive_amt)
					src.remove_reagent(reagent_id, transfer_amt, FALSE, FALSE)
					break

		if (update_self_reagents)
			src.update_total()
			src.handle_reactions()
			// this was missing. why was this missing? i might be breaking the shit out of something here
			src.reagents_changed()

		if (!target_reagents) // on_transfer may murder the target, see: nitroglycerin
			return amount

		if (update_target_reagents)
			target_reagents.update_total()
			target_reagents.handle_reactions()
			target_reagents.reagents_changed(TRUE)

		reagents_transferred()
		return amount

	/// multiplier is used to handle realtime metabolizations over byond time
	proc/metabolize(var/mob/target, var/multiplier = 1)
		if (islist(src.addiction_tally) && length(src.addiction_tally)) // if we got some addictions to process
			//DEBUG_MESSAGE("metabolize([target]) addiction_tally processing")
			for (var/rid in src.addiction_tally) // look at each addiction tally
				if (src.reagent_list.Find(rid)) // if we find that we've got that reagent in us right now
					//DEBUG_MESSAGE("[rid] currently in holder, continuing")
					continue // our tally's gunna go up for this reagent when it runs on_mob_life() below, so don't reduce it
				//DEBUG_MESSAGE("src.addiction_tally\[[rid]\] was [src.addiction_tally[rid]], now [src.addiction_tally[rid] - 0.2]")
				src.addiction_tally[rid] -= 0.01 * multiplier// otherwise, reduce it
				if (src.addiction_tally[rid] <= 0)
					src.addiction_tally -= rid

		var/mult_per_reagent = 1
		for (var/current_id in reagent_list)
			if(QDELETED(src)) return
			var/datum/reagent/current_reagent = reagent_list[current_id]
			if (current_reagent)
				mult_per_reagent = min(multiplier,current_reagent.how_many_depletions(target)) //limit the multiplier by how many depletions we have left

				//Actually, cap the multiplier minimum at 1	. This preserves some of the original expected funky stuff pre-realtime changes.
				// If someone who knows more about chemistry than MBC wants to remove this line, go right ahead :
				//mult_per_reagent = max(mult_per_reagent, 1)
				//hey this is mbc a couple months later, i commented out this line.


				current_reagent.on_mob_life(target, mult = mult_per_reagent)

		update_total()

	proc/handle_reactions()
		if(src.inert) return //We magically prevent all reactions inside ourselves.
		//if(ismob(my_atom)) return //No reactions inside mobs :I
		if (defer_reactions)
			deferred_reaction_checks++
			return
		var/list/old_reactions = active_reactions
		active_reactions = list()
		reaction_loop:
			for(var/datum/chemical_reaction/C in src.possible_reactions)
				if(src.disposed)
					return
				if (!islist(C.required_reagents)) //This shouldn't happen but when practice meets theory...they beat the shit out of one another I guess
					continue

				//Min / max temp intervals
				if(total_temperature < C.min_temperature)
					continue
				else if(total_temperature > C.max_temperature) continue

				var/total_matching_reagents = 0
				var/created_volume = src.maximum_volume
				for(var/B in C.required_reagents)
					var/B_required_volume = max(CHEM_EPSILON, C.required_reagents[B])
					//var/amount = get_reagent_amount(B)
					//trying to reduce proc call overhead from fluid system
					//copied get_reagent_amount proc here because it's relatively simple procedure
					var/amount = 0
					try
						if (reagent_list[B])
							var/datum/reagent/current_reagent = reagent_list[B]
							amount = current_reagent.volume
					catch (var/e)
						logTheThing(LOG_DEBUG, usr, "CRASH: reagent holder / handle_reactions: [C.name] reaction, reagent checked: '[B]', required = '[B_required_volume]', reagents in thing: [log_reagents(my_atom)].")
						CRASH("reagent holder / handle_reactions: tried to get reagent list '[B]' from '[reagent_list]' / [e]")
					//end my copy+paste


					if(round(amount, CHEM_EPSILON) >= B_required_volume || ((locate(C.type) in old_reactions) && amount >= CHEM_EPSILON && !C.instant))
						//This will mean you can have < 1 stuff not react OR the reaction is non-instant and already processing. This SHOULD be fine.
						total_matching_reagents++
						created_volume = min(created_volume, amount * (C.result_amount ? C.result_amount : 1) / B_required_volume)
					else
						break
				if(total_matching_reagents == C.required_reagents.len)
					for (var/inhibitor in C.inhibitors)
						var/inhibitor_amount_to_check = 0
						if (C.inhibitors[inhibitor])
							inhibitor_amount_to_check = C.inhibitors[inhibitor]
						if (src.has_reagent(inhibitor, inhibitor_amount_to_check))
							continue reaction_loop

					if(!C.does_react(src))
						continue reaction_loop

					if (!(locate(C.type) in old_reactions) && !(C in src.active_reactions))
						var/turf/T = 0
						if (my_atom)
							for(var/mob/living/M in AIviewers(7, get_turf(my_atom)) )	//Fuck you, ghosts
								if (C.mix_phrase) boutput(M, SPAN_NOTICE("[bicon(my_atom)] [C.mix_phrase]"))
							if (C.mix_sound) play_mix_sound(C.mix_sound)

							T = get_turf(my_atom.loc)

						// Ideally, we'd like to know the contents of chemical smoke and foam (Convair880).
						if (C.special_log_handling)
							logTheThing(LOG_CHEMISTRY, usr, "[C.name] chemical reaction [log_reagents(my_atom)] at [T ? "[log_loc(T)]" : "null"].")
							if(istype(src.my_atom, /obj/item/reagent_containers) && !locate(/obj/machinery/chem_dispenser) in get_turf(src.my_atom))
								message_admins("[key_name(usr)] caused a [C.name] reaction [log_reagents(my_atom)] at [T ? "[log_loc(T)]" : "null"].")
						else
							logTheThing(LOG_CHEMISTRY, usr, "[C.name] chemical reaction at [T ? "[log_loc(T)]" : "null"].")

					if (C.instant)
						//MBC : Cache covered turfs right before the reagents are deleted.
						// This is necessary to allow reactions to take place as part of a fluid.
						cache_covered_turf()
						var/datum/reagents/fluid_group/FG
						if (istype(src,/datum/reagents/fluid_group))
							FG = src

						for (var/B in C.required_reagents)
							if (FG) //MBC : I don't like doing this here, but it is necessary for fluids not to delete themselves mid-reaction
								FG.skip_next_update = 1
							var/amount_to_consume = C.required_reagents[B] * created_volume / (C.result_amount ? C.result_amount : 1)
							if(C.consume_all)
								var/datum/reagent/current_reagent_to_remove = src.reagent_list[B]
								amount_to_consume = current_reagent_to_remove ? current_reagent_to_remove.volume : 0
							src.remove_reagent(B, amount_to_consume, FALSE, FALSE)
						//only now, after all reactants for this particular reaction have reacted away, we update the chemistry holder and check for new reactions. No chem duping allowed.
						src.update_total()
						src.reagents_changed()

						if(C.result)
							src.add_reagent(C.result, created_volume,, src.total_temperature, chemical_reaction=TRUE)
						if(created_volume <= 0) //MBC : If a fluid reacted but didn't create anything, we require an update_total call to do drain/evaporate checks.
							src.update_total()
							if (FG && FG.my_group && src.total_volume <= 0) //also evaporate safety here
								FG.my_group.evaporate()
						C.on_reaction(src, created_volume)
						chemistry_particle(src, C)
						covered_cache = 0
						continue
					if (C.stateful)
						var/datum/chemical_reaction/old_reaction = locate(C.type) in old_reactions
						if (old_reaction)
							active_reactions += old_reaction
						else
							active_reactions += new C.type
					else
						active_reactions += C

		var/list/removed_reactions = old_reactions - src.active_reactions
		for (var/datum/chemical_reaction/reaction in removed_reactions)
			reaction.on_end_reaction(src)

		if (!active_reactions.len)
			if (processing_reactions)
				processing_reactions = 0
				active_reagent_holders -= src
		else if (!processing_reactions)
			processing_reactions = 1
			active_reagent_holders += src
		return 1

	proc/process_reactions()
		defer_reactions = 1
		deferred_reaction_checks = 0
		for(var/datum/chemical_reaction/C in src.active_reactions)
			if (C.result_amount <= 0)
				src.active_reactions -= C
				C.on_end_reaction(src)
				if (C.stateful)
					qdel(C)
				continue
			if(C.temperature_change)
				src.set_reagent_temp(src.total_temperature += C.temperature_change, react = TRUE)
			var/speed = C.reaction_speed * C.get_reaction_speed_multiplicator(src)
			for (var/reagent in C.required_reagents)
				var/required_amount = C.required_reagents[reagent] * speed / C.result_amount

				//Copy+paste to reduce proc calls
				//var/amount = get_reagent_amount(reagent)
				if (!(reagent in reagent_list))
					speed = 0
					continue
				var/datum/reagent/current_reagent = reagent_list[reagent]
				var/amount = current_reagent ? current_reagent.volume : 0
				//end copy+paste

				if (amount < required_amount)
					speed *= amount / required_amount
			if (speed <= 0) // don't add anything that modifies the speed before this check
				src.active_reactions -= C
				C.on_end_reaction(src)
				if (C.stateful)
					qdel(C)
				continue

			cache_covered_turf()
			C.on_reaction(src, speed)
			for (var/reagent in C.required_reagents)
				src.remove_reagent(reagent, C.required_reagents[reagent] * speed / C.result_amount)
			if (C.result)
				src.add_reagent(C.result, speed,, src.total_temperature, chemical_reaction=TRUE)
			covered_cache = 0
			chemistry_particle(src, C)

			if(my_atom?.loc) //We might be inside a thing, let's tell it we updated our reagents.
				my_atom.loc.handle_event("reagent_holder_update", src)

		defer_reactions = 0
		if (deferred_reaction_checks)
			src.handle_reactions()
		else if (!active_reactions.len && processing_reactions)
			processing_reactions = 0
			active_reagent_holders -= src

	proc/isolate_reagent(var/reagent)
		for(var/current_id in reagent_list)
			if (current_id != reagent)
				del_reagent(current_id)
				update_total()

	/**	Deletes a reagent from a container.
		The first argument is the reagent id, the second whether or not the total volume of the container should update,
		which may be undesirable in the update_total proc.
		*/
	proc/del_reagent(var/reagent, var/update_total = TRUE)
		if(src.disposed)
			CRASH("Attempting to delete [reagent] from disposed /datum/reagents.")
		var/datum/reagent/current_reagent = reagent_list[reagent]

		if (current_reagent)
			current_reagent.volume = 0 //mbc : I put these checks here to try to prevent an infloop
			current_reagent.check_threshold()
			if (current_reagent.disposed) //Caused some sort of infinite loop? gotta be safe.
				reagent_list.Remove(reagent)
			else
				current_reagent.on_remove()
				remove_possible_reactions(current_reagent.id) //Experimental structure
				reagent_list.Remove(reagent)
				if(update_total)
					update_total()

				reagents_changed()

				qdel(current_reagent)

				handle_reactions() //we might have removed an inhibitor, check if we should react

			return 0

		return 1

	proc/update_total()
		total_volume = 0

		for(var/current_id in reagent_list)
			var/datum/reagent/current_reagent = reagent_list[current_id]
			if(current_reagent)
				if(current_reagent.volume <= CHEM_EPSILON)
					del_reagent(current_id, update_total = FALSE)
				else
					current_reagent.volume = max(round(current_reagent.volume, 0.001), 0.001)
					composite_heat_capacity = total_volume/(total_volume+current_reagent.volume)*composite_heat_capacity + current_reagent.volume/(total_volume+current_reagent.volume)*current_reagent.heat_capacity
					total_volume += current_reagent.volume
		if(isitem(my_atom))
			var/obj/item/I = my_atom
			I.tooltip_rebuild = 1
		return 0

	proc/clear_reagents()
		for(var/current_id in reagent_list)
			del_reagent(current_id)

		return 0

	proc/grenade_effects(var/obj/grenade, var/atom/A)
		for (var/id in src.reagent_list)
			var/datum/reagent/R = src.reagent_list[id]
			R.grenade_effects(grenade, A)

	///	paramslist thingy can override the can_burn oh god im sorry.	paramslist only used for mobs for now, feeel free to paste in for turfs objs
	proc/reaction(var/atom/A, var/method=TOUCH, var/react_volume, var/can_spawn_fluid = 1, var/minimum_react = 0.01, var/can_burn = 1, var/list/paramslist = 0, var/exception = null)
		if (src.total_volume <= 0)
			return
		if (isintangible(A))
			return
		if (isobserver(A)) // errrr
			return

		.= list() //return a list of reagent_ids whose reactions were successful (e.g. had a custom effect. Used to decide if we should consume a fluid)

		if (!react_volume)
			react_volume = src.total_volume
		var/volume_fraction = react_volume / src.total_volume

		if (ismob(A))
			var/mob/M = A
			M.on_reagent_react(src, method, react_volume)

		var/turf/simulated/floor/fluid_turf
		var/datum/reagents/temp_fluid_reagents
		if (issimulatedturf(A))
			fluid_turf = A
			temp_fluid_reagents = new /datum/reagents(react_volume)
			//F.reagents.copy_to(temp_fluid_reagents)
			//if(current_reagent)
			//	target.add_reagent(reagent=reagent_id, amount=max(current_reagent.volume * multiplier, 1),donotreact=do_not_react)


		switch(method)
			if(TOUCH)
				var/mob/living/carbon/human/H = A
				if(istype(H) && can_burn)
					var/temp_to_burn_with = total_temperature
					var/dmg_multiplier = 1
					if (length(paramslist))
						if ("override_can_burn" in paramslist)
							temp_to_burn_with = paramslist["override_can_burn"]
						if ("dmg_multiplier" in paramslist)
							dmg_multiplier = paramslist["dmg_multiplier"]

					if(temp_to_burn_with > H.base_body_temp + (H.temp_tolerance * 4) && !H.is_heat_resistant())
						if (chem_helmet_check(H, "hot"))
							boutput(H, SPAN_ALERT("You are scalded by the hot chemicals!"))
							H.TakeDamage("head", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN) // lol this caused brute damage
							H.emote("scream")
							H.bodytemperature += clamp((temp_to_burn_with - (H.base_body_temp + (H.temp_tolerance * 4))) - 20, 5, 500)
					else if(temp_to_burn_with < H.base_body_temp - (H.temp_tolerance * 4) && !H.is_cold_resistant())
						if (chem_helmet_check(H, "cold"))
							boutput(H, SPAN_ALERT("You are frostbitten by the freezing cold chemicals!"))
							H.TakeDamage("head", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN)
							H.emote("scream")
							H.bodytemperature -= clamp((H.base_body_temp - (H.temp_tolerance * 4)) - temp_to_burn_with - 20, 5, 500)

				for(var/current_id in reagent_list)
					if (current_id == exception)
						continue
					var/datum/reagent/current_reagent = reagent_list[current_id]
					var/turf_reaction_success = 0
					// drsingh attempted fix for Cannot read null.volume, but this one makes no sense. should have been protected already
					//mbc : I put in a check to stop extremely distilled things in fluids from reacting
					if(current_reagent != null && current_reagent.volume > minimum_react) // Don't put spawn(0) in the below three lines it breaks foam! - IM
						if(ismob(A) && !isobserver(A))
							if (!current_reagent.reaction_mob_chemprot_layer(A, TOUCH, current_reagent.volume*volume_fraction, paramslist))
								.+= current_id
						if(isturf(A))
							if (!current_reagent.reaction_turf(A, current_reagent.volume*volume_fraction))
								turf_reaction_success = 1
								.+= current_id
						if(isobj(A))

							if (istype(A, /obj/overlay))
								continue
							// use current_reagent.reaction_obj for stuff that affects all objects
							// and reagent_act for stuff that affects specific objects
							if (!current_reagent.reaction_obj(A, current_reagent.volume*volume_fraction))
								.+= current_id
							if(A)
								// we want to make sure its still there after the initial reaction
								A.reagent_act(current_reagent.id,current_reagent.volume*volume_fraction,src)
							if (istype(A, /obj/blob))
								if (!current_reagent.reaction_blob(A, current_reagent.volume*volume_fraction))
									.+= current_id
						if (!turf_reaction_success && temp_fluid_reagents)
							temp_fluid_reagents.add_reagent(current_id, current_reagent.volume*volume_fraction, current_reagent.data, src.total_temperature, 1)
						//if (can_spawn_fluid && !turf_reaction_success && fluid_turf && current_reagent)
						//	fluid_turf.fluid_react_single(current_id, current_reagent.volume*volume_fraction) // todo optimize (too many fluid react singles, you can batch it)
			if(INGEST)

				if(ismob(A) && !isobserver(A) && can_burn)
					if(iscarbon(A))
						var/mob/living/carbon/C = A
						var/temp_to_burn_with = total_temperature
						var/dmg_multiplier = 1
						if (length(paramslist))
							if ("override_can_burn" in paramslist)
								temp_to_burn_with = paramslist["override_can_burn"]
							if ("dmg_multiplier" in paramslist)
								dmg_multiplier = paramslist["dmg_multiplier"]

						if(C.bioHolder)
							if(temp_to_burn_with > C.base_body_temp + (C.temp_tolerance * 4) && !C.is_heat_resistant())
								boutput(C, SPAN_ALERT("You scald yourself trying to consume the boiling hot substance!"))
								C.TakeDamage("chest", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN)
								C.bodytemperature += clamp((temp_to_burn_with - T0C) - 20, 5, 700)
							else if(temp_to_burn_with < C.base_body_temp - (C.temp_tolerance * 4) && !C.is_cold_resistant())
								boutput(C, SPAN_ALERT("You frostburn yourself trying to consume the freezing cold substance!"))
								C.TakeDamage("chest", 0, 7 * dmg_multiplier, 0, DAMAGE_BURN)
								C.bodytemperature -= clamp((temp_to_burn_with - T0C) - 20, 5, 700)


				// These spawn calls were breaking stuff elsewhere. Since they didn't appear to be necessary and
				// I didn't come across problems in local testing, I've commented them out as an experiment. If you've come
				// here while investigating INGEST-related bugs, feel free to revert my change (Convair880).
				for(var/current_id in reagent_list)
					if (current_id == exception)
						continue
					var/datum/reagent/current_reagent = reagent_list[current_id]
					var/turf_reaction_success = 0
					if(current_reagent && current_reagent.volume > minimum_react)
						if(ismob(A) && !isobserver(A))
							//SPAWN(0)
								//if (current_reagent) //This is in a spawn. Between our first check and the execution, this may be bad.
							if (!current_reagent.reaction_mob(A, INGEST, current_reagent.volume*volume_fraction, paramslist, current_reagent.volume*volume_fraction))
								.+= current_id
						if(isturf(A))
							//SPAWN(0)
								//if (current_reagent)
							if (!current_reagent.reaction_turf(A, current_reagent.volume*volume_fraction))
								turf_reaction_success = 1
								.+= current_id
						if(isobj(A))
							//SPAWN(0)
								//if (current_reagent)
							if (!current_reagent.reaction_obj(A, current_reagent.volume*volume_fraction))
								.+= current_id
						if (!turf_reaction_success && temp_fluid_reagents)
							temp_fluid_reagents.add_reagent(current_id, current_reagent.volume*volume_fraction, current_reagent.data, src.total_temperature, 1)
						//if (can_spawn_fluid && !turf_reaction_success && fluid_turf)
						//	fluid_turf.fluid_react_single(current_id, current_reagent.volume*volume_fraction)

		if (can_spawn_fluid && fluid_turf && temp_fluid_reagents)
			temp_fluid_reagents.update_total()
			fluid_turf.fluid_react(temp_fluid_reagents, temp_fluid_reagents.total_volume)

	proc/add_reagent(var/reagent, var/amount, var/sdata, var/temp_new=T20C, var/donotreact = 0, var/donotupdate = 0, var/chemical_reaction = FALSE, var/chem_reaction_priority = 1)
		if(istype(my_atom, /obj/item/reagent_containers/glass/plumbing) && chemical_reaction)
			var/obj/item/reagent_containers/glass/plumbing/condenser/condenser = my_atom
			condenser.try_adding_reagents_to_container(reagent, amount, sdata, temp_new, donotreact, donotupdate, chem_reaction_priority)
			return
		if(!isnum(amount) || amount <= 0 || src.disposed)
			return 1
		var/added_new = FALSE
		//this needs to be separate var because reagents added below 1u aren't real apparently
		var/check_reactions = FALSE
		if (!donotupdate)
			update_total()
		amount = round(amount, CHEM_EPSILON)
		if(amount < CHEM_EPSILON)
			return 0
		if(total_volume + amount > maximum_volume)
			amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

		var/datum/reagent/current_reagent = reagent_list[reagent]

		if(!current_reagent)
			if (length(reagents_cache) <= 0)
				build_reagent_cache()

			current_reagent = reagents_cache[reagent]

			if(current_reagent)
				current_reagent = new current_reagent.type
				reagent_list[reagent] = current_reagent
				current_reagent.holder = src
				current_reagent.volume = 0
				current_reagent.data = sdata
				added_new = TRUE
				check_reactions = TRUE
			else
				CRASH("Invalid reagent [reagent] in [src.my_atom] [src.my_atom?.type] (add_reagent))")
		// Else, if the reagent datum already exists, we'll just be adding to that and won't update with our new reagent datum data

		var/new_amount = (current_reagent.volume + amount)
		if (current_reagent.volume < 1 && new_amount >= 1)
			check_reactions = TRUE
		current_reagent.volume = new_amount
		if(!current_reagent.data) current_reagent.data = sdata

		src.last_temp = src.total_temperature
		var/temp_temperature = src.total_temperature*src.total_volume*src.composite_heat_capacity + temp_new*amount*current_reagent.heat_capacity

		var/divison_amount = src.total_volume*src.composite_heat_capacity + amount*current_reagent.heat_capacity
		if (divison_amount > 0)
			src.total_temperature = temp_temperature / divison_amount

		if(added_new)
			current_reagent.on_add()

		current_reagent.check_threshold()

		if (!donotupdate)
			update_total()

		if(!donotreact)
			temperature_react()

		if (!donotupdate)
			reagents_changed(1)

		if((added_new || check_reactions) && !QDELETED(current_reagent))
			append_possible_reactions(current_reagent.id) //Experimental reaction possibilities
			if (!donotreact)
				src.handle_reactions()
		return 1

	proc/remove_reagent(var/reagent, var/amount, var/update_total = 1, var/reagents_change = 1)

		if(!isnum(amount)) return 1

		if (istype(reagent, /datum/reagent))
			CRASH("Attempt to remove reagent by ref")

		var/datum/reagent/current_reagent = reagent_list[reagent]

		if(current_reagent)
			current_reagent.volume -= amount
			current_reagent.check_threshold()
			if(current_reagent.volume <= 0 && (reagents_change || update_total))
				del_reagent(reagent)

			if (update_total)
				update_total()
			if (reagents_change)
				reagents_changed()

		return 1

	// removed a check if reagent_list existed here in the interest of performance
	// if this happens again try to figure out why the fuck reagent_list would go null
	proc/has_reagent(var/reagent, var/amount=0)
		var/datum/reagent/current_reagent = reagent_list[reagent]
		return current_reagent && current_reagent.volume >= amount

	proc/has_any(list/reagents, amount)
		for (var/reagent_id in reagents)
			if (src.has_reagent(reagent_id, amount))
				return TRUE
		return FALSE

	proc/has_active_reaction(var/reaction_id, var/amount=0)
		for(var/datum/chemical_reaction/C in src.active_reactions)
			if(C.id == reaction_id)
				return C && C.result_amount >= amount
		return FALSE

	proc/get_reagent(var/reagent_id)
		RETURN_TYPE(/datum/reagent)
		return reagent_list[reagent_id]

	proc/get_reagent_amount(var/reagent)
		var/datum/reagent/current_reagent = reagent_list[reagent]

		return current_reagent ? current_reagent.volume : 0

	proc/get_dispersal()
		if (!total_volume)
			return 0
		var/dispersal = 9999
		for (var/id in reagent_list)
			var/datum/reagent/R = reagent_list[id]
			if (R.dispersal < dispersal)
				dispersal = R.dispersal
		return dispersal

	proc/get_smoke_spread_mod()
		if (!total_volume)
			return 0
		var/smoke_spread_mod = 9999
		for (var/id in reagent_list)
			var/datum/reagent/R = reagent_list[id]
			if (R.smoke_spread_mod < smoke_spread_mod)
				smoke_spread_mod = R.smoke_spread_mod
		return smoke_spread_mod


	/// redirect my_atom.on_reagent_change() through this function. var/add will be 1 if reagents were just added
	proc/reagents_changed(var/add = 0)
		if (my_atom)
			my_atom.on_reagent_change(add)
		return

	proc/reagents_transferred()
		my_atom?.on_reagent_transfer()
		return

	/// li'l tiny helper thing vOv
	proc/is_full()
		if (src.total_volume >= src.maximum_volume)
			return 1
		else
			return 0

	/////////////////////////
	// procs for description and color of this collection of reagents


	/// returns text description of reagent(s)
	/// plus exact text of reagents if using correct equipment
	proc/get_description(mob/user, rc_flags=0)
		if (rc_flags == 0 || !user.sight_check(1))	// Report nothing about the reagents in this case
			return null

		if (length(reagent_list))
			. += get_inexact_description(rc_flags)
			if(rc_flags & RC_SPECTRO)
				. += get_exact_description(user)
		else //if there is nothing in it, say "nothing in it"
			. += SPAN_NOTICE("Nothing in it.")


	proc/get_exact_description(mob/user)

		if(!length(reagent_list))
			return

		// check to see if user wearing the spectoscopic glasses (or similar)
		// if so give exact readout on what reagents are present
		if (HAS_ATOM_PROPERTY(user, PROP_MOB_SPECTRO))
			if("cloak_juice" in reagent_list)
				var/datum/reagent/cloaker = reagent_list["cloak_juice"]
				if(cloaker.volume >= 5)
					. += "<br>[SPAN_ALERT("ERR: SPECTROSCOPIC ANALYSIS OF THIS SUBSTANCE IS NOT POSSIBLE.")]"
					return

			SEND_SIGNAL(src, COMSIG_REAGENTS_ANALYZED, user)

			. += "<br>[SPAN_ALERT("Spectroscopic analysis:")]"

			for(var/current_id in reagent_list)
				var/datum/reagent/current_reagent = reagent_list[current_id]
				. += "<br>[SPAN_ALERT("[current_reagent.volume] units of [current_reagent.name]")]"

			if (user.traitHolder.hasTrait("training_bartender"))
				var/eth_eq = get_ethanol_equivalent(user, src)
				if (eth_eq)
					. += "<br> [SPAN_REGULAR("You estimate there's the equivalent of <b>[eth_eq] units of ethanol</b> here.")]"
		return

	proc/get_reagents_fullness()
		.= get_fullness(total_volume / maximum_volume * 100)

	proc/get_inexact_description(var/rc_flags=0)
		if(rc_flags == 0)
			return null

		var/full_text = get_reagents_fullness()

		if(full_text == "empty")
			if(rc_flags & (RC_SCALE | RC_VISIBLE | RC_FULLNESS) )
				. += SPAN_NOTICE("It is empty.")
			return

		var/datum/color/c = get_average_color()

		//. += "([c.r],[c.g],[c.b];[c.a])"

		var/nearest_color_text = get_nearest_color(c)

		var/opaque_text = get_opaqueness(c.a)

		var/state_text = get_state_description()

		if(state_text == "solid")	// if only have solids present, don't include opacity text
			opaque_text = null

		if(opaque_text) opaque_text += ", "

		var/t = "[opaque_text][nearest_color_text]"

		if(rc_flags & RC_VISIBLE)
			if(rc_flags & RC_SCALE)
				. += SPAN_NOTICE("It contains [total_volume] units of \a [t]-colored [state_text].")
			//blurgh
			else if (full_text && istype(src, /datum/reagents/fluid_group))
				. += SPAN_NOTICE("It is \a [full_text] [t]-colored [state_text].")
			else if (full_text)
				. += SPAN_NOTICE("It is [full_text] of \a [t]-colored [state_text].")
			else
				. += SPAN_NOTICE("It is \a [t]-colored [state_text].")
		else
			if(rc_flags & RC_SCALE)
				. += SPAN_NOTICE("It contains [total_volume] units.")
			else if((rc_flags & RC_FULLNESS) && full_text)
				. += SPAN_NOTICE("It is [full_text].")

		return .


	/// returns the average color of the reagents
	/// taking into account concentration and transparency
	/// reagent_exception_ids argument is a list of reagents to excluded from the calculation
	proc/get_average_color(list/reagent_exception_ids = null)
		RETURN_TYPE(/datum/color)
		var/datum/color/average = new(0,0,0,0)
		var/total_weight = 0

		for(var/id in reagent_list)
			if(reagent_exception_ids && (id in reagent_exception_ids))
				continue

			var/datum/reagent/current_reagent = reagent_list[id]

			// weigh contribution of each reagent to the average color by amount present and it's transparency

			var/weight = min(current_reagent.volume * current_reagent.transparency / 255, 1e24) //infinity breaks things real badly here
			total_weight += weight

			average.r += weight * current_reagent.fluid_r
			average.g += weight * current_reagent.fluid_g
			average.b += weight * current_reagent.fluid_b
			average.a += weight * current_reagent.transparency

		// now divide by total weight to get average color
		if(total_weight > 0)
			average.r /= total_weight
			average.g /= total_weight
			average.b /= total_weight
			average.a /= total_weight
		return average

	proc/get_average_rgb()
		var/datum/color/average = get_average_color()
		return rgb(average.r, average.g, average.b)

	/// give a list of the n tastes that are most present in this mixture
	/// takes argument of how many tastes
	proc/get_prevalent_tastes(var/num_val)
		RETURN_TYPE(/list)
		// create associative list with key = taste, val = total volume
		var/list/reag_list = list()
		for (var/current_id in src.reagent_list)
			var/datum/reagent/current_reagent = src.reagent_list[current_id]
			if (current_reagent.taste)
				if (islist(current_reagent.taste))
					for (var/taste in current_reagent.taste)
						reag_list[taste] += current_reagent.volume
				else
					reag_list[current_reagent.taste] += current_reagent.volume
		// restrict number of tastes
		num_val = min(num_val, length(reag_list))
		// make empty lists for results
		var/list/result_name[num_val]
		var/list/result_amount[num_val]
		// go through all tastes
		for (var/current_taste in reag_list)
			// check if it is higher than one of our top values
			for (var/top_index in 1 to num_val)
				if (reag_list[current_taste] > result_amount[top_index])
					// move all the values down
					for (var/i = num_val; i >= (top_index+1); i--)
						result_name[i] = result_name[i-1]
						result_amount[i] = result_amount[i-1]
					// set new top value
					result_name[top_index] = current_taste
					result_amount[top_index] = reag_list[current_taste]
					break
		// create associative list for result
		. = list()
		for (var/i in 1 to num_val)
			.[result_name[i]] = result_amount[i]

	/// Gets a string of what something tastes like (as shown to the drinker/eater/whatever)
	proc/get_taste_string(mob/taster)
		if (taster.traitHolder.hasTrait("training_bartender"))
			var/reag_list = ""
			var/eth_eq = get_ethanol_equivalent(taster, src)
			for (var/current_id in src.reagent_list)
				var/datum/reagent/current_reagent = src.reagent_list[current_id]
				if (length(src.reagent_list) > 1 && src.reagent_list[src.reagent_list.len] == current_id)
					reag_list += " and [current_reagent.name]"
					continue
				reag_list += ", [current_reagent.name]"
			reag_list = copytext(reag_list, 3)
			. = "Tastes like there might be some [reag_list] in this. "
			if (eth_eq)
				. += "[SPAN_REGULAR("This should be about <b>[eth_eq / src.total_volume * 100]% ethanol by volume.</b> <br>")]"
		var/tastes = src.get_prevalent_tastes(3)
		switch (length(tastes))
			if (0)
				. += "Tastes pretty bland."
			if (1)
				. += "Tastes kind of [tastes[1]]."
			if (2)
				. += "Tastes kind of [tastes[1]] and [tastes[2]]."
			else
				. += "Tastes kind of [tastes[1]], [tastes[2]], and a little bit [tastes[3]]."

	/// returns whether reagents are solid, liquid, gas, or mixture
	proc/get_state_description()
		var/has_solid = 0
		var/has_liquid = 0
		var/has_gas = 0

		for(var/id in reagent_list)

			var/datum/reagent/current_reagent = reagent_list[id]
			if(current_reagent.is_gas())
				has_gas = 1
			else if(current_reagent.is_liquid())
				has_liquid = 1
			else
				has_solid = 1

		if( (has_liquid+has_solid+has_gas)>1 )
			return "mixture"
		if(has_liquid)
			return "liquid"
		if(has_solid)
			return "solid"
		return "gas"

	proc/physical_shock(var/force)
		for (var/id in reagent_list)
			var/datum/reagent/current_reagent = reagent_list[id]
			current_reagent.physical_shock(force)
		for (var/datum/chemical_reaction/reaction in active_reactions)
			reaction.physical_shock(force, src)

	proc/move_trigger(var/mob/M, kindof)
		var/shock = 0
		switch (kindof)
			if ("sprint")
				shock = rand(8, 16)
			if ("run")
				shock = rand(5, 12)
			if ("walk", "swap")
				if (prob(5))
					shock = 1
			if ("bump")
				shock = rand(3, 8)
			if ("pushdown")
				shock = rand(8, 16)
		if (shock)
			physical_shock(shock)

	// there were two different implementations, one of which didn't work, so i moved the working one here and both call it now - IM
	proc/smoke_start(var/volume, var/classic = 0)
		purge_smoke_blacklist(src)

		var/list/covered = covered_turf()

		var/turf/T = length(covered) ? covered[1] : 0
		var/mob/our_user = null
		var/our_fingerprints = null

		// Sadly, we don't automatically get a mob reference under most circumstances.
		// If there's an existing lookup proc and/or better solution, I haven't found it yet.
		// If everything else fails, maybe there are fingerprints on the container for us to check though?
		if (my_atom)
			if (ismob(my_atom)) // Our mob, the container.
				our_user = my_atom
			else if (my_atom && (ismob(my_atom.loc))) // Backpacks etc.
				our_user = my_atom.loc
			else
				our_user = usr
				if (my_atom.fingerprintslast) // Our container. You don't necessarily have to pick it up to transfer stuff.
					our_fingerprints = my_atom.fingerprintslast
				else if (my_atom.loc.fingerprintslast) // Backpacks etc.
					our_fingerprints = my_atom.loc.fingerprintslast

		//DEBUG_MESSAGE("Heat-triggered smoke powder reaction: our user is [our_user ? "[our_user]" : "*null*"].[our_fingerprints ? " Fingerprints: [our_fingerprints]" : ""]")
		if (our_user && ismob(our_user))
			logTheThing(LOG_CHEMISTRY, our_user, "Smoke reaction ([my_atom ? log_reagents(my_atom) : log_reagents(src)]) at [T ? "[log_loc(T)]" : "null"].")
			if(istype(src.my_atom, /obj/item/reagent_containers) && !locate(/obj/machinery/chem_dispenser) in get_turf(src.my_atom))
				message_admins("[key_name(our_user)] caused a smoke reaction [my_atom ? log_reagents(my_atom) : log_reagents(src)] at [T ? "[log_loc(T)]" : "null"].")
		else
			logTheThing(LOG_CHEMISTRY, our_user, "Smoke reaction ([my_atom ? log_reagents(my_atom) : log_reagents(src)]) at [T ? "[log_loc(T)]" : "null"].[our_fingerprints ? " Container last touched by: [our_fingerprints]." : ""]")
			if(our_fingerprints && istype(src.my_atom, /obj/item/reagent_containers) && !locate(/obj/machinery/chem_dispenser) in get_turf(src.my_atom))
				message_admins("Smoke reaction [my_atom ? log_reagents(my_atom) : log_reagents(src)] at [T ? "[log_loc(T)]" : "null"]. Container last touched by: [key_name(our_fingerprints)].")

		if (classic)
			classic_smoke_reaction(src, min(round(volume / 5), 4), location = my_atom ? get_turf(my_atom) : 0)
		else
			smoke_reaction(src, round(min(5, round(volume/10))), location = my_atom ? get_turf(my_atom) : 0)

	proc/is_airborne()
		return FALSE

///////////////////////////////////////////////////////////////////////////////////


/// Convenience proc to create a reagents holder for an atom
/// Max vol is maximum volume of holder
atom/proc/create_reagents(var/max_vol = 100)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
