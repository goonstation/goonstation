//slightly cursed path because we just want the "immune to everything" quality
//maybe this should just be a turf component/var?
//Idk how the performance overhead of all these objects compares to defining Crossed/Uncrossed on every ocean turf
/obj/effects/current
	var/datum/force_push_controller/ocean/current/controller = null

	Crossed(atom/movable/AM)
		..()
		if (HAS_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH) || (AM.event_handler_flags & IMMUNE_OCEAN_PUSH))
			return
		APPLY_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src)
		src.controller.addAtom(AM, dir)

	Uncrossed(atom/movable/AM)
		..()
		REMOVE_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src)
		src.controller.removeAtom(AM, dir)

/obj/landmark/current_spawner
	name = "current spawner"
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrow"
	add_to_landmarks = TRUE
	deleted_on_start = FALSE
	var/width = 3
	///How far the current can curve away from the center, used to keep it vaguely straight
	var/max_variance = 3
	var/list/datum/force_push_controller/ocean/currents = list()

	init(delay_qdel = FALSE)
		if (!global.processScheduler) //wait to be set up later
			return ..()
		var/datum/controller/process/fMove/fmove_controller = global.processScheduler.getProcess("Forced movement")
		src.set_up(fmove_controller)
		..()

	//Meander
	proc/set_up(datum/controller/process/fMove/fmove_controller)
		var/center_index = (width + 1)/2
		//init our controllers for each sub-current to the side
		for (var/i in 1 to src.width)
			var/datum/force_push_controller/ocean/current/new_current = fmove_controller.requestCurrentController()
			var/dist_from_center = abs(center_index - i)
			//scale the starting flow values so the middle one is largest and they drop off towards the edges
			new_current.set_flow_rate(100 - 10 * (2 * dist_from_center) ** 2)
			currents += new_current
			new /obj/landmark/flotsam_spawner(get_steps(src, turn(src.dir, 90), i - center_index))

		var/turf/T = get_turf(src)
		//keep track of how far "left" we've moved total, so we can avoid straying too far off the original line
		var/left_delta = 0
		while(src.valid_turf(T))
			//pick a turn dir making sure it's not outside our max variance
			if (prob(10))
				if (prob(50) && left_delta > -src.max_variance)
					left_delta--
					T = src.do_corner(T, src.dir, -90)
				else if (left_delta < src.max_variance)
					left_delta++
					T = src.do_corner(T, src.dir, 90)
			else //just do a normal straight segment
				for (var/i in 1 to src.width)
					var/turf/spawn_turf = get_steps(T, turn(dir, 90), center_index - i)
					if (!src.valid_turf(spawn_turf))
						return
					var/obj/effects/current/new_current = new(spawn_turf)
					new_current.dir = dir
					new_current.controller = src.currents[i]
				T = get_step(T, dir)


	/**
	 * Build a corner segment to move the whole current one tile left or right.
	 *
	 * @param T Starting middle turf.
	 * @param dir Direction we're facing going into the turn.
	 * @param angle Angle of the turn (left or right)
	 * @return Resultant middle turf at the other end of the turn.
	 */
	proc/do_corner(turf/T, dir, angle = 90)
		var/center_index = (width + 1)/2
		for (var/forward in 1 to src.width)
			for (var/across in 1 to src.width + 1)
				var/turf/spawn_turf = get_steps(T, turn(dir, angle), across - center_index)
				if (!src.valid_turf(spawn_turf))
					return null
				var/obj/effects/current/new_current = new(spawn_turf)
				//this is just defining a diagonal line like x = y
				if ((src.width + 1 - across) == forward)
					new_current.dir = turn(dir, angle)
				else
					new_current.dir = dir
				if (across > forward)
					new_current.controller = src.currents[across - 1]
				else
					new_current.controller = src.currents[across]
			T = get_step(T, dir) //step forward one
		//we've moved width steps forward and one step to the side
		return get_step(T, turn(dir, angle))

	proc/valid_turf(turf/T)
		return istype(T, /turf/space/fluid) || istype(T, /turf/simulated/floor/plating/airless) //let currents flow over the toxins vent turf

/obj/landmark/flotsam_spawner
	add_to_landmarks = FALSE
	deleted_on_start = FALSE
	//TODO: add more to this
	var/list/flotsam_types = list(
		/obj/item/seashell = 10,
		/obj/item/raw_material/rock = 4,
		/obj/item/raw_material/scrap_metal = 3,
		/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 2, //I know these are pressed sheets but shhh, pretend they fell off a sushi boat or something
		/obj/item/reagent_containers/food/fish/shrimp = 2,
		/obj/item/raw_material/gold = 1,
		/obj/naval_mine/rusted = 0.1, //hehehe - won't damage turbines but will look scary
	)

	New()
		. = ..()
		//yes this is dumb but there'll only ever be like 3 of these on the map so I'm not making a process scheduler just for that
		//feel free to laugh at me in the future when there's 4289 of these for some reason
		SPAWN(0)
			while (!QDELETED(src))
				process()
				sleep(rand(8,12) SECONDS)

	proc/process()
		if (prob(10))
			var/type = weighted_pick(src.flotsam_types)
			var/atom/movable/thing = new type(src.loc)
			if (istype(thing, /obj/item/raw_material/scrap_metal))
				thing.setMaterial(getMaterial(pick("bohrum", "steel", "mauxite")))
			APPLY_ATOM_PROPERTY(thing, PROP_ATOM_FLOTSAM, src)
		var/datum/gas_mixture/bubble_gas = new()
		bubble_gas.temperature = T20C
		//increasingly rare as we go down the chain
		if (prob(50))
			bubble_gas.oxygen = rand(20, 40)
		else if (prob(60))
			bubble_gas.toxins = rand(20, 40)
		else if (prob(50))
			bubble_gas.nitrogen = rand(20, 40)
		else
			bubble_gas.oxygen_agent_b = rand(20, 40)
		new /obj/bubble/current(src.loc, bubble_gas)

