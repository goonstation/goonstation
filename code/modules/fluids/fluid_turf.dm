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

	turf_flags = CAN_BE_SPACE_SAMPLE | FLUID_MOVE

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


	New()
		..()

		if (randomIcon)
			switch(rand(1,3))
				if(1)
					icon_state = "sand_other_texture"
					src.dir = pick(alldirs)
				if(2)
					icon_state = "sand_other_texture2"
					src.dir = pick(alldirs)
				if(3)
					icon_state = "sand_other_texture3"
					src.dir = pick(cardinal)

		if (spawningFlags && current_state <= GAME_STATE_WORLD_INIT)
			//worldgenCandidates[src] = 1 //Adding self to possible worldgen turfs
			// idk about the above. walls still use [src]=1 ...
			// the bottom is much faster in my testing and works just as well
			// maybe should be converted to this everywhere?
			worldgenCandidates += src //Adding self to possible worldgen turfs

		//globals defined in fluid_spawner
		#ifdef UNDERWATER_MAP
		#else
		src.name = ocean_name
		#endif

		//let's replicate old behaivor
		if (generateLight)
			generateLight = 0
			if (z != 3) //nono z3
				for (var/dir in alldirs)
					var/turf/T = get_step(src,dir)
					if (istype(T, /turf/simulated))
						generateLight = 1
						break

		if (generateLight)
			light_generating_fluid_turfs.Add(src)

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
			if (!(src in processing_fluid_turfs))
				processing_fluid_turfs.Add(src)
		else
			if (src in processing_fluid_turfs)
				processing_fluid_turfs.Remove(src)
				if (src.light)
					src.light.disable()

	Entered(atom/movable/A as mob|obj) //MBC : I was too hurried and lazy to make this actually apply reagents on touch. this is a note to myself. FUCK YOUUU
		..()
		if(A.getStatusDuration("burning"))
			A.changeStatus("burning", -500)

		//nah disable for now i dont wanna do istype checks on enter
		//else if(isitem(A))
		//	var/obj/item/O = A
		//	if(O.burning && prob(40))
		//		O.burning = 0

	proc/force_mob_to_ingest(var/mob/M)//called when mob is drowning
		if (!M) return

		var/react_volume = 50
		if (M.reagents)
			react_volume = min(react_volume, abs(M.reagents.maximum_volume - M.reagents.total_volume)) //don't push out other reagents if we are full
			M.reagents.add_reagent(ocean_reagent_id, react_volume) //todo : maybe add temp var here too

	attackby(obj/item/C as obj, mob/user as mob, params) //i'm sorry
		if(istype(C, /obj/item/cable_coil))
			var/obj/item/cable_coil/coil = C
			coil.turf_place(src, user)
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
		if (src.z != 5)
			new /turf/space/fluid/warp_z5/realwarp(src)

//////////////////////duh look below
/turf/space/fluid/warp_z5

	name = "deep hole"
	icon_state = "pit"
	var/list/L = list()
	spawningFlags = 0
	randomIcon = 0
	generateLight = 0

	color = OCEAN_COLOR
	// fullbright = 1

	edge
		icon_state = "pit_wall"


	proc/try_build_turf_list()
		if (!L || L.len == 0)
			for(var/turf/T in get_area_turfs(/area/trench_landing))
				L+=T

	Entered(var/atom/movable/AM)
		if (istype(AM,/mob/dead) || istype(AM,/mob/wraith) || istype(AM,/mob/living/intangible) || istype(AM, /obj/lattice) || istype(AM, /obj/cable/reinforced) || istype(AM,/obj/torpedo_targeter) || istype(AM,/obj/overlay) || istype (AM, /obj/arrival_missile))
			return
		if (locate(/obj/lattice) in src)
			return
		return_if_overlay_or_effect(AM)

		try_build_turf_list()

		if (L && L.len)
			SPAWN_DBG(0.3 SECONDS)//you can 'jump' over a hole by running real fast or being thrown!!
				if (istype(AM.loc, /turf/space/fluid/warp_z5))
					visible_message("<span class='alert'>[AM] falls down [src]!</span>")
					if (ismob(AM))
						var/mob/M = AM
						random_brute_damage(M, 6)
						M.changeStatus("weakened", 2 SECONDS)
						playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 10, 1)
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
		..()


