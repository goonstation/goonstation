///////////////////
////Fluid Group////
///////////////////


/datum/reagents/fluid_group
	var/datum/fluid_group/my_group = null
	var/last_reaction_loc = 0
	var/skip_next_update = 0
	covered_turf()
		.= list()
		if (my_group)
			for (var/obj/fluid/F as anything in my_group.members)
				.+= F.loc

	clear_reagents()
		..()
		if (my_group)
			my_group.evaporate()

	//Handles reagent reduction -> shrinking puddle
	update_total()
		var/prev_volume = src.total_volume
		..()
		if (skip_next_update) //sometimes we need to change the total without automatically draining the removed amt.
			skip_next_update = 0
			return
		if (my_group)
			my_group.contained_amt = src.total_volume

			if (src.total_volume <= 0 && prev_volume > 0)
				my_group.evaporate()
				return

			if (my_group.amt_per_tile >= my_group.required_to_spread) return
			if ((src.total_volume >= prev_volume)) return

			var/member_dif = (round(src.total_volume / my_group.required_to_spread) - round(prev_volume / my_group.required_to_spread ))
			var/fluids_to_remove = 0
			if (member_dif < 0)
				fluids_to_remove = abs(member_dif)

			if (fluids_to_remove)
				var/obj/fluid/remove_source = my_group.last_reacted
				if (!remove_source)
					remove_source = my_group.spread_member
					if (!remove_source && length(my_group.members))
						remove_source = pick(my_group.members)
					if (!remove_source)
						my_group.evaporate()
						return
				skip_next_update = 1
				my_group.drain(remove_source, fluids_to_remove, remove_reagent = 0)

	get_reagents_fullness()
		. = null
		if (my_group)
			if (my_group.last_depth_level == 1)
				. = "very shallow"
			else if (my_group.last_depth_level == 2)
				. = "knee height"
			else if (my_group.last_depth_level == 3)
				. = "chest height"
			else if (my_group.last_depth_level == 4)
				. = "very deep"

	temperature_reagents(exposed_temperature, exposed_volume = 100, exposed_heat_capacity = 100, change_cap = 15, change_min = 0.0000001, loud = 0, cannot_be_cooled = FALSE)
		..()
		src.update_total()

	play_mix_sound(var/mix_sound) //play sound at random locs
		for (var/i = 0, i < length(my_group.members) / 20, i++)
			playsound(pick(my_group.members), mix_sound, 80, 1)
			if (i > 8) break

	get_state_description()
		if (istype(src.my_group, /datum/fluid_group/airborne))
			. = "vapor"
		else
			. = "fluid"

	is_airborne()
		return istype(src.my_group, /datum/fluid_group/airborne)

//We use datum/controller/process/fluid_group to do evaporation

