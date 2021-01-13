
/turf/var/obj/fluid/active_airborne_liquid = null

var/list/ban_from_airborne_fluid = list()

/datum/fluid_group/airborne

	base_evaporation_time = 30 SECONDS
	bonus_evaporation_time = 30 SECONDS

	//max_alpha = 200

	required_to_spread = 5

	drains_floor = 0

	update_required_to_spread()
		required_to_spread = min(15, max(0.25+src.reagents.get_smoke_spread_mod(), (src.contained_amt**0.8)/40)+0.65) //wowowow magic numbers

//What follows is not for the faint of heart.
// I have done a shitton of copy paste from the base obj/fluid type.
// This is messy as fuck, but its the fastest solution i could think of CPU wise

/obj/fluid/airborne
	name = "cloud"
	desc = "It's a free-flowing airborne state of matter!"
	icon_state = "airborne"
	do_iconstate_updates = 0
	mouse_opacity = 1
	opacity = 0
	layer = FLUID_AIR_LAYER

	set_up(var/newloc, var/do_enters = 1)
		if (is_setup) return
		if (!newloc) return

		is_setup = 1
		if(!isturf(newloc) || !waterflow_enabled)
			src.removed()
			return

		set_loc(newloc)
		src.loc = newloc
		src.loc:active_airborne_liquid = src //the dreaded :

	done_init()
		var/i = 0
		for(var/atom/A in range(0,src))
			if (src.pooled) return
			//var/atom/A = atom
			src.HasEntered(A,A.loc)
			i++
			if (i > 40)
				break
			LAGCHECK(LAG_MED)

	pooled()
		src.pooled = 1

		//this is slow, hopefully we can do without
		//if (src.group)
			//if (src in src.group.members)
			//	src.group.members -= src

		src.group = 0
		opacity = 0

		if (isturf(src.loc))
			src.loc:active_airborne_liquid = null

		name = "cloud"
		icon_state = "airborne"

		finalcolor = "#ffffff"
		finalalpha = 100
		alpha = 255
		color = "#ffffff"
		amt = 0
		avg_viscosity = initial(avg_viscosity)
		movement_speed_mod = 0
		group = 0
		touched_other_group = 0
		//float_anim = 0
		step_sound = 0
		last_spread_was_blocked = 0
		last_depth_level = 0
		touched_channel = 0
		is_setup = 0
		blocked_dirs = 0
		blocked_perspective_objects["[dir]"] = 0
		my_depth_level = 0
		..()

	unpooled()
		if (isturf(src.loc))
			var/turf/T = src.loc
			T.active_airborne_liquid = null
		..()

		src.step_sound = 0

	//ALTERNATIVE to force ingest in life
	proc/just_do_the_apply_thing(var/mob/M, var/mult = 1, var/hasmask = 0)
		if (!M) return
		if (!src.group || !src.group.reagents || !src.group.reagents.reagent_list || src.group.waitforit) return

		var/react_volume = src.amt > 10 ? (src.amt-10) / 3 + 10 : (src.amt)
		react_volume = min(react_volume,20) * mult
		if (M.reagents)
			react_volume = min(react_volume, abs(M.reagents.maximum_volume - M.reagents.total_volume)) //don't push out other reagents if we are full

		var/turf/T = get_turf(src)
		var/list/plist = list()
		plist["dmg_multiplier"] = 0.08
		if (T) //average that shit with the air temp
			var/turftemp = T.temperature
			plist["override_can_burn"] = (src.group.reagents.total_temperature + turftemp + turftemp) / 3

		src.group.reagents.reaction(M, TOUCH, react_volume/2, 0, paramslist = plist)

		if (!hasmask)
			src.group.reagents.reaction(M, INGEST, react_volume/2,1,src.group.members.len, paramslist = plist)
			src.group.reagents.trans_to(M, react_volume)

	force_mob_to_ingest(var/mob/M, var/mult = 1)//called when mob is drowning/standing in the smoke
		if (!M) return
		if (!src.group || !src.group.reagents || !src.group.reagents.reagent_list || src.group.waitforit) return

		var/react_volume = src.amt > 10 ? (src.amt-10) / 3 + 10 : (src.amt)
		react_volume = min(react_volume,20) * mult
		if (M.reagents)
			react_volume = min(react_volume, abs(M.reagents.maximum_volume - M.reagents.total_volume)) //don't push out other reagents if we are full

		var/turf/T = get_turf(src)
		var/list/plist = list()
		plist["dmg_multiplier"] = 0.08
		if (T) //average that shit with the air temp
			var/turftemp = T.temperature
			plist["override_can_burn"] = (src.group.reagents.total_temperature + turftemp + turftemp) / 3

		src.group.reagents.reaction(M, TOUCH, react_volume/2, 0, paramslist = plist)
		src.group.reagents.reaction(M, INGEST, react_volume/2,1,src.group.members.len, paramslist = plist)
		src.group.reagents.trans_to(M, react_volume)

	//incorporate touch_modifier?
	HasEntered(atom/A, atom/oldloc)
		if (!src.group || !src.group.reagents || src.pooled || istype(A,/obj/fluid))
			return

		A.EnteredAirborneFluid(src,oldloc)

	HasExited(atom/movable/AM, atom/newloc)
		return
		//if (AM.event_handler_flags & USE_FLUID_ENTER)
		//	AM.ExitedFluid(src,newloc)


	add_tracked_blood(atom/movable/AM as mob|obj)
		.=0

	update() //returns list of created fluid tiles
		if (!src.group) return
		.= list()
		last_spread_was_blocked = 1
		src.touched_channel = 0
		blocked_dirs = 0
		spawned_any = 0

		var/turf/t
		if(!waterflow_enabled) return
		for( var/dir in cardinal )
			LAGCHECK(LAG_LOW)
			if (!src.group)
				src.removed()
				return
			blocked_perspective_objects["[dir]"] = 0
			t = get_step( src, dir )
			if (!t) //the fuck? how
				continue
			if (!IS_VALID_FLUID_TURF(t))
				blocked_dirs++
				if (IS_PERSPECTIVE_WALL(t))
					blocked_perspective_objects["[dir]"] = 1
				continue
			if (t.active_airborne_liquid && !t.active_airborne_liquid.pooled)
				blocked_dirs++
				if (t.active_airborne_liquid.group && t.active_airborne_liquid.group != src.group)
					touched_other_group = t.active_airborne_liquid.group
					t.active_airborne_liquid.icon_state = "airborne"
				continue

			if(! t.density )
				var/suc = 1
				var/push_thing = 0
				for(var/obj/thing in t.contents) //HEY maybe do item pushing here since you're looping thru turf contents anyway??
					LAGCHECK(LAG_MED)
					var/found = 0
					if (IS_SOLID_TO_FLUID(thing))
						found = 1
					else if (!push_thing && !thing.anchored)
						push_thing = thing
					/*
					for(var/type_string in solid_to_fluid)
						if (istype(thing,text2path(type_string)))
							found = 1
							break
					*/
					if (found)
						if( thing.density )
							suc=0
							blocked_dirs++
							if (IS_PERSPECTIVE_BLOCK(thing))
							//for(var/type_string in perspective_blocks)
							//	if (istype(thing,text2path(type_string)))
								blocked_perspective_objects["[dir]"] = 1
							break

						if (istype(thing,/obj/channel))
							src.touched_channel = thing //Save this for later, we can't make use of it yet
							suc=0
							break

				if(suc && src.group) //group went missing? ok im doin a check here lol
					LAGCHECK(LAG_MED)
					spawned_any = 1
					src.icon_state = "airborne"
					var/obj/fluid/F = unpool(/obj/fluid/airborne)
					F.set_up(t,0)
					if (!F || !src.group) continue //set_up may decide to remove F

					F.amt = src.group.amt_per_tile
					F.name = src.name
					F.color = src.finalcolor
					F.finalcolor = src.finalcolor
					F.alpha = src.finalalpha
					F.finalalpha = src.finalalpha
					F.avg_viscosity = src.avg_viscosity
					F.last_depth_level = src.last_depth_level
					F.step_sound = src.step_sound
					F.movement_speed_mod = src.movement_speed_mod

					if (src.group)
						F.group = src.group
						. += F
					else
						var/datum/fluid_group/FG = new
						FG.add(F, src.group.amt_per_tile)
						F.group = FG

					F.done_init()
					last_spread_was_blocked = 0

					if (push_thing && prob(50))
						if (src.last_depth_level <= 3)
							if (isitem(push_thing))
								var/obj/item/I = push_thing
								if (I.w_class <= src.last_depth_level)
									step_away(I,src)
						else
							step_away(push_thing,src)

		if (spawned_any && prob(40))
			playsound( src.loc, 'sound/effects/smoke_tile_spread.ogg', 30,1,7)


	//kind of like a breadth-first search
	//return all fluids connected to src
	//If adjacent_match_quit > 0 , check fluids for a temp_removal_key that matches our own. Subtract 1 when we do find one. If adjacent_match_quit reaches 0, abort the search.
	//																															(Used to early detect when a split fails)
	get_connected_fluids(var/adjacent_match_quit = 0)
		.= list()
		if (!src.group) return list(src)

		var/list/queue = list(src)
		var/list/visited = list()
		var/turf/t

		var/obj/fluid/current_fluid = 0
		var/visited_changed = 0
		while(queue.len)
			LAGCHECK(LAG_MED)
			current_fluid = queue[1]
			queue.Cut(1, 2)

			for( var/dir in cardinal )
				LAGCHECK(LAG_MED)
				t = get_step( current_fluid, dir )
				if (!VALID_FLUID_CONNECTION(current_fluid, t)) continue
				if (!t.active_airborne_liquid.group)
					t.active_airborne_liquid.removed()
					continue

				LAGCHECK(LAG_MED)

				//Old method : search through 'visited' for 't.active_airborne_liquid'. Probably slow when you have big groups!!
				//if(t.active_airborne_liquid in visited) continue
				//visited += t.active_airborne_liquid

				//New method : Add the liquid at a specific index. To check whether the node has already been visited, just compare the len of the visited group from before + after the index has been set.
				//Probably slower for small groups and much faster for large groups.
				visited_changed = visited.len
				visited["[t.active_airborne_liquid.x]_[t.active_airborne_liquid.y]_[t.active_airborne_liquid.z]"] = t.active_airborne_liquid
				visited_changed = (visited.len != visited_changed)

				if (visited_changed)
					queue += t.active_airborne_liquid
					.+= t.active_airborne_liquid

					if (adjacent_match_quit)
						if (src.temp_removal_key && src != t.active_airborne_liquid && src.temp_removal_key == t.active_airborne_liquid.temp_removal_key)
							adjacent_match_quit--
							if (adjacent_match_quit <= 0)
								return 0 //bud nippin

			LAGCHECK(LAG_MED)

	try_connect_to_adjacent()
		var/turf/t
		for( var/dir in cardinal )
			t = get_step( src, dir )
			if( !t ) continue
			if (!t.active_airborne_liquid || t.active_airborne_liquid.pooled) continue
			if (t.active_airborne_liquid && t.active_airborne_liquid.group && src.group != t.active_airborne_liquid.group)
				t.active_airborne_liquid.group.join(src.group)
			LAGCHECK(LAG_MED)


	update_icon(var/neighbor_was_removed = 0)  //BE WARNED THIS PROC HAS A REPLICA UP ABOVE IN FLUID GROUP UPDATE_LOOP. DO NOT CHANGE THIS ONE WITHOUT MAKING THE SAME CHANGES UP THERE OH GOD I HATE THIS
		LAGCHECK(LAG_LOW)
		if (!src.group || !src.group.reagents) return

		src.name = src.group.master_reagent_name ? src.group.master_reagent_name : src.group.reagents.get_master_reagent_name() //maybe obscure later?

		var/datum/color/average = src.group.average_color ? src.group.average_color : src.group.reagents.get_average_color()
		src.finalalpha = max(25, (average.a / 255) * src.group.max_alpha)
		src.finalcolor = rgb(average.r, average.g, average.b)

		animate( src, color = finalcolor, alpha = finalalpha, time = 5 )

		LAGCHECK(LAG_LOW)

		if (neighbor_was_removed)
			last_spread_was_blocked = 0

		//air specific:
		var/old_opacity = src.opacity
		src.opacity = group.reagents.get_master_reagent_gas_opaque()
		if(src.opacity != old_opacity)
			var/turf/L = src.loc
			if(istype(L)) L.opaque_atom_count += src.opacity ? 1 : -1

	update_perspective_overlays() // fancy perspective overlaying
		.= 0

	display_overlay(var/overlay_key, var/pox, var/poy)
		.= 0

	clear_overlay(var/key = 0)
		.= 0