//trench floor
/turf/space/fluid/trench
	name = "trench floor"
	temperature = TRENCH_TEMP
	fullbright = 0
	luminosity = 1
	generateLight = 0
	spawningFlags = SPAWN_DECOR | SPAWN_PLANTS | SPAWN_FISH | SPAWN_LOOT | SPAWN_HALLU

/turf/space/fluid/nospawn
	spawningFlags = null

	generate_worldgen()
		return

/turf/space/fluid/noexplosion
	ex_act(severity)
		return

/turf/space/fluid/noexplosion/nospawn
	spawningFlags = null

	ex_act(severity)
		return

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

	New()
		..()

		var/turf/n = 0
		var/turf/e = 0
		var/turf/w = 0
		var/turf/s = 0

		n = get_step(src,NORTH)
		if (!istype(e,/turf/simulated/floor/specialroom/sea_elevator_shaft))
			n = 0
		e = get_step(src,EAST)
		if (!istype(e,/turf/simulated/floor/specialroom/sea_elevator_shaft))
			e = 0
		w = get_step(src,WEST)
		if (!istype(e,/turf/simulated/floor/specialroom/sea_elevator_shaft))
			w = 0
		s = get_step(src,SOUTH)
		if (!istype(e,/turf/simulated/floor/specialroom/sea_elevator_shaft))
			s = 0

		//have fun reading this! also fuck youu!
		if (e && s)
			dir = SOUTH
			e.dir = NORTH
			s.dir = WEST
		else if (e && n)
			dir = WEST
			e.dir = EAST
			n.dir = SOUTH
		else if (w && s)
			dir = NORTH
			w.dir = SOUTH
			s.dir = EAST
		else if (w && n)
			dir = EAST
			w.dir = WEST
			n.dir = NORTH


	ex_act(severity)
		return

	Entered(atom/movable/A as mob|obj)
		if (istype(A, /obj/overlay/tile_effect) || istype(A, /mob/dead) || istype(A, /mob/wraith) || istype(A, /mob/living/intangible))
			return ..()
		if (icefall.len)
			var/turf/T = pick(seafall)
			if (isturf(T))
				visible_message("<span class='alert'>[A] falls down [src]!</span>")
				if (ismob(A))
					var/mob/M = A
					random_brute_damage(M, 25)
					M.changeStatus("weakened", 5 SECONDS)
					M.emote("scream")
					playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 50, 1)
				A.set_loc(T)
				return
		else ..()

/obj/machinery/computer/sea_elevator
	name = "Elevator Control"
	icon_state = "shuttle"
	machine_registry_idx = MACHINES_ELEVATORCOMPS
	var/active = 0
	var/location = 1 // 0 for bottom, 1 for top

/obj/machinery/computer/sea_elevator/attack_hand(mob/user as mob)
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
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if (href_list["send"])
			if(!active)
				for(var/obj/machinery/computer/sea_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
					active = 1
					C.visible_message("<span class='alert'>The elevator begins to move!</span>")
				SPAWN_DBG(5 SECONDS)
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
			SPAWN_DBG(1 DECI SECOND)
				random_brute_damage(M, 30)
				M.changeStatus("weakened", 5 SECONDS)
				M.emote("scream")
				playsound(M.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 90, 1)
		start_location.move_contents_to(end_location, /turf/simulated/floor/specialroom/sea_elevator_shaft, ignore_fluid = 1)
		location = 0

	for(var/obj/machinery/computer/sea_elevator/C in machine_registry[MACHINES_ELEVATORCOMPS])
		active = 0
		C.visible_message("<span class='alert'>The elevator has moved.</span>")
		C.location = src.location

	return




#undef SPAWN_DECOR
#undef SPAWN_PLANTS
#undef SPAWN_FISH
#undef SPAWN_PLANTSMANTA
