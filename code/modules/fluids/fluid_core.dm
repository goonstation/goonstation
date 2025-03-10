///////////////////
////Fluid Object///
///////////////////

var/global/waterflow_enabled = 1

var/list/depth_levels = list(2,50,100,200)

var/mutable_appearance/fluid_ma

ADMIN_INTERACT_PROCS(/obj/fluid, proc/admin_clear_fluid)

/obj/fluid
	name = "fluid"
	desc = "It's a free-flowing liquid state of matter!"
	icon = 'icons/obj/fluid.dmi'
	icon_state = "15"
	anchored = ANCHORED_ALWAYS
	mouse_opacity = FALSE
	layer = FLUID_LAYER
	flags = UNCRUSHABLE | OPENCONTAINER

	event_handler_flags = IMMUNE_MANTA_PUSH

	var/finalcolor = "#ffffff"
	color = "#ffffff"
	var/finalalpha = 100
	alpha = 255

	var/const/max_slip_volume = 30
	var/const/max_slip_viscosity = 10

	var/const/max_reagent_volume = 300

	var/amt = 0 //amount of reagents contained - should be updated mainly by the group.

	var/const/max_viscosity = 20
	var/avg_viscosity = 1

	var/const/max_speed_mod = 3 //max. slowdown we can experience per slowdown type
	var/const/max_speed_mod_total = 5 //highest movement_speed_mod allowed
	var/movement_speed_mod = 0 //scales with viscosity + depth

	//Amt req to push an item as we spread
	var/const/push_tiny_req = 1
	var/const/push_small_req = 10
	var/const/push_med_req = 25
	var/const/push_large_req = 50

	var/datum/fluid_group/group = 0
	var/obj/fluid/touched_other_group = 0

	//var/float_anim = 0
	var/step_sound = 0

	var/last_spread_was_blocked = 0
	var/last_depth_level = 0
	var/touched_channel = 0

	var/list/wall_overlay_images = 0 //overlay bits onto a wall to make the water look deep. This is a cache of those overlays.
	//var/list/floated_atoms = 0 //list of atoms we triggered a float anim on (cleanup later on qdel())

	var/is_setup = 0
	var/blocked_dirs = 0 //amount of cardinal directions that i was blocked by in last update(). Cache this to skip updates on 'inner' fluid tiles of a group

	var/list/blocked_perspective_objects = list() //on our last spread, which directions were blocked by perspective OBJECTSs? (This saves us from doing a dumb loop to check all neighboring turfs)

	//temp_removal_key : this one is dumb... When a potential split happens, all adjacent fluid tiles to the split tile will be flagged with the same key.
	//get_connected(), if it encounters all these adjacent fluid tiles, will end early so we don't waste processing time searching through a group we are 100% sure did not split.
	// This key is used so we don't need to do a (more expensive) list search each get_connected loop iteration.
	var/temp_removal_key = 0

	var/my_depth_level = 0

	var/do_iconstate_updates = 1

	New(var/atom/location = null)
		..(location)
		if(location) //unpool starts this thing without a loc. if none is defined, don't immediate delete
			if (!waterflow_enabled)
				src.removed()
				return

		for (var/dir in cardinal)
			blocked_perspective_objects["[dir]"] = 0

		if (!fluid_ma)
			fluid_ma = new(src)


	proc/set_up(var/newloc, var/do_enters = 1)
		if (is_setup) return
		if (!newloc) return

		is_setup = 1
		if(!isturf(newloc) || !waterflow_enabled)
			src.removed()
			return

		set_loc(newloc)
		src.loc = newloc
		src.loc:active_liquid = src//the dreaded :

	proc/done_init()
		.=0
		//maybe slow, it was broke in the first place so lets just comment it out
		//for(var/mob/M in src.loc)
		//	if (src.disposed) return
		//	src.HasEntered(M,M.loc)
		//	LAGCHECK(LAG_MED)

		/*
		for(var/obj/O in src.loc)
			LAGCHECK(LAG_MED)
			if (src.disposed) return
			if (O.submerged_images)
				src.HasEntered(O,O.loc)
		*/

	proc/trigger_fluid_enter()
		for(var/atom/A in src.loc)
			if (src.group && !src.group.disposed && A.event_handler_flags & USE_FLUID_ENTER)
				A.EnteredFluid(src, src.loc)
		if(src.group && !src.group.disposed)
			src.loc?.EnteredFluid(src, src.loc)

	proc/turf_remove_cleanup(turf/the_turf)
		the_turf.active_liquid = null

	disposing()
		if (src.group && !src.group.disposed && src.group.members)
			src.group.members -= src

		src.group = null

		/*for (var/atom/A in src.floated_atoms) // ehh i dont like doing this, but I think we need it.
			if (!A) continue
			animate(A)
			A.pixel_y = initial(A.pixel_y)
		src.floated_atoms.len = 0*/

		if (isturf(src.loc))
			src.turf_remove_cleanup(src.loc)

		fluid_ma.icon_state = "15"
		fluid_ma.alpha = 255
		fluid_ma.color = "#ffffff"
		fluid_ma.overlays = null
		src.appearance = fluid_ma
		src.overlay_refs = null // setting appearance removes our overlays!

		finalcolor = "#ffffff"
		finalalpha = 100
		amt = 0
		avg_viscosity = initial(avg_viscosity)
		movement_speed_mod = 0
		group = null
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

	get_desc(dist, mob/user)
		if (dist > 4)
			return
		if (!src.group || !src.group.reagents)
			return
		. += "<br><b class='notice'>[capitalize(src.name)] analysis:</b>"
		. += "<br>[SPAN_NOTICE("[src.group.reagents.get_description(user,(RC_VISIBLE | RC_SPECTRO))]")]"

	admin_visible_name()
		return "[src.name] \[[src.group.reagents.get_master_reagent_name()]\]"

	attack_hand(mob/user)
		CRASH("[identify_object(user)] hit a fluid with their hand somehow. They shouldn't be able to do that.")

	attackby(obj/item/W, mob/user)
		CRASH("[identify_object(user)] hit a fluid with [identify_object(W)] somehow. They shouldn't be able to do that.")

	proc/add_reagents(var/datum/reagents/R, var/volume) //should be called right after new() on inital group creation
		if (!src.group) return
		R.trans_to(src.group.reagents,volume)

	proc/add_reagent(var/reagent_name, var/volume) //should be called right after new() on inital group creation
		if (!src.group) return
		src.group.reagents.add_reagent(reagent_name,volume)

	//incorporate touch_modifier?
	Crossed(atom/movable/A)
		..()
		if (!src.group || !src.group.reagents || src.disposed || istype(A,/obj/fluid)  || src.group.disposed || istype(src, /obj/fluid/airborne))
			return

		my_depth_level = last_depth_level

		/*if (src.float_anim)
			if (istype(A, /atom/movable) && !isobserver(A) && !istype(A, /mob/living/critter/small_animal/bee) && !istype(A, /obj/critter/domestic_bee))
				var/atom/movable/AM = A
				if (!AM.anchored)
					animate_bumble(AM, floatspeed = 8, Y1 = 3, Y2 = 0)
					src.floated_atoms += AM*/

		if (A.event_handler_flags & USE_FLUID_ENTER)
			A.EnteredFluid(src, A.last_turf)

	proc/force_mob_to_ingest(var/mob/M, var/mult = 1, var/list/exceptions = null)//called when mob is drowning
		if (!M) return
		if (!src.group || !src.group.reagents || !src.group.reagents.reagent_list) return

		var/react_volume = src.amt > 10 ? (src.amt / 2) : (src.amt)
		react_volume = min(react_volume,20) * mult
		if (M.reagents)
			react_volume = min(react_volume, abs(M.reagents.maximum_volume - M.reagents.total_volume)) //don't push out other reagents if we are full
		src.group.reagents.reaction(M, INGEST, react_volume,1,src.group.members.len)
		src.group.reagents.trans_to(M, react_volume, exceptions = exceptions)

	Uncrossed(atom/movable/AM)

		/*var/cancel_float = 0
		if (AM.loc == newloc)
			cancel_float = 1*/

		..()


		/*if (src.float_anim && isturf(newloc))
			var/turf/T = newloc
			if (!T.active_liquid || (T.active_liquid && T.active_liquid.amt < depth_levels[depth_levels.len-1]))
				cancel_float = 1
		else
			cancel_float = 1

		if (src.float_anim && cancel_float)
			if (istype(AM, /atom/movable) && !isobserver(AM) && !istype(AM, /mob/living/critter/small_animal/bee) && !istype(AM, /obj/critter/domestic_bee))
				animate(AM)
				AM.pixel_y = initial(AM.pixel_y)
				floated_atoms -= AM*/

		if ((AM.event_handler_flags & USE_FLUID_ENTER) && !istype(src, /obj/fluid/airborne))
			AM.ExitedFluid(src)


	proc/add_tracked_blood(atom/movable/AM as mob|obj)
		AM.tracked_blood = list("bDNA" = src.blood_DNA, "btype" = src.blood_type, "color" = src.color, "count" = rand(2,6), "sample_reagent" = src.group?.master_reagent_id)
		if (ismob(AM))
			var/mob/M = AM
			M.set_clothing_icon_dirty()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
		..()
		if (!src.group || !src.group.reagents || !length(src.group.members)) return
		src.group.last_temp_change = world.time
		//reduce exposed temperature by amt of members in the group
		src.group.reagents.temperature_reagents(exposed_temperature, exposed_volume, 100, 15, 1)

	ex_act()
		src.removed()

	proc/removed(var/sfx = 0)
		if (src.disposed) return

		if (sfx)
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

		if (src.group)
			if (!src.group.remove(src))
				qdel(src)
		else
			qdel(src)

		for(var/atom/A as anything in src.loc)
			if (A && A.flags & FLUID_SUBMERGE)
				var/mob/living/M = A
				var/obj/O = A
				if (istype(M))
					src.Uncrossed(M)
					M.show_submerged_image(0)
				else if (istype(O))
					if (O.submerged_images)
						src.Uncrossed(O)
						if ((O.submerged_images && length(O.submerged_images)) && (O.is_submerged != 0))
							O.show_submerged_image(0)

	var/spawned_any = 0
	proc/update() //returns list of created fluid tiles
		if (!src.group || src.group.disposed) //uh oh
			src.removed()
			return
		.= list()
		last_spread_was_blocked = 1
		src.touched_channel = 0
		blocked_dirs = 0
		spawned_any = 0

		var/turf/t
		if(!waterflow_enabled) return
		for( var/dir in cardinal )
			blocked_perspective_objects["[dir]"] = 0
			t = get_step( src, dir )
			if (!t) //the fuck? how
				continue
			if (!IS_VALID_FLUID_TURF(t))
				blocked_dirs++
				if (IS_PERSPECTIVE_WALL(t))
					blocked_perspective_objects["[dir]"] = 1
				continue
			if (t.active_liquid && !t.active_liquid.disposed)
				blocked_dirs++
				if (t.active_liquid.group && t.active_liquid.group != src.group)
					touched_other_group = t.active_liquid.group
					t.active_liquid.icon_state = "15"
				continue

			if(! t.density )
				var/suc = 1
				var/push_thing = 0
				for(var/obj/thing in t.contents)
					var/found = 0
					if (IS_SOLID_TO_FLUID(thing))
						found = 1
					else if (!push_thing && !thing.anchored)
						push_thing = thing

					if (found)
						if( thing.density || (thing.flags & FLUID_DENSE_ALWAYS) )
							suc=0
							blocked_dirs++
							if (IS_PERSPECTIVE_BLOCK(thing))
								blocked_perspective_objects["[dir]"] = 1
							break

						if (istype(thing,/obj/channel))
							src.touched_channel = thing //Save this for later, we can't make use of it yet
							suc=0
							break

				if(suc && src.group && !src.group.disposed) //group went missing? ok im doin a check here lol
					spawned_any = 1
					src.icon_state = "15"
					var/obj/fluid/F = new /obj/fluid
					F.set_up(t,0)
					if (!F || !src.group || src.group.disposed) continue //set_up may decide to remove F

					F.amt = src.group.amt_per_tile
					F.color = src.finalcolor
					F.finalcolor = src.finalcolor
					F.alpha = src.finalalpha
					F.finalalpha = src.finalalpha
					F.avg_viscosity = src.avg_viscosity
					F.last_depth_level = src.last_depth_level
					F.my_depth_level = src.last_depth_level
					F.step_sound = src.step_sound
					F.movement_speed_mod = src.movement_speed_mod

					if (src.group)
						src.group.add(F, src.group.amt_per_tile)
						F.group = src.group
					else
						var/datum/fluid_group/FG = new
						FG.add(F, src.group.amt_per_tile)
						F.group = FG
					. += F

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

					F.trigger_fluid_enter()

		if (spawned_any && prob(40))
			playsound( src.loc, 'sound/misc/waterflow.ogg', 30,0.7,7)


	//kind of like a breadth-first search
	//return all fluids connected to src
	//If adjacent_match_quit > 0 , check fluids for a temp_removal_key that matches our own. Subtract 1 when we do find one. If adjacent_match_quit reaches 0, abort the search.
	//																															(Used to early detect when a split fails)
	proc/get_connected_fluids(var/adjacent_match_quit = 0)
		.= list()
		if (!src.group) return list(src)

		var/list/queue = list(src)
		var/list/visited = list()
		var/turf/t

		var/obj/fluid/current_fluid = 0
		var/visited_changed = 0
		while(queue.len)
			current_fluid = queue[1]
			queue.Cut(1, 2)

			for( var/dir in cardinal )
				t = get_step( current_fluid, dir )
				if (!VALID_FLUID_CONNECTION(current_fluid, t)) continue
				if (!t.active_liquid.group)
					t.active_liquid.removed()
					continue

				//Old method : search through 'visited' for 't.active_liquid'. Probably slow when you have big groups!!
				//if(t.active_liquid in visited) continue
				//visited += t.active_liquid

				//New method : Add the liquid at a specific index. To check whether the node has already been visited, just compare the len of the visited group from before + after the index has been set.
				//Probably slower for small groups and much faster for large groups.
				visited_changed = length(visited)
				visited["[t.active_liquid.x]_[t.active_liquid.y]_[t.active_liquid.z]"] = t.active_liquid
				visited_changed = (visited.len != visited_changed)

				if (visited_changed)
					queue += t.active_liquid
					.+= t.active_liquid

					if (adjacent_match_quit)
						if (src.temp_removal_key && src != t.active_liquid && src.temp_removal_key == t.active_liquid.temp_removal_key)
							adjacent_match_quit--
							if (adjacent_match_quit <= 0)
								return 0 //bud nippin

	//sorry for copy paste, this ones a bit diff. return turfs of members nearby, stop at a number
	proc/get_connected_fluid_members(var/stop_at = 0)
		.= list()
		if (!src.group) return list(src)

		var/list/queue = list(src)
		var/list/visited = list()
		var/turf/t

		var/obj/fluid/current_fluid = 0
		var/visited_changed = 0
		while(queue.len)
			current_fluid = queue[1]
			queue.Cut(1, 2)

			for( var/dir in cardinal )
				t = get_step( current_fluid, dir )
				if (!VALID_FLUID_CONNECTION(current_fluid, t)) continue
				if (t.active_liquid.group != src.group)
					continue

				//Old method : search through 'visited' for 't.active_liquid'. Probably slow when you have big groups!!
				//if(t.active_liquid in visited) continue
				//visited += t.active_liquid

				//New method : Add the liquid at a specific index. To check whether the node has already been visited, just compare the len of the visited group from before + after the index has been set.
				//Probably slower for small groups and much faster for large groups.
				visited_changed = length(visited)
				visited["[t.active_liquid.x]_[t.active_liquid.y]_[t.active_liquid.z]"] = t.active_liquid
				visited_changed = (visited.len != visited_changed)

				if (visited_changed)
					queue += t.active_liquid
					.+= t

					if (stop_at > 0 && length(.) >= stop_at)
						return .


	proc/try_connect_to_adjacent()
		var/turf/t
		for( var/dir in cardinal )
			t = get_step( src, dir )
			if( !t ) continue
			if (!t.active_liquid || t.active_liquid.disposed) continue
			if (t.active_liquid && t.active_liquid.group && src.group != t.active_liquid.group)
				t.active_liquid.group.join(src.group)
			LAGCHECK(LAG_HIGH)

	//hey this isn't being called at all right now. Moved its blood spread shit up into spread() so we don't call this function that basically does nothing
	/*proc/flow_towards(var/list/obj/Flist, var/push_stuff = 1)
		if (!length(Flist)) return
		if (!src.group || !src.group.reagents) return

		var/push_class = 0
		if (push_stuff)
			if (src.amt >= push_tiny_req)
				push_class = 1
			if (src.amt >= push_small_req)
				push_class = 2
			if (src.amt >= push_med_req)
				push_class = 3
			if (src.amt >= push_large_req)
				push_class = 4

		for (var/obj/fluid/F in Flist)
			LAGCHECK(LAG_HIGH)
			if (!F) continue

			//copy blood stuff
			if (src.blood_DNA && !F.blood_DNA)
				F.blood_DNA = src.blood_DNA
			if (src.blood_type && !F.blood_type)
				F.blood_type = src.blood_type

			continue

			if (push_class)
				for (var/obj/item/I in src.loc)
					LAGCHECK(LAG_HIGH)
					if (prob(15) && !I.anchored && I.w_class <= push_class)
						step_towards(I,F.loc)
						break
				if (push_class >= 4 && prob(30))
					LAGCHECK(LAG_HIGH)
					for (var/mob/living/M in src.loc)
						step_towards(M,F.loc)
						break
	*/
	update_icon(var/neighbor_was_removed = 0)  //BE WARNED THIS PROC HAS A REPLICA UP ABOVE IN FLUID GROUP UPDATE_LOOP. DO NOT CHANGE THIS ONE WITHOUT MAKING THE SAME CHANGES UP THERE OH GOD I HATE THIS

		if (!src.group || !src.group.reagents) return



		var/color_changed = 0
		var/datum/color/average = src.group.average_color ? src.group.average_color : src.group.reagents.get_average_color()
		src.finalalpha = max(25, (average.a / 255) * src.group.max_alpha)
		src.finalcolor = rgb(average.r, average.g, average.b)
		if (src.color != finalcolor)
			color_changed = 1
		animate( src, color = finalcolor, alpha = finalalpha, time = 5 )

		if (neighbor_was_removed)
			last_spread_was_blocked = 0
			src.clear_overlay()

		var/last_icon = icon_state

		if (last_spread_was_blocked || (src.group && src.group.amt_per_tile > src.group.required_to_spread))
			icon_state = "15"
		else
			var/dirs = 0
			for (var/dir in cardinal)
				var/turf/simulated/T = get_step(src, dir)
				if (T && T.active_liquid && T.active_liquid.group == src.group)
					dirs |= dir
			icon_state = num2text(dirs)

			if (src.overlay_refs && length(src.overlay_refs))
				src.clear_overlay()

		if ((color_changed || last_icon != icon_state) && last_spread_was_blocked)
			src.update_perspective_overlays()

	proc/update_perspective_overlays() // fancy perspective overlaying
		if (icon_state != "15") return
		var/blocked = 0
		for( var/dir in cardinal )
			if (dir == SOUTH) //No south perspective
				continue

			if (blocked_perspective_objects["[dir]"])
				blocked = 1
				if (dir == NORTH)
					display_overlay("[dir]",0,32)
				else
					display_overlay("[dir]",(dir == EAST) ? 32 : -32,0)
			else
				clear_overlay("[dir]")

		if (!blocked) //Nothing adjacent!
			clear_overlay()

		if (src.overlay_refs && length(src.overlay_refs))
			if (src.overlay_refs["1"] && src.overlay_refs["8"]) //north, east
				display_overlay("9",-32,32) //northeast
			else
				clear_overlay("9")  //northeast
			if (src.overlay_refs["1"] && src.overlay_refs["4"]) //north, west
				display_overlay("5",32,32) //northwest
			else
				clear_overlay("5") //northwest

	//perspective overlays
	proc/display_overlay(var/overlay_key, var/pox, var/poy)
		var/image/overlay = 0
		if (!wall_overlay_images)
			wall_overlay_images = list()

		if (wall_overlay_images[overlay_key])
			overlay = wall_overlay_images[overlay_key]
		else
			overlay = image('icons/obj/fluid.dmi', "blank")

		var/over_obj = !(istype(src.loc, /turf/simulated/wall) || istype(src.loc,/turf/unsimulated/wall/)) //HEY HEY MBC THIS SMELLS THINK ABOUT IT LATER
		overlay.layer = over_obj ? 4 : src.layer
		overlay.icon_state = "wall_[overlay_key]_[last_depth_level]"
		overlay.pixel_x = pox
		overlay.pixel_y = poy
		wall_overlay_images[overlay_key] = overlay

		src.AddOverlays(overlay, overlay_key)

	proc/clear_overlay(var/key = 0)
		if (!key)
			src.ClearAllOverlays()
		else if(key && wall_overlay_images && wall_overlay_images[key])
			src.ClearSpecificOverlays(key)

	proc/debug_search()
		var/list/C = src.get_connected_fluids()
		var/obj/fluid/F
		var/c = pick("#0099ff","#dddddd","#ff7700")

		for (var/i = 1, i <= C.len, i++)
			F = C[i]
			F.finalcolor = c
			animate( F, color = F.finalcolor, alpha = finalalpha, time = 5 )
			sleep(0.1 SECONDS)

	proc/admin_clear_fluid()
		set name = "Clear Fluid"
		if(src.group)
			src.group.evaporate()
		else
			qdel(src)





