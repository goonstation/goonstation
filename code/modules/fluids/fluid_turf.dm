//fluid as a space tile
//on turfnotify, will start processing fluid creation

#define SPAWN_DECOR 1
#define SPAWN_PLANTS 2
#define SPAWN_FISH 4
#define SPAWN_LOOT 8
#define SPAWN_PLANTSMANTA 16
#define SPAWN_TRILOBITE 32
#define SPAWN_HALLU 64


/turf/proc/make_light() //dummyproc so we can inherit
	.=0

/turf/space/fluid
	name = "ocean floor"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "sand_other"
	color = OCEAN_COLOR
	pathable = 0
	mat_changename = 0
	mat_changedesc = 0
	fullbright = 0
	luminosity = 1
	intact = 0 //allow wire laying
	throw_unlimited = 0
	//todo fix : cannot flip.
	//todo : TOUCH reagent func

	oxygen = MOLES_O2STANDARD * 0.5
	nitrogen = MOLES_N2STANDARD * 0.5
	temperature = OCEAN_TEMP
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	special_volume_override = 0.62

	turf_flags = FLUID_MOVE

	var/datum/light/point/light = 0
	var/light_r = 0.16
	var/light_g = 0.6
	var/light_b = 0.8

	var/light_brightness = 0.8
	var/light_height = 3

	var/spawningFlags = SPAWN_DECOR | SPAWN_PLANTS | SPAWN_FISH
	var/randomIcon = 1

	var/generateLight = 1 //do we sometimes generate a special light?

	var/captured = 0 //Thermal vent collector on my tile? (messy i know, but faster lookups later)

	var/allow_hole = 1

	var/linked_hole = null


	New()
		..()

		if (randomIcon)
			switch(rand(1,3))
				if(1)
					icon_state = "sand_other_texture"
					src.set_dir(pick(alldirs))
				if(2)
					icon_state = "sand_other_texture2"
					src.set_dir(pick(alldirs))
				if(3)
					icon_state = "sand_other_texture3"
					src.set_dir(pick(cardinal))

		if (spawningFlags && current_state <= GAME_STATE_WORLD_INIT)
			//worldgenCandidates[src] = 1 //Adding self to possible worldgen turfs
			// idk about the above. walls still use [src]=1 ...
			// the bottom is much faster in my testing and works just as well
			// maybe should be converted to this everywhere?
			if(src.z == Z_LEVEL_STATION || src.z == Z_LEVEL_MINING)
				worldgenCandidates += src //Adding self to possible worldgen turfs

		if(current_state > GAME_STATE_WORLD_INIT)
			for(var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if(istype(T) && T.ocean_canpass() && !istype(T, /turf/space))
					src.tilenotify(T)
					break

		//globals defined in fluid_spawner
		#ifdef UNDERWATER_MAP
		#else
		src.name = ocean_name
		#endif

		if(ocean_color)
			var/fluid_color = hex_to_rgb_list(ocean_color)
			light_r = fluid_color[1] / 255
			light_g = fluid_color[2] / 255
			light_b = fluid_color[3] / 255

		//let's replicate old behavior
		if (generateLight)
			generateLight = 0
			if (z != 3) //nono z3
				for (var/dir in alldirs)
					var/turf/T = get_step(src,dir)
					if (istype(T, /turf/simulated))
						generateLight = 1
						break

		if (generateLight)
			START_TRACKING_CAT(TR_CAT_LIGHT_GENERATING_TURFS)

	Del()
		. = ..()
		if (generateLight)
			STOP_TRACKING_CAT(TR_CAT_LIGHT_GENERATING_TURFS)

	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		light.enable()

	proc/bake_light()


		sleep(0.1 SECONDS)
		for(var/obj/overlay/tile_effect/lighting/L in src)
			src.icon = getFlatIcon(L)
			qdel(L)

	proc/update_light()
		if (light)
			light.disable()
			light.set_brightness(light_brightness)
			light.set_color(light_r, light_g, light_b)
			light.set_height(light_height)
			light.enable()

//space/fluid/ReplaceWith() this is for future ctrl Fs
	ReplaceWith(var/what, var/keep_old_material = 1, var/handle_air = 1, var/handle_dir = 1, force = 0)
		.= ..(what, keep_old_material, handle_air)

		if (handle_air)
			for (dir in cardinal)
				var/turf/T = get_step(src,dir)
				if (istype(T,/turf/space/fluid))
					T.tilenotify(src)

		if (src in processing_fluid_turfs)
			processing_fluid_turfs.Remove(src)

	generate_worldgen()
		if (istype(src.loc, /area/shuttle)) return

		if (spawningFlags & SPAWN_DECOR)
			if (src.z == 5)
				if (prob(1))
					new /obj/item/seashell(src)
			else
				if (prob(5))
					new /obj/item/seashell(src)

		if (spawningFlags & SPAWN_PLANTS)
			if (prob(8))
				var/obj/plant = pick( src.z == 5 ? childrentypesof(/obj/sea_plant) : (childrentypesof(/obj/sea_plant) - /obj/sea_plant/anemone/lit) )
				var/obj/sea_plant/P = new plant(src)
				//mbc : bleh init() happens BFORRE this, most likely
				P.initialize()

		if (spawningFlags & SPAWN_PLANTSMANTA)
			if (prob(8))
				var/obj/plant = pick( src.z == 5 ? childrentypesof(/obj/sea_plant_manta) : (childrentypesof(/obj/sea_plant_manta) - /obj/sea_plant_manta/anemone/lit) )
				var/obj/sea_plant_manta/P = new plant(src)
				//mbc : bleh init() happens BFORRE this, most likely
				P.initialize()

		#ifndef UPSCALED_MAP
		if(spawningFlags & SPAWN_FISH) //can spawn bad fishy
			if (src.z == 5 && prob(1) && prob(2))
				new /obj/critter/gunbot/drone/buzzdrone/fish(src)
			else if (src.z == 5 && prob(1) && prob(4))
				new /obj/critter/gunbot/drone/gunshark(src)
			else if (prob(1) && prob(20))
				var/mob/fish = pick(childrentypesof(/mob/living/critter/aquatic/fish))
				new fish(src)
			else if (src.z == 5 && prob(1) && prob(9) && prob(90))
				var/obj/naval_mine/O = 0
				if (prob(20))
					if (prob(70))
						O = new /obj/naval_mine/standard(src)
					else
						O = new /obj/naval_mine/vandalized(src)
				else
					O = new /obj/naval_mine/rusted(src)
				if (O)
					O.initialize()
		#endif

		if(spawningFlags & SPAWN_TRILOBITE)
			if (prob(17))
				new /obj/overlay/tile_effect/cracks/spawner/trilobite(src)
			if (prob(2))
				new /obj/overlay/tile_effect/cracks/spawner/pikaia(src)

		if(spawningFlags & SPAWN_HALLU)
			if (prob(1) && prob(16))
				new /mob/living/critter/small_animal/hallucigenia/ai_controlled(src)
			else if (prob(1) && prob(18))
				new /obj/overlay/tile_effect/cracks/spawner/pikaia(src)

		if (spawningFlags & SPAWN_LOOT)
			if (prob(1) && prob(9))
				var/obj/storage/crate/trench_loot/C = pick(childrentypesof(/obj/storage/crate/trench_loot))
				var/obj/storage/crate/trench_loot/created_loot = new C(src)
				created_loot.initialize()

	levelupdate()
		for(var/obj/O in src)
			if(O.level == 1)
				O.hide(0)

	tilenotify(turf/notifier)
		if (istype(notifier, /turf/space)) return
		if(notifier.ocean_canpass())
			processing_fluid_turfs |= src
		else
			if (processing_fluid_turfs.Remove(src))
				if (src.light)
					src.light.disable()

	Entered(atom/movable/A as mob|obj) //MBC : I was too hurried and lazy to make this actually apply reagents on touch. this is a note to myself. FUCK YOUUU
		..()
		if(A.getStatusDuration("burning"))
			A.changeStatus("burning", -50 SECONDS)

		A.EnteredFluid(ocean_fluid_obj, A.loc)

		//nah disable for now i dont wanna do istype checks on enter
		//else if(isitem(A))
		//	var/obj/item/O = A
		//	if(O.burning && prob(40))
		//		O.burning = 0

	Exited(atom/movable/Obj, atom/newloc)
		. = ..()
		Obj.ExitedFluid(Obj, newloc)

	proc/force_mob_to_ingest(var/mob/M, var/mult = 1)//called when mob is drowning
		if (!M) return

		var/react_volume = 50 * mult
		if (M.reagents)
			react_volume = min(react_volume, abs(M.reagents.maximum_volume - M.reagents.total_volume)) //don't push out other reagents if we are full
			M.reagents.add_reagent(ocean_reagent_id, react_volume) //todo : maybe add temp var here too

	attackby(obj/item/C, mob/user, params) //i'm sorry
		if(istype(C, /obj/item/cable_coil))
			var/obj/item/cable_coil/coil = C
			coil.turf_place(src, get_turf(user), user)
		..()


	ex_act(severity)
		..()
		if (captured)
			return

		if (!prob(severity*20))
			for (var/obj/O in src)
				if (istype(O, /obj/lattice) || istype(O, /obj/cable/reinforced) || istype(O, /obj/item/heat_dowsing) || istype(O, /obj/machinery/conveyor) || istype(O,/obj/item/cable_coil/reinforced) )
					return

			blow_hole()

	proc/blow_hole()
		if (src.z != 5 && allow_hole)
			src.ReplaceWith(/turf/space/fluid/warp_z5/realwarp, FALSE, TRUE, FALSE, TRUE)

//////////////////////duh look below
/turf/space/fluid/warp_z5

	name = "deep hole"
	icon_state = "pit"
	var/list/L = list()
	spawningFlags = 0
	randomIcon = 0
	generateLight = 0

	allow_hole = 0

	color = OCEAN_COLOR
	// fullbright = 1

	edge
		icon_state = "pit_wall"

		New()
			. = ..()
			START_TRACKING

		Del()
			STOP_TRACKING
			. = ..()

	proc/try_build_turf_list()
		if (!L || L.len == 0)
			for(var/turf/T in get_area_turfs(/area/trench_landing))
				L+=T

	Entered(var/atom/movable/AM)
		. = ..()
		if (istype(AM,/mob/dead) || istype(AM,/mob/wraith) || istype(AM,/mob/living/intangible) || istype(AM, /obj/lattice) || istype(AM, /obj/cable/reinforced) || istype(AM,/obj/torpedo_targeter) || istype(AM,/obj/overlay) || istype (AM, /obj/arrival_missile) || istype(AM, /obj/sea_ladder_deployed))
			return
		if (locate(/obj/lattice) in src)
			return
		return_if_overlay_or_effect(AM)

		try_build_turf_list()

		if (length(L))
			SPAWN(0.3 SECONDS)//you can 'jump' over a hole by running real fast or being thrown!!
				if (istype(AM.loc, /turf/space/fluid/warp_z5))
					visible_message("<span class='alert'>[AM] falls down [src]!</span>")

					if (istype(AM, /obj/machinery/vehicle))
						var/obj/machinery/vehicle/V = AM
						var/turf/target_turf = V.go_home()
						if (V.going_home && target_turf)
							V.going_home = 0
							AM.set_loc(target_turf)
							return

					if (ismob(AM))
						var/mob/M = AM
						random_brute_damage(M, 6)
						M.changeStatus("weakened", 2 SECONDS)
						playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 10, 1)
						M.emote("scream")

					AM.set_loc(pick(L))