/atom/EnteredAirborneFluid(obj/fluid/F as obj)
	F.group.reagents.reaction(src, TOUCH, 0, 0)

/obj/particle/EnteredAirborneFluid(obj/fluid/F as obj)
	.=0
/obj/overlay/EnteredAirborneFluid(obj/fluid/F as obj)
	.=0
/obj/effects/EnteredAirborneFluid(obj/fluid/F as obj)
	.=0

/mob/EnteredAirborneFluid(obj/fluid/airborne/F as obj, atom/oldloc)
	.=0
	var/entered_group = 1 //Did the entering atom cross from a non-fluid to a fluid tile?

	var/turf/T = get_turf(oldloc)
	var/turf/currentloc = get_turf(src)
	if (currentloc != T && T?.active_airborne_liquid)
		entered_group = 0

	if (entered_group)
		F.just_do_the_apply_thing(src)

/mob/living/carbon/human/EnteredAirborneFluid(obj/fluid/airborne/F as obj, atom/oldloc)
	.=0
	var/entered_group = 1 //Did the entering atom cross from a non-fluid to a fluid tile?

	var/turf/T = get_turf(oldloc)
	var/turf/currentloc = get_turf(src)
	if (currentloc != T && T?.active_airborne_liquid)
		entered_group = 0

	if (entered_group)
		if (!src.clothing_protects_from_chems())
			F.just_do_the_apply_thing(src, hasmask = issmokeimmune(src))

/mob/living/silicon/EnteredAirborneFluid(obj/fluid/airborne/F as obj, atom/oldloc)
	.=0

/obj/fluid/airborne/EnteredAirborneFluid(obj/fluid/F as obj)
	.=0

///mob/EnteredAirborneFluid(obj/fluid/F as obj, atom/oldloc)
//	.=0