//HASENTERED CLLAS
// HASEXITED CALLS

//messy i know, but this works for me and is Optimal to avoid type checking


/obj/event_handler_flags = USE_FLUID_ENTER

/obj/EnteredFluid(obj/fluid/F as obj)
	//object submerged overlays
	if (src.submerged_images && (src.is_submerged != F.my_depth_level))
		for (var/image/I in src.submerged_images)
			I.color = F.finalcolor
			I.alpha = F.finalalpha
		if ((src.submerged_images && length(src.submerged_images)))
			src.show_submerged_image(F.my_depth_level)

	..()

/obj/ExitedFluid(obj/fluid/F as obj)
	if (src.submerged_images && src.is_submerged != 0)
		if (F.disposed)
			src.show_submerged_image(0)
			return

		if (isturf(src.loc))
			var/turf/T = src.loc
			if (!T.active_liquid || (T.active_liquid && T.active_liquid.amt < depth_levels[1]))
				src.show_submerged_image(0)
				return
		else
			src.show_submerged_image(0)
			return
	..()

/mob/living/EnteredFluid(obj/fluid/F as obj, atom/oldloc)
	//SUBMERGED OVERLAYS
	if (src.is_submerged != F.my_depth_level)
		for (var/image/I in src.submerged_images)
			I.color = F.finalcolor
			I.alpha = F.finalalpha
		src.show_submerged_image(F.my_depth_level)
	..()