/turf/space/fluid/warp_z5/realwarp
	New()
		..()
		if (get_step(src, NORTH).type != /turf/space/fluid/warp_z5/realwarp)
			icon_state = "pit_wall"

		var/turf/space/fluid/under = get_step(src, SOUTH)
		if (under.type == /turf/space/fluid/warp_z5/realwarp)
			under.icon_state = "pit"

	try_build_turf_list()
		if (!L || L.len == 0)
			for(var/turf/space/fluid/T in range(8,locate(src.x,src.y,5)))
				L += T
				break

			if(length(L))
				var/needlink = 1
				var/turf/space/fluid/picked_turf = pick(L)

				for(var/turf/space/fluid/T in range(5,picked_turf))
					if(T.linked_hole)
						needlink = 0
						break

				if(needlink)
					if(!picked_turf.linked_hole)
						picked_turf.linked_hole = src
						src.add_simple_light("trenchhole", list(120, 120, 120, 120))

		..()


//trench floor
/turf/space/fluid/trench
	name = "trench floor"
	temperature = TRENCH_TEMP
	fullbright = 0
	luminosity = 1
	generateLight = 0
	allow_hole = 0
	spawningFlags = SPAWN_DECOR | SPAWN_PLANTS | SPAWN_FISH | SPAWN_LOOT | SPAWN_HALLU

	blow_hole()
		if(src.z == 5)
			for(var/turf/space/fluid/T in range(1, locate(src.x, src.y, 1)))
				if(T.allow_hole)
					var/x = T.x
					var/y = T.y
					T.blow_hole()
					var/turf/space/fluid/warp_z5/hole = locate(x, y, 1)
					if(istype(hole))
						hole.L = list(src)
						src.linked_hole = hole
						src.add_simple_light("trenchhole", list(120, 120, 120, 120))
						break

