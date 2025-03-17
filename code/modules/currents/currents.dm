//slightly cursed path because we just want the "immune to everything" quality
//maybe this should just be a turf component/var?
//Idk how the performance overhead of all these objects compares to defining Crossed/Uncrossed on every ocean turf
/obj/effects/current
	//TODO: remove this debug icon
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrow"
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

//TODO: make this spawn junk occasionally?
/obj/landmark/current_spawner
	name = "current spawner"
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrow"
	add_to_landmarks = TRUE
	deleted_on_start = FALSE
	var/width = 3
	///How far the current can curve away from the center, used to keep it vaguely straight
	var/max_variance = 4
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

		var/turf/T = get_turf(src)
		var/left_delta = 0
		while(istype(T, /turf/space/fluid))
			//pick a turn dir making sure it's not outside our max variance
			if (prob(10))
				if (prob(50) && left_delta < src.max_variance)
					T = src.do_corner(T, src.dir, -90)
				else if (left_delta > -src.max_variance)
					T = src.do_corner(T, src.dir, 90)
			else //just do a normal straight segment
				for (var/i in 1 to src.width)
					var/turf/spawn_turf = get_steps(T, turn(dir, 90), center_index - i)
					if (!istype(spawn_turf, /turf/space/fluid))
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
				if (!istype(spawn_turf, /turf/space/fluid))
					return null
				var/obj/effects/current/new_current = new(spawn_turf)
				if (angle > 0 && across == forward || angle < 0 && ((src.width + 1 - across) == forward))
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