/mob/living/ExitedFluid(obj/fluid/F as obj)
	if (src.is_submerged == 0) return

	if (F.disposed)
		src.show_submerged_image(0)
		return
	else if (isturf(src.loc))
		var/turf/T = src.loc
		if (!T.active_liquid || (T.active_liquid && T.active_liquid.amt < depth_levels[1]))
			src.show_submerged_image(0)
			return
	else
		src.show_submerged_image(0)
		return
	..()

/mob/living/carbon/EnteredFluid(obj/fluid/F as obj, atom/oldloc, var/do_reagent_reaction = 1)
	var/entered_group = 1 //Did the entering atom cross from a non-fluid to a fluid tile?
	//SLIPPING
	//only slip if edge tile
	var/turf/T = get_turf(oldloc)
	if (T?.active_liquid)
		entered_group = 0

	if (entered_group && (src.loc != oldloc))
		if (F.amt > 0 && F.amt <= F.max_slip_volume && F.avg_viscosity <= F.max_slip_viscosity)
			var/master_block_slippy = F.group.reagents.get_master_reagent_slippy(F.group)
			switch(master_block_slippy)
				if(0)
					var/slippery =  (1 - (F.avg_viscosity/F.max_slip_viscosity)) * 50
					var/checks = 10
					for (var/thing in oldloc)
						if (istype(thing,/obj/machinery/door))
							slippery = 0
						checks--
						if (checks <= 0) break
					if (prob(slippery) && src.slip())
						src.visible_message(SPAN_ALERT("<b>[src]</b> slips on [F]!"),\
						SPAN_ALERT("You slip on [F]!"))
				if(-1) //space lube. this code bit is shit but i'm too lazy to make it Real right now. the proper implementation should also make exceptions for ice and stuff.
					src.remove_pulling()
					src.changeStatus("knockdown", 3.5 SECONDS)
					boutput(src, SPAN_NOTICE("You slipped on [F]!"))
					playsound(T, 'sound/misc/slip.ogg', 50, TRUE, -3)
					var/atom/target = get_edge_target_turf(src, src.dir)
					src.throw_at(target, 12, 1, throw_type = THROW_SLIP)
				if(-2) //superlibe
					src.remove_pulling()
					src.changeStatus("knockdown", 6 SECONDS)
					playsound(T, 'sound/misc/slip.ogg', 50, TRUE, -3)
					boutput(src, SPAN_NOTICE("You slipped on [F]!"))
					var/atom/target = get_edge_target_turf(src, src.dir)
					src.throw_at(target, 30, 1, throw_type = THROW_SLIP)
					random_brute_damage(src, 10)



	//Possibility to consume reagents. (Each reagent should return 0 in its reaction_[type]() proc if reagents should be removed from fluid)
	if (do_reagent_reaction && F.group.reagents && F.group.reagents.reagent_list && F.amt > CHEM_EPSILON)
		F.group.last_reacted = F
		var/react_volume = F.amt > 10 ? (F.amt / 2) : (F.amt)
		react_volume = min(react_volume,100) //capping the react amt
		var/list/reacted_ids = F.group.reagents.reaction(src, TOUCH, react_volume,1,F.group.members.len, entered_group)
		var/volume_fraction = F.group.reagents.total_volume ? (react_volume / F.group.reagents.total_volume) : 0

		for(var/current_id in reacted_ids)
			if (!src.group) return
			var/datum/reagent/current_reagent = F?.group.reagents.reagent_list[current_id]
			if (!current_reagent) continue
			F.group.reagents.remove_reagent(current_id, current_reagent.volume * volume_fraction)
		/*
		if (length(reacted_ids))
			src.UpdateIcon()
		*/

	..()