/turf/space/fluid/nospawn
	spawningFlags = null

	generate_worldgen()
		return

/turf/space/fluid/noexplosion
	allow_hole = 0
	ex_act(severity)
		return

/turf/space/fluid/noexplosion/nospawn
	spawningFlags = null

	ex_act(severity)
		return


//cenote for the biodome area
/turf/space/fluid/cenote
	fullbright = 0
	luminosity = 1
	generateLight = 0
	spawningFlags = null
	allow_hole = 0
	icon_state = "cenote"
	name = "cenote"
	desc = "A deep flooded sinkhole."
	randomIcon = 0

	New()
		..()
		src.set_dir(pick(NORTH,SOUTH))


	ex_act(severity)
		return

//full bright, used by oceanify on space maps
/turf/space/fluid/fullbright
	fullbright = 1

//Manta
/turf/space/fluid/manta
	luminosity = 1
	generateLight = 0
	spawningFlags = SPAWN_PLANTSMANTA
	turf_flags = CAN_BE_SPACE_SAMPLE | MANTA_PUSH

//Manta
/turf/space/fluid/manta/nospawn
	spawningFlags = null

/turf/simulated/floor/specialroom/sea_elevator_shaft
	name = "elevator shaft"
	desc = "It looks like it goes down a long ways."
	icon_state = "moon_shaft"
	var/const/area_type = /area/shuttle/sea_elevator/upper

	New()
		..()

		var/turf/n = get_step(src,NORTH)
		var/turf/e = get_step(src,EAST)
		var/turf/w = get_step(src,WEST)
		var/turf/s = get_step(src,SOUTH)

		if (!istype(get_area(n),area_type))
			n = null
		if (!istype(get_area(e),area_type))
			e = null
		if (!istype(get_area(w),area_type))
			w = null
		if (!istype(get_area(s),area_type))
			s = null

		if (e && s)
			set_dir(SOUTH)
			e.set_dir(NORTH)
			s.set_dir(WEST)
		else if (e && n)
			set_dir(WEST)
			e.set_dir(EAST)
			n.set_dir(SOUTH)
		else if (w && s)
			set_dir(NORTH)
			w.set_dir(SOUTH)
			s.set_dir(EAST)
		else if (w && n)
			set_dir(EAST)
			w.set_dir(WEST)
			n.set_dir(NORTH)

	ex_act(severity)
		return

	Entered(atom/movable/A as mob|obj)
		if (istype(A, /obj/overlay/tile_effect) || istype(A, /mob/dead) || istype(A, /mob/wraith) || istype(A, /mob/living/intangible))
			return ..()
		var/turf/T = pick_landmark(LANDMARK_FALL_SEA)
		if (isturf(T))
			visible_message("<span class='alert'>[A] falls down [src]!</span>")
			if (ismob(A))
				var/mob/M = A
				random_brute_damage(M, 25)
				M.changeStatus("weakened", 5 SECONDS)
				M.emote("scream")
				playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			A.set_loc(T)
			return
		else ..()