/datum/fluid_group

	var/const/group_type = /datum/fluid_group
	//var/const/object_type = /obj/fluid

	var/base_evaporation_time = 1500
	var/bonus_evaporation_time = 9000 //Ranges from 0 to this value depending on average viscosity
	var/const/max_viscosity = 20

	var/const/max_alpha = 230

	var/list/members = list()
	var/obj/fluid/spread_member = 0 //Member that we want to spread from. Should be changed on add amt, displace, etc.
	var/updating = 0 //already updating? block another loop from being started


	var/datum/reagents/fluid_group/reagents = null
	var/contained_amt = 0 //total reagent amt including all members
	var/amt_per_tile = 0 //Don't pull from this value for group calculations without updating it first
	var/required_to_spread = 30

	var/last_add_time = 0
	var/last_temp_change = 0
	var/last_spread_member = 0
	var/last_contained_amt = -1
	var/last_members_amt = 0
	var/last_depth_level = 0
	var/avg_viscosity = 1
	var/last_update_time = 0
	var/obj/fluid/last_reacted = 0

	var/datum/color/average_color = 0
	var/master_reagent_id = 0

	var/can_update = 1 //flag is set to 0 temporarily when doing a split operation
	var/draining = 0
	var/queued_drains = 0 // how many tiles to drain on next update?
	var/turf/last_drain = 0 // tile from which we should try to drain from

	var/drains_floor = 1

	disposing()
		can_update = 0

		for (var/fluid in src.members)
			if(fluid)
				var/obj/fluid/M = fluid
				M.group = null

		//if (src in processing_fluid_groups)
		//	processing_fluid_groups.Remove(src)
		//if (src in processing_fluid_spreads)
		//	processing_fluid_spreads.Remove(src)

		processing_fluid_groups -= src
		processing_fluid_spreads -= src
		processing_fluid_drains -= src

		members.Cut()

		reagents.my_group = null
		reagents = null

		spread_member = 0
		updating = 0
		contained_amt = 0
		amt_per_tile = 0
		required_to_spread = initial(required_to_spread)
		last_add_time = world.time //fuck
		last_temp_change = 0
		last_contained_amt = 0
		avg_viscosity = 1
		last_update_time = 0
		last_members_amt = 0
		last_depth_level = 0
		last_reacted = 0
		draining = 0
		queued_drains = 0
		last_drain = 0
		master_reagent_id = 0
		drains_floor = 1
		..()

	New()
		..()
		src.last_add_time = world.time

		reagents = new /datum/reagents/fluid_group(90000000) //high number lol.
		reagents.my_group = src

		processing_fluid_groups |= src

	proc/update_amt_per_tile()
		contained_amt = src.reagents.total_volume
		amt_per_tile = length(members) ? contained_amt / length(members) : 0

	proc/evaporate()
		//boutput(world,"IM HITTING THE VAPE!!!!!!!!!!")
		if (last_add_time == 0) //this should nOT HAPPEN
			last_add_time = world.time
			return

		for (var/obj/fluid/F as anything in src.members)
			if (!F) continue
			if (F.disposed) continue
			src.remove(F,0,1,1)

		if (!src.disposed)
			qdel(src)

	proc/add(var/obj/fluid/F, var/gained_fluid = 0, var/do_update = 1, var/guarantee_is_member = 0)
		if (!F || src.disposed || !members) return

		if (gained_fluid)
			spread_member = F

		//if (!length(src.members)) //very first member! do special stuff	we should def. have defined before anything else can happen
		//	contained_amt = src.reagents.total_volume
		//	amt_per_tile = contained_amt

		if (!guarantee_is_member)
			if (!length(src.members) || !(F in members))
				members += F
				F.group = src

		if (length(src.members) == 1)
			F.UpdateIcon() //update icon of the very first fluid in this group

		src.last_add_time = world.time

		if (!do_update) return

		src.update_loop()

		// recalculate depth level based on fluid amount
		// to account for change to fluid until fluid_core
		// can perform spread
		update_amt_per_tile()
		var/my_depth_level = 0
		for(var/x in depth_levels)
			if (src.amt_per_tile > x)
				my_depth_level++
			else
				break

		if (F.last_depth_level != my_depth_level)
			F.last_depth_level = my_depth_level

	//fluid has been removed from its tile. use 'lightweight' in evaporation procedure cause we dont need icon updates / try split / update loop checks at that point
	// if 'lightweight' parameter is 2, invoke an update loop but still ignore icon updates
	proc/remove(var/obj/fluid/F, var/lost_fluid = 1, var/lightweight = 0, var/allow_zero = 0)
		if (!F || F.disposed || src.disposed) return 0
		if (!members || !length(src.members) || !(F in members)) return 0

		if (!lightweight)
			var/turf/t
			for( var/dir in cardinal )
				t = get_step( F, dir )
				if (t?.active_liquid)
					t.active_liquid.blocked_dirs = 0
					t.active_liquid.UpdateIcon(1)
		else
			var/turf/t
			for( var/dir in cardinal )
				t = get_step( F, dir )
				if (t?.active_liquid)
					t.active_liquid.blocked_dirs = 0

		if(src.disposed || F.disposed) return 0 // UpdateIcon lagchecks, rip

		amt_per_tile = length(members) ? contained_amt / length(members) : 0
		members -= F //remove after amt per tile ok? otherwise bad thing could happen
		if (lost_fluid)
			src.reagents.skip_next_update = 1
			src.reagents.remove_any(amt_per_tile)
			src.contained_amt = src.reagents.total_volume

		F.group = null
		var/turf/removed_loc = F.loc
		if(removed_loc)
			F.turf_remove_cleanup(F.loc)

		qdel(F)

		if (!lightweight || lightweight == 2)
			if (!src.try_split(removed_loc))
				src.update_loop()

		if ((!members || length(src.members) == 0) && !allow_zero)
			qdel(src)

		return 1

	/* identical to remove, except this proc returns the fluids removed
	 * vol_max sets upper limit for fluid volume to be removed */
	proc/suck(var/obj/fluid/F, var/vol_max, var/lost_fluid = 1, var/lightweight = 0, var/allow_zero = 1)
		if (!F || F.disposed) return 0
		if (!members || !length(src.members) || !(F in members)) return 0

		var/datum/reagents/R = null

		if (!lightweight)
			var/turf/t
			for( var/dir in cardinal )
				t = get_step( F, dir )
				if (t?.active_liquid)
					t.active_liquid.blocked_dirs = 0
					t.active_liquid.UpdateIcon(1)
		else
			var/turf/t
			for( var/dir in cardinal )
				t = get_step( F, dir )
				if (t?.active_liquid)
					t.active_liquid.blocked_dirs = 0

		amt_per_tile = length(members) ? contained_amt / length(members) : 0
		var/amt_to_remove = min(amt_per_tile, vol_max)

		if(amt_to_remove == amt_per_tile)
			members -= F //remove after amt per tile ok? otherwise bad thing could happen
			if (lost_fluid)
				src.reagents.skip_next_update = 1
				R = src.reagents.remove_any_to(amt_to_remove)
				src.contained_amt = src.reagents.total_volume

			F.group = null
			var/turf/removed_loc = F.loc
			if (removed_loc)
				F.turf_remove_cleanup(F.loc)
		else
			if (lost_fluid)
				src.reagents.skip_next_update = 1
				R = src.reagents.remove_any_to(amt_to_remove)
				src.contained_amt = src.reagents.total_volume
		qdel(F)

		/*if (!lightweight || lightweight == 2)
			if (!src.try_split(removed_loc))
				src.update_loop()*/

		if ((!members || length(src.members) == 0) && !allow_zero)
			qdel(src)

		return R

	proc/displace(var/obj/fluid/F) //fluid has been displaced from its tile - delete this object and try to move my contents to adjacent tiles
		if (!members || !F) return
		if (length(src.members) == 1)
			var/turf/T
			var/blocked
			for( var/dir in cardinal )
				T = get_step( F, dir )
				if (! (istype(T, /turf/simulated/floor) || istype (T, /turf/unsimulated/floor)) )
					blocked++
					continue
				if (T.Enter(src))
					if (T.active_liquid && T.active_liquid.group)
						T.active_liquid.group.join(src)
					else
						F.turf_remove_cleanup(F.loc)
						F.set_loc(T)
						T.active_liquid = F
					break
				else
					blocked++
			if(blocked == length(cardinal)) // failed
				src.remove(F,0,2)
		else
			var/turf/T
			for( var/dir in cardinal )
				T = get_step( F, dir )
				if (T.active_liquid && T.active_liquid.group == src)
					spread_member = T.active_liquid
					break
			src.remove(F,0,2)


	proc/displace_channel(var/spread_dir, var/obj/fluid/F, var/obj/channel/channel) // use this to fake height levels. Result can either block a spread or 'jump' the channel by carrying over some fluid
		if (!(channel && F)) return 0
		LAGCHECK(LAG_HIGH)
		var/turf/jump_turf = 0
		var/amt_per_tile_added = length(members) ? (contained_amt+1) / length(members) : 0

		if (amt_per_tile_added <= channel.required_to_pass && spread_dir != channel.dir)
			return 0
		else
			jump_turf = get_step( channel.loc, spread_dir )
			if (spread_dir == channel.dir)
				if (jump_turf.active_liquid && jump_turf.active_liquid.group)
					if (jump_turf.active_liquid.group.amt_per_tile > channel.required_to_pass) //don't flow back in if its 'full'
						return 0


		if (!istype(jump_turf)) return 0

		LAGCHECK(LAG_MED)
		var/loss = amt_per_tile_added - channel.required_to_pass
		if (jump_turf.active_liquid)
			if (!jump_turf.active_liquid.group)
				var/datum/reagents/R = new /datum/reagents(amt_per_tile_added)
				src.reagents.copy_to(R)
				jump_turf.fluid_react(R,amt_per_tile_added)
			else
				var/datum/reagents/R = new /datum/reagents(amt_per_tile_added)
				src.reagents.copy_to(R)
				jump_turf.fluid_react(R,amt_per_tile_added)
		else
			var/datum/reagents/R = new /datum/reagents(amt_per_tile_added)
			src.reagents.copy_to(R)
			jump_turf.fluid_react(R,amt_per_tile_added)

		src.reagents.skip_next_update = 1
		src.reagents.remove_any(loss)

		return 1

	proc/update_viscosity()
		var/avg = 0
		var/reagents = 0

		for(var/reagent_id in src.reagents.reagent_list)
			if (QDELETED(src.reagents)) return
			var/datum/reagent/current_reagent = src.reagents.reagent_list[reagent_id]

			if (isnull(current_reagent))
				continue

			avg += current_reagent.viscosity
			reagents++
			LAGCHECK(LAG_HIGH)

		if (reagents && avg)
			avg = avg / reagents
			src.avg_viscosity = 1 + (avg * max_viscosity)
		else
			src.avg_viscosity = 1

		src.avg_viscosity = min(src.avg_viscosity,max_viscosity)

	proc/add_drain_process()
		if (src.qdeled) return

		src.draining = 1
		processing_fluid_drains |= src

	proc/update_loop()
		if (src.qdeled) return

		src.updating = 1
		processing_fluid_spreads |= src

	proc/update_required_to_spread()
		return

	proc/update_once(force = 0) //this would be called every time the fluid.dm process procs.
		if (src.qdeled || !can_update) return 1
		if (!members || !length(src.members))
			src.evaporate()
			return 1

		var/fluids_to_create = 0 //try to create X amount of new tiles (based on how much fluid and tiles we currently hold)

		src.update_viscosity()
		src.update_required_to_spread()
		if (SPREAD_CHECK(src) || force)
			LAGCHECK(LAG_HIGH)
			if (src.qdeled) return 1
			src.updating = 1

			if (src.spread_member != src.last_spread_member)
				if (!src.spread_member)
					src.spread_member = pick(members)
					if (!src.spread_member)
						src.updating = 0
						return 1

				src.last_spread_member = src.spread_member

			fluids_to_create = (contained_amt/required_to_spread) - length(src.members)

			if (force)
				fluids_to_create = force

			var/created = src.spread(fluids_to_create)
			if (created && !src.qdeled)
				return

		LAGCHECK(LAG_HIGH)

		if (src.last_contained_amt == src.contained_amt && length(src.members) == src.last_members_amt && !force)
			src.updating = 0
			return 1

		amt_per_tile = length(members) ? contained_amt / length(members) : 0
		var/my_depth_level = 0
		for(var/x in depth_levels)
			if (amt_per_tile > x)
				my_depth_level++
			else
				break

		LAGCHECK(LAG_MED)
		if (src.qdeled) return 1

		var/datum/color/last_color = src.average_color
		src.average_color = src.reagents?.get_average_color()
		var/color_dif = 0
		if (!last_color)
			color_dif = 999
		else
			color_dif = abs(average_color.r - last_color.r) + abs(average_color.g - last_color.g) + abs(average_color.b - last_color.b)
		var/color_changed = (color_dif > 10)

		if (my_depth_level == last_depth_level && !color_changed && length(src.members) == src.last_members_amt) //saves cycles for stuff like an ocean flooding into a pretty-much-aready-filled room
			src.updating = 0
			return 1

		LAGCHECK(LAG_MED)
		if (src.qdeled) return 1

		var/targetalpha = max(25, (src.average_color.a / 255) * src.max_alpha)
		var/targetcolor = rgb(src.average_color.r, src.average_color.g, src.average_color.b)

		src.master_reagent_id = src.reagents?.get_master_reagent_id()

		var/master_opacity = !src.drains_floor && src.reagents?.get_master_reagent_gas_opaque()

		var/depth_changed = 0 //force icon update later in the proc if fluid member depth changed
		var/last_icon = 0

		for (var/obj/fluid/F as anything in src.members)
			LAGCHECK(LAG_HIGH)
			if (!F || F.disposed || src.qdeled) continue

			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//Set_amt gets called a lot. Let's reduce proc call overhead : by being stupid and pasting the whole thing in this fuckin loop ugh
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			F.amt = src.amt_per_tile

			if (F.touched_channel)
				src.displace_channel(get_dir(F,F.touched_channel), F, F.touched_channel)
				F.touched_channel = 0
				if (!F || F.disposed || src.qdeled) continue

			//We update objects manually here because they don't move. A mob that moves around will call HasEntered on its own, so let that case happen naturally

			depth_changed = 0
			if (F.last_depth_level != my_depth_level)
				F.last_depth_level = my_depth_level
				for(var/obj/O in F.loc)
					LAGCHECK(LAG_MED)
					if (O?.submerged_images)
						F.Crossed(O)

				depth_changed = 1

			if (my_depth_level)
				var/splash_level = clamp(my_depth_level, 1, 3)
				F.step_sound = "sound/misc/splash_[splash_level].ogg"

			F.movement_speed_mod = F.last_depth_level <= 1 ? 0 : (viscosity_SLOW_COMPONENT(F.avg_viscosity,F.max_viscosity,F.max_speed_mod) + DEPTH_SLOW_COMPONENT(F.amt,F.max_reagent_volume,F.max_speed_mod))

			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//end
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		fluid_ma.color = targetcolor
		fluid_ma.alpha = targetalpha

		for (var/obj/fluid/F as anything in src.members)
			if (!F || F.disposed || src.qdeled) continue
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//Same shit here with UpdateIcon
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			F.finalalpha = targetalpha
			F.finalcolor = targetcolor


			if (F.do_iconstate_updates)
				last_icon = F.icon_state

				if (F.last_spread_was_blocked || (src.amt_per_tile > src.required_to_spread))
					fluid_ma.icon_state = "15"
				else
					var/dirs = 0
					for (var/dir in cardinal)
						var/turf/simulated/T = get_step(F, dir)
						if (T && T.active_liquid && T.active_liquid.group == F.group)
							dirs |= dir
					fluid_ma.icon_state = num2text(dirs)

					if (F.overlay_refs && length(F.overlay_refs))
						if (F)
							F.ClearAllOverlays()

				if (((color_changed || last_icon != F.icon_state) && F.last_spread_was_blocked) || depth_changed)
					F.update_perspective_overlays()
			else
				fluid_ma.icon_state = "airborne" //HACKY! BAD! BAD! WARNING!

			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//end
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			//air specific (messy)
			fluid_ma.opacity = master_opacity
			fluid_ma.overlays = F.overlays // gross, needed because of perspective overlays
			F.appearance = fluid_ma
			F.name = initial(F.name) // i don't know what the fuck is going on with the appearances here

		if(src.disposed)
			return 1

		src.last_contained_amt = src.contained_amt
		src.last_members_amt = length(src.members)
		src.last_depth_level = my_depth_level

		src.updating = 0
		return 1

	proc/spread(var/fluids_to_create) //spread in respect to members
		.= 0 //return created fluids
		var/obj/fluid/F
		var/membercount = length(src.members)
		for (var/i = 1, i <= membercount, i++)
			LAGCHECK(LAG_HIGH)
			if (src.qdeled) return
			if (i > membercount) continue
			F = members[i]
			if (!F || F.group != src) continue //This can happen if a fluid is deleted/caught with its pants down during an update loop.

			if (F.blocked_dirs < 4) //skip that update if we were blocked (not an edge tile)
				amt_per_tile = contained_amt / (membercount + .)

				for (var/obj/fluid/C as anything in F.update())
					LAGCHECK(LAG_HIGH)
					if (!C || C.disposed || src.disposed) continue
					var/turf/T = C.loc
					if (istype(T) && drains_floor)
						T.react_all_cleanables() // bug here regarding fluids doing their whole spread immediately if they're in a patch of cleanables. can't figure it out and its not TERRIBLE, fix later!!!
					C.amt = src.amt_per_tile

					//copy blood stuff
					if (F.blood_DNA && !C.blood_DNA)
						C.blood_DNA = F.blood_DNA
					if (F.blood_type && !C.blood_type)
						C.blood_type = F.blood_type

					members |= C
					.++

				if ((membercount + .)<=0) //this can happen somehow
					continue

				amt_per_tile = contained_amt / (membercount + .)

			if (F.touched_other_group && src != F.touched_other_group)
				if (src.join(F.touched_other_group))
					F.touched_other_group = 0
					break
				F.touched_other_group = 0

			if (. >= fluids_to_create)
				break

	proc/drain(var/obj/fluid/drain_source, var/fluids_to_remove, var/atom/transfer_to = 0, var/remove_reagent = 1) //basically a reverse spread with drain_source as the center
		if (!drain_source || drain_source.group != src) return

		//Don't delete tiles if we can just drain existing deep fluid
		amt_per_tile = length(members) ? contained_amt / length(members) : 0

		if (amt_per_tile > required_to_spread)
			if (transfer_to && transfer_to.reagents && src.reagents)
				src.reagents.trans_to_direct(transfer_to.reagents,min(fluids_to_remove * amt_per_tile, src.reagents.total_volume))
				src.contained_amt = src.reagents.total_volume
			else if(remove_reagent)
				src.reagents.remove_any(fluids_to_remove * amt_per_tile)

			src.update_loop()
			return src.avg_viscosity

		if (length(members) && src.members[1] != drain_source)
			if (length(src.members) <= 30)
				var/list/L = drain_source.get_connected_fluids()
				if (length(L) == length(members))
					src.members = L.Copy()// this is a bit of an ouch, but drains need to be able to finish off smallish puddles properly

		var/list/fluids_removed = list()
		var/fluids_removed_avg_viscosity = 0

		for (var/i = length(members), i > 0, i--)
			if (src.qdeled) return
			if (i > length(src.members)) continue
			if (!members[i]) continue
			var/obj/fluid/F = members[i] // todo fix error
			if (!F || F.group != src) continue

			fluids_removed += F
			fluids_removed_avg_viscosity += F.avg_viscosity

			if (length(fluids_removed) >= fluids_to_remove)
				break

		var/removed_len = length(fluids_removed)

		if (transfer_to && transfer_to.reagents && src.reagents)
			src.reagents.skip_next_update = 1
			src.reagents.trans_to_direct(transfer_to.reagents,src.amt_per_tile * removed_len)
			src.contained_amt = src.reagents.total_volume
		else if (src.reagents && remove_reagent)
			src.reagents.skip_next_update = 1
			src.reagents.remove_any(src.amt_per_tile * removed_len)
			src.contained_amt = src.reagents.total_volume

		for (var/obj/fluid/F as anything in fluids_removed)
			src.remove(F,0,src.updating)

		//fluids_removed_avg_viscosity = fluids_removed ? (fluids_removed_avg_viscosity / fluids_removed) : 1
		return src.avg_viscosity

	proc/join(var/datum/fluid_group/join_with) //join a fluid group into this one
		if (src == join_with || src.qdeled || !join_with || join_with.qdeled)
			return 0

		join_with.qdeled = 1 //hacky but stop updating

		for (var/obj/fluid/F as anything in join_with.members)
			if (!F) continue
			F.group = src
			src.members += F
			join_with.members -= F

		join_with.reagents.copy_to(src.reagents)

		join_with.evaporate()
		join_with = 0

		src.update_loop() //just in case one wasn't running already
		//src.last_add_time = world.time
		amt_per_tile = length(members) ? contained_amt / length(members) : 0
		return 1

	proc/try_split(var/turf/removed_loc) //called when a fluid is removed. check if the removal causes a split, and proceed from there.
		if (!removed_loc || src.qdeled) return 0
		var/list/connected = 0

		var/turf/T = 0
		var/obj/fluid/split_liq = 0
		var/removal_key = "[world.time]_[removed_loc.x]_[removed_loc.y]"
		var/adjacent_amt = -1
		for( var/dir in cardinal )
			T = get_step( removed_loc, dir )
			if (T && T.active_liquid && T.active_liquid.group == src)
				T.active_liquid.temp_removal_key = removal_key
				adjacent_amt++
				split_liq = T.active_liquid

		if (split_liq && adjacent_amt > 0) //(adjacent_amt > 0) means that we won't even try searching if the removal point is only connected to 1 fluid (could not possibly be a split)
			//pass in adjacent_amt: get_connected will check the removal_key of each fluid, which will trigger an early abort if we determine no split is necessary
			connected = split_liq.get_connected_fluids(adjacent_amt)

		if (!connected || length(connected) == length(src.members))
			return 0

		if (!removed_loc || src.qdeled || !src.reagents || !src.reagents.total_volume) //trying to stop the weird bug were a bunch of simultaneous splits removes all reagents
			return 0
		contained_amt = src.reagents.total_volume
		connected += split_liq //include the actual splitting liquid object we're looking at
		//remove some of contained_amt from src and add it to FG
		src.can_update = 0
		amt_per_tile = length(members) ? contained_amt / length(members) : 0
		var/datum/fluid_group/FG = new group_type
		FG.can_update = 0
		//add members to FG, remove them from src
		for (var/obj/fluid/F as anything in connected)
			if (!FG) return 0
			FG.members += F
			F.group = FG
			F.last_spread_was_blocked = 0
		src.members -= FG.members

		if (FG)
			src.reagents.skip_next_update = 1
			src.reagents.trans_to_direct(FG.reagents, amt_per_tile * connected.len)
			src.contained_amt = src.reagents.total_volume

			FG.can_update = 1
			FG.last_contained_amt = 0
			FG.last_members_amt = 0
			if (length(FG.members))
				FG.last_spread_member = FG.members[1]
			FG.update_loop()

		src.can_update = 1
		src.last_contained_amt = 0
		src.last_members_amt = 0
		src.update_loop()

		//src.last_add_time = world.time

		return 1