/mob/living/carbon/human/EnteredFluid(obj/fluid/F as obj, atom/oldloc)
	var/entered_group = 1 //Did the entering atom cross from a non-fluid to a fluid tile?
	//SLIPPING
	//only slip if edge tile
	var/turf/T = get_turf(oldloc)
	if (T?.active_liquid)
		entered_group = 0

	//BLOODSTAINS
	if (F.group.master_reagent_id == "blood" || F.group.master_reagent_id == "bloodc" || F.group.master_reagent_id == "hemolymph") // Replace with a blood reagent check proc
		if (src.lying)
			if (src.wear_suit)
				src.wear_suit.add_blood(F)
				src.update_bloody_suit()
			else if (src.w_uniform)
				src.w_uniform.add_blood(F)
				src.update_bloody_uniform()
		else
			if (src.shoes)
				src.shoes.add_blood(F)
				src.update_bloody_shoes()
			else
				src.add_blood(F)

		F.add_tracked_blood(src)
		src.update_bloody_feet()

	var/do_reagent_reaction = 1

	if (F.my_depth_level == 1)
		if(!src.lying && src.shoes && src.shoes.hasProperty ("chemprot") && (src.shoes.getProperty("chemprot") >= 5)) //sandals do not help
			do_reagent_reaction = 0
			if (!src.wear_suit || !(src.wear_suit.c_flags & SPACEWEAR)) // suits can go over shoes
				F.group.reagents.reaction(src.shoes, TOUCH, F.group.amt_per_tile, can_spawn_fluid = FALSE)

	if (entered_group) //if entered_group == 1, it may not have been set yet
		if (isturf(oldloc))
			if (T.active_liquid)
				entered_group = 0

	..(F, oldloc, do_reagent_reaction)