/obj/machinery/computer/sea_elevator
	name = "Elevator Control"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_ELEVATORCOMPS
	var/active = 0
	var/location = 1 // 0 for bottom, 1 for top

/obj/machinery/computer/sea_elevator/attack_hand(mob/user)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	if(location)
		dat += "Elevator Location: Upper level"
	else
		dat += "Elevator Location: Lower Level"
	dat += "<BR>"
	if(active)
		dat += "Moving"
	else
		dat += "<a href='byond://?src=\ref[src];send=1'>Move Elevator</a><BR><BR>"

	user.Browse(dat, "window=sea_elevator")
	onclose(user, "sea_elevator")
	return

/obj/machinery/computer/sea_elevator/Topic(href, href_list)
	if(..())
		return
	if (((src in usr.contents) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if (href_list["send"])
			if(!active)
				for(var/obj/machinery/computer/sea_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
					active = 1
					C.visible_message("<span class='alert'>The elevator begins to move!</span>")
					playsound(C.loc, 'sound/machines/elevator_move.ogg', 100, 0)
				SPAWN(5 SECONDS)
					call_shuttle()

		if (href_list["close"])
			src.remove_dialog(usr)
			usr.Browse(null, "window=sea_elevator")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/sea_elevator/proc/call_shuttle()

	if(location == 0) // at bottom
		var/area/start_location = locate(/area/shuttle/sea_elevator/lower)
		var/area/end_location = locate(/area/shuttle/sea_elevator/upper)
		start_location.move_contents_to(end_location, /turf/simulated/floor/plating, ignore_fluid = 1)
		location = 1
	else // at top
		var/area/start_location = locate(/area/shuttle/sea_elevator/upper)
		var/area/end_location = locate(/area/shuttle/sea_elevator/lower)
		for(var/mob/M in end_location) // oh dear, stay behind the yellow line kids
			SPAWN(1 DECI SECOND)
				random_brute_damage(M, 30)
				M.changeStatus("weakened", 5 SECONDS)
				M.emote("scream")
				playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 90, 1)
		start_location.move_contents_to(end_location, /turf/simulated/floor/specialroom/sea_elevator_shaft, ignore_fluid = 1)
		location = 0

	for(var/obj/machinery/computer/sea_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
		active = 0
		C.visible_message("<span class='alert'>The elevator has moved.</span>")
		C.location = src.location

	return




proc/fluid_turf_setup(first_time=FALSE)
	if(QDELETED(ocean_fluid_obj))
		ocean_fluid_obj = new
	var/datum/fluid_group/FG = new
	FG.add(ocean_fluid_obj)
	ocean_fluid_obj.group = FG
	ocean_fluid_obj.my_depth_level = 4 // maybe a good idea to change to 5 so it's possible to distinguish ocean at some point
	FG.reagents.add_reagent(ocean_reagent_id, INFINITY)


#undef SPAWN_DECOR
#undef SPAWN_PLANTS
#undef SPAWN_FISH
#undef SPAWN_PLANTSMANTA
